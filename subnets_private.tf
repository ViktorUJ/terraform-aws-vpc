
data "aws_availability_zones" "available" {}

locals {
  az_mapping = {
    for idx, az in data.aws_availability_zones.available.names : az =>
    data.aws_availability_zones.available.zone_ids[idx]
  }

  az_id_to_az = {for az, az_id in local.az_mapping : az_id => az}

  normalized_private_subnets = {
    for k, v in var.subnets.private : k => merge(v, {
      az = lookup(local.az_id_to_az, v.az, v.az)  # Преобразуем AZ ID в AZ, если это необходимо
    })
  }


  private_subnets_by_az = {
    for az in distinct([for s in local.normalized_private_subnets : s.az]) :
    az => {
      ids  = [for k, s in local.normalized_private_subnets : aws_subnet.private[k].id if s.az == az]
      keys = [for k, s in local.normalized_private_subnets : k if s.az == az]
    }
  }

}


 output "az_mapping" {
   value = local.az_mapping
 }

output "normalized_private_subnets" {
  value = local.normalized_private_subnets
}

output "private_subnets_by_az" {
  value = local.private_subnets_by_az
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.default.id
  for_each                = local.normalized_private_subnets
  map_public_ip_on_launch = "false"
  cidr_block              = each.value.cidr

#  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
#  customer_owned_ipv4_pool = each.value.customer_owned_ipv4_pool != "" ? each.value.customer_owned_ipv4_pool : null
#  enable_dns64= each.value.enable_dns64
#  enable_resource_name_dns_aaaa_record_on_launch= each.value.enable_resource_name_dns_aaaa_record_on_launch
#  enable_resource_name_dns_a_record_on_launch= each.value.enable_resource_name_dns_a_record_on_launch
#  ipv6_cidr_block= each.value.ipv6_cidr_block != ""? each.value.ipv6_cidr_block : null
#  ipv6_native= each.value.ipv6_native
#  map_customer_owned_ip_on_launch= each.value.map_customer_owned_ip_on_launch ? each.value.map_customer_owned_ip_on_launch : null
#  outpost_arn= each.value.outpost_arn != "" ? each.value.outpost_arn : null
#  private_dns_hostname_type_on_launch= each.value.private_dns_hostname_type_on_launch != "" ? each.value.private_dns_hostname_type_on_launch : null



  availability_zone       =  each.value.az

  tags                    = merge(var.tags_default , { "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="private"} ,each.value.tags )
}




resource "aws_route_table" "private" {
  for_each                = local.normalized_private_subnets
  vpc_id     = aws_vpc.default.id
  tags                    = merge(var.tags_default , { "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="private"} ,each.value.tags )
}

resource "aws_route_table_association" "private" {
  for_each       = local.normalized_private_subnets
  route_table_id = aws_route_table.private["${each.key}"].id
  subnet_id      = aws_subnet.private["${each.key}"].id
}

/*

locals {
  filtered_subnets = {
    for k, v in aws_subnet.private :
    k => v if contains(["AZ", "DEFAULT"], var.subnets.private[k].nat_gateway)
  }

  subnets_by_az = {
    for az in distinct([for s in local.filtered_subnets : s.availability_zone]) :
    az => {
      ids = [for s in local.filtered_subnets : s.id if s.availability_zone == az]
      keys = [for k, s in local.filtered_subnets : k if s.availability_zone == az]
    }
  }
}

locals {
  all_subnet_ids = toset(flatten([
    for az, data in local.subnets_by_az : data.ids
  ]))
}



resource "aws_nat_gateway" "az_nat_gateway" {
  for_each = local.subnets_by_az

  allocation_id = aws_eip.nat_gateway_eip[each.key].id
  subnet_id     = each.value.ids[0]  # Используем первый сабнет в списке
}

resource "aws_eip" "nat_gateway_eip" {
  depends_on = [
    aws_subnet.private
  ]
  for_each = local.subnets_by_az

   domain   = "vpc"
}

output "subnets_by_az" {
  value = local.subnets_by_az
}

output "all_subnet_ids" {
  value = local.all_subnet_ids
}

locals {
  flat_subnet_keys = flatten([
    for az, data in local.subnets_by_az : [
      for key in data.keys : {
        key = key
        az  = az
        id = "${az}-${key}"
      }
    ]
  ])

  routes_map = {
    for entry in local.flat_subnet_keys : entry.id => {
      key = entry.key
      az  = entry.az
    }
  }
}

output "routes_map" {
  value = local.routes_map
}

resource "aws_route" "private_route" {
  depends_on = [
  aws_subnet.private]
  for_each = local.routes_map

  route_table_id         = aws_route_table.private[each.value.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az_nat_gateway[each.value.az].id
}


 */