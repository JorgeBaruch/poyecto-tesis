# Test file for Generate-ReadingCard.ps1

$scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\Generate-ReadingCard.ps1"

Describe "Generate-ReadingCard.ps1" {
    It "Should exist and be importable" {
        Test-Path $scriptToTest | Should Be $true
    }
    Context "Casos funcionales" {
        # TODO: Agregar tests funcionales con datos de ejemplo en tests/data/
    }
    Context "Manejo de errores" {
        # TODO: Agregar tests de errores (texto vacío, formato incorrecto, etc)
    }
}
