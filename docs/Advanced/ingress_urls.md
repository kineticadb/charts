

#### GAdmin Paths

| Path      | Service                        | Port                |
|:----------|:-------------------------------|:--------------------|
| `/gadmin`   | `cluster-name-gadmin-service`  | `gadmin` (8080/TCP) |
| `/tableau`  | `cluster-name-gadmin-service`  | `gadmin` (8080/TCP)    |
 | `/files`  | `cluster-name^-gadmin-service` | `gadmin`   (8080/TCP)  |

where `cluster-name` is the name of the Kinetica Cluster 
i.e. what is in the `.spec.gpudbCluster.clusterName` in the KineticaCluster CR.

#### Workbench Paths

| Path    | Service                              | Port                        |
|:--------|:-------------------------------------|:----------------------------|
| `/` | `workbench-workbench-service` | `workbench-port` (8000/TCP) |

#### DB `rank-0` Paths

| Path                                                 | Service                          | Port                             |
|:-----------------------------------------------------|:---------------------------------|:---------------------------------|
| <code>/cluster-145025b8(/gpudb-0(/.*&#124;$))</code> | `cluster-145025b8-rank0-service` | `httpd` (8082/TCP) |
| `/cluster-145025b8/gpudb-0/hostmanager(.*)`          | `cluster-145025b8-rank0-service` | `hostmanager` (9300/TCP)         |

#### DB `rank-N` Paths

| Path                                                 | Service                          | Port                             |
|:-----------------------------------------------------|:---------------------------------|:---------------------------------|
| <code>/cluster-145025b8(/gpudb-N(/.*&#124;$))</code> | `cluster-145025b8-rank1-service` | `httpd` (8082/TCP) |
| `/cluster-145025b8/gpudb-N/hostmanager(.*)`          | `cluster-145025b8-rank1-service` | `hostmanager` (9300/TCP)         |


#### Reveal Paths

| Path       | Service                              | Port                |
|:-----------|:-------------------------------------|:--------------------|
| `/reveal`  | `cluster-name-reveal-service` | `reveal` (8088/TCP) |
| `/caravel` | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/static`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/logout`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/resetmypassword`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/dashboardmodelview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/dashboardmodelviewasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/slicemodelview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/slicemodelviewasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/sliceaddview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/databaseview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/databaseasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/databasetablesasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/tablemodelview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/csstemplatemodelview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/csstemplatemodelviewasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/users`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/roles`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/userstatschartview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/permissions`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/viewmenus`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/permissionviews`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/accessrequestsmodelview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/accessrequestsmodelviewasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/logmodelview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/logmodelviewasync`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/userinfoeditview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/tablecolumninlineview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |
| `/sqlmetricinlineview`  | `cluster-name-reveal-service` | `reveal` (8088/TCP)         |

