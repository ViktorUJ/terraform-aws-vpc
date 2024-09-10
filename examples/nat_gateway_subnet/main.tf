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
       nat_gateway                         = "SUBNET"

     }
     "private2" = {
       name        = "private-subnet-2"
       cidr        = "10.10.12.0/24"
       az          = "eu-north-1a"
       nat_gateway                         = "SUBNET"
     }
      "private3" = {
       name        = "private-subnet-3"
       cidr        = "10.10.13.0/24"
       az          = "eu-north-1b"
       nat_gateway                         = "SUBNET"
     }
      "private4" = {
       name        = "private-subnet-4"
       cidr        = "10.10.14.0/24"
       az          = "eu-north-1b"
       nat_gateway                         = "NONE"  # this subnet will not have NAT Gateway
     }


    }
  }
}
