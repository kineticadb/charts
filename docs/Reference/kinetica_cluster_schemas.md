---
hide:
  - navigation
tags:
  - Reference
---
# Kinetica Cluster Schemas CRD Reference

## Full Kinetica Cluster Schemas CR Structure

``` yaml title="kineticaclusterschemas.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaClusterSchema 
metadata: {}
# KineticaClusterSchemaSpec defines the desired state of
# KineticaClusterSchema
spec: 
  db_create_schema_request:
    # Name - the name of the resource group to create in the DB
    name: string
    # Optional parameters. The default value is an empty map (
    # {} ). Supported Parameters: "max_cpu_concurrency", "max_data"
    options: {}
  # RingName is the name of the kinetica ring that this user belongs
  # to.
  ringName: string
# KineticaClusterSchemaStatus defines the observed state of
# KineticaClusterSchema
status: 
  provisioned: string
```

---

--8<-- "includes/abbreviations.md"