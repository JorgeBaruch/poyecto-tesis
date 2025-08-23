

# Bitácora de Proyecto

> **Nota:** Este documento es parte de un sistema interdependiente junto con `DECISIONES_ESTRATEGICAS.md` y `ARQUITECTURA_DEL_PROYECTO.md`. Toda decisión, cambio metodológico o estructural relevante debe reflejarse y justificarse de manera coherente en los tres archivos para asegurar trazabilidad y continuidad.

Este documento registra la evolución de la metodología y el flujo de trabajo del 'Proyecto Tesis'.

---

### Entrada 10: Robustecimiento y Automatización de Tests (16 de agosto de 2025)

**Evento:** Se realiza una etapa intensiva de robustecimiento, depuración y automatización de la suite de tests para todos los scripts PowerShell y utilidades clave del proyecto.

**Desarrollo:**
1.  Se reescriben y limpian los archivos de tests para garantizar compatibilidad total con Pester 3.x, eliminando errores de sintaxis y problemas de estructura de bloques.
2.  Se automatiza la creación y limpieza de archivos dummy para pruebas, asegurando que todos los tests sean 100% reproducibles y no interactivos (apto para CI/CD).
3.  Se agregan tests funcionales mínimos a scripts con lógica real y tests de existencia/importación a scripts placeholder.
4.  Se documentan y resuelven problemas comunes: errores de llaves en contextos Pester, manejo de archivos temporales, y limitaciones de Pester 3.x (sin Remove-Mock, contextos estrictos).
5.  Se valida que toda la suite pase en verde y se deja registro de los scripts que requieren expansión futura de tests funcionales.
6.  Se revisan y justifican los documentos meta (`BITACORA_DE_PROYECTO.md`, `DECISIONES_ESTRATEGICAS.md`, `ARQUITECTURA_DEL_PROYECTO.md`) para asegurar trazabilidad y claridad de las mejoras.

**Dificultades y problemas resueltos:**
- Errores persistentes de sintaxis por cierre incorrecto de bloques en tests Pester.
- Necesidad de crear y limpiar archivos temporales para pruebas automáticas.
- Falta de tests funcionales en scripts clave (se agregan donde corresponde).
- Scripts placeholder: se decide mantener solo tests mínimos hasta que se implemente funcionalidad real.

**Pendientes:**
- Expandir tests funcionales en scripts que evolucionen o reciban lógica nueva.
- Documentar futuras dificultades técnicas en esta bitácora y registrar decisiones técnicas en los documentos meta correspondientes.


### Entrada 9: Refinamiento del Léxico Clave y Adopción de Mejoras (Fecha actual)

**Evento:** El usuario solicita una mayor precisión en el análisis del léxico clave y adopta formalmente las mejoras propuestas en la auditoría.

**Desarrollo:**
1.  Se refina la directriz para el campo "Léxico Clave" en las fichas: no solo identificar palabras, sino analizar su **función y rol** en el contexto del documento.
2.  Se adoptan formalmente todas las **"Mejoras Propuestas"** de la auditoría crítica del diseño del proyecto (Entrada 8).
3.  Se crean los nuevos documentos meta: `ARQUITECTURA_DEL_PROYECTO.md` y `DECISIONES_ESTRATEGICAS.md` en `99_META/`.
4.  La plantilla de ficha se consolida en la **v2.3**.

---

### Entrada 8: Adopción de Mejoras Propuestas y Nuevos Documentos Meta (Fecha anterior)

**Evento:** El usuario presenta una lista consolidada de mejoras propuestas para el diseño del proyecto.

**Desarrollo:**
1.  Se adoptan formalmente las "Mejoras Propuestas" que incluyen refinamientos en la arquitectura de carpetas, la plantilla de fichas, los documentos de síntesis y el flujo de trabajo.
2.  Se crean dos nuevos documentos meta:
    *   `ARQUITECTURA_DEL_PROYECTO.md` en `99_META/` para documentar la lógica de diseño del proyecto.
    *   `DECISIONES_ESTRATEGICAS.md` en `99_META/` para registrar dilemas y decisiones estratégicas.
3.  Se actualiza la plantilla de ficha a la **v2.3**, incorporando la directriz de analizar la **función y rol** del léxico clave en su contexto.

---

### Entrada 7: Auditoría Crítica del Diseño y Nuevos Documentos (Fecha anterior)

**Evento:** Auditoría crítica del diseño del proyecto solicitada por el usuario.

