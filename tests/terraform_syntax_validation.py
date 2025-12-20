#!/usr/bin/env python3
"""
Terraform Syntax Validation Tests for Production Best Practices Documentation

This script validates that all Terraform code examples in the documentation
are syntactically correct and follow best practices.

Requirements tested:
- 1.4: All code examples must be syntactically correct
- 2.1: Security configurations must be valid
- 2.5: IAM policies must be properly formatted
- 4.1: Monitoring configurations must be valid
"""

import os
import re
import json
import subprocess
import tempfile
from pathlib import Path
from typing import List, Dict, Tuple


class TerraformValidator:
    """Validates Terraform code examples from documentation"""
    
    def __init__(self, doc_path: str):
        self.doc_path = Path(doc_path)
        self.errors = []
        self.warnings = []
        
    def extract_terraform_blocks(self) -> List[Dict[str, str]]:
        """Extract all Terraform code blocks from the documentation"""
        
        if not self.doc_path.exists():
            raise FileNotFoundError(f"Documentation file not found: {self.doc_path}")
        
        with open(self.doc_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match Terraform code blocks
        pattern = r'```hcl\n(.*?)\n```'
        matches = re.findall(pattern, content, re.DOTALL)
        
        terraform_blocks = []
        for i, match in enumerate(matches):
            terraform_blocks.append({
                'id': f'block_{i+1}',
                'content': match.strip(),
                'line_number': self._find_line_number(content, match)
            })
        
        return terraform_blocks
    
    def _find_line_number(self, content: str, block_content: str) -> int:
        """Find the approximate line number of a code block"""
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if block_content[:50] in content[content.find(line):content.find(line) + 1000]:
                return i + 1
        return 0
    
    def validate_syntax(self, terraform_blocks: List[Dict[str, str]]) -> bool:
        """Validate Terraform syntax for all blocks"""
        
        all_valid = True
        
        for block in terraform_blocks:
            try:
                is_valid = self._validate_single_block(block)
                if not is_valid:
                    all_valid = False
            except Exception as e:
                self.errors.append(f"Error validating block {block['id']}: {str(e)}")
                all_valid = False
        
        return all_valid
    
    def _validate_single_block(self, block: Dict[str, str]) -> bool:
        """Validate a single Terraform code block"""
        
        content = block['content']
        block_id = block['id']
        
        # Skip blocks that are just comments or incomplete examples
        if self._is_incomplete_example(content):
            self.warnings.append(f"Block {block_id}: Skipping incomplete example")
            return True
        
        # Create temporary directory and file
        with tempfile.TemporaryDirectory() as temp_dir:
            tf_file = Path(temp_dir) / 'main.tf'
            
            # Add required providers if not present
            full_content = self._add_required_providers(content)
            
            with open(tf_file, 'w') as f:
                f.write(full_content)
            
            # Run terraform validate
            try:
                # Initialize terraform
                init_result = subprocess.run(
                    ['terraform', 'init'],
                    cwd=temp_dir,
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                
                if init_result.returncode != 0:
                    self.errors.append(f"Block {block_id}: Terraform init failed - {init_result.stderr}")
                    return False
                
                # Validate terraform
                validate_result = subprocess.run(
                    ['terraform', 'validate'],
                    cwd=temp_dir,
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                
                if validate_result.returncode != 0:
                    self.errors.append(f"Block {block_id}: Terraform validation failed - {validate_result.stderr}")
                    return False
                
                # Additional custom validations
                self._validate_best_practices(content, block_id)
                
                return True
                
            except subprocess.TimeoutExpired:
                self.errors.append(f"Block {block_id}: Terraform validation timed out")
                return False
            except FileNotFoundError:
                self.errors.append("Terraform CLI not found. Please install Terraform.")
                return False
    
    def _is_incomplete_example(self, content: str) -> bool:
        """Check if the code block is an incomplete example"""
        
        incomplete_indicators = [
            '# ...',
            '...',
            '# Configuration continues',
            '# Add more configuration',
            '# Example continues',
            'ACCOUNT-ID',
            'your-bucket-name',
            'your-key-name'
        ]
        
        for indicator in incomplete_indicators:
            if indicator in content:
                return True
        
        # Check if it's just a snippet without resource definitions
        if not re.search(r'(resource|module|data)\s+"', content):
            return True
        
        return False
    
    def _add_required_providers(self, content: str) -> str:
        """Add required provider configuration if not present"""
        
        # Check if providers are already defined
        if 'terraform {' in content or 'provider "aws"' in content:
            return content
        
        # Add basic provider configuration
        provider_config = '''
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Mock data sources for validation
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

'''
        
        return provider_config + content
    
    def _validate_best_practices(self, content: str, block_id: str):
        """Validate Terraform best practices"""
        
        # Check for hardcoded values
        hardcoded_patterns = [
            r'ami-[a-f0-9]{8,}',  # AMI IDs
            r'\d{12}',  # Account IDs (12 digits)
            r'AKIA[A-Z0-9]{16}',  # AWS Access Keys
        ]
        
        for pattern in hardcoded_patterns:
            if re.search(pattern, content):
                self.warnings.append(f"Block {block_id}: Contains potentially hardcoded values")
        
        # Check for missing tags
        if 'resource "aws_' in content and 'tags' not in content:
            self.warnings.append(f"Block {block_id}: AWS resource without tags")
        
        # Check for security best practices
        if 'cidr_blocks = ["0.0.0.0/0"]' in content and 'ingress' in content:
            self.warnings.append(f"Block {block_id}: Overly permissive security group rule")
    
    def validate_json_blocks(self) -> bool:
        """Validate JSON code blocks (for IAM policies, etc.)"""
        
        with open(self.doc_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match JSON code blocks
        pattern = r'```json\n(.*?)\n```'
        matches = re.findall(pattern, content, re.DOTALL)
        
        all_valid = True
        
        for i, match in enumerate(matches):
            try:
                json.loads(match.strip())
            except json.JSONDecodeError as e:
                self.errors.append(f"JSON block {i+1}: Invalid JSON - {str(e)}")
                all_valid = False
        
        return all_valid
    
    def validate_bash_blocks(self) -> bool:
        """Validate bash code blocks for basic syntax"""
        
        with open(self.doc_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match bash code blocks
        pattern = r'```bash\n(.*?)\n```'
        matches = re.findall(pattern, content, re.DOTALL)
        
        all_valid = True
        
        for i, match in enumerate(matches):
            # Basic bash syntax validation
            if self._validate_bash_syntax(match.strip()):
                continue
            else:
                self.errors.append(f"Bash block {i+1}: Potential syntax issues")
                all_valid = False
        
        return all_valid
    
    def _validate_bash_syntax(self, bash_content: str) -> bool:
        """Basic bash syntax validation"""
        
        # Check for common syntax errors
        lines = bash_content.split('\n')
        
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            # Check for unmatched quotes
            single_quotes = line.count("'") - line.count("\\'")
            double_quotes = line.count('"') - line.count('\\"')
            
            if single_quotes % 2 != 0 or double_quotes % 2 != 0:
                return False
        
        return True
    
    def generate_report(self) -> Dict[str, any]:
        """Generate validation report"""
        
        return {
            'total_errors': len(self.errors),
            'total_warnings': len(self.warnings),
            'errors': self.errors,
            'warnings': self.warnings,
            'status': 'PASS' if len(self.errors) == 0 else 'FAIL'
        }


def main():
    """Main function to run all validation tests"""
    
    # Path to the documentation file
    doc_path = 'PRODUCTION_BEST_PRACTICES.md'
    
    if not os.path.exists(doc_path):
        print(f"Error: Documentation file not found: {doc_path}")
        return 1
    
    print("Starting Terraform syntax validation...")
    print("=" * 50)
    
    validator = TerraformValidator(doc_path)
    
    # Extract and validate Terraform blocks
    try:
        terraform_blocks = validator.extract_terraform_blocks()
        print(f"Found {len(terraform_blocks)} Terraform code blocks")
        
        # Validate Terraform syntax
        tf_valid = validator.validate_syntax(terraform_blocks)
        
        # Validate JSON blocks
        json_valid = validator.validate_json_blocks()
        
        # Validate bash blocks
        bash_valid = validator.validate_bash_blocks()
        
        # Generate report
        report = validator.generate_report()
        
        # Print results
        print("\nValidation Results:")
        print("=" * 50)
        print(f"Status: {report['status']}")
        print(f"Total Errors: {report['total_errors']}")
        print(f"Total Warnings: {report['total_warnings']}")
        
        if report['errors']:
            print("\nErrors:")
            for error in report['errors']:
                print(f"  ❌ {error}")
        
        if report['warnings']:
            print("\nWarnings:")
            for warning in report['warnings']:
                print(f"  ⚠️  {warning}")
        
        if report['status'] == 'PASS':
            print("\n✅ All validation tests passed!")
            return 0
        else:
            print("\n❌ Validation tests failed!")
            return 1
            
    except Exception as e:
        print(f"Error during validation: {str(e)}")
        return 1


if __name__ == '__main__':
    exit(main())