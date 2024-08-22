provider "aws" {
  region = "eu-north-1"
}


module "vpc" {
  source = "../../"
  tags_default = {
    "Owner" = "DevOps Team"
    "Terraform" = "true"
    "cost_center"="1111"
  }
  vpc={
  name = "test-vpc"
  cidr = "10.10.0.0/16"
  secondary_cidr_blocks=["10.2.0.0/16","10.3.0.0/16"]
    tags={"cost_center"="444"}
  }

  subnets= {
    public = {
      "pub1" = {
        name = "public-subnet-1"
        cidr = "10.10.0.0/16"
        az = "eun1-az1"
        type="qa-test"
                tags={"cost_center"="5555"}
      }
      "pub2" = {
        name = "public-subnet-2"
        cidr = "10.2.0.0/16"
        az = "eu-north-1c"
        type="Devops"
        tags={"cost_center"="1234"}

      }

    }
  }

}