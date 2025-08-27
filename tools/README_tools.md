# Project Thesis Tools

This folder contains scripts and utilities to automate various tasks related to knowledge management for your thesis.

## Folder Structure

```
tools/
├── Analyze-Frequency.ps1
├── analyze_topics.py
├── Convert-PdfToText.ps1

├── Generate-ConceptIndex.ps1
├── Generate-ReadingCard.ps1
├── Generate-StrategicSynthesis.ps1
├── Organize-Sources.ps1
├── Test-PageExtraction.ps1
├── Validate-Structure.ps1
├── Version-Draft.ps1
├── README_tools.md                  # This file
│
└── utils/                           # Auxiliary scripts
    ├── Convert-OcrPdf.ps1            # For OCR processing of scanned PDFs
    └── test_pdftotext.ps1            # To test pdftotext installation
```

## Main Scripts

*   **`Convert-PdfToText.ps1`**: Este script transforma documentos PDF en texto plano (`.txt`) insertando marcadores de página `[[p=##]]`. Utiliza `pdftotext` para la conversión. **Requiere que `pdftotext` esté instalado y accesible en el PATH del sistema.**
    *   **Status:** Funcional y probado para PDFs.

*   **`CitaExtractor.psm1`**: Un módulo de PowerShell que contiene la lógica avanzada para procesar archivos de texto, identificar citas, extraer referencias y autores, y organizar los resultados en la carpeta `97_CITAS`. Este módulo es utilizado por las tareas automatizadas y reemplaza al antiguo script `Extract-QuotesFromText.ps1`.
    *   **Status:** Funcional y cubierto por pruebas unitarias en `tests/CitaExtractor.Tests.ps1`.

## Other Utilities

These scripts provide additional functionalities for project management and analysis:

*   **`Analyze-Frequency.ps1`**: Analyzes word frequency or other textual patterns.
*   **`analyze_topics.py`**: Performs topic modeling using TF-IDF and NMF to identify underlying themes and key terms in text documents.
*   **`Generate-ReadingCard.ps1`**: Generates structured reading cards from processed texts.
*   **`Generate-ConceptIndex.ps1`**: Creates an index of key concepts.
*   **`Generate-StrategicSynthesis.ps1`**: Generates strategic synthesis documents.
*   **`Organize-Sources.ps1`**: Helps organize source files.
*   **`Run-AllTests.ps1`**: Executes all Pester tests in the `tests/` directory, providing a quick way to verify project integrity.
*   **`Test-PageExtraction.ps1`**: (Previously `test_page_extraction.ps1`) Likely a script to test page extraction logic.
*   **`Validate-Structure.ps1`**: Validates the project's folder structure.
*   **`Version-Draft.ps1`**: Manages versions of your thesis drafts.

## How to Use

To run any of these scripts, open a PowerShell terminal in your project root and use the following format:

```powershell
.\tools\Script-Name.ps1 [parameters]
```

For example:

```powershell
.\tools\Generate-ReadingCard.ps1 -PdfPath "00_FUENTES/My_New_Book.pdf"
```

## Next Steps

Continue developing the placeholder scripts and expand test coverage for all modules. Ensure all documentation is up-to-date with the new naming conventions and project structure.

```