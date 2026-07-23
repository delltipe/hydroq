@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_all_checks.ps1"
if errorlevel 1 (
  echo.
  echo Verification failed. Review the error above.
  pause
  exit /b 1
)
echo.
echo All HydroQ checks passed.
pause
