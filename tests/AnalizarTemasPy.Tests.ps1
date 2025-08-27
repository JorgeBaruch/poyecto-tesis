# Test básico para analizar_temas.py
Describe "analizar_temas.py" {
    It "El archivo debe existir" {
        $scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\analizar_temas.py"
        Test-Path $scriptToTest | Should Be $true
    }
    # Para tests funcionales, se recomienda usar pytest en Python
}
