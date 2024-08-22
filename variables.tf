variable "vpc" {
  type = object({
    name = string
    cidr = string
    secondary_cidr_blocks = optional(list(string), [])
    tags = optional(map(string), {})
    instance_tenancy = optional(string, "default") # default, dedicated
    enable_dns_support = optional(bool, true) # true, false
    enable_dns_hostnames = optional(bool, false) # true, false
  })
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
      private_dns_hostname_type_on_launch= optional(string, "")


    })))
   private=optional(map(object({
      name=string
      cidr=string
      az=string # Availability Zone or Availability Zone ID
      tags=optional(map(string), {})
      type=optional(string, "private") # any sort key for grouping . example , DB , WEB , APP , etc
    })))
  })
  default = {
    public={}
    private={}
  }
}


