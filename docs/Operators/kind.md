# Overview

This installation in a kind cluster is for trying out the operators and the database in a non production environment. This method currently only supports installing a CPU version of the database.

You will need a license key for this to work. Please contact [Kinetica Support](support@kinetica.com).

## Kind (kubernetes in docker kind.sigs.k8s.io)

### Create Kind Cluster 1.29

```bash
kind create cluster --config charts/kinetica-operators/kind.yaml
``` 

#### Kind - Install kinetica-operators including a sample db to try out

Review the values file charts/kinetica-operators/values.onPrem.kind.yaml. This is trying to install the operators and a simple db with workbench installation for a non production try out.

As you can see it is trying to create an ingress pointing towards local.kinetica. If you have a domain pointing to your machine, replace it with the correct domain name.


##### Kind - Install the kinetica-operators chart


```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.kind.yaml --set db.gpudbCluster.license="your_license_key" --set dbAdminUser.password="your_password"
```

You should be able to access the workbench at [http://local.kinetica](http://local.kinetica)

Username as per the values file mentioned above is kadmin and password is Kinetica1234!
