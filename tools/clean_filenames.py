import os
import re
from datetime import datetime

# Expresión regular para capturar las partes relevantes del nombre del archivo.
# Se adapta a patrones como "_AUTOR_ - Título_ficha.md" o "Autor_Titulo_ficha.md"
# Es flexible con espacios, guiones bajos y capitalización.
FILENAME_PATTERN = re.compile(
    r"^(?:_?)(?P<author>[a-zA-ZÀ-ÿ\s_’]+?)(?:_?-_?)?\s*(?P<title>.+?)(?:_ficha)?\.md$",
    re.IGNORECASE
)

def sanitize_part(text: str) -> str:
    """Convierte a minúsculas, reemplaza espacios y guiones bajos por guiones,
    y elimina caracteres no alfanuméricos excepto guiones."""
    text = text.lower().strip().replace(" ", "-").replace("_", "-")
    return re.sub(r"[^a-z0-9-]", "", text)

def clean_filenames(directory: str):
    """
    Renombra los archivos en el directorio especificado a un formato estandarizado:
    YYYY-MM-DD_autor_titulo-corto.md
    """
    print(f"Analizando archivos en: {directory}")
    renamed_files = set()
    for filename in os.listdir(directory):
        if not filename.endswith(".md"):
            continue

        match = FILENAME_PATTERN.match(filename)
        if not match:
            print(f"  -> Saltando (no coincide el patrón): {filename}")
            continue

        author = sanitize_part(match.group("author"))
        title = sanitize_part(match.group("title"))
        
        date_prefix = datetime.now().strftime("%Y-%m-%d")
        
        base_new_filename = f"{date_prefix}_{author}_{title}"
        new_filename = f"{base_new_filename}.md"
        counter = 1
        while new_filename in renamed_files or os.path.exists(os.path.join(directory, new_filename)):
            new_filename = f"{base_new_filename}_{counter}.md"
            counter += 1

        renamed_files.add(new_filename)

        old_path = os.path.join(directory, filename)
        new_path = os.path.join(directory, new_filename)

        if old_path == new_path:
            print(f"  -> Saltando (nombre ya estandarizado): {filename}")
            continue

        print(f"  -> Renombrando: {filename}  -->  {new_filename}")
        os.rename(old_path, new_path)

    print("\nLimpieza de nombres de archivo completada.")

if __name__ == "__main__":
    FICHAS_DIR = os.path.join(os.path.dirname(__file__), "..", "01_FICHAS_DE_LECTURA")
    clean_filenames(os.path.normpath(FICHAS_DIR))