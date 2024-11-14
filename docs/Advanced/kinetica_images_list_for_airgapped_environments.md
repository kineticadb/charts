??? info "Kinetica Images for an Air-Gapped Environment"
    If you are installing Kinetica with Helm in an air-gapped environment you will either need a Registry Proxy to pass
    the requests through or to download the images and push them to your internal Registry.

    For information on ways to transfer the files into an air-gapped environment [**_See here_**](../Advanced/airgapped.md "Ways to transfer images").

    ### Required Container Images
    #### docker.io (Required Kinetica Images for All Installations)
    * docker.io/kinetica/kinetica-k8s-operator:{{kinetica_full_version}}
        * docker.io/kinetica/kinetica-k8s-cpu:{{kinetica_full_version}} **or**
        * docker.io/kinetica/kinetica-k8s-cpu-avx512:{{kinetica_full_version}} **or**
        * docker.io/kinetica/kinetica-k8s-gpu:{{kinetica_full_version}}
    * docker.io/kinetica/workbench-operator:{{kinetica_full_version}}
    * docker.io/kinetica/workbench:{{kinetica_full_version}}
    * docker.io/kinetica/kinetica-k8s-monitor:{{kinetica_full_version}}
    * docker.io/kinetica/busybox:{{kinetica_full_version}}
    * docker.io/kinetica/fluent-bit:{{kinetica_full_version}}
    * docker.io/kinetica/kagent:7.1.9.15.20230823123615.ga

    #### nvcr.io (Required Kinetica Images for GPU Installations using `kinetica-k8s-gpu`)
    * nvcr.io/nvidia/gpu-operator:v23.9.1

    #### registry.k8s.io (Required Kinetica Images for GPU Installations using `kinetica-k8s-gpu`)
    * registry.k8s.io/nfd/node-feature-discovery:v0.14.2

    #### docker.io (Required Supporting Images)
    * docker.io/bitnami/openldap:2.6.7
    * docker.io/alpine/openssl:latest (used by bitnami/openldap)
    * docker.io/otel/opentelemetry-collector-contrib:0.95.0

    #### quay.io (Required Supporting Images)
    * quay.io/brancz/kube-rbac-proxy:v0.14.2

    ### Optional Container Images
    These images are only required if certain features are enabled as part of the Helm installation: -
    
    * CertManager
    * ingress-ninx
    
    #### quay.io (Optional Supporting Images)
    * quay.io/jetstack/cert-manager-cainjector:v1.13.3 (if optionally installing CertManager via Kinetica Helm Chart)
    * quay.io/jetstack/cert-manager-controller:v1.13.3 (if optionally installing CertManager via Kinetica Helm Chart)
    * quay.io/jetstack/cert-manager-webhook:v1.13.3 (if optionally installing CertManager via Kinetica Helm Chart)

    #### registry.k8s.io (Optional Supporting Images)
    * registry.k8s.io/ingress-nginx/controller:v1.9.4 (if optionally installing Ingress nGinx via Kinetica Helm Chart)
    * registry.k8s.io/ingress-nginx/controller:v1.9.6@sha256:1405cc613bd95b2c6edd8b2a152510ae91c7e62aea4698500d23b2145960ab9c
    
    ### Which Kinetica Core Image do I use?

    | Container Image | Intel (AMD64) | Intel (AMD64 AVX512) | Amd (AMD64) | Graviton (aarch64) | Apple Silicon (aarch64) |
    | :-------------- | :------------: | :-------------------: | :----------: | :-----------------: | :----------------------: |
    | kinetica-k8s-cpu | :octicons-check-circle-fill-24: | :octicons-check-circle-fill-24:(1) | :octicons-check-circle-fill-24: | :octicons-check-circle-fill-24: | :octicons-check-circle-fill-24: | 
    | kinetica-k8s-cpu-avx512 |  | :octicons-check-circle-fill-24: |  |  |  | 
    | kinetica-k8s-gpu | :octicons-check-circle-fill-24:(2) | :octicons-check-circle-fill-24:(2) | :octicons-check-circle-fill-24:(2) |  |  | 

    1. It is preferable on an Intel AVX512 enabled CPU to use the kinetica-k8s-cpu-avx512 container image
    2. With a supported nVidia GPU.

---
