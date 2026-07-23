@echo off
setlocal
cd /d "%~dp0hydroq"
call scripts\setup_windows.bat
if errorlevel 1 exit /b 1
call scripts\run_web_windows.bat
