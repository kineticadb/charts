---
hide:
  - navigation
tags:
  - Installation
icon: material/emoticon-happy
---
# :simple-nvidia: Installation - CPU with GPU Acceleration

For managed Kubernetes solutions (AKS, EKS, GKE), OpenShift or on-prem (kubeadm) Kubernetes variants,
follow this generic guide to install the Kinetica Operators, Database and Workbench.

!!! warning "Preparation & Prequisites"
    Please make sure you have followed the [Preparation & Prequisites steps](preparation_and_prerequisites.md)

### Install via the `kinetica-operators` Helm Chart

#### GPU Cluster with Remote SQLAssistant

Run the following Helm install command after substituting values from
[section 3](preparation_and_prerequisites.md#3-determine-the-following-prior-to-the-chart-install)

``` sh title="Helm install kinetica-operators (No On-Prem SQLAssistant)"
helm -n kinetica-system install \
kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--values values.onPrem.k8s.yaml \
--set db.gpudbCluster.license="LICENSE-KEY" \
--set dbAdminUser.password="PASSWORD" \
--set global.defaultStorageClass="DEFAULT-STORAGE-CLASS"
```

#### GPU Cluster with On-Prem SQLAssistant 

or to enable SQLAssistant to be deployed and run 'On-Prem' i.e. in the same cluster

``` sh hl_lines="8" title="Helm install kinetica-operators (With On-Prem SQLAssistant)"
helm -n kinetica-system install \
kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--values values.onPrem.k8s.yaml \
--set db.gpudbCluster.license="LICENSE-KEY" \
--set dbAdminUser.password="PASSWORD" \
--set global.defaultStorageClass="DEFAULT-STORAGE-CLASS"
--set db.gpudbCluster.config.ai.apiProvider = "kineticallm"
```


--8<-- "docs/GettingStarted/note_additional_gpu_sqlassistant.md"

### Check installation progress

After a few moments, follow the progression of the main database pod startup with:

``` sh title="Monitor the Kinetica installation progress"
kubectl -n gpudb get po gpudb-0 -w
```

until it reaches `"gpudb-0  3/3  Running"` at which point the database should be ready and all other software installed
in the cluster. You may have to run this command in a different terminal if the `helm` command from step 4 has not yet
returned to the system prompt. Once running, you can quit this kubectl watch command using ++ctrl+c++.

??? failure "error no pod named gpudb-0"
    If you receive an error message running `kubectl -n gpudb get po gpudb-0 -w` informing you that no pod
    named `gpudb-0` exists. Please check that the OpenLDAP pod is running by running
    
    ```shell title="Check OpenLDAP status"
    kubectl -n gpudb get pods
    kubectl -n gpudb describe pod openldap-5f87f77c8b-trpmf
    ```

    where the pod name `openldap-5f87f77c8b-trpmf` is that shown when running `kubectl -n gpudb get pods`
    
    Validate if the pod is waiting for it's Persistent Volume Claim/Persistent Volume to be created
    and bound to the pod.

### Accessing the Kinetica installation

## Target Platform Specifics

=== "cloud"
    If you are installing into a managed Kubernetes environment and the NGINX ingress controller that is installed
    as part of this install creates a LoadBalancer service, you may need to associate the LoadBalancer with the domain
    you plan to use.

     As of now, the kinetica-operator chart installs NGINX ingress controller.
     So after the installation is complete, you may need to edit the KineticaCluster Custom Resource
     and Workbench Custom Resource with the correct domain name.
    
     Option 1: Use the LoadBalancer domain
     ``` sh title="Set your FQDN in Kinetica"
     kubectl get svc -n kinetica-system
     # look at the loadbalancer dns name, copy it
    
     kubectl -n gpudb edit $(kubectl -n gpudb get kc -o name)
     # replace local.kinetica with the loadbalancer dns name
     kubectl -n gpudb edit $(kubectl -n gpudb get wb -o name)
     # replace local.kinetica with the loadbalancer dns name
     # save and exit
     # you should be able to access the workbench from the loadbalancer dns name
     ```

     Option 2: Use your custom domain
     Create a record in your DNS server pointing to the LoadBalancer DNS. Then edit the KineticaCluster Custom Resource and Workbench Custom Resource with the correct domain name, as mentioned above.

=== "OpenShift"
    OpenShift Container Platform version 4 is supported. If you are installing on this 
    flavor of Kubernetes, SecurityContextConstraints are required for some of the Kinetica
    components. To install these add the folowing set to the main Helm install kinetica-operators
    command above:

    ```sh title=""
    --set openshift="true"
    ```

    !!! note 
        The defaultStorageClass must still be set for installation to proceed. Run `oc get sc` 
        to determine available choices.

=== "local - dev"
    Installing on a local machine which does not have a domain name,
    you can add the following entry to your `/etc/hosts` file or equivalent:

    ``` sh title="Configure local acces - /etc/hosts"
    127.0.0.1  local.kinetica
    ```
    
    !!! note 
        The default chart configuration points to `local.kinetica` but this is configurable.

=== "bare metal - prod"
    Installing on a bare metal machines which do not have an external hardware loadbalancer requires an
    Ingress controller along with a software loadbalancer in order to be accessible.

    Kinetica for Kubernetes has been tested with 
    [kube-vip](https://kube-vip.io/ "Software Loadbalancer for bare metal installations")

--- 
