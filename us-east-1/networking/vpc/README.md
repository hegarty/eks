# EKS Subnet Configuration

This document outlines the subnet configuration for the EKS cluster deployment, with a focus on creating a contiguous and efficient CIDR allocation across the different subnet types and Availability Zones.

## Goals

- Allocate CIDR blocks for subnets in a contiguous manner, minimizing gaps or wasted IP addresses between them.
- Optimize the IP space allocation based on the different subnet requirements (controller, ingress-egress, worker).
- Distribute subnets across multiple Availability Zones for high availability, following EKS best practices.

## Subnet Breakdown

The following subnets are defined in the adjacent `terragrunt.hcl` file:

### Controller Subnets
- 2 private subnets with CIDR blocks of `/28` (16 IP addresses each, 32 IP addresses total)
- Allocated in a contiguous manner within the VPC CIDR range
- Distributed across `use1-az1` and `use1-az2` Availability Zones

### Ingress-Egress Subnets
- 3 public subnets with CIDR blocks of `/25` (128 IP addresses each, 384 IP addresses total)
- Allocated immediately after the controller subnets in the VPC CIDR range
- Distributed across `use1-az1`, `use1-az2`, and `use1-az4` Availability Zones

### Worker Subnets
- 3 private subnets with CIDR blocks of `/23` (512 IP addresses each, 1,536 IP addresses total)
- Allocated immediately after the ingress-egress subnets in the VPC CIDR range
- Distributed across `use1-az1`, `use1-az2`, and `use1-az4` Availability Zones

## CIDR Allocation
The CIDR blocks are allocated in the following contiguous manner within the VPC CIDR range:
```
Controller Subnets:
10.0.24.0/28  (use1-az1)
10.0.24.16/28 (use1-az2)
```
```
Ingress-Egress Subnets:
10.0.24.128/25 (use1-az2)
10.0.25.0/25   (use1-az4)
10.0.25.128/25 (use1-az1)
```
```
Worker Subnets:
10.0.26.0/23 (use1-az1)
10.0.28.0/23 (use1-az2)
10.0.30.0/23 (use1-az4)
```
