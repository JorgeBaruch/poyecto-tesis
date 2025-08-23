#Requires -Version 5.0
<#
.SYNOPSIS
    Organiza los archivos PDF huérfanos en la carpeta 00_FUENTES.

.DESCRIPTION
    El script busca archivos PDF que se encuentren en la raíz de '00_FUENTES' y no en subdirectorios. Para cada PDF encontrado, muestra un menú interactivo con los subdirectorios existentes (las categorías temáticas) y permite al usuario elegir a dónde mover el archivo. También ofrece la opción de crear un nuevo directorio temático.

.EXAMPLE
    .\scripts\organizar_fuentes.ps1
#>

# --- Configuración ---
$FuentesPath = "00_FUENTES"

if (-not (Test-Path -Path $FuentesPath -PathType Container)) {
    Write-Error "Error: El directorio base '$FuentesPath' no existe."
    exit 1
}

# --- Búsqueda de PDFs huérfanos ---
$orphanPdfs = Get-ChildItem -Path $FuentesPath -Filter *.pdf -File

if ($orphanPdfs.Count -eq 0) {
    Write-Host "No se encontraron archivos PDF para organizar en la raíz de '$FuentesPath'." -ForegroundColor Green
    exit 0
}

Write-Host "Se encontraron $($orphanPdfs.Count) archivos PDF para organizar." -ForegroundColor Yellow

# --- Búsqueda de categorías existentes ---
$categories = Get-ChildItem -Path $FuentesPath -Directory | Select-Object -ExpandProperty Name

# --- Procesamiento interactivo ---
foreach ($pdf in $orphanPdfs) {
    Write-Host "`n--- Organizando archivo: $($pdf.Name) ---" -ForegroundColor Cyan

    # Mostrar menú de opciones
    $menu = @{}
    $i = 1
    foreach ($category in $categories) {
        Write-Host "[$i] Mover a: $category"
        $menu[$i] = $category
        $i++
    }
    Write-Host "[N] Crear nueva categoría"
    Write-Host "[S] Omitir (Skip)"

    # Esperar respuesta del usuario
    $choice = Read-Host -Prompt "Elige una opción"

    switch ($choice) {
        "S" {
            Write-Host "Archivo '$($pdf.Name)' omitido." -ForegroundColor Gray
            continue
        }
        "N" {
            $newCategory = Read-Host -Prompt "Nombre de la nueva categoría"
            if ([string]::IsNullOrWhiteSpace($newCategory)) {
                Write-Warning "Nombre de categoría inválido. Omitiendo archivo."
                continue
            }
            $newCategoryPath = Join-Path -Path $FuentesPath -ChildPath $newCategory
            if (-not (Test-Path $newCategoryPath)) {
                New-Item -Path $newCategoryPath -ItemType Directory | Out-Null
                $categories += $newCategory # Añadir a la lista para futuros movimientos
                Write-Host "Categoría '$newCategory' creada." -ForegroundColor Green
            }
            $destinationPath = Join-Path -Path $newCategoryPath -ChildPath $pdf.Name
            Move-Item -Path $pdf.FullName -Destination $destinationPath
            Write-Host "Movido a '$destinationPath'" -ForegroundColor Green
        }
        default {
            $chosenIndex = 0
            if (($choice -as [int]) -and ($choice -ge 1) -and ($choice -lt $i)) {
                $chosenCategory = $menu[[int]$choice]
                $destinationPath = Join-Path -Path $FuentesPath -ChildPath $chosenCategory | Join-Path -ChildPath $pdf.Name
                Move-Item -Path $pdf.FullName -Destination $destinationPath
                Write-Host "Movido a '$destinationPath'" -ForegroundColor Green
            } else {
                Write-Warning "Opción inválida. Omitiendo archivo."
                continue
            }
        }
    }
}

Write-Host "`nOrganización completada." -ForegroundColor Green
