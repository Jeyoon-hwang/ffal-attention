# 🚀 NEXUS 개발 상황 대시보드

**프로젝트:** 무술 창조 게임 (Option 2)  
**엔진:** Godot 4.2  
**타임라인:** 12주 (2026-05-07 ~ 2026-07-29)  
**현재 날짜:** 2026-05-07  
**현재 진행률:** 준비 중 (0%)

---

## 📊 주요 문서

| 문서 | 내용 | 상태 |
|------|------|------|
| **GDD_OPTION2_FINAL.md** | 게임 전체 설계 (스펙, 월드, 시스템) | ✅ 완료 |
| **ROADMAP_12WEEKS_TIGHT.md** | 12주 타이트 로드맵 (주별 목표) | ✅ 완료 |
| **PROJECT_STRUCTURE.md** | 프로젝트 폴더 & 파일 구조 | ✅ 완료 |
| **WEEK1_DAY1-2_ACTION_PLAN.md** | 지금 해야 할 일 (Day 1-2 상세 계획) | ✅ 완료 |
| **CLASS_DESIGN.md** | 핵심 클래스 설계 (MartialArt, Player 등) | 📋 Day 2 생성 |
| **DATA_FORMAT.md** | 데이터 포맷 정의 (JSON 스키마) | 📋 Day 2 생성 |

---

## 🎯 Week 1-2 목표 (프로토타입)

### 핵심 산출물 (2주 내)
- ✅ **무술 생성 엔진** (동작)
- ✅ **플레이어 전투 시스템** (기본)
- ✅ **적 AI Level 1-2** (동작)
- ✅ **중원 프로토타입** (플레이 가능)
- ✅ **첫 보스** (클리어 가능)

### 완성도 목표
- **Day 2 말:** 기초 클래스 완성 (20% 준비)
- **Day 14 말:** 프로토타입 플레이 가능 (20% 완성도)

---

## 📅 지금부터 시작 (Day 1-2, 2026-05-07 ~ 2026-05-08)

### ⚡ Day 1 (5시간) - 프로젝트 초기화

**Task 1: Godot 4.2 설치 & 확인** (30분)
```bash
# Godot 4.2 다운로드 & 설치
godot --version  # 4.2.x 이상 확인
```
✅ 완료 체크: 버전 확인됨

**Task 2: Git & 폴더 구조** (20분)
```bash
cd /Users/hwangjeyeong/.openclaw/workspace
mkdir NEXUS
cd NEXUS
git init
# 폴더 구조 생성 (Assets, Scripts, Scenes, Data, Docs, etc.)
```
✅ 완료 체크: 폴더 생성, .gitignore 작성

**Task 3: Godot 프로젝트 생성** (30분)
- Godot 에디터 → New Project
- 경로: `/Users/hwangjeyeong/.openclaw/workspace/NEXUS`
- 렌더러: Forward+
- 기본 설정 (해상도, 물리)

✅ 완료 체크: project.godot 생성, 에디터 실행 가능

**Task 4: 핵심 클래스 설계서** (1시간)
- `Docs/CLASS_DESIGN.md` 작성
- MartialArt, Player, Enemy, CombatSystem, AIController 설계

✅ 완료 체크: 문서 작성 완료

**Task 5: 데이터 포맷 정의** (1.5시간)
- `Docs/DATA_FORMAT.md` 작성
- JSON 스키마 정의

✅ 완료 체크: 문서 작성 완료

**Task 6: 첫 Git 커밋** (30분)
```bash
git add .
git commit -m "Initial project setup: Godot 4.2, structure, docs"
```
✅ 완료 체크: 커밋 완료

---

### ⚡ Day 2 (5시간) - 핵심 클래스 구현

**Task 1: MartialArt 클래스** (30분)
- `Scripts/Martial/MartialArt.gd` 작성
- 속성: id, name, power, energy_cost, effect 등
- 메서드: calculate_damage(), to_dict(), from_dict()

✅ 완료 체크: 클래스 구현, 컴파일 성공

**Task 2: Player 클래스** (1시간)
- `Scripts/Combat/Player.gd` 작성
- 스탯, 체력, 에너지, 무술 슬롯
- 입력 처리 (WASD 이동, 1-5 공격)

✅ 완료 체크: 기본 동작 확인

**Task 3: Enemy 클래스** (45분)
- `Scripts/Combat/Enemy.gd` 작성
- AI 상태 머신 (Idle → Chase → Attack)
- take_damage(), die()

✅ 완료 체크: 클래스 구현

**Task 4: MartialArtEngine** (1시간)
- `Scripts/Martial/MartialArtEngine.gd` 작성
- generate_martial_art(), load_martial_arts(), save_martial_arts()

✅ 완료 체크: 무술 생성 테스트

**Task 5: CombatSystem** (45분)
- `Scripts/Combat/CombatSystem.gd` 작성
- calculate_damage(), execute_attack(), apply_effect()

✅ 완료 체크: 데미지 계산 테스트

**Task 6: 테스트 씬** (1시간)
- `Scenes/CombatTest.tscn` 생성
- Player + Enemy + CombatSystem 통합
- 게임 실행 테스트

✅ 완료 체크: 게임 실행, 기본 입력 작동

**Task 7: Git 커밋** (15분)
```bash
git add .
git commit -m "Day 2: Core classes (MartialArt, Player, Enemy, CombatSystem), combat test"
```
✅ 완료 체크: 커밋 완료

---

