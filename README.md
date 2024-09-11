# Terraform AWS VPC Module
<p align="center">
    <a href="https://github.com/ViktorUJ/cks"><img src="img/logo_192x192.png" width="192" height="192" alt="SRE Learning Platform"/></a>
</p>

##  Overview

This Terraform module creates an Amazon Virtual Private Cloud (VPC) with both public and private subnets, route tables, Network ACLs (NACLs), and NAT Gateways. It provides an extensible and customizable setup for scalable networking in AWS.

##  Features
- **Creation of a VPC** with specified CIDR blocks, tags, and NACL settings.
- **Dynamic creation of public and private subnets** with automatic retrieval of their IDs.
- **Subnet creation** with the ability to assign them to specific Availability Zones (AZ) or AZ IDs.
- **Independent tagging** for each subnet, allowing for individual resource labeling.
- **Flexible network management**: ability to add new subnets or remove existing ones without impacting other subnets.
- Support for **three NAT Gateway scenarios** (by default, **AZ NAT Gateway** is used):
  - **AZ**: One NAT Gateway is created for each AZ specified in private subnets.
  - **SINGLE**: One NAT Gateway is created for the entire VPC.
  - **SUBNET**: One NAT Gateway per subnet.
  - **NONE**: No NAT Gateway is created for the subnet, and no routes for 0.0.0.0/0 are configured.
  - Each subnet can be configured with any NAT Gateway type, and all types can coexist within a single VPC.
- **Custom DHCP options** to fine-tune network configurations.
- **Output** of all created resources, including subnet IDs grouped by type, AZ, and AZ ID.




Table Of Contents
-----------------

