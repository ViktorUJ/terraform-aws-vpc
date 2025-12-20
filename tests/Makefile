# Makefile for Documentation Validation Tests

.PHONY: all test terraform-test structure-test link-test clean help install-deps

# Default target
all: test

# Install Python dependencies
install-deps:
	@echo "Installing Python dependencies..."
	@pip install --upgrade pip
	@echo "Dependencies installed successfully"

# Run all tests
test:
	@echo "Running all documentation validation tests..."
	@python run_all_tests.py

# Run individual test suites
terraform-test:
	@echo "Running Terraform syntax validation..."
	@cd .. && python tests/terraform_syntax_validation.py

structure-test:
	@echo "Running documentation structure validation..."
	@cd .. && python tests/documentation_structure_validation.py

link-test:
	@echo "Running link validation..."
	@cd .. && python tests/link_validation.py

# Run link test with external URL checking
link-test-online:
	@echo "Running link validation with external URL checking..."
	@cd .. && CHECK_EXTERNAL_LINKS=true python tests/link_validation.py

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	@rm -f test_results_*.json
	@rm -f test_results_*.html
	@rm -rf __pycache__
	@rm -rf .pytest_cache
	@echo "Cleanup completed"

# Check if required tools are installed
check-deps:
	@echo "Checking dependencies..."
	@python --version || (echo "Python not found" && exit 1)
	@terraform --version || (echo "Terraform not found - some tests may fail" && exit 1)
	@echo "Dependencies check completed"

# Run tests in CI mode (with external link checking)
ci-test:
	@echo "Running tests in CI mode..."
	@CHECK_EXTERNAL_LINKS=true python run_all_tests.py

# Generate test report only
report:
	@echo "Generating test report..."
	@python run_all_tests.py --report-only

# Validate specific file
validate-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make validate-file FILE=path/to/file.md"; \
		exit 1; \
	fi
	@echo "Validating file: $(FILE)"
	@python -c "
import sys
sys.path.append('.')
from documentation_structure_validation import DocumentationStructureValidator
from link_validation import LinkValidator

print('Validating structure...')
struct_validator = DocumentationStructureValidator('$(FILE)')
struct_validator.load_content()
struct_validator.extract_sections()
struct_valid = struct_validator.validate_required_sections()

print('Validating links...')
link_validator = LinkValidator('$(FILE)')
link_validator.load_content()
links = link_validator.extract_all_links()
anchors = link_validator.extract_anchors()
link_valid = link_validator.validate_internal_links(links['internal'], anchors)

if struct_valid and link_valid:
    print('✅ File validation passed')
    sys.exit(0)
else:
    print('❌ File validation failed')
    sys.exit(1)
"

# Help target
help:
	@echo "Available targets:"
	@echo "  all              - Run all tests (default)"
	@echo "  test             - Run all tests"
	@echo "  terraform-test   - Run Terraform syntax validation only"
	@echo "  structure-test   - Run documentation structure validation only"
	@echo "  link-test        - Run link validation only"
	@echo "  link-test-online - Run link validation with external URL checking"
	@echo "  ci-test          - Run tests in CI mode (with external checks)"
	@echo "  install-deps     - Install Python dependencies"
	@echo "  check-deps       - Check if required tools are installed"
	@echo "  clean            - Clean up test artifacts"
	@echo "  validate-file    - Validate specific file (use FILE=path)"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make test                    # Run all tests"
	@echo "  make terraform-test          # Run only Terraform validation"
	@echo "  make link-test-online        # Run link validation with online checks"
	@echo "  make validate-file FILE=README.md  # Validate specific file"