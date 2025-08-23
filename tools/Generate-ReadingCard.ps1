<#
.SYNOPSIS
    (v1.0) Genera una ficha de lectura en formato Markdown a partir de un archivo PDF.
.DESCRIPTION
    Este script crea una nueva ficha de lectura en la carpeta '01_FICHAS_DE_LECTURA'.
    Toma la ruta de un archivo PDF como entrada, extrae su nombre para usarlo como título
    y genera un archivo .md con metadatos pre-rellenados en formato YAML, listo para ser completado.
.PARAMETER PdfPath
    La ruta completa al archivo PDF de origen que se encuentra en la carpeta '00_FUENTES'.
.EXAMPLE
    .\Generate-ReadingCard.ps1 -PdfPath "ruta\a\su\documento.pdf"
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$PdfPath
)


# --- [LOGGING ROBUSTO] ---
$LogFile = "generate_reading_card.log"
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

# --- 1. Validación de Rutas y Nombres ---

# Validar que el archivo PDF de entrada exista
if (-not (Test-Path -Path $PdfPath -PathType Leaf)) {
  Write-Error "El archivo PDF especificado no existe en la ruta: $PdfPath"
  Write-Log "El archivo PDF especificado no existe: $PdfPath" "ERROR"
  exit 1
}

# Extraer el nombre base del archivo PDF (sin extensión)
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($PdfPath)

# Construir el nombre del archivo de la ficha de lectura
$fichaFileName = "${baseName}_ficha.md"

# Obtener la ruta del directorio del script para construir rutas relativas
$scriptRoot = $PSScriptRoot
$projectRoot = (Get-Item -Path $scriptRoot).Parent.FullName

# Construir la ruta de salida para la nueva ficha
$outputDir = Join-Path -Path $projectRoot -ChildPath "01_FICHAS_DE_LECTURA"
$outputPath = Join-Path -Path $outputDir -ChildPath $fichaFileName

# Validar que no exista ya una ficha con el mismo nombre
if (Test-Path -Path $outputPath) {
  Write-Error "Ya existe una ficha de lectura para este archivo: $outputPath"
  Write-Log "Intento de sobrescribir ficha existente: $outputPath" "WARNING"
  exit 1
}

# --- 2. Generación de Metadatos ---

# Generar un ID único basado en la fecha y hora actual
$id = Get-Date -Format "yyyyMMddHHmmss"

# Limpiar el nombre base para usarlo como título (reemplazar guiones y underscores por espacios)
$titulo = $baseName -replace '_', ' ' -replace '-', ' '

# Obtener la fecha actual en formato ISO 8601
$fechaLectura = Get-Date -Format "yyyy-MM-dd"

# Normalizar la ruta del PDF para que sea relativa al proyecto
$fuentePdf = $PdfPath.Replace($projectRoot + '\', '') -replace '\\', '/'

# --- 3. Creación del Contenido de la Ficha ---

$fileContent = @"
---
id: "$id"
# --- Metadatos Básicos ---
titulo_original: "$titulo"
autor: "(Por definir)"
fuente_pdf: "$fuentePdf"
fecha_lectura: "$fechaLectura"
estado: "Pendiente"

# --- Análisis Central ---
tesis_central: >
  (Escribir la tesis central del texto aquí)
palabras_clave:
  - 

# --- Observaciones Analíticas Detalladas ---
observaciones_notables:
  - tipo: ""
    descripcion: ""
    cita_relacionada: ""

# --- Conexiones y Estrategia (Proyectivo) ---
conexiones:
  - tipo: ""
    con_id: ""
    descripcion: ""
implicancias_estrategicas:
  - prioridad: ""
    descripcion: ""
    tipo: ""

# --- Conexiones Inter-Ficha Estructuradas ---
conexiones_inter_ficha:
  - con_id: "ID_FICHA_EJEMPLO"
    tipo: "Ejemplo"
    concepto: "Concepto de Ejemplo"
    descripcion: "Esta es una conexión de ejemplo para inicializar la estructura."
---

## Resumen Extendido

(Escribir un resumen extendido del texto aquí)

## Citas Clave

> (Pegar citas clave aquí)

## Reflexiones Personales

(Escribir reflexiones personales aquí)
"@

# --- 4. Escritura del Archivo ---

try {
  # Crear el directorio de salida si no existe
  if (-not (Test-Path -Path $outputDir -PathType Container)) {
    try {
      New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
      Write-Log "Directorio de salida creado: $outputDir" "SUCCESS"
    } catch {
      Write-Error "No se pudo crear el directorio de salida: $outputDir"
      Write-Log "No se pudo crear el directorio de salida: $outputDir. $($_.Exception.Message)" "ERROR"
      exit 1
    }
  }

  # Crear y escribir el contenido en el nuevo archivo de la ficha
  Set-Content -Path $outputPath -Value $fileContent -Encoding UTF8
  Write-Log "Ficha de lectura creada exitosamente en: $outputPath" "SUCCESS"
  Write-Output "Ficha de lectura creada exitosamente en: $outputPath"
} catch {
  Write-Error "Ocurrió un error al crear la ficha de lectura: $($_.Exception.Message)"
  Write-Log "Error al crear la ficha de lectura: $($_.Exception.Message)" "ERROR"
  exit 1
}