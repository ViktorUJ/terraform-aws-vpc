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
    public={}
    private={}

  }
}
