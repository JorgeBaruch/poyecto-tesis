<#
.SYNOPSIS
    (v1.1) Orquesta el flujo de trabajo completo del proyecto de tesis.
.DESCRIPTION
    Este script maestro automatiza toda la cadena de procesamiento:
    1. Convierte todas las fuentes (PDF, DOCX, TXT) de 00_FUENTES a texto en 00_FUENTES_PROCESADAS.
    2. Extrae todas las citas de los archivos de texto y las guarda en 97_CITAS.
    3. Genera las fichas de lectura para las fuentes que aún no la tengan.
.EXAMPLE
    # Ejecuta todo el proceso
    .\tools\Start-FullProcess.ps1
#>

[CmdletBinding()]
param()

# --- [SETUP] ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ProjectRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName

$FuentesDir = Join-Path -Path $ProjectRoot -ChildPath "00_FUENTES"
$ProcesadosDir = Join-Path -Path $ProjectRoot -ChildPath "00_FUENTES_PROCESADAS"
$FichasDir = Join-Path -Path $ProjectRoot -ChildPath "01_FICHAS_DE_LECTURA"
$CitasDir = Join-Path -Path $ProjectRoot -ChildPath "97_CITAS"

$ImporterScript = Join-Path -Path $PSScriptRoot -ChildPath "Import-Source.ps1"
$CardGeneratorScript = Join-Path -Path $PSScriptRoot -ChildPath "Generate-ReadingCard.ps1"
$CitaExtractorModule = Join-Path -Path $PSScriptRoot -ChildPath "CitaExtractor.psm1"

Write-Host "--- INICIANDO PROCESO COMPLETO DE ANÁLISIS DE TESIS ---" -ForegroundColor Green

# --- [PASO 1: IMPORTAR Y CONVERTIR FUENTES] ---
Write-Host "`n[1/3] Importando y convirtiendo fuentes a formato de texto..." -ForegroundColor Yellow
try {
    & $ImporterScript -InputDir $FuentesDir -OutDir $ProcesadosDir -ErrorAction Stop
    Write-Host "Importación de fuentes completada." -ForegroundColor Green
} catch {
    Write-Error "El script de importación de fuentes falló. Abortando proceso."
    exit 1
}

# --- [PASO 2: EXTRAER CITAS] ---
Write-Host "`n[2/3] Extrayendo citas de los archivos de texto..." -ForegroundColor Yellow
try {
    Import-Module $CitaExtractorModule -Force
    Invoke-QuoteExtraction -TxtDir $ProcesadosDir -OutDir $CitasDir -ErrorAction Stop
    Write-Host "Extracción de citas completada." -ForegroundColor Green
} catch {
    Write-Error "El módulo de extracción de citas falló. Abortando proceso."
    exit 1
}

# --- [PASO 3: GENERAR FICHAS DE LECTURA] ---
Write-Host "`n[3/3] Generando fichas de lectura para documentos nuevos..." -ForegroundColor Yellow
try {
    $supportedExtensions = @("*.pdf", "*.docx", "*.txt")
    $allSourceFiles = Get-ChildItem -Path $FuentesDir -Include $supportedExtensions -Recurse
    
    $filesSinFicha = $allSourceFiles | Where-Object {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $fichaPath = Join-Path -Path $FichasDir -ChildPath "${baseName}_ficha.md"
        -not (Test-Path $fichaPath)
    }

    if ($filesSinFicha.Count -eq 0) {
        Write-Host "No se encontraron nuevas fuentes que necesiten ficha de lectura."
    } else {
        Write-Host "Se encontraron $($filesSinFicha.Count) fuentes para generar ficha. Procesando..."
        foreach ($sourceFile in $filesSinFicha) {
            Write-Host "  - Generando ficha para $($sourceFile.Name)..."
            & $CardGeneratorScript -SourcePath $sourceFile.FullName -ErrorAction Stop
        }
    }
    Write-Host "Generación de fichas de lectura completada." -ForegroundColor Green
} catch {
    Write-Error "El script de generación de fichas de lectura falló."
}

Write-Host "`n--- PROCESO COMPLETO FINALIZADO ---" -ForegroundColor Green
