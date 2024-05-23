---
hide:
  - navigation
tags:
  - Operations
---
# Kinetica for Kubernetes Suspend & Resume

It is possible to supend Kinetica for Kubernetes which spins down the DB.

!!! note "Infra Structure"
    For each deployment of Kinetica for Kubernetes there are two distinct types of pods: -
    
    * 'Compute' pods containing the Kinetica DB along with the Statics Pod
    * 'Infra' pods containing the supporting apps, e.g. Workbench, OpenLDAP etc,
    and the Kinetica Operators.

    Whilst Kinetica for Kubernetes is in the `Suspended` state only the 'Compute' pods are
    scaled down. The 'Infra' pods remain running in order for Workbenchto be able
    to login, backup, restore and in this case Resume the suspended system.

There are three discrete ways to suspand and resume KInetica for Kubernetes: -

* Manually from Workbench
* Auto-Suspend set in Workbench or fro the Helm installation Chart.
* Manually using a Kubernetes CR

## Suspend - Manually from Workbench

---

## Suspend - Auto-Suspend

---

## Suspend - Manually using a Kubernetes CR
