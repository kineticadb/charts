# Overview

This repository provides the helm chart for deploying the Kubernetes Operators for Database and Workbench. Once the operators are installed, you should be able to use the Kinetica Database and Workbench CRDs to deploy and manage Kinetica clusters and workbenches.


## Add Kinetica Helm Repository

To add the Kinetica Helm repoistory to Helm 3:-

```shell
helm repo add kinetica-operators https://kineticadb.github.io/charts
helm repo update

# if you get a 404 error on the .tgz file, you may do the following
# you could get this if you had previously added the repo and the chart has been updated in development
helm repo remove kinetica-operators
helm repo add kinetica-operators https://kineticadb.github.io/charts

```

Installation values will depend on the target kubernetes platform you are using.

This chart provides out of the box support for trying out in K3s and Kind clusters. For k3s, you should be able to use either the GPU and CPU version of the databases. In these platforms, a non production configuration of the Kinetica Database and Workbench is also deployed for you to get started. However, you should be able to change the k3s values file to deploy in other platforms as well. For fine grained configuration of the Database or the Workbench, refer to the [Database](Database/database.md) and [Workbench](Workbench/workbench.md) documentation.

We use the same chart for our [SaaS](https://cloud.kinetica.com/) and [AWS Marketplace offerings](https://www.kinetica.com/blog/getting-started-with-kinetica-on-aws/). If you want to try out in SaaS or AWS Marketplace, follow those links, you need not use this chart directly.

Current version of the chart supports kubernetes version 1.25 and above.



## k3s (k3s.io)

Refer to  [Kinetica on K3s](Operators/k3s.md)

## Kind (kubernetes in docker kind.sigs.k8s.io)

Refer to  [Kinetica on Kind](Operators/kind.md)

## K8s - Any flavour (kubernetes.io)

Refer to  [Kinetica on K8s](Operators/k8s.md)

