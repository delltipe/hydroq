@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"
if errorlevel 1 (
  echo.
  echo Setup gagal. Baca pesan error di atas.
  pause
  exit /b 1
)
exit /b 0
