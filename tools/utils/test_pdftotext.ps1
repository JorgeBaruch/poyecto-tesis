#!/usr/bin/env pwsh
# Este script es un placeholder para probar la instalación de pdftotext.
# Su objetivo es verificar que pdftotext esté en el PATH y funcione correctamente.

function Test-PdftotextInstallation {
    try {
        $process = Start-Process -FilePath "pdftotext" -ArgumentList "-v" -NoNewWindow -PassThru -ErrorAction Stop
        $process | Wait-Process
        if ($process.ExitCode -eq 0) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

Test-PdftotextInstallation