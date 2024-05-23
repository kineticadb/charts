---
hide:
  - navigation
tags:
  - Reference
  - Operations
---
# Kinetica Cluster Backups Reference

## Full KineticaClusterBackup CR Structure

``` yaml title="kineticaclusterbackups.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaClusterBackup 
metadata: {}
# Fields specific to the linked backup engine
provider:
  # Name of the backup/restore provider. FOR INTERNAL USE ONLY.
  backupProvider: "velero"
  # Name of the backup in the linked BackupProvider. FOR INTERNAL USE
  # ONLY.
  linkedItemName: ""
# BackupSpec defines the specification for a Velero backup.
spec:
  # DefaultVolumesToRestic specifies whether restic should be used to
  # take a backup of all pod volumes by default.
  defaultVolumesToRestic: true
  # ExcludedNamespaces contains a list of namespaces that are not
  # included in the backup.
  excludedNamespaces: ["string"]
  # ExcludedResources is a slice of resource names that are not included
  # in the backup.
  excludedResources: ["string"]
  # Hooks represent custom behaviors that should be executed at
  # different phases of the backup.
  hooks:
    # Resources are hooks that should be executed when backing up
    # individual instances of a resource.
    resources:
    - excludedNamespaces: ["string"]
      # ExcludedResources specifies the resources to which this hook
      # spec does not apply.
      excludedResources: ["string"]
      # IncludedNamespaces specifies the namespaces to which this hook
      # spec applies. If empty, it applies to all namespaces.
      includedNamespaces: ["string"]
      # IncludedResources specifies the resources to which this hook
      # spec applies. If empty, it applies to all resources.
      includedResources: ["string"]
      # LabelSelector, if specified, filters the resources to which this
      # hook spec applies.
      labelSelector:
        # matchExpressions is a list of label selector requirements. The
        # requirements are ANDed.
        matchExpressions:
        - key: string
          # operator represents a key's relationship to a set of values.
          # Valid operators are In, NotIn, Exists and DoesNotExist.
          operator: string
          # values is an array of string values. If the operator is In
          # or NotIn, the values array must be non-empty. If the
          # operator is Exists or DoesNotExist, the values array must
          # be empty. This array is replaced during a strategic merge
          # patch.
          values: ["string"]
        # matchLabels is a map of {key,value} pairs. A single
        # {key,value} in the matchLabels map is equivalent to an
        # element of matchExpressions, whose key field is "key", the
        # operator is "In", and the values array contains only "value".
        # The requirements are ANDed.
        matchLabels: {}
      # Name is the name of this hook.
      name: string
      # PostHooks is a list of BackupResourceHooks to execute after
      # storing the item in the backup. These are executed after
      # all "additional items" from item actions are processed.
      post:
      - exec:
          # Command is the command and arguments to execute.
          command: ["string"]
          # Container is the container in the pod where the command
          # should be executed. If not specified, the pod's first
          # container is used.
          container: string
          # OnError specifies how Velero should behave if it encounters
          # an error executing this hook.
          onError: string
          # Timeout defines the maximum amount of time Velero should
          # wait for the hook to complete before considering the
          # execution a failure.
          timeout: string
      # PreHooks is a list of BackupResourceHooks to execute prior to
      # storing the item in the backup. These are executed before
      # any "additional items" from item actions are processed.
      pre:
      - exec:
          # Command is the command and arguments to execute.
          command: ["string"]
          # Container is the container in the pod where the command
          # should be executed. If not specified, the pod's first
          # container is used.
          container: string
          # OnError specifies how Velero should behave if it encounters
          # an error executing this hook.
          onError: string
          # Timeout defines the maximum amount of time Velero should
          # wait for the hook to complete before considering the
          # execution a failure.
          timeout: string
  # IncludeClusterResources specifies whether cluster-scoped resources
  # should be included for consideration in the backup.
  includeClusterResources: true
  # IncludedNamespaces is a slice of namespace names to include objects
  # from. If empty, all namespaces are included.
  includedNamespaces: ["string"]
  # IncludedResources is a slice of resource names to include in the
  # backup. If empty, all resources are included.
  includedResources: ["string"]
  # LabelSelector is a metav1.LabelSelector to filter with when adding
  # individual objects to the backup. If empty or nil, all objects are
  # included. Optional.
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
    matchLabels: {} metadata: labels: {}
  # OrderedResources specifies the backup order of resources of specific
  # Kind. The map key is the Kind name and value is a list of resource
  # names separated by commas. Each resource name has
  # format "namespace/resourcename".  For cluster resources, simply
  # use "resourcename".
  orderedResources: {}
  # SnapshotVolumes specifies whether to take cloud snapshots of any
  # PV's referenced in the set of objects included in the Backup.
  snapshotVolumes: true
  # StorageLocation is a string containing the name of a
  # BackupStorageLocation where the backup should be stored.
  storageLocation: string
  # TTL is a time.Duration-parseable string describing how long the
  # Backup should be retained for.
  ttl: string
  # VolumeSnapshotLocations is a list containing names of
  # VolumeSnapshotLocations associated with this backup.
  volumeSnapshotLocations: ["string"] status:
  # ClusterSize the current number of ranks & type i.e. CPU or GPU of
  # the cluster when the backup took place.
  clusterSize:
    # ClusterSizeEnum - T-Shirt size of the Kinetica DB Cluster i.e. a
    # representation of the number of nodes in a simple to understand
    # T-Short size scheme. This indicates the size of the cluster i.e.
    # the number of nodes. It does not identify the size of the cloud
    # provider nodes. For node size see ClusterTypeEnum. Supported
    # Values are: - XS S M L XL XXL XXXL
    tshirtSize: string
    # ClusterTypeEnum - An Enum of the node types of a KineticaCluster
    # e.g. CPU, GPU along with the Cloud Provider node size e.g. size
    # of the VM.
    tshirtType: string coldTierBackup: string
  # CompletionTimestamp records the time a backup was completed.
  # Completion time is recorded even on failed backups. Completion time
  # is recorded before uploading the backup object. The server's time
  # is used for CompletionTimestamps
  completionTimestamp: string
  # Errors is a count of all error messages that were generated during
  # execution of the backup.  The actual errors are in the backup's log
  # file in object storage.
  errors: 1
  # Expiration is when this Backup is eligible for garbage-collection.
  expiration: string
  # FormatVersion is the backup format version, including major, minor,
  # and patch version.
  formatVersion: string
  # Phase is the current state of the Backup.
  phase: string
  # Progress contains information about the backup's execution progress.
  # Note that this information is best-effort only -- if Velero fails
  # to update it during a backup for any reason, it may be
  # inaccurate/stale.
  progress:
    # ItemsBackedUp is the number of items that have actually been
    # written to the backup tarball so far.
    itemsBackedUp: 1
    # TotalItems is the total number of items to be backed up. This
    # number may change throughout the execution of the backup due to
    # plugins that return additional related items to back up, the
    # velero.io/exclude-from-backup label, and various other filters
    # that happen as items are processed.
    totalItems: 1
  # StartTimestamp records the time a backup was started. Separate from
  # CreationTimestamp, since that value changes on restores. The
  # server's time is used for StartTimestamps
  startTimestamp: string
  # ValidationErrors is a slice of all validation errors
  # (if applicable).
  validationErrors: ["string"]
  # Version is the backup format major version. Deprecated: Please see
  # FormatVersion
  version: 1
  # VolumeSnapshotsAttempted is the total number of attempted volume
  # snapshots for this backup.
  volumeSnapshotsAttempted: 1
  # VolumeSnapshotsCompleted is the total number of successfully
  # completed volume snapshots for this backup.
  volumeSnapshotsCompleted: 1
  # Warnings is a count of all warning messages that were generated
  # during execution of the backup. The actual warnings are in the
  # backup's log file in object storage.
  warnings: 1
```

---

--8<-- "includes/abbreviations.md"
