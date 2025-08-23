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

## Dependencias

Para el correcto funcionamiento de los scripts, es necesario tener instalada la herramienta `pdftotext` de la suite Poppler y las dependencias de Python.

### Instalación de Poppler (Windows)

Se recomienda instalar Poppler a través de un gestor de paquetes como `winget` o descargarlo directamente.

#### Opción 1: Usando `winget` (Recomendado)

Abre una terminal de PowerShell o Símbolo del Sistema y ejecuta el siguiente comando:

```bash
winget install Poppler.Poppler
```

#### Opción 2: Descarga Manual

1.  Visita la página oficial de Poppler o un repositorio de binarios confiable (por ejemplo, [https://poppler.freedesktop.org/](https://poppler.freedesktop.org/) o buscar "Poppler for Windows").
2.  Descarga la versión más reciente de los binarios para Windows.
3.  Descomprime el archivo ZIP en una ubicación de tu elección (ej. `C:\Program Files\poppler`).
4.  Añade la ruta a la carpeta `bin` de Poppler a la variable de entorno `Path` de tu sistema. Esto permitirá que `pdftotext` sea accesible desde cualquier terminal.

    *   **Pasos para añadir al Path:**
        1.  Busca "Editar las variables de entorno del sistema" en el menú de inicio de Windows.
        2.  Haz clic en "Variables de entorno...".
        3.  En la sección "Variables del sistema", selecciona `Path` y haz clic en "Editar...".
        4.  Haz clic en "Nuevo" y añade la ruta completa a la carpeta `bin` de Poppler (ej. `C:\Program Files\poppler\bin`).
        5.  Haz clic en "Aceptar" en todas las ventanas para guardar los cambios.

Después de la instalación, puedes verificar que `pdftotext` está disponible abriendo una nueva terminal y ejecutando:

```bash
pdftotext -v
```

Deberías ver la información de la versión de Poppler.

### Dependencias de Python

Algunos scripts en la carpeta `tools/` (ej. `analizar_temas.py`) requieren librerías de Python. Se recomienda usar un entorno virtual para gestionar estas dependencias.

1.  **Crear un entorno virtual (si no tienes uno):**
    ```bash
    python -m venv .venv
    ```
2.  **Activar el entorno virtual:**
    *   **Windows:**
        ```bash
        \ .\.venv\Scripts\activate
        ```
    *   **macOS/Linux:**
        ```bash
        source ./.venv/bin/activate
        ```
3.  **Instalar las dependencias:**
    ```bash
    pip install -r requirements.txt
    ```

## Git Hooks

El proyecto utiliza Git hooks para automatizar ciertas tareas de versionado. Específicamente, el script `tools/Version-Draft.ps1` está diseñado para ejecutarse como un hook `pre-commit` para asegurar que los borradores en `03_BORRADORES/` sigan una convención de nombrado consistente (`YYYY-MM-DD_nombre.md`).

Para configurar el hook `pre-commit`:

1.  Abre tu terminal en la raíz del repositorio.
2.  Crea o edita el archivo `pre-commit` dentro de la carpeta `.git/hooks/`.
    *   **Windows (PowerShell):**
        ```powershell
        Set-Content -Path .\.git\hooks\pre-commit -Value @'
        #!/usr/bin/env pwsh
        .\tools\Version-Draft.ps1
        '@
        ```
    *   **macOS/Linux (Bash:
        ```bash
        echo '#!/bin/bash' > .git/hooks/pre-commit
        echo 'pwsh ./tools/Version-Draft.ps1' >> .git/hooks/pre-commit
        chmod +x .git/hooks/pre-commit
        ```
3.  Asegúrate de que el archivo `pre-commit` sea ejecutable (en macOS/Linux, usa `chmod +x .git/hooks/pre-commit`).

Ahora, cada vez que intentes hacer un `git commit`, el script `Version-Draft.ps1` se ejecutará automáticamente para versionar tus borradores.