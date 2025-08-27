# Arquitectura del Proyecto

> Última actualización: 2025-08-27
> Este documento describe la arquitectura técnica del sistema, sus componentes principales y los flujos de datos.

---

## 1. Mapa de Componentes

El sistema se compone de tres áreas principales, que interactúan de forma desacoplada:

1.  **Pipeline de Procesamiento de Datos:** Un conjunto de scripts (PowerShell y Python) que se ejecutan de forma secuencial para procesar documentos PDF y extraer información estructurada.
2.  **API Web:** Una API basada en FastAPI que expone los datos procesados o funcionalidades de análisis a través de endpoints HTTP.
3.  **Frontend:** Una aplicación web simple (HTML/CSS/JS) que actúa como interfaz de usuario para consumir los servicios de la API.

  <!-- Se recomienda generar un diagrama real con herramientas como diagrams.net (draw.io) o Mermaid -->

---

## 2. Flujo de Trabajo Principal (Pipeline de Datos)

El pipeline es el corazón del proyecto y sigue un flujo lineal orquestado por el script `Start-FullProcess.ps1`.

1.  **Ingesta:** Los PDFs se colocan en `00_FUENTES/`.
2.  **Conversión a Texto:** `tools/Convert-PdfToText.ps1` (usando `pdftotext`) convierte los PDFs a archivos `.txt` en `00_FUENTES_PROCESADAS/`, insertando marcadores de página.
3.  **Generación de Fichas:** Se crean fichas de lectura en formato Markdown en `01_FICHAS_DE_LECTURA/`.
4.  **Extracción y Análisis:** Scripts en `tools/` (como `CitaExtractor.psm1` y `analyze_topics.py`) procesan las fichas para generar citas, mapas conceptuales y síntesis en las carpetas `97_CITAS/`, `02_MAPAS_Y_ESQUEMAS/` y `04_SINTESIS/`.

---

## 3. Consideraciones de Diseño y Escalabilidad

### 3.1. Stack Tecnológico

*   **Backend/Pipeline:** Python, PowerShell
*   **API:** FastAPI (Python)
*   **Dependencias Notables:** `scikit-learn`, `nltk`, `PyYAML`, Poppler (`pdftotext`)

### 3.2. Limitaciones de Escalabilidad

La arquitectura actual está diseñada para ejecutarse en una única máquina. Su rendimiento es secuencial y está limitado por la CPU y la memoria disponibles.

*   **Cuello de Botella Identificado:** El procesamiento de PDFs y los análisis de NLP son las operaciones más costosas.
*   **Plan de Evolución Futuro:** Para un crecimiento a gran escala, se recomienda una re-arquitectura hacia un **modelo basado en eventos y serverless** (ej. AWS Lambda/S3, Azure Functions/Blob Storage). Esto permitiría el procesamiento paralelo y masivo de documentos, mejorando drásticamente la escalabilidad y el rendimiento.