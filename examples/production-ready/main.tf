provider "aws" {
  region = "eu-west-1"
}

# Production-ready VPC configuration with monitoring
module "vpc" {
  source = "../../"
  
  tags_default = {
    Environment   = "production"
    Project       = "my-app"
    Owner         = "platform-team"
    CostCenter    = "12345"
    Terraform     = "true"
    BackupPolicy  = "daily"
  }

  vpc = {
    name                 = "prod-vpc"
    cidr                 = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    
    # Custom DHCP options for production
    dhcp_options = {
      domain_name         = "prod.internal"
      domain_name_servers = ["AmazonProvidedDNS"]
    }
  }

  subnets = {
    # Public subnets for load balancers
    public = {
      "alb-1a" = {
        name = "prod-alb-1a"
        cidr = "10.0.1.0/24"
        az   = "eu-west-1a"
        type = "alb"
        tags = { Tier = "public", Purpose = "load-balancer" }
      }
      "alb-1b" = {
        name = "prod-alb-1b"
        cidr = "10.0.2.0/24"
        az   = "eu-west-1b"
        type = "alb"
        tags = { Tier = "public", Purpose = "load-balancer" }
      }
      "alb-1c" = {
        name = "prod-alb-1c"
        cidr = "10.0.3.0/24"
        az   = "eu-west-1c"
        type = "alb"
        tags = { Tier = "public", Purpose = "load-balancer" }
      }
      # NAT Gateway subnet
      "nat-1a" = {
        name        = "prod-nat-1a"
        cidr        = "10.0.4.0/28"  # Small subnet for NAT Gateway
        az          = "eu-west-1a"
        type        = "nat"
        nat_gateway = "DEFAULT"
        tags        = { Tier = "public", Purpose = "nat-gateway" }
      }
    }

    # Private subnets for applications
    private = {
      # Web tier
      "web-1a" = {
        name        = "prod-web-1a"
        cidr        = "10.0.11.0/24"
        az          = "eu-west-1a"
        type        = "web"
        nat_gateway = "SINGLE"
        tags        = { Tier = "web", Purpose = "web-servers" }
      }
      "web-1b" = {
        name        = "prod-web-1b"
        cidr        = "10.0.12.0/24"
        az          = "eu-west-1b"
        type        = "web"
        nat_gateway = "SINGLE"
        tags        = { Tier = "web", Purpose = "web-servers" }
      }
      "web-1c" = {
        name        = "prod-web-1c"
        cidr        = "10.0.13.0/24"
        az          = "eu-west-1c"
        type        = "web"
        nat_gateway = "SINGLE"
        tags        = { Tier = "web", Purpose = "web-servers" }
      }

      # Application tier
      "app-1a" = {
        name        = "prod-app-1a"
        cidr        = "10.0.21.0/24"
        az          = "eu-west-1a"
        type        = "app"
        nat_gateway = "SINGLE"
        tags        = { Tier = "app", Purpose = "application-servers" }
      }
      "app-1b" = {
        name        = "prod-app-1b"
        cidr        = "10.0.22.0/24"
        az          = "eu-west-1b"
        type        = "app"
        nat_gateway = "SINGLE"
        tags        = { Tier = "app", Purpose = "application-servers" }
      }
      "app-1c" = {
        name        = "prod-app-1c"
        cidr        = "10.0.23.0/24"
        az          = "eu-west-1c"
        type        = "app"
        nat_gateway = "SINGLE"
        tags        = { Tier = "app", Purpose = "application-servers" }
      }

      # Database tier (no NAT Gateway for security)
      "db-1a" = {
        name        = "prod-db-1a"
        cidr        = "10.0.31.0/26"  # Smaller subnet for databases
        az          = "eu-west-1a"
        type        = "db"
        nat_gateway = "NONE"
        tags        = { Tier = "db", Purpose = "database" }
      }
      "db-1b" = {
        name        = "prod-db-1b"
        cidr        = "10.0.31.64/26"
        az          = "eu-west-1b"
        type        = "db"
        nat_gateway = "NONE"
        tags        = { Tier = "db", Purpose = "database" }
      }
      "db-1c" = {
        name        = "prod-db-1c"
        cidr        = "10.0.31.128/26"
        az          = "eu-west-1c"
        type        = "db"
        nat_gateway = "NONE"
        tags        = { Tier = "db", Purpose = "database" }
      }

      # Management/Tools subnet
      "mgmt-1a" = {
        name        = "prod-mgmt-1a"
        cidr        = "10.0.41.0/26"
        az          = "eu-west-1a"
        type        = "mgmt"
        nat_gateway = "SINGLE"
        tags        = { Tier = "mgmt", Purpose = "management-tools" }
      }
    }
  }
}

# Optional: Add monitoring
module "vpc_monitoring" {
  source = "../../modules/monitoring"
  
  vpc_id                    = module.vpc.vpc_raw.id
  nat_gateway_ids          = [for ng in module.vpc.nat_gateway_single_raw : ng.id]
  enable_flow_logs         = true
  flow_logs_retention_days = 30
  
  tags = {
    Environment = "production"
    Purpose     = "vpc-monitoring"
  }
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_raw.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_raw.cidr_block
}

output "public_subnets_by_type" {
  description = "Public subnets grouped by type"
  value       = module.vpc.public_subnets_by_type
}

output "private_subnets_by_type" {
  description = "Private subnets grouped by type"
  value       = module.vpc.private_subnets_by_type
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = [for ng in module.vpc.nat_gateway_single_raw : ng.id]
}

output "flow_log_id" {
  description = "VPC Flow Log ID"
  value       = module.vpc_monitoring.flow_log_id
}