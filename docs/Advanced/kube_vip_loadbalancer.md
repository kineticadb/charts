---
hide:
  - navigation
tags:
  - Advanced
  - Ingress
---
# Kubernetes Cluster LoadBalancer for Bare Metal/VM Installations

For our example we are going to enable a Kubernetes based LoadBalancer to issue
IP addresses to our Kubernetes Services of type `LoadBalancer` using
[`kube-vip`](https://kube-vip.io/).

??? example "Ingress Service is pending"
    The `ingress-nginx-controller` is currently in the `pending` state as there is no CCM/LoadBalancer
    ![pending_service.gif](..%2Fimages%2Fkube_vip%2Fpending_service.gif)

## `kube-vip`

We will install two components into our Kubernetes CLuster

* [kube-vip-cloud-controller](https://kube-vip.io/docs/usage/cloud-provider/)
* [Kubernetes Load-Balancer Service](https://kube-vip.io/docs/usage/kubernetes-services/)

### kube-vip-cloud-controller

!!! quote
    The kube-vip cloud provider can be used to populate 
    an IP address for Services of type LoadBalancer similar to what 
    public cloud providers allow through a Kubernetes CCM.

??? example "Install the kube-vip CCM"
    ![kube_vip_install_ccm.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_install_ccm.gif)

```shell title="Install the kube-vip CCM"
kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml
```

Now we need to setup the required RBAC permissions: -

??? example "Install the kube-vip RBAC"
    ![kube_vip_install_rbac.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_install_rbac.gif)

```shell title="Install kube-vip RBAC"
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml
```

The following ConfigMap will configure the `kube-vip-cloud-controller` to obtain
IP addresses from the host networks DHCP server. i.e. the DHCP
on the physical network that the host machine or VM is connected to.

??? example "Install the kube-vip ConfigMap"
    ![kube_vip_install_configmap.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_install_configmap.gif)

```yaml title="Install the kube-vip ConfigMap"
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubevip
  namespace: kube-system
data:
  cidr-global: 0.0.0.0/32
```

It is possible to specify IP address ranges see [here](https://kube-vip.io/docs/usage/cloud-provider/).

### Kubernetes Load-Balancer Service

??? example "Obtain the Master Node IP address & Interface name"
    ![kube_vip_install_ip_a.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_install_ip_a.gif)

```shell title="Obtain the Master Node IP address & Interface name"
ip a
```

In this example the network interface of the master node is `192.168.2.180` and the interface is
`enp0s1`.

We need to apply the `kube-vip` daemonset but first we 
??? example "Install the kube-vip Daemonset"
    ![kube_vip_install_daemonset.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_install_daemonset.gif)

```yaml title="Install the kube-vip Daemonset"
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app.kubernetes.io/name: kube-vip-ds
    app.kubernetes.io/version: v0.7.2
  name: kube-vip-ds
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: kube-vip-ds
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kube-vip-ds
        app.kubernetes.io/version: v0.7.2
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/master
                operator: Exists
            - matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: Exists
      containers:
      - args:
        - manager
        env:
        - name: vip_arp
          value: "true"
        - name: port
          value: "6443"
        - name: vip_interface
          value: enp0s1
        - name: vip_cidr
          value: "32"
        - name: dns_mode
          value: first
        - name: cp_enable
          value: "true"
        - name: cp_namespace
          value: kube-system
        - name: svc_enable
          value: "true"
        - name: svc_leasename
          value: plndr-svcs-lock
        - name: vip_leaderelection
          value: "true"
        - name: vip_leasename
          value: plndr-cp-lock
        - name: vip_leaseduration
          value: "5"
        - name: vip_renewdeadline
          value: "3"
        - name: vip_retryperiod
          value: "1"
        - name: address
          value: 192.168.3.199
        - name: prometheus_server
          value: :2112
        image: ghcr.io/kube-vip/kube-vip:v0.7.2
        imagePullPolicy: Always
        name: kube-vip
        resources: {}
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
            - NET_RAW
      hostNetwork: true
      serviceAccountName: kube-vip
      tolerations:
      - effect: NoSchedule
        operator: Exists
      - effect: NoExecute
        operator: Exists
  updateStrategy: {}
```

!!! note "ARP or BGP"
    The Daemonset above uses ARP to communicate with the network it is also possible to use BGP.
    [**_See Here_**](https://kube-vip.io/docs/installation/daemonset/#bgp-example-for-daemonset)

??? example "Example showing DHCP allocated external IP address to the Ingress Controller"
    ![ingress_not_pending.png](..%2Fimages%2Fingress_not_pending.png)

Our `ingress-nginx-controller` has been allocated the IP Address `192.168.2.194`.  

!!! note "Ingress Access"
    The `ingress-niginx-controller` requires the host FQDN to be on the user requests in order to know
    how to route the requests to the correct Kubernetes Service. Using the iP address in the URL will cause
    an error as ingress cannot select the correct service.

??? example "List Ingress"
    ![kube_vip_get_ing.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_get_ing.gif)

![get_ing.png](..%2Fimages%2Fkube_vip%2Fget_ing.png)

If you did not set the FQDN of the Kinetica Cluster to a DNS resolvable hostname add `local.kinetica`
to your `/etc/hosts/` file in order to be able to access the Kinetica URLs

??? example "Edit /etc/hosts"
    ![kube_vip_etc_hosts.gif](..%2Fimages%2Fkube_vip%2Fkube_vip_etc_hosts.gif)

!!! success "Accessing the Workbench"
    You should be able to access the workbench at [http://local.kinetica](http://local.kinetica "Workbench URL")


---
