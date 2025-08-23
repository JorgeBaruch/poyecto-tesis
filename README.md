# Proyecto de Tesis: Extracción y Análisis de Citas

Este repositorio contiene las herramientas y el flujo de trabajo para la extracción, procesamiento y análisis de citas de diversas fuentes documentales para un proyecto de tesis. Su objetivo es transformar documentos PDF en información estructurada y analizable.

## Estructura del Proyecto

- `00_FUENTES/`: Documentos PDF originales.
- `00_FUENTES_PROCESADAS/`: Versiones en texto plano de los documentos PDF.
- `01_FICHAS_DE_LECTURA/`: Fichas de lectura y resúmenes en formato Markdown.
- `02_MAPAS_Y_ESQUEMAS/`: Mapas conceptuales y esquemas de síntesis.
- `03_BORRADORES/`: Borradores y secciones en desarrollo de la tesis.
- `97_CITAS/`: Citas extraídas y organizadas por autor, año y categoría.
- `99_META/`: Metadocumentación del proyecto (arquitectura, decisiones, vocabulario).
- `tools/`: Scripts y utilidades para automatizar el flujo de trabajo.

## Flujo de Trabajo Automatizado

Para procesar todos los documentos del proyecto, simplemente ejecute el script orquestador principal desde la raíz del repositorio:

```powershell
.\tools\Start-FullProcess.ps1
```

Este comando se encargará de todo el proceso de forma automática:
1.  **Convertirá** los PDFs nuevos a texto.
2.  **Extraerá** las citas de los textos procesados.
3.  **Generará** las fichas de lectura para los documentos que no la tengan.

## Dependencias y Configuración

### 1. Poppler (pdftotext)

La herramienta `pdftotext` es esencial para convertir los documentos PDF a texto. El sistema es flexible y puede encontrar el ejecutable de varias maneras, en el siguiente orden de prioridad:

#### Opción 1: Configuración Central (Recomendado)

Es el método más robusto y portable.
1.  Abra el archivo `config/analysis.json`.
2.  Modifique la clave `pdftotextPath` para que apunte a la ubicación de su ejecutable `pdftotext.exe`. Use barras inclinadas hacia adelante (`/`).

    ```json
    {
      "pdftotextPath": "C:/ruta/a/poppler/bin/pdftotext.exe",
      "stopWords": [...],
      "conceptMapping": {...}
    }
    ```

#### Opción 2: Parámetro de Script

Puede pasar la ruta al ejecutable directamente al script `Convert-PdfToText.ps1` usando el parámetro `-PdftotextExecutablePath`. Esto sobrescribirá la ruta del archivo de configuración.

#### Opción 3: Variable de Entorno (PATH)

Si las opciones anteriores no se utilizan, el script buscará `pdftotext.exe` en el `PATH` de su sistema. Para que esto funcione, debe añadir la carpeta `bin` de su instalación de Poppler a las variables de entorno de Windows.

**Instalación de Poppler:** Si no tiene Poppler, puede instalarlo usando `winget install Poppler.Poppler` o descargándolo manualmente.

### 2. Python

Algunos scripts de análisis requieren Python. Se recomienda usar un entorno virtual.

1.  **Crear un entorno virtual:** `python -m venv .venv`
2.  **Activar el entorno:** `.\.venv\Scripts\activate` (en Windows)
3.  **Instalar dependencias:** `pip install -r requirements.txt`

## Git Hooks

El proyecto utiliza un hook `pre-commit` para versionar automáticamente los borradores en la carpeta `03_BORRADORES/`. El hook ya está configurado en el repositorio (`.git/hooks/pre-commit`) y debería funcionar sin necesidad de configuración manual.

Cada vez que realice un `git commit` de un archivo en `03_BORRADORES/`, el hook se ejecutará para asegurar que el archivo sigue la convención de nombrado de versiones (ej. `nombre_v1.md`).
