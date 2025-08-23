<#
.SYNOPSIS
    (v1.2) Gestiona el versionado de archivos de borrador.
.DESCRIPTION
    Este script automatiza el versionado de los archivos de borrador en la carpeta '03_BORRADORES'.
    Si un archivo no tiene versión, lo renombra a '_v1'. Si ya tiene una versión,
    crea una copia nueva con el número de versión incrementado.
.PARAMETER DraftPath
    La ruta completa al archivo de borrador (ej. '.../03_BORRADORES/PRELUDIO_ONTOLOGICO/mi_idea.md').
.EXAMPLE
    # Caso 1: Sin versión previa
    .\Version-Draft.ps1 -DraftPath ".\03_BORRADORES\mi_idea.md"
    # Resultado: Renombra 'mi_idea.md' a 'mi_idea_v1.md'

    # Caso 2: Con versión previa
    .\Version-Draft.ps1 -DraftPath ".\03_BORRADORES\mi_idea_v1.md"
    # Resultado: Crea una copia llamada 'mi_idea_v2.md'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$DraftPath
)

# --- 1. Validación ---
if (-not (Test-Path -Path $DraftPath -PathType Leaf)) {
    Write-Error "El archivo de borrador especificado no existe: $DraftPath"
    exit 1
}

# Validar extensión permitida
$allowedExtensions = @('.md', '.txt')
if ($allowedExtensions -notcontains $([System.IO.Path]::GetExtension($DraftPath).ToLower())) {
    Write-Error "Solo se permite versionar archivos .md o .txt."
    exit 1
}

# --- 2. Análisis de Nombre y Versión ---
$directory = [System.IO.Path]::GetDirectoryName($DraftPath)
$extension = [System.IO.Path]::GetExtension($DraftPath)
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($DraftPath)

# Regex para encontrar el sufijo de versión, ej. _v1, _v25
$versionPattern = '_v(\d+)'
$match = [regex]::Match($baseName, $versionPattern)

# --- 3. Lógica de Versionado ---

if ($match.Success) {
    # --- Caso: Ya tiene versión, crear nueva ---
    $currentVersion = [int]$match.Groups[1].Value
    $newVersion = $currentVersion + 1
    $nameWithoutVersion = $baseName.Substring(0, $match.Index)
    $newFileName = "${nameWithoutVersion}_v${newVersion}${extension}"
    $newFilePath = Join-Path -Path $directory -ChildPath $newFileName
    if (Test-Path $newFilePath) {
        Write-Error "Ya existe una versión con el nombre: $newFileName. No se sobrescribirá."
        exit 1
    }
    try {
        Copy-Item -Path $DraftPath -Destination $newFilePath -ErrorAction Stop
        Write-Output "Nueva versión creada exitosamente: $newFilePath"
    }
    catch {
        Write-Error "No se pudo crear la nueva versión del archivo: $($_.Exception.Message)"
        exit 1
    }
} else {
    # --- Caso: No tiene versión, renombrar a v1 ---
    $newFileName = "${baseName}_v1${extension}"
    $newFilePath = Join-Path -Path $directory -ChildPath $newFileName
    if (Test-Path $newFilePath) {
        Write-Error "Ya existe un archivo con el nombre: $newFileName. No se sobrescribirá."
        exit 1
    }
    try {
        Rename-Item -Path $DraftPath -NewName $newFileName -ErrorAction Stop
        Write-Output "Archivo renombrado a su primera versión: $newFilePath"
    }
    catch {
        Write-Error "No se pudo renombrar el archivo: $($_.Exception.Message)"
        exit 1
    }
}
