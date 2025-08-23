<#
    Test file for CitaExtractor.psm1
    Estructura estándar: Contextos funcionales, de error y de integración.
    Mantener y expandir lógica avanzada aquí.
#>

# Importar el módulo a testear
$modulePath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\CitaExtractor.psm1"
Import-Module -Name $modulePath -Force

Describe "CitaExtractor.psm1" {
    Context "Carga y entorno de pruebas" {
        It "Debe importar el módulo sin errores" {
            { Import-Module -Name $modulePath -Force -ErrorAction Stop } | Should Not Throw
        }
        # TODO: Agregar pruebas de parámetros inválidos, rutas inexistentes, etc.
    }

    # --- CONTEXTOS FUNCIONALES AVANZADOS ---
    # Mock the authors.json loading for isolated testing
    BeforeAll {
        $mockAuthorsDB = @{
            "MARX" = @("Marx", "Karl Marx");
            "LACAN" = @("Lacan", "Jacques Lacan");
            "FREUD" = @("Freud", "Sigmund Freud");
            "DUSSEL" = @("Dussel", "Enrique Dussel");
            "DERRIDA" = @("Derrida", "Jacques Derrida");
            "NIETZSCHE" = @("Nietzsche", "Friedrich Nietzsche");
            "SOUZA" = @("Souza", "Jessé Souza");
            "HEATH" = @("Heath", "Stephen Heath");
        }
        Mock Get-Content { return ($mockAuthorsDB | ConvertTo-Json) } -ParameterFilter { $Path -like "*authors.json" }
        Mock ConvertFrom-Json { return $mockAuthorsDB }
    }

    Context "Get-PageContent function" {
        It "Should correctly extract page numbers and content" {
            $rawContent = "[[p=1]]Page 1 content." + "`f" + "[[p=2]]Page 2 content."
            $pages = Get-PageContent -RawContent $rawContent

            $pages.Count | Should Be 2
            $pages[0].PageNumber | Should Be "1"
            $pages[0].Content | Should Be "Page 1 content."
            $pages[1].PageNumber | Should Be "2"
            $pages[1].Content | Should Be "Page 2 content."
        }

        It "Should handle content without page numbers" {
            $rawContent = "Just some content." + "`f" + "Another page."
            $pages = Get-PageContent -RawContent $rawContent

            $pages.Count | Should Be 2
            $pages[0].PageNumber | Should Be 0
            $pages[0].Content | Should Be "Just some content."
            $pages[1].PageNumber | Should Be 0
            $pages[1].Content | Should Be "Another page."
        }

        It "Should handle empty content" {
            $rawContent = ""
            $pages = Get-PageContent -RawContent $rawContent

            $pages.Count | Should Be 0
        }
    }

    Context "Find-QuotesOnPage function" {
        It "Should find quotes enclosed in double quotes" {
            $pageText = 'This is a text with a "quote here". And another "second quote".'
            $quotes = Find-QuotesOnPage -PageText $pageText

            $quotes.Count | Should Be 2
            ($quotes | Where-Object { $_ -eq 'quote here' }).Count | Should Be 1
            ($quotes | Where-Object { $_ -eq 'second quote' }).Count | Should Be 1
        }

        It "Should handle no quotes" {
            $pageText = "This text has no quotes."
            $quotes = Find-QuotesOnPage -PageText $pageText

            $quotes.Count | Should Be 0
        }

        It "Should handle empty string" {
            $pageText = ""
            $quotes = Find-QuotesOnPage -PageText $pageText

            $quotes.Count | Should Be 0
        }
    }

    Context "Identify-AuthorAndReference function" {
        It "Should identify author and reference from APA-like citation (Author, Year)" {
            $contextText = 'Some text (Marx, 1867) with a quote.'
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be 'MARX'
            $result.Year | Should Be '1867'
            $result.Reference | Should Be '(Marx, 1867)'
            $result.Confidence | Should Be 'apa'
        }

        It "Should identify author from alias in APA-like citation" {
            $contextText = 'Another text (K. Marx, 1867) with a quote.'
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be 'MARX'
            $result.Year | Should Be '1867'
            $result.Reference | Should Be '(K. Marx, 1867)'
            $result.Confidence | Should Be 'alias_in_apa'
        }

        It "Should identify author from loose alias in context" {
            $contextText = 'Lacan states that something is true.'
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be 'LACAN'
            $result.Year | Should Be ''
            $result.Reference | Should Be ''
            $result.Confidence | Should Be 'loose_alias'
        }

        It "Should handle multiple citations and pick the first valid one" {
            $contextText = 'Text (Unknown, 2000) and then (Freud, 1905) a quote.'
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be 'FREUD'
            $result.Year | Should Be '1905'
            $result.Reference | Should Be '(Freud, 1905)'
            $result.Confidence | Should Be 'apa'
        }

        It "Should return UNIDENTIFIED_AUTHOR if no author is found" {
            $contextText = 'Some text with no known author or citation (Anon, 2020).'
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be 'UNIDENTIFIED_AUTHOR'
            $result.Year | Should Be '2020'
            $result.Reference | Should Be '(Anon, 2020)'
            $result.Confidence | Should Be 'apa' # Still APA if year pattern matches
        }

        It "Should return empty year if no year is found in citation" {
            $contextText = 'Some text (Marx) with a quote.'
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be 'MARX'
            $result.Year | Should Be ''
            $result.Reference | Should Be '(Marx)'
            $result.Confidence | Should Be 'apa'
        }

        It "Should handle empty context text" {
            $contextText = ''
            $result = Identify-AuthorAndReference -ContextText $contextText
            $result.Author | Should Be $null
            $result.Year | Should Be ''
            $result.Reference | Should Be ''
            $result.Confidence | Should Be 'unknown'
        }
    }

    Context "Process-TextFile function" {
        BeforeEach {
            # Mock Get-Content for the files being processed
            Mock Get-Content {
                param($Path, $Raw, $Encoding)
                if ($Path -like '*file1.txt') {
                    return '[[p=1]]"Quote from file 1, page 1". (Marx, 1867)' + "`f" + '[[p=2]]Some text. "Another quote from file 1".'
                } elseif ($Path -like '*subdir\\file2.txt') {
                    return '[[p=1]]"Quote from file 2". (Lacan, 1960)'
                }
                return ''
            }
            # Mock Get-ChildItem to simulate text files
            Mock Get-ChildItem {
                param($Path, $Filter, $Recurse)
                if ($Path -like "*test_txt_dir*") {
                    return @(
                        [PSCustomObject]@{ FullName = "C:\test_txt_dir\file1.txt"; Name = "file1.txt"; Directory = [PSCustomObject]@{ FullName = "C:\test_txt_dir" } },
                        [PSCustomObject]@{ FullName = "C:\test_txt_dir\subdir\file2.txt"; Name = "file2.txt"; Directory = [PSCustomObject]@{ FullName = "C:\test_txt_dir\subdir" } }
                    )
                }
                return @()
            }
            # Mock Resolve-Path for BaseDirectory
            Mock Resolve-Path {
                param($Path)
                return [PSCustomObject]@{ Path = "C:\test_txt_dir" }
            }
        }

        It "Should correctly process text files and extract quotes with author info" {
            $txtDir = "C:\test_txt_dir"
            $baseDirectory = "C:\test_txt_dir"
            $result = Process-TextFile -FilePath "C:\test_txt_dir\file1.txt" -BaseDirectory $baseDirectory

            $result.Keys | Should Contain "file1.txt" # Category should be the file name if no subdir
            $result."file1.txt".Keys | Should Contain "1867"
            $result."file1.txt"."1867".Keys | Should Contain "MARX"
            $result."file1.txt"."1867".MARX.Keys | Should Contain "Quote from file 1, page 1"
            $result."file1.txt"."1867".MARX."Quote from file 1, page 1".Page | Should Be 1

            # Test the second quote from file1.txt (no author/year in its immediate context)
            $result."file1.txt".NO_YEAR.UNIDENTIFIED_AUTHOR.Keys | Should Contain "Another quote from file 1"
            $result."file1.txt".NO_YEAR.UNIDENTIFIED_AUTHOR."Another quote from file 1".Page | Should Be 2
        }

        It "Should correctly categorize files from subdirectories" {
            $txtDir = "C:\test_txt_dir"
            $baseDirectory = "C:\test_txt_dir"
            $result = Process-TextFile -FilePath "C:\test_txt_dir\subdir\file2.txt" -BaseDirectory $baseDirectory

            $result.Keys | Should Contain "subdir" # Category should be the top-level subdir
            $result.subdir.Keys | Should Contain "1960"
            $result.subdir."1960".Keys | Should Contain "LACAN"
            $result.subdir."1960".LACAN.Keys | Should Contain "Quote from file 2"
            $result.subdir."1960".LACAN."Quote from file 2".Page | Should Be 1
        }

        It "Should handle empty text file content" {
            Mock Get-Content { return "" } -ParameterFilter { $Path -like "*empty_file.txt*" }
            $result = Process-TextFile -FilePath "C:\test_txt_dir\empty_file.txt" -BaseDirectory "C:\test_txt_dir"
            $result.Count | Should Be 0
        }
    }

    Context "Save-ExtractedQuotes function" {
        BeforeEach {
            # Mock New-Item and Set-Content to prevent actual file system changes
            Mock New-Item { param($Path, $ItemType, $Force) }
            Mock Set-Content { param($Path, $Value, $Encoding) }
        }

        It "Should create correct directory structure and save quotes" {
            $quotesDB = @{
                "Category1" = @{
                    "2020" = @{
                        "AUTHOR1" = @{
                            "Quote 1" = [PSCustomObject]@{ Page = 1; Confidence = "high"; SourceFile = "file1.txt"; Reference = "(Author1, 2020)" }
                            "Quote 2" = [PSCustomObject]@{ Page = 5; Confidence = "medium"; SourceFile = "file1.txt"; Reference = "" }
                        }
                    }
                };
                "Category2" = @{
                    "NO_YEAR" = @{
                        "UNIDENTIFIED_AUTHOR" = @{
                            "Quote 3" = [PSCustomObject]@{ Page = 10; Confidence = "low"; SourceFile = "file2.txt"; Reference = "" }
                        }
                    }
                }
            }
            $outputBaseDir = "C:\OutputQuotes"

            Save-ExtractedQuotes -QuotesDB $quotesDB -OutputBaseDir $outputBaseDir

            # Verify New-Item calls
            Assert-MockCalled New-Item -ParameterFilter { $Path -like "*Category1*" -and $Path -like "*2020*" -and $Path -like "*AUTHOR1*" } -Times 1
            Assert-MockCalled New-Item -ParameterFilter { $Path -like "*Category2*" -and $Path -like "*NO_YEAR*" -and $Path -like "*UNIDENTIFIED_AUTHOR*" } -Times 1

            # Verify Set-Content calls and content
                Assert-MockCalled Set-Content -ParameterFilter {
                    $Path -like '*Category1\\2020\\AUTHOR1\\extracted_quotes.md*' -and
                    $Value -like '*Quote 1*' -and $Value -like '*[[p=1]]*' -and $Value -like '*Confidence: high*' -and $Value -like '*Source: file1.txt*' -and $Value -like '*Reference: (Author1, 2020)*' -and
                    $Value -like '*Quote 2*' -and $Value -like '*[[p=5]]*' -and $Value -like '*Confidence: medium*' -and $Value -notlike '*Reference:*'
                } -Times 1

                Assert-MockCalled Set-Content -ParameterFilter {
                    $Path -like '*Category2\\NO_YEAR\\UNIDENTIFIED_AUTHOR\\extracted_quotes.md*' -and
                    $Value -match 'Quote 3' -and $Value -match '\[\[p=10\]\]' -and $Value -match 'Confidence: low' -and $Value -notmatch 'Reference:'
                } -Times 1
            Assert-MockCalled Set-Content -ParameterFilter {
                $Path -like "*Category2\NO_YEAR\UNIDENTIFIED_AUTHOR\extracted_quotes.md*" -and
                $Value -like "*"Quote 3"*" -and $Value -like "*[[p=10]]*" -and $Value -like "*Confidence: low*" -and $Value -notlike "*Reference:*"
            } -Times 1
        }

        It "Should not create files for empty author data" {
            $quotesDB = @{
                "Category1" = @{
                    "2020" = @{
                        "AUTHOR1" = @{} # Empty author data
                    }
                }
            }
            $outputBaseDir = "C:\OutputQuotes"

            Save-ExtractedQuotes -QuotesDB $quotesDB -OutputBaseDir $outputBaseDir

            Assert-MockCalled New-Item -Times 0
            Assert-MockCalled Set-Content -Times 0
        }
    }

    Context "Invoke-QuoteExtraction function" {
        BeforeEach {
            # Mock internal functions called by Invoke-QuoteExtraction
            Mock Process-TextFile { param($FilePath, $BaseDirectory) return @{ "MockCategory" = @{ "MockYear" = @{ "MockAuthor" = @{ "MockQuote" = [PSCustomObject]@{ Page = 1; Confidence = "test"; SourceFile = "mock.txt"; Reference = "(Mock, 2023)" } } } } } } # Simplified mock return
            Mock Save-ExtractedQuotes { param($QuotesDB, $OutputBaseDir) }
            Mock Get-ChildItem { param($Path, $Filter, $Recurse) return @([PSCustomObject]@{ FullName = "C:\test_txt_dir\mock.txt"; Name = "mock.txt" }) }
            Mock Resolve-Path { param($Path) return [PSCustomObject]@{ Path = "C:\test_dir" } }
        }

        It "Should call Process-TextFile and Save-ExtractedQuotes" {
            Invoke-QuoteExtraction -TxtDir "C:\test_dir" -OutDir "C:\output_dir"

            Assert-MockCalled Process-TextFile -Times 1
            Assert-MockCalled Save-ExtractedQuotes -Times 1
        }

        It "Should handle no text files found" {
            Mock Get-ChildItem { param($Path, $Filter, $Recurse) return @() }
            Invoke-QuoteExtraction -TxtDir "C:\test_dir" -OutDir "C:\output_dir"

            Assert-MockCalled Process-TextFile -Times 0
            Assert-MockCalled Save-ExtractedQuotes -Times 0
        }
    }
    # --- CONTEXTOS DE ERRORES Y CASOS LÍMITE ---
    Context "Manejo de errores y casos límite" {
        It "Debe manejar rutas de archivo inexistentes sin lanzar excepción" {
            { Process-TextFile -FilePath 'Z:\ruta\inexistente.txt' -BaseDirectory 'Z:\ruta' } | Should Not Throw
        }
        # TODO: Agregar más pruebas de errores de entrada, archivos corruptos, permisos, etc.
    }
}
