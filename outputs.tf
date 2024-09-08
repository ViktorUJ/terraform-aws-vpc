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

output "public__subnets_by_az" {
  value = local.public_subnets_by_az_output
}

output "public__subnets_by_az_id" {
  value = local.public_subnets_by_az_id
}
#subnets private
output "normalized_private_subnets_AZ" {
  value = local.normalized_private_subnets_AZ
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

# public sublets





# Output for public NACL rules
output "public_nacl_rules" {
  value = local.public_nacl_rules
}