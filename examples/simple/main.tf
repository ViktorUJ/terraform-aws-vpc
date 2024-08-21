provider "aws" {
  region = "eu-west-1"
}


module "vpc" {
  source = "../../"
  vpc={
  name = "test-vpc"
  cidr = "10.0.0.0/16"
  secondary_cidr_blocks=["10.1.0.0/16"]
  }


}