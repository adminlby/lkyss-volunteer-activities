@echo off
rem HK Oldies Sing-Along - start a local HTTP server and open the game.
rem Keep this window open while the game is running.
cd /d "%~dp0"
set PORT=8765

where python >nul 2>nul
if errorlevel 1 (
  where py >nul 2>nul
  if errorlevel 1 (
    echo Python not found. Please install Python 3, or run a local HTTP server manually.
    echo Example: python -m http.server 8765
    pause
    exit /b 1
  ) else (
    start "HK Oldies Server" /min cmd /c "py -m http.server %PORT% --bind 127.0.0.1"
  )
) else (
  start "HK Oldies Server" /min cmd /c "python -m http.server %PORT% --bind 127.0.0.1"
)

timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:%PORT%/"
exit /b 0
