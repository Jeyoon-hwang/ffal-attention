# 🔥 NEXUS Week 1-2 Day 3-4 액션 플랜 (2026-05-10 토요일)

**시간**: 2026-05-10 18:56 PM ~ 2026-05-11 (예정)  
**대상**: Week 1-2 Day 3-4 (무술 생성 엔진 → 플레이어 전투 시스템)  
**목표**: 0% → 20% (프로토타입 기초 완성)  
**에러**: 0건 유지  

---

## 📋 현재 상태 점검

### ✅ 이미 완료된 것 (Day 1-2)
- ✅ Godot 4.2+ 프로젝트 초기화
- ✅ 폴더 구조 생성 (Assets, Scripts, Scenes, Data, Docs)
- ✅ 핵심 클래스 설계 (6개)
- ✅ MartialArtEngine.gd (기본 구조 있음)
- ✅ Player.gd (기본 구조 있음)
- ✅ CombatSystem.gd (기본 구조 있음)
- ✅ Enemy.gd (기본 구조 있음)

### ❓ 확인 필요한 것
- [ ] MartialArtEngine: 450개 무술 정말 생성되는지?
- [ ] Player: 무술 슬롯 5개 정상 작동?
- [ ] CombatSystem: 플레이어 vs 더미 전투 가능?
- [ ] 적 AI Level 1-2: 동작 확인?
- [ ] FirstBoss: 패턴 정상 작동?

### ❌ 아직 안 된 것
- [ ] 무술 생성 엔진 완전 테스트 (Day 3-4 목표)
- [ ] 플레이어 전투 완전 구현 (Day 5-6 목표)
- [ ] 중원 맵 프로토타입 (Day 10-11)
- [ ] 첫 보스 전투 (Day 10-11)

---

## 🎯 Day 3-4 목표 (오늘 & 내일)

### Priority 1: 무술 생성 엔진 완전 구현 (Day 3, 3-4시간)

**현재 상태 확인:**
1. MartialArtEngine.gd 열고 마지막 부분 읽기
2. 생성된 무술 수 확인 (목표: 450개 이상)
3. 테스트 스크립트 실행 (TestMartialArtEngine.gd)

**필요한 작업:**
1. **완전한 무술 데이터베이스 확인**
   - 기본 동작 100개 (punch, kick, guard, special, etc)
   - 리듬 3가지 (Fast, Mid, Slow)
   - 방어 타입 5가지 × 레벨 5 = 25가지
   - 추가 효과 20가지
   - **이론상 100 × 3 × 25 × 20 = 150,000조합** (실제는 더 많음)

2. **MartialArtEngine.gd 테스트 & 버그 수정**
   - `get_random_martial_art()` 함수 동작 확인
   - `save_martial_art()` / `load_martial_art()` 동작 확인
   - JSON 저장/로드 테스트

3. **출력:**
   - ✅ 테스트 결과 (무술 450+개 확인)
   - ✅ 버그 수정 (있으면)
   - ✅ MartialArtEngine v1.0 확정

### Priority 2: 플레이어 전투 시스템 기초 (Day 4, 3-4시간)

**현재 상태 확인:**
1. Player.gd 확인
   - 스탯 시스템 (STR, DEX, CON, INT, WIS, CHA)
   - 무술 슬롯 (5개)
   - HP/에너지 시스템

2. 기본 공격 시스템
   - `attack(martial_slot)` 함수
   - 에너지 소모
   - 데미지 계산

**필요한 작업:**
1. **Player.gd 완성**
   - 능력치 계산 함수 (`recalculate_max_hp()`)
   - 에너지 회복 로직 (`recover_energy()`)
   - 데미지 처리 (`take_damage()`)
   - 크리티컬 계산 (`calculate_critical()`)
   - 상태 관리 (기절, 경직, 다운)

2. **CombatSystem.gd와 통합 테스트**
   - Player vs Enemy 전투 시뮬레이션
   - 콤보 시스템 확인
   - 상태 이상 확인

3. **출력:**
   - ✅ Player v1.0 확정
   - ✅ CombatSystem 통합 테스트 (10턴 시뮬레이션)
   - ✅ 버그 리스트 (있으면)

---

## ✅ Day 3-4 체크리스트

### 오늘 (Day 3, 토요일 18:56~)

#### Task 1: 코드 읽기 & 상태 파악 (30분)
- [ ] MartialArtEngine.gd 전체 읽기 (offset=101부터)
- [ ] Player.gd 전체 읽기 (offset=101부터)
- [ ] CombatSystem.gd 전체 읽기 (offset=101부터)
- [ ] 현재 구현 상태 정리

#### Task 2: 무술 엔진 테스트 (1.5시간)
- [ ] TestMartialArtEngine.gd 생성 또는 실행
- [ ] 무술 450+개 생성 확인
- [ ] JSON 저장/로드 테스트
- [ ] 버그 수정 (있으면)

