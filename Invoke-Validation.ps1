# Invoke-Validation.ps1
Write-Host "Running all project validation steps..."

# --- Linting ---
Write-Host "Running PowerShell Linter (PSScriptAnalyzer)..."
Invoke-ScriptAnalyzer -Path ./tools -Settings ./PSScriptAnalyzerSettings.psd1 -Recurse

Write-Host "Running Python Linter (flake8)..."
flake8 .

# --- Formatting ---
Write-Host "Checking Python code formatting (black)..."
black . --check

# --- Security Scanning ---
Write-Host "Running Python Dependency Scan (pip-audit)..."
pip-audit -r requirements.txt

Write-Host "Running Python Static Code Analysis (bandit)..."
bandit -r . -c .flake8

# --- Testing ---
Write-Host "Running Pester tests..."
# Ensure we exit with a non-zero code if tests fail
$testResults = Invoke-Pester -Path ./tests -PassThru
if ($testResults.FailedCount -gt 0) {
    exit 1
}

Write-Host "Validation complete."
