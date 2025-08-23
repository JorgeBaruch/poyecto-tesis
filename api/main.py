# main.py
import os
import subprocess
import threading
from fastapi import FastAPI, BackgroundTasks, HTTPException, Query
from fastapi.responses import PlainTextResponse

app = FastAPI()

# --- Security ---
# Get the absolute path of the project root directory.
# The API will not be allowed to access any file or directory outside of this path.
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def secure_path(path: str) -> str:
    """
    Joins a path to the project root and ensures it's a safe, canonical path.
    Raises HTTPException if the path is outside the project root.
    """
    full_path = os.path.abspath(os.path.join(PROJECT_ROOT, path))
    if not full_path.startswith(PROJECT_ROOT):
        raise HTTPException(status_code=400, detail="Acceso a ruta no válido.")
    return full_path

# --- Background Task ---
def run_powershell_script(script_path: str):
    """Runs a PowerShell script and logs its output."""
    full_script_path = secure_path(script_path)
    command = ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", full_script_path]
    try:
        print(f"Starting script: {' '.join(command)}")
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding='utf-8',
            cwd=PROJECT_ROOT # Run the script from the project root
        )

        for line in iter(process.stdout.readline, ''):
            print(f"SCRIPT STDOUT: {line.strip()}")
        for line in iter(process.stderr.readline, ''):
            print(f"SCRIPT STDERR: {line.strip()}")

        process.stdout.close()
        process.stderr.close()
        process.wait()
        print(f"Script finished with exit code {process.returncode}")

    except Exception as e:
        print(f"Failed to run script: {e}")

# --- API Endpoints ---
@app.get("/")
def read_root():
    return {"message": "Servidor de la API del Proyecto de Tesis funcionando."}

@app.post("/process")
async def process_all_files(background_tasks: BackgroundTasks):
    """
    Triggers the full processing pipeline in the background.
    """
    script_path = "tools/Start-FullProcess.ps1"
    background_tasks.add_task(run_powershell_script, script_path)
    
    return {"message": "Proceso completo iniciado en segundo plano. Revise la consola del servidor para ver el progreso."}

@app.get("/files")
def list_files(directory: str = Query(..., description="Directorio a listar, relativo a la raíz del proyecto.")):
    """
    Lists all files in a specified directory.
    """
    safe_dir_path = secure_path(directory)
    if not os.path.isdir(safe_dir_path):
        raise HTTPException(status_code=404, detail="El directorio no existe.")
    
    file_list = []
    for root, _, files in os.walk(safe_dir_path):
        for file in files:
            full_path = os.path.join(root, file)
            # Return path relative to the project root
            relative_path = os.path.relpath(full_path, PROJECT_ROOT).replace("\", "/")
            file_list.append(relative_path)
            
    return {"directory": directory, "files": sorted(file_list)}

@app.get("/file-content", response_class=PlainTextResponse)
def get_file_content(path: str = Query(..., description="Ruta al archivo a leer, relativa a la raíz del proyecto.")):
    """
    Reads and returns the content of a specific file.
    """
    safe_file_path = secure_path(path)
    if not os.path.isfile(safe_file_path):
        raise HTTPException(status_code=404, detail="El archivo no existe.")
    
    try:
        with open(safe_file_path, "r", encoding="utf-8") as f:
            return f.read()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"No se pudo leer el archivo: {e}")
