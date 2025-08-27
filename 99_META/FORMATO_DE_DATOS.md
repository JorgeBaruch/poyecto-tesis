# Formato de Datos del Proyecto

Este documento describe la estructura y el formato esperados para los archivos de datos intermedios y de configuración utilizados en el pipeline de este proyecto. Sirve como un "contrato de datos" entre los diferentes scripts.

---

## 1. Textos Procesados (`00_FUENTES_PROCESADAS/`)

-   **Formato:** Archivos de texto plano (`.txt`).
-   **Codificación:** `UTF-8`.
-   **Estructura:**
    -   El contenido es el texto extraído directamente del PDF original.
    -   Cada página del documento original está marcada y separada por un identificador único: `[[p=NUMERO_DE_PAGINA]]`.
    -   Este marcador se inserta al principio del texto de cada nueva página.

**Ejemplo:**

```
[[p=1]]
Texto de la primera página.

[[p=2]]
Texto de la segunda página.
...
```

---

## 2. Fichas de Lectura (`01_FICHAS_DE_LECTURA/`)

-   **Formato:** Archivos Markdown (`.md`).
-   **Estructura:** Cada ficha debe seguir una plantilla basada en metadatos YAML Front Matter y secciones de Markdown.

**Ejemplo de Plantilla:**

```yaml
---
autor: "Apellido, Nombre"
año: AAAA
titulo: "Título del Documento"
fuente: "nombre_del_archivo_original.pdf"
---

### Resumen General

(Síntesis del documento en uno o dos párrafos).

### Conceptos Clave

-   **Concepto 1:** Definición o descripción.
-   **Concepto 2:** Definición o descripción.

### Citas Relevantes

> "[[p=45]] Texto de la cita textual..."

> "[[p=102]] Otra cita importante..."

```

---

## 3. Base de Datos de Citas (`97_CITAS/`)

-   **Formato:** La estructura de carpetas es la base de datos. Los archivos finales son `.md`.
-   **Estructura Jerárquica:**
    -   `97_CITAS/<Categoría>/<Año>/<AUTOR>.md`
    -   **Categoría:** El nombre de la subcarpeta dentro de `00_FUENTES` (ej. `Concepto_Valor`).
    -   **Año:** El año de publicación de la obra, extraído de la ficha de lectura.
    -   **AUTOR.md:** El nombre del autor en mayúsculas, extraído de la ficha de lectura.
-   **Contenido del Archivo:** Una lista de citas en formato Markdown.

---

## 4. Archivos de Configuración (`config/`)

### `authors.json`

-   **Propósito:** Mapear posibles variaciones del nombre de un autor a un único nombre canónico para estandarizar las referencias.
-   **Formato:** JSON.

**Ejemplo de Estructura:**

```json
{
  "MARX, KARL": [
    "Marx, K.",
    "K. Marx"
  ],
  "LACAN, JACQUES": [
    "Lacan, J.",
    "Jacques Lacan"
  ]
}
```
