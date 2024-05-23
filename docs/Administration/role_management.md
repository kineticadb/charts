---
hide:
  - navigation
  - toc
tags:
  - Administration
---
# :fontawesome-solid-user-group: Role Management

Management of roles is done with the `KineticaRole` CRD. 

!!! tip "kubectl Usage"
    From the `kubectl` command line they are referenced by `kineticaroles` or the short form is `kr`.

## List Roles

To list the roles deployed to a Kinetica DB installation we can use the following from the
command-line: -

`kubectl -n gpudb get kineticaroles` or `kubectl -n gpudb get kr`

where the namespace `-n gpudb` matches the namespace of the Kinetica DB installation.

This outputs

| Name   |  Ring Name           | Role    | Resource Group Name | LDAP | DB |
|:-------| :--------------------|:-------|:--------------------|:----:|:---:| 
| db-users |  kinetica-k8s-sample | db_users |                     |  OK  | OK | 
| global-admins | kinetica-k8s-sample | global_admins |  |  OK  | OK |

### Name

The name of the Kubernetes CR i.e. the `metadata.name` this is not necessarily the name of the user.

### Ring Name

The name of the `KineticaCluster` the user is created in.

### Role Name

The name of the role as contained with LDAP & the DB.

## Role Creation

``` yaml title="test-role-2.yaml"
apiVersion: app.kinetica.com/v1
kind: KineticaRole
metadata:
    name: test-role-2
    namespace: gpudb
spec:
    ringName: kineticacluster-sample
    role:
        name: "test_role2"
```

## Role Deletion

To delete a role from the Kinetica Cluster simply delete the Role CR from Kubernetes: -


``` shell title="Delete User"
kubectl -n gpudb delete kr user-fred-smith 
```
