package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
		Vars: map[string]interface{}{
			// Override any variables here if needed
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test VPC creation
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId)

	// Test subnet creation
	publicSubnets := terraform.OutputMap(t, terraformOptions, "public_subnets_by_type")
	assert.NotEmpty(t, publicSubnets)

	privateSubnets := terraform.OutputMap(t, terraformOptions, "private_subnets_by_type")
	assert.NotEmpty(t, privateSubnets)
}

func TestVPCModuleWithCustomConfig(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/custom",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test that NAT Gateways are created correctly
	natGatewayAZ := terraform.OutputMap(t, terraformOptions, "nat_gateway_az_raw")
	assert.NotEmpty(t, natGatewayAZ)
}