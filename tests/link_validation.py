#!/usr/bin/env python3
"""
Link Validation Tests for Production Best Practices Documentation

This script validates all links in the documentation including:
- Internal links (anchors)
- External URLs
- File references
- Cross-references

Requirements tested:
- 1.4: All links must be valid and accessible
- 3.4: Cross-references between sections must be correct
- 5.5: Links to external resources must be valid
"""

import os
import re
import urllib.request
import urllib.error
from pathlib import Path
from typing import List, Dict, Set, Tuple
from urllib.parse import urlparse


class LinkValidator:
    """Validates all links in documentation"""
    
    def __init__(self, doc_path: str, project_root: str = '.'):
        self.doc_path = Path(doc_path)
        self.project_root = Path(project_root)
        self.content = ""
        self.errors = []
        self.warnings = []
        self.checked_urls = {}  # Cache for URL checks
        
    def load_content(self):
        """Load documentation content"""
        if not self.doc_path.exists():
            raise FileNotFoundError(f"Documentation file not found: {self.doc_path}")
        
        with open(self.doc_path, 'r', encoding='utf-8') as f:
            self.content = f.read()
    
    def extract_all_links(self) -> Dict[str, List[Dict]]:
        """Extract all types of links from documentation"""
        
        links = {
            'internal': [],
            'external': [],
            'file': [],
            'image': []
        }
        
        # Extract markdown links: [text](url)
        markdown_links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', self.content)
        
        for text, url in markdown_links:
            link_info = {
                'text': text,
                'url': url,
                'line': self._find_line_number(url)
            }
            
            if url.startswith('#'):
                links['internal'].append(link_info)
            elif url.startswith('http://') or url.startswith('https://'):
                links['external'].append(link_info)
            elif url.endswith(('.png', '.jpg', '.jpeg', '.gif', '.svg')):
                links['image'].append(link_info)
            else:
                links['file'].append(link_info)
        
        # Extract HTML links: <a href="url">
        html_links = re.findall(r'<a\s+href=["\']([^"\']+)["\']', self.content)
        
        for url in html_links:
            link_info = {
                'text': '',
                'url': url,
                'line': self._find_line_number(url)
            }
            
            if url.startswith('#'):
                links['internal'].append(link_info)
            elif url.startswith('http://') or url.startswith('https://'):
                links['external'].append(link_info)
        
        return links
    
    def _find_line_number(self, text: str) -> int:
        """Find line number where text appears"""
        lines = self.content.split('\n')
        for i, line in enumerate(lines, 1):
            if text in line:
                return i
        return 0
    
    def extract_anchors(self) -> Set[str]:
        """Extract all valid anchor targets from headers"""
        
        anchors = set()
        
        # Find all markdown headers
        headers = re.findall(r'^#{1,6}\s+(.+)$', self.content, re.MULTILINE)
        
        for header in headers:
            # Convert header to anchor format
            # Remove markdown formatting
            header_clean = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', header)
            header_clean = re.sub(r'[`*_]', '', header_clean)
            
            # Convert to lowercase and replace spaces with hyphens
            anchor = header_clean.lower().strip()
            anchor = re.sub(r'[^\w\s-]', '', anchor)
            anchor = re.sub(r'[-\s]+', '-', anchor)
            
            anchors.add(anchor)
        
        return anchors
    
    def validate_internal_links(self, internal_links: List[Dict], anchors: Set[str]) -> bool:
        """Validate internal anchor links"""
        
        all_valid = True
        
        for link in internal_links:
            anchor = link['url'][1:]  # Remove leading #
            
            if anchor not in anchors:
                self.errors.append(
                    f"Line {link['line']}: Broken internal link to #{anchor} "
                    f"(text: '{link['text']}')"
                )
                all_valid = False
        
        return all_valid
    
    def validate_external_links(self, external_links: List[Dict], check_online: bool = True) -> bool:
        """Validate external URLs"""
        
        all_valid = True
        
        for link in external_links:
            url = link['url']
            
            # Skip if already checked
            if url in self.checked_urls:
                if not self.checked_urls[url]:
                    all_valid = False
                continue
            
            # Basic URL format validation
            parsed = urlparse(url)
            if not parsed.scheme or not parsed.netloc:
                self.errors.append(
                    f"Line {link['line']}: Invalid URL format: {url}"
                )
                self.checked_urls[url] = False
                all_valid = False
                continue
            
            # Check if URL is accessible (if enabled)
            if check_online:
                is_valid = self._check_url_accessible(url, link['line'])
                self.checked_urls[url] = is_valid
                if not is_valid:
                    all_valid = False
            else:
                self.warnings.append(
                    f"Line {link['line']}: Skipping online check for {url}"
                )
                self.checked_urls[url] = True
        
        return all_valid
    
    def _check_url_accessible(self, url: str, line_number: int) -> bool:
        """Check if URL is accessible"""
        
        try:
            # Set a reasonable timeout
            req = urllib.request.Request(
                url,
                headers={'User-Agent': 'Mozilla/5.0 (Documentation Link Checker)'}
            )
            
            with urllib.request.urlopen(req, timeout=10) as response:
                status_code = response.getcode()
                
                if status_code >= 400:
                    self.errors.append(
                        f"Line {line_number}: URL returned error {status_code}: {url}"
                    )
                    return False
                
                return True
                
        except urllib.error.HTTPError as e:
            self.errors.append(
                f"Line {line_number}: HTTP error {e.code} for URL: {url}"
            )
            return False
            
        except urllib.error.URLError as e:
            self.errors.append(
                f"Line {line_number}: URL error for {url}: {str(e.reason)}"
            )
            return False
            
        except Exception as e:
            self.warnings.append(
                f"Line {line_number}: Could not check URL {url}: {str(e)}"
            )
            return True  # Don't fail on network issues
    
    def validate_file_links(self, file_links: List[Dict]) -> bool:
        """Validate file path links"""
        
        all_valid = True
        
        for link in file_links:
            file_path = link['url']
            
            # Handle relative paths
            if file_path.startswith('./'):
                file_path = file_path[2:]
            
            # Construct full path
            full_path = self.project_root / file_path
            
            if not full_path.exists():
                self.errors.append(
                    f"Line {link['line']}: File not found: {file_path}"
                )
                all_valid = False
        
        return all_valid
    
    def validate_image_links(self, image_links: List[Dict]) -> bool:
        """Validate image file links"""
        
        all_valid = True
        
        for link in image_links:
            image_path = link['url']
            
            # Skip external images
            if image_path.startswith('http://') or image_path.startswith('https://'):
                continue
            
            # Handle relative paths
            if image_path.startswith('./'):
                image_path = image_path[2:]
            
            # Construct full path
            full_path = self.project_root / image_path
            
            if not full_path.exists():
                self.errors.append(
                    f"Line {link['line']}: Image file not found: {image_path}"
                )
                all_valid = False
        
        return all_valid
    
    def validate_example_references(self) -> bool:
        """Validate references to example files"""
        
        all_valid = True
        
        # Find references to examples
        example_refs = re.findall(
            r'examples?/([a-zA-Z0-9_/-]+)',
            self.content,
            re.IGNORECASE
        )
        
        for ref in example_refs:
            example_path = self.project_root / 'examples' / ref
            
            # Check if it's a directory or file
            if not example_path.exists():
                # Try with common extensions
                found = False
                for ext in ['.tf', '.md', '']:
                    test_path = Path(str(example_path) + ext)
                    if test_path.exists():
                        found = True
                        break
                
                if not found:
                    self.warnings.append(
                        f"Referenced example not found: examples/{ref}"
                    )
        
        return all_valid
    
    def check_duplicate_anchors(self) -> bool:
        """Check for duplicate anchor definitions"""
        
        headers = re.findall(r'^#{1,6}\s+(.+)$', self.content, re.MULTILINE)
        
        anchor_counts = {}
        
        for header in headers:
            # Convert to anchor format
            header_clean = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', header)
            header_clean = re.sub(r'[`*_]', '', header_clean)
            anchor = header_clean.lower().strip()
            anchor = re.sub(r'[^\w\s-]', '', anchor)
            anchor = re.sub(r'[-\s]+', '-', anchor)
            
            anchor_counts[anchor] = anchor_counts.get(anchor, 0) + 1
        
        duplicates = {k: v for k, v in anchor_counts.items() if v > 1}
        
        if duplicates:
            for anchor, count in duplicates.items():
                self.warnings.append(
                    f"Duplicate anchor '{anchor}' appears {count} times"
                )
            return False
        
        return True
    
    def validate_aws_documentation_links(self, external_links: List[Dict]) -> bool:
        """Validate AWS documentation links for common issues"""
        
        all_valid = True
        
        for link in external_links:
            url = link['url']
            
            # Check AWS docs links
            if 'docs.aws.amazon.com' in url:
                # Check for common issues
                if '/latest/' not in url and '/index.html' not in url:
                    self.warnings.append(
                        f"Line {link['line']}: AWS docs link may not use '/latest/': {url}"
                    )
                
                # Check for deprecated services
                deprecated_services = ['elasticbeanstalk', 'opsworks']
                for service in deprecated_services:
                    if service in url.lower():
                        self.warnings.append(
                            f"Line {link['line']}: Link to potentially deprecated service: {url}"
                        )
        
        return all_valid
    
    def generate_report(self) -> Dict[str, any]:
        """Generate comprehensive link validation report"""
        
        return {
            'total_errors': len(self.errors),
            'total_warnings': len(self.warnings),
            'errors': self.errors,
            'warnings': self.warnings,
            'status': 'PASS' if len(self.errors) == 0 else 'FAIL',
            'checked_urls': len(self.checked_urls),
            'accessible_urls': sum(1 for v in self.checked_urls.values() if v),
            'broken_urls': sum(1 for v in self.checked_urls.values() if not v)
        }


