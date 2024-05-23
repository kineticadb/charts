---
hide:
  - navigation
  - toc
tags:
  - Advanced
---
# Advanced Topics

<div class="grid cards" markdown>
-   :simple-helm:{ .lg .middle } __Find alternative chart versions__ 

    ---

    How to use pre-release or development Chart version if requested to by Kinetica Support. 
    <br/><br/>
    [:octicons-arrow-right-24: Alternative Charts](alternative_charts.md "Pre-Release Helm Usage")

-   :simple-ingress:{ .lg .middle } __Configuring Ingress Records__ 

    ---

    How to expose Kinetica via Kubernetes Ingress.
    <br/><br/><br/>
    [:octicons-arrow-right-24: Ingress Configuration](ingress_configuration.md "Ingress Record Creation")

-   :material-connection:{ .lg .middle } __Air-Gapped Environments__ :material-new-box:

    ---

    Specifics for installing Kinetica for Kubernetes in an Air-Gapped Environment
    <br/><br/>
    [:octicons-arrow-right-24: Airgapped](airgapped.md "Air-Gapped Envionment Specifics")

-   :simple-opentelemetry:{ .lg .middle } __Using your own OpenTelemetry Collector__

    ---

    How to configure Kinetica for Kubernetes to use your open OpenTelemetry collector.
    <br/><br/>

    [:octicons-arrow-right-24: External OTEL](advanced_topics.md "OTEL Collector Configuration")

-   :simple-minio:{ .lg .middle } __Minio for Dev/Test S3 Storage__ :material-dev-to: :material-new-box:

    ---

    Install [Minio](https://min.io/) in order to enable S3 storage for Development.<br/><br/>

    [:octicons-arrow-right-24: min.io](minio_s3_dev_test.md "S3 Buckets for Dev/Test")

- :material-kubernetes:{ .lg .middle } __Creating Resources with Kubernetes APIs__ :material-new-box:

    ---

    Create Users, Roles, DB Schema etc. using Kubernertes CRs.
    <br/><br/>
    [:octicons-arrow-right-24: Resources](../Administration/index.md "Kinetica CR for Resource Management")

  -   :material-apple:{ .lg .middle } __Kinetica on OS X (Apple Silicon)__ :simple-arm: :material-dev-to: :material-new-box:

      ---

      Install the Kinetica DB on a new Kubernetes 'production-like' cluster on Apple OS X
      (Apple Silicon) using [UTM](https://mac.getutm.app/
       "UTM employs Apple's Hypervisor virtualization framework to run ARM64 operating systems on Apple Silicon at near native speeds.").
      <br/><br/><br/>
      [:octicons-arrow-right-24: Apple ARM64](kinetica_mac_arm_k8s.md)

  -   :material-tools:{ .lg .middle } __Bare Metal/VM Installation from Scratch__ :material-new-box:

      ---

      Install the Kinetica DB on a new Kubernetes 'production-like' bare metal (or VMs) 
      cluster via [`kubeadm`](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
      using [`cilium`](https://cilium.io/) Networking,
      [`kube-vip`](https://kube-vip.io/) LoadBalancer.
      <br/><br/>
      [:octicons-arrow-right-24: Bare Metal/VM Installation](kubernetes_bare_metal_vm_install.md)

-   :simple-ingress:{ .lg .middle } __Software LoadBalancer__ :material-new-box:

      ---

    Install a software Kubernetes CCM/LoadBalancer for bare metal or 
    VM based Kubernetes CLusters.
    <br/><br/>
    [`kube-vip`](https://kube-vip.io/) LoadBalancer.

    [:octicons-arrow-right-24: Software LoadBalancer](kube_vip_loadbalancer.md)

</div>

--- 
