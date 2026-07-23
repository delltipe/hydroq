@echo off
setlocal
call "%~dp0setup_windows.bat"
if errorlevel 1 exit /b 1
call "%~dp0run_web_windows.bat"
