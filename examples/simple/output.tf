output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets_var" {
  value = module.vpc.subnets_var
}
output "subnets_pub_raw" {
  value = module.vpc.subnets_pub_raw
}