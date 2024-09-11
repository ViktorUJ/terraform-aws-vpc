output "vpc_raw" {
  value = module.vpc.vpc_raw
}

output "nacl_default_rules_raw" {
  value = module.vpc.nacl_default_rules_raw
}
