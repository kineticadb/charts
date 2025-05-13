---
hide:
  - navigation
tags:
  - Administration
---

# Grant Management

As a part of managing access to Kinetica and its underlying data, Administrators
can grant roles and permissions through the KineticaGrant Custom Resources.

## Granting Permissions

Permissions can be assigned to a [Role](role_management.md) or to a
[User](user_management.md), and can be set at the table, [schema](schema_management.md)
or system level.

### Granting Permissions to a Table or Schema

To grant one or more permissions to tables or schemas in the database, you can use the
`addGrantPermissionRequest.tablePermissions` on the `KineticaGrant` as below...

#### Filter Expression

A string containing the filter expression to specify what rows this grant applies to.
Filter expressions may contain column expressions as well as tests for equality/inequality
for selecting records from the database and must evaluate to true/false.  Filter
expressions *cannot* contain aggregation functions.

#### Name

The username or role name to grant these permissions to.

#### Permission

The permission to grant.  Can be one of...

* **table_admin** - full read/write and administrative access to the table
* **table_insert** - insert access to the table
* **table_update** - update access to the table
* **table_delete** - delete access to the table
* **table_read** - read access to the table

#### Example

The following can be used to grant the user `jdoe` on the cluster "cluster0"
read access to the `myschema.mytable` table.

``` yaml
apiVersion: app.kinetica.com/v1
kind: KineticaGrant
metadata:
  name: kineticagranttable-sample
  namespace: gpudb
spec:
  ringName: "cluster0" ## kc.metadata.name
  addGrantPermissionRequest:
    tablePermissions:
      - name: "jdoe"
        permission: "table_read"
        table_name: "myschema.mytable"
```

## Granting Roles

Roles may be granted to users or other roles.  In this case, all that is required are
the role being granted and the member (username or role) to grant it to.  The following
example grants the `admin` role to the `jdoe` user.

``` yaml
apiVersion: app.kinetica.com/v1
kind: KineticaGrant
metadata:
  name: kineticagrantrole-sample
  namespace: gpudb
spec:
  ringName: "cluster0" ## kc.metadata.name
  addGrantRoleRequest:
    member: "jdoe"
    role: "admin"
```
