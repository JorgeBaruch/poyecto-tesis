<#
.SYNOPSIS
    Validates the integrity of processed text files.
.DESCRIPTION
    This script audits the '00_FUENTES_PROCESADAS' directory to ensure all files are .txt
    and that page markers [[p=##]] are present, sequential, and without gaps.
.PARAMETER TargetDir
    The directory to validate. Defaults to '.\00_FUENTES_PROCESADAS'.
#>
param(
    [string]$TargetDir = ".\00_FUENTES_PROCESADAS"
)

$ErrorCount = 0
$files = Get-ChildItem -Path $TargetDir -Recurse

# 1. Check for non-txt files
$nonTxtFiles = $files | Where-Object { $_.Extension -ne ".txt" }
if ($nonTxtFiles) {
    Write-Host "----------------------------------------"
    Write-Warning "VALIDATION FAILED: Found non-.txt files in target directory."
    $nonTxtFiles | ForEach-Object { Write-Output " -> $($_.FullName)" }
    $ErrorCount += $nonTxtFiles.Count
    Write-Host "----------------------------------------"
}

# 2. Check page marker integrity for each .txt file
$txtFiles = $files | Where-Object { $_.Extension -eq ".txt" }
Write-Host "Starting page marker validation for $($txtFiles.Count) .txt files..."

foreach ($file in $txtFiles) {
    $fileContent = Get-Content -Path $file.FullName -Raw
    $pageMarkers = [regex]::Matches($fileContent, '\[\[p=(\d+)\]\]')
    
    if ($pageMarkers.Count -eq 0) {
        Write-Warning " -> FAILED: $($file.Name) - No page markers found."
        $ErrorCount++
        continue
    }

    $pageNumbers = $pageMarkers | ForEach-Object { [int]$_.Groups[1].Value }

    $isSorted = $true
    for ($i = 0; $i -lt ($pageNumbers.Count - 1); $i++) {
        if ($pageNumbers[$i] -gt $pageNumbers[$i+1]) {
            $isSorted = $false
            break
        }
    }

    if (-not $isSorted) {
        Write-Warning " -> FAILED: $($file.Name) - Page markers are not in ascending order."
        $ErrorCount++
        continue
    }

    $expectedSequence = 1..$pageNumbers[-1]
    $missingPages = Compare-Object -ReferenceObject $expectedSequence -DifferenceObject $pageNumbers | Where-Object { $_.SideIndicator -eq "<=" }

    if ($missingPages) {
        $missingList = $missingPages.InputObject -join ", "
        Write-Warning " -> FAILED: $($file.Name) - Missing or duplicate page markers detected. Gaps at: $missingList"
        $ErrorCount++
        continue
    }

    Write-Host " -> PASSED: $($file.Name)"
}

Write-Host "----------------------------------------"
if ($ErrorCount -eq 0) {
    Write-Host "Validation Complete: All files passed." -ForegroundColor Green
} else {
    Write-Warning "Validation Complete: Found $ErrorCount error(s)."
}
