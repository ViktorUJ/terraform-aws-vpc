output "vpc_id" {
  value = module.vpc.vpc_raw.id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_raw.cidr_block
}


output "private_subnets_by_type" {
  value = module.vpc.private_subnets_by_type
}
output "public_subnets_by_type" {
  value = module.vpc.public_subnets_by_type
}
