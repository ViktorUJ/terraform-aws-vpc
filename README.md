
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
provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "../../"
  tags_default = {
    "Owner"       = "DevOps Team"
    "Terraform"   = "true"
    "cost_center" = "1111"
  }
  vpc = {
    name                  = "test-vpc"
    cidr                  = "10.10.0.0/16"
    secondary_cidr_blocks = ["10.2.0.0/16", "10.3.0.0/16"]
    tags                  = { "cost_center" = "444" }
    nacl_default = {
      test = {
        egress      = "true"
        rule_number = "99"
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
      test2 = {
        egress      = "false"
        rule_number = "99"
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    }
  }

  subnets = {
    public = {
      "pub1" = {
        name                                = "public-subnet-1"
        cidr                                = "10.10.1.0/24"
        az                                  = "eun1-az1"
        type                                = "qa-test"
        tags                                = { "cost_center" = "5555" }
        private_dns_hostname_type_on_launch = "resource-name"
        nacl = {
          test = {
            egress      = "true"
            rule_number = "99"
            rule_action = "allow"
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
          }
          test2 = {
            egress      = "false"
            rule_number = "99"
            rule_action = "allow"
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
          }
          allow_all_inbound = {
            egress      = "false"
            rule_number = "9999"
            rule_action = "allow"
            from_port   = "0"
            to_port     = "0"
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
          allow_all_outbound = {
            egress      = "true"
            rule_number = "8888"
            rule_action = "allow"
            from_port   = "0"
            to_port     = "0"
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
        }
      }
    }
    private = {
      "private1" = {
        name                                = "private-subnet-1"
        cidr                                = "10.10.11.0/24"
        az                                  = "eun1-az1"
        type                                = "qa-test"
        tags                                = { "cost_center" = "5555" }
        private_dns_hostname_type_on_launch = "resource-name"
        nat_gateway                         = "SINGLE"
        nacl = {
          test = {
            egress      = "true"
            rule_number = "99"
            rule_action = "allow"
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
          }
          test2 = {
            egress      = "false"
            rule_number = "99"
            rule_action = "allow"
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
          }
        }
      }

      "private2" = {
        name        = "private-subnet-2"
        cidr        = "10.10.12.0/24"
        az          = "eun1-az3"
        type        = "Devops"
        tags        = { "cost_center" = "1234" }
        nat_gateway = "SINGLE"
      }

      "private3" = {
        name        = "private-subnet-3"
        cidr        = "10.10.13.0/24"
        az          = "eu-north-1a"
        type        = "Devops"
        tags        = { "cost_center" = "1234" }
        nat_gateway = "SINGLE"
      }

      "private4" = {
        name        = "private-subnet-4"
        cidr        = "10.10.14.0/24"
        az          = "eun1-az3"
        type        = "Devops"
        tags        = { "cost_center" = "1234" }
        nat_gateway = "DEFAULT"
      }

      "k8s1" = {
        name        = "private-k8s-1"
        cidr        = "10.10.15.0/24"
        az          = "eun1-az3"
        type        = "k8s"
        tags        = { "cost_center" = "1234" }
        nat_gateway = "SINGLE"
      }

      "k8s2" = {
        name = "private-k8s-2"
        cidr = "10.10.16.0/24"
        az   = "eun1-az3"
        type = "k8s"
        tags = { "cost_center" = "1234" }
      }
    }
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



## Contribution
If you want to be part of the project development team, get in touch with [us](https://github.com/ViktorUJ/cks/tree/master#contacts). We are always happy to welcome new members to our development team


If you want to say **thank you** or/and support the active development of **module** :
- [Star](https://github.com/ViktorUJ/terraform-aws-vpc) the **terraform-aws-vpc** on Github
- Feel free to write articles about the project on [dev.to](https://dev.to/), [medium](https://medium.com/), [hackernoon](https://hackernoon.com) or on your personal blog and share your experiences.


## License and Usage Agreement
- [Apache License 2.0](LICENSE)

## Contacts

If you encounter any issues or have questions about the project, you can reach out to:

[![email](https://badgen.net/badge/icon/email?icon=email&label)](mailto:viktoruj@gmail.com) [![Telegram](https://badgen.net/badge/icon/telegram?icon=telegram&label)](https://t.me/viktor_uj) [![LinkedI](https://badgen.net/badge/icon/linkedin?icon=linkedin&label)](https://www.linkedin.com/in/viktar-mikalayeu-mns)
