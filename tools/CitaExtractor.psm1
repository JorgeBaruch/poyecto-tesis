# --- [LOGGING ROBUSTO] ---
$LogFile = "cita_extractor.log"
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
    Módulo para extracción avanzada de citas y referencias bibliográficas.
.DESCRIPTION
    Contiene funciones para procesar archivos de texto, identificar citas,
    extraer referencias y autores, y organizar los resultados para su guardado.
#>

# --- [CONFIGURACIÓN GLOBAL DEL MÓDULO] ---
$OutputEncoding = [System.Text.Encoding]::UTF8

# Patrones regex como string y como objeto [regex]
$quotePattern = '"([^"]+)"'
$quoteRegex = [regex]$quotePattern
$citationPattern = '\(([^)]+)\)'
$citationRegex = [regex]$citationPattern
$pageNumberPattern = '\[\[p=(\d+)\]\]'
$pageNumberRegex = [regex]$pageNumberPattern

# --- [HELPER FUNCTIONS] ---

function Get-PageContent {
    [CmdletBinding()]
    param(
        [string]$RawContent
    )
    if ([string]::IsNullOrEmpty($RawContent)) { return @() }
    $pages = $RawContent -split "`f"
    $result = New-Object System.Collections.ArrayList
    foreach ($pageContent in $pages) {
        if ([string]::IsNullOrEmpty($pageContent)) { continue }
        $pageNumber = 0
        $tempPage = $pageContent
        if ($tempPage -match $pageNumberRegex) {
            $pageNumber = $matches[1]
            $tempPage = $tempPage -replace $pageNumberRegex, ''
        }
        $trimmedPage = $tempPage.Trim()
        $result += [PSCustomObject]@{
            PageNumber = $pageNumber
            Content = $trimmedPage
        }
    }
    return $result
}

function Find-QuotesOnPage {
    [CmdletBinding()]
    param(
        [string]$PageText
    )
    if ([string]::IsNullOrEmpty($PageText)) { return @() }
    $matches = [regex]::Matches($PageText, $quoteRegex)
    $extractedQuotes = @()
    foreach ($m in $matches) {
        $extractedQuotes += $m.Groups[1].Value.Trim()
    }
    return $extractedQuotes
}

function Identify-AuthorAndReference {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory = $true)]
        [string]$ContextText,
    [Parameter(Mandatory = $true)]
        [hashtable]$AuthorsDB
    )
    try {
        Write-Log "Procesando contexto para identificar autor/referencia..." "DEBUG"
        $foundAuthor = $null
        $confidence = "unknown"
        $foundReference = ""
        $foundYear = ""

        $citationMatches = $citationRegex.Matches($ContextText)
        foreach ($citationMatch in $citationMatches) {
            $refText = $citationMatch.Groups[1].Value
            if ($refText -match '\d{4}') { # Check for year pattern
                $foundReference = "($refText)"
                $confidence = "apa"
                if ($refText -match '\b(\d{4})\b') { $foundYear = $Matches[1] }
                foreach ($authorEntry in $AuthorsDB.GetEnumerator()) {
                    foreach ($alias in $authorEntry.Value) {
                        if ($refText -match "(?i)$alias") { $foundAuthor = $authorEntry.Name; $confidence = "alias_in_apa"; break }
                    }
                    if ($foundAuthor) { break }
                }
                if (-not $foundAuthor) {
                    $possibleAuthor = ($refText -split ",")[0].Trim().ToUpper()
                    if ($possibleAuthor.Length -gt 2 -and $possibleAuthor.Length -lt 50) {
                        $foundAuthor = $possibleAuthor
                    }
                }
                break
            }
        }

        if (-not $foundAuthor) {
            foreach ($authorEntry in $AuthorsDB.GetEnumerator()) {
                foreach ($alias in $authorEntry.Value) {
                    if ($ContextText -match "(?i)$alias") { $foundAuthor = $authorEntry.Name; $confidence = "loose_alias"; break }
                }
                if ($foundAuthor) { break }
            }
        }

        return [PSCustomObject]@{
            Author = $foundAuthor
            Year = $foundYear
            Reference = $foundReference
            Confidence = $confidence
        }
    } catch {
    Write-Error "Error in Identify-AuthorAndReference: $($_.Exception.Message)"
    Write-Log "Error en Identify-AuthorAndReference: $($_.Exception.Message)" "ERROR"
        return $null # Return null or an empty object on error
    }
}

