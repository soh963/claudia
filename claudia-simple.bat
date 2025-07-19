@echo off
wsl bash -c "cd /mnt/d/claudia && source ~/.nvm/nvm.sh && source ~/.cargo/env && npm run tauri dev"