# 🎮 NEXUS - 시작 가이드

## 설치 완료! ✅

### 설치된 도구
- ✅ Godot 4.6.2 (게임 엔진)
- ✅ 프로젝트 구조 생성
- ✅ 핵심 스크립트 작성 (플레이어, 적, 게임 매니저)
- ✅ 게임 디자인 문서 (GDD)
- ✅ 기본 게임 장면 설계

### 프로젝트 구조
```
game-nexus/
├── src/
│   ├── scripts/
│   │   ├── player.gd          (플레이어 제어)
│   │   ├── enemy.gd           (적 AI)
│   │   ├── game_manager.gd    (웨이브/난이도)
│   │   └── ui_manager.gd      (UI/HUD)
│   └── scenes/
│       ├── main.tscn          (메인 씬)
│       ├── player.tscn        (플레이어 모델)
│       └── enemy.tscn         (적 모델)
├── project.godot              (Godot 설정)
└── docs/
    └── GDD.md                 (게임 디자인 문서)
```

---

## 🚀 게임 실행하기

### 방법 1: 터미널에서
```bash
cd /Users/hwangjeyeong/.openclaw/workspace/game-nexus
godot
```

### 방법 2: Applications에서
1. Godot.app 열기
2. "Open Project" → `/Users/hwangjeyeong/.openclaw/workspace/game-nexus` 선택
3. Play 버튼 클릭

---

## 🎮 게임 플레이

### 컨트롤
- **이동**: WASD
- **시점**: 마우스 움직임
- **점프**: Space
- **공격**: X 키
- **종료**: ESC

### 게임 목표
- 웨이브마다 스폰되는 적을 모두 제거
- 웨이브가 높을수록 적이 강해짐
- 최고 점수를 목표로!

---

## 🛠️ 다음 개발 단계

### 즉시 할 일 (Next 30 mins)
1. [ ] Godot에서 프로젝트 열기
2. [ ] 메인 씬 로드
3. [ ] 플레이 버튼으로 게임 테스트
4. [ ] 버그 리포트

### 단기 (Next 1-2 hours)
1. [ ] 3D 모델 개선 (큐브/캡슐 → 사이버펑크 스타일)
2. [ ] 공격 VFX 추가
3. [ ] 파티클 시스템
4. [ ] 사운드 이펙트

### 중기 (Next 4-6 hours)
1. [ ] 보스 전투 시스템
2. [ ] 아이템 드롭 & 픽업
3. [ ] 업그레이드 트리 UI
4. [ ] 게임 오버 화면

### 장기 (Next 24+ hours)
1. [ ] 모바일 터치 컨트롤
2. [ ] 모바일 최적화
3. [ ] VR 지원
4. [ ] 스팀/앱스토어 준비

---

## 🎨 에셋 리소스

### 3D 모델 (무료 옵션)
- [Sketchfab](https://sketchfab.com) - 사용 가능한 모델
- [TurboSquid Free](https://www.turbosquid.com/search/3d-models/free)
- [CGTrader Free](https://www.cgtrader.com/free-3d-models)

### 사운드 (로열티 프리)
- [Freesound](https://freesound.org)
- [Pixabay Music](https://pixabay.com/music)
- [ZapSplat](https://www.zapsplat.com)

### 음악 생성
- AI 사용 (Suno, MusicLM)
- 또는 Ollama에서 로컬 생성

---

## 📊 개발 진행도

```
[████████░░] 40% 완료
- [████████] 코어 게임 루프 ✅
- [███░░░░░░] 3D 모델 & VFX
- [░░░░░░░░░░] 멀티플랫폼 포팅
- [░░░░░░░░░░] 최종 포리싱
```

---

## 💡 팁

- **개발 중에는 항상 저장하세요** (Ctrl+S)
- **자주 테스트하세요** (버그 조기 발견)
- **성능은 나중에 최적화** (기능 우선)
- **에셋은 증분으로 추가** (큰 파일은 한 번에)

---

## 🔗 리소스

- [Godot 공식 문서](https://docs.godotengine.org)
- [Godot 튜토리얼](https://docs.godotengine.org/en/stable/community/tutorials.html)
- [GDD 작성 가이드](./docs/GDD.md)

---

## 📝 버그 리포트 템플릿

문제 발생 시:
```
## 버그 설명
[문제를 설명하세요]

## 재현 방법
1. ...
2. ...
3. ...

## 예상 결과
[뭐가 일어나야 하는가]

## 실제 결과
[뭐가 일어났는가]
```

---

**Happy Coding! 🚀**

*마지막 업데이트: 2026-05-05 22:52*
*개발자: 천재 AI 🤖*
