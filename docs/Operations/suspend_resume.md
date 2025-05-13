---
hide:
  - navigation
tags:
  - Administration
  - Operations
---
# Kinetica for Kubernetes Suspend & Resume

It is possible to supend Kinetica for Kubernetes which spins down the DB.  This is
can be useful for multiple reasons.

* In the case where the Kubernetes cluster will be shutdown or upgraded, all in-flight
  data will be written to file as Kinetica will be shut down gracefully.
* After some changes in configuration, Kinetica may need to be restarted to apply the
  config changes.
* Suspending can free up compute resources for other applications and in the case of
  a cloud environment where node scaling is available, suspending can allow the
  Kubernetes cluster to scale down expensive compute nodes to save money.

!!! note "Infra Structure"
    For each deployment of Kinetica for Kubernetes there are two distinct types of pods: -
    
    * 'Compute' pods containing the Kinetica DB along with the Statics Pod
    * 'Infra' pods containing the supporting apps, e.g. Workbench, OpenLDAP etc,
    and the Kinetica Operators.

    Whilst Kinetica for Kubernetes is in the `Suspended` state only the 'Compute' pods are
    scaled down. The 'Infra' pods remain running in order for Workbench to be able
    to login, backup, restore and in this case Resume the suspended system.

There are three discrete ways to suspend and resume Kinetica for Kubernetes:

## Manual Suspend/Resume

=== ":material-monitor: Workbench"

    When logged into Workbench AS AN ADMIN TODO FINISH, navigate in the upper menu to
    Manage => Cluster.  Then in the upper right hand corner, you can pick the `Suspend`
    and/or `Resume` buttons.

=== ":simple-kubernetes: kubectl"

    To suspend (or resume) without using a user interface, you can submit a new
    [KineticaClusterAdmin](../Reference/kinetica_cluster_admins.md) CR to Kubernetes.  

    ``` yaml title="suspend.yaml"
    apiVersion: app.kinetica.com/v1
    kind: KineticaClusterAdmin
    metadata:
      name: sample-suspend
      namespace: gpudb
    spec:
      kineticaClusterName: "CLUSTERNAME"
      offline:
        offline: true
    ```

    ... and to resume the database, you would submit a new
    [KineticaClusterAdmin](../Reference/kinetica_cluster_admins.md) CR with offline
    false.

    ``` yaml title="resume.yaml"
    apiVersion: app.kinetica.com/v1
    kind: KineticaClusterAdmin
    metadata:
      name: sample-resume
      namespace: gpudb
    spec:
      kineticaClusterName: "CLUSTERNAME"
      offline:
        offline: false
    ```

    !!! tip
        You must submit a new CR for each operation.  Once a CR has been processed, it
        will no longer register updates.

## Auto-Suspend

The Kinetica Operators can track how long a Kinetica Cluster has been idle and suspend
it after a set time of lack of activity.  This can be used to cut cloud costs in
Kubernetes clusters which can automatically create and destroy Kubernetes nodes.

=== ":material-monitor: Workbench"

    Users can also edit the auto suspend rules in Workbench by browsing to Manage => Cluster
    in the top menu and then clicking the `Edit` button next to the `Auto Suspend` Status.
    If the cluster was installed via Helm, however, it is highly recommended to update
    the AutoSuspend settings in your values file instead, as that value can be reset by
    Helm during an upgrade.

=== ":simple-helm: Helm"

    When using Helm to install and manage the cluster, the Helm values file should be
    used to enable auto-suspend.  To do this, set `db.autoSuspend.enabled` to `true` and
    `db.autoSuspend.inactivityDuration` to a number followed by a unit of time ("4h",
    "1d", etc.)

    ``` yaml
    db:
      autoSuspend:
        enabled: true
        inactivityDuration: "2h"
    ```

=== ":simple-kubernetes: kubectl"

    Similarly to when installing with the Helm chart, the KineticaCluster CR has settings
    for autoSuspend available to allow users to control when the cluster suspends after
    inactivity.

    ``` yaml
    spec:
      autoSuspend:
        enabled: true
        inactivityDuration: "2h"
    ```

To resume the database after it has been auto-suspended, please see the above section
for Manual Suspend/Resume.
