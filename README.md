# Terraform AWS VPC Module
<p align="center">
    <a href="https://github.com/ViktorUJ/cks"><img src="img/logo_192x192.png" width="192" height="192" alt="SRE Learning Platform"/></a>
</p>

##  Overview

This Terraform module creates an Amazon Virtual Private Cloud (VPC) with both public and private subnets, route tables, Network ACLs (NACLs), and NAT Gateways. It provides an extensible and customizable setup for scalable networking in AWS.

##  Features

- Creates a VPC with the specified CIDR blocks.
- Supports public and private subnets across multiple availability zones or availability zones ID .
- Configures Network ACLs with customizable rules.
- Adds NAT Gateways for secure outbound internet traffic from private subnets.
- Custom DHCP options and default network ACL configurations.
- Support for tagging resources (VPC, subnets, etc.).




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
| **`subnets.public.az`**                 | `string`        | Yes      | N/A                          | Availability Zone for the public subnet.                        |
| **`subnets.public.cidr`**               | `string`        | Yes      | N/A                          | The CIDR block for the public subnet.                           |
| **`subnets.public.type`**               | `string`        | No       | N/A                          | A custom type label for the public subnet (e.g., `web`, `app`). |
| **`subnets.public.tags`**               | `map(string)`   | No       | `{}`                         | Tags to assign to the public subnet.                            |
| **`subnets.public.route_table_id`**     | `string`        | No       | `""`                         | (Optional) Route table ID to associate with the public subnet.  |
| **`subnets.public.private_dns_hostname_type_on_launch`** | `string` | No       | `ip-name`                    | Type of DNS hostname to assign on launch for public subnet.     |

#### Private Subnets

| Variable                                                  | Type            | Required | Default                      | Description                                                                                         |
|-----------------------------------------------------------|-----------------|----------|------------------------------|-----------------------------------------------------------------------------------------------------|
| **`subnets.private`**                                     | `map(object)`   | No       | N/A                          | Private subnets                                                  |
| **`subnets.private.az`**                                  | `string`        | Yes      | N/A                          | Availability Zone for the private subnet.                                                            |
| **`subnets.private.cidr`**                                | `string`        | Yes      | N/A                          | The CIDR block for the private subnet.                                                               |
| **`subnets.private.type`**                                | `string`        | No       | N/A                          | A custom type label for the private subnet (e.g., `app`, `db`).                                      |
| **`subnets.private.tags`**                                | `map(string)`   | No       | `{}`                         | Tags to assign to the private subnet.                                                                |
| **`subnets.private.route_table_id`**                      | `string`        | No       | `""`                         | (Optional) Route table ID to associate with the private subnet.                                       |
| **`subnets.private.private_dns_hostname_type_on_launch`** | `string` | No       | `resource-name`              | Type of DNS hostname to assign on launch for private subnet.                                          |

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
