# Kinetica DB Cluster Operator Deployment

Helm Charts and kubectl `.yaml` files are provided to support the deployment of the Kinetica Database 
Kubernetes Operator(s). There are two Kinetica operators that will be deployed: -

* [Kinetica Database Operator](#kinetica-database-operator)
* [Kinetica Workbench Operator](#kinetica-workbench-operator)

## Kinetica Database Operator
The Kinetica Database Operator manages the full lifecycle of the Database including: - 

* Deployment
* Management (Pause/Suspend)
* Upgrading
* Backup
* Restore
* Deletion
* User Creation
* User Deletion
* User Grants
* User Schema

both on [supported on-premise Kubernetes distributions](#supported-on-premise-kubernetes-distributions) and 
[supported cloud platforms](#supported-cloud-platforms).

## Kinetica Workbench Operator
The Kinetica Workbench Operator manages the lifecycle of the Kinetica Workbench deployment. 
Each Kinetica DB has a corresponding Workbench associated.

## Helm Charts

Information on the [Helm Charts](Operators/kinetica-operators.md)

## Supported On-Premise Kubernetes Distributions

* KinD - Kubernetes Versions >= 1.22.x
* Kubeadm - Kubernetes Versions >= 1.22.x

## Supported Cloud Platforms
Currently the Kinetica DB Operator supports deployment on: -

* [Microsoft Azure](#microsoft-azure)
* [Amazon AWS](#amazon-aws)

### Microsoft Azure

The operator runs as part of an Azure Marketplace offering.

### Amazon AWS

The operator runs as part of an AWS Marketplace offering.
