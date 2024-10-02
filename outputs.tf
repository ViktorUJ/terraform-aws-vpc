# inputs
output "tags_default" {
  description = "Default tags"
  value       = var.tags_default
}

output "subnets_var" {
  description = "for test"
  value       = var.subnets
}
output "vpc_var" {
  value = var.vpc
}

# vpc
output "vpc_raw" {
  value = try(aws_vpc.default, null)
}


# debug
output "az_mapping" {
  value = local.az_mapping
}


#subnets public

output "normalized_public_subnets_all" {
  value = local.normalized_public_subnets_all
}

output "subnets_public_raw" {
  value = try(aws_subnet.public, null)
}
output "public_subnets_by_type" {
  value = local.public_subnets_by_type
}

output "public_subnets_by_az" {
  value = local.public_subnets_by_az_output
}

output "public_subnets_by_az_id" {
  value = local.public_subnets_by_az_id
}
#subnets private
output "normalized_private_subnets_all" {
  value = local.normalized_private_subnets_all
}

output "subnets_private_raw" {
  value = try(aws_subnet.private, null)
}

output "private_subnets_by_type" {
  value = local.private_subnets_by_type
}

output "private_subnets_by_az" {
  value = local.private_subnets_by_az_output
}

output "private_subnets_by_az_id" {
  value = local.private_subnets_by_az_id
}

# NACL
output "nacl_default_rules_raw" {
  value = aws_network_acl_rule.default
}
output "public_nacl_raw" {
  value = try(aws_network_acl.public, null)

}
output "public_nacl_rules_raw" {
  value = aws_network_acl_rule.public_rules
}


output "private_nacl_raw" {
  value = try(aws_network_acl.private, null)
}
output "private_nacl_rules_raw" {
  value = aws_network_acl_rule.private_rules
}

# NAT Gateway

output "nat_gateway_single_raw" {
  value = try(aws_nat_gateway.SINGLE_nat_gateway, null)
}


output "nat_gateway_subnet_raw" {
  value = try(aws_nat_gateway.SUBNET_nat_gateway, null)
}

output "nat_gateway_az_raw" {
  value = try(aws_nat_gateway.az_nat_gateway, null)
}

# Route Table
output "route_table_private_raw" {
  value = try(aws_route_table.private, null)
}

output "route_table_public_raw" {
  value = try(aws_route_table.public, null)
}


