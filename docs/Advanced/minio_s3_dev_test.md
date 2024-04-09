---
hide:
  - navigation
tags:
  - Advanced
  - Storage
status: new
---
# Using [Minio](https://min.io/) for S3 Storage in Dev/Test :material-new-box:

!!! note "If you require a new Minio installation"
    Please follow the installation instructions found 
    [here](https://min.io/docs/minio/kubernetes/upstream/operations/installation.html) 
    to install the Minio Operator and to create your first tenant.

## Create Minio Tenant

In our example below we have created a tenant `kinetica` in the `gpudb` namespace using 
the Kinetica storage class `kinetica-k8s-sample-storageclass`.

![create_tenant.png](..%2Fimages%2Fminio%2Fcreate_tenant.png)

or use the minio kubectl plugin

```shell title="minio cli - create tenant"
kubectl minio tenant create kinetica --capacity 32Gi --servers 1 --volumes 1 --namespace gpudb --storage-class kinetica-k8s-sample-storageclass --disable-tls
```

!!! tip "Console Port Forward"
    Forward the minio console for our newly created tenant

    ```shell
    kubectl port-forward service/kinetica-console -n gpudb 9443:9443
    ```

In that tenant we create a bucket `kinetica-cold-storage` and in that bucket we
create the path `gpudb/cold-storage`.

![create_path_in_bucket.png](..%2Fimages%2Fminio%2Fcreate_path_in_bucket.png)

Once you have a tenant up and running we can configure Kinetica for Kubernetes to use 
it as the DB Cold Storage tier.

!!! tip "Backup/Restore Storage"
    Minio can also be used as the S3 storage for Velero. This enables Backup/Restore
    functionality via the `KineticaBackup` & `KineticaRestore` CRs.

## Configuring Kinetica to use Minio

### Cold Storage

In order to configure the Cold Storage Tier for the Database it is necessary to add a 
`coldStorageTier` to the `KineticaCluster` CR. As we are using S3 Buckets for storage
we then require `coldStorageS3` entry which allows us to set the `awsSecretAccessKey` &
`awsAccessKeyId` which were generated when the tenant was created in Minio. 

If we look in the `gpudb` name space we can see that Minio created a 
Kubernetes service called `minio` exposed on port `443`.   

In the `coldStorageS3` we need to add an `endpoint` field which contains the `minio`
service name and the namespace `gpudb` i.e. `minio.gpudb.svc.cluster.local`.

```yaml title="`KineticaCluster coldStorageTier` S3 Configuration"
spec:
  gpudbCluster:
    config:
      tieredStorage:
        coldStorageTier:
          coldStorageS3:
        coldStorageTier:
            coldStorageType: s3
            coldStorageS3:
            basePath: gpudb/cold-storage/
            bucketName: kinetica-cold-storage
            endpoint: minio.gpudb.svc.cluster.local:80
            limit: "32Gi"
            useHttps: false
            useManagedCredentials: false
            useVirtualAddressing: false
            awsSecretAccessKey: 6rLaOOddP3KStwPDhf47XLHREPdBqdav
            awsAccessKeyId: VvlP5rHbQqzcYPHG
      tieredStrategy:
        default: VRAM 1, RAM 5, PERSIST 5, COLD0 10
```
---

### Velero Backups

#### Coming Soon

---
[:material-arrow-expand-up:  Home](../index.md "Home Page")
