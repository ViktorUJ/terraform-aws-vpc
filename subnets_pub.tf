resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  for_each                = var.subnets.public
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  cidr_block              = each.value.cidr

  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  customer_owned_ipv4_pool                       = each.value.customer_owned_ipv4_pool != "" ? each.value.customer_owned_ipv4_pool : null
  enable_dns64                                   = each.value.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  ipv6_cidr_block                                = each.value.ipv6_cidr_block != "" ? each.value.ipv6_cidr_block : null
  ipv6_native                                    = each.value.ipv6_native
  map_customer_owned_ip_on_launch                = each.value.map_customer_owned_ip_on_launch ? each.value.map_customer_owned_ip_on_launch : null
  outpost_arn                                    = each.value.outpost_arn != "" ? each.value.outpost_arn : null
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch != "" ? each.value.private_dns_hostname_type_on_launch : null


  availability_zone_id = length(regexall("^[a-z]{2}-", each.value.az)) == 0 ? each.value.az : null
  availability_zone    = length(regexall("^[a-z]{2}-", each.value.az)) > 0 ? each.value.az : null

  tags = merge(var.tags_default, { "Name" = each.value.name }, { "type" = each.value.type }, { "subnet_key" = each.key }, { "access_type" = "public" }, each.value.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  tags   = merge(var.tags_default, { "access_type" = "public" })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id

  timeouts {
    create = "5m"
  }
}


resource "aws_route_table_association" "pub" {
  for_each       = var.subnets.public
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public["${each.key}"].id
}


locals {
  # Группировка публичных подсетей по типу
  public_subnet_by_type = {
    for type in distinct([for k, v in var.subnets.public : v.type]) : type => {
      ids  = [for k, v in var.subnets.public : aws_subnet.public[k].id if v.type == type]
      keys = [for k, v in var.subnets.public : k if v.type == type]
    }
  }
}

# Вывод для проверки
output "public_subnet_by_type" {
  value = local.public_subnet_by_type
}
