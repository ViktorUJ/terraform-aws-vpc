resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.default.id
  for_each                = var.subnets.private
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


  availability_zone_id    = length(regexall("^[a-z]{2}-", each.value.az)) == 0 ?  each.value.az :null
  availability_zone       = length(regexall("^[a-z]{2}-", each.value.az)) > 0 ? each.value.az : null

  tags                    = merge(var.tags_default , { "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="private"} ,each.value.tags )
}

resource "aws_route_table" "private" {
  for_each                = var.subnets.private
  vpc_id     = aws_vpc.default.id
  tags                    = merge(var.tags_default , { "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="private"} ,each.value.tags )
}

resource "aws_route_table_association" "private" {
  for_each       = var.subnets.private
  route_table_id = aws_route_table.private["${each.key}"].id
  subnet_id      = aws_subnet.private["${each.key}"].id
}


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
  for_each = local.subnets_by_az

   domain   = "vpc"
}

output "subnets_by_az" {
  value = local.subnets_by_az
}

output "all_subnet_ids" {
  value = local.all_subnet_ids
}

resource "aws_route" "private_route" {
  for_each = {
    for az, data in local.subnets_by_az : {
      for key in data.keys : "${az}-${key}" => {
        key = key
        az  = az
      }
    }
  }

  route_table_id         = aws_route_table.private[each.value.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az_nat_gateway[each.value.az].id
}