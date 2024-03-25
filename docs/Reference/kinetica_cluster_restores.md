---
hide:
  - toc
---
# Kinetica Cluster Restores Reference

## Full KineticaClusterRestore CR Structure

``` yaml title="kineticaclusterrestores.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaClusterRestore 
metadata: {}
# RestoreSpec defines the specification for a Velero restore.
spec:
  # BackupName is the unique name of the Velero backup to restore from.
  backupName: string
  # ExcludedNamespaces contains a list of namespaces that are not
  # included in the restore.
  excludedNamespaces: ["string"]
  # ExcludedResources is a slice of resource names that are not included
  # in the restore.
  excludedResources: ["string"]
  # IncludeClusterResources specifies whether cluster-scoped resources
  # should be included for consideration in the restore. If null,
  # defaults to true.
  includeClusterResources: true
  # IncludedNamespaces is a slice of namespace names to include objects
  # from. If empty, all namespaces are included.
  includedNamespaces: ["string"]
  # IncludedResources is a slice of resource names to include in the
  # restore. If empty, all resources in the backup are included.
  includedResources: ["string"]
  # LabelSelector is a metav1.LabelSelector to filter with when
  # restoring individual objects from the backup. If empty or nil, all
  # objects are included. Optional.
  labelSelector:
    # matchExpressions is a list of label selector requirements. The
    # requirements are ANDed.
    matchExpressions:
    - key: string
      # operator represents a key's relationship to a set of values.
      # Valid operators are In, NotIn, Exists and DoesNotExist.
      operator: string
      # values is an array of string values. If the operator is In or
      # NotIn, the values array must be non-empty. If the operator is
      # Exists or DoesNotExist, the values array must be empty. This
      # array is replaced during a strategic merge patch.
      values: ["string"]
    # matchLabels is a map of {key,value} pairs. A single {key,value} in
    # the matchLabels map is equivalent to an element of
    # matchExpressions, whose key field is "key", the operator is "In",
    # and the values array contains only "value". The requirements are
    # ANDed.
    matchLabels: {}
  # NamespaceMapping is a map of source namespace names to target
  # namespace names to restore into. Any source namespaces not included
  # in the map will be restored into namespaces of the same name.
  namespaceMapping: {}
  # RestorePVs specifies whether to restore all included PVs from
  # snapshot (via the cloudprovider).
  restorePVs: true
  # ScheduleName is the unique name of the Velero schedule to restore
  # from. If specified, and BackupName is empty, Velero will restore
  # from the most recent successful backup created from this schedule.
  scheduleName: string status: coldTierRestore: ""
  # CompletionTimestamp records the time the restore operation was
  # completed. Completion time is recorded even on failed restore. The
  # server's time is used for StartTimestamps
  completionTimestamp: string
  # Errors is a count of all error messages that were generated during
  # execution of the restore. The actual errors are stored in object
  # storage.
  errors: 1
  # FailureReason is an error that caused the entire restore to fail.
  failureReason: string
  # Phase is the current state of the Restore
  phase: string
  # Progress contains information about the restore's execution
  # progress. Note that this information is best-effort only -- if
  # Velero fails to update it during a restore for any reason, it may
  # be inaccurate/stale.
  progress:
    # ItemsRestored is the number of items that have actually been
    # restored so far
    itemsRestored: 1
    # TotalItems is the total number of items to be restored. This
    # number may change throughout the execution of the restore due to
    # plugins that return additional related items to restore
    totalItems: 1
  # StartTimestamp records the time the restore operation was started.
  # The server's time is used for StartTimestamps
  startTimestamp: string
  # ValidationErrors is a slice of all validation errors(if applicable)
  validationErrors: ["string"]
  # Warnings is a count of all warning messages that were generated
  # during execution of the restore. The actual warnings are stored in
  # object storage.
  warnings: 1
```

---

--8<-- "includes/abbreviations.md"