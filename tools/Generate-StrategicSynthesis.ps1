#Requires -Version 5.0
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
<#
.SYNOPSIS
    Genera un documento de síntesis con las implicancias estratégicas de alta prioridad.
.DESCRIPTION
    Recorre todas las fichas de lectura en '01_FICHAS_DE_LECTURA',
    extrae las implicancias estratégicas marcadas con 'prioridad: Alta' en su front-matter YAML,
    y las consolida en un nuevo archivo Markdown en '04_SINTESIS'.
.EXAMPLE
    .\tools\Generate-StrategicSynthesis.ps1
#>

$FichasPath = "01_FICHAS_DE_LECTURA"
$OutputPath = "04_SINTESIS"
$OutputFileName = "SINTESIS_ESTRATEGICA_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
$OutputFilePath = Join-Path -Path $OutputPath -ChildPath $OutputFileName


# --- [IMPORTAR powershell-yaml] ---
try {
    Import-Module powershell-yaml -Force -ErrorAction Stop
    Write-Host "[INFO] Módulo powershell-yaml importado correctamente."
} catch {
    Write-Warning "No se pudo importar el módulo powershell-yaml. Ejecute: Install-Module -Name powershell-yaml -Scope CurrentUser -Force"
    throw
}

# --- [LOGGING ROBUSTO] ---
$LogFile = "99_META/generate_strategic_synthesis.log"
Remove-Item $LogFile -ErrorAction SilentlyContinue # Limpiar log anterior
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

function ConvertTo-ImplicanciaEstrategica {
    param(
        [string]$implicationsBlock
    )
    $implications = @()
    $current = $null
    $currentField = $null
    if (-not $implicationsBlock) {
        Write-Log "[ConvertTo-ImplicanciaEstrategica] El bloque de implicancias es nulo o vacío." "WARNING"
        return $implications
    }
    $lines = $implicationsBlock -split "`n"
    foreach ($line in $lines) {
        $raw = $line
        $trim = $line.Trim()
        # Detecta inicio de nueva implicancia
        if ($trim -like '- priority:*' -or $trim -like '- prioridad:*') {
            if ($null -ne $current) { $implications += $current }
            $prioridad = ''
            if (($trim -split ':', 2).Count -ge 2) {
                $prioridad = ($trim -split ':', 2)[1].Trim(' "')
            } else {
                Write-Log "[ConvertTo-ImplicanciaEstrategica] Línea de prioridad malformada: $trim" "WARNING"
            }
            $current = @{ prioridad = $prioridad; descripcion = ''; tipo = '' }
            $currentField = $null
        } elseif ($trim -like 'descripcion:*') {
            if ($null -ne $current -and $current.ContainsKey('prioridad')) {
                $desc = ''
                if (($trim -split ':', 2).Count -ge 2) {
                    $desc = ($trim -split ':', 2)[1].TrimStart(' "')
                }
                $current['descripcion'] = $desc
                $currentField = 'descripcion'
            }
        } elseif ($trim -like 'tipo:*') {
            if ($null -ne $current -and $current.ContainsKey('prioridad')) {
                $tipo = ''
                if (($trim -split ':', 2).Count -ge 2) {
                    $tipo = ($trim -split ':', 2)[1].TrimStart(' "')
                }
                $current['tipo'] = $tipo
                $currentField = 'tipo'
            }
        } elseif ($raw -match '^\s{2,}.+') {
            # Línea indentada: continuación multilínea YAML
            if ($null -ne $current -and $null -ne $currentField -and $current.ContainsKey($currentField)) {
                $current[$currentField] += " `n" + $trim
            }
        } else {
            $currentField = $null
        }
    }
    if ($null -ne $current) { $implications += $current }
    Write-Log "[ConvertTo-ImplicanciaEstrategica] Implicancias parseadas: $($implications | ConvertTo-Json -Compress)" "DEBUG"
    return $implications
}

# --- Inicializar el documento de síntesis ---
$SynthesisContent = @()
$SynthesisContent += "# Síntesis de Implicancias Estratégicas (Prioridad Alta)"
$SynthesisContent += ""
$SynthesisContent += "Generado el: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$SynthesisContent += "\n---\n"
Write-Log "Iniciando generación de síntesis estratégica." "INFO"
Write-Log "Ruta de fichas: $FichasPath" "DEBUG"
Write-Log "Ruta de salida: $OutputPath" "DEBUG"
Write-Log "Archivo de salida: $OutputFilePath" "DEBUG"


