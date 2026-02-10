---
hide:
  - navigation
  - toc
tags:
  - GKE
  - Getting Started
  - Storage
---
# :simple-google: Google GKE Specifics

This page covers any Google Kubernetes Engine installation specifics.  Please make sure you have read the
[Preparation and Prerequisites](preparation_and_prerequisites.md) as well.  For example, you may wish to create
specific node groups for the compute and infrastructure nodes.

## CSI driver

!!! warning
    Make sure you have enabled the ebs-csi driver in your EKS cluster.
    This is required for the default storage class to work.
    
    Please refer to this [Google documentation](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver "GKE CSI Docs")
    for more information.

---

# Example Values for the Helm Chart

``` yaml
# NOTE: the pd-ssd type of storage is not applicable to some of the newer vm types and you may need to use one of the hyperdisk-* types instead.

global:
  defaultStorageClass: premium-rwo

kineticacluster:
  gpudbCluster:
    config:
      tieredStorage:
        globalTier:
          colocateDisks: true
        persistTier:
          default:
            parameters:
              type: pd-ssd
            provisioner: pd.csi.storage.gke.io
            volumeClaim:
              spec:
                storageClassName: premium-rwo

workbench:
  storageClass: premium-rwo

```
