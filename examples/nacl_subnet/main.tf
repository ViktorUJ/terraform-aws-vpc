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
  }

  subnets = {
    public = {
      "pub1" = {
        name                                = "public-subnet-1"
        cidr                                = "10.10.1.0/24"
        az                                  = "eu-north-1a"
      }
      "pub2" = {
        name = "public-subnet-2"
        cidr = "10.10.2.0/24"
        az   = "eu-north-1a"
    }

    }
    private = {

     "private1" = {
       name                                = "private-subnet-1"
       cidr                                = "10.10.11.0/24"
       az                                  = "eu-north-1a"
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
     "private2" = {
       name        = "private-subnet-2"
       cidr        = "10.10.12.0/24"
       az          = "eu-north-1a"
        nacl={
         test = {
            egress      = "true"
            rule_number = "99"
            rule_action = "allow"
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
         }
         ssh = {
           egress      = "false"
           rule_number = "88"
           rule_action = "allow"
           protocol    = "tcp"
           from_port   = "22"
           to_port     = "22"
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
    }
  }
}
