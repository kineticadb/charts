---
hide:
  - navigation
tags:
  - Reference
  - Administration
---
# Kinetica Cluster Roles CRD

## Full KineticaRole CR Structure

``` yaml title="kineticaroles.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaRole 
metadata: {}
# KineticaRoleSpec defines the desired state of KineticaRole
spec:
  # AlterRoleRequest Kinetica DB REST API Request Format Object.
  alter_role:
    # Action - Modification operation to be applied to the role.
    action: string
    # Role UID - Name of the role to be altered. Must be an existing
    # role.
    name: string
    # Optional parameters. The default value is an empty map ( {} ).
    options: {}
    # Value - The value of the modification, depending on input
    # parameter action.
    value: string
  # Debug debug the call
  debug: false
  # RingName is the name of the kinetica ring that this user belongs
  # to.
  ringName: string
  # AddRoleRequest Kinetica DB REST API Request Format Object.
  role:
    # User UID
    name: string
    # Optional parameters. The default value is an empty map (
    # {} ). Supported Parameters: resource_group	Name of an existing
    # resource group to associate with this role.
    options: {}
    # ResourceGroupName of an existing resource group to associate with
    # this role
    resourceGroupName: ""
# KineticaRoleStatus defines the observed state of KineticaRole
status:
  # DBStringResponse - The GPUdb server embeds the endpoint response
  # inside a standard response structure which contains status
  # information and the actual response to the query.
  db_response: data: string
    # This embedded JSON represents the result of the endpoint
    data_str: string
    # API Call Specific
    data_type: string
    # Empty if success or an error message
    message: string
    # 'OK' or 'ERROR'
    status: string 
    ldap_response: string
```

---

--8<-- "includes/abbreviations.md"