#### Task 3: 플레이어 전투 기초 테스트 (1시간)
- [ ] TestPlayerCombat.gd 생성
- [ ] 기본 공격 (1-5 슬롯)
- [ ] 에너지 소모 & 회복
- [ ] 콤보 시스템 확인

#### Task 4: Git 커밋 & 메모리 업데이트 (30분)
- [ ] 진행 상황 커밋 (Day 3 진행)
- [ ] MEMORY.md 업데이트
- [ ] memory/2026-05-10.md 업데이트

**예상 소요시간**: 3.5시간

---

## 🚀 내일 (Day 4, 일요일)

### 목표
- 플레이어 전투 시스템 완성
- 적 AI Level 1-2 동작 확인
- 중원 맵 기초 구조
- 통합 테스트

### 예상 일정
- 09:00~12:00: 적 AI Level 1-2 검증 (3시간)
- 12:00~14:00: 중원 맵 기초 (2시간)
- 14:00~16:00: 통합 테스트 & 버그 수정 (2시간)
- 16:00~17:00: Git 커밋 & 메모리 (1시간)

**예상 소요시간**: 8시간

---

## 📊 Week 1-2 진행도 예상

| 단계 | 목표 | 현재 | Day 3-4 후 | 완료 예정 |
|------|------|------|----------|----------|
| **무술 엔진** | 100% | 70% | 95% | Day 3 |
| **플레이어 전투** | 100% | 40% | 80% | Day 4 |
| **적 AI** | 100% | 20% | 50% | Day 4 |
| **첫 보스** | 100% | 0% | 30% | Day 5-6 |
| **중원 맵** | 100% | 5% | 20% | Day 7 |
| **통합 테스트** | 100% | 0% | 50% | Day 7 |
| **총 진행도** | **20%** | **5%** | **12%** | **Day 7: 20%** |

---

## 🛠️ 기술 체크리스트

### MartialArtEngine
- [ ] 450+ 무술 생성 확인
- [ ] `get_random_martial_art()` 동작
- [ ] `save_martial_art()` JSON 저장
- [ ] `load_martial_art()` JSON 로드
- [ ] 밸런싱 함수 동작 (강력함 vs 에너지)

### Player
- [ ] `recalculate_max_hp()` 동작
- [ ] `recover_energy()` 자동 회복
- [ ] `take_damage()` 데미지 처리
- [ ] `attack(slot)` 공격 실행
- [ ] `use_martial_art(slot)` 무술 발동

### CombatSystem
- [ ] `start_combat(player, enemy)` 초기화
- [ ] `execute_turn()` 턴 진행
- [ ] `deal_damage()` 데미지 계산
- [ ] 콤보 카운트
- [ ] 전투 로그

### Enemy
- [ ] Level 1 AI (10% 회피)
- [ ] Level 2 AI (25% 회피, 패턴 학습)
- [ ] 상태 머신 (Idle → Chase → Attack)
- [ ] 리워드 시스템

---

## 📝 문서 생성 (Day 3-4)

- [ ] Day3-4_Progress.md (진행 상황)
- [ ] Day3-4_BugReport.md (버그 리스트)
- [ ] TestResult_MartialArtEngine.txt (테스트 결과)
- [ ] TestResult_PlayerCombat.txt (테스트 결과)

---

## 🔥 성공 기준

### Day 3 (오늘) 성공 기준
```
✅ 무술 엔진: 450+ 무술 생성 확인
✅ 에러: 0건
✅ Git 커밋: "Day 3: MartialArtEngine v1.0 완료"
✅ 진행도: 5% → 8%
```

### Day 4 (내일) 성공 기준
```
✅ 플레이어 전투: 10턴 시뮬레이션 완료
✅ 적 AI: Level 1-2 동작 확인
✅ 에러: 0건
✅ Git 커밋: "Day 4: Player Combat + AI Level 1-2 완료"
✅ 진행도: 8% → 12%
```

### Week 1-2 (Day 7) 성공 기준
```
✅ 무술 엔진: 완벽 동작
✅ 플레이어 전투: 기본 공격, 방어, 회피 가능
✅ 적 AI: Level 1-2 동작
✅ 중원 맵: 기초 프로토타입
✅ 첫 보스: Phase 1-2 패턴 작동
✅ 에러: 0건
✅ 진행도: 20%
```

---

## 💡 주의사항

1. **에러 0 정책**: 모든 버그는 그날 바로 수정
2. **테스트 우선**: 각 기능 구현 후 즉시 테스트
3. **문서화**: 각 단계마다 진행 상황 기록
4. **Git**: 매시간 또는 완료 단위로 커밋
5. **메모리**: 매일 memory/YYYY-MM-DD.md 업데이트

---

**Created with ⚡ by 천재**  
**2026-05-10 18:56 (Asia/Seoul)**  
**Status**: 🚀 Day 3-4 스프린트 준비 완료

