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
        cidr = "10.10.1.0/24"
        az = "eun1-az1"
        type="qa-test"
        tags={"cost_center"="5555"}
        private_dns_hostname_type_on_launch="resource-name"
      }
      "pub2" = {
        name = "public-subnet-2"
        cidr = "10.10.2.0/24"
        az = "eun1-az3"
        type="Devops"
        tags={"cost_center"="1234"}

      }}
    private = {
      "private1" = {
        name = "private-subnet-1"
        cidr = "10.10.11.0/24"
        az = "eun1-az1"
        type="qa-test"
        tags={"cost_center"="5555"}
        private_dns_hostname_type_on_launch="resource-name"
                nat_gateway="SINGLE"
      }
      "private2" = {
        name = "private-subnet-2"
        cidr = "10.10.12.0/24"
        az = "eun1-az3"
        type="Devops"
        tags={"cost_center"="1234"}
                nat_gateway="SINGLE"

      }
      "private3" = {
        name = "private-subnet-3"
        cidr = "10.10.13.0/24"
        az = "eun1-az3"
        type="Devops"
        tags={"cost_center"="1234"}
        nat_gateway="SINGLE"

      }
      "private4" = {
        name = "private-subnet-4"
        cidr = "10.10.14.0/24"
        az = "eun1-az3"
        type="Devops"
        tags={"cost_center"="1234"}
        nat_gateway="DEFAULT"

      }

      "k8s1" = {
        name = "private-k8s-1"
        cidr = "10.10.15.0/24"
        az = "eun1-az3"
        type="k8s"
        tags={"cost_center"="1234"}
        nat_gateway="SINGLE"

      }
      "k8s2" = {
        name = "private-k8s-2"
        cidr = "10.10.16.0/240"
        az = "eun1-az3"
        type="k8s"
        tags={"cost_center"="1234"}


      }

    }
  }

}
