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

/*
variable "subnets" {
  type = object({
    public=optional(map(object({
      name=string
      cidr=string
      az=string # Availability Zone or Availability Zone ID
      tags=optional(map(string), {})
      type=optional(string, "public") # any sort key for grouping . example , DB , WEB , APP , etc
    })))
   private=optional(map(object({
      name=string
      cidr=string
      az=string # Availability Zone or Availability Zone ID
      tags=optional(map(string), {})
      type=optional(string, "private") # any sort key for grouping . example , DB , WEB , APP , etc
    })))
  })
}

*/
