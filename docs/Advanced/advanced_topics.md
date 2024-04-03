---
hide:
  - navigation
  - toc
tags:
  - Advanced
---

# :material-ninja: Advanced Topics

## Install from a development/pre-release chart version

Find all alternative chart versions with:

``` sh title="Find alternative chart versions"
helm search repo kinetica-operators --devel --versions
```

![helm_alternative_versions](../images/helm_alternative_versions.gif)

Then append `--devel --version [CHART-DEVEL-VERSION]` to the end of the Helm install command. _See_ [
_here_](../GettingStarted/installation.md#4-install-the-helm-chart).

---
