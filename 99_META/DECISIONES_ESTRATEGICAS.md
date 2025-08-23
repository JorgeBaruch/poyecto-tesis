

# Decisiones Estratégicas del Proyecto

> **Nota:** Este documento es parte de un sistema interdependiente junto con `BITACORA_DE_PROYECTO.md` y `ARQUITECTURA_DEL_PROYECTO.md`. Toda decisión, cambio metodológico o estructural relevante debe reflejarse y justificarse de manera coherente en los tres archivos para asegurar trazabilidad y continuidad.

Este documento registra los dilemas, justificaciones, trade-offs y aprendizajes de las decisiones de alto nivel tomadas durante el desarrollo del proyecto.

---

## 16 de agosto de 2025

### Dilema:
La suite de tests presentaba errores persistentes de sintaxis y estructura, y no era completamente automática ni reproducible en entornos CI/CD.

### Opciones Consideradas:
1.  Mantener los tests mínimos y corregir solo los errores críticos.
2.  Realizar una reescritura integral, automatizando la creación/limpieza de archivos dummy y asegurando compatibilidad total con Pester 3.x y CI/CD.

### Decisión Tomada y Justificación:
Se optó por la **Opción 2**. Se reescribieron los tests, se automatizó la gestión de archivos temporales y se validó la suite en verde. Esto garantiza reproducibilidad, robustez y facilita la integración continua.

### Trade-offs (Ganancias y Pérdidas):
*   **Ganancia:** Tests confiables, reproducibles y mantenibles; base sólida para futuras expansiones y refactorizaciones.
*   **Pérdida:** Tiempo invertido en depuración y reescritura, mitigado por la ganancia en calidad y trazabilidad.

### Aprendizajes Clave:
La automatización y robustecimiento de tests es esencial para la sostenibilidad técnica del proyecto y la facilidad de retomarlo tras pausas.


## 13 de agosto de 2025

### Dilema:
La carpeta `00_FUENTES` contenía 45 archivos PDF sin una organización interna, lo que dificultaba la localización de textos específicos y la comprensión de la base de conocimiento de un vistazo. Esto fue identificado como un riesgo de escalabilidad en `ARQUITECTURA_DEL_PROYECTO.md`.

### Opciones Consideradas:
1.  **Mantener la estructura plana:** Rápido a corto plazo, pero ineficiente a medida que el proyecto crezca.
2.  **Crear subcarpetas temáticas:** Requiere un esfuerzo inicial de clasificación, pero mejora drásticamente la organización y la eficiencia a largo plazo.

### Decisión Tomada y Justificación:
Se optó por la **Opción 2**. Se crearon 8 subcarpetas temáticas (`Filosofia_General`, `Politica_Sociedad`, `Economia_Capitalismo`, `Psicoanalisis_Lacan`, `Marx_Grundrisse`, `Tematica_Argentina`, `Concepto_Valor`, `Arte_Estetica`) y se clasificaron los 43 archivos pertinentes. La justificación es alinear el proyecto con las mejores prácticas de gestión del conocimiento y facilitar el acceso y análisis del material fuente, tal como se proponía en la auditoría de la arquitectura.

### Trade-offs (Ganancias y Pérdidas):
*   **Ganancia:** Claridad estructural, facilidad para añadir nuevas fuentes, eficiencia en la búsqueda, visión clara de los ejes temáticos del proyecto.
*   **Pérdida:** Tiempo invertido en la clasificación inicial. Se mitiga por el hecho de que esta tarea solo se realiza una vez de forma masiva.

### Aprendizajes Clave:
La implementación de mejoras propuestas en la fase de auditoría es crucial para la salud y sostenibilidad del proyecto. Actuar proactivamente sobre una "evaluación crítica" validó el proceso de automejora continua.

---

## 13 de agosto de 2025

### Dilema:
Se discutió la implementación de la metodología de "Sprints de Investigación", propuesta en la arquitectura del proyecto para realizar análisis dirigidos y ágiles. El dilema era si adoptar esta metodología de inmediato o posponerla.

### Opciones Consideradas:
1.  **Implementación Inmediata:** Comenzar a usar sprints para investigar temas específicos de forma paralela al análisis secuencial.
2.  **Uso Diferido:** Completar primero la fase de análisis secuencial de todas las fuentes para construir una base de conocimiento exhaustiva, y reservar los sprints para una fase posterior de análisis profundo y transversal.

