variable "vpc" {
  type = object({
    name = string
    cidr = string
    secondary_cidr_blocks = optional(list(string), [])
    tags = optional(map(string), {})
    instance_tenancy = optional(string, "default") # default, dedicated
    enable_dns_support = optional(bool, true) # true, false
    enable_dns_hostnames = optional(bool, false) # true, false
    nacl_default=optional(type(map(object({
        egress          = string
        rule_number     = string
        rule_action     = string
        from_port       = string
        to_port         = string
        icmp_code       = string
        icmp_type       = string
        protocol        = string
        cidr_block      = string
        ipv6_cidr_block = string

    }))) , {})
  })

  # Validation for CIDR format
  validation {
    condition = can(cidrsubnet(var.vpc.cidr, 0, 0))
    error_message = "Invalid CIDR block format for VPC. CIDR block must be a valid subnet, e.g., 10.0.0.0/16."
  }
}

variable "tags_default" {
  type = map(string)
  default = {}
}


variable "subnets" {
  type = object({
    public=optional(map(object({
      name=string
      cidr=string
      az=string # Availability Zone or Availability Zone ID
      tags=optional(map(string), {})
      type=optional(string, "public") # any sort key for grouping . example , DB , WEB , APP , etc

      assign_ipv6_address_on_creation = optional(bool, false)
      customer_owned_ipv4_pool = optional(string, "")
      enable_dns64= optional(bool, false)
      enable_resource_name_dns_aaaa_record_on_launch= optional(bool, false)
      enable_resource_name_dns_a_record_on_launch= optional(bool, false)
      ipv6_cidr_block= optional(string, "")
      ipv6_native= optional(bool, false)
      map_customer_owned_ip_on_launch= optional(bool, false)
      map_public_ip_on_launch= optional(bool, true)
      outpost_arn= optional(string, "")
      private_dns_hostname_type_on_launch= optional(string, "ip-name") #  The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID . Valid values:  ip-name, resource-name.


    })))
   private=optional(map(object({
      name=string
      cidr=string
      az=string # Availability Zone or Availability Zone ID
      tags=optional(map(string), {})
      type=optional(string, "private") # any sort key for grouping . example , DB , WEB , APP , etc
      nat_gateway=optional(string, "AZ") # AZ - nat gateway for  each AZ , SINGLE - single nat gateway for all AZ , DEFAULT - default nat gateway for all AZ  with SINGLE value ,SUBNET - dedicate nat gateway for each  subnet with SUBNET  type   ,  NONE - no nat gateway
      assign_ipv6_address_on_creation = optional(bool, false)
      customer_owned_ipv4_pool = optional(string, "")
      enable_dns64= optional(bool, false)
      enable_resource_name_dns_aaaa_record_on_launch= optional(bool, false)
      enable_resource_name_dns_a_record_on_launch= optional(bool, false)
      ipv6_cidr_block= optional(string, "")
      ipv6_native= optional(bool, false)
      map_customer_owned_ip_on_launch= optional(bool, false)
      map_public_ip_on_launch= optional(bool, true)
      outpost_arn= optional(string, "")
      private_dns_hostname_type_on_launch= optional(string, "ip-name") #  The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID . Valid values:  ip-name, resource-name.

    })))
  })
  default = {
    public={}
    private={}
  }
  # Validation for nat_gateway field
  validation {
    condition = alltrue([
      for _, subnet in var.subnets.private : contains(["AZ", "SINGLE", "DEFAULT", "SUBNET", "NONE"], subnet.nat_gateway)
    ])
    error_message = "nat_gateway must be one of: AZ, SINGLE, DEFAULT, SUBNET, NONE."
  }

  # Validation for CIDR format in private subnets
  validation {
    condition = alltrue([
      for _, subnet in var.subnets.private : can(cidrsubnet(subnet.cidr, 0, 0))
    ])
    error_message = "Invalid CIDR block format. CIDR block must be a valid subnet, e.g., 10.10.16.0/24."
  }

  # Validation for CIDR format in public subnets
  validation {
    condition = alltrue([
      for _, subnet in var.subnets.public : can(cidrsubnet(subnet.cidr, 0, 0))
    ])
    error_message = "Invalid CIDR block format. CIDR block must be a valid subnet, e.g., 10.10.16.0/24."
  }

  # Validation for private_dns_hostname_type_on_launch field in private subnets
  validation {
    condition = alltrue([
      for _, subnet in var.subnets.private : contains(["ip-name", "resource-name"], subnet.private_dns_hostname_type_on_launch)
    ])
    error_message = "Invalid value for private_dns_hostname_type_on_launch. Must be one of: ip-name, resource-name."
  }

  # Validation for private_dns_hostname_type_on_launch field in public subnets
  validation {
    condition = alltrue([
      for _, subnet in var.subnets.public : contains(["ip-name", "resource-name"], subnet.private_dns_hostname_type_on_launch)
    ])
    error_message = "Invalid value for private_dns_hostname_type_on_launch. Must be one of: ip-name, resource-name."
  }

}