## 📋 Day 3-7 (Week 1 후반) - 무술 엔진 & 첫 보스

**예정 작업:**
1. 무술 생성 엔진 고도화 (100+ 무술)
2. 플레이어 전투 완성 (콤보, 방어)
3. 적 AI Level 3-4 구현
4. 첫 보스 AI & 패턴
5. 중원 맵 프로토타입
6. 첫 던전 구현
7. 무술관 NPC & 강화 시스템

---

## 📊 완성도 추적

### 현재 상황
```
Week 1-2: 프로토타입       [==--------] 10%
  ├─ 엔진 & 기초          [====------] 40%
  ├─ 그래픽 & 애니        [----------] 0%
  └─ 콘텐츠              [----------] 0%

Week 3-4: 그래픽           [----------] 0%
Week 5-6: 콘텐츠           [----------] 0%
Week 7-8: 심화 & 엔드      [----------] 0%
Week 9-10: 최적화          [----------] 0%
Week 11-12: 폴리시 & 출시  [----------] 0%

=== TOTAL: 10% (준비 단계) ===
```

### 목표 (Week 2 말)
```
Week 1-2: 프로토타입       [========--] 80%
  ├─ 엔진 & 기초          [========--] 80%
  ├─ 무술 엔진            [========--] 80%
  ├─ 플레이어 전투        [======----] 60%
  ├─ 적 AI                [======----] 60%
  ├─ 첫 보스              [====------] 40%
  └─ 콘텐츠 (기본)        [====------] 40%

=== TARGET: 20% (프로토타입 플레이 가능) ===
```

---

## 🎯 성공 기준 (Week 2 말)

### 게임 플레이 가능해야 함:
1. ✅ 캐릭터 생성 & 기본 스탯
2. ✅ WASD 이동 가능
3. ✅ 1-5 슬롯 무술 사용 가능
4. ✅ 적과 전투 가능
5. ✅ 기본 보스 클리어 가능
6. ✅ 무술 강화 가능
7. ✅ 레벨업 가능

### 에러 & 버그:
- 치명적 에러: 0개
- 경고: 최소화
- 성능: 60 FPS 유지

---

## 🔥 황제영, 지금 해야 할 일!

### **Day 1 (오늘, 5시간)**
```
[ ] 1. Godot 4.2 설치
[ ] 2. NEXUS 폴더 생성 & Git 초기화
[ ] 3. 폴더 구조 생성
[ ] 4. Godot 프로젝트 생성
[ ] 5. CLASS_DESIGN.md 작성
[ ] 6. DATA_FORMAT.md 작성
[ ] 7. 첫 커밋
```

### **Day 2 (내일, 5시간)**
```
[ ] 1. MartialArt.gd 작성
[ ] 2. Player.gd 작성
[ ] 3. Enemy.gd 작성
[ ] 4. MartialArtEngine.gd 작성
[ ] 5. CombatSystem.gd 작성
[ ] 6. CombatTest.tscn 생성
[ ] 7. 게임 실행 테스트
[ ] 8. 두 번째 커밋
```

### **Day 3-7 (Week 1 후반)**
- 무술 엔진 고도화
- 전투 시스템 완성
- 적 AI 완성
- 첫 보스 구현
- 중원 맵 기본

---

## 📞 문의 사항

### "뭘 먼저 해?"
1. **Godot 4.2 설치** (Day 1 Task 1)
2. **폴더 생성** (Day 1 Task 2)
3. **프로젝트 생성** (Day 1 Task 3)

### "무술 시스템은 어떻게?"
- `Docs/CLASS_DESIGN.md` 참고 (MartialArt 클래스)
- 기본: 100가지 동작 × 리듬 × 방어타입 = 수천 조합
- 최종: 프래그먼트 시스템으로 수백만 가능

### "적 AI는?"
- Level 1: 간단 (추격 + 공격)
- Level 2: 기본 (패턴 감지, 회피)
- Level 3: 고급 (약점 적응)
- Level 4: 마스터 (멀티페이즈 보스)

---

## 🗂️ 빠른 참고

### 핵심 파일 위치
```
/Users/hwangjeyeong/.openclaw/workspace/
├── GDD_OPTION2_FINAL.md
├── ROADMAP_12WEEKS_TIGHT.md
├── PROJECT_STRUCTURE.md
├── WEEK1_DAY1-2_ACTION_PLAN.md
├── DEV_STATUS.md (이 파일)
└── NEXUS/
    ├── Assets/
    ├── Scripts/
    ├── Scenes/
    ├── Data/
    └── Docs/
```

### 중요한 커맨드
```bash
cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS

# Godot 실행
godot

# Git 상태 확인
git status

# 커밋
git add .
git commit -m "메시지"

# 로그 확인
git log --oneline -5
```

---

## ✅ 다음 체크포인트

- **Day 2 말:** 기초 클래스 구현 완료, 테스트 씬 실행 가능
- **Day 7 말:** 프로토타입 플레이 가능 (20% 완성도)
- **Day 14 말:** 첫 보스 클리어 가능

---

**Version:** 1.0  
**Updated:** 2026-05-07  
**Status:** 🚀 준비 완료, 개발 시작!

---

## 📝 메모

- 에러는 빠르게 잡을수록 저렴 → 매일 테스트
- 밸런싱은 Day 1부터 시작 → 계속 조정
- 병렬 작업 가능 (그래픽팀 + 프로그래머) → 두 팀 동시 진행
- 완벽함은 나중 → 프로토타입부터 플레이 가능하게
