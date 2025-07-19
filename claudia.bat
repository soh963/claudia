@echo off
REM Claudia launcher for Windows
REM This batch file starts Claudia from Windows command prompt

echo Starting Claudia...

REM Check if WSL is available
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: WSL is not installed or not available.
    echo Please install WSL to run Claudia.
    pause
    exit /b 1
)

REM Run Claudia with login shell to ensure all environment variables are loaded
echo Loading WSL environment and starting Claudia...
wsl -e bash -lic "cd /mnt/d/claudia && npm run tauri dev"

REM If npm fails, try with bun
if %errorlevel% neq 0 (
    echo.
    echo Trying with bun...
    wsl -e bash -lic "cd /mnt/d/claudia && bun run tauri dev"
)

REM If still fails, show diagnostic information
if %errorlevel% neq 0 (
    echo.
    echo Error: Failed to start Claudia.
    echo Please check that Node.js and Rust are installed in WSL.
)

pause