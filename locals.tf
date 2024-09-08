locals {
  az_mapping = {
    for idx, az in data.aws_availability_zones.available.names : az =>
    data.aws_availability_zones.available.zone_ids[idx]
  }

  az_id_to_az = { for az, az_id in local.az_mapping : az_id => az }

  normalized_private_subnets_all = {
    for k, v in var.subnets.private : k => merge(v, {
      az = lookup(local.az_id_to_az, v.az, v.az) # Преобразуем AZ ID в AZ, если это необходимо
    })
  }

  # group by type and create a list of identifiers
  private_subnet_by_type = {
    for type in distinct([for k, v in local.normalized_private_subnets_all : v.type]) : type => {
      ids  = [for k, v in local.normalized_private_subnets_all : aws_subnet.private[k].id if v.type == type]
      keys = [for k, v in local.normalized_private_subnets_all : k if v.type == type]
    }
  }

    public_subnet_by_type = {
    for type in distinct([for k, v in var.subnets.public : v.type]) : type => {
      ids  = [for k, v in var.subnets.public : aws_subnet.public[k].id if v.type == type]
      keys = [for k, v in var.subnets.public : k if v.type == type]
    }
  }

  private_subnet_by_az = {
    for az in distinct([for subnet in local.normalized_private_subnets : subnet.az]) : az => [
      for subnet_key, subnet in local.normalized_private_subnets : aws_subnet.private[subnet_key].id
      if subnet.az == az
    ]
  }
}
