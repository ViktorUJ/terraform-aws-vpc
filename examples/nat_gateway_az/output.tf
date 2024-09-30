output "nat_gateway_az_raw" {
  value = module.vpc.nat_gateway_az_raw
}

output "public_subnets_by_az" {
  value = module.vpc.public_subnets_by_az
}