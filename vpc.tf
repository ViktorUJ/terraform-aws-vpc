resource "aws_vpc" "default" {
  cidr_block           = var.vpc.cidr
  enable_dns_support   = var.vpc.enable_dns_support
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  tags                 = merge(var.tags_default, { "Name" = var.vpc.name }, var.vpc.tags)
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags   = merge(var.tags_default, { "Name" = var.vpc.name }, var.vpc.tags)
}

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each   = toset(var.vpc.secondary_cidr_blocks)
  vpc_id     = aws_vpc.default.id
  cidr_block = each.value
}

resource "aws_network_acl_rule" "default" {
  for_each        = var.vpc.nacl_default
  network_acl_id  = aws_vpc.default.default_network_acl_id
  rule_number     = each.value.rule_number
  egress          = each.value.egress
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = each.value.cidr_block != "" ? each.value.cidr_block : null
  from_port       = each.value.from_port != "" ? each.value.from_port : null
  to_port         = each.value.to_port != "" ? each.value.to_port : null
  ipv6_cidr_block = each.value.ipv6_cidr_block != "" ? each.value.ipv6_cidr_block : null
}


locals {
  # Check if any DHCP option is defined (for strings and lists)
  dhcp_options_defined = (
    var.vpc.dhcp_options.domain_name != "" ||
    length(var.vpc.dhcp_options.domain_name_servers) > 0 ||
    length(var.vpc.dhcp_options.ntp_servers) > 0 ||
    length(var.vpc.dhcp_options.netbios_name_servers) > 0 ||
    var.vpc.dhcp_options.netbios_node_type != "" ||
    var.vpc.dhcp_options.ipv6_address_preferred_lease_time != "140"
  )
}

resource "aws_vpc_dhcp_options" "default" {
  for_each = local.dhcp_options_defined ? toset(["enable"]) : toset([])
  domain_name          = var.vpc.dhcp_options.domain_name !=""? var.vpc.dhcp_options.domain_name : null
  domain_name_servers  = length(var.vpc.dhcp_options.domain_name_servers) > 0 ? var.vpc.dhcp_options.domain_name_servers : null
  ntp_servers          = length(var.vpc.dhcp_options.ntp_servers) > 0 ? var.vpc.dhcp_options.ntp_servers : null
  netbios_name_servers = length(var.vpc.dhcp_options.netbios_name_servers) > 0 ? var.vpc.dhcp_options.netbios_name_servers : null
  netbios_node_type    = var.vpc.dhcp_options.netbios_node_type != "" ? var.vpc.dhcp_options.netbios_node_type : null
  ipv6_address_preferred_lease_time= var.vpc.dhcp_options.ipv6_address_preferred_lease_time != "140" ? var.vpc.dhcp_options.ipv6_address_preferred_lease_time : null
  tags = merge(var.tags_default, { "Name" = var.vpc.name }, var.vpc.tags)
}

resource "aws_vpc_dhcp_options_association" "default" {
  for_each = local.dhcp_options_defined ? toset(["enable"]) : toset([])
  vpc_id          = aws_vpc.default.id
  dhcp_options_id = aws_vpc_dhcp_options.default[each.key].id
}
