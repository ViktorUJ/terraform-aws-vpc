resource "aws_vpc" "default" {
  cidr_block           = var.vpc.cidr
  enable_dns_support   = var.vpc.enable_dns_support
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  tags                 = merge(var.tags_default,{ "Name" = var.vpc.name },var.vpc.tags)
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags   = merge(var.tags_default,{ "Name" = var.vpc.name },var.vpc.tags)
}

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each = toset(var.vpc.secondary_cidr_blocks)
  vpc_id = aws_vpc.default.id
  cidr_block = each.value
}