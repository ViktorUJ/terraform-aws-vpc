# Documentation Validation Tests

This directory contains comprehensive validation tests for the Production Best Practices documentation. The tests ensure that the documentation is complete, accurate, and follows best practices.

## Test Suites

### 1. Terraform Syntax Validation (`terraform_syntax_validation.py`)

Validates all Terraform code examples in the documentation:

- **Syntax Validation**: Ensures all HCL code is syntactically correct
- **Best Practices**: Checks for common Terraform best practices
- **JSON Validation**: Validates JSON blocks (IAM policies, etc.)
- **Bash Validation**: Basic validation of bash script examples

**Requirements Tested:**
- 1.4: All code examples must be syntactically correct
- 2.1: Security configurations must be valid
- 2.5: IAM policies must be properly formatted
- 4.1: Monitoring configurations must be valid

### 2. Documentation Structure Validation (`documentation_structure_validation.py`)

Validates the overall structure and completeness of the documentation:

- **Required Sections**: Ensures all mandatory sections are present
- **Table of Contents**: Validates TOC completeness and accuracy
- **Content Quality**: Checks for minimum content length and code examples
- **Markdown Syntax**: Validates markdown formatting
- **Mermaid Diagrams**: Basic validation of Mermaid diagram syntax
- **Cross References**: Validates internal cross-references

**Requirements Tested:**
- 1.1: Complete table of contents with all required sections
- 1.2: Proper section organization and hierarchy
- 1.3: All required content areas covered
- 2.1-5.5: All requirement areas have corresponding documentation sections

### 3. Link Validation (`link_validation.py`)

Validates all links in the documentation:

- **Internal Links**: Validates anchor links within the document
- **External URLs**: Checks external URL accessibility (optional)
- **File References**: Validates references to local files
- **Image Links**: Validates image file references
- **Example References**: Validates references to example files
- **AWS Documentation**: Special validation for AWS docs links

**Requirements Tested:**
- 1.4: All links must be valid and accessible
- 3.4: Cross-references between sections must be correct
- 5.5: Links to external resources must be valid

## Running Tests

### Prerequisites

1. **Python 3.7+**: Required for running the test scripts
2. **Terraform CLI**: Required for Terraform syntax validation
3. **Internet Connection**: Optional, for external link validation

### Quick Start

```bash
# Run all tests
make test

# Or run the test runner directly
python tests/run_all_tests.py
```

### Individual Test Suites

```bash
# Run specific test suites
make terraform-test    # Terraform syntax validation
make structure-test    # Documentation structure validation
make link-test         # Link validation (offline)
make link-test-online  # Link validation with external URL checking
```

### Advanced Usage

```bash
# Run tests with external link checking (CI mode)
make ci-test

# Validate a specific file
make validate-file FILE=path/to/document.md

# Check dependencies
make check-deps

# Clean up test artifacts
make clean
```

## Test Configuration

### Environment Variables

- `CHECK_EXTERNAL_LINKS`: Set to `true` to enable external URL validation
  ```bash
  CHECK_EXTERNAL_LINKS=true python tests/link_validation.py
  ```

### Test Customization

You can customize test behavior by modifying the test scripts:

#### Terraform Validation
- Modify `_add_required_providers()` to change provider requirements
- Update `_validate_best_practices()` to add custom validation rules
- Adjust timeout values for slow systems

#### Structure Validation
- Update `required_sections` to change required documentation sections
- Modify `min_section_length` and `required_code_examples` for content quality
- Add custom validation rules in `validate_content_quality()`

#### Link Validation
- Modify URL timeout in `_check_url_accessible()`
- Add custom link validation rules
- Update file extension checks for different file types

## Test Reports

Tests generate comprehensive reports in multiple formats:

### JSON Report
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "summary": {
    "total_tests": 3,
    "passed_tests": 3,
    "failed_tests": 0,
    "success_rate": 100.0
  },
  "results": [...]
}
```

### HTML Report
Interactive HTML report with:
- Test summary statistics
- Detailed results for each test suite
- Error and warning details
- Expandable output sections

## Continuous Integration

### GitHub Actions Example

```yaml
name: Documentation Validation

on: [push, pull_request]

jobs:
  validate-docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.6.0
    
    - name: Install dependencies
      run: make install-deps
      working-directory: tests
    
    - name: Run tests
      run: make ci-test
      working-directory: tests
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: test_results_*.html
```

### GitLab CI Example

```yaml
validate-documentation:
  stage: test
  image: python:3.9
  before_script:
    - apt-get update && apt-get install -y wget unzip
    - wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
    - unzip terraform_1.6.0_linux_amd64.zip && mv terraform /usr/local/bin/
    - cd tests && make install-deps
  script:
    - cd tests && make ci-test
  artifacts:
    when: always
    paths:
      - test_results_*.html
    expire_in: 1 week
```

## Troubleshooting

### Common Issues

#### Terraform Not Found
```
Error: Terraform CLI not found. Please install Terraform.
```
**Solution**: Install Terraform CLI from https://terraform.io/downloads

#### Network Timeouts
```
Warning: Could not check URL https://example.com: timeout
```
**Solution**: 
- Check internet connection
- Increase timeout in `_check_url_accessible()`
- Run without external link checking: `make link-test`

#### Missing Dependencies
```
ModuleNotFoundError: No module named 'xyz'
```
**Solution**: Run `make install-deps` to install required packages

#### Permission Errors
```
PermissionError: [Errno 13] Permission denied
```
**Solution**: Ensure proper file permissions or run with appropriate privileges

### Debug Mode

Enable verbose output for debugging:

```bash
# Add debug prints to test scripts
export DEBUG=true
python tests/terraform_syntax_validation.py
```

### Test Development

To add new tests:

1. Create a new test script in the `tests/` directory
2. Follow the existing pattern for error/warning collection
3. Add the test to `run_all_tests.py`
4. Update the Makefile with a new target
5. Document the test in this README

## Best Practices

### Writing Tests
- Use descriptive error messages with line numbers
- Separate errors (must fix) from warnings (should fix)
- Provide actionable feedback
- Handle edge cases gracefully
- Include timeout handling for network operations

### Maintaining Tests
- Keep tests up to date with documentation changes
- Review test coverage regularly
- Update validation rules as requirements evolve
- Monitor test performance and optimize as needed

### CI Integration
- Run tests on every commit
- Fail builds on test failures
- Generate and archive test reports
- Set up notifications for test failures
- Use caching to improve CI performance

## Contributing

When contributing to the test suite:

1. Follow existing code style and patterns
2. Add appropriate error handling
3. Include comprehensive test coverage
4. Update documentation
5. Test your changes thoroughly
6. Consider backward compatibility

## Support

For issues with the test suite:

1. Check this README for common solutions
2. Review test output for specific error messages
3. Check the project's main documentation
4. Open an issue with detailed error information