# --- PROCESAR FICHAS ---
try {
    $FichaFiles = Get-ChildItem -Path $FichasPath -Filter "*.md" -File -Recurse
    if ($FichaFiles.Count -eq 0) {
        $SynthesisContent += "No se encontraron fichas para procesar en '$FichasPath'."
        Write-Log "No se encontraron fichas para procesar en '$FichasPath'." "WARNING"
    } else {
        $SynthesisContent += "Se encontraron $($FichaFiles.Count) fichas. Procesando..."
        Write-Log "Se encontraron $($FichaFiles.Count) fichas. Procesando..." "INFO"
        foreach ($fichaFile in $FichaFiles) {
            Write-Log "--- Procesando ficha: $($fichaFile.Name) ---" "DEBUG"
            $content = Get-Content -Path $fichaFile.FullName -Raw -Encoding UTF8 -ReadCount 0
            # Normalizar saltos de línea a \n para máxima compatibilidad de regex
            $content = $content -replace "\r\n", "\n" -replace "\r", "\n"
            if (-not $content) {
                Write-Log "[Advertencia] Ficha vacía: $($fichaFile.Name)" "WARNING"
                continue
            }
            # Log de depuración: mostrar los códigos hexadecimales de los primeros 10 caracteres
            $hexCodes = ($content.ToCharArray() | Select-Object -First 10 | ForEach-Object { [int]$_ }) | ForEach-Object { $_.ToString("X2") }
            $hexString = ($hexCodes -join ' ')
            Write-Log "[DEBUG] Códigos hexadecimales de los primeros 10 caracteres de $($fichaFile.Name): $hexString" "DEBUG"

            # Log ultra detallado: mostrar los primeros 20 caracteres del contenido completo
            $first20chars = @($content.ToCharArray() | Select-Object -First 20)
            $first20hexArr = @()
            $first20decArr = @()
            $first20literalArr = @()
            foreach ($c in $first20chars) {
                $first20hexArr += ([int]$c).ToString("X2")
                $first20decArr += ([int]$c)
                if ([int]$c -eq 10) { $first20literalArr += '<LF>' }
                elseif ([int]$c -eq 13) { $first20literalArr += '<CR>' }
                elseif ([int]$c -eq 9) { $first20literalArr += '<TAB>' }
                else { $first20literalArr += $c }
            }
            $first20hex = $first20hexArr -join ' '
            $first20dec = $first20decArr -join ' '
            $first20literal = $first20literalArr -join ''
            Write-Log "[DEBUG] Primeros 20 caracteres hex: $first20hex" "DEBUG"
            Write-Log "[DEBUG] Primeros 20 caracteres dec: $first20dec" "DEBUG"
            Write-Log "[DEBUG] Primeros 20 caracteres literal: $first20literal" "DEBUG"
            $preview = if ($content.Length -gt 0) { $content.Substring(0, [System.Math]::Min(200, $content.Length)) } else { "(vacío)" }
            Write-Log "Contenido de la ficha $($fichaFile.Name) (primeras 200 chars): $preview..." "DEBUG"
            $yamlMatch = $null
            # Extracción robusta de YAML: buscar índices de líneas con solo '---' y extraer el bloque entre ellas
            $yamlContent = $null
            $lines = $content -split "\n"
            $startIdx = $null
            $endIdx = $null
            for ($i = 0; $i -lt $lines.Count; $i++) {
                # Detecta línea que contiene solo '---' (ignorando espacios y saltos de línea)
                if ($lines[$i] -match '^[\s-]*---[\s-]*$') {
                    if ($null -eq $startIdx) {
                        $startIdx = $i
                    } elseif ($null -eq $endIdx) {
                        $endIdx = $i
                        break
                    }
                }
            }
            if ($null -ne $startIdx -and $null -ne $endIdx -and $endIdx -gt $startIdx) {
                $yamlContent = ($lines[($startIdx + 1)..($endIdx - 1)] -join "`n")
            }
            if ($null -ne $yamlContent -and -not [string]::IsNullOrWhiteSpace($yamlContent)) {
                Write-Log "YAML extraído: `n$yamlContent`n" "DEBUG"
                try {
                    $yamlObj = ConvertFrom-Yaml $yamlContent
                } catch {
                    Write-Log "[ERROR] Fallo al parsear YAML en $($fichaFile.Name): $($_.Exception.Message)" "ERROR"
                    continue
                }
                $fichaTitle = if ($yamlObj.titulo_original) { $yamlObj.titulo_original } else { 'Sin título' }
                Write-Log "Título de ficha: $fichaTitle" "DEBUG"
                $fichaId = if ($yamlObj.id) { $yamlObj.id } else { 'SinID' }
                Write-Log "ID de ficha: $fichaId" "DEBUG"
                $implicanciasBlock = $yamlObj.implicancias_estrategicas
                if (-not $implicanciasBlock) {
                    Write-Log "  [Advertencia] Sección 'implicancias_estrategicas' vacía o nula en la ficha $($fichaFile.Name)." "WARNING"
                    continue
                }
                Write-Log "Bloque de implicancias estratégicas: `n$implicanciasBlock`n" "DEBUG"
                $implications = @()
                if ($implicanciasBlock -is [System.Collections.IEnumerable] -and ($implicanciasBlock -isnot [string])) {
                    # Ya es un array de objetos YAML
                    $implications = $implicanciasBlock
                    Write-Log "[YAML] implicancias_estrategicas ya es array de objetos. Count: $($implications.Count)" "DEBUG"
                } else {
                    # Es un bloque de texto, usar parser manual
                    $implications = ConvertTo-ImplicanciaEstrategica $implicanciasBlock
                }
                if ($null -eq $implications -or $implications.Count -eq 0) {
                    Write-Log "  [Advertencia] No se encontraron implicancias estratégicas parseadas en la ficha $($fichaFile.Name)." "WARNING"
                } else {
                    Write-Log "Implicancias parseadas: $($implications | ConvertTo-Json -Compress)" "DEBUG"
                    foreach ($imp in $implications) {
                        if ($null -eq $imp -or -not ($imp -is [hashtable])) {
                            Write-Log "  [Advertencia] Implicancia nula o no es hashtable: $($imp | Out-String)" "WARNING"
                            continue
                        }
                        if ($imp.ContainsKey('prioridad') -and $imp['prioridad'] -eq 'Alta') {
                            # Buscar claves flexibles para tipo y descripción
                            $tipo = ''
                            $desc = ''
                            foreach ($k in $imp.Keys) {
                                if ($k -match '^(tipo|Tipo)$') { $tipo = $imp[$k] }
                                if ($k -match '^(descripcion|descripción|Descripción)$') { $desc = $imp[$k] }
                            }
                            $SynthesisContent += "### Implicancia de '$fichaTitle' (ID: $fichaId)"
                            $SynthesisContent += "- **Prioridad:** $($imp['prioridad'])"
                            $SynthesisContent += "- **Tipo:** $tipo"
                            $SynthesisContent += "- **Descripción:** $desc"
                            $SynthesisContent += ""
                            Write-Log "  [+] Añadida implicancia de alta prioridad de '$fichaTitle'." "SUCCESS"
                        }
                    }
                }
            } else {
                Write-Log "  [Advertencia] Ficha sin front-matter YAML: $($fichaFile.Name)" "WARNING"
            }
        }
    }

    # --- ESCRIBIR DOCUMENTO ---
    $OutputFileName = "SINTESIS_ESTRATEGICA_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    $OutputFilePath = Join-Path -Path $OutputPath -ChildPath $OutputFileName
    [System.IO.File]::WriteAllLines($OutputFilePath, $SynthesisContent, [System.Text.UTF8Encoding]::new($false))
    Write-Log "Éxito: Documento de síntesis generado en '$OutputFilePath'" "SUCCESS"
    Write-Log "Archivo de salida: $OutputFilePath" "DEBUG"
} catch {
    Write-Error "Ocurrió un error durante la generación de la síntesis: $($_.Exception.Message)"
    Write-Log "Error durante la generación de la síntesis: $($_.Exception.Message)" "ERROR"
    exit 1
}
