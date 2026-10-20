@echo off
title Launching UAC Terminal Prompt...
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uac_prompt.ps1"

