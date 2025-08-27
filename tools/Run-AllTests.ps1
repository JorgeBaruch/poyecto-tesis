# Run-AllTests.ps1
# This script runs all Pester tests in the 'tests/' directory.

# Ensure Pester module is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Warning "Pester module not found. Please install it using: Install-Module Pester -ScopeCurrentUser"
    exit 1
}

# Get the absolute path to the tests directory
$testsDir = Join-Path -Path $PSScriptRoot -ChildPath "..\tests"

# Run all Pester tests and capture output
$testResults = Invoke-Pester -Path $testsDir

# Output the results to stdout
Write-Output $testResults

# Exit with appropriate code based on test results
if ($testResults.TestResult.FailedCount -gt 0) {
    exit 1
} else {
    exit 0
}
