# AGREGADO CORAL – Núcleo y Satélites Descubiertos

Fecha: 2025-10-12
Modo: Descubrir + Cruz (automático)

Escaneo:
- satellites.index.json: no encontrado
- Búsqueda de `satellite.manifest.json` (hasta 2 niveles): 1 encontrado

## Tabla comparativa

| Sistema | Ruta absoluta | data v1 | process v1 | language v1 | observability v1 (HTTP) | observability v1 (SSE) | policy v1 | Endpoints HTTP | Léxico (config) | Gaps principales |
|---|---|---:|---:|---:|---:|---:|---:|---|---:|---|
| Núcleo (Organizador) | N/D | ? | ? | ? | ? | ? | ? | N/D | ? | No localizado en workspace |
| proyecto-tesis | /workspace | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | `/`, `/health`, `/process`, `/files`, `/file-content` | ✓ | Falta SSE; Policy no explicitada; Métricas no expuestas; Alinear CORS/shell |
| razonandes | N/D | ? | ? | ? | ? | ? | ? | N/D | ? | No localizado en workspace |

## Notas
- Solo se detectó el satélite `proyecto-tesis` (este repositorio). No se localizaron rutas para el núcleo (Organizador) ni para `razonandes` dentro del workspace actual.
- Para habilitar el CROSS completo, monte los repos de núcleo y satélite como carpetas hermanas, o provea `satellites.index.json` en la raíz con sus rutas absolutas.

## Rutas empleadas
- proyecto-tesis: `/workspace`
- Organizador: N/D
- razonandes: N/D

## Ambigüedades/Conflictos
- Descubrimiento multi-root no disponible en el entorno actual. Se requiere multi-root o index explícito para continuar con análisis comparativo real de núcleo y otros satélites.
