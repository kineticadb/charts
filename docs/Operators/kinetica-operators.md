# Kinetica DB Operator Helm Charts


## Add Kinetica Helm Repoistory
To add the Kinetica Helm repoistory to Helm 3:-

```shell
helm repo add kinetica-operators https://kineticadb.github.io/charts
```

## Perform a Helm installation of the Kinetica Operatoes

```shell
helm install -n kinetica-system \
kinetica-operators kinetica-operators/kinetica-operators --create-namespace
```

This will install all the Kubernetes Operators required into the `kinetica-system` namespace and create the namespace
if it is not currently present.

!!! note   
    Depending on what target platform you are installing to it may be necessary to supply an additional parameter 
    pointing to a values file to successfully provision the DB.

```shell
helm install -n kinetica-system -f values.yaml --set provider=aks \
kinetica-operators kinetica-operators/kinetica-operators --create-namespace
```

The command above uses a custom `values.yaml` for helm and sets the install platform to Microsoft Azure AKS.

Currently supported `providers` are: -

* `aks` - Microsoft Azure AKS
* `eks` - Amazon AWS EKS
* `local` - Generic 'On-Prem' Kubernetes Clusters e.g. one deployed using `kubeadm`

Example Helm `values.yaml` for different Cloud Providers/On-Prem installations: -

=== "Azure AKS"

    ```yaml title="values.yaml" linenums="1" hl_lines="15 20 23 26"
    namespace: kinetica-system
    
    db:
      serviceAccount: {}
      image:
        # Kinetica DB Operator installer image
        repository: "registry.harbor.kinetica.com/kinetica/kinetica-k8s-operator"
        #  Kinetica DB Operator installer image tag
        tag: ""
    
      parameters:
        # <base64 encode of kubeconfig> of the Kubernetes Cluster to deploy to
        kubeconfig: ""
        # The storage class to use for PVCs
        storageClass: "managed-premium"
    
      storageClass:
        persist:
          # Workbench Operator Persistent Volume Storage Class
          provisioner: "disk.csi.azure.com"
        procs:
          # Workbench Operator Procs Volume Storage Class
          provisioner: "disk.csi.azure.com"
        cache:
          # Workbench Operator Cache Volume Storage Class
          provisioner: "disk.csi.azure.com"
    ```

    15 __`storageClass: "managed-premium"`__ - sets the appropriate `storageClass` for Microsoft Azure AKS Persistent Volume (PV)

    20 __`provisioner: "disk.csi.azure.com"`__ - sets the appropriate disk provisioner for the DB (Persist) filesystem for Microsoft Azure

    23 __`provisioner: "disk.csi.azure.com"`__ - sets the appropriate disk provisioner for the DB Procs filesystem for Microsoft Azure

    26 __`provisioner: "disk.csi.azure.com"`__ - sets the appropriate disk provisioner for the DB Cache filesystem for Microsoft Azure
    
=== "Amazon EKS"

    ```yaml title="values.yaml" linenums="1" hl_lines="15 20 23 26"
    namespace: kinetica-system
    
    db:
      serviceAccount: {}
      image:
        # Kinetica DB Operator installer image
        repository: "registry.harbor.kinetica.com/kinetica/kinetica-k8s-operator"
        #  Kinetica DB Operator installer image tag
        tag: ""
    
      parameters:
        # <base64 encode of kubeconfig> of the Kubernetes Cluster to deploy to
        kubeconfig: ""
        # The storage class to use for PVCs
        storageClass: "gp2"
    
      storageClass:
        persist:
          # Workbench Operator Persistent Volume Storage Class
          provisioner: "kubernetes.io/aws-ebs"
        procs:
          # Workbench Operator Procs Volume Storage Class
          provisioner: "kubernetes.io/aws-ebs"
        cache:
          # Workbench Operator Cache Volume Storage Class
          provisioner: "kubernetes.io/aws-ebs"
    ```

    15 __`storageClass: "gp2"`__ - sets the appropriate `storageClass` for Amazon EKS Persistent Volume (PV)

    20 __`provisioner: "kubernetes.io/aws-ebs"`__ - sets the appropriate disk provisioner for the DB (Persist) filesystem for Microsoft Azure

    23 __`provisioner: "kubernetes.io/aws-ebs"`__ - sets the appropriate disk provisioner for the DB Procs filesystem for Microsoft Azure

    26 __`provisioner: "kubernetes.io/aws-ebs"`__ - sets the appropriate disk provisioner for the DB Cache filesystem for Microsoft Azure

