<#
.SYNOPSIS
    Versiona automáticamente todos los borradores en 03_BORRADORES/ y subcarpetas.
.DESCRIPTION
    Renombra archivos sin versión a _v1. Para archivos ya versionados, no hace nada.
    Genera un log de acciones en batch_version.log.
#>

$DraftsRoot = Join-Path $PSScriptRoot "..\03_BORRADORES"
$LogFile = Join-Path $PSScriptRoot "..\03_BORRADORES\batch_version.log"

$allDrafts = Get-ChildItem -Path $DraftsRoot -Recurse -File -Include *.md, *.txt
$versionPattern = '_v(\d+)$'
$actions = @()

if ($allDrafts.Count -eq 0) {
    $msg = "No se encontraron archivos de borrador para versionar en $DraftsRoot."
    $actions += $msg
    $actions | Out-File -FilePath $LogFile -Encoding UTF8
    Write-Output $msg
    return
}

foreach ($draft in $allDrafts) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($draft.Name)
    $extension = $draft.Extension
    if ($baseName -notmatch $versionPattern) {
        $newName = "${baseName}_v1${extension}"
        $newPath = Join-Path -Path $draft.DirectoryName -ChildPath $newName
        if (-not (Test-Path $newPath)) {
            try {
                Rename-Item -Path $draft.FullName -NewName $newName -ErrorAction Stop
                $actions += "[OK] $($draft.Name) -> $newName"
            } catch {
                $actions += "[ERROR] $($draft.Name): $($_.Exception.Message)"
            }
        } else {
            $actions += "[SKIP] $($draft.Name): $newName ya existe"
        }
    } else {
        $actions += "[NOOP] $($draft.Name): ya versionado"
    }
}

$actions | Out-File -FilePath $LogFile -Encoding UTF8
Write-Output "Batch versioning completo. Ver log en $LogFile"
