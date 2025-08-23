#Requires -Version 5.0
<#
.SYNOPSIS
    Valida la estructura de carpetas y la convención de nombres del proyecto.

.DESCRIPTION
    Este script revisa varias reglas predefinidas para asegurar la integridad estructural del proyecto de tesis. Comprueba que ciertos directorios solo contengan tipos de archivo específicos y que los nombres de archivo sigan las convenciones establecidas. Al final, reporta un resumen de los errores encontrados.

.EXAMPLE
    .\scripts\validar_estructura.ps1
#>

$ErrorCount = 0
$Report = ""

Function Add-Error($Message) {
    $script:ErrorCount++
    $script:Report += "- [Error] $Message`n"
    Write-Host "[Error] $Message" -ForegroundColor Red
}

Function Add-Info($Message) {
    $script:Report += "- [Info] $Message`n"
    Write-Host "[Info] $Message" -ForegroundColor Gray
}

Write-Host "Iniciando validación de la estructura del proyecto..." -ForegroundColor Cyan

# --- Regla 1: Validar 00_FUENTES ---
Add-Info "Validando '00_FUENTES'..."
$fuentesPath = "00_FUENTES"
if (Test-Path $fuentesPath) {
    Get-ChildItem -Path $fuentesPath -File | ForEach-Object {
        if ($_.Extension -ne ".pdf") {
            Add-Error "En '00_FUENTES': Se encontró un archivo que no es PDF en la raíz: $($_.Name)"
        }
    }
} else {
    Add-Error "El directorio '00_FUENTES' no existe."
}

# --- Regla 2: Validar 01_FICHAS_DE_LECTURA ---
Add-Info "Validando '01_FICHAS_DE_LECTURA'..."
$fichasPath = "01_FICHAS_DE_LECTURA"
if (Test-Path $fichasPath) {
    Get-ChildItem -Path $fichasPath -File | ForEach-Object {
        if ($_.Extension -ne ".md") {
            Add-Error "En '01_FICHAS_DE_LECTURA': Se encontró un archivo que no es Markdown: $($_.Name)"
        }
        if (-not ($_.Name -like "*_ficha.md")) {
            Add-Error "En '01_FICHAS_DE_LECTURA': El archivo '$($_.Name)' no cumple la convención de nombrado '..._ficha.md'."
        }
    }
} else {
    Add-Error "El directorio '01_FICHAS_DE_LECTURA' no existe."
}

# --- Regla 3: Validar 02_MAPAS_Y_ESQUEMAS ---
Add-Info "Validando '02_MAPAS_Y_ESQUEMAS'..."
$mapasPath = "02_MAPAS_Y_ESQUEMAS"
if (Test-Path $mapasPath) {
    Get-ChildItem -Path $mapasPath -File | ForEach-Object {
        if ($_.Extension -ne ".md") {
            Add-Error "En '02_MAPAS_Y_ESQUEMAS': Se encontró un archivo que no es Markdown: $($_.Name)"
        }
    }
} else {
    Add-Error "El directorio '02_MAPAS_Y_ESQUEMAS' no existe."
}

# --- Regla 4: Validar scripts (opcional, pero buena práctica) ---
Add-Info "Validando 'tools'..."
$scriptsPath = "tools"
if (Test-Path $scriptsPath) {
    Get-ChildItem -Path $scriptsPath -File | ForEach-Object {
        if ($_.Extension -ne ".ps1" -and $_.Extension -ne ".py") {
            Add-Error "En 'tools': Se encontró un archivo que no es de PowerShell (.ps1) ni Python (.py): $($_.Name)"
        }
    }
} else {
    Add-Error "El directorio 'tools' no existe."
}

# --- Reporte Final ---
Write-Host "`n--- Reporte de Validación ---" -ForegroundColor Cyan
if ($ErrorCount -eq 0) {
    Write-Host "¡Excelente! La estructura del proyecto es consistente y no se encontraron errores." -ForegroundColor Green
} else {
    Write-Host "Se encontraron $ErrorCount errores. Por favor, revisa los mensajes anteriores." -ForegroundColor Yellow
    # Opcional: guardar el reporte a un archivo
    # $Report | Out-File -FilePath "reporte_validacion.log" -Encoding utf8
}