### Decisión Tomada y Justificación:
Se optó por la **Opción 2**. La decisión se basa en que la fase actual del proyecto se beneficia más de una acumulación de conocimiento amplia y sistemática. Los "Sprints de Investigación" se consideran una herramienta más adecuada para la etapa final del proyecto, una vez que se tenga un mapa completo del material, para así poder realizar incursiones profundas y específicas sobre temas que requieran una mayor elaboración.

### Trade-offs (Ganancias y Pérdidas):
*   **Ganancia:** Se asegura una base de conocimiento completa y homogénea antes de pasar a análisis especializados. Se evita la fragmentación temprana de la investigación.
*   **Pérdida:** Se pospone la capacidad de obtener respuestas rápidas a preguntas específicas que puedan surgir durante la fase de lectura inicial.

### Aprendizajes Clave:
La elección de una metodología de trabajo debe adaptarse a la fase actual del proyecto. No se trata de descartar herramientas, sino de secuenciarlas estratégicamente para maximizar su efectividad.

---

## 15 de agosto de 2025

### Dilema:
Las fichas de lectura, aunque robustas, carecían de un campo estructurado para vincularlas entre sí, una mejora clave propuesta en la auditoría de arquitectura para permitir la creación de un grafo de conocimiento.

### Opciones Consideradas:
1.  **Dejar las conexiones como texto libre:** Simple, pero impide el análisis automatizado de relaciones.
2.  **Añadir un campo YAML estructurado:** Requiere una modificación masiva de los archivos existentes, pero establece la base para la interoperabilidad y la minería de datos.

### Decisión Tomada y Justificación:
Se optó por la **Opción 2**. Se modificaron las 13 fichas de lectura existentes en `01_FICHAS_DE_LECTURA` para añadir el campo `conexiones_inter_ficha`. Esta acción implementa directamente una mejora estratégica de la auditoría, transformando las fichas de documentos aislados a nodos de una red de conocimiento.

### Trade-offs (Ganancias y Pérdidas):
*   **Ganancia:** Se estandariza el formato de las fichas y se habilita la capacidad de análisis programático de las conexiones conceptuales, un objetivo central del proyecto.
*   **Pérdida:** Mínima. El esfuerzo de la modificación masiva se realizó una sola vez de forma automatizada.

### Aprendizajes Clave:
La automatización de cambios estructurales en el corpus de datos es una capacidad fundamental para la evolución del proyecto.

---

## 15 de agosto de 2025

### Dilema:
El proceso para crear una nueva ficha de lectura era enteramente manual, requiriendo copiar, pegar y modificar una plantilla, lo cual era lento y propenso a errores de inconsistencia. La auditoría sugirió automatizar este flujo de trabajo.

### Opciones Consideradas:
1.  **Mantener el proceso manual:** No requiere desarrollo, pero perpetúa la ineficiencia.
2.  **Crear un script de generación automática:** Requiere un esfuerzo de desarrollo inicial para crear una herramienta reutilizable.

### Decisión Tomada y Justificación:
Se optó por la **Opción 2**. Se desarrolló el script `tools/Generate-ReadingCard.ps1`. Esta herramienta toma la ruta de un PDF y genera automáticamente una ficha de lectura pre-rellenada en `01_FICHAS_DE_LECTURA`, con un ID único, título, ruta de origen y fecha. La decisión se alinea con el principio de mejora continua del flujo de trabajo.

### Trade-offs (Ganancias y Pérdidas):
*   **Ganancia:** Aceleración drástica del proceso de ingesta de nuevas fuentes, eliminación de errores manuales y garantía de consistencia en todas las fichas nuevas.
*   **Pérdida:** Tiempo de desarrollo del script. Se considera una inversión que se amortiza rápidamente.

### Aprendizajes Clave:
Invertir en herramientas internas que automaticen tareas repetitivas es crucial para la eficiencia y escalabilidad del proyecto. La depuración de la herramienta (corrección de la ruta y de la política de ejecución) reforzó la importancia de las pruebas unitarias para los scripts del proyecto.

---