---
hide:
  - navigation
  - toc
tags:
  - Reference
---
# Kinetica Database Configuration

* kubectl (yaml)

## KineticaCluster

To deploy a new Database Instance into a Kubernetes cluster...

=== "kubectl"
    Using kubetctl a CustomResource of type `KineticaCluster` is used to define a new Kinetica DB Cluster in a yaml file.

    The basic Group, Version, Kind or GVK to instantiate a Kinetica DB Cluster is as follows: -
    
    ```yaml title="kineticacluster.yaml" linenums="1"
    apiVersion: app.kinetica.com/v1
    kind: KineticaCluster
    ```

    ### Metadata

    to which we add a `metadata:` block for the name of the DB CR along with the `namespace` into which we are
    targetting the installation of the DB cluster.

    ```yaml title="kineticacluster.yaml" linenums="1"
    apiVersion: app.kinetica.com/v1
    kind: KineticaCluster
    metadata:
      name: my-kinetica-db-cr
      namespace: gpudb
    spec:
    ```

    ### Spec
    
    Under the `spec:` section of the KineticaCLuster CR we have a number of sections supporting different aspects
    of the deployed DB cluster:-

    * [gpudbCluster](#gpudbCluster)
    * [autoSuspend](#autoSuspend)
    * [gadmin](#gadmin)

    #### gpudbCluster

    Configuartion items specific to the DB itself.

    ```yaml title="kineticacluster.yaml - gpudbCluster" linenums="1"
    apiVersion: app.kinetica.com/v1
    kind: KineticaCluster
    metadata:
      name: my-kinetica-db-cr
      namespace: gpudb
    spec:
      gpudbCluster:
    ```

    ##### gpudbCluster

    ```yaml title="cluster name & size" linenums="1"
    clusterName: kinetica-cluster 
    clusterSize: 
      tshirtSize: M 
      tshirtType: LargeCPU 
    fqdn: kinetica-cluster.saas.kinetica.com
    haRingName: default
    hasPools: false    
    ```

    `1. clusterName` - the user defined name of the Kinetica DB Cluster

    `2. clusterSize` - block that defines the number of DB Ranks to run

    `3. tshirtSize` - sets the cluster size to a defined size based upon the t-shirt size. Valid sizes are: -

    * `XS` -   1 DB Rank
    * `S` -    2 DB Ranks
    * `M` -    4 DB Ranks
    * `L` -    8 DB Ranks
    * `XL` -   16 DB Ranks
    * `XXL` -  32 DB Ranks
    * `XXXL` - 64 DB Ranks

    `4. tshirtType` - block that defines the tyoe DB Ranks to run: -

    * `SmallCPU` - 
    * `LargeCPU` -
    * `SmallGPU` - 
    * `LargeGPU` -

    `5. fqdn` - The fully qualified URL for the DB cluster. Used on the Ingress records for any exposed services.

    `6. haRingName` - Default: `default`

    `7. hasPools` - Whether to enable the separate node 'pools' for "infra", "compute" pod scheduling.
                    Default: false
                    +optional

    #### autoSuspend

    The DB Cluster autosuspend section allows for the spinning down of the core DB Pods to release the underlying
    Kubernetes nodes to reduce infrastructure costs when the DB is not in use. 

    ``` yaml title="kineticacluster.yaml - autoSuspend" linenums="1" hl_lines="7 8 9"
    apiVersion: app.kinetica.com/v1
    kind: KineticaCluster
    metadata:
      name: my-kinetica-db-cr
      namespace: gpudb
    spec:
      autoSuspend:
        enabled: false
        inactivityDuration: 1h0m0s
    ```

    `7.` the start of the `autoSuspend` definition

    `8.` `enabled` when set to `true` auto suspend of the DB cluster is enabled otherwise set to `false` and no 
        automatic suspending of the DB takes place.  If omitted it defaults to `false`

    `9.` `inactivityDuration` the duration after which if no DB activity has taken place the DB will be suspended

    !!! info "Horizontal Pod Autoscaler"

        In order for `autoSuspend` to work correctly the Kubernetes Horizontal Pod Autoscaler needs to be deployed to
        the cluster.


    #### gadmin

    GAdmin the Database Administration Console

    ![GAdmin](../images/gadmin.png)


    ```yaml title="kineticacluster.yaml - gadmin" linenums="1" hl_lines="7 8 9 10 11 12"
    apiVersion: app.kinetica.com/v1
    kind: KineticaCluster
    metadata:
      name: my-kinetica-db-cr
      namespace: gpudb
    spec:
      gadmin:
        containerPort:
          containerPort: 8080
          name: gadmin
          protocol: TCP
        isEnabled: true
    ```

    `7.` `gadmin` configuration block definition

    `8.` `containerPort` configuration block i.e. where `gadmin` is exposed on the DB Pod

    `9.` `containerPort` the port number as an integer. Default: `8080`

    `10.` `name` the name of the port being exposed. Default:  `gadmin`

    `11.` `protocol` network protocal used. Default: `TCP`

    `12.` `isEnabled` whether `gadmin` is exposed from the DB pod. Default: `true`

## KineticaUser

## KineticaGrant

## KineticaSchema

## KineticaResourceGroup
