provider "aws" {
  region = "eu-north-1"
}


module "vpc" {
 # source = "ViktorUJ/vpc/aws"
  source = "../../"
  tags_default = {
    "Owner"       = "DevOps Team"
    "Terraform"   = "true"
    "cost_center" = "1111"
  }
  vpc = {
    name = "test-vpc"
    cidr = "10.10.0.0/16"
  }

  subnets = {
    public = {
      "pub1" = {
        name = "public-subnet-1"
        cidr = "10.10.1.0/24"
        az   = "eu-north-1a"
      }
      "pub2" = {
        name = "public-subnet-2"
        cidr = "10.10.2.0/24"
        az   = "eu-north-1a"
      }

    }
    private = {

      "private1" = {
        name = "private-subnet-1"
        cidr = "10.10.11.0/24"
        az   = "eu-north-1a"

      }
      "private2" = {
        name = "private-subnet-2"
        cidr = "10.10.12.0/24"
        az   = "eu-north-1a"
      }
    }
  }
}
