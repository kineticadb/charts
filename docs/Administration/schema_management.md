---
hide:
  - navigation
tags:
  - Administration
---
# Creating Schemas from Kubernetes CRs

Schemas can be created and destroyed using KineticaClusterSchema Custom
Resource objects.  To create a schema, simply create the CR with the requested
information and to later delete it, simply delete the CR.

!!! tip "schema naming"
    Schema names must start with an alphanumeric character and can only contain alpha numeric characters
    the following characters: _ { } [ ] : - ( ) #

## Example Schema

The following example will create the `sample_schema` schema on the `kinetica-sample-cluster` cluster in
the `gpudb` namespace.  You can apply it using kubectl.

``` yaml title="kineticaclusterschema.yaml"
apiVersion: app.kinetica.com/v1
kind: KineticaClusterSchema
metadata:
  name: sample-schema
  namespace: gpudb
spec:
  db_create_schema_request:
    name: sample_schema
  ringName: kinetica-sample-cluster
```