# Usa una imagen base con PowerShell Core sobre Debian.
# Esto proporciona un entorno Linux donde podemos instalar fácilmente otras dependencias.
FROM mcr.microsoft.com/powershell:latest

# Cambia al usuario root para instalar paquetes del sistema
USER root

# Instala las dependencias de sistema requeridas por el proyecto:
# - python3 y python3-pip: Para ejecutar scripts de Python e instalar paquetes.
# - poppler-utils: Proporciona la utilidad crítica 'pdftotext'.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    poppler-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia todo el contenido del proyecto al directorio de trabajo del contenedor
COPY . .

# Instala las dependencias de los paquetes de Python desde el archivo requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# El contenedor está ahora configurado con todas las dependencias.
# Puedes ejecutar cualquier script usando 'docker run'.

# Por defecto, al iniciar el contenedor se abrirá una sesión de PowerShell.
CMD [ "pwsh" ]
