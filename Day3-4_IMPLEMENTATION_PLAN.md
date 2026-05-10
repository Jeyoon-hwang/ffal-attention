# Day 3-4 구현 계획 (무술 엔진 & 플레이어 전투)

**상태**: 분석 완료, 수정 준비  
**목표**: Week 1-2 Day 3-4 마일스톤 달성 (0% → 20%)  
**에러**: 0건 유지  

---

## 📊 현재 코드 상태 분석

### ✅ 이미 구현된 것
1. **MartialArtEngine.gd** (기본 구조 있음)
   - 기본 동작 100개
   - 기본 무술 10개 (펀치, 킥, 방어, 회피)
   - 랜덤 무술 생성 함수 (`generate_random_martial()`)
   - 저장/로드 시스템

2. **Player.gd** (기본 구조 있음)
   - 6개 능력치
   - HP/에너지 시스템
   - 무술 슬롯 (5개)
   - 무술 발동 (`execute_martial_art()`)
   - 레벨업 시스템

3. **CombatSystem.gd** (기본 구조 있음)
   - 턴 기반 전투
   - 데미지 계산
   - 전투 로그

4. **Enemy.gd** (기본 구조 있음)
   - AI 난이도 1-4
   - 상태 머신

### ❌ 문제점 & 수정 필요

#### 문제 1: 무술이 충분하지 않음
**원인**: `_load_martial_database()`가 기본 10가지만 생성
**해결**: 
- [ ] 450+ 무술 자동 생성 함수 추가
- [ ] `initialize_combat_martial_arts()` 함수 생성
- [ ] 매 시작 시 자동으로 생성

**코드 (MartialArtEngine.gd에 추가)**:
```gdscript
func initialize_combat_martial_arts() -> void:
	"""게임 시작 시 450+ 무술 자동 생성"""
	if martial_arts_db.size() > 100:
		return  # 이미 생성됨
	
	print("[MartialArtEngine] 450+ 무술 생성 중...")
	for i in range(450):
		var martial = generate_random_martial()
		if martial:
			martial_arts_db[martial.martial_id] = martial
	
	print(f"[MartialArtEngine] 생성 완료: {martial_arts_db.size()}개 무술")
```

#### 문제 2: Player가 무술을 장착하지 않음
**원인**: `execute_martial_art()`가 호출되기 전에 슬롯이 비어있음
**해결**:
- [ ] Player 초기화 시 기본 무술 3개 자동 장착
- [ ] `load_starting_martial_arts()` 함수 추가

**코드 (Player.gd의 `_ready()` 함수에 추가)**:
```gdscript
func _ready() -> void:
	# ... 기존 코드 ...
	load_starting_martial_arts()

func load_starting_martial_arts() -> void:
	"""게임 시작 시 기본 무술 3개 자동 장착"""
	var engine = MartialArtEngine.new()
	engine._ready()
	engine.initialize_combat_martial_arts()
	
	# 기본 3개 무술 가져오기
	var martial_ids = ["basic_punch", "kick", "guard"]
	for slot in range(martial_ids.size()):
		if engine.martial_arts_db.has(martial_ids[slot]):
			martial_slots[slot] = engine.martial_arts_db[martial_ids[slot]]
```

#### 문제 3: MartialArt 클래스 데이터 타입 불일치
**확인 필요**:
- [ ] `MartialArt.gd` 클래스의 필드 정의 확인
- [ ] `id` vs `martial_id` 속성 통일
- [ ] `effects` 배열 타입 확인

#### 문제 4: Enemy의 데미지 계산 부족
**해결**:
- [ ] Enemy에 `calculate_attack_damage()` 함수 추가
- [ ] AI 난이도별 데미지 계산

**코드 (Enemy.gd에 추가)**:
```gdscript
func calculate_attack_damage() -> float:
	"""AI 난이도별 공격 데미지 계산"""
	var base_damage = 5.0 + float(ai_level) * 5.0
	var variance = randf_range(0.8, 1.2)
	return base_damage * variance
```

---

## 🎯 Day 3 작업 순서 (3-4시간)

### Task 1: 코드 정리 & 분석 (30분)
- [ ] MartialArt.gd 완전 읽기 (속성 확인)
- [ ] Enemy.gd 완전 읽기
- [ ] 모든 클래스 상속 관계 확인

