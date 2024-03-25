# Advanced Topics

## Install from a development/pre-release chart version

Find all alternative chart versions with:

``` sh title="Find alternative chart versions"
helm search repo kinetica-operators --devel --versions
```

![helm_alternative_versions](../images/helm_alternative_versions.gif)

Then append `--devel --version [CHART-DEVEL-VERSION]` to the end of the Helm install command. _See_ [
_here_](../GettingStarted/installation.md#4-install-the-helm-chart).

---

--- 

## Using your own OpenTelemetry Collector

### Coming Soon

---

## Configuring Ingress Records

### ingress-nginx

#### Coming Soon

### nginx-ingress

#### Coming Soon

---

## Bare Metal LoadBalancer

### kube-vip

[kube-vip](https://kube-vip.io/) provides Kubernetes clusters with a virtual IP and load balancer for both
the control plane (for building a highly-available cluster) and Kubernetes Services of type LoadBalancer without relying
on any external hardware or software.

#### Coming Soon

 ## Integration with Kerberos

#### Coming Soon