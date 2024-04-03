---
hide:
  - navigation
  - toc
---

# Kinetica for Kubernetes Setup

<div class="grid cards" markdown>
-   :material-shovel:{ .lg .middle } __Prepare to Install__

    ---

    What you need to know & do before beginning an installation.

    [:octicons-arrow-right-24: Preparation and Prerequisites](../GettingStarted/preparation_and_prerequisites.md)

-   :material-clock-fast:{ .lg .middle } __Set up in 15 minutes__

    ---

    Install the Kinetica DB with Helm and get up and running in minutes.

    [:octicons-arrow-right-24: Installation](../GettingStarted/installation.md)

-   :material-wrench:{ .lg .middle } __Beyond a Simple Installation__

    ---

    It is possible using the Helm Charts and Kinetica CRDs to customize your installation in a number of ways.

    [:octicons-arrow-right-24: Advanced Topics](../Advanced/advanced_topics.md)

</div>

[//]: # (* [Getting Started]&#40;../GettingStarted/index.md&#41;)

[//]: # (* [Advanced Topics]&#40;../Advanced/advanced_topics.md&#41;)


[//]: # (Helm Charts and kubectl `.yaml` files are provided to support the deployment of the Kinetica Database )

[//]: # (Kubernetes Operator&#40;s&#41;. There are two Kinetica operators that will be deployed: -)

[//]: # ()

[//]: # (* [Kinetica Database Operator]&#40;#kinetica-database-operator&#41;)

[//]: # (* [Kinetica Workbench Operator]&#40;#kinetica-workbench-operator&#41;)

[//]: # ()

[//]: # (## Kinetica Database Operator)

[//]: # (The Kinetica Database Operator manages the full lifecycle of the Database including: - )

[//]: # ()

[//]: # (* Deployment)

[//]: # (* Management &#40;Pause/Suspend&#41;)

[//]: # (* Upgrading)

[//]: # (* Backup)

[//]: # (* Restore)

[//]: # (* Deletion)

[//]: # (* User Creation)

[//]: # (* User Deletion)

[//]: # (* User Grants)

[//]: # (* User Schema)

[//]: # ()

[//]: # (both on [supported on-premise Kubernetes distributions]&#40;#supported-on-premise-kubernetes-distributions&#41; and )

[//]: # ([supported cloud platforms]&#40;#supported-cloud-platforms&#41;.)

[//]: # ()

[//]: # (## Kinetica Workbench Operator)

[//]: # (The Kinetica Workbench Operator manages the lifecycle of the Kinetica Workbench deployment. )

[//]: # (Each Kinetica DB has a corresponding Workbench associated.)

[//]: # ()

[//]: # (## Helm Charts)

[//]: # ()

[//]: # (Information on the [Helm Charts]&#40;Operators/kinetica-operators.md&#41;)

[//]: # ()

[//]: # (## Supported On-Premise Kubernetes Distributions)

[//]: # ()

[//]: # (* KinD - Kubernetes Versions >= 1.22.x)

[//]: # (* Kubeadm - Kubernetes Versions >= 1.22.x)

[//]: # ()

[//]: # (## Supported Cloud Platforms)

[//]: # (Currently the Kinetica DB Operator supports deployment on: -)

[//]: # ()

[//]: # (* [Microsoft Azure]&#40;#microsoft-azure&#41;)

[//]: # (* [Amazon AWS]&#40;#amazon-aws&#41;)

[//]: # ()

[//]: # (### Microsoft Azure)

[//]: # ()

[//]: # (The operator runs as part of an Azure Marketplace offering.)

[//]: # ()

[//]: # (### Amazon AWS)

[//]: # ()

[//]: # (The operator runs as part of an AWS Marketplace offering.)
