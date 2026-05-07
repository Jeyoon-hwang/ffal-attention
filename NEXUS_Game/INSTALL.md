# 설치 가이드 - NEXUS 무술 창조

**버전:** 1.0.0  
**마지막 업데이트:** 2026-05-07

---

## 📥 다운로드

공식 웹사이트에서 최신 버전을 다운로드하세요:
- **https://nexus-game.dev/download**

또는 Steam에서:
- **https://store.steampowered.com/app/nexus-game**

---

## 🪟 Windows 설치

### 시스템 요구사항
- **OS:** Windows 10 / 11 (64-bit)
- **CPU:** Intel i5 / AMD Ryzen 5 이상
- **RAM:** 8GB 이상
- **GPU:** NVIDIA GTX 960 / AMD R9 290 이상
- **저장공간:** 5GB 이상 (SSD 권장)
- **DirectX:** 12 이상

### 설치 단계

#### 1단계: 다운로드 및 해제
```
1. NEXUS_Game_Windows.zip 다운로드
2. 원하는 폴더에 해제 (예: C:\Games\NEXUS)
3. 해제 완료 대기 (약 30초)
```

#### 2단계: 실행
```
1. 해제된 폴더 열기
2. NEXUS.exe 더블클릭
3. 첫 실행 시 초기 설정 (약 5초)
4. 게임 시작!
```

#### 3단계: 바탕화면 바로가기 (선택)
```
1. NEXUS.exe 우클릭
2. "바로가기 생성" 클릭
3. 바탕화면으로 이동
```

### 문제 해결

#### ❌ "DirectX 12가 필요합니다" 오류
```
해결책:
1. Windows Update 실행 (설정 → 업데이트 및 보안)
2. 그래픽 드라이버 업데이트
   - NVIDIA: nvidia.com/Download/driverDetails
   - AMD: amd.com/en/support

또는:
3. 재설치 (한 단계 위로 올라가서 새로 해제)
```

#### ❌ 게임이 실행되지 않음
```
해결책:
1. 관리자 권한으로 실행
   - NEXUS.exe 우클릭 → "관리자 권한으로 실행"

2. 안티바이러스 확인
   - Windows Defender/다른 안티바이러스가 차단할 수 있음
   - 예외 추가: [설치 경로]/NEXUS.exe

3. .NET Framework 설치 확인
   - Windows 11은 자동 포함
   - Windows 10: Microsoft .NET Framework 4.8 필요
```

#### ❌ "GPU 드라이버 오류"
```
해결책:
1. 그래픽 드라이버 업데이트
2. VRAM 확인 (최소 2GB)
3. 오버클럭 해제 (있는 경우)
```

---

## 🍎 macOS 설치

### 시스템 요구사항
- **OS:** macOS 10.15 이상
- **CPU:** Intel / Apple Silicon
- **RAM:** 8GB 이상
- **GPU:** 내장 그래픽 이상
- **저장공간:** 5GB 이상 (SSD 권장)

### 설치 단계 (Intel Mac)

#### 1단계: 다운로드 및 해제
```
1. NEXUS_Game_macOS_Intel.zip 다운로드
2. Downloads 폴더에서 자동 해제 (또는 더블클릭)
3. Applications 폴더로 이동
```

#### 2단계: 실행
```
1. Applications 폴더에서 NEXUS.app 찾기
2. 더블클릭
3. 보안 경고 (처음 실행 시만)
   - "열기" 클릭
4. 게임 시작!
```

### 설치 단계 (Apple Silicon Mac - M1/M2/M3)

#### 1단계: 다운로드 및 해제
```
1. NEXUS_Game_macOS_ARM64.zip 다운로드
2. Downloads 폴더에서 자동 해제
3. Applications 폴더로 이동
```

#### 2단계: 실행
```
1. Applications 폴더에서 NEXUS.app 찾기
2. 우클릭 → "열기" (또는 더블클릭 후 경고에서 "열기")
3. 게임 시작!
```

### 문제 해결

#### ❌ "손상된 파일" 경고
```
해결책:
1. Gatekeeper 보안 해제 (일시적)
2. 터미널 실행 (Command + Space → Terminal)
3. 다음 명령 입력:
   xattr -rd com.apple.quarantine ~/Applications/NEXUS.app
4. 확인 후 실행
```

#### ❌ "확인할 수 없는 개발자"
```
해결책:
1. 우클릭 → "열기"
2. 경고 창에서 "열기" 클릭
3. macOS는 이를 기억하고 다음부터는 정상 실행
```

#### ❌ Apple Silicon에서 실행 안 됨
```
해결책:
1. Intel 버전 다운로드 (Rosetta 2로 자동 번역됨)
2. 또는 ARM64 네이티브 버전 다시 다운로드
3. 문의: support@nexus-game.dev
```