function Process-TextFile {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory = $true)]
        [string]$FilePath,
    [Parameter(Mandatory = $true)]
        [string]$BaseDirectory, # The absolute path of the root text directory (e.g., $absTxtDir)
    [Parameter(Mandatory = $true)]
        [hashtable]$AuthorsDB
    )
    try {
        Write-Log "Procesando archivo: $FilePath" "INFO"
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $relativeDirPath = $FilePath.Substring($BaseDirectory.Length).TrimStart("\ ")
        $category = if ([string]::IsNullOrEmpty($relativeDirPath)) { "UNCATEGORIZED" } else { $relativeDirPath.Split("\ ")[0] } # Get top-level category

    $pages = Get-PageContent -RawContent $content
    $fileQuotes = @{}

    foreach ($page in $pages) {
            $quotes = Find-QuotesOnPage -PageText $page.Content
            foreach ($quoteText in $quotes) {
                $authorInfo = Identify-AuthorAndReference -ContextText $page.Content -AuthorsDB $AuthorsDB

                $authorIdentifier = if ($authorInfo.Author) { $authorInfo.Author } else { "UNIDENTIFIED_AUTHOR" }
                $yearIdentifier = if ($authorInfo.Year) { $authorInfo.Year } else { "NO_YEAR" }

                if (-not $fileQuotes.ContainsKey($category)) { $fileQuotes[$category] = @{} }
                if (-not $fileQuotes[$category].ContainsKey($yearIdentifier)) { $fileQuotes[$category][$yearIdentifier] = @{} }
                if (-not $fileQuotes[$category][$yearIdentifier].ContainsKey($authorIdentifier)) { $fileQuotes[$category][$yearIdentifier][$authorIdentifier] = @{} }
                if (-not $fileQuotes[$category][$yearIdentifier][$authorIdentifier].ContainsKey($quoteText)) {
                     $fileQuotes[$category][$yearIdentifier][$authorIdentifier][$quoteText] = [PSCustomObject]@{
                        Page = $page.PageNumber; Confidence = $authorInfo.Confidence; SourceFile = (Split-Path -Path $FilePath -Leaf); Reference = $authorInfo.Reference
                    }
                    Write-Log "Cita extraída: [$category][$yearIdentifier][$authorIdentifier] $quoteText" "DEBUG"
                }
            }
        }
    Write-Log "Archivo procesado: $FilePath" "SUCCESS"
    return $fileQuotes
    } catch {
        Write-Error "Error processing file '${FilePath}': $($_.Exception.Message)"
        Write-Log "Error procesando archivo '${FilePath}': $($_.Exception.Message)" "ERROR"
        return @{} # Return empty hashtable on error
    }
}

function Save-ExtractedQuotes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$QuotesDB,
        [Parameter(Mandatory=$true)]
        [string]$OutputBaseDir
    )

    foreach ($category in $QuotesDB.Keys) {
        foreach ($year in $QuotesDB[$category].Keys) {
            foreach ($author in $QuotesDB[$category][$year].Keys) {

                $quotesData = $QuotesDB[$category][$year][$author]
                if ($quotesData.Count -eq 0) { continue }

                $safeAuthorName = $author -replace '[^a-zA-Z0-9_.-]', ''
                $safeCategoryName = $category -replace '[^a-zA-Z0-9_.-]', ''
                $safeYearName = $year -replace '[^a-zA-Z0-9_.-]', ''

                $finalOutputDir = Join-Path -Path (Join-Path -Path $OutputBaseDir -ChildPath $safeCategoryName) -ChildPath $safeYearName
                $finalAuthorDir = Join-Path -Path $finalOutputDir -ChildPath $safeAuthorName
                try {
                    New-Item -Path $finalAuthorDir -ItemType Directory -Force | Out-Null
                    $outFile = Join-Path -Path $finalAuthorDir -ChildPath "extracted_quotes.md"
                    
                    $mdOutputLines = foreach($quote in $quotesData.GetEnumerator()) {
                        $quoteText = $quote.Name
                        $quoteInfo = $quote.Value
                        $referenceBlock = if ($quoteInfo.Reference) {
                            "- **Found Reference:** $($quoteInfo.Reference)"
                        } else {
                            ""
                        }
                        
                        # Using a here-string for robust multiline content
                        @"
"$quoteText"
$referenceBlock
- **Location in PDF:** [[p=$($quoteInfo.Page)]] | **Confidence:** $($quoteInfo.Confidence) | **Source:** $($quoteInfo.SourceFile)
---
"@
                    }
                    # Join with two newlines for separation between entries
                    $mdOutput = ($mdOutputLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join "`n`n"

                    Set-Content -Path $outFile -Value $mdOutput -Encoding utf8
                    Write-Log "Guardadas $($mdOutputLines.Count) citas para $author ($year) en $outFile" "SUCCESS"
                    Write-Verbose " -> Saved $($mdOutputLines.Count) quotes for $author ($year) in $outFile"
                } catch {
                    $errorMessage = $_.Exception.Message
                    Write-Error "Error guardando citas para $author ($year) en ${outFile}: $errorMessage"
                    Write-Log "Error guardando citas para $author ($year) en ${outFile}: $errorMessage" "ERROR"
                }
            }
        }
    }
}

