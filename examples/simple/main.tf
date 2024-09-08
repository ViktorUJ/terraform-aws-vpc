provider "aws" {
  region = "eu-north-1"
}


module "vpc" {
  source = "../../"
  tags_default = {
    "Owner"       = "DevOps Team"
    "Terraform"   = "true"
    "cost_center" = "1111"
  }
  vpc = {
    name                  = "test-vpc"
    cidr                  = "10.10.0.0/16"
    secondary_cidr_blocks = ["10.2.0.0/16", "10.3.0.0/16"]
    tags                  = { "cost_center" = "444" }
    dhcp_options={
      netbios_node_type = "3"
    }
    nacl_default = {
      test = {
        egress      = "true"
        rule_number = "99"
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"


      }
      test2 = {
        egress      = "false"
        rule_number = "99"
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"


      }
    }
  }

  subnets = {
    public = {
      "pub1" = {
        name                                = "public-subnet-1"
        cidr                                = "10.10.1.0/24"
        az                                  = "eun1-az1"
        type                                = "qa-test"
        tags                                = { "cost_center" = "5555" }
        private_dns_hostname_type_on_launch = "resource-name"
        nacl={
         test = {
            egress      = "true"
            rule_number = "99"
            rule_action = "allow"
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
         }
         test2 = {
           egress      = "false"
           rule_number = "99"
           rule_action = "allow"
           protocol    = "tcp"
           cidr_block  = "0.0.0.0/0"
         }
         allow_all_inbound = {
           egress      = "false"
           rule_number = "9999"
           rule_action = "allow"
           from_port   = "0"
           to_port     = "0"
           protocol    = "-1"
           cidr_block  = "0.0.0.0/0"
         }
         allow_all_outbound = {
           egress      = "true"
           rule_number = "8888"
           rule_action = "allow"
           from_port   = "0"
           to_port     = "0"
           protocol    = "-1"
           cidr_block  = "0.0.0.0/0"
         }


        }
      }
      "pub2" = {
        name = "public-subnet-2"
        cidr = "10.10.2.0/24"
        az   = "eun1-az3"
        type = "Devops"
        tags = { "cost_center" = "1234" }

    }

    }
    private = {
     "private_no_nat" = {
       name                                = "private-subnet-1"
       cidr                                = "10.10.33.0/24"
       az                                  = "eun1-az1"
       type                                = "qa-test"
       tags                                = { "cost_center" = "5555" }
       private_dns_hostname_type_on_launch = "resource-name"
       nat_gateway                         = "NONE"
       nacl={
        test = {
           egress      = "true"
           rule_number = "99"
           rule_action = "allow"
           protocol    = "tcp"
           cidr_block  = "0.0.0.0/0"
        }
        test2 = {
          egress      = "false"
          rule_number = "99"
          rule_action = "allow"
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        }
       }   }

     "private1" = {
       name                                = "private-subnet-1"
       cidr                                = "10.10.11.0/24"
       az                                  = "eun1-az1"
       type                                = "qa-test"
       tags                                = { "cost_center" = "5555" }
       private_dns_hostname_type_on_launch = "resource-name"
       nat_gateway                         = "SINGLE"
       nacl={
        test = {
           egress      = "true"
           rule_number = "99"
           rule_action = "allow"
           protocol    = "tcp"
           cidr_block  = "0.0.0.0/0"
        }
        test2 = {
          egress      = "false"
          rule_number = "99"
          rule_action = "allow"
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        }
       }


     }
     "private2" = {
       name        = "private-subnet-2"
       cidr        = "10.10.12.0/24"
       az          = "eun1-az3"
       type        = "Devops"
       tags        = { "cost_center" = "1234" }
       nat_gateway = "SINGLE"

     }
     "private3" = {
       name        = "private-subnet-3"
       cidr        = "10.10.13.0/24"
       az          = "eu-north-1a"
       type        = "Devops"
       tags        = { "cost_center" = "1234" }
       nat_gateway = "SINGLE"

     }
     "private4" = {
       name        = "private-subnet-4"
       cidr        = "10.10.14.0/24"
       az          = "eun1-az3"
       type        = "Devops"
       tags        = { "cost_center" = "1234" }
       nat_gateway = "DEFAULT"

     }

     "k8s1" = {
       name        = "private-k8s-1"
       cidr        = "10.10.15.0/24"
       az          = "eun1-az3"
       type        = "k8s"
       tags        = { "cost_center" = "1234" }
       nat_gateway = "SINGLE"

     }
     "k8s2" = {
       name = "private-k8s-2"
       cidr = "10.10.16.0/24"
       az   = "eun1-az3"
       type = "k8s"
       tags = { "cost_center" = "1234" }


     }

    }


  }

}