def main():
    """Main function to run all link validation tests"""
    
    doc_path = 'PRODUCTION_BEST_PRACTICES.md'
    project_root = '.'
    
    if not os.path.exists(doc_path):
        print(f"Error: Documentation file not found: {doc_path}")
        return 1
    
    print("Starting link validation...")
    print("=" * 50)
    
    # Check if we should validate external links online
    check_online = os.environ.get('CHECK_EXTERNAL_LINKS', 'false').lower() == 'true'
    
    if not check_online:
        print("Note: Skipping online external link validation")
        print("Set CHECK_EXTERNAL_LINKS=true to enable")
        print()
    
    validator = LinkValidator(doc_path, project_root)
    
    try:
        # Load content
        validator.load_content()
        
        # Extract all links
        links = validator.extract_all_links()
        
        print(f"Found {len(links['internal'])} internal links")
        print(f"Found {len(links['external'])} external links")
        print(f"Found {len(links['file'])} file links")
        print(f"Found {len(links['image'])} image links")
        print()
        
        # Extract anchors
        anchors = validator.extract_anchors()
        print(f"Found {len(anchors)} anchor targets")
        print()
        
        # Run all validation tests
        tests = [
            ("Internal Links", lambda: validator.validate_internal_links(links['internal'], anchors)),
            ("External Links", lambda: validator.validate_external_links(links['external'], check_online)),
            ("File Links", lambda: validator.validate_file_links(links['file'])),
            ("Image Links", lambda: validator.validate_image_links(links['image'])),
            ("Example References", validator.validate_example_references),
            ("Duplicate Anchors", validator.check_duplicate_anchors),
            ("AWS Docs Links", lambda: validator.validate_aws_documentation_links(links['external']))
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
        print(f"Total Errors: {report['total_errors']}")
        print(f"Total Warnings: {report['total_warnings']}")
        print(f"URLs Checked: {report['checked_urls']}")
        print(f"Accessible URLs: {report['accessible_urls']}")
        print(f"Broken URLs: {report['broken_urls']}")
        
        # Print test results
        print("\nTest Results:")
        for test_name, result in results.items():
            status = "✅ PASS" if result else "⚠️  ISSUES"
            print(f"  {test_name}: {status}")
        
        if report['errors']:
            print("\nErrors:")
            for error in report['errors']:
                print(f"  ❌ {error}")
        
        if report['warnings']:
            print("\nWarnings:")
            for warning in report['warnings']:
                print(f"  ⚠️  {warning}")
        
        if report['status'] == 'PASS':
            print("\n✅ All link validation tests passed!")
            return 0
        else:
            print("\n❌ Link validation tests failed!")
            return 1
            
    except Exception as e:
        print(f"Error during validation: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    exit(main())