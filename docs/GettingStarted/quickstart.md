---
hide:
    - navigation
tags:
    - Getting Started
---
# :material-clock-fast: Quickstart

For the quickstart we have examples for [Kind](https://kind.sigs.k8s.io "Kind Homepage") or
[k3s](https://k3s.io "k3s Homepage").

* Kind - is suitable for CPU only installations.
* k3s - is suitable for CPU or GPU installations.

!!! note "Kubernetes >= 1.25"
    The current version of the chart supports kubernetes version 1.25 and above.

## Please select your target Kubernetes variant:

=== "kind"

    ### Kind (kubernetes in docker kind.sigs.k8s.io)
    This installation in a kind cluster is for trying out the operators and the database
    in a non-production environment.
    
    !!! note "CPU Only"
        This method currently only supports installing a CPU version of the database.
    
        **Please contact [Kinetica Support](mailto:support@kinetica.com "Kinetica Support Email") to request a trial key.**
    
    #### Create Kind Cluster 1.29
    
    ``` sh title="Create a new Kind Cluster"
    wget https://raw.githubusercontent.com/kineticadb/charts/{{kinetica_full_version}}/kinetica-operators/kind.yaml
    kind create cluster --name kinetica --config kind.yaml
    ```

    ```shell title="List Kind clusters"
     kind get clusters
    ```

    !!! tip "Set Kubernetes Context"
        Please set your Kubernetes Context to `kind-kinetica` before performing the following steps. 
    
    #### Kind - Install kinetica-operators including a sample db to try out
    
    Review the values file charts/kinetica-operators/values.onPrem.kind.yaml. 
    This is trying to install the operators and a simple db with workbench 
    installation for a non production try out.
    
    As you can see it is trying to create an ingress pointing towards local.kinetica. 
    If you have a domain pointing to your machine, replace it with the correct domain name.
    
    ##### Kind - Install the  Kinetica-Operators Chart

    --8<-- "docs/GettingStarted/helm_repo_add.md"

    ``` sh title="Get & install the Kinetica-Operators Chart"
    wget https://raw.githubusercontent.com/kineticadb/charts/{{kinetica_full_version}}/kinetica-operators/values.onPrem.kind.yaml

    helm -n kinetica-system upgrade -i kinetica-operators kinetica-operators/kinetica-operators --create-namespace --values values.onPrem.kind.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password"
    ```
    
    or if you have been asked by the Kinetica Support team to try a development version

    ``` sh title="Using a development version"

    helm search repo kinetica-operators --devel --versions

    helm -n kinetica-system upgrade -i kinetica-operators kinetica-operators/kinetica-operators/ --create-namespace --values values.onPrem.kind.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password" --devel --version {{helm_chart_version}}
    ```
 
    !!! success "Accessing the Workbench"
        You should be able to access the workbench at [http://local.kinetica](http://local.kinetica "Workbench URL")

    
=== ":simple-k3s: k3s"
    ### k3s (k3s.io)
    
    #### Install k3s 1.29
    
    ``` sh title="Install k3s"
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.29.2+k3s1 sh -
    ```

    Once installed we need to set the current Kubernetes context to point to the newly
    created k3s cluster.

    Select if you want local or remote access to the Kubernetes Cluster: -

    === "Local Access"
        For only local access to the cluster we can simply set the `KUBECONFIG` 
        environment variable

        ``` shell title="Set kubectl context"
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        ```
    === "Remote Access"
        For remote access i.e. outside the host/VM k3s is installed on: -

        Copy `/etc/rancher/k3s/k3s.yaml` on your machine located 
        outside the cluster as `~/.kube/config`. 
        Then edit the file and replace the value of the server 
        field with the IP or name of your K3s server.

        ```shell title="Copy the kube config and set the context"
        sudo chmod 600 /etc/rancher/k3s/k3s.yaml
        mkdir -p ~/.kube
        sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
        sudo chown "${USER:=$(/usr/bin/logname)}:$USER" ~/.kube/config
        # Edit the ~/.kube/config server field with the IP or name of your K3s server here
        export KUBECONFIG=~/.kube/config
        ```

    #### K3s - Install kinetica-operators including a sample db to try out

    Review the values file `charts/kinetica-operators/values.onPrem.k3s.yaml`. 
    This is trying to install the operators and a simple db with workbench installation 
    for a non production try out.
    
    As you can see it is trying to create an ingress pointing towards `local.kinetica`. 
    If you have a domain pointing to your machine, replace it with the correct domain name.
    
    If you are on a local machine which is not having a domain name, 
    you add the following entry to your `/etc/hosts` file or equivalent.
    
    ```shell title="Configure local acces - /etc/hosts"
    127.0.0.1  local.kinetica
    ```
   
    #### K3S - Install the  Kinetica-Operators Chart (CPU)

    --8<-- "docs/GettingStarted/helm_repo_add.md"

    ``` shell title="Download Template values.yaml" 
    wget https://raw.githubusercontent.com/kineticadb/charts/master/kinetica-operators/values.onPrem.k3s.yaml
    
    helm -n kinetica-system install kinetica-operators kinetica-operators/kinetica-operators --create-namespace --values values.onPrem.k3s.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password"
    ```

    or if you have been asked by the Kinetica Support team to try a development version

    ``` sh title="Using a development version"
    helm search repo kinetica-operators --devel --versions
    
    helm -n kinetica-system install kinetica-operators kinetica-operators/kinetica-operators --create-namespace --values values.onPrem.k3s.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password" --devel --version 7.2.0-2.rc-2
    ```

    #### K3S - Install the  Kinetica-Operators Chart (GPU)

    If you wish to try out the GPU capabilities, you can use the following values file, 
    provided you are in a nvidia gpu capable machine.
    
    ``` sh title="k3s GPU Installation"
    wget https://raw.githubusercontent.com/kineticadb/charts/master/kinetica-operators/values.onPrem.k3s.gpu.yaml
    
    helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values values.onPrem.k3s.gpu.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password"
    ```
    
    !!! success "Accessing the Workbench"
        You should be able to access the workbench at [http://local.kinetica](http://local.kinetica "Workbench URL")
     
    #### Uninstall k3s

    ``` sh title="uninstall k3s"
    /usr/local/bin/k3s-uninstall.sh
    ```

---

!!! note "Default User"
    Username as per the values file mentioned above is `kadmin` and password is `Kinetica1234!`
