# Best Practices for AWS VPC Module

## Security Recommendations

### 1. CIDR Planning
- Use RFC 1918 private address spaces (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Plan for future growth - don't use /24 for VPC if you need many subnets
- Reserve IP ranges for peering with other VPCs

### 2. Subnet Design
- Use consistent naming conventions
- Distribute subnets across multiple AZs for high availability
- Separate tiers (web, app, db) into different subnet types

### 3. NAT Gateway Strategy
- **AZ**: Best for high availability and performance (default)
- **SINGLE**: Cost-effective for development environments
- **SUBNET**: Use only when specific subnet isolation is required
- **NONE**: For completely isolated subnets (e.g., database tiers)

### 4. Network ACLs
- Use NACLs as an additional layer of security (defense in depth)
- Keep NACL rules simple and well-documented
- Remember NACLs are stateless - configure both inbound and outbound rules

### 5. Tagging Strategy
```hcl
tags_default = {
  "Environment"   = "production"
  "Project"       = "my-project"
  "Owner"         = "team-name"
  "CostCenter"    = "12345"
  "Terraform"     = "true"
  "BackupPolicy"  = "daily"
}
```

## Performance Optimization

### 1. Availability Zone Distribution
```hcl
# Good: Distribute across multiple AZs
subnets = {
  public = {
    "web-1a" = { az = "us-west-2a", cidr = "10.0.1.0/24" }
    "web-1b" = { az = "us-west-2b", cidr = "10.0.2.0/24" }
    "web-1c" = { az = "us-west-2c", cidr = "10.0.3.0/24" }
  }
}
```

### 2. Subnet Sizing
```hcl
# Reserve space for growth
vpc = {
  cidr = "10.0.0.0/16"  # 65,536 IPs
}

subnets = {
  public = {
    "web-1a" = { cidr = "10.0.1.0/24" }   # 256 IPs
    "web-1b" = { cidr = "10.0.2.0/24" }   # 256 IPs
  }
  private = {
    "app-1a" = { cidr = "10.0.11.0/24" }  # 256 IPs
    "app-1b" = { cidr = "10.0.12.0/24" }  # 256 IPs
    "db-1a"  = { cidr = "10.0.21.0/26" }  # 64 IPs (smaller for DB)
    "db-1b"  = { cidr = "10.0.21.64/26" } # 64 IPs
  }
}
```

## Cost Optimization

### 1. NAT Gateway Costs
- Use SINGLE NAT Gateway for dev/test environments
- Consider NAT Instances for very low traffic scenarios
- Use VPC Endpoints for AWS services to avoid NAT Gateway costs

### 2. Elastic IP Management
```hcl
# Reuse existing EIPs to avoid additional charges
existing_eip_ids_az = {
  "us-west-2a" = "eipalloc-12345678901234567"
  "us-west-2b" = "eipalloc-23456789012345678"
}
```

## Monitoring and Troubleshooting

### 1. Enable VPC Flow Logs
```hcl
# Add to your root module
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_raw.id
}
```

### 2. CloudWatch Metrics
- Monitor NAT Gateway bandwidth and connection counts
- Set up alarms for unusual traffic patterns
- Track subnet IP utilization

## Common Pitfalls to Avoid

1. **CIDR Overlap**: Ensure no subnet CIDRs overlap
2. **Missing Routes**: Verify route tables are properly associated
3. **NACL Conflicts**: Remember NACLs are evaluated before Security Groups
4. **AZ Naming**: Use consistent AZ names or IDs across regions
5. **Tag Inheritance**: Ensure proper tag propagation for cost tracking

## Example Configurations

### Production Environment
```hcl
module "vpc" {
  source = "ViktorUJ/vpc/aws"
  
  vpc = {
    name = "prod-vpc"
    cidr = "10.0.0.0/16"
    enable_dns_hostnames = true
  }
  
  subnets = {
    public = {
      "web-1a" = { name = "prod-web-1a", cidr = "10.0.1.0/24", az = "us-west-2a" }
      "web-1b" = { name = "prod-web-1b", cidr = "10.0.2.0/24", az = "us-west-2b" }
    }
    private = {
      "app-1a" = { name = "prod-app-1a", cidr = "10.0.11.0/24", az = "us-west-2a", nat_gateway = "AZ" }
      "app-1b" = { name = "prod-app-1b", cidr = "10.0.12.0/24", az = "us-west-2b", nat_gateway = "AZ" }
      "db-1a"  = { name = "prod-db-1a",  cidr = "10.0.21.0/26", az = "us-west-2a", nat_gateway = "NONE" }
      "db-1b"  = { name = "prod-db-1b",  cidr = "10.0.21.64/26", az = "us-west-2b", nat_gateway = "NONE" }
    }
  }
  
  tags_default = {
    Environment = "production"
    Terraform   = "true"
  }
}
```