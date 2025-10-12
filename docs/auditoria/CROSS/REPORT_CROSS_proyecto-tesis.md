# Reporte CROSS – proyecto-tesis

Fecha: 2025-10-12
Satélite: proyecto-tesis
Core: <organizer>

## 1) Inventario de contratos (v1)
- data: v1:corpus.reading (01_FICHAS_DE_LECTURA), v1:quotes.db (97_CITAS), v1:concept.index (02_MAPAS_Y_ESQUEMAS/INDICE_DE_CONCEPTOS.md), v1:strategic.synthesis (04_SINTESIS)
- process: v1 (tools/Start-FullProcess.ps1; API POST `/process`)
- language: v1 (configuración léxica en `config/analysis.json`)
- observability: v1 (HTTP health `/health`), SSE no implementado
- policy: v1 (no explícito en este repo)

## 2) Adapters del satélite
- process: `tools/Start-FullProcess.ps1`
- data: `api/main.py` (exposición de contenido/archivos)

## 3) Léxico (claves)
- Base satélite: `config/analysis.json` (stopwords + mapping de conceptos)
- Por comparar con léxico del core para detectar claves huérfanas/divergentes

## 4) Process Contract (endpoints / SSE)
- HTTP: `/` (root), `/health`, `/process` (POST), `/files`, `/file-content`
- SSE: no implementado

## 5) Observabilidad
- Healthcheck: `/health` (OK)
- Latido SSE: no disponible (⚠)
- Métricas mínimas: no explícitas (⚠)

## 6) Matriz de hallazgos

| Área | Ítem | Tipo | Estado | Severidad | Notas |
|---|---|---|---|---|---|
| Contratos | data v1: corpus.reading | ✓ | Herencia coral | P2 | `01_FICHAS_DE_LECTURA` |
| Contratos | data v1: quotes.db | ✓ | Herencia coral | P2 | `97_CITAS` |
| Contratos | data v1: concept.index | ✓ | Herencia coral | P2 | `02_MAPAS_Y_ESQUEMAS/INDICE_DE_CONCEPTOS.md` (generable) |
| Contratos | data v1: strategic.synthesis | ✓ | Herencia coral | P2 | `04_SINTESIS` |
| Contratos | process v1 | ✓ | Herencia coral | P2 | Orquestador + API `/process` |
| Contratos | language v1 | ✓ | Herencia coral | P2 | `config/analysis.json` |
| Contratos | observability v1 (SSE) | ⚠ | Divergencia | P1 | Falta endpoint SSE |
| Contratos | policy v1 | ⚠ | Divergencia | P1 | No hay política explícita |
| Proceso | Endpoints HTTP | ✓ | Herencia coral | P2 | `/`, `/health`, `/process`, `/files`, `/file-content` |
| Proceso | SSE | ⚠ | Divergencia | P0 | No implementado |
| Observabilidad | Health | ✓ | Herencia coral | P2 | `/health` OK |
| Observabilidad | Métricas | ⚠ | Divergencia | P2 | No hay métricas |
| Adapters | process | ✓ | Herencia coral | P2 | `tools/Start-FullProcess.ps1` |
| Adapters | data | ✓ | Herencia coral | P2 | `api/main.py` |
| Lenguaje | Léxico `analysis.json` | ✓ | Herencia coral | P2 | Stopwords y conceptos |
| Lenguaje | Claves huérfanas/divergentes | ★ | Especificidad satélite | P2 | Requiere cotejo con core |

## 7) Recomendaciones por prioridad
- P0: Implementar SSE (contrato de observabilidad v1) o ajustar manifiesto si no aplica.
- P1: Definir contrato de `policy v1` (permisos, CORS, rutas seguras) y documentarlo.
- P1: Alinear CORS/CSP del frontend con el origen de ejecución (8080) y shell cross-platform en API.
- P2: Exponer métricas mínimas (cuentas de citas/fichas, tiempo de pipeline) y normalizar nombres de archivos.
- P2: Comparar léxico con el core para detectar claves huérfanas y decidir adopción o adaptación.
