
# Terraform VPC Module

## Overview

This Terraform module provisions a Virtual Private Cloud (VPC) with public and private subnets, NAT gateways, and associated Network ACL (NACL) rules on AWS. It includes features for managing public and private subnets, routing tables, and network access control for both IPv4 and IPv6 configurations.

### Features

- Provisioning of a VPC with configurable CIDR block.
- Creation of public and private subnets in multiple Availability Zones (AZs).
- Automatic NAT Gateway creation for private subnets.
- Public and private subnet association with NACLs (Network ACLs).
- Routing table management for both public and private subnets.
- Validation of CIDR blocks, DNS settings, and NACL rules.

## Usage

```hcl
module "vpc" {
  source  = "./path_to_vpc_module"

  vpc = {
    name                 = "example-vpc"
    cidr                 = "10.0.0.0/16"
    secondary_cidr_blocks = ["10.1.0.0/16"]
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags                 = {
      "Environment" = "dev"
    }
  }

  subnets = {
    public = {
      "pub1" = {
        name                               = "public-subnet-1"
        cidr                               = "10.0.1.0/24"
        az                                 = "us-west-2a"
        map_public_ip_on_launch            = true
        private_dns_hostname_type_on_launch = "ip-name"
        nacl = {
          "rule1" = {
            rule_number = 100
            egress      = false
            protocol    = "tcp"
            rule_action = "allow"
            cidr_block  = "0.0.0.0/0"
            from_port   = 80
            to_port     = 80
          }
        }
      }
    }
    private = {
      "private1" = {
        name                               = "private-subnet-1"
        cidr                               = "10.0.2.0/24"
        az                                 = "us-west-2b"
        nat_gateway                        = "SINGLE"
        private_dns_hostname_type_on_launch = "resource-name"
      }
    }
  }

  tags_default = {
    "Owner"       = "DevOps"
    "Terraform"   = "true"
  }
}
```

## Inputs

| Name                       | Description                                                                                          | Type     | Default                   | Required |
|----------------------------|------------------------------------------------------------------------------------------------------|----------|---------------------------|----------|
| `vpc`                      | Configuration of the VPC, including name, CIDR block, DNS settings, etc.                             | `object` | n/a                       | yes      |
| `subnets`                  | Configuration of public and private subnets, including CIDR blocks, AZs, NACL rules, and more.       | `object` | `{}`                      | yes      |
| `tags_default`             | Default tags to apply to all resources.                                                              | `map`    | `{}`                      | no       |

## Outputs

| Name                        | Description                                                                                          |
|-----------------------------|------------------------------------------------------------------------------------------------------|
| `vpc_id`                    | The ID of the VPC.                                                                                   |
| `public_subnet_ids`          | A list of IDs for all public subnets.                                                                |
| `private_subnet_ids`         | A list of IDs for all private subnets.                                                               |
| `nat_gateway_ids`            | A list of NAT Gateway IDs.                                                                           |

## Validations

The module includes validation rules for:

- CIDR block formats (`vpc.cidr`, `subnets.public[].cidr`, `subnets.private[].cidr`).
- Allowed values for `private_dns_hostname_type_on_launch`.
- NACL rules validation to ensure proper configuration.

## License

This module is released under the MIT License. See [LICENSE](LICENSE) for more information.
