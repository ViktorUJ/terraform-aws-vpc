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
        az   = "eu-north-1a"
      }

    }
    private = {

      "rds1" = {
        name = "rds-subnet-1"
        cidr = "10.10.11.0/24"
        az   = "eu-north-1b"
        type = "rds"

      }
      "rds2" = {
        name = "rds-subnet-2"
        cidr = "10.10.12.0/24"
        az   = "eu-north-1a"
        type = "rds"
      }
      "k8s1" = {
        name = "rds-subnet-1"
        cidr = "10.10.13.0/24"
        az   = "eu-north-1a"
        type = "k8s"
      }

      "k8s2" = {
        name = "rds-subnet-2"
        cidr = "10.10.14.0/24"
        az   = "eu-north-1a"
        type = "k8s"
      }
      "app1" = {
        name = "app-subnet-1"
        cidr = "10.10.16.0/24"
        az   = "eu-north-1a"
        type = "app"
      }
      "app2" = {
        name = "app-subnet-2"
        cidr = "10.10.15.0/24"
        az   = "eu-north-1a"
        type = "app"
      }


    }
  }
}
