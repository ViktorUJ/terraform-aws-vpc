output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets_var" {
  value = module.vpc.subnets_var
}
output "subnets_pub_raw" {
  value = module.vpc.subnets_pub_raw
}
output "az_mapping" {
  value = module.vpc.az_mapping
}
output "normalized_subnet" {
  value = module.vpc.normalized_subnets
}

/*
output "subnets_private_raw" {
  value = module.vpc.subnets_private_raw
}

output "subnets_by_az" {
  value = module.vpc.subnets_by_az
}

output "all_subnet_ids" {
  value = module.vpc.all_subnet_ids
}

output "routes_map" {
  value = module.vpc.routes_map
}

 */