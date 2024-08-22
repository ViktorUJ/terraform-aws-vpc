resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  for_each                = var.subnets.public
  map_public_ip_on_launch = true
  cidr_block              = each.value.cidr
  availability_zone                              = length(regexall("^[a-z]{2}-", element(each.value.az, count.index))) > 0 ? element(each.value.az, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(each.value.az, count.index))) == 0 ? element(each.value.az, count.index) : null
  tags                    = merge(var.tags_default , { "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="public"} ,each.value.tags )
}

resource "aws_route_table" "public" {
  vpc_id     = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
    tags  = merge(var.tags_default , {"access_type"="public"} )
}

resource "aws_route_table_association" "pub" {
  for_each       = var.subnets.public
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public["${each.key}"].id
}
