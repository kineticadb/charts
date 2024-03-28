# :simple-amazoneks: Amazon EKS Specifics

This page covers any Amazon EKS kubernetes cluster installation specifics.

## EBS CSI driver

!!! warning
    Make sure you have enabled the ebs-csi driver in your EKS cluster.
    This is required for the default storage class to work.
    
    Please refer to this [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html "AWS EBS CSI Docs")
    for more information.

