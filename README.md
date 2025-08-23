# Proyecto de Tesis: Extracción y Análisis de Citas

Este repositorio contiene las herramientas y el flujo de trabajo para la extracción, procesamiento y análisis de citas de diversas fuentes documentales para un proyecto de tesis. Su objetivo es transformar documentos PDF, DOCX y TXT en información estructurada y analizable.

## Estructura del Proyecto

- `00_FUENTES/`: Documentos fuente originales (PDF, DOCX, TXT).
- `00_FUENTES_PROCESADAS/`: Versiones en texto plano de los documentos.
- `01_FICHAS_DE_LECTURA/`: Fichas de lectura y resúmenes en formato Markdown.
- `02_MAPAS_Y_ESQUEMAS/`: Mapas conceptuales y esquemas de síntesis.
- `03_BORRADORES/`: Borradores y secciones en desarrollo de la tesis.
- `97_CITAS/`: Citas extraídas y organizadas por autor, año y categoría.
- `99_META/`: Metadocumentación del proyecto (arquitectura, decisiones, vocabulario).
- `tools/`: Scripts y utilidades para automatizar el flujo de trabajo.
- `api/`: Contiene la API de backend en Python.
- `frontend/`: Contiene los archivos de la interfaz de usuario web (HTML, CSS, JS).

## Flujo de Trabajo Automatizado

Para procesar todos los documentos del proyecto, simplemente ejecute el script orquestador principal desde la raíz del repositorio:

```powershell
.\tools\Start-FullProcess.ps1
```

Este comando se encargará de todo el proceso de forma automática:
1.  **Importará y convertirá** todas las fuentes soportadas (PDF, DOCX, TXT) a texto plano.
2.  **Extraerá** las citas de los textos procesados.
3.  **Generará** las fichas de lectura para los documentos que no la tengan.

## Dependencias y Configuración

El sistema depende de herramientas externas para la conversión de documentos. Se configuran principalmente a través del archivo `config/analysis.json`.

### 1. Poppler (para PDFs)

La herramienta `pdftotext` es esencial para convertir los documentos PDF a texto.

**Instalación:** `winget install Poppler.Poppler` o descarga manual.

**Configuración:** Después de instalar, configure la ruta al ejecutable en `config/analysis.json`:

```json
{
  "pdftotextPath": "C:/ruta/a/poppler/bin/pdftotext.exe",
  "pandocPath": "C:/ruta/a/pandoc/pandoc.exe",
  "stopWords": [...],
  "conceptMapping": {...}
}
```
El script `Import-Source.ps1` también buscará la herramienta en el PATH del sistema si la ruta en el archivo de configuración no es válida.

### 2. Pandoc (para DOCX)

La herramienta `pandoc` se utiliza para convertir documentos de Word (`.docx`) a texto plano.

**Instalación:** `winget install Pandoc.Pandoc` o descargue el instalador desde el sitio web oficial de Pandoc.

**Configuración:** Al igual que con Poppler, la ruta al ejecutable de `pandoc` debe especificarse en `config/analysis.json`, como se muestra en el ejemplo anterior.

### 3. Python

Algunos scripts de análisis requieren Python. Se recomienda usar un entorno virtual.

1.  **Crear un entorno virtual:** `python -m venv .venv`
2.  **Activar el entorno:** `.\.venv\Scripts\activate` (en Windows)
3.  **Instalar dependencias:** `pip install -r requirements.txt`

## Git Hooks

El proyecto utiliza un hook `pre-commit` para versionar automáticamente los borradores en la carpeta `03_BORRADORES/`. El hook ya está configurado en el repositorio y funciona sin necesidad de configuración manual.

## Interfaz de Usuario y API

Para facilitar la interacción con el proyecto, se ha desarrollado una interfaz de usuario web que se comunica con una API de backend local.

### Cómo ejecutar la API y la Interfaz

1.  **Asegúrese de tener las dependencias de Python instaladas.** Si es la primera vez o si el archivo `requirements.txt` ha cambiado, ejecute:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Inicie el servidor de la API.** Desde la carpeta raíz del proyecto, ejecute el siguiente comando:
    ```bash
    uvicorn api.main:app --reload --app-dir .
    ```
    *Nota: El parámetro `--app-dir .` es importante para que `uvicorn` sirva correctamente los archivos estáticos del frontend.*

3.  **Abra la interfaz.** Una vez que el servidor esté en funcionamiento, podrá acceder a la interfaz de usuario desde su navegador en la dirección `http://127.0.0.1:8000/frontend/index.html`.
