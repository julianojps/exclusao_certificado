@echo off
title Monitor MS-Organization-Access
echo Iniciando monitor de certificados...
echo.
powershell -NoExit -ExecutionPolicy Bypass -NoLogo -NoProfile -File "%~dp0remover-cert-msorg.ps1"
pause
