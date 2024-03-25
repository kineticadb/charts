---
hide:
  - navigation
  - toc
---
# `ingress-nginx` Ingress Configuration


#### Coming Soon

### Exposing the Postgres Proxy Port

In order to access Kinetica's Postgres functionality some TCP (not HTTP) ports need to be open externally.

For `ingress-nginx` a configuration file needs to be created to enable port 5432.

```  yaml title="tcp-services.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: kinetica-system # (1)!
data:
  '5432': gpudb/kinetica-k8s-sample-rank0-service:5432 #(2)!
```
1. Change the namespace to the namespace your ingress-nginx controller is running in. e.g. `ingress-nginx`  
2. This exposes the postgres proxy port on the default 5432 if you wish to change this to a non-standard port then it needs to be changed here but also in the Helm `values.yaml` to match. 
---

[:octicons-arrow-left-24: Ingress Configuration](ingress_configuration.md "Ingress Configuration")

[:octicons-arrow-up-24:  Advanced Topics](index.md "Advanced Topics")

