# Reporte CROSS – proyecto-tesis

Fecha: 2025-10-12
Satélite: proyecto-tesis
scope_sat_root: /workspace
scope_core_root: (referencia canónica de contratos v1 del Organizador)

Manifiesto satélite: `satellite.manifest.json`
- name: proyecto-tesis
- version: 0.3.0
- contracts: data/process/language/observability/policy (v1)
- adapters: process=`tools/Start-FullProcess.ps1`, data=`api/main.py`
- health: http=`/health`, sse=∅

## 1) Inventario de contratos (v1)
- data:
  - v1:corpus.reading → `01_FICHAS_DE_LECTURA/`
  - v1:quotes.db → `97_CITAS/`
  - v1:concept.index → `02_MAPAS_Y_ESQUEMAS/INDICE_DE_CONCEPTOS.md` (generable)
  - v1:strategic.synthesis → `04_SINTESIS/`
- process: v1 → orquestador `tools/Start-FullProcess.ps1` + API `POST /process`
- language: v1 → `config/analysis.json` (stopwords + conceptMapping)
- observability: v1 → `GET /health`; SSE no implementado
- policy: v1 → no formalizado explícitamente (CORS, rutas seguras, permisos)

## 2) Adapters del satélite
- process: `tools/Start-FullProcess.ps1` (pipeline 5 pasos con profiling)
- data: `api/main.py` (listado/lectura de archivos vía `/files` y `/file-content`)

## 3) Léxico (claves)
- Base satélite: `config/analysis.json` con stopwords y `conceptMapping` (≈30+ claves)
- Comparación con core: pendiente (requiere léxico del Organizador). Se asume alta intersección temática (Marx/Lacan/Derrida/Argentina/valor)

## 4) Process Contract (endpoints / SSE)
- HTTP: `/`, `/health`, `POST /process`, `/files`, `/file-content`
- SSE: no implementado (contrato v1 prevé canal de eventos)

## 5) Observabilidad
- Healthcheck: `/health` (OK)
- Latido SSE: ausente (⚠)
- Métricas mínimas: no expuestas (⚠) — hay profiling en logs del pipeline

## 6) Matriz de hallazgos

| Área | Ítem | Tipo | Estado | Severidad | Notas |
|---|---|---|---|---|---|
| Contratos | data v1: corpus.reading | ✓ | Herencia coral | P2 | `01_FICHAS_DE_LECTURA` |
| Contratos | data v1: quotes.db | ✓ | Herencia coral | P2 | `97_CITAS` |
| Contratos | data v1: concept.index | ✓ | Herencia coral | P2 | `02_MAPAS_Y_ESQUEMAS/INDICE_DE_CONCEPTOS.md` |
| Contratos | data v1: strategic.synthesis | ✓ | Herencia coral | P2 | `04_SINTESIS` |
| Contratos | process v1 | ✓ | Herencia coral | P2 | Orquestador + `POST /process` |
| Contratos | language v1 | ✓ | Herencia coral | P2 | `config/analysis.json` |
| Contratos | observability v1 (SSE) | ⚠ | Divergencia | P1 | Falta endpoint SSE |
| Contratos | policy v1 | ⚠ | Divergencia | P1 | Política no explicitada |
| Proceso | Endpoints HTTP | ✓ | Herencia coral | P2 | `/`, `/health`, `/process`, `/files`, `/file-content` |
| Proceso | SSE | ⚠ | Divergencia | P0 | No implementado |
| Observabilidad | Health | ✓ | Herencia coral | P2 | `/health` OK |
| Observabilidad | Métricas | ⚠ | Divergencia | P2 | Sin métricas expuestas |
| Adapters | process | ✓ | Herencia coral | P2 | `tools/Start-FullProcess.ps1` |
| Adapters | data | ✓ | Herencia coral | P2 | `api/main.py` |
| Lenguaje | Léxico `analysis.json` | ✓ | Herencia coral | P2 | Stopwords + mapping |
| Lenguaje | Claves huérfanas/divergentes | ★ | Especificidad | P2 | Requiere cotejo con core |

## 7) Recomendaciones por prioridad
- P0: Implementar SSE (observability v1) o documentar excepción en manifiesto/política.
- P1: Formalizar contrato de policy v1 (CORS, permisos, rutas seguras) y publicarlo en `/contracts/policy.v1.md`.
- P1: Unificar shell cross-platform en API (usar `pwsh`) y alinear CORS/CSP con origen del frontend (8080).
- P2: Exponer métricas mínimas (conteos, duraciones) y normalizar nombres/acentos para trazabilidad determinista.
- P2: Cotejar léxico con core y decidir adopción/adaptación de claves divergentes.
