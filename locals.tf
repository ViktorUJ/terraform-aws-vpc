locals {
  az_mapping = {
    for idx, az in data.aws_availability_zones.available.names : az =>
    data.aws_availability_zones.available.zone_ids[idx]
  }

  az_id_to_az = {for az, az_id in local.az_mapping : az_id => az}

  normalized_private_subnets_all = {
    for k, v in var.subnets.private : k => merge(v, {
      az = lookup(local.az_id_to_az, v.az, v.az)  # Преобразуем AZ ID в AZ, если это необходимо
    })
  }



}