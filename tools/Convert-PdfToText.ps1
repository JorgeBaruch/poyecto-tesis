#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Convierte PDFs a texto con marcadores de página y mayor robustez.
.DESCRIPTION
    Este script transforma documentos PDF en texto plano (.txt) insertando
    marcadores de página [[p=##]]. Utiliza pdftotext y ahora verifica
    que el archivo de texto temporal no esté vacío, mejorando la robustez.
.PARAMETER InputDir
    La ruta al directorio que contiene los archivos PDF a convertir.
.PARAMETER OutDir
    La ruta al directorio donde se guardarán los archivos .txt convertidos.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\convertir_a_txt.ps1 -InputDir .\00_FUENTES -OutDir .\00_FUENTES_PROCESADAS
#>
#Requires -Version 5.0
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputDir,

    [Parameter(Mandatory = $true)]
    [string]$OutDir,

    [Parameter(Mandatory = $false)]
    [string]$PdftotextExecutablePath # Optional: Path to pdftotext.exe if not in PATH or default location
)

$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$LogFile = "convert_pdf_to_text.log"
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

# --- Configuración y Validación de Dependencias ---
$pdftotextPath = $null
if (-not ([string]::IsNullOrEmpty($PdftotextExecutablePath))) {
    if (Test-Path -Path $PdftotextExecutablePath -PathType Leaf) {
        $pdftotextPath = $PdftotextExecutablePath
    } else {
        Write-Error "Error: La ruta proporcionada para pdftotext en -PdftotextExecutablePath no es válida: '$PdftotextExecutablePath'"
        exit 1
    }
} else {
    # Si no se proporciona una ruta, buscar en el PATH.
    $pdftotextCmd = Get-Command pdftotext -ErrorAction SilentlyContinue
    if ($null -ne $pdftotextCmd) {
        $pdftotextPath = $pdftotextCmd.Source
    } else {
        # Si no se encuentra, dar un error claro.
        Write-Error "Error: El comando 'pdftotext' no se encuentra en el PATH. Por favor, instale Poppler y asegúrese de que el directorio 'bin' esté en la variable de entorno PATH, o especifique la ruta al ejecutable usando el parámetro -PdftotextExecutablePath."
        exit 1
    }
}

try {
    $absInputDir = (Resolve-Path -Path $InputDir).Path
    $absOutDir = (Resolve-Path -Path $OutDir).Path
} catch {
    Write-Error "Error: No se pudo resolver una de las rutas: InputDir ('$InputDir') u OutDir ('$OutDir')."
    exit 1 # Para un script de nivel superior, 'exit 1' es una forma aceptable de terminar en errores críticos.
}

if (-not (Test-Path -Path $absInputDir -PathType Container)) {
    Write-Error "Error: El directorio de entrada '$absInputDir' no existe."
    exit 1 # Para un script de nivel superior, 'exit 1' es una forma aceptable de terminar en errores críticos.
}

# --- Validación de permisos y existencia de carpetas de salida ---
if (-not (Test-Path -Path $absOutDir -PathType Container)) {
    try {
        New-Item -Path $absOutDir -ItemType Directory -Force | Out-Null
        Write-Log "Directorio de salida creado: $absOutDir" "SUCCESS"
    } catch {
        Write-Error "No se pudo crear el directorio de salida: $absOutDir"
        Write-Log "No se pudo crear el directorio de salida: $absOutDir" "ERROR"
        exit 1
    }
}

# --- Procesamiento ---
Write-Verbose "Iniciando la conversión de PDFs a TXT..."

# WORKAROUND: Excluir archivos que comienzan con '??'.
# Esto es una solución temporal para nombres de archivo que pdftotext no puede procesar correctamente.
# Se recomienda investigar la causa raíz de este problema (ej. codificación) para una solución permanente.
$allPdfFiles = Get-ChildItem -Path $absInputDir -Filter *.pdf -Recurse
$pdfFiles = $allPdfFiles | Where-Object { $_.Name -notmatch '^[""??"" ]' }
$ignoredFiles = $allPdfFiles | Where-Object { $_.Name -match '^[""??"" ]' }
if ($ignoredFiles.Count -gt 0) {
    Write-Warning "Se ignoraron $($ignoredFiles.Count) archivos PDF con nombres problemáticos (comienzan con '??'). Revise el log para detalles."
    foreach ($file in $ignoredFiles) {
        Write-Log "Archivo ignorado por nombre problemático: $($file.FullName)" "WARN"
    }
}

if ($pdfFiles.Count -eq 0) {
    Write-Warning "No se encontraron archivos PDF válidos en '$absInputDir'."
    exit 0
}

foreach ($pdfFile in $pdfFiles) {
    Write-Verbose "Convirtiendo: $($pdfFile.FullName)"
    Write-Log "Procesando archivo: $($pdfFile.FullName)" "INFO"

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($pdfFile.Name)
    $relativeSubDir = $pdfFile.Directory.FullName.Substring($absInputDir.Length).TrimStart('\')
    $finalOutputDir = Join-Path -Path $absOutDir -ChildPath $relativeSubDir
    
    if (-not (Test-Path -Path $finalOutputDir -PathType Container)) {
        New-Item -Path $finalOutputDir -ItemType Directory -Force | Out-Null
    }

    $finalTxtPath = Join-Path -Path $finalOutputDir -ChildPath "$baseName.txt"
    $tempTxtPath = Join-Path -Path $finalOutputDir -ChildPath "temp_$baseName.txt"

    

    $arguments = @("-layout", "-enc", "UTF-8", "`"$($pdfFile.FullName)`"", "`"$tempTxtPath`"" )
    try {
        & $pdftotextPath $arguments
        Write-Log "pdftotext ejecutado correctamente para: $($pdfFile.FullName)" "SUCCESS"
    } catch {
        Write-Error "Error al ejecutar pdftotext para '$($pdfFile.FullName)': $($_.Exception.Message)"
        Write-Log "Error al ejecutar pdftotext para '$($pdfFile.FullName)': $($_.Exception.Message)" "ERROR"
        Remove-Item -Path $tempTxtPath -ErrorAction SilentlyContinue
        $failedFiles += $pdfFile.FullName
        continue
    }
    
    # --- MEJORA: Verificar el código de salida de pdftotext y si el archivo temporal fue creado y no está vacío ---
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $tempTxtPath) -or (Get-Item $tempTxtPath).Length -eq 0) {
        Write-Error "Error: pdftotext no pudo generar un archivo temporal válido para '$($pdfFile.FullName)'. Código de salida: $LASTEXITCODE."
        Write-Log "pdftotext falló para '$($pdfFile.FullName)'. Código de salida: $LASTEXITCODE." "ERROR"
        Remove-Item -Path $tempTxtPath -ErrorAction SilentlyContinue
        $failedFiles += $pdfFile.FullName
        continue
    }

    # CONSIDERACIÓN DE RENDIMIENTO: Para archivos TXT muy grandes, leer todo el contenido en memoria
    # con Get-Content -Raw podría consumir mucha RAM. Para casos extremos, se podría considerar
    # procesar el archivo línea por línea o en bloques.
    $content = Get-Content -Path $tempTxtPath -Raw -Encoding UTF8
    $pages = $content -split '\f'

    $processedContent = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $pages.Length; $i++) {
        $pageNumber = $i + 1 # Assign sequential page numbers
        [void]$processedContent.Append("[[$pageNumber]]`n")
        [void]$processedContent.Append($pages[$i].Trim())
        if ($i -lt ($pages.Length - 1)) {
            [void]$processedContent.Append("`n`n")
        }
    }

    Set-Content -Path $finalTxtPath -Value $processedContent.ToString() -Encoding UTF8
    Remove-Item -Path $tempTxtPath
    Write-Output " -> Guardado en: $finalTxtPath"
    Write-Log "Archivo TXT generado: $finalTxtPath" "SUCCESS"
}

Write-Output "Proceso completado."

# Reporte de archivos fallidos
if ($failedFiles.Count -gt 0) {
    Write-Warning "Se encontraron errores al procesar los siguientes archivos PDF:"
    $failedFiles | ForEach-Object { Write-Warning "  - $_`; Write-Log "Archivo fallido: $_" "WARNING" }
} else {
    Write-Output "Todos los archivos PDF se procesaron exitosamente."
    Write-Log "Todos los archivos PDF se procesaron exitosamente." "SUCCESS"
}
