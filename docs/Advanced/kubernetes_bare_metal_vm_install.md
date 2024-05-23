---
hide:
  - navigation
tags:
  - Advanced
  - Installation
status: new
---
# Bare Metal/VM Installation - `kubeadm`

This walkthrough will show how to install Kinetica DB. For this example the Kubernetes cluster will be
running on 3 VMs with Ubuntu Linux 22.04 (ARM64).

This solution is equivalent to a production bare metal installation and does
not use Docker, Podman or QEMU.

The Kubernetes cluster requires 3 VMs consiting of one Master node `k8smaster1`
and two Worker nodes `k8snode1` & `k8snode2`.
 
!!! example "Purple Example Boxes"
    The purple boxes in the instructions below can be expanded for a screen recording of the 
    commands & their results.

## Kubernetes Node Installation

### Setup the Kubernetes Nodes

#### Edit `/etc/hosts`
SSH into **each of the nodes** and run the following: -

``` shell title="Edit `/etc/hosts"
sudo vi /etc/hosts

x.x.x.x k8smaster1
x.x.x.x k8snode1
x.x.x.x k8snode2
```

where x.x.x.x is the IP Address of the corresponding nose.

#### Disable Linux Swap
Next we need to disable Swap on Linux: -

??? example "Disable Swap"
    ![linux_swapoff.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_swapoff.gif)

``` shell title="Disable Swap"
sudo swapoff -a

sudo vi /etc/fstab
```

comment out the swap entry in `/etc/fstab` on each node.

#### Linux System Configuration Changes
We are using containerd as the container runtime but in order
to do so we need to make some system level changes on Linux.

??? example "Linux System Configuration Changes"
    ![linux_system_changes.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_system_changes.gif)

``` shell title="Linux System Configuration Changes"
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay

sudo modprobe br_netfilter

cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
```

### Container Runtime Installation

!!! note "Run on all nodes (VMs)"
    Run the following commands, until advised not to, on all of the VMs you created.

#### Install `containerd`

??? example "Install `containerd`"
    ![linux_install_containerd.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_containerd.gif)

``` shell title="Install `containerd`"
sudo apt update

sudo apt install -y containerd
```

#### Create a Default `containerd` Config

??? example "Create a Default `containerd` Config"
    ![linux_containerd_config.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_containerd_config.gif)

``` shell title="Create a Default `containerd` Config"
sudo mkdir -p /etc/containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml
```

#### Enable System CGroup
Change the SystemdCgroup value to true in the containerd configuration file
and restart the service

??? example "Enable System CGroup"
    ![linux_sed_cgroup.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_sed_cgroup.gif)

``` shell title="Enable System CGroup"
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
```

#### Install Pre-requisite/Utility packages

??? example "Install Pre-requisite/Utility packages"
    ![linux_utility_install.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_utility_install.gif)

``` shell title="Install Pre-requisite/Utility packages"
sudo apt update

sudo apt install -y apt-transport-https ca-certificates curl gpg git
```

#### Download the Kubernetes public signing key

??? example "Download the Kubernetes public signing key"
    ![linux_install_kubernetes_key.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_kubernetes_key.gif)

``` shell title="Download the Kubernetes public signing key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

#### Add the Kubernetes Package Repository

``` shell title="Add the Kubernetes Package Repository"
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

#### Install the Kubernetes Installation and Management Tools

??? example "Install the Kubernetes Installation and Management Tools"
    ![linux_install_kubernetes_tools.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_kubernetes_tools.gif)

``` shell title="Install the Kubernetes Installation and Management Tools"
sudo apt update

sudo apt install -y kubeadm=1.29.0-1.1  kubelet=1.29.0-1.1  kubectl=1.29.0-1.1 

