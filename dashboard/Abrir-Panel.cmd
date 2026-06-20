@echo off
REM Re-escanea tu flota y abre el panel (Windows, doble-clic).
REM Lee las rutas de flota.config.json; o pasa --centro "..." --proyectos "..." como argumentos.
cd /d "%~dp0"
python escanear-flota.py --abrir %*
if errorlevel 1 (
  echo.
  echo No se pudo ejecutar. Comprueba que Python esta instalado y que existe flota.config.json
  echo (copia flota.config.example.json y pon tus rutas^).
  pause
)
