
data "aws_availability_zones" "available" {}

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


output "az_mapping" {
   value = local.az_mapping
 }




resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.default.id
  for_each                = local.normalized_private_subnets_all
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
  for_each                = local.normalized_private_subnets_all
  vpc_id     = aws_vpc.default.id
  tags                    = merge(var.tags_default , { "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="private"} ,each.value.tags )
}

resource "aws_route_table_association" "private" {
  for_each       = local.normalized_private_subnets_all
  route_table_id = aws_route_table.private["${each.key}"].id
  subnet_id      = aws_subnet.private["${each.key}"].id
}

# < Az NAT Gateway
locals {
  normalized_private_subnets_AZ = {
    for k, v in var.subnets.private : k => merge(v, {
      az = lookup(local.az_id_to_az, v.az, v.az)  # Преобразуем AZ ID в AZ, если это необходимо
    })
    if v.nat_gateway == "AZ"  # Фильтруем только те подсети, где nat_gateway = "AZ"
  }



  private_subnets_by_az = {
    for az in distinct([for s in local.normalized_private_subnets_AZ : s.az]) :
    az => {
      ids  = [for k, s in local.normalized_private_subnets_AZ : aws_subnet.private[k].id if s.az == az]
      keys = [for k, s in local.normalized_private_subnets_AZ : k if s.az == az]
    }
  }
}

resource "aws_nat_gateway" "az_nat_gateway" {
  for_each = local.private_subnets_by_az

  allocation_id = aws_eip.az_nat_gateway_eip[each.key].id
  subnet_id     = each.value.ids[0]
  tags                    = merge(var.tags_default , { "Name" = "az_nat_gateway-${each.key}" })
}

resource "aws_eip" "az_nat_gateway_eip" {
  for_each = local.private_subnets_by_az
  tags                    = merge(var.tags_default , { "Name" = "az_nat_gateway-${each.key}" })
   domain   = "vpc"
}

locals {
  flat_private_subnet_keys = flatten([
    for az, data in local.private_subnets_by_az : [
      for key in data.keys : {
        key = key
        az  = az
        id = "${az}-${key}"
      }
    ]
  ])

  routes_map_private_subnet_az = {
    for entry in local.flat_private_subnet_keys : entry.id => {
      key = entry.key
      az  = entry.az
    }
  }
}

resource "aws_route" "private_route_az" {

  for_each = local.routes_map_private_subnet_az

  route_table_id         = aws_route_table.private[each.value.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az_nat_gateway[each.value.az].id
}


output "normalized_private_subnets_AZ" {
  value = local.normalized_private_subnets_AZ
}

output "private_subnets_by_az" {
  value = local.private_subnets_by_az
}

# Az NAT Gateway >



# < SUBNET NAT Gateway

locals {
  normalized_private_subnets_SUBNET = {
    for k, v in var.subnets.private : k => merge(v, {
      az = lookup(local.az_id_to_az, v.az, v.az)  # Преобразуем AZ ID в AZ, если это необходимо
    })
    if v.nat_gateway == "SUBNET"  # Фильтруем только те подсети, где nat_gateway = "SUBNET"
  }


}

output "normalized_private_subnets_SUBNET" {
  value = local.normalized_private_subnets_SUBNET
}
resource "aws_eip" "SUBNET_nat_gateway_eip" {
  for_each = local.normalized_private_subnets_SUBNET
  tags                    = merge(var.tags_default , { "Name" = "SUBNET_nat_gateway-${each.key}" })
   domain   = "vpc"
}

resource "aws_nat_gateway" "SUBNET_nat_gateway" {
  for_each = local.normalized_private_subnets_SUBNET

  allocation_id = aws_eip.SUBNET_nat_gateway_eip[each.key].id
  subnet_id     = aws_subnet.private[each.key].id
  tags                    = merge(var.tags_default , { "Name" = "SUBNET_nat_gateway-${each.key}" })
}

resource "aws_route" "private_route_SUBNET" {

for_each = local.normalized_private_subnets_SUBNET
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.SUBNET_nat_gateway[each.key].id
}

# SUBNET NAT Gateway >