output "nat_gateway_az_raw" {
  value = module.vpc.nat_gateway_az_raw
}

module "public_subnets_by_az" {
  source = module.vpc.public_subnets_by_az
}