@echo off
rem Update skills and AutoCAD connector. Run from Command Prompt:  setup\update.cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update.ps1"
pause
