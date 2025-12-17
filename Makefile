# Variables
VENV_PATH := .venv
VENV_BIN_PATH := $(VENV_PATH)/bin
TERRAFORM_VERSION := 1.6.0
EXAMPLES_DIR := examples

# Default target
.DEFAULT_GOAL := help

# Help target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development setup
venv: ## Create Python virtual environment
	virtualenv -p python3 -q $(VENV_PATH)
	$(VENV_BIN_PATH)/pip install --default-timeout 60 -r .hooks/requirements.txt
	@echo 'Virtualenv created'

install_git_hooks: venv ## Install pre-commit hooks
	$(VENV_BIN_PATH)/pre-commit install
	@echo 'Pre-commit hooks installed'

dev: venv install_git_hooks ## Setup development environment

# Linting and validation
lint: ## Run pre-commit hooks on all files
	pre-commit run --all-files -c .hooks/.pre-commit-config.yaml

fmt: ## Format Terraform files
	terraform fmt -recursive

validate: ## Validate Terraform configuration
	terraform init -backend=false
	terraform validate

# Testing
test-examples: ## Test all examples
	@for example in $(shell ls $(EXAMPLES_DIR)); do \
		echo "Testing example: $$example"; \
		cd $(EXAMPLES_DIR)/$$example && \
		terraform init -backend=false && \
		terraform validate && \
		terraform plan -out=tfplan && \
		rm -f tfplan && \
		cd ../..; \
	done

test-example: ## Test specific example (usage: make test-example EXAMPLE=simple)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "Please specify EXAMPLE variable (e.g., make test-example EXAMPLE=simple)"; \
		exit 1; \
	fi
	cd $(EXAMPLES_DIR)/$(EXAMPLE) && \
	terraform init -backend=false && \
	terraform validate && \
	terraform plan

# Documentation
docs: ## Generate documentation
	terraform-docs markdown table --output-file README.md .

# Security
security: ## Run security checks
	checkov -d . --framework terraform

# Cleanup
clean: ## Clean up temporary files and virtual environment
	@rm -fr $(VENV_PATH)
	@find . -name "*.tfplan" -delete
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -delete
	@echo 'Cleanup completed'

# CI/CD helpers
ci-validate: fmt validate lint security ## Run all CI validation steps
	@echo 'All CI validation steps completed successfully'

# Release helpers
check-version: ## Check if Terraform version matches required version
	@terraform version | grep "Terraform v$(TERRAFORM_VERSION)" || \
	(echo "Terraform version $(TERRAFORM_VERSION) required" && exit 1)

.PHONY: help venv install_git_hooks dev lint fmt validate test-examples test-example docs security clean ci-validate check-version
