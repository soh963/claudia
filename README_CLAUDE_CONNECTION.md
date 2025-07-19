# Claudia - Claude Code Max 연결 가이드

## 현재 상태 ✅

1. **Claude Code 설치 완료**
   - 경로: `/root/.bun/bin/claude`
   - 버전: 1.0.56
   - 인증: 유효함 (토큰 확인됨)

2. **Claudia 실행 중**
   - URL: http://localhost:1420/
   - Tauri 데스크톱 앱 실행 중
   - Claude Code 바이너리 경로 자동 감지

3. **코드 수정 완료**
   - `--dangerously-skip-permissions` 플래그 제거 (root 권한 문제 해결)
   - `/src-tauri/src/commands/claude.rs` 파일 수정됨

## Claudia 사용 방법

### 1. Claudia 실행
```bash
# WSL에서 실행
source ~/.nvm/nvm.sh && source ~/.cargo/env && npm run tauri dev

# 또는 Windows에서
wsl bash -c "source ~/.nvm/nvm.sh && source ~/.cargo/env && cd /mnt/d/claudia && npm run tauri dev"
```

### 2. Claude Code 연결 사용

1. Tauri 데스크톱 창에서 Claudia 열기
2. 프로젝트 폴더 선택 (예: `/mnt/d/claudia`)
3. 프롬프트 입력 (예: "이 프로젝트의 구조를 설명해줘")
4. Enter 키 또는 전송 버튼 클릭
5. Claude Code가 자동으로 실행되어 응답

### 3. 기능 확인

- **세션 관리**: 대화 내역이 `~/.claude/projects/`에 저장됨
- **스트리밍 출력**: 실시간으로 Claude의 응답 확인
- **도구 사용**: Claude가 파일 읽기, 편집, 터미널 명령 등 실행

## 문제 해결

### Claude Code가 연결되지 않을 때
1. Claude Code 설치 확인: `which claude`
2. 버전 확인: `claude --version`
3. 인증 확인: `claude -p "Hello" --model sonnet --output-format json`

### Tauri 창이 보이지 않을 때
1. WSLg 또는 X11 서버 실행 확인
2. `DISPLAY` 환경 변수 확인: `echo $DISPLAY`
3. VcXsrv 실행 (Windows 10) 또는 WSLg 활성화 (Windows 11)

### 권한 오류 발생 시
- root가 아닌 일반 사용자로 실행 권장
- 또는 이미 수정된 코드 사용 (--dangerously-skip-permissions 제거됨)

## 기술 스택

- **Frontend**: React + TypeScript + Vite
- **Backend**: Rust + Tauri
- **Claude Integration**: Claude Code 바이너리 직접 실행
- **인증**: Claude Code Max 구독 (API 키 불필요)