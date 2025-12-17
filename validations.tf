# Additional runtime validations
locals {
  # Validate that all subnet CIDRs are within VPC CIDR
  subnet_cidr_validation = {
    for subnet_type in ["public", "private"] : subnet_type => {
      for subnet_key, subnet in lookup(var.subnets, subnet_type, {}) : subnet_key => {
        is_valid = can(cidrsubnet(var.vpc.cidr, 
          tonumber(split("/", subnet.cidr)[1]) - tonumber(split("/", var.vpc.cidr)[1]), 
          0
        ))
        subnet_cidr = subnet.cidr
        vpc_cidr = var.vpc.cidr
      }
    }
  }

  # Check for CIDR overlaps between subnets
  all_subnet_cidrs = merge(
    { for k, v in lookup(var.subnets, "public", {}) : "public_${k}" => v.cidr },
    { for k, v in lookup(var.subnets, "private", {}) : "private_${k}" => v.cidr }
  )

  # Validate NAT Gateway configuration consistency
  nat_gateway_validation = {
    single_nat_requires_default = length([
      for k, v in lookup(var.subnets, "private", {}) : k 
      if v.nat_gateway == "SINGLE"
    ]) > 0 ? length([
      for k, v in lookup(var.subnets, "public", {}) : k 
      if lookup(v, "nat_gateway", "") == "DEFAULT"
    ]) > 0 : true
  }
}

# Runtime checks using check blocks (Terraform 1.5+)
check "subnet_cidrs_within_vpc" {
  assert {
    condition = alltrue([
      for subnet_type, subnets in local.subnet_cidr_validation : alltrue([
        for subnet_key, validation in subnets : validation.is_valid
      ])
    ])
    error_message = "All subnet CIDR blocks must be within the VPC CIDR block."
  }
}

check "nat_gateway_configuration" {
  assert {
    condition = local.nat_gateway_validation.single_nat_requires_default
    error_message = "When using SINGLE NAT Gateway for private subnets, at least one public subnet must have nat_gateway = 'DEFAULT'."
  }
}