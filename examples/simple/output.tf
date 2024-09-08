# inputs
output "tags_default" {
  description = "Default tags"
  value       = module.vpc.tags_default
}

output "subnets_var" {
  description = "for test"
  value       = module.vpc.subnets_var
}
output "vpc_var" {
  value = module.vpc.vpc_var
}

# vpc
output "vpc_raw" {
  value = module.vpc.vpc_raw
}



# debug
output "az_mapping" {
  value = module.vpc.az_mapping
}


#subnets public

output "normalized_public_subnets_all" {
  value = module.vpc.normalized_public_subnets_all
}

output "subnets_public_raw" {
  value = module.vpc.subnets_public_raw
}
output "public_subnets_by_type" {
  value = module.vpc.public_subnets_by_type
}

output "public_subnets_by_az" {
  value = module.vpc.public_subnets_by_az
}

output "public_subnets_by_az_id" {
  value = module.vpc.public_subnets_by_az_id
}
#subnets private
output "normalized_private_subnets_all" {
  value = module.vpc.normalized_private_subnets_all
}

output "subnets_private_raw" {
  value = module.vpc.subnets_private_raw
}

output "private_subnets_by_type" {
  value = module.vpc.private_subnets_by_type
}

output "private_subnets_by_az" {
  value = module.vpc.private_subnets_by_az
}

output "private_subnets_by_az_id" {
  value = module.vpc.private_subnets_by_az_id
}

# NACL
output "public_nacl_raw" {
  value = module.vpc.public_nacl_raw

}
output "public_nacl_rules_raw" {
  value = module.vpc.public_nacl_rules_raw
}

output "private_nacl_raw" {
    value = module.vpc.private_nacl_raw
}
output "private_nacl_rules_raw" {
  value = module.vpc.private_nacl_rules_raw
}

# NAT Gateway

output "nat_gateway_single_raw" {
  value = module.vpc.nat_gateway_single_raw
}

output "nat_gateway_subnet_raw" {
  value = module.vpc.nat_gateway_subnet_raw
}

output "nat_gateway_az_raw" {
  value = module.vpc.nat_gateway_az_raw
}

# Route Table
output "route_table_private_raw" {
  value = module.vpc.route_table_private_raw
}

output "route_table_public_raw" {
  value = module.vpc.route_table_public_raw
}


# EXAMPLES

output "vpc_id" {
  value = module.vpc.vpc_raw.id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_raw.cidr_block
}



/*
output "vpc_id" {
  value = module.vpc.vpc_raw.id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_raw.cidr_block
}

output "vpc_raw" {
  value = module.vpc.vpc_raw
}


output "subnets_var" {
  value = module.vpc.subnets_var
}
output "subnets_public_raw" {
  value = module.vpc.subnets_public_raw
}
output "az_mapping" {
  value = module.vpc.az_mapping
}
output "normalized_subnet" {
  value = module.vpc.normalized_private_subnets_all
}


output "private_subnets_by_type" {
  value = module.vpc.private_subnets_by_type
}

output "private_subnets_by_az" {
  value = module.vpc.private_subnets_by_az
}
output "private_subnets_by_az_id" {
  value = module.vpc.private_subnets_by_az_id
}


output "public_subnets_by_type" {
  value = module.vpc.public_subnets_by_type
}

output "public_subnets_by_az" {
  value = module.vpc.public_subnets_by_az
}
output "public_nacl_rules" {
  value = module.vpc.public_nacl_rules
}

*/