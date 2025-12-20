#!/usr/bin/env python3
"""
Documentation Structure Validation Tests

This script validates that the production best practices documentation
has the correct structure, completeness, and follows documentation standards.

Requirements tested:
- 1.1: Complete table of contents with all required sections
- 1.2: Proper section organization and hierarchy
- 1.3: All required content areas covered
- 2.1-5.5: All requirement areas have corresponding documentation sections
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Set, Tuple


class DocumentationStructureValidator:
    """Validates documentation structure and completeness"""
    
    def __init__(self, doc_path: str):
        self.doc_path = Path(doc_path)
        self.content = ""
        self.errors = []
        self.warnings = []
        self.sections = {}
        
        # Required sections based on requirements
        self.required_sections = {
            "Introduction": {
                "level": 2,
                "required_subsections": ["Prerequisites", "How to Use This Guide"]
            },
            "Security Best Practices": {
                "level": 2,
                "required_subsections": [
                    "Network ACL Configuration",
                    "Private Subnet Isolation", 
                    "VPC Flow Logs",
                    "IAM Policies for Terraform"
                ]
            },
            "Network Architecture Patterns": {
                "level": 2,
                "required_subsections": [
                    "CIDR Planning",
                    "Multi-AZ Deployment Patterns",
                    "NAT Gateway Strategies",
                    "Multi-Environment Patterns"
                ]
            },
            "Cost Optimization": {
                "level": 2,
                "required_subsections": [
                    "Subnet Placement Strategies",
                    "NAT Gateway Cost Analysis"
                ]
            },
            "Monitoring and Observability": {
                "level": 2,
                "required_subsections": [
                    "CloudWatch Configuration",
                    "Troubleshooting Guide"
                ]
            },
            "Operational Considerations": {
                "level": 2,
                "required_subsections": [
                    "Terraform State Management",
                    "Zero-Downtime Deployment",
                    "Disaster Recovery"
                ]
            },
            "Compliance and Governance": {
                "level": 2,
                "required_subsections": [
                    "Resource Naming and Tagging",
                    "Compliance Frameworks",
                    "Audit Logging",
                    "Architecture Documentation Templates"
                ]
            }
        }
        
        # Content quality requirements
        self.min_section_length = 500  # Minimum characters per major section
        self.required_code_examples = 2  # Minimum code examples per major section
        
    def load_content(self):
        """Load documentation content"""
        if not self.doc_path.exists():
            raise FileNotFoundError(f"Documentation file not found: {self.doc_path}")
        
        with open(self.doc_path, 'r', encoding='utf-8') as f:
            self.content = f.read()
    
    def extract_sections(self) -> Dict[str, Dict]:
        """Extract all sections and their hierarchy"""
        
        sections = {}
        lines = self.content.split('\n')
        
        current_section = None
        current_content = []
        
        for i, line in enumerate(lines):
            # Match markdown headers
            header_match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            
            if header_match:
                # Save previous section
                if current_section:
                    sections[current_section]['content'] = '\n'.join(current_content)
                    sections[current_section]['length'] = len('\n'.join(current_content))
                
                # Start new section
                level = len(header_match.group(1))
                title = header_match.group(2).strip()
                
                sections[title] = {
                    'level': level,
                    'line_number': i + 1,
                    'content': '',
                    'length': 0,
                    'subsections': []
                }
                
                current_section = title
                current_content = []
            else:
                if current_section:
                    current_content.append(line)
        
        # Save last section
        if current_section:
            sections[current_section]['content'] = '\n'.join(current_content)
            sections[current_section]['length'] = len('\n'.join(current_content))
        
        # Build subsection relationships
        self._build_section_hierarchy(sections)
        
        self.sections = sections
        return sections
    
    def _build_section_hierarchy(self, sections: Dict[str, Dict]):
        """Build parent-child relationships between sections"""
        
        section_list = list(sections.items())
        
        for i, (title, section) in enumerate(section_list):
            # Find subsections (next level down)
            current_level = section['level']
            
            for j in range(i + 1, len(section_list)):
                next_title, next_section = section_list[j]
                next_level = next_section['level']
                
                # If we hit a section at the same or higher level, stop
                if next_level <= current_level:
                    break
                
                # If it's exactly one level down, it's a direct subsection
                if next_level == current_level + 1:
                    section['subsections'].append(next_title)
    
    def validate_required_sections(self) -> bool:
        """Validate that all required sections are present"""
        
        all_present = True
        
        for section_name, requirements in self.required_sections.items():
            if section_name not in self.sections:
                self.errors.append(f"Missing required section: {section_name}")
                all_present = False
                continue
            
            section = self.sections[section_name]
            
            # Check section level
            expected_level = requirements['level']
            if section['level'] != expected_level:
                self.errors.append(
                    f"Section '{section_name}' has incorrect level {section['level']}, "
                    f"expected {expected_level}"
                )
            
            # Check required subsections
            required_subsections = requirements.get('required_subsections', [])
            missing_subsections = []
            
            for subsection in required_subsections:
                if subsection not in section['subsections']:
                    # Check if subsection exists anywhere in document
                    if subsection not in self.sections:
                        missing_subsections.append(subsection)
            
            if missing_subsections:
                self.errors.append(
                    f"Section '{section_name}' missing required subsections: "
                    f"{', '.join(missing_subsections)}"
                )
                all_present = False
        
        return all_present
    
    def validate_table_of_contents(self) -> bool:
        """Validate table of contents completeness and accuracy"""
        
        # Find table of contents section
        toc_pattern = r'## Table of Contents\n(.*?)(?=\n##|\n#[^#]|$)'
        toc_match = re.search(toc_pattern, self.content, re.DOTALL)
        
        if not toc_match:
            self.errors.append("Table of Contents section not found")
            return False
        
        toc_content = toc_match.group(1)
        
        # Extract TOC entries
        toc_entries = re.findall(r'-\s+\[([^\]]+)\]', toc_content)
        
        # Check if all major sections are in TOC
        missing_from_toc = []
        for section_name in self.required_sections.keys():
            if section_name not in toc_entries:
                missing_from_toc.append(section_name)
        
        if missing_from_toc:
            self.errors.append(
                f"Table of Contents missing entries: {', '.join(missing_from_toc)}"
            )
            return False
        
        # Check for broken TOC links
        broken_links = []
        for entry in toc_entries:
            # Convert to anchor format
            anchor = entry.lower().replace(' ', '-').replace('/', '')
            anchor = re.sub(r'[^a-z0-9\-]', '', anchor)
            
            # Check if corresponding section exists
            if entry not in self.sections:
                broken_links.append(entry)
        
        if broken_links:
            self.warnings.append(
                f"Potential broken TOC links: {', '.join(broken_links)}"
            )
        
        return True
    
    def validate_content_quality(self) -> bool:
        """Validate content quality and completeness"""
        
        quality_issues = []
        
        for section_name, requirements in self.required_sections.items():
            if section_name not in self.sections:
                continue
            
            section = self.sections[section_name]
            content = section['content']
            
            # Check minimum length
            if section['length'] < self.min_section_length:
                quality_issues.append(
                    f"Section '{section_name}' is too short "
                    f"({section['length']} chars, minimum {self.min_section_length})"
                )
            
            # Check for code examples
            code_blocks = len(re.findall(r'```', content))
            code_examples = code_blocks // 2  # Each example has opening and closing ```
            
            if code_examples < self.required_code_examples:
                quality_issues.append(
                    f"Section '{section_name}' has insufficient code examples "
                    f"({code_examples}, minimum {self.required_code_examples})"
                )
            
            # Check for placeholder content
            placeholders = [
                '*Content will be added*',
                'TODO:',
                'TBD',
                '[PLACEHOLDER]',
                'Coming soon'
            ]
            
            for placeholder in placeholders:
                if placeholder in content:
                    quality_issues.append(
                        f"Section '{section_name}' contains placeholder content: {placeholder}"
                    )
        
        if quality_issues:
            self.errors.extend(quality_issues)
            return False
        
        return True
    
    def validate_markdown_syntax(self) -> bool:
        """Validate markdown syntax and formatting"""
        
        syntax_issues = []
        lines = self.content.split('\n')
        
        for i, line in enumerate(lines, 1):
            # Check for malformed headers
            if line.strip().startswith('#'):
                if not re.match(r'^#{1,6}\s+.+$', line.strip()):
                    syntax_issues.append(f"Line {i}: Malformed header - {line.strip()}")
            
            # Check for unmatched code block markers
            if line.strip() == '```' or line.strip().startswith('```'):
                # This is basic - a more thorough check would track opening/closing
                pass
            
            # Check for broken internal links
            internal_links = re.findall(r'\[([^\]]+)\]\(#([^)]+)\)', line)
            for link_text, anchor in internal_links:
                # Convert anchor to section name format
                section_name = anchor.replace('-', ' ').title()
                if section_name not in self.sections:
                    syntax_issues.append(
                        f"Line {i}: Broken internal link to #{anchor}"
                    )
        
        # Check for unmatched code blocks
        code_block_count = self.content.count('```')
        if code_block_count % 2 != 0:
            syntax_issues.append("Unmatched code block markers (```)")
        
        if syntax_issues:
            self.errors.extend(syntax_issues)
            return False
        
        return True
    
    def validate_mermaid_diagrams(self) -> bool:
        """Validate Mermaid diagram syntax"""
        
        # Extract Mermaid diagrams
        mermaid_pattern = r'```mermaid\n(.*?)\n```'
        diagrams = re.findall(mermaid_pattern, self.content, re.DOTALL)
        
        diagram_issues = []
        
        for i, diagram in enumerate(diagrams, 1):
            # Basic Mermaid syntax validation
            lines = diagram.strip().split('\n')
            
            if not lines:
                diagram_issues.append(f"Mermaid diagram {i}: Empty diagram")
                continue
            
            first_line = lines[0].strip()
            
            # Check for valid diagram type
            valid_types = ['graph', 'flowchart', 'sequenceDiagram', 'classDiagram', 'gitgraph']
            if not any(first_line.startswith(t) for t in valid_types):
                diagram_issues.append(f"Mermaid diagram {i}: Invalid or missing diagram type")
            
            # Check for basic syntax issues
            for line in lines[1:]:
                line = line.strip()
                if not line:
                    continue
                
                # Check for unmatched brackets/quotes
                if line.count('[') != line.count(']'):
                    diagram_issues.append(f"Mermaid diagram {i}: Unmatched brackets in: {line}")
                
                if line.count('"') % 2 != 0:
                    diagram_issues.append(f"Mermaid diagram {i}: Unmatched quotes in: {line}")
        
        if diagram_issues:
            self.warnings.extend(diagram_issues)
            return False
        
        return True
    
    def validate_cross_references(self) -> bool:
        """Validate cross-references between sections"""
        
        # Find all internal references
        ref_pattern = r'see\s+(?:section\s+)?["\']?([^"\'.,\n]+)["\']?'
        references = re.findall(ref_pattern, self.content, re.IGNORECASE)
        
        broken_refs = []
        
        for ref in references:
            ref_clean = ref.strip()
            
            # Check if referenced section exists
            if ref_clean not in self.sections:
                # Try fuzzy matching
                fuzzy_matches = [s for s in self.sections.keys() 
                               if ref_clean.lower() in s.lower()]
                
                if not fuzzy_matches:
                    broken_refs.append(ref_clean)
        
        if broken_refs:
            self.warnings.extend([f"Potential broken reference: {ref}" for ref in broken_refs])
        
        return len(broken_refs) == 0
    
    def generate_report(self) -> Dict[str, any]:
        """Generate comprehensive validation report"""
        
        return {
            'total_sections': len(self.sections),
            'required_sections': len(self.required_sections),
            'total_errors': len(self.errors),
            'total_warnings': len(self.warnings),
            'errors': self.errors,
            'warnings': self.warnings,
            'status': 'PASS' if len(self.errors) == 0 else 'FAIL',
            'sections_found': list(self.sections.keys()),
            'missing_sections': [
                name for name in self.required_sections.keys() 
                if name not in self.sections
            ]
        }


def main():
    """Main function to run all structure validation tests"""
    
    doc_path = 'PRODUCTION_BEST_PRACTICES.md'
    
    if not os.path.exists(doc_path):
        print(f"Error: Documentation file not found: {doc_path}")
        return 1
    
    print("Starting documentation structure validation...")
    print("=" * 50)
    
    validator = DocumentationStructureValidator(doc_path)
    
    try:
        # Load content and extract sections
        validator.load_content()
        sections = validator.extract_sections()
        
        print(f"Found {len(sections)} sections in documentation")
        
        # Run all validation tests
        tests = [
            ("Required Sections", validator.validate_required_sections),
            ("Table of Contents", validator.validate_table_of_contents),
            ("Content Quality", validator.validate_content_quality),
            ("Markdown Syntax", validator.validate_markdown_syntax),
            ("Mermaid Diagrams", validator.validate_mermaid_diagrams),
            ("Cross References", validator.validate_cross_references)
        ]
        
        results = {}
        for test_name, test_func in tests:
            print(f"Running {test_name} validation...")
            results[test_name] = test_func()
        
        # Generate report
        report = validator.generate_report()
        
        # Print results
        print("\nValidation Results:")
        print("=" * 50)
        print(f"Status: {report['status']}")
        print(f"Total Sections: {report['total_sections']}")
        print(f"Required Sections: {report['required_sections']}")
        print(f"Total Errors: {report['total_errors']}")
        print(f"Total Warnings: {report['total_warnings']}")
        
        # Print test results
        print("\nTest Results:")
        for test_name, result in results.items():
            status = "✅ PASS" if result else "❌ FAIL"
            print(f"  {test_name}: {status}")
        
        if report['errors']:
            print("\nErrors:")
            for error in report['errors']:
                print(f"  ❌ {error}")
        
        if report['warnings']:
            print("\nWarnings:")
            for warning in report['warnings']:
                print(f"  ⚠️  {warning}")
        
        if report['missing_sections']:
            print(f"\nMissing Required Sections:")
            for section in report['missing_sections']:
                print(f"  📝 {section}")
        
        if report['status'] == 'PASS':
            print("\n✅ All structure validation tests passed!")
            return 0
        else:
            print("\n❌ Structure validation tests failed!")
            return 1
            
    except Exception as e:
        print(f"Error during validation: {str(e)}")
        return 1


if __name__ == '__main__':
    exit(main())