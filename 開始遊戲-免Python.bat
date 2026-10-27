@echo off
rem HK Oldies Sing-Along - no Python, no admin.
rem Starts a small PowerShell local server and opens the game.
rem Keep the server window open while the game is running.
cd /d "%~dp0"

start "HK Oldies Server" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:8765/"
exit /b 0
