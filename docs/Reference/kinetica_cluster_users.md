---
hide:
  - navigation
tags:
  - Reference
---
# Kinetica Cluster Users CRD Reference

## Full KineticaUser CR Structure

``` yaml title="kineticausers.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaUser
metadata: {}
# KineticaUserSpec defines the desired state of KineticaUser
spec:
  # Action field contains UserActionEnum field indicating whether it is
  # an Upsert or Change Password operation. For deletion delete the
  # KineticaUser CR and a finalizer will remove the user from LDAP.
  action: string
  # ChangePassword specific fields
  changePassword:
    # PasswordSecret - Not the actual user password but the name of a
    # Kubernetes Secret containing a Data element with a Password
    # attribute. The secret is removed on user creation. Must be in the
    # same namespace as the Kinetica Cluster. Must contain the
    # following fields: - oldPassword newPassword
    passwordSecret: string
  # Debug debug the call
  debug: false
  # GroupID - Organisation or Team Id the user belongs to.
  groupId: string
  # Create the user in Reveal
  reveal: true
  # RingName is the name of the kinetica ring that this user belongs
  # to.
  ringName: string
  # UID is the username (not UUID UID).
  uid: string
  # Upsert specific fields
  upsert:
    # CreateHomeDirectory - when true, a home directory in KiFS is
    # created for this user The default value is true. The supported
    # values are: true false
    createHomeDirectory: true
    # DB Memory user data size limit
    dataLimit: "10Gi"
    # DisplayName
    displayName: string
    # GivenName is Firstname also called Christian name. givenName in
    # LDAP terms.
    givenName: string
    # KIFs user data size limit
    kifsDataLimit: "2Gi"
    # LastName refers to last name or surname. sn in LDAP terms.
    lastName: string
    # Options -
    options: {}
    # PasswordSecret - Not the actual user password but the name of a
    # Kubernetes Secret containing a Data element with a Password
    # attribute. The secret is removed on user creation. Must be in the
    # same namespace as the Kinetica Cluster.
    passwordSecret: string
    # UPN or UserPrincipalName - e.g. guyt@cp.com  
    # Looks like an email address.
    userPrincipalName: string
  # UUID is the user unique UUID from the Control Plane.
  uuid: string
# KineticaUserStatus defines the observed state of KineticaUser
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
    reveal_admin: string
```

---

--8<-- "includes/abbreviations.md"