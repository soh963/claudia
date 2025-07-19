#!/bin/bash

# Claudia 실행 스크립트

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting Claudia...${NC}"

# NVM 환경 설정
source ~/.nvm/nvm.sh

# Cargo 환경 설정
source ~/.cargo/env

# 프로젝트 디렉토리로 이동
cd /mnt/d/claudia

# 의존성 확인
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
fi

# Tauri 개발 서버 실행
npm run tauri dev