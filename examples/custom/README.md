# Example showcasing custom configurations in the VPC, Subnets, NACL, etc.

This example demonstrates advanced VPC configurations including custom Network ACLs, multiple subnet types, and various NAT Gateway strategies.

## Configuration Highlights

- Custom Network ACL rules for enhanced security
- Multiple subnet types (web, app, database)
- Mixed NAT Gateway strategies
- Custom DHCP options
- Comprehensive tagging strategy

## Production Considerations

For production deployments using similar configurations, refer to the [Production Best Practices Guide](../../PRODUCTION_BEST_PRACTICES.md) for:

- **Security best practices** for Network ACL configuration
- **CIDR planning** strategies for scalable networks
- **Cost optimization** techniques for NAT Gateways
- **Monitoring and observability** setup
- **Compliance requirements** for regulated environments

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Clean Up

```bash
terraform destroy
```
