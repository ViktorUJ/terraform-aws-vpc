# This is the main entry point for the VPC module
# The actual VPC resources are defined in vpc.tf
# This file serves as documentation for the module structure

# Module structure:
# - vpc.tf: VPC, Internet Gateway, DHCP options
# - subnets_private.tf: Private subnets and NAT Gateways
# - subnets_pub.tf: Public subnets and routing
# - locals.tf: Local variables and data transformations
# - variables.tf: Input variables
# - outputs.tf: Output values
# - data.tf: Data sources
# - versions.tf: Provider requirements