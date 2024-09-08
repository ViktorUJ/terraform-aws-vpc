# inputs
output "tags_default" {
  description = "Default tags"
  value       = var.tags_default
}

output "subnets_var" {
  description = "for test"
  value       = var.subnets
}

# debug
output "subnets_pub_raw" {
  value = try(aws_subnet.public, null)
}

output "az_mapping" {
  value = local.az_mapping
}


output "subnets_private_raw" {
  value = try(  aws_subnet.private, null)
}

# vpc
output "vpc_raw" {
  value = try(aws_vpc.default, null)
}


# private sublets

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

output "public_subnets_by_type" {
  value = local.public_subnets_by_type
}

output "normalized_private_subnets_AZ" {
  value = local.normalized_private_subnets_AZ
}
