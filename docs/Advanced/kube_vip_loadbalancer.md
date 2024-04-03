---
hide:
  - navigation
---
# Kubernetes Cluster LoadBalancer for Bare Metal/VM Installations

For our example we are going to enable a Kubernetes based LoadBalancer to issue
IP addresses to our Kubernetes Services of type `LoadBalancer` using
[`kube-vip`](https://kube-vip.io/).

## `kube-vip`

We will install two components into our Kubernetes CLuster

* [kube-vip-cloud-controller](https://kube-vip.io/docs/usage/cloud-provider/)
* [Kubernetes Load-Balancer Service](https://kube-vip.io/docs/usage/kubernetes-services/)

### kube-vip-cloud-controller

!!! quote
    The kube-vip cloud provider can be used to populate 
    an IP address for Services of type LoadBalancer similar to what 
    public cloud providers allow through a Kubernetes CCM.


```shell title="Install the kube-vip CCM"
kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml
```

Now we need to setup the required RBAC permissions: -

```shell
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml
```

The following ConfigMap will configure the `kube-vip-cloud-controller` to obtain
IP addresses from the host networks DHCP server. i.e. the DHCP
on the physical network that the host machine or VM is connected to.

```yaml
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

```yaml
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

Example showing DHCP allocated external IP address to the Ingress Controller.

![ingress_not_pending.png](..%2Fimages%2Fingress_not_pending.png)

---
[:material-arrow-expand-up:  Home](../index.md "Home Page")