---
hide:
  - navigation
tags:
  - Administration
---

# Updating Cluster Configuration

Clusters are created and configured with the KineticaCluster CRD.

## Configuration Changes

Once a cluster is created, you can update the configuration on the cluster
by editing the CRD.  After changing the configuation, you may need to
restart the database to apply the configuration changes.  The easiest way
to do so is to [Suspend and then Resume](../Operations/suspend_resume.md)
the cluster.

## Scaling the Cluster

Over time, you may find that you may require more or fewer resources dedicated
to the Kinetica cluster.  Depending on your needs, you can modify the size
of the disks or the compute assigned to the kinetica cluster.

### Modifying Volume Sizing

One common issue is that the cluster may be running low on disk space.  If
the Volumes assigned to the Kinetica StatefulSet are set to `AllowVolumeExpansion`,
then you can edit the `PersistentVolumeClaims` to resize the disks.  Depending
on the storage provisioner, a restart of the pods *may* be required.  Generally
Persistent Volumes in Kubernetes may only increase in size - you cannot shrink
them.

!!! warning "AllowVolumeExpansion"
    You can only set the `AllowVolumeExpansion` on a Persistent Volume when it is
    first created.  You should confirm this setting in the Storage Class and/or
    KineticaCluster before you create the cluster to ensure it is set properly.
    Once the volumes are provisioned, you can no longer update that parameter.

### Increasing or Decreasing the Compute Resources

The amount of computational power dedicated to the cluster can also be changed.
The Kinetica cluster consists of Ranks, which are the basic "worker" of the database.
The number of Ranks can be increased or decreased, and also the amount of resources
dedicated to each Rank can be increased or decreased.

!!! warning "down time"
    When changing the number of Kinetica Ranks that are running or changing the
    resources assigned to each rank, the database will be forced to restart and
    consequently users will experience downtime.  If you require a user experience
    that avoids all downtime, you should investigate our HA offerings, which are not
    yet compatible with our Kubernetes offering.

#### Changing the Number of Ranks

The number of worker Ranks can be adjusted by modifying the `db.gpudbCluster.replicas`
parameter on the helm values.  This number must be greater than zero.  When updated,
the Kinetica Operators will automatically update the number of replicas of the
database that are running and will rebalance the data across the remaining Ranks,
assuming that there is enough disk space to do so (mostly this could be a problem
when scaling down - please check first that there is enough room).  The database
will be unavailable for queries during the time that it takes to rebalance the data
and restart.

!!! warning "rebalancing"
    Depending on many factors, including the general performance of your hardware
    and the complexity of the data stored in Kinetica (especially primary and
    foreign keys), rebalancing may be a time consuming effort.  It is best to
    test performance of rebalance in your own environment and with your own data
    if minimizing downtime during a rebalance is a priority.

#### Resizing Each Rank

In most cases, it is best to run a single rank per node and give each node as large a
percentage of the node as you need up to about 75-85% of the node's capacity.  Going
beyond 85% of the node is risky and can lead to the database being terminated by the
linux Out Of Memory Killer Kernel Process (OOMKill).  Ranks will be identical in
size and consequently the size of the Ranks will be determined by the smallest node
that is availble for the cluster to run upon.

You can set rank limits via the `db.gpudbCluster.resources` field in the Helm values
file.  As a reminder, this value is a "per Rank" value, not an overall value.  For
example, the following will create (or resize) a cluster with three worker ranks
each on a different node, and each having 16 vcpus and 64Gi of memory.  Meaning that
in total, you would be using 48 vcpus (16 vcpu x 3) and 192Gi of RAM (64Gi x 3).

``` yaml
db:
  gpudbCluster:
    ranksPerNode: 1
    replicas: 3
    resources:
      requests:
        cpu: 16
        memory: 64Gi
      limit:
        cpu: 16
        memory: 64Gi
```

!!! warning "auto sizing"
    If you do *not* put any limits on the pods, Kinetica will inspect the nodes
    that are available (and which match the app.kinetica.com/pool=compute label
    if `db.gpudbCluster.hasPools` is true).  It will assume that Kinetica is being
    given exclusive access to these nodes and will default to using 85% of the
    largest N matching nodes (by memory capacity) where N is the number of ranks.

#### Running Multiple Ranks Per Node

In some instances, it may be best to run more than one Rank per node.  By default,
the Kinetica Operator assumes that there will only be one Rank per node and puts
a Kubernetes "anti-affinity" on the pods of the stateful set, forcing Kubernetes
to pick unique node hostnames to run Kinetica on.  If you wish to run multiple
Ranks per node, you should update the `db.gpudbCluster.ranksPerNode` setting on the
helm values file to specify how many ranks you wish to run per node.  Setting more
than one will remove the anti-affinity from the pods and will affect the automatic
resource calculations if you have not specified per-pod resources.