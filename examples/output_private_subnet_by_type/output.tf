output "private_subnets_by_type" {
  value = module.vpc.private_subnets_by_type
}

output "k8s_subnets_id" {
  value = module.vpc.private_subnets_by_type.k8s.ids
}

output "rds_subnets_id" {
  value = module.vpc.private_subnets_by_type.rds.ids
}

output "app_subnets_id" {
  value = module.vpc.private_subnets_by_type.app.ids
}