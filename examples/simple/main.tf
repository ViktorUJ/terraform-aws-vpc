provider "aws" {
  region = "eu-north-1"
}


module "vpc" {
  source = "../../"
  tags_default = {
    "Owner" = "DevOps Team"
    "Terraform" = "true"
  }
  vpc={
  name = "test-vpc"
  cidr = "10.0.0.0/16"
  secondary_cidr_blocks=["10.1.0.0/16"]
  subnets={

  }
  }


}