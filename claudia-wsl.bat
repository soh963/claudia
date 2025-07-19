@echo off
REM Claudia launcher - Direct WSL execution

echo Starting Claudia in WSL...

REM Run a complete bash session with all environment setup
wsl -e bash -lic "cd /mnt/d/claudia && npm run tauri dev"

pause