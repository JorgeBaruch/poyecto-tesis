import os, sys
from openai import OpenAI

SYSTEM = (
    "Eres un analista que transforma auditorías en información accionable. "
    "Devuelve SIEMPRE un JSON con: resumen, hallazgos_clave[], riesgos[], acciones_sugeridas[]. "
    "Escribe en español, conciso y claro."
)

USER_TMPL = """Analiza la siguiente auditoría y devuelve el JSON pedido.

### Objetivo
- Resumen <150 palabras.
- Hallazgos clave: máx 5 bullets.
- Riesgos: máx 5 bullets.
- Acciones sugeridas: máx 5 (cada una con responsable y horizonte corto/medio/largo).

### Texto de auditoría
{texto}
"""

def main():
    if len(sys.argv) < 2:
        print("Uso: python tools/audits_chat.py RUTA_AL_ARCHIVO.md|txt")
        raise SystemExit(1)

    ruta = sys.argv[1]
    if not os.path.isfile(ruta):
        raise FileNotFoundError(f"No existe: {ruta}")

    with open(ruta, "r", encoding="utf-8", errors="ignore") as f:
        texto = f.read()

    user = USER_TMPL.format(texto=texto[:12000])  # recorte de seguridad
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("Falta OPENAI_API_KEY")

    client = OpenAI(api_key=api_key)
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": user},
        ],
        temperature=0.2,
    )
    print(resp.choices[0].message.content.strip())

if __name__ == "__main__":
    main()
