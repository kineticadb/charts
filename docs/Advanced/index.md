---
hide:
  - navigation
  - toc
---
# :material-ninja: Advanced Topics

<div class="grid cards" markdown>
-   :simple-helm:{ .lg .middle } __Find alternative chart versions__

    ---

    How to use pre-release or development Chart version if requested to by Kinetica Support. 

    [:octicons-arrow-right-24: Alternative Charts](alternative_charts.md "Pre-Release Helm Usage")

-   :simple-ingress:{ .lg .middle } __Configuring Ingress Records__

    ---

    How to expose Kinetica via Kubernetes Ingress.


    [:octicons-arrow-right-24: Ingress Configuration](ingress_configuration.md "Ingress Record Creation")

-   :material-connection:{ .lg .middle } __Air-Gapped Environments__

    ---

    Specifics for installing Kinetica for Kubernetes in an Air-Gapped Environment


    [:octicons-arrow-right-24: Airgapped](airgapped.md "Air-Gapped Envionment Specifics")

-   :simple-opentelemetry:{ .lg .middle } __Using your own OpenTelemetry Collector__

    ---

    How to configure Kinetica for Kubernetes to use your open OpenTelemetry collector.


    [:octicons-arrow-right-24: External OTEL](advanced_topics.md "OTEL Collector Configuration")

-   :simple-minio:{ .lg .middle } __Minio for Dev/Test S3 Storage__

    ---

    Install [Minio](https://min.io/) in order to enable S3 storage for Dev/Test.
    (Production).

    [:octicons-arrow-right-24: min.io](minio_s3_dev_test.md "S3 Buckets for Dev/Test")

-   :material-backup-restore:{ .lg .middle } __Installing Velero for Backup/Restore__

    ---

    Install [Velero](https://velero.io/) in order to enable Kinetica for Kubernetes 
    Backup/Restore functionality.
    (Production).

    [:octicons-arrow-right-24: Velero](velero_backup_restore.md "Backup/Restore Engine")

-   :material-apple:{ .lg .middle } __Kinetica DB on Apple OS X (Apple Silicon)__

    ---

    Install the Kinetica DB on a new Kubernetes 'production-like' cluster on Apple OS X
    (Apple Silicon) using [UTM](https://mac.getutm.app/
     "UTM employs Apple's Hypervisor virtualization framework to run ARM64 operating systems on Apple Silicon at near native speeds.").

    [:octicons-arrow-right-24: Apple ARM64](kinetica_mac_arm_k8s.md)

  -   :material-tools:{ .lg .middle } __Bare Metal/VM Installation from Scratch__

      ---

      Install the Kinetica DB on a new Kubernetes 'production-like' bare metal (or VMs) 
      cluster via [`kubeadm`](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
      using [`cilium`](https://cilium.io/) Networking,
      [`kube-vip`](https://kube-vip.io/) LoadBalancer.
      (Production).

      [:octicons-arrow-right-24: Apple ARM64](kinetica_mac_arm_k8s.md)

</div>

--- 
[:material-arrow-expand-up:  Home](../index.md "Home Page")
