from datetime import datetime
from pathlib import Path

CANONICAL_PATH = Path("99_META/AUDITORIA.md")

HEADER = """# Auditoría Técnica (canónica)
> Última actualización: {fecha}
> Responsable: Equipo del proyecto

---
"""

def ensure_header(existing: str) -> str:
    """Si el archivo está vacío o no tiene encabezado, lo crea."""
    if existing.strip() == "":
        return HEADER.format(fecha=datetime.now().strftime("%Y-%m-%d")) + "\n"
    return existing

def write_canonical_summary(body_markdown: str, append_history: bool = True) -> None:
    """
    Escribe el resumen canónico en 99_META/AUDITORIA.md.
    - Reemplaza el contenido principal manteniendo encabezado.
    - Si append_history=True, agrega una línea al historial con fecha actual.
    """
    CANONICAL_PATH.parent.mkdir(parents=True, exist_ok=True)

    existing = CANONICAL_PATH.read_text(encoding="utf-8") if CANONICAL_PATH.exists() else ""
    content = ensure_header(existing)

    # Construye el bloque principal estándar
    fecha_hoy = datetime.now().strftime("%Y-%m-%d")
    main_block = body_markdown.strip()

    # Reemplaza todo el documento dejando header + bloque
    # (si quieres conservar secciones fijas, puedes parsear y reinsertar)
    new_doc = HEADER.format(fecha=fecha_hoy) + "\n" + main_block + "\n\n"

    # Si corresponde, añade una línea de historial al final
    if append_history:
        new_doc += "## 5. Historial de Auditorías\n"
        new_doc += f"- {fecha_hoy}: Actualización automática del resumen canónico.\n"

    CANONICAL_PATH.write_text(new_doc, encoding="utf-8")
    print(f"[audit] Escrito resumen en {CANONICAL_PATH}")