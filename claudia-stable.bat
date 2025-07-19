@echo off
REM Claudia launcher for Windows - Stable version
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

REM Use a more comprehensive startup command
echo Setting up environment and starting Claudia...

REM Try with comprehensive environment setup
wsl -e bash -c "cd /mnt/d/claudia && export PATH=/root/.bun/bin:/root/.nvm/versions/node/v23.11.0/bin:/root/.cargo/bin:$PATH && source ~/.bashrc && npm run tauri dev"

REM If npm fails, try with bun
if %errorlevel% neq 0 (
    echo.
    echo Trying with bun...
    wsl -e bash -c "cd /mnt/d/claudia && export PATH=/root/.bun/bin:/root/.nvm/versions/node/v23.11.0/bin:/root/.cargo/bin:$PATH && source ~/.bashrc && bun run tauri dev"
)

REM If still fails, show diagnostic information
if %errorlevel% neq 0 (
    echo.
    echo Error: Failed to start Claudia.
    echo.
    echo Checking environment...
    wsl -e bash -c "echo 'Node.js:' && which node && node --version"
    wsl -e bash -c "echo 'Bun:' && which bun && bun --version"
    wsl -e bash -c "echo 'Cargo:' && which cargo && cargo --version"
    echo.
    echo Please ensure Node.js, Bun, and Rust are properly installed in WSL.
)

pause