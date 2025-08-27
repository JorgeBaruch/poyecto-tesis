# Requiere Pester v3.x
# Test-Command: Invoke-Pester -Path "tests/Import-Source.Tests.ps1"

$scriptFile = (Resolve-Path "../tools/Import-Source.ps1").Path

Describe "Import-Source Script" {
    $tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())
    $inputDir = Join-Path -Path $tempDir -ChildPath "Input"
    $outputDir = Join-Path -Path $tempDir -ChildPath "Output"

    BeforeAll {
        New-Item -Path $inputDir -ItemType Directory -Force | Out-Null
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    AfterAll {
        Remove-Item -Path $tempDir -Recurse -Force
    }

    Context "cuando procesa archivos .txt" {
        It "debe copiar el archivo .txt al directorio de salida" {
            $sourceTxt = Join-Path -Path $inputDir -ChildPath "test.txt"
            $expectedTxt = Join-Path -Path $outputDir -ChildPath "test.txt"
            Set-Content -Path $sourceTxt -Value "Este es un archivo de prueba."

            & $scriptFile -InputDir $inputDir -OutDir $outputDir

            (Test-Path -Path $expectedTxt -PathType Leaf) | Should Be $true
            (Get-Content -Path $expectedTxt) | Should Be "Este es un archivo de prueba."
        }

        It "debe preservar la estructura de subdirectorios para los .txt" {
            $subDir = Join-Path -Path $inputDir -ChildPath "Sub"
            New-Item -Path $subDir -ItemType Directory | Out-Null
            $sourceTxt = Join-Path -Path $subDir -ChildPath "nested.txt"
            $expectedDir = Join-Path -Path $outputDir -ChildPath "Sub"
            $expectedTxt = Join-Path -Path $expectedDir -ChildPath "nested.txt"
            Set-Content -Path $sourceTxt -Value "Archivo anidado."

            & $scriptFile -InputDir $inputDir -OutDir $outputDir

            (Test-Path -Path $expectedTxt -PathType Leaf) | Should Be $true
            (Get-Content -Path $expectedTxt) | Should Be "Archivo anidado."
        }
    }

    Context "cuando procesa archivos .pdf" {
        BeforeEach {
            # Mock pdftotext para evitar dependencia externa
            Mock pdftotext {
                param($arguments)
                # Simula la creación de un archivo de texto por parte de pdftotext
                $outputPath = $arguments[-1].Trim('"'')
                Set-Content -Path $outputPath -Value "Contenido de PDF.\fPágina 2."
                return 0
            } -Verifiable
        }

        It "debe procesar un archivo .pdf y añadir marcadores de página" {
            $sourcePdf = Join-Path -Path $inputDir -ChildPath "document.pdf"
            $expectedTxt = Join-Path -Path $outputDir -ChildPath "document.txt"
            New-Item -Path $sourcePdf -ItemType File -Force | Out-Null

            & $scriptFile -InputDir $inputDir -OutDir $outputDir -PdftotextExecutablePath "pdftotext"

            (Test-Path -Path $expectedTxt -PathType Leaf) | Should Be $true
            $content = Get-Content -Path $expectedTxt -Raw
            $content | Should Match "\[\[p=1\]\]`nContenido de PDF."
            $content | Should Match "\[\[p=2\]\]`nPágina 2."
            Should -Invoke PesterMock -CommandName "pdftotext" -Times 1
        }
    }

    Context "cuando procesa archivos .docx" {
        BeforeEach {
            # Mock pandoc para evitar dependencia externa
            Mock pandoc {
                param($arguments)
                $outputPath = $arguments | Where-Object { $_ -eq "-o" } | Select-Object -Index 1
                Set-Content -Path $outputPath -Value "Contenido de DOCX."
                return 0
            } -Verifiable
        }

        It "debe procesar un archivo .docx usando pandoc" {
            $sourceDocx = Join-Path -Path $inputDir -ChildPath "document.docx"
            $expectedTxt = Join-Path -Path $outputDir -ChildPath "document.txt"
            New-Item -Path $sourceDocx -ItemType File -Force | Out-Null

            & $scriptFile -InputDir $inputDir -OutDir $outputDir -PandocExecutablePath "pandoc"

            (Test-Path -Path $expectedTxt -PathType Leaf) | Should Be $true
            (Get-Content -Path $expectedTxt) | Should Be "Contenido de DOCX."
            Should -Invoke PesterMock -CommandName "pandoc" -Times 1
        }
    }

    Context "manejo de errores y archivos no soportados" {
        It "debe ignorar archivos con extensiones no soportadas" {
            $sourceUnsupported = Join-Path -Path $inputDir -ChildPath "image.jpg"
            $expectedFile = Join-Path -Path $outputDir -ChildPath "image.txt"
            New-Item -Path $sourceUnsupported -ItemType File -Force | Out-Null

            & $scriptFile -InputDir $inputDir -OutDir $outputDir

            (Test-Path -Path $expectedFile) | Should Be $false
        }

        It "debe fallar si el InputDir no existe" {
            { & $scriptFile -InputDir "ruta/inexistente" -OutDir $outputDir } | Should Throw "Error: El directorio de entrada"
        }
    }
}
