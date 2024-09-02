output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets_var" {
  value = module.vpc.subnets_var
}
output "subnets_pub_raw" {
  value = module.vpc.subnets_pub_raw
}
output "subnets_private_raw" {
  value = module.vpc.subnets_private_raw
}

output "subnets_by_az" {
  value = module.vpc.subnets_by_az
}

output "subnets_by_az_id" {
  value = module.vpc.subnets_by_az_id
}