function Invoke-QuoteExtraction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TxtDir,
        [Parameter(Mandatory=$true)]
        [string]$OutDir
    )

    Write-Verbose "Starting advanced quote extraction (v2.2)..."
    Write-Log "Inicio de extracción avanzada de citas (v2.2)" "INFO"
    $absTxtDir = (Resolve-Path -Path $TxtDir).Path
    $absOutDir = (Resolve-Path -Path $OutDir).Path
    
    # Load AuthorsDB within the main invocation function
    $moduleRoot = Split-Path -Parent $PSCommandPath # Get the directory of the module file itself
    $AuthorsDBPath = Join-Path -Path $moduleRoot -ChildPath "..\config\authors.json"
    if (-not (Test-Path $AuthorsDBPath)) {
        Write-Error "Error: authors.json not found at $AuthorsDBPath"
        Write-Log "No se encontró authors.json en $AuthorsDBPath" "ERROR"
        return
    }
    $AuthorsDB = (Get-Content -Path $AuthorsDBPath -Encoding UTF8 | ConvertFrom-Json) -as [hashtable]
    if (-not $AuthorsDB) {
        Write-Error "Error: Could not load authors.json or it's empty."
        Write-Log "No se pudo cargar authors.json o está vacío" "ERROR"
        return
    }

    $QuotesDB = @{}

    $txtFiles = Get-ChildItem -Path $absTxtDir -Filter *.txt -Recurse
    if ($txtFiles.Count -eq 0) {
        Write-Warning "No .txt files found."
        Write-Log "No se encontraron archivos .txt en $absTxtDir" "WARNING"
        return
    }

    foreach ($file in $txtFiles) {
        Write-Verbose "Processing: $($file.Name)"
        Write-Log "Procesando archivo TXT: $($file.FullName)" "INFO"
        $fileQuotes = Process-TextFile -FilePath $file.FullName -BaseDirectory $absTxtDir -AuthorsDB $AuthorsDB
        # Merge results from each file into the main QuotesDB
        foreach ($category in $fileQuotes.Keys) {
            if (-not $QuotesDB.ContainsKey($category)) { $QuotesDB[$category] = @{} }
            foreach ($year in $fileQuotes[$category].Keys) {
                if (-not $QuotesDB[$category].ContainsKey($year)) { $QuotesDB[$category][$year] = @{} }
                foreach ($author in $fileQuotes[$category][$year].Keys) {
                    if (-not $QuotesDB[$category][$year].ContainsKey($author)) { $QuotesDB[$category][$year][$author] = @{} }
                    foreach ($quoteText in $fileQuotes[$category][$year][$author].Keys) {
                        $QuotesDB[$category][$year][$author][$quoteText] = $fileQuotes[$category][$year][$author][$quoteText]
                    }
                }
            }
        }
    }

    Write-Verbose "Saving found quotes..."
    Write-Log "Guardando citas extraídas..." "INFO"
    Save-ExtractedQuotes -QuotesDB $QuotesDB -OutputBaseDir $absOutDir

    Write-Verbose "Advanced quote extraction (v2.2) completed."
    Write-Log "Extracción avanzada de citas completada." "SUCCESS"
}

Export-ModuleMember -Function *