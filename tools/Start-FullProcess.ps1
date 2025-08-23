<#
.SYNOPSIS
    (v1.0) Orquesta el flujo de trabajo completo del proyecto de tesis.
.DESCRIPTION
    Este script maestro automatiza toda la cadena de procesamiento:
    1. Convierte todos los PDFs de 00_FUENTES a texto en 00_FUENTES_PROCESADAS.
    2. Extrae todas las citas de los archivos de texto y las guarda en 97_CITAS.
    3. Genera las fichas de lectura para los PDFs que aún no la tengan.
.EXAMPLE
    # Ejecuta todo el proceso
    .\tools\Start-FullProcess.ps1
#>

[CmdletBinding()]
param()

# --- [SETUP] ---
# Obtenemos la ruta raíz del proyecto basándonos en la ubicación de este script.
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ProjectRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName

# Definimos las rutas clave del proyecto
$FuentesDir = Join-Path -Path $ProjectRoot -ChildPath "00_FUENTES"
$ProcesadosDir = Join-Path -Path $ProjectRoot -ChildPath "00_FUENTES_PROCESADAS"
$FichasDir = Join-Path -Path $ProjectRoot -ChildPath "01_FICHAS_DE_LECTURA"
$CitasDir = Join-Path -Path $ProjectRoot -ChildPath "97_CITAS"

# Definimos las rutas a los scripts que vamos a orquestar
$ConverterScript = Join-Path -Path $PSScriptRoot -ChildPath "Convert-PdfToText.ps1"
$CardGeneratorScript = Join-Path -Path $PSScriptRoot -ChildPath "Generate-ReadingCard.ps1"
$CitaExtractorModule = Join-Path -Path $PSScriptRoot -ChildPath "CitaExtractor.psm1"

Write-Host "--- INICIANDO PROCESO COMPLETO DE ANÁLISIS DE TESIS ---" -ForegroundColor Green

# --- [PASO 1: CONVERTIR PDFS A TEXTO] ---
Write-Host "`n[1/3] Convirtiendo PDFs a formato de texto..." -ForegroundColor Yellow
try {
    & $ConverterScript -InputDir $FuentesDir -OutDir $ProcesadosDir -ErrorAction Stop
    Write-Host "Conversión de PDFs completada." -ForegroundColor Green
} catch {
    Write-Error "El script de conversión de PDF falló. Abortando proceso."
    # El script Convert-PdfToText.ps1 ya escribe sus propios logs, no es necesario añadir más aquí.
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
    # El módulo CitaExtractor.psm1 ya escribe sus propios logs.
    exit 1
}

# --- [PASO 3: GENERAR FICHAS DE LECTURA] ---
Write-Host "`n[3/3] Generando fichas de lectura para documentos nuevos..." -ForegroundColor Yellow
try {
    $allPdfs = Get-ChildItem -Path $FuentesDir -Filter *.pdf -Recurse
    $pdfsSinFicha = $allPdfs | Where-Object {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $fichaPath = Join-Path -Path $FichasDir -ChildPath "${baseName}_ficha.md"
        -not (Test-Path $fichaPath)
    }

    if ($pdfsSinFicha.Count -eq 0) {
        Write-Host "No se encontraron nuevos PDFs que necesiten ficha de lectura."
    } else {
        Write-Host "Se encontraron $($pdfsSinFicha.Count) PDFs para generar ficha. Procesando..."
        foreach ($pdf in $pdfsSinFicha) {
            Write-Host "  - Generando ficha para $($pdf.Name)..."
            & $CardGeneratorScript -PdfPath $pdf.FullName -ErrorAction Stop
        }
    }
    Write-Host "Generación de fichas de lectura completada." -ForegroundColor Green
} catch {
    Write-Error "El script de generación de fichas de lectura falló."
    # El script Generate-ReadingCard.ps1 ya escribe sus propios logs.
}

Write-Host "`n--- PROCESO COMPLETO FINALIZADO ---" -ForegroundColor Green
