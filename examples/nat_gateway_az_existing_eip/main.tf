provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source = "ViktorUJ/vpc/aws"
  # Using existing EIP IDs here
  existing_eip_ids_az = {
    "us-west-1a" = "vpc-0a1b2c3d4e5f6g7h8"
    "us-east-1b" = "vpc-0a1b2c3d4e5f6g7h8"
  }
  vpc = {
    name                  = "main"
    cidr                  = "10.2.0.0/16"
    secondary_cidr_blocks = ["100.64.0.0/16"]
    instance_tenancy      = "default"
    enable_dns_support    = true
    enable_dns_hostnames  = false
    tags_default = {
      "Environment" = "Dev"
      "Name"        = "EKS-VPC"
      "Owner"       = "DevOps"
    }
    dhcp_options = {
      domain_name          = ""
      domain_name_servers  = []
      ntp_servers          = []
      netbios_name_servers = []
      netbios_node_type    = ""
    }
  }

  subnets = {
    public = {
      public1 = {
        name                                           = "public-1"
        cidr                                           = "10.2.2.0/24"
        az                                             = "us-west-1a"
        tags                                           = { "Name" = "public-1" }
        type                                           = "public"
        assign_ipv6_address_on_creation                = false
        customer_owned_ipv4_pool                       = ""
        enable_dns64                                   = false
        enable_resource_name_dns_aaaa_record_on_launch = false
        enable_resource_name_dns_a_record_on_launch    = false
        ipv6_native                                    = false
        map_customer_owned_ip_on_launch                = false
        map_public_ip_on_launch                        = true
        outpost_arn                                    = ""
        private_dns_hostname_type_on_launch            = "ip-name"
        nacl = {
          default_ingress = {
            egress      = false
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
          default_egress = {
            egress      = true
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
        }
      }
      public2 = {
        name                                           = "public-2"
        cidr                                           = "10.2.3.0/24"
        az                                             = "us-west-1b"
        tags                                           = { "Name" = "public-2" }
        type                                           = "public"
        assign_ipv6_address_on_creation                = false
        customer_owned_ipv4_pool                       = ""
        enable_dns64                                   = false
        enable_resource_name_dns_aaaa_record_on_launch = false
        enable_resource_name_dns_a_record_on_launch    = false
        ipv6_native                                    = false
        map_customer_owned_ip_on_launch                = false
        map_public_ip_on_launch                        = true
        outpost_arn                                    = ""
        private_dns_hostname_type_on_launch            = "ip-name"
        nacl = {
          default_ingress = {
            egress      = false
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
          default_egress = {
            egress      = true
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
        }
      }
    }
    private = {
      eks1 = {
        name                                           = "eks-control-plane-1"
        cidr                                           = "10.2.0.0/24"
        az                                             = "us-west-1a"
        tags                                           = {}
        type                                           = "private"
        assign_ipv6_address_on_creation                = false
        customer_owned_ipv4_pool                       = ""
        enable_dns64                                   = false
        enable_resource_name_dns_aaaa_record_on_launch = false
        enable_resource_name_dns_a_record_on_launch    = false
        ipv6_native                                    = false
        map_customer_owned_ip_on_launch                = false
        map_public_ip_on_launch                        = false
        outpost_arn                                    = ""
        private_dns_hostname_type_on_launch            = "ip-name"
        nacl = {
          eks_default_ingress = {
            egress      = false
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
          eks_default_egress = {
            egress      = true
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
        }
      }
      eks2 = {
        name                                           = "elk-control-plane-2"
        cidr                                           = "10.2.1.0/24"
        az                                             = "us-west-1b"
        tags                                           = {}
        type                                           = "private"
        assign_ipv6_address_on_creation                = false
        customer_owned_ipv4_pool                       = ""
        enable_dns64                                   = false
        enable_resource_name_dns_aaaa_record_on_launch = false
        enable_resource_name_dns_a_record_on_launch    = false
        ipv6_native                                    = false
        map_customer_owned_ip_on_launch                = false
        map_public_ip_on_launch                        = false
        outpost_arn                                    = ""
        private_dns_hostname_type_on_launch            = "ip-name"
        nacl = {
          eks_default_ingress = {
            egress      = false
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
          eks_default_egress = {
            egress      = true
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          }
        }
      }
    }
  }

  tags_default = {
    "Environment" = "Dev"
    "Name"        = "EKS-VPC"
    "Owner"       = "DevOps"
  }
}
