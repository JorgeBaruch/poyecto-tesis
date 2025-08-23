<#
    Test file for Version-Draft.ps1
    Estructura estándar: Contextos funcionales, de error y de integración.
    Mantener y expandir lógica avanzada aquí.
#>

# Importar el script a testear (dot-sourcing)
$scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\Version-Draft.ps1"

Describe "Version-Draft.ps1" {
    Context "Carga y entorno de pruebas" {
        It "Debe importar el script sin errores" {
            $tempDraftDir = Join-Path $env:TEMP "03_BORRADORES"
            if (!(Test-Path $tempDraftDir)) { New-Item -Path $tempDraftDir -ItemType Directory | Out-Null }
            $DraftFile = "dummy_import.md"
            $DraftPath = Join-Path $tempDraftDir $DraftFile
            Set-Content -Path $DraftPath -Value "dummy"
            try {
                { . $scriptToTest -DraftPath $DraftPath } | Should Not Throw
            } finally {
                if (Test-Path $DraftPath) { Remove-Item $DraftPath }
                if (Test-Path $tempDraftDir) { Remove-Item $tempDraftDir -Recurse }
            }
        }
    }
    Context "Versionado funcional mínimo" {
        It "Renombra archivo sin versión previa a _v1" {
            $tempDraftDir = Join-Path $env:TEMP "03_BORRADORES"
            if (!(Test-Path $tempDraftDir)) { New-Item -Path $tempDraftDir -ItemType Directory | Out-Null }
            $DraftFile = "DraftSimple.md"
            $DraftPath = Join-Path $tempDraftDir $DraftFile
            $VersionedPath = Join-Path $tempDraftDir "DraftSimple_v1.md"
            Set-Content -Path $DraftPath -Value "contenido dummy"
            try {
                . $scriptToTest -DraftPath $DraftPath
                Test-Path $VersionedPath | Should Be $true
            } finally {
                if (Test-Path $VersionedPath) { Remove-Item $VersionedPath }
                if (Test-Path $tempDraftDir) { Remove-Item $tempDraftDir -Recurse }
            }
        }
        It "No renombra archivo ya versionado" {
            $tempDraftDir = Join-Path $env:TEMP "03_BORRADORES"
            if (!(Test-Path $tempDraftDir)) { New-Item -Path $tempDraftDir -ItemType Directory | Out-Null }
            $DraftFile = "DraftSimple_v1.md"
            $DraftPath = Join-Path $tempDraftDir $DraftFile
            Set-Content -Path $DraftPath -Value "contenido dummy"
            try {
                . $scriptToTest -DraftPath $DraftPath
                Test-Path $DraftPath | Should Be $true
            } finally {
                if (Test-Path $DraftPath) { Remove-Item $DraftPath }
                if (Test-Path $tempDraftDir) { Remove-Item $tempDraftDir -Recurse }
            }
        }
        It "Crea nueva versión si ya existe _v1" {
            $tempDraftDir = Join-Path $env:TEMP "03_BORRADORES"
            if (!(Test-Path $tempDraftDir)) { New-Item -Path $tempDraftDir -ItemType Directory | Out-Null }
            $DraftFile = "DraftSimple_v1.md"
            $DraftPath = Join-Path $tempDraftDir $DraftFile
            $VersionedPath = Join-Path $tempDraftDir "DraftSimple_v2.md"
            Set-Content -Path $DraftPath -Value "contenido dummy"
            try {
                . $scriptToTest -DraftPath $DraftPath
                Test-Path $VersionedPath | Should Be $true
            } finally {
                if (Test-Path $VersionedPath) { Remove-Item $VersionedPath }
                if (Test-Path $DraftPath) { Remove-Item $DraftPath }
                if (Test-Path $tempDraftDir) { Remove-Item $tempDraftDir -Recurse }
            }
        }
    }
}
