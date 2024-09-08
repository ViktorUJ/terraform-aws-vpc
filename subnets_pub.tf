resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  for_each                = local.normalized_pub_subnets_all
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



# Local variable to flatten all NACL rules for public subnets
locals {
  public_nacl_rules = flatten([
    for subnet_key, subnet in local.normalized_pub_subnets_all : [
      for rule_key, rule in subnet.nacl : {
        subnet_key = subnet_key
        rule_key   = rule_key
        rule       = rule
      }
      if length(subnet.nacl) > 0
    ]
  ])
}

# Create a Network ACL for each public subnet if nacl is defined and contains rules
resource "aws_network_acl" "public" {
  for_each = {
    for subnet_key, subnet in local.normalized_pub_subnets_all :
    subnet_key => subnet
    if length(subnet.nacl) > 0
  }

  vpc_id = aws_vpc.default.id

  tags = merge(var.tags_default, {
    "Name" = "${each.value.name}-nacl"
  })
}

# Create Network ACL rules for each public subnet's NACL
resource "aws_network_acl_rule" "public_rules" {
  for_each = {
    for rule in local.public_nacl_rules :
    "${rule.subnet_key}-${rule.rule_key}-${rule.rule.rule_number}" => rule
    if length(var.subnets.public[rule.subnet_key].nacl) > 0
  }

  network_acl_id = aws_network_acl.public[each.value.subnet_key].id
  rule_number    = each.value.rule.rule_number
  egress         = each.value.rule.egress == "true" ? true : false
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.rule_action
  cidr_block     = each.value.rule.cidr_block != "" ? each.value.rule.cidr_block : null
  from_port      = each.value.rule.from_port != "" ? tonumber(each.value.rule.from_port) : null
  to_port        = each.value.rule.to_port != "" ? tonumber(each.value.rule.to_port) : null
  icmp_code      = each.value.rule.icmp_code != "" ? tonumber(each.value.rule.icmp_code) : null
  icmp_type      = each.value.rule.icmp_type != "" ? tonumber(each.value.rule.icmp_type) : null
  ipv6_cidr_block = each.value.rule.ipv6_cidr_block != "" ? each.value.rule.ipv6_cidr_block : null
}

# Associate the NACL with each public subnet if NACL is defined and contains rules
resource "aws_network_acl_association" "public_association" {
  for_each = {
    for subnet_key, subnet in local.normalized_pub_subnets_all:
    subnet_key => subnet
    if length(subnet.nacl) > 0
  }

  subnet_id      = aws_subnet.public[each.key].id
  network_acl_id = aws_network_acl.public[each.key].id
}



