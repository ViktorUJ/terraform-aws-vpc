resource "aws_subnet" "subnets_pub" {
  vpc_id                  = aws_vpc.default.id
  for_each                = var.subnets.public
  map_public_ip_on_launch = true
  cidr_block              = each.value.cidr
  availability_zone_id    = each.value.az
  tags                    = merge(var.tags_default,{ "Name" = each.value.name }, {"type"=each.value.type}, {"subnet_key"=each.key},{"access_type"="public"} )
}