sudo apt-mark hold kubeadm kubelet kubectl
```

### Initialize the Kubernetes Cluster
Initialize the Kubernetes Cluster by using kubeadm on the `k8smaster1` control plane node.

!!! note
    You will need an IP Address range for the Kubernetes Pods. This range is provided
    to `kubeadm` as part of the initialization. For our cluster of three nodes, given the
    default number of pods supported by a node (110) we need a CIDR of at least 330 distinct
    IP Addresses. Therefore, for this example we will use a `--pod-network-cidr` of
    `10.1.1.0/22` which allows for 1007 usable IPs. The reason for this is each node will
    get `/24` of the `/22` total.

    The `apiserver-advertise-address` should be the IP Address of the `k8smaster1` VM.

??? example "Initialize the Kubernetes Cluster"
    ![linux_install_kubernetes_kubeadm.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_kubernetes_kubeadm.gif)

``` shell title="Initialize the Kubernetes Cluster"
sudo kubeadm init --pod-network-cidr 10.1.1.0/22 --apiserver-advertise-address 192.168.2.180 --kubernetes-version 1.29.2
```

You should now deploy a pod network to the cluster.
Run `kubectl apply -f [podnetwork].yaml` with one of the options listed at:
[Cluster Administration Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)


Make a note of the portion of the shell output which gives the join command which
we will need to add our worker nodes to the master.

!!! note "Copy the `kudeadm join` command"
    Then you can join any number of worker nodes by running the following on each as root:

    ``` shell title="Copy the `kudeadm join` command"
    kubeadm join 192.168.2.180:6443 --token wonuiv.v93rkizr6wvxwe6l \
    --discovery-token-ca-cert-hash sha256:046ffa6303e6b281285a636e856b8e9e51d8c755248d9d013e15ae5c5f6bb127
    ```

#### Setup `kubeconfig`
Before we add the worker nodes we can setup the `kubeconfig` so we will be able to use
`kubectl` going forwards.

??? example "Setup `kubeconfig`"
    ![linux_install_kubernetes_config.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_kubernetes_config.gif)

``` shell title="Setup `kubeconfig`"
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### Connect & List the Kubernetes Cluster Nodes
We can now run `kubectl` to connect to the Kubernetes API Server to display the nodes
in the newly created Kubernetes CLuster.

??? example "Connect & List the Kubernetes Cluster Nodes"
    ![linux_install_kubernetes_kubectl_nodes_master_only.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_kubernetes_kubectl_nodes_master_only.gif)

``` shell title="Connect & List the Kubernetes Cluster Nodes"
kubectl get nodes
```

!!! note "STATUS = NotReady"
    From the `kubectl` output the status of the `k8smaster1` node is showing as
    `NotReady` as we have yet to install the Kubernetes Network to the cluster.

    We will be installing `cilium` as that provider in a future step.

!!! warning
    At this point we should complete the installations of the worker nodes to this
    same point before continuing.

#### Join the Worker Nodes to the Cluster
Once installed we run the join on the worker nodes. Note that the command which was output
from the `kubeadm init` needs to run with `sudo`

``` shell title="Join the Worker Nodes to the Cluster"
sudo kubeadm join 192.168.2.180:6443 --token wonuiv.v93rkizr6wvxwe6l \
	--discovery-token-ca-cert-hash sha256:046ffa6303e6b281285a636e856b8e9e51d8c755248d9d013e15ae5c5f6bb127
```
??? example "`kubectl get nodes`"
    ![linux_install_kubernetes_kubectl_nodes_all.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_kubernetes_kubectl_nodes_all.gif)

Now we can again run

``` shell title="`kubectl get nodes`"
kubectl get nodes
```

Now we can see all the nodes are present in the Kubernetes Cluster.

!!! note "Run on Head Node only"
    From now the following cpmmands need to be run on the Master Node only..

### Install Kubernetes Networking

We now need to install a Kubernetes CNI (Container Network Interface) to enable the pod
network.

We will use Cilium as the CNI for our cluster.

``` shell title="Installing the Cilium CLI"
curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-arm64.tar.gz
sudo tar xzvfC cilium-linux-arm64.tar.gz /usr/local/bin
rm cilium-linux-arm64.tar.gz
```

#### Install `cilium`
You can now install Cilium with the following command:

``` shell title="Install `cilium`" 
cilium install
cilium status 
```

If `cilium status` shows errors you may need to wait until the Cilium pods have started.

You can check progress with

``` shell
kubectl get po -A
```

#### Check `cilium` Status
Once Cilium the Cilium pods are running we can check the status of Cilium again by using

??? example "Check `cilium` Status"
    ![linux_install_CNI_cilium_status.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_CNI_cilium_status.gif)

``` shell title="Check `cilium` Status"
cilium status 
```

