# Proyecto Tesis

Este repositorio contiene las herramientas y el flujo de trabajo para un proyecto de investigación y tesis. El sistema está diseñado para procesar fuentes de documentos (PDF), extraer información, analizarla y generar síntesis estructuradas.

---

## ⚙️ Instalación y Configuración

Para ejecutar este proyecto correctamente, se requiere la siguiente configuración de entorno.

### 1. Dependencias de Python

Asegúrese de tener Python 3.8+ instalado. Luego, instale las librerías necesarias utilizando pip y el archivo `requirements.txt`:

```bash
pip install -r requirements.txt
```

### 2. Dependencia Externa: Poppler (`pdftotext`)

El pipeline de procesamiento de datos depende de la herramienta `pdftotext`, que es parte de la suite Poppler.

1.  **Descargar Poppler:** Descargue los binarios más recientes de Poppler para Windows desde [esta página](https://github.com/oschwartz10612/poppler-windows/releases/). Se recomienda la última versión.
2.  **Descomprimir:** Descomprima el archivo `.zip` en una ubicación estable en su sistema (por ejemplo, `d:\tools\poppler-24.08.0`).
3.  **Añadir al PATH:** Añada la ruta a la carpeta `bin` de Poppler (ej. `d:\tools\poppler-24.08.0\Library\bin`) a la variable de entorno `PATH` de su sistema. Esto permite que los scripts encuentren el ejecutable `pdftotext.exe`.
4.  **Verificar:** Abra un nuevo terminal (PowerShell o CMD) y ejecute `pdftotext -v`. Debería ver la información de la versión, confirmando que la instalación fue exitosa.

### 3. Dependencia Externa: Pandoc (Opcional, para .docx)

Para procesar archivos de Microsoft Word (`.docx`), el sistema utiliza Pandoc.

1.  **Instalar Pandoc:** Descargue e instale la última versión desde la [página oficial de Pandoc](https://pandoc.org/installing.html).
2.  **Añadir al PATH:** Asegúrese de que la ruta al ejecutable de Pandoc esté en la variable de entorno `PATH` de su sistema. El instalador de Windows generalmente se encarga de esto automáticamente.
3.  **Verificar:** Abra un nuevo terminal y ejecute `pandoc --version`. Debería ver la información de la versión.

### 4. Claves de API

Si alguna funcionalidad requiere claves de API (por ejemplo, para servicios de IA), estas deben configurarse como variables de entorno. No deben guardarse en archivos de configuración.

**Ejemplo:**

```powershell
# En PowerShell
$env:OPENAI_API_KEY="TU_CLAVE_DE_API_AQUI"
```

## 🚀 Uso del Proyecto

### Ejecutar el Pipeline de Procesamiento de Datos

El flujo principal de procesamiento de datos ahora es un proceso completo de 5 pasos que se ejecuta con un único script orquestador. Este script se encarga de:
1. Convertir PDFs y otros formatos a texto.
2. Extraer citas.
3. Generar fichas de lectura.
4. Crear/actualizar el índice de conceptos.
5. Generar una nueva síntesis estratégica.

Para ejecutarlo:

```powershell
./tools/Start-FullProcess.ps1
```
*Asegúrate de haber colocado los archivos PDF fuente en la carpeta `00_FUENTES`.*

### Iniciar la API

Para exponer los resultados a través de la API:

```bash
uvicorn api.main:app --reload
```

### Ver el Frontend

Una vez que la API esté en funcionamiento, simplemente abre el archivo `frontend/index.html` en tu navegador.

## 🤝 Cómo Contribuir

Las contribuciones para mejorar este proyecto son bienvenidas. Por favor, sigue estas guías:

1.  **Estándares de Código:** Asegúrate de que tu código pase las validaciones de calidad. Ejecuta el script de validación antes de confirmar tus cambios:
    ```powershell
    ./Invoke-Validation.ps1
    ```
2.  **Flujo de Trabajo:** Trabaja en una rama separada y abre un Pull Request a la rama `main` para integrar tus cambios.

Para más detalles, consulta el archivo `CONTRIBUTING.md`.