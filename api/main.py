# main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Servidor de la API del Proyecto de Tesis funcionando."}
