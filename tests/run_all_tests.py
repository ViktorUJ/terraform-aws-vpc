#!/usr/bin/env python3
"""
Test Runner for Production Best Practices Documentation

This script runs all validation tests for the documentation and generates
a comprehensive report.
"""

import os
import sys
import subprocess
import json
from datetime import datetime
from pathlib import Path


def run_test(test_script: str, test_name: str) -> dict:
    """Run a single test script and capture results"""
    
    print(f"\n{'='*60}")
    print(f"Running {test_name}")
    print(f"{'='*60}")
    
    try:
        # Run the test script
        result = subprocess.run(
            [sys.executable, test_script],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        return {
            'name': test_name,
            'script': test_script,
            'return_code': result.returncode,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'success': result.returncode == 0,
            'timestamp': datetime.now().isoformat()
        }
        
    except subprocess.TimeoutExpired:
        return {
            'name': test_name,
            'script': test_script,
            'return_code': -1,
            'stdout': '',
            'stderr': 'Test timed out after 5 minutes',
            'success': False,
            'timestamp': datetime.now().isoformat()
        }
    except Exception as e:
        return {
            'name': test_name,
            'script': test_script,
            'return_code': -1,
            'stdout': '',
            'stderr': str(e),
            'success': False,
            'timestamp': datetime.now().isoformat()
        }


def generate_html_report(results: list, output_file: str):
    """Generate HTML report of test results"""
    
    html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Documentation Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { margin: 20px 0; }
        .test-result { margin: 20px 0; border: 1px solid #ddd; border-radius: 5px; }
        .test-header { padding: 10px; font-weight: bold; }
        .test-success { background-color: #d4edda; color: #155724; }
        .test-failure { background-color: #f8d7da; color: #721c24; }
        .test-output { padding: 10px; background-color: #f8f9fa; }
        .test-output pre { white-space: pre-wrap; word-wrap: break-word; }
        .stats { display: flex; gap: 20px; }
        .stat-box { padding: 15px; border-radius: 5px; text-align: center; }
        .stat-success { background-color: #d4edda; }
        .stat-failure { background-color: #f8d7da; }
        .stat-total { background-color: #e2e3e5; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Documentation Validation Report</h1>
        <p>Generated on: {timestamp}</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <div class="stats">
            <div class="stat-box stat-total">
                <h3>{total_tests}</h3>
                <p>Total Tests</p>
            </div>
            <div class="stat-box stat-success">
                <h3>{passed_tests}</h3>
                <p>Passed</p>
            </div>
            <div class="stat-box stat-failure">
                <h3>{failed_tests}</h3>
                <p>Failed</p>
            </div>
        </div>
    </div>
    
    <div class="results">
        <h2>Test Results</h2>
        {test_results}
    </div>
</body>
</html>
    """
    
    # Generate test result HTML
    test_results_html = ""
    
    for result in results:
        status_class = "test-success" if result['success'] else "test-failure"
        status_text = "✅ PASSED" if result['success'] else "❌ FAILED"
        
        test_html = f"""
        <div class="test-result">
            <div class="test-header {status_class}">
                {result['name']} - {status_text}
            </div>
            <div class="test-output">
                <h4>Output:</h4>
                <pre>{result['stdout']}</pre>
                {f'<h4>Errors:</h4><pre>{result["stderr"]}</pre>' if result['stderr'] else ''}
            </div>
        </div>
        """
        test_results_html += test_html
    
    # Calculate statistics
    total_tests = len(results)
    passed_tests = sum(1 for r in results if r['success'])
    failed_tests = total_tests - passed_tests
    
    # Generate final HTML
    html_content = html_template.format(
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        total_tests=total_tests,
        passed_tests=passed_tests,
        failed_tests=failed_tests,
        test_results=test_results_html
    )
    
    with open(output_file, 'w') as f:
        f.write(html_content)


def main():
    """Main function to run all tests"""
    
    # Change to tests directory
    tests_dir = Path(__file__).parent
    os.chdir(tests_dir.parent)  # Go to project root
    
    print("Documentation Validation Test Suite")
    print("=" * 60)
    print(f"Working directory: {os.getcwd()}")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Define tests to run
    tests = [
        ('tests/terraform_syntax_validation.py', 'Terraform Syntax Validation'),
        ('tests/documentation_structure_validation.py', 'Documentation Structure Validation'),
        ('tests/link_validation.py', 'Link Validation')
    ]
    
    # Check if all test files exist
    missing_tests = []
    for test_script, test_name in tests:
        if not os.path.exists(test_script):
            missing_tests.append(test_script)
    
    if missing_tests:
        print(f"\nError: Missing test files:")
        for test in missing_tests:
            print(f"  - {test}")
        return 1
    
    # Check if documentation file exists
    if not os.path.exists('PRODUCTION_BEST_PRACTICES.md'):
        print("\nError: PRODUCTION_BEST_PRACTICES.md not found")
        return 1
    
    # Run all tests
    results = []
    
    for test_script, test_name in tests:
        result = run_test(test_script, test_name)
        results.append(result)
        
        # Print immediate result
        if result['success']:
            print(f"\n✅ {test_name} PASSED")
        else:
            print(f"\n❌ {test_name} FAILED")
            if result['stderr']:
                print(f"Error: {result['stderr']}")
    
    # Generate summary
    print(f"\n{'='*60}")
    print("FINAL SUMMARY")
    print(f"{'='*60}")
    
    total_tests = len(results)
    passed_tests = sum(1 for r in results if r['success'])
    failed_tests = total_tests - passed_tests
    
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed_tests}")
    print(f"Failed: {failed_tests}")
    
    # List failed tests
    if failed_tests > 0:
        print(f"\nFailed Tests:")
        for result in results:
            if not result['success']:
                print(f"  ❌ {result['name']}")
    
    # Generate reports
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # JSON report
    json_report = {
        'timestamp': datetime.now().isoformat(),
        'summary': {
            'total_tests': total_tests,
            'passed_tests': passed_tests,
            'failed_tests': failed_tests,
            'success_rate': (passed_tests / total_tests) * 100 if total_tests > 0 else 0
        },
        'results': results
    }
    
    json_file = f'test_results_{timestamp}.json'
    with open(json_file, 'w') as f:
        json.dump(json_report, f, indent=2)
    
    print(f"\nReports generated:")
    print(f"  📄 JSON Report: {json_file}")
    
    # HTML report
    html_file = f'test_results_{timestamp}.html'
    generate_html_report(results, html_file)
    print(f"  🌐 HTML Report: {html_file}")
    
    # Return appropriate exit code
    if failed_tests == 0:
        print(f"\n🎉 All tests passed!")
        return 0
    else:
        print(f"\n💥 {failed_tests} test(s) failed!")
        return 1


if __name__ == '__main__':
    exit(main())