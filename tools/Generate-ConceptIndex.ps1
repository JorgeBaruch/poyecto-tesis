
param(
    [Parameter(Mandatory = $true)]
    [string]$TxtDir,

    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

# --- [LOGGING ROBUSTO] ---
$LogFile = "generate_concept_index.log"
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


<#
.SYNOPSIS
    Genera un índice de conceptos clave a partir de los textos procesados.
.DESCRIPTION
    Este script lee una lista predefinida de conceptos, busca sus apariciones
    en todos los archivos de texto de un directorio y genera un archivo Markdown
    con un índice que muestra en qué documento y página aparece cada concepto.
.PARAMETER TxtDir
    Directorio de entrada que contiene los archivos .txt a procesar.
.PARAMETER OutFile
    Ruta completa del archivo Markdown de salida para el índice.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\generar_indice_conceptos.ps1 -TxtDir .\00_FUENTES_PROCESADAS -OutFile .\02_MAPAS_Y_ESQUEMAS\INDICE_DE_CONCEPTOS.md
#>

#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Genera un índice de conceptos clave a partir de los textos procesados.
.DESCRIPTION
    Este script lee una lista predefinida de conceptos, busca sus apariciones
    en todos los archivos de texto de un directorio y genera un archivo Markdown
    con un índice que muestra en qué documento y página aparece cada concepto.
.PARAMETER TxtDir
    Directorio de entrada que contiene los archivos .txt a procesar.
.PARAMETER OutFile
    Ruta completa del archivo Markdown de salida para el índice.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\generar_indice_conceptos.ps1 -TxtDir .\00_FUENTES_PROCESADAS -OutFile .\02_MAPAS_Y_ESQUEMAS\INDICE_DE_CONCEPTOS.md
#>

#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Genera un índice de conceptos clave a partir de los textos procesados.
.DESCRIPTION
    Este script lee una lista predefinida de conceptos, busca sus apariciones
    en todos los archivos de texto de un directorio y genera un archivo Markdown
    con un índice que muestra en qué documento y página aparece cada concepto.
.PARAMETER TxtDir
    Directorio de entrada que contiene los archivos .txt a procesar.
.PARAMETER OutFile
    Ruta completa del archivo Markdown de salida para el índice.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\generar_indice_conceptos.ps1 -TxtDir .\00_FUENTES_PROCESADAS -OutFile .\02_MAPAS_Y_ESQUEMAS\INDICE_DE_CONCEPTOS.md
#>

# --- [CONFIGURACIÓN] ---

# Cargar configuración desde analysis.json
$analysisConfigPath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "config\analysis.json"
try {
    $analysisConfig = Get-Content -Path $analysisConfigPath -Encoding UTF8 | ConvertFrom-Json
    $stopWords = $analysisConfig.stopWords
    $ConceptMapping = $analysisConfig.conceptMapping
    Write-Log "Configuración cargada desde '$analysisConfigPath'" "SUCCESS"
} catch {
    Write-Error "Error al cargar la configuración desde '$analysisConfigPath': $($_.Exception.Message)"
    Write-Log "Error al cargar la configuración desde '$analysisConfigPath': $($_.Exception.Message)" "ERROR"
    exit 1
}

# La lista $conceptosClave se mantiene aquí ya que es específica de este script
# y no es parte del mapeo general de conceptos.
$conceptosClave = @(
    "Ética", "valor", "Economía", "capital", "Sociedad", "trabajo", "Política",
    "Producción", "Historia", "Relación", "Análisis", "Forma", "Estado",
    "Sistema", "Mercado", "Sujeto", "Dinero", "Vida", "Tiempo", "Canción",
    "Clave", "Proceso", "Constitución", "Cambio", "Discurso", "Objeto",
    "Nacional", "Saber", "Música", "Plus", "Poder", "Intuición", "Mercancía",
    "Teoría", "goce", "derechos", "deseo", "rock", "sentido", "tango",
    "crisis", "lugar", "mundo", "Filosofía", "Dialéctica", "Negación",
    "Axiología", "Epistemologías", "Epistemicidio", "Perspectivismo"
)

# --- [INICIALIZACIÓN] ---

$msg = "Iniciando la generación de índice de conceptos..."
Write-Verbose $msg
Write-Log $msg "INFO"
$absTxtDir = (Resolve-Path -Path $TxtDir).Path
$conceptIndex = @{} # Usaremos un hashtable para almacenar el índice: Concepto -> @{ FilePath -> @(PageNumbers) }

# --- [PROCESAMIENTO] ---


try {
    $txtFiles = Get-ChildItem -Path $absTxtDir -Filter *.txt -Recurse
    if ($txtFiles.Count -eq 0) {
        Write-Warning "No se encontraron archivos .txt."
        Write-Log "No se encontraron archivos .txt en $absTxtDir" "WARNING"
        exit 0
    }
} catch {
    Write-Error "Error al buscar archivos .txt en '$absTxtDir': $($_.Exception.Message)"
    Write-Log "Error al buscar archivos .txt en '$absTxtDir': $($_.Exception.Message)" "ERROR"
    exit 1
}

foreach ($file in $txtFiles) {
    try {
        Write-Verbose "Procesando: $($file.Name)"
        Write-Log "Procesando archivo: $($file.FullName)" "INFO"
        $lines = Get-Content -Path $file.FullName -Encoding UTF8

        $currentFile = $file.Name
        $currentPage = 0

        foreach ($line in $lines) {
            # Extraer número de página si la línea contiene el marcador [[p=##]]
            if ($line -match '\[\[p=(\d+)\]\]') {
                $currentPage = [int]$matches[1]
                $cleanedLine = $line -replace '\[\[p=(\d+)\]\]', '' # Eliminar el marcador de la línea
            } else {
                $cleanedLine = $line
            }

            # Limpieza del texto de la línea
            $processedLine = $cleanedLine.ToLower() `
                -replace '[^a-záéíóúüñ\s]', ' ' # Mantener solo letras y espacios

            # Tokenización
            $words = $processedLine.Split([char[]](" ", "`t", "`n", "`r"), [System.StringSplitOptions]::RemoveEmptyEntries)

            foreach ($word in $words) {
                # Solo procesar palabras que no sean stop words y tengan más de 2 caracteres
                if ($stopWords -notcontains $word -and $word.Length -gt 2) {
                    $foundCanonicalConcept = $null
                    foreach ($canonicalConcept in $ConceptMapping.Keys) {
                        if ($ConceptMapping[$canonicalConcept] -contains $word) {
                            $foundCanonicalConcept = $canonicalConcept
                            break
                        }
                    }

                    if ($foundCanonicalConcept) {
                        # Si el concepto canónico no existe en el índice, inicializarlo
                        if (-not $conceptIndex.ContainsKey($foundCanonicalConcept)) {
                            $conceptIndex[$foundCanonicalConcept] = @{}
                        }
                        # Si el archivo no existe para este concepto, inicializarlo
                        if (-not $conceptIndex[$foundCanonicalConcept].ContainsKey($currentFile)) {
                            $conceptIndex[$foundCanonicalConcept][$currentFile] = New-Object System.Collections.Generic.List[int]
                        }
                        # Añadir el número de página si no está ya presente para este archivo
                        if (-not $conceptIndex[$foundCanonicalConcept][$currentFile].Contains($currentPage)) {
                            $conceptIndex[$foundCanonicalConcept][$currentFile].Add($currentPage)
                            Write-Log "Concepto '$foundCanonicalConcept' encontrado en $currentFile página $currentPage" "DEBUG"
                        }
                    }
                }
            }
        }
        Write-Log "Archivo procesado: $($file.FullName)" "SUCCESS"
    } catch {
        Write-Error "Error procesando archivo '$($file.FullName)': $($_.Exception.Message)"
        Write-Log "Error procesando archivo '$($file.FullName)': $($_.Exception.Message)" "ERROR"
    }
}

# --- [GENERACIÓN DE SALIDA MARKDOWN] ---


$msg = "Generando archivo Markdown de índice de conceptos..."
Write-Verbose $msg
Write-Log $msg "INFO"

$mdContent = New-Object System.Text.StringBuilder
[void]$mdContent.AppendLine("# Índice de Conceptos Clave")
[void]$mdContent.AppendLine("Generado el: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$mdContent.AppendLine("---")
[void]$mdContent.AppendLine()

# Ordenar conceptos alfabéticamente
$sortedConcepts = $conceptIndex.Keys | Sort-Object

foreach ($concept in $sortedConcepts) {
    [void]$mdContent.AppendLine("## $concept")
    $filesWithConcept = $conceptIndex[$concept].Keys | Sort-Object

    foreach ($file in $filesWithConcept) {
        $pages = $conceptIndex[$concept][$file] | Sort-Object | ForEach-Object { "p.$_" }
        [void]$mdContent.AppendLine("- **$file**: $($pages -join ', ')")
    }
    [void]$mdContent.AppendLine()
}

# Escribir el contenido al archivo de salida
try {
    Set-Content -Path $OutFile -Value $mdContent.ToString() -Encoding UTF8
    Write-Log "Índice de conceptos generado en '$OutFile'" "SUCCESS"
    Write-Output "Éxito: Índice de conceptos generado en '$OutFile'"
} catch {
    Write-Error "Error al escribir el archivo de índice de conceptos en '$OutFile': $($_.Exception.Message)"
    Write-Log "Error al escribir el archivo de índice de conceptos en '$OutFile': $($_.Exception.Message)" "ERROR"
    exit 1
}
