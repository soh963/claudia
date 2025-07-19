@echo off
title Claudia

echo Starting Claudia...

REM WSL에서 실행
wsl bash -c "source ~/.nvm/nvm.sh && source ~/.cargo/env && cd /mnt/d/claudia && npm run tauri dev"

pause