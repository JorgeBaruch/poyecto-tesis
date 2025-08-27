# Guía de Contribución

¡Gracias por tu interés en contribuir a este proyecto! Todas las contribuciones son bienvenidas.

Para asegurar la calidad y consistencia del código, por favor sigue estas guías.

## Flujo de Trabajo

1.  **Crea una Rama (Branch):** No trabajes directamente sobre la rama `main`. Crea una nueva rama para tus cambios con un nombre descriptivo (ej. `feature/agregar-nuevo-analisis` o `fix/corregir-error-en-fichas`).
    ```bash
    git checkout -b nombre-de-tu-rama
    ```

2.  **Realiza tus Cambios:** Implementa tu nueva funcionalidad o corrección de error.

3.  **Valida tu Código:** Antes de enviar tus cambios, asegúrate de que pasen todas las validaciones de calidad y pruebas. Ejecuta el script de validación desde la raíz del proyecto:
    ```powershell
    ./Invoke-Validation.ps1
    ```
    Este script se encargará de ejecutar linters y tests para asegurar que todo sigue funcionando como se espera.

4.  **Confirma tus Cambios (Commit):** Haz commit de tus cambios con un mensaje claro y descriptivo.

5.  **Envía un Pull Request (PR):** Sube tu rama al repositorio remoto y abre un Pull Request contra la rama `main`. En la descripción del PR, explica los cambios que has realizado y por qué.

## Estándares de Código

- **Estilo:** Sigue el estilo de código existente en el proyecto.
- **Documentación:** Si añades una nueva funcionalidad, asegúrate de que esté debidamente documentada, ya sea a través de comentarios en el código (si es complejo) o actualizando los archivos `README.md` relevantes.

Gracias de nuevo por tu contribución.