// script.js

document.addEventListener('DOMContentLoaded', () => {
    const processAllBtn = document.getElementById('processAllBtn');
    const folderButtons = document.querySelectorAll('.folder-list button');
    const fileList = document.getElementById('file-list');
    const fileContent = document.getElementById('file-content');
    const statusMessage = document.getElementById('statusMessage'); // NEW
    const loadingSpinner = document.getElementById('loadingSpinner'); // NEW

    const API_BASE_URL = document.documentElement.dataset.apiBaseUrl || 'http://127.0.0.1:8000';

    // --- Simple API service layer ---
    const Api = {
        listFiles: async (directory) => {
            const url = `${API_BASE_URL}/files?directory=${encodeURIComponent(directory)}`;
            const response = await fetch(url);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return response.json();
        },
        readFile: async (filePath) => {
            const url = `${API_BASE_URL}/file-content?path=${encodeURIComponent(filePath)}`;
            const response = await fetch(url);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return response.text();
        },
        processAll: async () => {
            const url = `${API_BASE_URL}/process`;
            const response = await fetch(url, { method: 'POST' });
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return response.json();
        }
    };

    // --- Event Listeners ---
    processAllBtn.addEventListener('click', async () => {
        processAllBtn.disabled = true;
        processAllBtn.textContent = 'Procesando...';
        statusMessage.textContent = 'Iniciando proceso completo...'; // NEW
        loadingSpinner.style.display = 'inline-block'; // NEW
        fileContent.textContent = ''; // Clear previous content

        try {
            const data = await Api.processAll();
            statusMessage.textContent = data.message; // Use statusMessage for feedback
            statusMessage.style.color = '#28a745'; // Green for success
        } catch (error) {
            console.error('Error al iniciar el proceso:', error);
            statusMessage.textContent = 'Error al iniciar el proceso. Verifique la consola del navegador y del servidor.'; // Use statusMessage for feedback
            statusMessage.style.color = '#dc3545'; // Red for error
        } finally {
            processAllBtn.disabled = false;
            processAllBtn.textContent = 'Iniciar Proceso Completo';
            loadingSpinner.style.display = 'none'; // NEW
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
        fileList.setAttribute('aria-busy', 'true');
        try {
            const data = await Api.listFiles(directory);
            
            if (data.files && data.files.length > 0) {
                data.files.forEach(file => {
                    const listItem = document.createElement('li');
                    listItem.textContent = file.split('/').pop(); // Display just the file name
                    listItem.dataset.fullPath = file; // Store full path for content loading
                    listItem.tabIndex = 0;
                    listItem.setAttribute('role', 'button');
                    listItem.addEventListener('click', () => loadFileContent(file));
                    listItem.addEventListener('keydown', (e) => {
                        if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            loadFileContent(file);
                        }
                    });
                    fileList.appendChild(listItem);
                });
                fileContent.textContent = `Archivos en ${directory}:`;
            } else {
                fileContent.textContent = `No se encontraron archivos en ${directory}.`;
            }
        } catch (error) {
            console.error('Error al cargar archivos:', error);
            fileContent.textContent = `Error al cargar archivos de ${directory}.`;
        } finally {
            fileList.removeAttribute('aria-busy');
        }
    }

    async function loadFileContent(filePath) {
        fileContent.textContent = 'Cargando contenido...';
        try {
            const content = await Api.readFile(filePath);
            const MAX_CHARS = 200000;
            fileContent.textContent = content.length > MAX_CHARS
                ? content.slice(0, MAX_CHARS) + '\n...[contenido truncado]'
                : content;
        } catch (error) {
            console.error('Error al cargar contenido del archivo:', error);
            fileContent.textContent = `Error al cargar el contenido de ${filePath}.`;
        }
    }

    // Initial load
    loadFiles('00_FUENTES_PROCESADAS');
});
