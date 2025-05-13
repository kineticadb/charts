---
hide:
  - navigation
  - toc
tags:
  - Advanced
  - Configuration
  - Ingress

status: new
subtitle: Configure Ingress to Kinetica for Kubernetes
---
# Ingress Configuration

Ingress provides a way for traffic to enter your Kubernetes cluster and get routed to
the proper destination.  Our Helm chart includes an option to automatically install
and configure an [`ingress-nginx`](https://kubernetes.github.io/ingress-nginx/ "ingress-nginx documention site")
ingress controller and can also create matching ingress records (by ensuring that the
`db.ingressController` value is set to `nginx`).

# Custom Ingress

Alternatively, you can create your own ingress and ingress records.  In Helm, you need 
to set the `ingressNginx.install` value to `false` to prevent the included `ingress-nginx`
from being installed.  Secondly, you can set the `db.ingressController` to `"none"` to
prevent the Operator from creating ingress records.

!!! tip
    If you are creating Kinetica Clusters outside of the Helm chart, you can set the
    spec.ingressController on the Kinetica Cluster to modify the ingress creation
    behavior.

<div class="grid cards" markdown>
-   :simple-nginx:{ .lg .middle } __`ingress-nginx` Configuration__

    ---

    Kubernetes provids the free [`ingress-nginx`](https://kubernetes.github.io/ingress-nginx/ "ingress-nginx documention site") for Kubernetes.

    [:octicons-arrow-right-24: How to set up Ingress with `ingress-nginx`](ingress_nginx_config.md)

-   :simple-nginx:{ .lg .middle } __`nginx-ingress` Configuration__

    ---

    Nginx offers an ingress controller named [`nginx-ingress`](https://docs.nginx.com/nginx-ingress-controller/ "nginx-ingress documentation site") for Kubernetes.

    [:octicons-arrow-right-24: How to set up Ingress with `nginx-ingress`](nginx_ingress_config.md "Setting up Ingress with nginx-ingress")
</div>

--- 
