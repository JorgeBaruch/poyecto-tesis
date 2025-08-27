<#
.SYNOPSIS
    (v2.4) Orquesta el flujo de trabajo completo del proyecto de tesis con profiling.
.DESCRIPTION
    Este script maestro automatiza toda la cadena de procesamiento y mide el tiempo
    de ejecución de cada paso para identificar cuellos de botella.
    1. Convierte fuentes (PDF, DOCX, TXT) a texto plano.
    2. Extrae citas y las guarda en 97_CITAS.
    3. Genera fichas de lectura para nuevas fuentes.
    4. Crea/actualiza el índice de conceptos.
    5. Genera una nueva síntesis estratégica.
.EXAMPLE
    # Ejecuta todo el proceso y muestra el profiling
    .\tools\Start-FullProcess.ps1
#>

[CmdletBinding(DefaultParameterSetName='Default', SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRootPath,

    [Parameter(Mandatory=$false)]
    [string]$FuentesDirPath,

    [Parameter(Mandatory=$false)]
    [string]$ProcesadosDirPath,

    [Parameter(Mandatory=$false)]
    [string]$FichasDirPath,

    [Parameter(Mandatory=$false)]
    [string]$MapasDirPath,

    [Parameter(Mandatory=$false)]
    [string]$SintesisDirPath,

    [Parameter(Mandatory=$false)]
    [string]$CitasDirPath,

    [Parameter(Mandatory=$false)]
    [string]$LogsDirPath,

    [Parameter(Mandatory=$false)]
    [string]$PdftotextExecutablePath # New parameter
)

# --- [SETUP] ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ProjectRoot = if (-not [string]::IsNullOrEmpty($ProjectRootPath)) { $ProjectRootPath } else { (Get-Item -Path $PSScriptRoot).Parent.FullName }

# Directorios
$FuentesDir = if (-not [string]::IsNullOrEmpty($FuentesDirPath)) { $FuentesDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "00_FUENTES" }
$ProcesadosDir = if (-not [string]::IsNullOrEmpty($ProcesadosDirPath)) { $ProcesadosDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "00_FUENTES_PROCESADAS" }
$FichasDir = if (-not [string]::IsNullOrEmpty($FichasDirPath)) { $FichasDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "01_FICHAS_DE_LECTURA" }
$MapasDir = if (-not [string]::IsNullOrEmpty($MapasDirPath)) { $MapasDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "02_MAPAS_Y_ESQUEMAS" }
$SintesisDir = if (-not [string]::IsNullOrEmpty($SintesisDirPath)) { $SintesisDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "04_SINTESIS" }
$CitasDir = if (-not [string]::IsNullOrEmpty($CitasDirPath)) { $CitasDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "97_CITAS" }
$LogsDir = if (-not [string]::IsNullOrEmpty($LogsDirPath)) { $LogsDirPath } else { Join-Path -Path $ProjectRoot -ChildPath "logs" }

# Scripts
$ImporterScript = Join-Path -Path $PSScriptRoot -ChildPath "Import-Source.ps1"
$CardGeneratorScript = Join-Path -Path $PSScriptRoot -ChildPath "Generate-ReadingCard.ps1"
$CitaExtractorModule = Join-Path -Path $PSScriptRoot -ChildPath "CitaExtractor.psm1"
$ConceptIndexScript = Join-Path -Path $PSScriptRoot -ChildPath "Generate-ConceptIndex.ps1"
$StrategicSynthesisScript = Join-Path -Path $PSScriptRoot -ChildPath "Generate-StrategicSynthesis.ps1"

# Array para almacenar los resultados del profiling
$profilingResults = @()
$profilingOutputFile = Join-Path -Path $LogsDir -ChildPath "profiling_results.txt"

# Asegurarse de que el directorio de logs exista
if (-not (Test-Path -Path $LogsDir -PathType Container)) {
    New-Item -Path $LogsDir -ItemType Directory -Force | Out-Null
}

Write-Output "--- INICIANDO PROCESO COMPLETO DE ANÁLISIS DE TESIS ---"

# --- [PASO 1: IMPORTAR Y CONVERTIR FUENTES] ---
$stepName = "1. Importar y Convertir Fuentes"
$time = Measure-Command {
    Write-Output "`n[1/5] Importando y convirtiendo fuentes a formato de texto..."
    try {
        # Pass PdftotextExecutablePath to Import-Source.ps1 if provided
        if (-not [string]::IsNullOrEmpty($PdftotextExecutablePath)) {
            & $ImporterScript -InputDir $FuentesDir -OutDir $ProcesadosDir -PdftotextExecutablePath $PdftotextExecutablePath -ErrorAction Stop
        } else {
            & $ImporterScript -InputDir $FuentesDir -OutDir $ProcesadosDir -ErrorAction Stop
        }
        Write-Output "Importación de fuentes completada."
    } catch {
        Write-Error "El script de importación de fuentes falló: $($_.Exception.Message | Out-String)"
        exit 1
    }
}
$profilingResults += [PSCustomObject]@{Step = $stepName; TimeSeconds = $time.TotalSeconds}

# --- [PASO 2: EXTRAER CITAS] ---
$stepName = "2. Extraer Citas"
$time = Measure-Command {
    Write-Output "`n[2/5] Extrayendo citas de los archivos de texto..."
    try {
        Import-Module $CitaExtractorModule -Force
        Invoke-QuoteExtraction -TxtDir $ProcesadosDir -OutDir $CitasDir -ErrorAction Stop
        Write-Output "Extracción de citas completada."
    } catch {
        Write-Error "El módulo de extracción de citas falló: $($_.Exception.Message | Out-String)"
        exit 1
    }
}
$profilingResults += [PSCustomObject]@{Step = $stepName; TimeSeconds = $time.TotalSeconds}

# --- [PASO 3: GENERAR FICHAS DE LECTURA] ---
$stepName = "3. Generar Fichas de Lectura"
$time = Measure-Command {
    Write-Output "`n[3/5] Generando fichas de lectura para documentos nuevos..."
    try {
        # The card generator only works for PDFs currently
        $pdfSourceFiles = Get-ChildItem -Path $FuentesDir -Filter "*.pdf" -Recurse
        
        $filesSinFicha = $pdfSourceFiles | Where-Object {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
            $fichaPath = Join-Path -Path $FichasDir -ChildPath "${baseName}_ficha.md"
            -not (Test-Path $fichaPath)
        }

        if ($filesSinFicha.Count -eq 0) {
            Write-Output "No se encontraron nuevos PDFs que necesiten ficha de lectura."
        } else {
            Write-Output "Se encontraron $($filesSinFicha.Count) PDFs para generar ficha. Procesando..."
            foreach ($sourceFile in $filesSinFicha) {
                Write-Output "  - Generando ficha para $($sourceFile.Name)..."
                # Corrected parameter name from -SourcePath to -PdfPath
                & $CardGeneratorScript -PdfPath $sourceFile.FullName -ErrorAction Stop
            }
        }
        Write-Output "Generación de fichas de lectura completada."
    } catch {
        Write-Error "El script de generación de fichas de lectura falló: $($_.Exception.Message | Out-String)"
        exit 1
    }
}
$profilingResults += [PSCustomObject]@{Step = $stepName; TimeSeconds = $time.TotalSeconds}

# --- [PASO 4: GENERAR ÍNDICE DE CONCEPTOS] ---
$stepName = "4. Generar Índice de Conceptos"
$time = Measure-Command {
    Write-Output "`n[4/5] Generando el índice de conceptos..."
    try {
        $indexOutFile = Join-Path -Path $MapasDir -ChildPath "INDICE_DE_CONCEPTOS.md"
        & $ConceptIndexScript -TxtDir $ProcesadosDir -OutFile $indexOutFile -ErrorAction Stop
        Write-Output "Índice de conceptos generado/actualizado."
    } catch {
        Write-Error "El script de generación del índice de conceptos falló: $($_.Exception.Message | Out-String)"
        exit 1
    }
}
$profilingResults += [PSCustomObject]@{Step = $stepName; TimeSeconds = $time.TotalSeconds}

# --- [PASO 5: GENERAR SÍNTESIS ESTRATÉGICA] ---
$stepName = "5. Generar Síntesis Estratégica"
$time = Measure-Command {
    Write-Output "`n[5/5] Generando nueva síntesis estratégica..."
    try {
        & $StrategicSynthesisScript -ErrorAction Stop
        Write-Output "Síntesis estratégica generada."
    } catch {
        Write-Error "El script de generación de síntesis estratégica falló: $($_.Exception.Message | Out-String)"
        exit 1
    }
}
$profilingResults += [PSCustomObject]@{Step = $stepName; TimeSeconds = $time.TotalSeconds}

Write-Output "`n--- PROCESO COMPLETO FINALIZADO ---"

# Escribir los resultados del profiling a un archivo
Write-Output "`n--- RESULTADOS DEL PROFILING ---" | Out-File $profilingOutputFile -Encoding UTF8
$profilingResults | Format-Table -AutoSize | Out-File $profilingOutputFile -Append -Encoding UTF8
Write-Output "Resultados del profiling guardados en: $profilingOutputFile"
Write-Output "-----------------------------------"