=== "On-Prem"

    --8<-- ".browserslistrc"

    ```yaml title="values.yaml" linenums="1" hl_lines="15 17"
    namespace: kinetica-system

    db:
      serviceAccount: {}
      image:
        # Kinetica DB Operator installer image
        repository: "registry.harbor.kinetica.com/kinetica/kinetica-k8s-operator"
        #  Kinetica DB Operator installer image tag
        tag: ""

      parameters:
        # <base64 encode of kubeconfig> of the Kubernetes Cluster to deploy to
        kubeconfig: ""
        # the type of installation e.g. aks, eks, local
        environment: "local"
        # The storage class to use for PVCs
        storageClass: "standard"
    
      storageClass:
        procs: {}
        persist: {}
        cache: {}
    ```

    15 __`environment: "local"`__ - tells the DB Operator to deploy the DB as a 'local' instance to the Kubernetes Cluster

    17 __`storageClass: "standard"`__ - sets the appropriate `storageClass` for the On-Prem Persistent Volume Provisioner

    !!! note "storageClass"
        
        The `storageClass` should be present in the target environment. 

        A list of available `storageClass` can be obtained using: -
     
        ```bash
        kubectl get sc
        ```

## Components

The `kinetica-db` Helm Chart wraps the deployment of a number of sub-components: -

* [Porter Operator](#porter-operator)
* [Kinetica Database Operator](#database-operator)
* [Kinetica Workbench Operator](#workbench-operator)

Installation/Upgrading/Deletion of the Kinetica Operators is done via two CRs which leverage
[porter.sh](https://porter.sh/) as the orchestrator. The corresponding Porter Operator, DB Operator &
Workbench Operator CRs are submitted by running the appropriate helm command i.e.

* install
* upgrade
* uninstall

## Porter Operator


## Database Operator

The Kinetica DB Operator installation CR for the [porter.sh](https://porter.sh) operator is: -

```yaml
apiVersion: porter.sh/v1
kind: Installation
metadata:
  annotations:
    meta.helm.sh/release-name: kinetica-operators
    meta.helm.sh/release-namespace: kinetica-system
  labels:
    app.kubernetes.io/instance: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/version: 0.1.0
    helm.sh/chart: kinetica-operators-0.1.0
    installVersion: 0.38.10
  name: kinetica-operators-operator-install
  namespace: kinetica-system
spec:
  action: install
  agentConfig:
    volumeSize: '0'
  parameters:
    environment: local
    storageclass: managed-premium
  reference: docker.io/kinetica/kinetica-k8s-operator:v7.1.9-7.rc3

```

## Workbench Operator

The Kinetica Workbench installation CR for the [porter.sh](https://porter.sh) operator is: -

```yaml
apiVersion: porter.sh/v1
kind: Installation
metadata:
  annotations:
    meta.helm.sh/release-name: kinetica-operators
    meta.helm.sh/release-namespace: kinetica-system
  labels:
    app.kubernetes.io/instance: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/version: 0.1.0
    helm.sh/chart: kinetica-operators-0.1.0
    installVersion: 0.38.10
  name: kinetica-operators-wb-operator-install
  namespace: kinetica-system
spec:
  action: install
  agentConfig:
    volumeSize: '0'
  parameters:
    environment: local
  reference: docker.io/kinetica/workbench-operator:v7.1.9-7.rc3
```

## Overriding Images Tags

```shell linenums="1" hl_lines="3 4 5 6 7"
helm install -n kinetica-system kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--set provider=aks  
--set dbOperator.image.tag=v7.1.9-7.rc3 \
--set dbOperator.image.repository=docker.io/kinetica/kinetica-k8s-operator \
--set wbOperator.image.repository=docker.io/kinetica/workbench-operator \
--set wbOperator.image.tag=v7.1.9-7.rc3
```

