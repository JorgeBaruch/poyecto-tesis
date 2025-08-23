#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Analiza la frecuencia de términos en un corpus de texto, con mapeo de conceptos.
.DESCRIPTION
    Este script lee todos los archivos .txt de un directorio, los tokeniza, elimina palabras vacías (stop words)
    y cuenta la frecuencia de cada término, agrupándolos según un mapeo de conceptos para
    identificar los conceptos clave de forma más refinada.
.PARAMETER TxtDir
    Directorio de entrada que contiene los archivos .txt a analizar.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\analizar_frecuencia.ps1 -TxtDir .\00_FUENTES_PROCESADAS
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TxtDir
)

# --- [CONFIGURACIÓN] ---

# Cargar configuración desde analysis.json
$analysisConfigPath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "config\analysis.json"
try {
    $analysisConfig = Get-Content -Path $analysisConfigPath | ConvertFrom-Json
    $stopWords = $analysisConfig.stopWords
    $ConceptMapping = $analysisConfig.conceptMapping
} catch {
    Write-Error "Error al cargar la configuración desde '$analysisConfigPath': $($_.Exception.Message)"
    exit 1
}

# --- [INICIALIZACIÓN] ---

$msg = "Iniciando análisis de frecuencia de términos..."
Write-Verbose $msg
$absTxtDir = (Resolve-Path -Path $TxtDir).Path
$conceptFrequencies = @{}

# Inicializar las frecuencias para los conceptos canónicos
foreach ($concept in $ConceptMapping.Keys) {
    $conceptFrequencies[$concept] = 0
}

# Crear un mapeo inverso para una búsqueda eficiente de variantes a conceptos canónicos
$variantToCanonicalMap = @{}
foreach ($canonicalConcept in $ConceptMapping.Keys) {
    foreach ($variant in $ConceptMapping[$canonicalConcept]) {
        $variantToCanonicalMap[$variant] = $canonicalConcept
    }
}

# --- [PROCESAMIENTO] ---

$txtFiles = Get-ChildItem -Path $absTxtDir -Filter *.txt -Recurse
if ($txtFiles.Count -eq 0) { Write-Warning "No se encontraron archivos .txt."; exit 0 }

foreach ($file in $txtFiles) {
    Write-Verbose "Procesando: $($file.Name)"
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8 # Ensure UTF8 encoding
    } catch {
        Write-Warning "Advertencia: No se pudo leer el archivo '$($file.FullName)'. Error: $($_.Exception.Message)"
        continue # Skip to the next file
    }
    # Limpieza del texto
    $cleanedContent = $content.ToLower() `
        -replace '[[p=\\d+]]', ' ' ` # Corrected regex for page markers
        -replace '[^a-záéíóúüñ\s-]', ' ' # Mantener solo letras, espacios y guiones

    # Tokenización
    $words = $cleanedContent.Split([char[]](`' `', '`t', '`n', '`r'), [System.StringSplitOptions]::RemoveEmptyEntries)
    foreach ($word in $words) {
        # 1. Filtrar stop words primero
        if ($stopWords -contains $word) {
            continue # Saltar esta palabra si es una stop word
        }

        # 2. Buscar si la palabra es una variante de un concepto canónico usando el mapeo inverso
        $foundCanonicalConcept = $variantToCanonicalMap[$word]

        if ($foundCanonicalConcept) {
            $conceptFrequencies[$foundCanonicalConcept]++
        } else {
            # Si no es una variante de un concepto canónico y no es una stop word
            if ($word.Length -gt 2) { # Solo contar palabras de más de 2 caracteres
                if ($conceptFrequencies.ContainsKey($word)) {
                    $conceptFrequencies[$word]++
                } else {
                    $conceptFrequencies[$word] = 1
                }
            }
        }
    }
}

# --- [PRESENTACIÓN DE RESULTADOS] ---

Write-Output "Análisis completado. Top 50 de conceptos más frecuentes:"
$sortedFrequencies = $conceptFrequencies.GetEnumerator() | Sort-Object -Property Value -Descending

$i = 1
$sortedFrequencies | Select-Object -First 50 | ForEach-Object {
    Write-Output ("{0,2}. {1,-20} ({2} apariciones)" -f $i, $_.Name, $_.Value)
    $i++
}
return $conceptFrequencies # Return the frequencies hashtable
