#output "public_subnets_by_az_output" {
#  value = module.vpc.nat_gateway_subnet_raw
#}
#
output "public_subnets_by_az_output" {
  value = module.vpc.local_public_subnets_by_az_output
}

output "normalized_private_subnets_SUBNET" {
  value = module.vpc.normalized_private_subnets_SUBNET
}