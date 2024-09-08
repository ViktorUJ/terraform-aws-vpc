output "tags_default" {
  description = "Default tags"
  value       = var.tags_default
}

output "subnets_var" {
  description = "for test"
  value       = var.subnets
}

output "subnets_pub_raw" {
  value = try(aws_subnet.public, null)
}

output "az_mapping" {
  value = local.az_mapping
}


output "subnets_private_raw" {
  value = try(  aws_subnet.private, null)
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.default.id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.default.arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.default.cidr_block, null)
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = try(aws_vpc.default.default_security_group_id, null)
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = try(aws_vpc.default.default_network_acl_id, null)
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = try(aws_vpc.default.default_route_table_id, null)
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = try(aws_vpc.default.instance_tenancy, null)
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = try(aws_vpc.default.enable_dns_support, null)
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = try(aws_vpc.default.enable_dns_hostnames, null)
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = try(aws_vpc.default.main_route_table_id, null)
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = try(aws_vpc.default.ipv6_association_id, null)
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = try(aws_vpc.default.ipv6_cidr_block, null)
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = var.vpc.secondary_cidr_blocks
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = try(aws_vpc.default.owner_id, null)
}

# private sublets


output "private_subnets_by_az" {
  value = local.private_subnets_by_az
}

output "private_subnets_by_az_id" {
  value = local.private_subnets_by_az_id
}
# public sublets

output "public_subnet_by_type" {
  value = local.public_subnets_by_type
}

output "normalized_private_subnets_AZ" {
  value = local.normalized_private_subnets_AZ
}