### Task 2: MartialArtEngine 강화 (1시간)
- [ ] `initialize_combat_martial_arts()` 함수 추가
- [ ] 테스트 실행 (450+ 무술 생성 확인)
- [ ] JSON 저장/로드 테스트

**파일**: MartialArtEngine.gd (180줄 추가)

### Task 3: Player 강화 (1시간)
- [ ] `load_starting_martial_arts()` 함수 추가
- [ ] MartialArtEngine과 통합
- [ ] `execute_martial_art()` 테스트

**파일**: Player.gd (100줄 추가)

### Task 4: Enemy 강화 (30분)
- [ ] `calculate_attack_damage()` 함수 추가
- [ ] AI 난이도별 행동 다양화
- [ ] 데미지 계산 검증

**파일**: Enemy.gd (50줄 추가)

### Task 5: 통합 테스트 (1시간)
- [ ] Day3_QuickTest.gd 실행
- [ ] 버그 리포트 작성
- [ ] 수정 사항 적용

### Task 6: Git 커밋 (30분)
- [ ] `git add -A`
- [ ] `git commit -m "Day 3: MartialArtEngine & Player 강화"`
- [ ] memory/2026-05-10.md 업데이트

**예상 소요시간**: 3.5시간
**예상 완성도**: 5% → 8%

---

## 🎯 Day 4 작업 순서 (4-5시간)

### Task 1: 적 AI Level 1-2 검증 (1시간)
- [ ] Enemy AI 동작 확인
- [ ] 난이도별 회피율 테스트
- [ ] 패턴 학습 시스템 검증

### Task 2: CombatSystem 강화 (1시간)
- [ ] `execute_enemy_turn()` 함수 확인
- [ ] 콤보 시스템 검증
- [ ] 상태 이상 시스템 테스트

### Task 3: 중원 맵 기초 (1.5시간)
- [ ] CenterZone.tscn 프로토타입
- [ ] 기초 지형 & 조명
- [ ] 플레이어 스폰 지점

### Task 4: 첫 던전 기초 (1시간)
- [ ] FirstDungeon.tscn 프로토타입
- [ ] 몬스터 2-3마리 배치
- [ ] 보스 방 준비

### Task 5: 통합 테스트 & 디버그 (1시간)
- [ ] 전체 게임 플로우 테스트
- [ ] 버그 수정
- [ ] 성능 체크

**예상 소요시간**: 5시간
**예상 완성도**: 8% → 12%

---

## 📝 생성할 파일 (Day 3-4)

### 코드 파일 (수정)
- [ ] MartialArtEngine.gd (+180줄)
- [ ] Player.gd (+100줄)
- [ ] Enemy.gd (+50줄)
- [ ] CombatSystem.gd (+50줄)

### 테스트 파일
- [ ] Day3_QuickTest.gd (이미 생성)
- [ ] Day4_FullCombatTest.gd (Day 4)

### 문서
- [ ] Day3-4_ProgressReport.md
- [ ] Day3-4_BugReport.md
- [ ] Test_Results.txt

---

## ✅ 성공 기준

### Day 3 성공
```
✅ 450+ 무술 생성 확인
✅ Player 무술 슬롯 자동 장착
✅ 기본 전투 시뮬레이션 동작
✅ 에러: 0건
✅ Git 커밋 완료
✅ 진행도: 5% → 8%
```

### Day 4 성공
```
✅ 적 AI Level 1-2 검증
✅ 중원 맵 프로토타입
✅ 첫 던전 기초
✅ 10턴 전투 시뮬레이션 완료
✅ 에러: 0건
✅ Git 커밋 완료
✅ 진행도: 8% → 12%
```

### Week 1-2 (Day 7) 성공
```
✅ 무술 엔진: 완벽 동작 (450+개)
✅ 플레이어 전투: 기본 공격/방어/회피
✅ 적 AI: Level 1-2 동작
✅ 중원 맵: 기초 플레이 가능
✅ 첫 보스: 3-Phase 패턴 작동
✅ 에러: 0건
✅ 진행도: 20%
```

---

## 🔥 중요 체크포인트

1. **에러 0 정책**: 모든 버그는 그날 수정
2. **테스트 우선**: 각 기능 추가 후 즉시 테스트
3. **성능**: 60 FPS 유지 확인
4. **메모리**: 누수 없음 확인
5. **Git**: 매 기능마다 커밋

---

**Created by 천재** ⚡  
**2026-05-10 19:30 (Asia/Seoul)**
