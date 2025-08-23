// script.js

document.addEventListener('DOMContentLoaded', () => {
    const processAllBtn = document.getElementById('processAllBtn');
    const folderButtons = document.querySelectorAll('.folder-list button');
    const fileList = document.getElementById('file-list');
    const fileContent = document.getElementById('file-content');

    const API_BASE_URL = 'http://127.0.0.1:8000';

    // --- Event Listeners ---
    processAllBtn.addEventListener('click', async () => {
        processAllBtn.disabled = true;
        processAllBtn.textContent = 'Procesando...';
        fileContent.textContent = 'Iniciando proceso completo. Revise la consola del servidor para ver el progreso.';
        try {
            const response = await fetch(`${API_BASE_URL}/process`, {
                method: 'POST',
            });
            const data = await response.json();
            alert(data.message);
        } catch (error) {
            console.error('Error al iniciar el proceso:', error);
            alert('Error al iniciar el proceso. Verifique la consola del navegador y del servidor.');
        } finally {
            processAllBtn.disabled = false;
            processAllBtn.textContent = 'Iniciar Proceso Completo';
            // Optionally, refresh file lists after a delay
            setTimeout(() => loadFiles('00_FUENTES_PROCESADAS'), 5000); 
        }
    });

    folderButtons.forEach(button => {
        button.addEventListener('click', () => {
            const path = button.dataset.path;
            loadFiles(path);
        });
    });

    // --- API Calls ---
    async function loadFiles(directory) {
        fileList.innerHTML = ''; // Clear previous list
        fileContent.textContent = 'Cargando archivos...';
        try {
            const response = await fetch(`${API_BASE_URL}/files?directory=${directory}`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            
            if (data.files && data.files.length > 0) {
                data.files.forEach(file => {
                    const listItem = document.createElement('li');
                    listItem.textContent = file.split('/').pop(); // Display just the file name
                    listItem.dataset.fullPath = file; // Store full path for content loading
                    listItem.addEventListener('click', () => loadFileContent(file));
                    fileList.appendChild(listItem);
                });
                fileContent.textContent = `Archivos en ${directory}:`;
            } else {
                fileContent.textContent = `No se encontraron archivos en ${directory}.`;
            }
        } catch (error) {
            console.error('Error al cargar archivos:', error);
            fileContent.textContent = `Error al cargar archivos de ${directory}.`;
        }
    }

    async function loadFileContent(filePath) {
        fileContent.textContent = 'Cargando contenido...';
        try {
            const response = await fetch(`${API_BASE_URL}/file-content?path=${filePath}`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const content = await response.text();
            fileContent.textContent = content;
        } catch (error) {
            console.error('Error al cargar contenido del archivo:', error);
            fileContent.textContent = `Error al cargar el contenido de ${filePath}.`;
        }
    }

    // Initial load
    loadFiles('00_FUENTES_PROCESADAS');
});
