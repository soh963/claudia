# Windows에서 Claudia 설정하기

## 1. Windows 명령 프롬프트에서 Claudia 실행하기

### 방법 1: 환경 변수에 경로 추가
1. Windows 환경 변수 PATH에 `D:\claudia` 폴더 추가
2. 명령 프롬프트에서 다음 명령 실행:
   ```cmd
   claudia
   ```

### 방법 2: 배치 파일 직접 실행
```cmd
D:\claudia\claudia.bat
```

### 제공된 배치 파일
- `claudia.bat` - 기본 실행 파일 (login shell 사용)
- `claudia-simple.bat` - 간단한 실행 파일
- `claudia-stable.bat` - 상세한 환경 설정 포함
- `claudia-wsl.bat` - 직접 WSL 실행 방식

## 2. 한글 입력 문제 해결

### 수정된 내용
1. **IME (Input Method Editor) 지원 추가**
   - `onCompositionStart` - 한글 입력 시작 감지
   - `onCompositionEnd` - 한글 입력 완료 감지
   - 한글 입력 중에는 Enter 키가 동작하지 않도록 수정

2. **수정된 파일**
   - `/src/components/FloatingPromptInput.tsx`

### 한글 입력 방법
1. 채팅 입력창 클릭
2. 한/영 키로 한글 입력 모드 전환
3. 한글 입력
4. Enter 키로 전송 (한글 조합 중에는 Enter가 동작하지 않음)

### 테스트 방법
1. Claudia 실행
2. 프로젝트 폴더 선택
3. 입력창에서 한글 입력 테스트:
   - "안녕하세요"
   - "한글 입력이 잘 되나요?"
   - 한/영 전환 테스트

## 3. 주의사항

### WSL 요구사항
- Windows 10 버전 2004 이상 또는 Windows 11
- WSL2가 설치되어 있어야 함
- WSLg 또는 X11 서버가 실행 중이어야 함

### 한글 입력 관련
- Windows IME가 활성화되어 있어야 함
- 한/영 전환 키가 정상 작동해야 함
- 브라우저에서는 한글 입력이 더 안정적일 수 있음

## 4. 문제 해결

### "bun: not found" 또는 "node: not found" 오류
이 오류는 WSL 내부의 PATH 설정 문제입니다. 해결 방법:

1. **수정된 claudia.bat 사용** (권장)
   - 최신 버전은 `-lic` 옵션으로 login shell을 사용하여 환경 변수를 자동 로드

2. **수동으로 WSL 환경 확인**
   ```cmd
   wsl -e bash -lic "which node"
   wsl -e bash -lic "which bun"
   wsl -e bash -lic "which cargo"
   ```

3. **WSL 내부에서 직접 실행**
   ```bash
   wsl
   cd /mnt/d/claudia
   npm run tauri dev
   ```

### Claudia가 실행되지 않을 때
1. WSL 상태 확인: `wsl --status`
2. Node.js 설치 확인: `wsl -e bash -lic "node --version"`
3. Rust 설치 확인: `wsl -e bash -lic "cargo --version"`
4. Bun 설치 확인: `wsl -e bash -lic "bun --version"`

### 한글 입력이 안 될 때
1. Windows IME 설정 확인
2. 브라우저 콘솔에서 Composition 이벤트 로그 확인
3. 다른 브라우저에서 테스트 (Chrome, Edge 권장)

### 디버깅
브라우저 개발자 도구(F12)에서 콘솔 로그 확인:
- "[FloatingPromptInput] Composition started" - 한글 입력 시작
- "[FloatingPromptInput] Composition ended" - 한글 입력 완료