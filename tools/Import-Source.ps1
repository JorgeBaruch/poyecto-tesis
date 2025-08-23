#!/usr/bin/env pwsh
<#
.SYNOPSIS
    (v2.0) Importa y convierte múltiples tipos de fuentes (PDF, DOCX, TXT) a texto plano.
.DESCRIPTION
    Este script procesa un directorio de entrada y convierte los archivos soportados
    a formato .txt en un directorio de salida, preservando la estructura de carpetas.
    - PDF: Usa pdftotext para extraer texto y marcadores de página.
    - DOCX: Usa pandoc para convertir el documento a texto.
    - TXT: Copia y estandariza el archivo.
.PARAMETER InputDir
    La ruta al directorio que contiene los archivos fuente.
.PARAMETER OutDir
    La ruta al directorio donde se guardarán los archivos .txt convertidos.
.EXAMPLE
    .\tools\Import-Source.ps1 -InputDir .\00_FUENTES -OutDir .\00_FUENTES_PROCESADAS
#>
#Requires -Version 5.0
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputDir,

    [Parameter(Mandatory = $true)]
    [string]$OutDir,

    [Parameter(Mandatory = $false)]
    [string]$PdftotextExecutablePath,

    [Parameter(Mandatory = $false)]
    [string]$PandocExecutablePath
)

# --- [SETUP] ---
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$scriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$configPath = Join-Path -Path $scriptRoot -ChildPath "..\config\analysis.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
$logBaseDir = Join-Path -Path (Split-Path -Parent -Path $scriptRoot) -ChildPath ($config.logPath -replace "[/\]", [System.IO.Path]::DirectorySeparatorChar)
if (-not (Test-Path -Path $logBaseDir -PathType Container)) {
    New-Item -Path $logBaseDir -ItemType Directory -Force | Out-Null
}
$LogFile = Join-Path -Path $logBaseDir -ChildPath "import_source.log"

# --- [HELPER FUNCTIONS] ---
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "$timestamp [$Level] $Message"
    $maxRetries = 5
    $retryDelayMs = 200
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
            break
        } catch {
            if ($attempt -eq $maxRetries) {
                Write-Warning "No se pudo escribir en el log tras $maxRetries intentos: $logEntry"
            } else {
                Start-Sleep -Milliseconds $retryDelayMs
            }
        }
    }
}

function Get-ExecutablePath {
    param(
        [string]$exeName, # "pdftotext" or "pandoc"
        [string]$configKey, # "pdftotextPath" or "pandocPath"
        [string]$manualPath # from parameters
    )
    
    # 1. Try config file
    if (Test-Path -Path $configPath -PathType Leaf) {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($config -and $config.PSObject.Properties.Match($configKey) -and -not ([string]::IsNullOrEmpty($config.$configKey))) {
            return $config.$configKey
        }
    }

    # 2. Try manual parameter
    if (-not [string]::IsNullOrEmpty($manualPath)) {
        return $manualPath
    }

    # 3. Try PATH environment variable
    $pathCommand = Get-Command $exeName -ErrorAction SilentlyContinue
    if ($pathCommand) {
        return $pathCommand.Source
    }

    return $null
}

# --- [CONFIGURATION & VALIDATION] ---
$pdftotextPath = Get-ExecutablePath -exeName "pdftotext" -configKey "pdftotextPath" -manualPath $PdftotextExecutablePath
$pandocPath = Get-ExecutablePath -exeName "pandoc" -configKey "pandocPath" -manualPath $PandocExecutablePath

try {
    $absInputDir = (Resolve-Path -Path $InputDir).Path
    $absOutDir = (Resolve-Path -Path $OutDir).Path
} catch {
    Write-Error "Error: No se pudo resolver una de las rutas: InputDir ('$InputDir') u OutDir ('$OutDir')."
    exit 1
}

if (-not (Test-Path -Path $absInputDir -PathType Container)) {
    Write-Error "Error: El directorio de entrada '$absInputDir' no existe."
    exit 1
}

if (-not (Test-Path -Path $absOutDir -PathType Container)) {
    New-Item -Path $absOutDir -ItemType Directory -Force | Out-Null
}

# --- [PROCESSING] ---
Write-Host "Iniciando la importación de fuentes..."
$supportedExtensions = @("*.pdf", "*.docx", "*.txt")
$allSourceFiles = Get-ChildItem -Path $absInputDir -Include $supportedExtensions -Recurse
$failedFiles = @()

foreach ($sourceFile in $allSourceFiles) {
    Write-Verbose "Procesando: $($sourceFile.FullName)"
    Write-Log "Procesando archivo: $($sourceFile.FullName)" "INFO"

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile.Name)
    $relativeSubDir = $sourceFile.Directory.FullName.Substring($absInputDir.Length).TrimStart('\')
    $finalOutputDir = Join-Path -Path $absOutDir -ChildPath $relativeSubDir
    
    if (-not (Test-Path -Path $finalOutputDir -PathType Container)) {
        New-Item -Path $finalOutputDir -ItemType Directory -Force | Out-Null
    }

    $finalTxtPath = Join-Path -Path $finalOutputDir -ChildPath "$baseName.txt"
    $tempTxtPath = Join-Path -Path $finalOutputDir -ChildPath "temp_$baseName.txt"
    $success = $false

    try {
        switch ($sourceFile.Extension.ToLower()) {
            ".pdf" {
                if (-not $pdftotextPath) { throw "pdftotext.exe no encontrado. Verifique la configuración." }
                $arguments = @("-layout", "-enc", "UTF-8", "`"$($sourceFile.FullName)`"", "`"$tempTxtPath`"")
                & $pdftotextPath $arguments
                if ($LASTEXITCODE -ne 0) { throw "pdftotext falló con código de salida $LASTEXITCODE." }
                
                $content = Get-Content -Path $tempTxtPath -Raw -Encoding UTF8
                $pages = $content -split '\f'
                $processedContent = New-Object System.Text.StringBuilder
                for ($i = 0; $i -lt $pages.Length; $i++) {
                    $pageNumber = $i + 1
                    [void]$processedContent.Append("[[p=$pageNumber]]`n")
                    [void]$processedContent.Append($pages[$i].Trim())
                    if ($i -lt ($pages.Length - 1)) { [void]$processedContent.Append(
