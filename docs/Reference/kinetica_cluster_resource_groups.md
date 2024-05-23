---
hide:
  - navigation
tags:
  - Reference
  - Administration
---
# Kinetica Cluster Resource Groups CRD Reference

## Full KineticaResourceGroup CR Structure

``` yaml title="kineticaclusterresourcegroups.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaClusterResourceGroup 
metadata: {}
# KineticaClusterResourceGroupSpec defines the desired state of
# KineticaClusterResourceGroup
spec: 
  db_create_resource_group_request:
    # AdjoiningResourceGroup -
    adjoining_resource_group: ""
    # Name - name of the DB ResourceGroup
    # https://docs.kinetica.com/7.1/azure/sql/resource_group/?search-highlight=resource+group#id-baea5b60-769c-5373-bff1-53f4f1ca5c21
    name: string
    # Options - DB Options used when creating the ResourceGroup
    options: {}
    # Ranking - Indicates the relative ranking among existing resource
    # groups where this new resource group will be placed. When using
    # before or after, specify which resource group this one will be
    # inserted before or after in input parameter
    # adjoining_resource_group. The supported values are: first last
    # before after
    ranking: ""
  # RingName is the name of the kinetica ring that this user belongs
  # to.
  ringName: string
# KineticaClusterResourceGroupStatus defines the observed state of
# KineticaClusterResourceGroup
status: 
  provisioned: string
```

---

--8<-- "includes/abbreviations.md"
