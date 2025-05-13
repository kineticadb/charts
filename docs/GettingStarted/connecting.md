---
hide:
  - navigation
tags:
  - Connecting
---

# Connecting to Kinetica

## :material-monitor: Connecting to the User Interfaces

How to connect to Kinetica from outside the Kubernetes cluster depends upon how ingress and cluster
are configured. When using the provided ingress and the various UIs are enabled, they are found at:

Workbench: `FQDN/workbench`

GAdmin: `FQDN/gadmin`

Reveal: `FQDN/reveal`

... where the FQDN is provided by the Helm chart values at `db.gpudbCluster.fqdn` or by the
KineticaCluster CR at `spec.gpudbCluster.fqdn`.

## :material-api: Connecting to Rest APIs

=== ":simple-kubernetes: Inside Kubernetes"

    In many cases, database API clients are running inside Kubernetes.  In these cases, it is often
    preferable to connect to the database using an internal kubernetes service, rather than an external
    Load Balancer.  In these cases, you can utilize the automatically created cluster service:

    `CLUSTERNAME-service-rank0.gpudb.svc.cluster.local:8082/gpudb-0`

    The Kinetica Operators create service endpoints for the database in the format `CLUSTERNAME-service-rankN`
    where CLUSTERNAME is the name of the KineticaCluster object and N is the rank number.

    Clients should always primarily connect to the `rank0` service.  The other services are used when
    users perform multi-headed inserts or queries.

    The ports on the services follow the standard Kinetica port list, and clients should generally connect
    to port 8082 with the path /gpudb-N where again N is the rank number.

    Additionally, when enabled, a Postgres TCP service is available on port 5432 of the rank0 service
    (`CLUSTERNAME-service-rank0.gpudb.svc.cluster.local:5432`).

=== ":simple-nginx: External to Kubernetes With the Provided Ingress-nginx"

    When installing the Kinetica Operators from Helm, one option is to install a known working version
    of [ingress-nginx](https://github.com/kubernetes/ingress-nginx) and create the proper ingress
    records (`db.ingressController` = `nginx`).  This will create standard ingress records which should
    route traffic from the Fully Qualified Domain Name (FQDN) that was provided in the Helm chart values
    (`db.gpudbCluster.fqdn` to the various Kinetica services).  API clients should connect over http/https
    ports (depending on cluster configuration) via:

    `http(s)://FQDN/CLUSTERNAME/gpudb-0`

    Additionally, when properly configured and enabled, a Postgres TCP service is exposed on the LoadBalancer
    service on port 5432 (`tcp://FQDN:5432`).


=== ":material-web: Using a Custom Ingress"

    When creating your own ingress records, please refer to the [Ingress documentation](../Advanced/ingress_configuration.md)
    on how to create the proper ingress records.  The URLs you will connect to will depend upon how you
    setup your ingress.

