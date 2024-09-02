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
  filtered_subnets = tomap({
    for k, v in aws_subnet.private :
    k => v.id if contains(["AZ", "DEFAULT"], var.subnets.private[k].nat_gateway)
  })
}

locals {
  subnets_by_az = {
    for az in distinct([for s in local.filtered_subnets : aws_subnet.private[s].availability_zone]) :
    az => [for s in local.filtered_subnets : aws_subnet.private[s].id if aws_subnet.private[s].availability_zone == az]
  }

  subnets_by_az_id = {
    for az_id in distinct([for s in local.filtered_subnets : aws_subnet.private[s].availability_zone_id]) :
    az_id => [for s in local.filtered_subnets : aws_subnet.private[s].id if aws_subnet.private[s].availability_zone_id == az_id]
  }
}


output "subnets_by_az" {
  value = local.subnets_by_az
}

output "subnets_by_az_id" {
  value = local.subnets_by_az_id
}