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
