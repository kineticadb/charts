
# Overview

If you are on a kubernetes flavour other than Kind or K3s, you may follow this generic guide to install the Kinetica Operators.

You will need a license key for this to work. Please contact [Kinetica Support](support@kinetica.com).



## Install the kinetica-operators chart

This is trying to install the operators and a simple db with workbench installation.

If you are in a managed Kubernetes environment, and your nginx ingress controller which is installed along with this install creates a LoadBalancer service, you may need to make sure you associate the LoadBalancer to the domain you are using. If you are on a local machine which is not having a domain name, you add the following entry to your /etc/hosts file or equivalent.

If you are on a local machine which is not having a domain name, you add the following entry to your /etc/hosts file or equivalent. By default, the default chart configuration is pointing to local.kinetica.

```text
127.0.0.1 local.kinetica
```

```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.k8s.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password" --set global.defaultStorageClass="your_default_storage_class"
```



