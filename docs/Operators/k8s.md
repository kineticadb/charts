
# Overview

For managed Kubernetes solutions (AKS, EKS, GKE) or other on-prem K8s flavors, 
follow this generic guide to install the Kinetica Operators, Database and Workbench. 
A product license key will be required for install. Please contact [Kinetica Support](mailto:support@kinetica.com) 
to request a trial key.

## Preparation and prerequisites

Installation requires **Helm3** and access to an on-prem or CSP managed Kubernetes cluster. 
**kubectl** is optional but highly recommended.
The context for the desired target cluster must be selected from your `~/.kube/config` file 
or set via the `KUBECONFIG` environment variable. Check to see if you have the correct context with,

```bash
kubectl config current-context
```

and that you can access this cluster correctly with,

```bash
kubectl get nodes
```

If you do not see a list of nodes for your K8s cluster the helm installation will not work. Please check your Kubernetes installation or access credentials (kubeconfig).

## Install the kinetica-operators chart

This chart will install the Kinetica K8s operators together with a default configured database and workbench UI.

If you are installing into a managed Kubernetes environment and the NGINX ingress controller that is installed as part of this install creates a LoadBalancer service, you may need to associate the LoadBalancer with the domain you plan to use.

Alternatively, if you are installing on a local machine which does not have a domain name, you can add the following entry to your `/etc/hosts` file or equivalent:

```bash
127.0.0.1  local.kinetica
```

Note that the default chart configuration points to `local.kinetica` but this is configurable.

### 1. Add the Kinetica chart repository

Add the repo locally as *kinetica-operators*:

```bash
helm repo add kinetica-operators https://kineticadb.github.io/charts
```

### 2. Obtain the default Helm values file

For the generic Kubernetes install use the following values file without modification. Advanced users with specific requirements may need to adjust parameters in this file.

```bash
wget https://raw.githubusercontent.com/kineticadb/charts/master/kinetica-operators/values.onPrem.k8s.yaml
```

### 3. Determine the following prior to the chart install

(a) Obtain a LICENSE-KEY as described in the introduction above.
(b) Choose a PASSWORD for the initial administrator user (Note: the default in the chart for this user is `kadmin` but this is configurable). Non-ASCII characters and typographical symbols in the password must be escaped with a "\". For example, `--set dbAdminUser.password="MyPassword\!"`
(c) As storage class name varies between K8s flavor and/or there can be multiple, this must be prescribed in the chart installation. Obtain DEFAULT-STORAGE-CLASS name with the command:

```bash
kubectl get sc -o name 
```

use the name found after the /, For example, in `"storageclass.storage.k8s.io/TheName"` use "TheName" as the parameter.

### 4. Install the helm chart

Run the following Helm install command after substituting values from section 3 above:

```bash
helm -n kinetica-system install \
kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--values values.onPrem.k8s.yaml \
--set kineticacluster.gpudbCluster.license="LICENSE-KEY" \
--set dbAdminUser.password="PASSWORD" \
--set global.defaultStorageClass="DEFAULT-STORAGE-CLASS"
```

### 5. Check installation progress

After a few moments, follow the progression of the main database pod startup with:

```bash
kubectl -n gpudb get po gpudb-0 -w
```

until it reaches `"gpudb-0  3/3  Running"` at which point the database should be ready and all other software installed in the cluster. You may have to run this command in a different terminal if the `helm` command from step 4 has not yet returned to the system prompt. Once running, you can quit this kubectl watch command using *ctrl-c*.

### 6. Accessing the Kinetica installation

## (Optional) Install a development chart version

Find all alternative chart versions with:

```bash
helm search repo kinetica-operators --devel --versions
```

Then append `--devel --version [CHART-DEVEL-VERSION]` to the end of the Helm install command in section 4 above.

## K8s Flavour specific notes

### EKS

#### EBS CSI driver

Make sure you have enabled the ebs-csi driver in your EKS cluster. This is required for the default storage class to work. Please refer to this [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) for more information.

#### Ingress

As of now, the kinetica-operator chart installs NGINX ingress controller. So after the installation is complete, you may need to edit the KineticaCluster Custom Resource and Workbench Custom Resource with the correct domain name.

##### Option 1: Use the LoadBalancer domain

```bash
kubectl get svc -n kinetica-system
# look at the loadbalancer dns name, copy it

kubectl -n gpudb edit $(kubectl -n gpudb get kc -o name)
# replace local.kinetica with the loadbalancer dns name
kubectl -n gpudb edit $(kubectl -n gpudb get wb -o name)
# replace local.kinetica with the loadbalancer dns name
# save and exit
# you should be able to access the workbench from the loadbalancer dns name
```

##### Option 1: Use your custom domain

Create a record in your DNS server pointing to the LoadBalancer DNS. Then edit the KineticaCluster Custom Resource and Workbench Custom Resource with the correct domain name, as mentioned above.


---
