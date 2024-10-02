provider "aws" {
  region = "eu-north-1"
}


module "vpc" {
  source = "ViktorUJ/vpc/aws"
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
        az   = "eu-north-1b"
      }

    }
    private = {

      "private1" = {
        name        = "private-subnet-1"
        cidr        = "10.10.11.0/24"
        az          = "eu-north-1a"
        nat_gateway = "AZ" # it is default . you can remove it

      }
      "private2" = {
        name = "private-subnet-2"
        cidr = "10.10.12.0/24"
        az   = "eu-north-1a"
        #       nat_gateway                         = "AZ"  # it is default . you can remove it
      }
      "private3" = {
        name = "private-subnet-3"
        cidr = "10.10.13.0/24"
        az   = "eu-north-1b"
        #       nat_gateway                         = "AZ"  # it is default . you can remove it
      }
      "private4" = {
        name = "private-subnet-4"
        cidr = "10.10.14.0/24"
        az   = "eu-north-1b"
        #       nat_gateway                         = "AZ"  # it is default . you can remove it
      }


    }
  }
}