We can now recheck the Kubernetes Cluster Nodes

![linux_install_CNI_cilium_nodes_ready.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_CNI_cilium_nodes_ready.gif)

``` shell 
kubectl get nodes
```

and they should have `Status Ready`

### Kubernetes Node Preparation

#### Label Kubernetes Nodes
Now we go ahead and label the nodes. Kinetica uses node labels in production clusters
where there are separate 'node groups'  configured so that the Kinetica Infrastructure
pods are deployed on a smaller VM type and the DB itself is deployed on larger nodes
or gpu enabled nodes.

If we were using a Cloud Provider Kubernetes these are synonymous with
EKS Node Groups or AKS VMSS which would be created with the same two labels on two node groups.

``` shell title="Label Kubernetes Nodes"
kubectl label node k8snode1 app.kinetica.com/pool=infra
kubectl label node k8snode2 app.kinetica.com/pool=compute
```

additionally in our case as we have created a new cluster the 'role' of the worker nodes
is not set so we can also set that. In many cases the role is already set to `worker` but here
we have some latitude.

![linux_install_node_labels.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_node_labels.gif)

```shell
kubectl label node k8snode1 kubernetes.io/role=kinetica-infra
kubectl label node k8snode2 kubernetes.io/role=kinetica-compute
```

#### Install Storage Class
Install a local path provisioner storage class. In this case we are using the
[Rancher Local Path provisioner](https://github.com/rancher/local-path-provisioner)

??? example "Install Storage Class"
    ![linux_install_storage_class_rancher.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_storage_class_rancher.gif)

``` shell title="Install Storage Class"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
```

## Set Default Storage Class

??? example "Set Default Storage Class"
    ![linux_install_storage_class_rancher_set_default.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_storage_class_rancher_set_default.gif)

``` shell title="Set Default Storage Class"
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

!!! success "Kubernetes Cluster Provision Complete"
    Your basre Kubernetes Cluster is now complete and ready to have the Kinetica DB installed
    on it using the Helm Chart.

## Install Kinetica for Kubernetes using Helm

### Add the Helm Repository

??? example "Add the Helm Repository"
    ![linux_install_helm_repo.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_helm_repo.gif)

``` shell title="Add the Helm Repository"
helm repo add kinetica-operators https://kineticadb.github.io/charts
helm repo update
```

#### Download a Starter Helm `values.yaml`
Now we need to obtain a starter `values.yaml` file to pass to our Helm install.
We can download one from the `github.com/kineticadb/charts` repo.

??? example "Download a Starter Helm `values.yaml`"
    ![linux_install_helm_get_values.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_helm_get_values.gif)

``` shell title="Download a Starter Helm `values.yaml`"
    wget https://raw.githubusercontent.com/kineticadb/charts/master/kinetica-operators/values.onPrem.k8s.yaml
```

!!! note "Obtain a Kinetica License Key"
    A product license key will be required for install.
    Please contact [Kinetica Support](mailto:support@kinetica.com "Kinetica Support Email") to request a trial key.

#### Helm Install Kinetica
??? example "#### Helm Install Kinetica"
    ![linux_install_helm.gif](..%2Fimages%2Fkinetica_mac_arm_k8s%2Flinux_install_helm.gif)

``` sh title="Helm install kinetica-operators"
helm -n kinetica-system upgrade -i \
kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--values values.onPrem.k8s.yaml \
--set db.gpudbCluster.license="LICENSE-KEY" \
--set dbAdminUser.password="PASSWORD" \
--set global.defaultStorageClass="local-path"
```

#### Monitor Kinetica Startup
After a few moments, follow the progression of the main database pod startup with:

``` shell title="Monitor the Kinetica installation progress"
kubectl -n gpudb get po gpudb-0 -w
```

!!! success "Kinetica DB Provision Complete"
    Once you see `gpudb-0 3/3 Running` the database is up and running.

---

!!! note "Software LoadBalancer"
    If you require a software based LoadBalancer to allocate IP address to the 
    Ingress Controller or
    exposed Kubernetes Services then [**_see here_**](kube_vip_loadbalancer.md)

    This is usually apparent if your ingress or other Kubernetes Services with the type
    `LoadBalancer` are stuck in the `Pending` state.

---