* [Quick Start](#quick-start)
* [Input Variables](#Input-Variables)
  * [VPC](#VPC)
  * [Subnets](#Subnets)
    * [Public Subnets](#Public-Subnets)
    * [Private Subnets](#Private-Subnets)
  * [Other](#Other)
* [Output](#Output)
* [Examples](#Examples)
* [Contribution](#contribution)
* [License and Usage Agreement](#license-and-usage-agreement)
* [Contacts](#contacts)



## Quick Start

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
    name          = "test-vpc"
    cidr          = "10.10.0.0/16"
  }

  subnets = {
    public = {
      "pub1" = {
        name   = "public-subnet-1"
        cidr   = "10.10.1.0/24"
        az     = "eu-north-1c"
      }
      "pub2" = {
        name   = "public-subnet-2"
        cidr   = "10.10.2.0/24"
        az     = "eu-north-1a"
    }

    }
    private = {

     "private1" = {
       name        = "private-subnet-1"
       cidr        = "10.10.11.0/24"
       az          = "eu-north-1a"
       tags        = { "cost_center" = "1234" }

     }
     "private2" = {
       name        = "private-subnet-2"
       cidr        = "10.10.12.0/24"
       az          = "eu-north-1c"
       tags        = { "cost_center" = "5678" }    
     }
    }
  }
}

output "vpc_id" {
  value = module.vpc.vpc_raw.id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_raw.cidr_block
}


output "private_subnets_by_type" {
  value = module.vpc.private_subnets_by_type
}
output "public_subnets_by_type" {
  value = module.vpc.public_subnets_by_type
}
```

##  Input Variables

### VPC

| Variable                                   | Type            | Required | Default                      | Description                                                                                         |
|--------------------------------------------|-----------------|----------|------------------------------|-----------------------------------------------------------------------------------------------------|
| **`vpc.name`**                             | `string`        | Yes      | N/A                          | The name of the VPC.                                                                                 |
| **`vpc.cidr`**                             | `string`        | Yes      | N/A                          | The CIDR block for the VPC.                                                                          |
| **`vpc.secondary_cidr_blocks`**            | `list(string)`  | No       | `[]`                         | Additional CIDR blocks to associate with the VPC.                                                    |
| **`vpc.tags`**                             | `map(string)`   | No       | `{}`                         | Tags to assign to the VPC.                                                                           |
| **`vpc.instance_tenancy`**                 | `string`        | No       | `default`                    | Instance tenancy option for instances in the VPC. Options: `default`, `dedicated`.                   |
| **`vpc.enable_dns_support`**               | `bool`          | No       | `true`                       | Enable DNS support in the VPC.                                                                       |
| **`vpc.enable_dns_hostnames`**             | `bool`          | No       | `false`                      | Enable DNS hostnames in the VPC.                                                                     |
| **`vpc.nacl_default`**                     | `map(object)`   | No       | `{}`                         | Default NACL rules for the VPC.                                                                      |
| **`vpc.dhcp_options`**                     | `object`        | No       | `{}`                         | DHCP options set for the VPC.                                                                        |

### Subnets

#### Public Subnets

| Variable                                | Type            | Required | Default                      | Description                                                     |
|-----------------------------------------|-----------------|----------|------------------------------|-----------------------------------------------------------------|
| **`subnets.public`**                    | `map(object)`   | No       | N/A                          | Public subnets                                                  |
| **`subnets.public.name`**               | `string`        | Yes      | N/A                          | Name of the public subnet.                                      |
| **`subnets.public.cidr`**               | `string`        | Yes      | N/A                          | The CIDR block for the public subnet.                           |
| **`subnets.public.az`**                 | `string`        | Yes      | N/A                          | Availability Zone or Availability Zone ID for the public subnet. |
| **`subnets.public.tags`**               | `map(string)`   | No       | `{}`                         | Tags to assign to the public subnet.                            |
| **`subnets.public.type`**               | `string`        | No       | `"public"`                   | A custom type label for the public subnet (e.g., `web`, `app`). |
| **`subnets.public.assign_ipv6_address_on_creation`** | `bool`   | No       | `false`                      | Assign IPv6 addresses on creation.                              |
| **`subnets.public.customer_owned_ipv4_pool`** | `string`    | No       | `""`                         | ID of the customer-owned IPv4 address pool to use for the subnet. |
| **`subnets.public.enable_dns64`**       | `bool`          | No       | `false`                      | Enable DNS64 for NAT64 in the public subnet.                    |
| **`subnets.public.enable_resource_name_dns_aaaa_record_on_launch`** | `bool` | No       | `false`                      | Enable DNS AAAA records for resources in the public subnet.      |
| **`subnets.public.enable_resource_name_dns_a_record_on_launch`** | `bool` | No       | `false`                      | Enable DNS A records for resources in the public subnet.         |
| **`subnets.public.ipv6_cidr_block`**    | `string`        | No       | `""`                         | The IPv6 CIDR block for the public subnet.                      |
| **`subnets.public.ipv6_native`**        | `bool`          | No       | `false`                      | Enable native IPv6 addressing.                                  |
| **`subnets.public.map_customer_owned_ip_on_launch`** | `bool`   | No       | `false`                      | Map customer-owned IP addresses on launch.                      |
| **`subnets.public.map_public_ip_on_launch`** | `bool`       | No       | `true`                       | Map public IP addresses on launch.                              |
| **`subnets.public.outpost_arn`**        | `string`        | No       | `""`                         | ARN of the Outpost for the public subnet.                       |
| **`subnets.public.private_dns_hostname_type_on_launch`** | `string` | No       | `ip-name`                    | The type of DNS hostnames to assign on launch.                  |
| **`subnets.public.nacl`**               | `map(object)`   | No       | `{}`                         | Network ACL (NACL) configuration for the public subnet.          |
| **`subnets.public.nacl.egress`**        | `string`        | No       | N/A                          | Egress rule for NACL (allow or deny).                           |
| **`subnets.public.nacl.rule_number`**   | `string`        | No       | N/A                          | Rule number for the NACL entry.                                 |
| **`subnets.public.nacl.rule_action`**   | `string`        | No       | N/A                          | Rule action for the NACL entry (allow or deny).                 |
| **`subnets.public.nacl.from_port`**     | `string`        | No       | `""`                         | From port for NACL rule (if applicable).                        |
| **`subnets.public.nacl.to_port`**       | `string`        | No       | `""`                         | To port for NACL rule (if applicable).                          |
| **`subnets.public.nacl.icmp_code`**     | `string`        | No       | `""`                         | ICMP code for NACL rule (if applicable).                        |
| **`subnets.public.nacl.icmp_type`**     | `string`        | No       | `""`                         | ICMP type for NACL rule (if applicable).                        |
| **`subnets.public.nacl.protocol`**      | `string`        | Yes      | N/A                          | Protocol for the NACL rule (e.g., TCP, UDP, ICMP, or `-1` for all). |
| **`subnets.public.nacl.cidr_block`**    | `string`        | No       | `""`                         | CIDR block for the NACL rule (if applicable).                   |
| **`subnets.public.nacl.ipv6_cidr_block`** | `string`      | No       | `""`                         | IPv6 CIDR block for the NACL rule (if applicable).              |

#### Private Subnets

| Variable                                                  | Type            | Required | Default                      | Description                                                                                         |
|-----------------------------------------------------------|-----------------|----------|------------------------------|-----------------------------------------------------------------------------------------------------|
| **`subnets.private`**                                     | `map(object)`   | No       | N/A                          | Private subnets.                                                                                     |
| **`subnets.private.name`**                                | `string`        | Yes      | N/A                          | Name of the private subnet.                                                                          |
| **`subnets.private.cidr`**                                | `string`        | Yes      | N/A                          | The CIDR block for the private subnet.                                                               |
| **`subnets.private.az`**                                  | `string`        | Yes      | N/A                          | Availability Zone or Availability Zone ID for the private subnet.                                    |
| **`subnets.private.tags`**                                | `map(string)`   | No       | `{}`                         | Tags to assign to the private subnet.                                                                |
| **`subnets.private.type`**                                | `string`        | No       | `"private"`                  | A custom type label for the private subnet (e.g., `app`, `db`).                                      |
| **`subnets.private.nat_gateway`**                         | `string`        | No       | `"AZ"`                       | NAT Gateway configuration: AZ, SINGLE, SUBNET, DEFAULT, or NONE.                                    |
| **`subnets.private.assign_ipv6_address_on_creation`**      | `bool`          | No       | `false`                      | Assign IPv6 addresses on creation.                                                                   |
| **`subnets.private.customer_owned_ipv4_pool`**            | `string`        | No       | `""`                         | ID of the customer-owned IPv4 address pool to use for the subnet.                                    |
| **`subnets.private.enable_dns64`**                        | `bool`          | No       | `false`                      | Enable DNS64 for NAT64 in the private subnet.                                                        |
| **`subnets.private.enable_resource_name_dns_aaaa_record_on_launch`** | `bool` | No  | `false`                      | Enable DNS AAAA records for resources in the private subnet.                                         |
| **`subnets.private.enable_resource_name_dns_a_record_on_launch`**    | `bool` | No  | `false`                      | Enable DNS A records for resources in the private subnet.                                            |
| **`subnets.private.ipv6_cidr_block`**                     | `string`        | No       | `""`                         | The IPv6 CIDR block for the private subnet.                                                          |
| **`subnets.private.ipv6_native`**                         | `bool`          | No       | `false`                      | Enable native IPv6 addressing.                                                                       |
| **`subnets.private.map_customer_owned_ip_on_launch`**     | `bool`          | No       | `false`                      | Map customer-owned IP addresses on launch.                                                           |
| **`subnets.private.map_public_ip_on_launch`**             | `bool`          | No       | `true`                       | Map public IP addresses on launch.                                                                   |
| **`subnets.private.outpost_arn`**                         | `string`        | No       | `""`                         | ARN of the Outpost for the private subnet.                                                           |
| **`subnets.private.private_dns_hostname_type_on_launch`** | `string`        | No       | `"ip-name"`                  | The type of DNS hostnames to assign on launch for the private subnet.                                |
| **`subnets.private.nacl`**                                | `map(object)`   | No       | `{}`                         | Network ACL (NACL) configuration for the private subnet.                                             |
| **`subnets.private.nacl.egress`**                         | `string`        | No       | N/A                          | Egress rule for NACL (allow or deny).                                                                |
| **`subnets.private.nacl.rule_number`**                    | `string`        | No       | N/A                          | Rule number for the NACL entry.                                                                      |
| **`subnets.private.nacl.rule_action`**                    | `string`        | No       | N/A                          | Rule action for the NACL entry (allow or deny).                                                      |
| **`subnets.private.nacl.from_port`**                      | `string`        | No       | `""`                         | From port for NACL rule (if applicable).                                                             |
| **`subnets.private.nacl.to_port`**                        | `string`        | No       | `""`                         | To port for NACL rule (if applicable).                                                               |
| **`subnets.private.nacl.icmp_code`**                      | `string`        | No       | `""`                         | ICMP code for NACL rule (if applicable).                                                             |
| **`subnets.private.nacl.icmp_type`**                      | `string`        | No       | `""`                         | ICMP type for NACL rule (if applicable).                                                             |
| **`subnets.private.nacl.protocol`**                       | `string`        | Yes      | N/A                          | Protocol for the NACL rule (e.g., TCP, UDP, ICMP, or `-1` for all protocols).                        |
| **`subnets.private.nacl.cidr_block`**                     | `string`        | No       | `""`                         | CIDR block for the NACL rule (if applicable).                                                        |
| **`subnets.private.nacl.ipv6_cidr_block`**                | `string`        | No       | `""`                         | IPv6 CIDR block for the NACL rule (if applicable).                                                   |

### Other

| Variable                                   | Type            | Required | Default                      | Description                                                                                         |
|--------------------------------------------|-----------------|----------|------------------------------|-----------------------------------------------------------------------------------------------------|
| **`tags_default`**                         | `map(string)`   | No       | `{}`                         | (Optional) Default tags to assign across all resources created by the module.                         |

## Output

| Variable                                   | Type            | Description                                                                            |
|--------------------------------------------|-----------------|----------------------------------------------------------------------------------------|
| **`vpc_var`**                              | `object`        | The input VPC object.                                                                  |
| **`vpc_raw`**                              | `object`        | The AWS VPC resource.                                                                  |
| **`normalized_public_subnets_all`**        | `list(string)`  | Normalized list of all public subnets.                                                 |
| **`public_subnets_by_type`**               | `map(string)`   | Public subnets grouped by type.                                                        |
| **`public_subnets_by_az`**                 | `map(string)`   | Public subnets grouped by Availability Zone.                                           |
| **`normalized_private_subnets_all`**       | `list(string)`  | Normalized list of all private subnets.                                                |
| **`private_subnets_by_type`**              | `map(string)`   | Private subnets grouped by type.                                                       |
| **`private_subnets_by_az`**                | `map(string)`   | Private subnets grouped by Availability Zone.                                          |
| **`nat_gateway_single_raw`**               | `object`        | The NAT gateway for a single subnet.                                                   |
| **`nat_gateway_subnet_raw`**               | `object`        | The NAT gateway for each subnet.                                                       |
| **`nat_gateway_az_raw`**                   | `object`        | The NAT gateway for each Availability Zone.                                            |
| **`nacl_default_rules_raw`**               | `object`        | Default NACL rules.                                                                    |
| **`public_nacl_raw`**                      | `object`        | Public Network ACL resource.                                                           |
| **`public_nacl_rules_raw`**                | `object`        | Rules for the public Network ACL.                                                      |
| **`private_nacl_raw`**                     | `object`        | Private Network ACL resource.                                                          |
| **`private_nacl_rules_raw`**               | `object`        | Rules for the private Network ACL.                                                     |
| **`route_table_private_raw`**              | `object`        | Private route table.                                                                   |
| **`route_table_public_raw`**               | `object`        | Public route table.                                                                    |

##  Examples

You can find additional examples in the [examples](./examples) directory:

- **Simple VPC setup**: [examples/simple](./examples/simple)
- **Advanced VPC setup**: [examples/advanced](./examples/advanced)


## Contribution
If you want to be part of the project development team, get in touch with [us](#contacts). We are always happy to welcome new members to our development team


If you want to say **thank you** or/and support the active development of **module** :
- [Star](https://github.com/ViktorUJ/terraform-aws-vpc) the **terraform-aws-vpc** on Github
- Feel free to write articles about the project on [dev.to](https://dev.to/), [medium](https://medium.com/), [hackernoon](https://hackernoon.com) or on your personal blog and share your experiences.


## License and Usage Agreement
- [Apache License 2.0](LICENSE)

## Contacts

If you encounter any issues or have questions about the project, you can reach out to:

[![email](https://badgen.net/badge/icon/email?icon=email&label)](mailto:viktoruj@gmail.com) [![Telegram](https://badgen.net/badge/icon/telegram?icon=telegram&label)](https://t.me/viktor_uj) [![LinkedI](https://badgen.net/badge/icon/linkedin?icon=linkedin&label)](https://www.linkedin.com/in/viktar-mikalayeu-mns)
