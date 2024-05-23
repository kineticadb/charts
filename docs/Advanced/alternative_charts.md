---
hide:
  - navigation
  - toc
tags:
    - Advanced
    - Installation
---
# :simple-helm: Using Alternative Helm Charts

If requested by Kinetica Support you can search and use pre-release versions of the Kinetica Helm Charts.

## Install from a development/pre-release chart version

Find all alternative chart versions with:

``` sh title="Find alternative chart versions"
helm search repo kinetica-operators --devel --versions
```

![helm_alternative_versions](../images/helm_alternative_versions.gif)

Then append `--devel --version [CHART-DEVEL-VERSION]` to the end of the Helm install command.

``` sh title="Helm install kinetica-operators"
helm -n kinetica-system install \
kinetica-operators kinetica-operators/kinetica-operators \
--create-namespace \
--devel \
--version 72.0 \
--values values.onPrem.k8s.yaml \
--set db.gpudbCluster.license="LICENSE-KEY" \
--set dbAdminUser.password="PASSWORD" \
--set global.defaultStorageClass="DEFAULT-STORAGE-CLASS"
```

---
