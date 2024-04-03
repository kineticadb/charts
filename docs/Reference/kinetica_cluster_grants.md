---
hide:
  - navigation
tags:
  - Reference
---
# Kinetica Cluster Grants CRD Reference

## Full KineticaGrant CR Structure

``` yaml title="kineticagrants.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaGrant 
metadata: {}
# KineticaGrantSpec defines the desired state of KineticaGrant
spec:
  # Grants system-level and/or table permissions to a user or role.
  addGrantAllOnSchemaRequest:
    # Name of the user or role that will be granted membership in input
    # parameter role. Must be an existing user or role.
    member: string
    # Optional parameters. The default value is an empty map ( {} ).
    options: {}
    # SchemaName - name of the schema on which to perform the Grant All
    schemaName: string
  # Grants system-level and/or table permissions to a user or role.
  addGrantPermissionRequest:
    # Optional parameters. The default value is an empty map ( {} ).
    options: {}
    # Permission to grant to the user or role. Supported
    # Values	Description system_admin	Full access to all data and
    # system functions. system_user_admin	Access to administer users
    # and roles that do not have system_admin permission.
    # system_write	Read and write access to all tables.
    # system_read	Read-only access to all tables.
    systemPermission:
      # UID of the user or role to which the permission will be granted.
      # Must be an existing user or role.
      name: string
      # Optional parameters. The default value is an empty map (
      # {} ). Supported Parameters: resource_group	Name of an existing
      # resource group to associate with this role.
      options: {}
      # Permission to grant to the user or role. Supported
      # Values	Description table_admin	Full read/write and
      # administrative access to the table. table_insert	Insert access
      # to the table. table_update	Update access to the table.
      # table_delete	Delete access to the table. table_read	Read access
      # to the table.
      permission: string
    # Permission to grant to the user or role. Supported
    # Values	Description<br/> system_admin	Full access to all data and
    # system functions.<br/> system_user_admin	Access to administer
    # users and roles that do not have system_admin permission.<br/>
    # system_write	Read and write access to all tables.<br/>
    # system_read	Read-only access to all tables.<br/>
    tablePermissions:
    - filter_expression: ""
      # UID of the user or role to which the permission will be granted.
      # Must be an existing user or role.
      name: string
      # Optional parameters. The default value is an empty map (
      # {} ). Supported Parameters: resource_group	Name of an existing
      # resource group to associate with this role.
      options: {}
      # Permission to grant to the user or role. Supported
      # Values	Description table_admin	Full read/write and
      # administrative access to the table. table_insert	Insert access
      # to the table. table_update	Update access to the table.
      # table_delete	Delete access to the table. table_read	Read access
      # to the table.
      permission: string
      # Name of the table for which the Permission is to be granted
      table_name: string
  # Grants membership in a role to a user or role.
  addGrantRoleRequest:
    # Name of the user or role that will be granted membership in input
    # parameter role. Must be an existing user or role.
    member: string
    # Optional parameters. The default value is an empty map ( {} ).
    options: {}
    # Name of the role in which membership will be granted. Must be an
    # existing role.
    role: string
  # Debug debug the call
  debug: false
  # RingName is the name of the kinetica ring that this user belongs
  # to.
  ringName: string
# KineticaGrantStatus defines the observed state of KineticaGrant
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