
# Overview

Kinetica Operators can be installed in any on-prem kubernetes cluster. This document provides instructions to install the operators in k3s. If you are on another distribution, you should be able to change the values file to suit your environment.

You will need a license key for this to work. Please contact [Kinetica Support](support@kinetica.com).

## Kinetica on k3s (k3s.io)

Current version of the chart supports kubernetes version 1.25 and above.

### Install k3s 1.29

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.29.1+k3s2 sh -
```


#### K3s -Install kinetica-operators including a sample db to try out

Review the values file charts/kinetica-operators/values.onPrem.k3s.yaml. This is trying to install the operators and a simple db with workbench installation for a non production try out.

As you can see it is trying to create an ingress pointing towards local.kinetica. If you have a domain pointing to your machine, replace it with the correct domain name.

If you are on a local machine which is not having a domain name, you add the following entry to your /etc/hosts file or equivalent.

```text
127.0.0.1 local.kinetica
```

##### K3s - Install the kinetica-operators chart



```bash
helm -n kinetica-system install kinetica-operators kinetica-operators/kinetica-operators --create-namespace --values charts/kinetica-operators/values.onPrem.k3s.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password"

# if you want to try out a development version,
helm search repo kinetica-operators --devel --versions

helm -n kinetica-system install kinetica-operators kinetica-operators/kinetica-operators --create-namespace --values charts/kinetica-operators/values.onPrem.k3s.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password" --devel --version 7.2.0-2.rc-2

```

##### K3s - Install the kinetica-operators chart (GPU Capable Machine)

If you wish to try out the GPU capabilities, you can use the following values file, provided you are in a nvidia gpu capable machine.

```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.k3s.gpu.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password"
```

You should be able to access the workbench at [http://local.kinetica](http://local.kinetica)

Username as per the values file mentioned above is kadmin and password is Kinetica1234!

## Uninstall k3s

```bash
/usr/local/bin/k3s-uninstall.sh
```