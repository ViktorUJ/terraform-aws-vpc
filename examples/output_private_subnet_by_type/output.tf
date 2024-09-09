output "private_subnets_by_type" {
  value = module.vpc.private_subnets_by_type
}

output "k8s_subnets_id" {
  value = module.vpc.private_subnets_by_type.k8s.ids
}