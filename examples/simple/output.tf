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
  value = module.vpc.normalized_private_subnets_AZ
}


output "normalized_private_subnets_SUBNET" {
  value = module.vpc.normalized_private_subnets_SUBNET
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

