---
hide:
  - navigation
glightbox.auto_caption: true
tags:
  - Advanced
---
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

![Choose Virtualize in UTM](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.52.38.png){ width="500px" data-title="Start Virtualizing"}

Select Linux as the VM OS.

![Choose Linux in UTM](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.53.03.png){ width="500px" data-title="Use Apple Virtualization"}

On the Linux page - Select `Use Apple Virtualization`
and an Ubuntu 22.04 (Arm64) ISO.

![Apple Virtualization & Ubuntu 22.04 ARM64](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.54.33.png){ width="500px" }

As this is the master Kubernetes node (VM) it can be smaller than the nodes hosting the
Kinetica DB itself.

Set the memory to 8 GB and the number of CPUs to 4.

![Memory & CPUs](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.54.56.png){ width="500px" }

Set the storage to between 40-64 GB.

![Disk Size](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.55.11.png){ width="500px" }

This next step is optional if you wish to setup a shared folder between your Mac host &
the Linux VM.

![Screenshot 2024-03-26 at 20.55.34.png](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.55.34.png){ width="500px" }

The final step to create the VM is a summary. Please check the values shown and hit `Save`

![Screenshot 2024-03-26 at 20.56.12.png](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.56.12.png){ width="500px" }

You should now see your new VM in the left hand pane of the UTM UI.

![Screenshot 2024-03-26 at 20.57.03.png](..%2Fimages%2Fkinetica_mac_arm_k8s%2FScreenshot%202024-03-26%20at%2020.57.03.png){ width="500px" }

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

!!! note
    Make a note of the IP(s) for later use.

!!! success "Your VMs are complete"
    Continue installing your new VMs by following 
    [**Bare Metal/VM Installation**](kubernetes_bare_metal_vm_install.md "Install Kubernetes and Kinetica")








