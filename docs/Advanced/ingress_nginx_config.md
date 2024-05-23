---
hide:
  - navigation
tags:
  - Advanced  
  - Configuration
  - Ingress
icon: simple-nginx
---
# :simple-nginx: `ingress-nginx` Ingress Configuration

To use an 'external' ingress-nginx controller 
i.e. not the one optionally installed 
by the Kinetica Operators Helm chart it is necessary to 
disable ingress in the `KineticaCluster` CR.

The field `spec.ingressController: nginx` should be set to `spec.ingressController: none`.

It is then necessary to create the required Ingress CRs by hand. Below is a list
of the Ingress paths that need to be exposed along with sample ingress-nginx CRs.

## Required Ingress Routes

### Ingress Routes

--8<-- "docs/Advanced/ingress_urls.md"

### Example Ingress CRs

#### Example GAdmin Ingress CR

??? example "Example GAdmin Ingress CR"
    ```yaml title="Example GAdmin Ingress CR"
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name:  cluster-name-gadmin-ingress #(1)!
      namespace: gpudb
    spec:
      ingressClassName: nginx
      tls:
        - hosts:
            - cluster-name.example.com #(1)!
          secretName: kinetica-tls
      rules:
        - host: cluster-name.example.com #(1)!
          http:
            paths:
              - path: /gadmin
                pathType: Prefix
                backend:
                  service:
                    name: cluster-name-gadmin-service #(1)!
                    port:
                      name: gadmin
              - path: /tableau
                pathType: Prefix
                backend:
                  service:
                    name: cluster-name-gadmin-service #(1)!
                    port:
                      name: gadmin
              - path: /files
                pathType: Prefix
                backend:
                  service:
                    name: cluster-name-gadmin-service #(1)!
                    port:
                      name: gadmin
    ```
     1. where `cluster-name` is the name of the Kinetica Cluster

#### Example Rank Ingress CR

??? example "Example Rank Ingress CR"
    ``` yaml title="Example Rank Ingress CR"
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: cluster-name-rank1-ingress
      namespace: gpudb
    spec:
      ingressClassName: nginx
      tls:
        - hosts:
            - cluster-name.example.com
          secretName: kinetica-tls
      rules:
        - host: cluster-name.example.com
          http:
            paths:
              - path: /cluster-name(/gpudb-1(/.*|$))
                pathType: Prefix
                backend:
                  service:
                    name: cluster-name-rank1-service
                    port:
                      name: httpd
              - path: /cluster-name/gpudb-1/hostmanager(.*)
                pathType: Prefix
                backend:
                  service:
                    name: cluster-name-rank1-service
                    port:
                      name: hostmanager
    
    ```
   1. where `cluster-name` is the name of the Kinetica Cluster
    
#### Example Reveal Ingress CR
??? example "Example Reveal Ingress CR"
    ```yaml title="Example Reveal Ingress CR"
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          name: cluster-name-reveal-ingress
          namespace: gpudb
        spec:
          ingressClassName: nginx
          tls:
            - hosts:
                - cluster-name.example.com
              secretName: kinetica-tls
          rules:
            - host: cluster-name.example.com
              http:
                paths:
                  - path: /reveal
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /caravel
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /static
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /logout
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /resetmypassword
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /dashboardmodelview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /dashboardmodelviewasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /slicemodelview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /slicemodelviewasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /sliceaddview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /databaseview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /databaseasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /databasetablesasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /tablemodelview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /tablemodelviewasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /csstemplatemodelview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /csstemplatemodelviewasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /users
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /roles
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /userstatschartview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /permissions
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /viewmenus
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /permissionviews
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /accessrequestsmodelview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /accessrequestsmodelviewasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /logmodelview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /logmodelviewasync
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /userinfoeditview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /tablecolumninlineview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
                  - path: /sqlmetricinlineview
                    pathType: Prefix
                    backend:
                      service:
                        name: cluster-name-reveal-service
                        port:
                          name: reveal
    ```
    1. where `cluster-name` is the name of the Kinetica Cluster

### Exposing the Postgres Proxy Port

In order to access Kinetica's Postgres functionality some TCP (not HTTP) ports need to be open externally.

For `ingress-nginx` a configuration file needs to be created to enable port 5432.

```  yaml title="tcp-services.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: kinetica-system # (1)!
data:
  '5432': gpudb/kinetica-k8s-sample-rank0-service:5432 #(2)!
  '9002': gpudb/kinetica-k8s-sample-rank0-service:9002 #(3)!
```
1. Change the namespace to the namespace your ingress-nginx controller is running in. e.g. `ingress-nginx` <br/>
2. This exposes the postgres proxy port on the default `5432` port. If you wish to change this to a non-standard port then it needs to be changed here but also in the Helm `values.yaml` to match.<br/>
3. This port is the Table Monitor port and should always be exposed alongside the Postgres Proxy.
---
