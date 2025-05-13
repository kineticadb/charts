---
hide:
  - navigation
tags:
  - Administration
---

# Resource Group Management

Kinetica can restrict the resource consumption of users so that users do not
monopolize all the resources of a cluster.

## Creating a Resource Group

To create a resource group, you must provide a...

### Name

The name to be created.

!!! tip "naming"
    Must contain only letters, digits, and underscores.  Cannot begin with a digit.

### Ranking

The relative ranking among existing resource groups.  When using `before` or `after`,
you must also provide an Adjoining Resource Group to which this group is relative.
Valid values are:

* first
* last
* before
* after

### Adjoining Resource Group

When ranking is 'before' or 'after', this field specifies the name of the group to which
this comes before or after.

### Max CPU Concurrency

Maximum number of simultaneous threads that will be used to execute a request for this
group. The minimum allowed value is 4.

### Max Data

Maximum amount of cumulative ram usage regardless of tier status for this group. The
minimum allowed value is -1, which signifies unlimited.

### Max Scheduling Priority

Maximum priority of a scheduled task for this group. The minimum allowed value is 1. The
maximum allowed value is 100.

### Max Tier Priority

Maximum priority of a tiered object for this group. The minimum allowed value is 1. The
maximum allowed value is 10.

### Example

The following is an example of a Resource Group where users are limited to six concurrent
threads and twenty gigabytes of memory.

``` yaml
apiVersion: app.kinetica.com/v1
kind: KineticaClusterResourceGroup
metadata:
  name: resource-group-sample
  namespace: gpudb
spec:
  db_create_resource_group_request:
    name: limited
    options:
      max_cpu_concurrency: "6"
      max_data: "21474836480" # 20*1024*1024*1024
```
