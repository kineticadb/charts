---
hide:
  - navigation
tags:
  - Operations
---
# Kinetica for Kubernetes Backup & Restore

Kinetica for Kubernetes supports the Backup & Restoring of the installed Kinetica DB by leveraging 
[Velero](https://velero.io/docs/main/)
which is required to be installed into the same Kubernetes cluster that the `kinetica-operators` Helm chart is deployed.

!!! quote "Velero"
    Velero (formerly Heptio Ark) gives you tools to back up and restore your Kubernetes cluster 
    resources and persistent volumes. You can run Velero with a cloud provider or on-premises.

For Velero installation please see [here](https://velero.io/docs/main/basic-install/).

!!! warning "Velero Installation"
    The `kinetica-operators` Helm chart does not deploy Velero it is a prerequisite for it to be installed before
    Backup & Restore will work correctly.

There are two ways to initiate a Backup or Restore

* Workbench Initiated
* Kubernetes CR Initiated

!!! note "Preferred Backup/Restore Mechanism"
    The preferred way to Backup or Restore the Kinetica for Kubernetes DB instance is via Workbench.

## Workbench Initiated Backup or Restore

### > Home 

From the Workbench Home page

![workbench.png](..%2Fimages%2Fworkbench%2Fworkbench.png)

we need to select the `Manage` option from the toolbar.

![workbench_manage_menu.png](..%2Fimages%2Fworkbench%2Fworkbench_manage_menu.png)

### > Manage > Cluster > Overview

On the Cluster Overview page select the 'Snapshots' tab

![workbench_cluster.png](..%2Fimages%2Fworkbench%2Fworkbench_cluster.png)

### > Manage > Cluster > Snapshots

#### Backup

Select the 'Backup Now' button

![workbench_cluster_snapshots.png](..%2Fimages%2Fworkbench%2Fworkbench_cluster_snapshots.png)

and the backup will start and you will be able to see the progress

![workbench_clister_snapshots_backup_in_progress.png](..%2Fimages%2Fworkbench%2Fworkbench_clister_snapshots_backup_in_progress.png)

#### Restore




---

## Kubernetes CR Initiated Backup or Restore

The Kinetica DB Operator supports two custom CRs 

* [`KineticaClusterBackup`](#kineticaclusterbackup-cr)
* [`KineticaClusterRestore`](#kineticaclusterrestore-cr)

which can be used to perform a Backup of the database and a Restore of
Kinetica namespaces.

---

### `KineticaClusterBackup` CR

Submission of a `KineticaClusterBackup` CR will trigger the Kinetica DB Operator to perform a backup of a
Kinetica DB instance.

!!! warning "Kinetica DB Offline"
    In order to perform a database backup the Kinetica DB needs to be suspended in order for Velero 
    to have access to the necessary disks. The DB will be stopped & restarted automatically by the
    Kinetica DB Operator as part of the backup process.

```yaml title="Example KineticaClusterBackup CR yaml"
apiVersion: app.kinetica.com/v1
kind: KineticaClusterBackup
metadata:
  name: kineticaclusterbackup-sample
  namespace: gpudb
spec:
  includedNamespaces:
    - gpudb
```

The namespace of the backup CR should be different to that of the namespace the Kinetica DB is running in
i.e. not `gpudb`. We recommend using the namespace Velero is deployed into.

!!! warning "Backup names are unique"
    The name of the `KineticaClusterBackup` CR is unique we therefore suggest creating the name of the CR
    containing the date + time of the backup to ensure uniqueness. Kubernetes CR names have a strict
    naming format so the specified name must conform to those patterns.

For a detailed description of the `KineticaClusterBackup` CRD see [here](../Reference/kinetica_cluster_backups.md)

---

### `KineticaClusterRestore` CR 

In order to perform a restore of Kinetica for Kubernetes the easiest way is to simply delete the `gpudb`
namespace from the Kubernetes cluster.

``` shell title="Delete the Kinetica DB"
kubectl delete ns gpudb
```

!!! warning "Kinetica DB Offline"
    In order to perform a database restore the Kinetica DB needs to be suspended in order for Velero
    to have access to the necessary disks. The DB will be stopped & restarted automatically by the
    Kinetica DB Operator as part of the restore process.

```yaml title="Example KineticaClusterBackup CR yaml"
apiVersion: app.kinetica.com/v1
kind: KineticaClusterRestore
metadata:
  name: kineticaclusterrestore-sample
  namespace: gpudb
spec:
  backupName: kineticaclusterbackup-sample
```

The namespace of the restore CR should be the same as that of the namespace the `KineticaClusterBackup` CR
was placed in. i.e. Not the namespace Kinetica DB is running in.

!!! warning "Restore names are unique"
    The name of the `KineticaClusterRestore` CR is unique we therefore suggest creating the name of the CR
    containing the date + time of the restore process to ensure uniqueness. Kubernetes CR names have a strict
    naming format so the specified name must conform to those patterns.

For a detailed description of the `KineticaClusterRestore` CRD see [here](../Reference/kinetica_cluster_restores.md)

---
