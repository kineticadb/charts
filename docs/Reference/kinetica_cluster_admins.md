---
hide:
  - toc
---
# Kinetica Cluster Admins Reference

## Full KineticaClusterAdmin CR Structure

``` yaml title="kineticaclusteradmins.app.kinetica.com_sample.yaml"
# APIVersion defines the versioned schema of this representation of an
# object. Servers should convert recognized schemas to the latest
# internal value, and may reject unrecognized values. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
apiVersion: app.kinetica.com/v1
# Kind is a string value representing the REST resource this object
# represents. Servers may infer this from the endpoint the client
# submits requests to. Cannot be updated. In CamelCase. More info:
# https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
kind: KineticaClusterAdmin
metadata: {}
# KineticaClusterAdminSpec defines the desired state of
# KineticaClusterAdmin
spec:
  # ForceDBStatus - Force a Status of the DB.
  forceDbStatus: string
  # Name - The name of the cluster to target.
  kineticaClusterName: string
  # Offline - Pause/Resume of the DB.
  offline:
    # Set to true if desired state is offline. The supported values are:
    # true false
    offline: false
    # Optional parameters. The default value is an empty map (
    # {} ). Supported Parameters: flush_to_disk	Flush to disk when
    # going offline The supported values are: true false
    options: {}
  # Rebalance of the DB.
  rebalance:
    # Optional parameters. The default value is an empty map (
    # {} ). Supported Parameters: rebalance_sharded_data		If true,
    # sharded data will be rebalanced approximately equally across the
    # cluster. Note that for clusters with large amounts of sharded
    # data, this data transfer could be time-consuming and result in
    # delayed query responses. The default value is true. The supported
    # values are: true false rebalance_unsharded_data	If true,
    # unsharded data (a.k.a. randomly-sharded) will be rebalanced
    # approximately equally across the cluster. Note that for clusters
    # with large amounts of unsharded data, this data transfer could be
    # time-consuming and result in delayed query responses. The default
    # value is true. The supported values are: true false
    # table_includes				Comma-separated list of unsharded table names
    # to rebalance. Not applicable to sharded tables because they are
    # always rebalanced. Cannot be used simultaneously with
    # table_excludes. This parameter is ignored if
    # rebalance_unsharded_data is false.
    # table_excludes				Comma-separated list of unsharded table names
    # to not rebalance. Not applicable to sharded tables because they
    # are always rebalanced. Cannot be used simultaneously with
    # table_includes. This parameter is ignored if rebalance_
    # unsharded_data is false. aggressiveness				Influences how much
    # data is moved at a time during rebalance. A higher aggressiveness
    # will complete the rebalance faster. A lower aggressiveness will
    # take longer but allow for better interleaving between the
    # rebalance and other queries. Valid values are constants from 1
    # (lowest) to 10 (highest). The default value is '1'.
    # compact_after_rebalance 	Perform compaction of deleted records
    # once the rebalance completes to reclaim memory and disk space.
    # Default is true, unless repair_incorrectly_sharded_data is set to
    # true. The default value is true. The supported values are: true
    # false compact_only 				If set to true, ignore rebalance options
    # and attempt to perform compaction of deleted records to reclaim
    # memory and disk space without rebalancing first. The default
    # value is false. The supported values are: true false
    # repair_incorrectly_sharded_data		Scans for any data sharded
    # incorrectly and re-routes the data to the correct location. Only
    # necessary if /admin/verifydb reports an error in sharding
    # alignment. This can be done as part of a typical rebalance after
    # expanding the cluster or in a standalone fashion when it is
    # believed that data is sharded incorrectly somewhere in the
    # cluster. Compaction will not be performed by default when this is
    # enabled. If this option is set to true, the time necessary to
    # rebalance and the memory used by the rebalance may increase. The
    # default value is false. The supported values are: true false
    options: {}
  # RegenerateDBConfig - Force regenerate of DB ConfigMap. true -
  # restarts DB Pods after config generation false - writes new
  # configuration without restarting the DB Pods
  regenerateDBConfig:
    # Restart - Scales down the DB STS and back up once the DB
    # Configuration has been regenerated.
    restart: false
# KineticaClusterAdminStatus defines the observed state of
# KineticaClusterAdmin
status:
  # Phase - The current phase/state of the Admin request
  phase: string
  # Processed - Indicates if the admin request has already been
  # processed. Avoids the request being rerun in the case the Operator
  # gets restarted.
  processed: false
```

---

--8<-- "includes/abbreviations.md"