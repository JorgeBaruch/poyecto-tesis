# Test file for Convert-PdfToText.ps1

$scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\Convert-PdfToText.ps1"

Describe "Convert-PdfToText.ps1" {
    It "Should exist and be importable" {
        Test-Path $scriptToTest | Should Be $true
    }
    Context "Casos funcionales" {
        # TODO: Agregar tests funcionales con PDFs de ejemplo en tests/data/
    }
    Context "Manejo de errores" {
        # TODO: Agregar tests de errores (PDF inexistente, corrupto, etc)
    }
}
