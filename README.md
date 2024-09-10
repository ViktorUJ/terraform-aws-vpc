
# Terraform AWS VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) along with public and private subnets, route tables, NAT gateways, and Network ACLs. It provides a customizable setup for a scalable and secure VPC in AWS, allowing the user to configure core components based on their specific use case.

## Usage

```hcl
module "vpc" {
  source = "path_to_module"

  vpc = {
    name                  = "example-vpc"
    cidr                  = "10.0.0.0/16"
    secondary_cidr_blocks = []
    tags                  = {
      Environment = "dev"
    }
    enable_dns_support   = true
    enable_dns_hostnames = true
  }

  subnets = {
    public = {
      subnet_1 = {
        az   = "us-west-2a"
        cidr = "10.0.1.0/24"
        type = "web"
      }
    }

    private = {
      subnet_1 = {
        az   = "us-west-2a"
        cidr = "10.0.2.0/24"
        type = "app"
      }
    }
  }
}
```

## Input Variables

### VPC Configuration (`vpc` object)
- **`name`** (`string`) – The name of the VPC.
- **`cidr`** (`string`) – The CIDR block for the VPC.
- **`secondary_cidr_blocks`** (`list(string)`) – (Optional) Additional CIDR blocks to associate with the VPC. Default is an empty list.
- **`tags`** (`map(string)`) – (Optional) Tags to assign to the VPC. Default is an empty map.
- **`instance_tenancy`** (`string`) – (Optional) The instance tenancy option for instances in the VPC. Can be `default` or `dedicated`. Default is `default`.
- **`enable_dns_support`** (`bool`) – (Optional) Enable DNS support in the VPC. Default is `true`.
- **`enable_dns_hostnames`** (`bool`) – (Optional) Enable DNS hostnames in the VPC. Default is `false`.

### Subnet Configuration (`subnets` object)
- **`public`** (`map`) – Public subnet configurations, keyed by subnet name.
  - **`az`** (`string`) – Availability Zone for the subnet.
  - **`cidr`** (`string`) – The CIDR block for the subnet.
  - **`type`** (`string`) – A custom type label for the subnet (e.g., `web`, `app`).
- **`private`** (`map`) – Private subnet configurations, keyed by subnet name.
  - **`az`** (`string`) – Availability Zone for the subnet.
  - **`cidr`** (`string`) – The CIDR block for the subnet.
  - **`type`** (`string`) – A custom type label for the subnet (e.g., `app`, `db`).

## Outputs

### VPC Outputs
- **`vpc_var`** – The input VPC object.
- **`vpc_raw`** – The AWS VPC resource.

### Subnet Outputs
- **`normalized_public_subnets_all`** – Normalized list of all public subnets.
- **`public_subnets_by_type`** – Public subnets grouped by type.
- **`public_subnets_by_az`** – Public subnets grouped by Availability Zone.
- **`normalized_private_subnets_all`** – Normalized list of all private subnets.
- **`private_subnets_by_type`** – Private subnets grouped by type.
- **`private_subnets_by_az`** – Private subnets grouped by Availability Zone.

### NAT Gateway Outputs
- **`nat_gateway_single_raw`** – The NAT gateway for a single subnet.
- **`nat_gateway_subnet_raw`** – The NAT gateway for each subnet.
- **`nat_gateway_az_raw`** – The NAT gateway for each Availability Zone.

### Network ACL (NACL) Outputs
- **`nacl_default_rules_raw`** – Default NACL rules.
- **`public_nacl_raw`** – Public Network ACL resource.
- **`public_nacl_rules_raw`** – Rules for the public Network ACL.
- **`private_nacl_raw`** – Private Network ACL resource.
- **`private_nacl_rules_raw`** – Rules for the private Network ACL.

### Route Table Outputs
- **`route_table_private_raw`** – Private route table.
- **`route_table_public_raw`** – Public route table.