**Desarrollo:**
1.  Se realiza una auditoría crítica integral de la arquitectura de carpetas, plantilla de fichas, documentos de síntesis y flujo de trabajo.
2.  Se proponen mejoras para la sub-categorización dinámica de `00_FUENTES`, versionado de `03_BORRADORES`, y conexiones estructuradas en las fichas.
3.  Se crean dos nuevos documentos meta:
    *   `ARQUITECTURA_DEL_PROYECTO.md` en `99_META/` para documentar la lógica de diseño del proyecto.
    *   `DECISIONES_ESTRATEGICAS.md` en `99_META/` para registrar dilemas y decisiones estratégicas.
4.  Se actualiza la plantilla de ficha a la **v2.3**, incluyendo el análisis de la **función y rol** del léxico clave.

---

### Entrada 6: Síntesis 3: El Método Dialéctico y la Humillación como Exceso (Fecha anterior)

**Evento:** Tercera pausa de síntesis y metodología.

**Desarrollo:**
1.  Se integran los hallazgos de los textos sobre el método de Marx (*Grundrisse*) y el análisis sociológico de Jessé Souza (*El Pobre de Derecha*).
2.  Se profundiza la comprensión del **CORTE** como el método dialéctico de Marx y la racionalidad económica que simplifica la complejidad social.
3.  Se expande el **EXCESO** para incluir la "totalidad concreta" de la realidad (Marx) y la "humillación" y necesidad de reconocimiento social (Souza).
4.  Se refina la **ASTUCIA** como la confusión de órdenes (Marx) y el "falso moralismo" (Souza) que desvía la ira de los humillados.

---

### Entrada 5: Principio de "Igualdad Conceptual" para las Hipótesis (Fecha anterior)

**Evento:** El usuario aclara el rol de su ensayo "Los 10 Mandamientos del Capital".

**Desarrollo:**
1.  Se establece la regla de no dar un estatus privilegiado o central a las hipótesis de trabajo propias.
2.  El ensayo "Los 10 Mandamientos" no será tratado como un marco a confirmar, sino como un **objeto de análisis más**, una hipótesis a ser contrastada con las fuentes.
3.  Lógicamente, se categoriza como un "Discurso del Amo" a ser analizado con las mismas herramientas críticas (Corte/Exceso/Astucia) que los demás textos.
4.  **Decisión operativa:** No se creará una ficha para él, ni se lo incluirá textualmente en la Síntesis Conceptual para no darle un peso indebido. Se registrará esta decisión en la bitácora como una regla metodológica.

---

### Entrada 4: El Trípode Analítico y la Ficha v2.1 (Fecha anterior)

**Evento:** Segunda pausa de síntesis y metodología.

**Desarrollo:**
1.  Se realiza una revisión retrospectiva de todas las fichas creadas.
2.  Se consolida un marco analítico de tres conceptos clave: **CORTE** (la operación que limita y ordena), **EXCESO** (el resto irreductible que es producto del corte) y **ASTUCIA** (el mecanismo ideológico que vela la relación entre corte y exceso).
3.  Se actualiza la plantilla de la ficha a la **versión 2.1**, añadiendo un campo explícito para el análisis de la "Astucia".
4.  Se decide crear este mismo documento (la Bitácora) y un documento de "Síntesis Conceptual" para registrar formalmente la evolución del método y de las ideas.

---

### Entrada 3: Flujo por Lotes y Ficha v2.0 (Fecha anterior)

**Evento:** El usuario solicita una forma más fluida de trabajar.

**Desarrollo:**
1.  Se propone y adopta un flujo de trabajo por lotes: el usuario convierte varios archivos a PDF, el asistente los mueve todos a `00_FUENTES` y luego se procede al análisis secuencial.
2.  A la luz de los primeros análisis, se refina la plantilla de la ficha a una **versión 2.0**, añadiendo los campos "Rol Discursivo / Posición" y "Variantes y Cotejo de Fuentes".

---

### Entrada 2: Sistema de Fichas de Lectura (Fecha anterior)

**Evento:** El usuario sugiere la necesidad de crear una "ficha" por cada documento.

**Desarrollo:**
1.  Se acoge la propuesta y se diseña una **plantilla de Ficha de Lectura (v1.0)** basada en el método filológico-lacaniano y la dialéctica Corte/Exceso.
2.  Se acuerda que cada ficha será un archivo Markdown individual en la carpeta `01_FICHAS_DE_LECTURA/`.

---

### Entrada 1: Creación de Estructura de Carpetas (Fecha inicial)

**Evento:** El usuario solicita pensar la estructura de carpetas del proyecto.

**Desarrollo:**
1.  Se diseña y crea una estructura de carpetas con prefijos numéricos para ordenar el flujo de trabajo:
    *   `00_FUENTES`
    *   `01_FICHAS_DE_LECTURA`
    *   `02_MAPAS_Y_ESQUEMAS`
    *   `03_BORRADORES`
    *   `99_META`