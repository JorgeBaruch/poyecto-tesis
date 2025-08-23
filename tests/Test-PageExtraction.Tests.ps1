
$scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\Test-PageExtraction.ps1"

Describe "Test-PageExtraction.ps1" {
    It "Should exist and be importable" {
        Test-Path $scriptToTest | Should Be $true
    }
    It "Debe extraer correctamente el número y contenido de cada página" {
        # El script imprime en inglés, así que validamos contra ese output
        $output = powershell -NoProfile -ExecutionPolicy Bypass -File $scriptToTest | Out-String
        $output | Should Match "Page Number: 1"
        $output | Should Match "Page Content: Some content on page 1."
        $output | Should Match "Page Number: 2"
        $output | Should Match "Page Content: Some content on page 2."
    }
}
