# Auditor Tnica del Proyecto (Nivel 2)

## Arquitectura
- [ ] Documentar la arquitectura general (frontend/backend/datos).
- [ ] Verificar uso de patrones recomendados (12-Factor App, Clean Architecture).

## Frontend
- [ ] Revisar accesibilidad y responsividad de la UI.
- [ ] Mejorar manejo de errores en `fetch` (retry, mensajes claros).
- [ ] Agregar log de auditor de acciones en consola.
- [ ] Proponer un redise 1o simple de UI.

## Backend / API
- [ ] Validaciones robustas de parmetros.
- [ ] Configuraci 1n de CORS correcta (localhost:8080).
- [ ] Endpoints documentados en OpenAPI (/docs).
- [ ] Agregar `/health` endpoint.

## Datos y carpetas
- [ ] Estandarizar nombres de carpetas (snake_case).
- [ ] Confirmar existencia de 00_FUENTES, 00_FUENTES_PROCESADAS, 01_FICHAS_DE_LECTURA, 97_CITAS.
- [ ] Asociar metadatos JSON/YAML por archivo.

## Control de versiones / CI-CD
- [ ] Flujo Nivel 2 confirmado (commit 10 pull --rebase 10 push).
- [ ] Activar GitHub Actions (tests + linters).
- [ ] Configurar Docker Compose para entorno reproducible.

## Seguridad y permisos
- [ ] Usar `.env` para credenciales y secretos.
- [ ] Revisar riesgos OWASP Top 10 y ASVS.
- [ ] Confirmar permisos correctos en archivos y carpetas.

## Plan de acci 1n
1. Consolidar README con instrucciones reproducibles.
2. Pulir frontend con auditor 1a de accesibilidad.
3. Endurecer backend (validaciones, logs, CORS).
4. Configurar hooks Git para confirmaciones Nivel 2.
5. A 1adir CI/CD con GitHub Actions.
6. Revisiones periodicas (tiempo a definir posteriormente) de seguridad y calidad.
