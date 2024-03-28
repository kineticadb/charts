# :material-apple: Kinetica DB on Kubernetes :simple-arm:

This walkthrough will show how to install Kinetica DB on a Mac running OS X.  
The Kubernetes cluster will be running on VMs with Ubuntu Linux 22.04 ARM64. 

This solution is equivalent to a production bare metal installation and does 
not use Docker or QEMU but rather Apple native Virtualization.

The Kubernetes cluster will consist of one Master node `k8smaster1`
and two Worker nodes `k8snode1` & `k8snode2`.

The virtualization platform is [UTM](https://mac.getutm.app/). 

!!! note "Obtain a Kinetica License Key"
    A product license key will be required for install.
    Please contact [Kinetica Support](mailto:support@kinetica.com "Kinetica Support Email") to request a trial key.


Download and install UTM.

## Create the VMs

### `k8smaster1`

For this walkthrough the master node will be 4 vCPU, 8 GB RAM & 40-64 GB disk.

Start the creation of a new VM in UTM. Select `Virtualize`

![Choose Virtualize in UTM](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.52.38.png)

Select Linux as the VM OS.

![Choose Linux in UTM](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.53.03.png)

On the Linux page - Select `Use Apple Virtualization`
and an Ubuntu 22.04 (Arm64) ISO.

![Apple Virtualization & Ubuntu 22.04 ARM64](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.54.33.png)

As this is the master Kubernetes node (VM) it can be smaller than the nodes hosting the
Kinetica DB itself.

Set the memory to 8 GB and the number of CPUs to 4.

![Memory & CPUs](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.54.56.png)

Set the storage to between 40-64 GB.

![Disk Size](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.55.11.png)

This next step is optional if you wish to setup a shared folder between your Mac host &
the Linux VM.

![Screenshot 2024-03-26 at 20.55.34.png](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.55.34.png)

The final step to create the VM is a summary. Please check the values shown and hit `Save`

![Screenshot 2024-03-26 at 20.56.12.png](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.56.12.png)

You should now see your new VM in the left hand pane of the UTM UI.

![Screenshot 2024-03-26 at 20.57.03.png](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.57.03.png)

Go ahead and click the :material-play: button.

Once the Ubuntu installer comes up follow the steps selecting whichever keyboard etc. you require.

The only changes you need to make are: -

* Change the installation to `Ubuntu Server (minimized)`
* Your server's name to `k8smaster1`
* Enable OpenSSH server.

and complete the installation.

Reboot the VM, remove the ISO from the 'external' drive
. 
Log in to the VM and get the VMs IP address with

``` shell
ip a
```

Make a note of the IP for later use.

### `k8snode1` & `k8snode2`

Repeat the same process to provision one or two nodes depending on how much memory you
have available on the Mac.

You need to change the RAM size to 16 GB. You can leave the vCPU count at 4. 
For the disk size that depends on how much data you want to ingest. 
It should however be at least 4x RAM size.

Once installed again log in to the VM and get the VMs IP address with

``` shell
ip a
```

Make a note of the IP(s) for later use.

## Kubernetes Node Installation

### Setup the Kubernets Nodes 

SSH into **each of the nodes** and run the following: -

``` shell
sudo vi /etc/hosts

x.x.x.x k8smaster1
x.x.x.x k8snode1
x.x.x.x k8snode2
```

where x.x.x.x is the IP Address of the corresponding nose.

Next we need to disable Swap on Linux: -

``` shell
sudo swapoff -a

sudo vi /etc/fstab
```

comment out the swap entry in `/etc/fstab` on each node.

We are using containerd as the container runtime but in order 
to do so we need to make some system level changes on Linux.

``` shell
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

Perform the following commands on **each of the nodes**

``` shell
sudo apt update

sudo apt install -y containerd
```

Create a default `containerd` config.

``` shell
sudo mkdir -p /etc/containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml
```

Change the SystemdCgroup value to true in the containerd configuration file 
and restart the service

``` shell
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
```

Add some pre-requisite/ utility packages

``` shell 
sudo apt update

sudo apt install -y apt-transport-https ca-certificates curl gpg git
```

Download the Kubernetes public signing key

``` shell
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

Add the Kubernetes package repository

``` shell
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Install the Kubernetes installation tools

``` shell
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

``` shell 
sudo kubeadm init --pod-network-cidr 10.1.1.0/22 --apiserver-advertise-address 192.168.2.180 --kubernetes-version 1.29.2
```

Make a note of the portion of the shell output which gives the join command which
we will need to add our worker nodes to the master.

```
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.2.180:6443 --token wonuiv.v93rkizr6wvxwe6l \
	--discovery-token-ca-cert-hash sha256:046ffa6303e6b281285a636e856b8e9e51d8c755248d9d013e15ae5c5f6bb127
```

Before we add the worker nodes we can setup the `kubeconfig` so we will be able to use
`kubectl` going forwards.

``` shell
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

We can now run `kubectl` to connect to the Kubernetes API Server to display the nodes
in the newly created Kubernetes CLuster.

``` shell
kubectl get nodes
```

!!! note "STATUS = NotReady"
    From the `kubectl` output the status of the `k8smaster1` node is showing as
    `NotReady` as we have yet to install the Kubernetes Network to the cluster.
    
    We will be installing `cilium` as that provider in a future step.

!!! warning
    At this point we should complete the installations of the worker nodes to this
    same point before continuing.

Once installed we run the join on the worker nodes. Note that the command which was output
from the `kubeadm init` needs to run with `sudo`

```shell
sudo kubeadm join 192.168.2.180:6443 --token wonuiv.v93rkizr6wvxwe6l \
	--discovery-token-ca-cert-hash sha256:046ffa6303e6b281285a636e856b8e9e51d8c755248d9d013e15ae5c5f6bb127

```

Now we can again run 

``` shell
kubectl get nodes
```


Now we can see all the nodes are present in the Kubernetes Cluster.

### Install Kubernetes Networking

We now need to install a Kubernetes CNI (Container Network Interface) to enable the pod
network.

We will use Cilium as the CNI for our cluster.

``` shell title="Installing the Cilium CLI"
curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-arm64.tar.gz
sudo tar xzvfC cilium-linux-arm64.tar.gz /usr/local/bin
rm cilium-linux-arm64.tar.gz
```

You can now install Cilium with the following command: 

``` shell
cilium install
cilium status 
```

If `cilium status` shows errors you may need to wait until the Cilium pods have started.

You can check progress with

``` shell
kubectl get po -A
```

Once Cilium the Cilium pods are running

we can check the status of Cilium again by using 

``` shell
cilium status 
```

We can now recheck the Kubernetes Cluster Nodes

``` shell 
kubectl get nodes
```

and they should have `Status Ready`

### Kubernetes Node Preparation

Now we go ahead and label the nodes. Kinetica uses node labels in production clusters
where there are separate 'node groups'  configured so that the Kinetica Infrastructure 
pods are deployed on a smaller VM type and the DB itself is deployed on larger nodes
or gpu enabled nodes. 

If we were using a Cloud Provider Kubernetes these are synonymous with 
EKS Node Groups or AKS VMSS which would be created with the same two labels on two node groups.

``` shell
kubectl label node k8snode1 app.kinetica.com/pool=infra
kubectl label node k8snode2 app.kinetica.com/pool=compute
```

additionally in our case as we have created a new cluster the 'role' of the worker nodes
is not set so we can also set that. In many cases the role is already set to `worker` but here
we have some latitude.

```shell
kubectl label node k8snode1 kubernetes.io/role=kinetica-infra
kubectl label node k8snode2 kubernetes.io/role=kinetica-compute
```

Install a local path provisioner storage class. In this case we are using the
[Rancher Local Path provisioner](https://github.com/rancher/local-path-provisioner)

``` shell
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
```

We now need to set this storageclass as the default.

``` shell
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

!!! success "Kubernetes Cluster Provision Complete"
    Your basre Kubernetes Cluster is now complete and ready to have the Kinetica DB installed
    on it using the Helm Chart.

## Install Kinetica for Kubernetes using Helm

### Add the Helm Repository

``` shell
helm repo add kinetica-operators https://kineticadb.github.io/charts
helm repo update
```

Now we need to obtain a starter `values.yaml` file to pass to our Helm install.
We can download one from the `github.com/kineticadb/charts` repo.

``` shell 
    wget https://raw.githubusercontent.com/kineticadb/charts/master/kinetica-operators/values.onPrem.k8s.yaml
```

!!! note "Obtain a Kinetica License Key"
    A product license key will be required for install.
    Please contact [Kinetica Support](mailto:support@kinetica.com "Kinetica Support Email") to request a trial key.


``` sh title="Helm install kinetica-operators"
helm -n kinetica-system upgrade -i \
kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--values values.onPrem.k8s.yaml \
--set db.gpudbCluster.license="LICENSE-KEY" \
--set dbAdminUser.password="PASSWORD" \
--set global.defaultStorageClass="local-path"
```

After a few moments, follow the progression of the main database pod startup with:

``` shell title="Monitor the Kinetica installation progress"
kubectl -n gpudb get po gpudb-0 -w
```

!!! success "Kinetica DB Provision Complete"
    Once you see `gpudb-0 3/3 Running` the database is up and running.