---

## 🐧 Linux 설치

### 시스템 요구사항
- **OS:** Ubuntu 20.04 / 22.04 또는 동등 배포판
- **CPU:** Intel / AMD 64-bit
- **RAM:** 8GB 이상
- **GPU:** OpenGL 4.0 이상
- **저장공간:** 5GB 이상

### 의존성 설치

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
    libgl1 \
    libxrandr2 \
    libxinerama1 \
    libxi6 \
    libxcursor1 \
    libglib2.0-0 \
    libxext6 \
    libx11-6

# Fedora/RHEL
sudo dnf install -y \
    mesa-libGL \
    libXrandr \
    libXinerama \
    libXi \
    libXcursor \
    glib2 \
    libXext \
    libX11
```

### 설치 단계

```bash
# 1. 다운로드 및 해제
unzip NEXUS_Game_Linux.zip
cd NEXUS_Game_Linux

# 2. 실행 권한 부여
chmod +x NEXUS

# 3. 게임 실행
./NEXUS

# 또는 (권장)
./NEXUS &
```

### 바탕화면 바로가기 생성 (선택)

```bash
# Desktop 아이콘 생성
cat > ~/.local/share/applications/nexus.desktop << EOF
[Desktop Entry]
Type=Application
Name=NEXUS 무술 창조
Exec=$(pwd)/NEXUS
Icon=$(pwd)/icon.png
Categories=Games;
Terminal=false
EOF

# 바탕화면에 바로가기 생성
cp ~/.local/share/applications/nexus.desktop ~/Desktop/
chmod +x ~/Desktop/nexus.desktop
```

### 문제 해결

#### ❌ "라이브러리를 찾을 수 없음" 오류
```
해결책:
1. 위의 의존성 설치 단계 실행
2. 또는:
   ldd ./NEXUS
   # 출력에서 "not found"인 것 확인 후 설치
```

#### ❌ "권한 거부" 오류
```
해결책:
chmod +x NEXUS
```

#### ❌ "X11 오류" 또는 Wayland 호환성
```
해결책:
# X11 환경에서 실행
GDK_BACKEND=x11 ./NEXUS

# 또는 Wayland 지원 설정
export QT_QPA_PLATFORM=wayland
```

---

## 🎮 첫 실행 후 설정

### 초기 설정 화면

게임을 첫 실행하면 다음 설정을 확인합니다:

1. **게임 설정**
   - 난이도 선택 (초급, 보통, 어려움, 신급)
   - 언어 (한국어, 영어)

2. **그래픽 설정**
   - 해상도 (1920x1080, 2560x1440 등)
   - FPS 제한 (60, 120, 무제한)
   - 그래픽 품질 (낮음, 중간, 높음)

3. **사운드 설정**
   - 마스터 볼륨
   - 배경음악 / 효과음 / 음성

### 게임 시작

설정 완료 후:
1. "새 게임" 선택
2. 캐릭터 생성 (간단한 설정)
3. 중원으로 입장
4. 게임 시작!

---

## 🚀 성능 최적화

### 낮은 사양 PC에서 실행

```
설정:
- 해상도: 1280x720 또는 1600x900
- FPS 제한: 30 또는 60
- 그래픽 품질: 낮음
- 입자 효과: 비활성화
- 그림자: 낮음

결과:
- 대부분의 게임 구간에서 30 FPS 유지
- 전투 시 약간의 버벅거림 가능 (문제 없음)
```

### 고성능 PC에서 최적화

```
설정:
- 해상도: 2560x1440 또는 3840x2160
- FPS 제한: 120 또는 무제한
- 그래픽 품질: 높음
- 입자 효과: 활성화
- 그림자: 높음

결과:
- 부드러운 120 FPS 플레이
- 아름다운 그래픽 경험
```

---

## 📋 체크리스트

설치가 완료되었나요? 확인해보세요:

- [ ] NEXUS 실행됨
- [ ] 초기 메뉴 화면 보임
- [ ] 설정 완료
- [ ] 새 게임 시작 가능
- [ ] 캐릭터 생성 가능
- [ ] 게임 플레이 가능

모두 확인되었다면 **설치 완료!** 🎉

---

## 🆘 추가 지원

설치 중 문제가 발생했나요?

### 자주 묻는 질문
- [FAQ.md](./FAQ.md) 참고

### 버그 리포트
- **이메일:** support@nexus-game.dev
- **Discord:** discord.gg/nexus-game

### 커뮤니티
- **포럼:** nexus-game.dev/forum
- **Reddit:** r/NEXUSGame

---

**⚡ 설치 완료! 게임을 즐기세요! ⚡**

v1.0.0 | 2026-05-07
