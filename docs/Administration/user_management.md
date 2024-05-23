---
hide:
  - navigation
  - toc
tags:
  - Administration
---
# :fontawesome-solid-user: User Management

Management of users is done with the `KineticaUser` CRD. 

!!! tip "kubectl Usage"
    From the `kubectl` command line they are referenced by `kineticausers` or the short form is `ku`.

## List Users

To list the users deployed to a Kinetica DB installation we can use the following from the 
command-line: -

`kubectl -n gpudb get kineticausers` or `kubectl -n gpudb get ku`

where the namespace `-n gpudb` matches the namespace of the Kinetica DB installation.

This outputs 

| Name   | Action | Ring Name           | UID    | Last Name | Given Name | Display Name  | LDAP | DB | Reveal |
|:-------|:-------|:--------------------|:-------|:----------|:-----------|:--------------|:----:-|:---:| :---: |
| kadmin | upsert | kinetica-k8s-sample | kadmin | Account          | Admin      | Admin Account | OK   | OK | OK |

### Name

The name of the Kubernetes CR i.e. the `metadata.name` this is not necessarily the name of the user.

### Action

There are two actions possible on a `KineticaUser`. The first is `upsert` which is for user creation or
modification. The second is `change-password` which shows when a user password reset has been performed.

### Ring Name

The name of the `KineticaCluster` the user is created in.

### UID

The unique, user id to use in LDAP & the DB to reference this user.

### Last Name

Last Name refers to last name or surname. 

`sn` in LDAP terms.

### Given Name

Given Name is the Firstname also called Christian name. 

`givenName` in LDAP terms.

### Display Name

The name shown on any UI representation.

### LDAP

Identifies if the user has been successfully created within LDAP. 

* '' - if empty the user has not yet been created in LDAP
* 'OK' - shows the user has been successfully created within LDAP
* 'Failed' - shows there was a failure adding the user to LDAP

### DB

Identifies if the user has been successfully created within the DB.

* '' - if empty the user has not yet been created in the DB
* 'OK' - shows the user has been successfully created within the DB
* 'Failed' - shows there was a failure adding the user to the DB

### Reveal

Identifies if the user has been successfully created within Reveal.

* '' - if empty the user has not yet been created in Reveal
* 'OK' - shows the user has been successfully created within Reveal
* 'Failed' - shows there was a failure adding the user to Reveal

---

## User Creation

User creation requires two Kubernetes CRs to be submitted to Kubernetes and processed
by the Kinetica DB Operator.

* User Secret (Password)
* Kinetica User

!!! tip "Creation Sequence"
    It is preferable to create the User Secret prior to creating the `KineticaUser`.

!!! note "Secret Deletion"
    The User Secret will be deleted once the `KineticaUser` is created by the operator.
    The users password will be stored in LDAP and not be present in Kubernetes.

### User Secret

In this example a user Fred Smith will be created.

``` yaml title="fred-smith-secret.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: fred-smith-secret
  namespace: gpudb
stringData:
  password: testpassword
```

``` shell title="Create the User Password Secret"
kubectl apply -f fred-smith-secret.yaml
```

### `KineticaUser`

``` yaml title="user-fred-smith.yaml"
apiVersion: app.kinetica.com/v1
kind: KineticaUser
metadata:
  name: user-fred-smith
  namespace: gpudb
spec:
  ringName: kineticacluster-sample
  uid: fred
  action: upsert
  reveal: true
  upsert:
    userPrincipalName: fred.smith@example.com
    givenName: Fred
    displayName: FredSmith
    lastName: Smith
    passwordSecret: fred-smith-secret
```

---

## User Deletion

To delete a user from the Kinetica Cluster simply delete the User CR from Kubernetes: -

``` yaml title="Delete User"
kubectl -n gpudb delete ku user-fred-smith 
```

---

## Change Password

To change a users password we use the `change-password` action rather than the `upsert`
action we used previously.

!!! tip "Creation Sequence"
It is preferable to create the User Secret prior to creating the `KineticaUser`.

!!! note "Secret Deletion"
The User Secret will be deleted once the `KineticaUser` is created by the operator.
The users password will be stored in LDAP and not be present in Kubernetes.

``` yaml title="fred-smith-change-pwd-secret.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: fred-smith-change-pwd-secret
  namespace: gpudb
stringData:
  password: testpassword
```

``` shell title="Create the User Password Secret"
kubectl apply -f fred-smith-change-pwd-secret.yaml
```

``` yaml title="user-fred-smith-change-password.yaml"
apiVersion: app.kinetica.com/v1
kind: KineticaUser
metadata:
  name: user-fred-smith-change-password
  namespace: gpudb
spec:
  ringName: kineticacluster-sample
  uid: fred
  action: change-password
  changePassword:
    passwordSecret: fred-smith-change-pwd-secret
```

## Advanced Topics

### Limit User Resources

#### Data Limit

KIFs user data size limit.

```yaml title="dataLimit"
spec:
  upsert:
    dataLimit: 10Gi
```

### User Kifs Usage

!!! note "Kifs Enablement"
    In order to use the Kifs user features below there is a requirement that Kifs 
    is enabled on the Kinetica DB.

#### Home Directory

When creating a new user it is possible to create that user a 'home' directory within 
the Kifs filesystem by using the `createHomeDirectory` option.

```yaml title="createHomeDirectory"
spec:
  upsert:
    createHomeDirectory: true
```

##### Limit Directory Storage

It is possible to limit the amount of Kifs file storage the user has by adding
`kifsDataLimit` to the user creation yaml and setting the value to a Kubernetes Quantity
e.g. `2Gi`

```yaml title="kifsDataLimit"
spec:
  upsert:
    kifsDataLimit: 2Gi
```
