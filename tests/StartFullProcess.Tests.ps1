
Describe "Start-FullProcess.ps1 Integration" {
    # Path to the script under test
    $scriptToTest = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "tools\Start-FullProcess.ps1"

    BeforeAll {
        # Define temporary directories for testing
        $tempTestDir = Join-Path -Path $PSScriptRoot -ChildPath "temp_StartFullProcess_test"
        $tempFuentesDir = Join-Path -Path $tempTestDir -ChildPath "00_FUENTES"
        $tempProcesadosDir = Join-Path -Path $tempTestDir -ChildPath "00_FUENTES_PROCESADAS"
        $tempFichasDir = Join-Path -Path $tempTestDir -ChildPath "01_FICHAS_DE_LECTURA"
        $tempCitasDir = Join-Path -Path $tempTestDir -ChildPath "97_CITAS"
        $tempLogsDir = Join-Path -Path $tempTestDir -ChildPath "logs"

        # Clean up any previous test runs
        if (Test-Path $tempTestDir) {
            Remove-Item $tempTestDir -Recurse -Force
        }
        # Create necessary temporary directories
        New-Item -ItemType Directory -Path $tempFuentesDir | Out-Null
        New-Item -ItemType Directory -Path $tempProcesadosDir | Out-Null
        New-Item -ItemType Directory -Path $tempFichasDir | Out-Null
        New-Item -ItemType Directory -Path $tempCitasDir | Out-Null
        New-Item -ItemType Directory -Path $tempLogsDir | Out-Null

        # Create a dummy PDF file for testing
        $dummyPdfContent = "This is a dummy PDF content for testing purposes."
        Set-Content -Path (Join-Path $tempFuentesDir "dummy_document.pdf") -Value $dummyPdfContent -Encoding UTF8
    }

    AfterAll {
        # Clean up temporary directories after all tests are done
        # The tempTestDir is defined in BeforeAll, so it needs to be accessed from a scope that has it.
        # For AfterAll, we can redefine it or ensure it's passed/accessible.
        # A simpler approach for AfterAll is to just use the same logic as BeforeAll to get the path.
        $tempTestDir = Join-Path -Path $PSScriptRoot -ChildPath "temp_StartFullProcess_test"
        if (Test-Path $tempTestDir) {
            Remove-Item $tempTestDir -Recurse -Force
        }
    }

    It "should run the full process without errors and create expected output files" {
        # Execute the script with temporary directories
        $projectRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName # This is the tests directory
        $scriptToExecute = Join-Path -Path $projectRoot -ChildPath "tools\Start-FullProcess.ps1"

        # Define temporary directories for this test run
        $tempTestRoot = Join-Path -Path $PSScriptRoot -ChildPath "temp_StartFullProcess_test_run"
        $tempFuentes = Join-Path -Path $tempTestRoot -ChildPath "00_FUENTES"
        $tempProcesados = Join-Path -Path $tempTestRoot -ChildPath "00_FUENTES_PROCESADAS"
        $tempFichas = Join-Path -Path $tempTestRoot -ChildPath "01_FICHAS_DE_LECTURA"
        $tempCitas = Join-Path -Path $tempTestRoot -ChildPath "97_CITAS"
        $tempLogs = Join-Path -Path $tempTestRoot -ChildPath "logs"

        # Ensure temporary directories exist for this test run
        New-Item -ItemType Directory -Path $tempFuentes -Force | Out-Null
        New-Item -ItemType Directory -Path $tempProcesados -Force | Out-Null
        New-Item -ItemType Directory -Path $tempFichas -Force | Out-Null
        New-Item -ItemType Directory -Path $tempCitas -Force | Out-Null
        New-Item -ItemType Directory -Path $tempLogs -Force | Out-Null

        # Create a dummy PDF file for testing in the temporary Fuentes directory
        $dummyPdfContent = "This is a dummy PDF content for testing purposes."
        Set-Content -Path (Join-Path $tempFuentes "dummy_document.pdf") -Value $dummyPdfContent -Encoding UTF8

        # Mock pdftotext.exe to simulate successful conversion
        Mock -CommandName (Get-Command pdftotext).Path {
            param($arguments)
            # Extract the output path from the arguments
            $outputPath = $arguments[-1].Trim('`"') # Last argument is the output path
            Write-Host "Mock creating file at: $outputPath"

            # Simulate pdftotext output
            Set-Content -Path $outputPath -Value "Mocked PDF content for testing. [[p=1]] Page 1. [[p=2]] Page 2." -Encoding UTF8

            # Simulate successful exit code
            $LASTEXITCODE = 0
        }

        # Mock Get-ExecutablePath within Import-Source.ps1 to return the path to the mocked pdftotext
        Mock -CommandName Get-ExecutablePath -ModuleName Import-Source.ps1 {
            param($exeName, $configKey, $manualPath)
            if ($exeName -eq "pdftotext") {
                return (Get-Command pdftotext).Path # Return the path to the mocked pdftotext
            }
            # For other executables, call the original Get-ExecutablePath
            Invoke-MockedCommand -CommandName Get-ExecutablePath -Arguments @($exeName, $configKey, $manualPath)
        }

        # Execute Start-FullProcess.ps1 with the temporary paths
        powershell.exe -File $scriptToExecute `
            -ProjectRootPath $tempTestRoot `
            -FuentesDirPath $tempFuentes `
            -ProcesadosDirPath $tempProcesados `
            -FichasDirPath $tempFichas `
            -CitasDirPath $tempCitas `
            -LogsDirPath $tempLogs `
            -PdftotextExecutablePath (Get-Command pdftotext).Path `
            -ErrorAction Stop

        # Assertions
        # Check if the processed text file exists
        (Test-Path (Join-Path $tempProcesados "dummy_document.txt")) | Should Be $true

        # Check if the reading card file exists (assuming it's generated for new sources)
        (Test-Path (Join-Path $tempFichas "dummy_document_ficha.md")) | Should Be $true

        # Check if the profiling results file exists
        (Test-Path (Join-Path $tempLogs "profiling_results.txt")) | Should Be $true

        # Clean up temporary directories after the test
        Remove-Item $tempTestRoot -Recurse -Force
    }
}
