# Test file for test_pdftotext.ps1

$scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\utils\test_pdftotext.ps1"

Describe "test_pdftotext.ps1" {
    It "Should exist and be importable" {
        Test-Path $scriptToTest | Should Be $true
    }
    # Agregar más tests funcionales aquí según la lógica del script
}
