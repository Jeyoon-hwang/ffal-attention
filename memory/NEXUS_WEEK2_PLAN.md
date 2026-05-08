# NEXUS Week 2 계획 (Day 5-14)

**목표**: 20% → 35% 진행도  
**타임라인**: 2026-05-08 (새벽) ~ 2026-05-14  
**핵심**: 플레이어 전투 고도화 + 보스 AI + 콘텐츠 폭발

---

## 🎯 주요 마일스톤

### Week 1 (완료) ✅
```
Day 1-2: 프로젝트 초기화 & 기초 클래스
Day 3: 450개 무술 생성 + 테스트 스위트
Day 4: 200개 무술 확장 + 보스 데이터 + 던전 매니저
```

### Week 2 (예정)
```
Day 5-6: 플레이어 전투 고도화 (콤보, 에너지 회복)
Day 7-8: 보스 AI 완성 (3-4단계)
Day 9-10: 첫 던전 완전 구현 (씬 & 인터페이스)
Day 11-12: 지역 프로토타입 (중원 맵 기본)
Day 13-14: 통합 테스트 & 플레이 가능 데모
```

---

## 📋 Day 5-6: 플레이어 전투 고도화 (2시간)

### 목표
- ✅ 콤보 시스템 검증
- ✅ 에너지 회복 로직 확인
- ✅ 방어/회피 완성
- ✅ 기본 애니메이션 틀 (BoxModel)

### Todo
- [ ] Player.gd 콤보 카운트 정확도 테스트
- [ ] 에너지 회복율 조정 (초당 5 → 10?)
- [ ] 크리티컬 확률 밸런싱 (5% → 10%?)
- [ ] 무술 슬롯 UI 프로토타입 (숫자 키 1-5)
- [ ] 회피/방어 애니메이션 플레이홀더

### 코드
```gdscript
# Player.gd 콤보 시스템 검증
var combo_timer: float = 0.0  # 콤보 유지 시간
var combo_count: int = 0       # 누적 콤보
const COMBO_MAX_TIME: float = 2.0  # 2초 이내

func _process(delta):
    # 콤보 타이머 감소
    if combo_timer > 0:
        combo_timer -= delta
    else:
        combo_count = 0  # 콤보 리셋

func perform_combo_attack():
    combo_count += 1
    combo_timer = COMBO_MAX_TIME
    var bonus_damage = combo_count * 5
    return base_damage + bonus_damage
```

### 결과
- 콤보 시스템 확인 ✅
- 공격 피드백 구현 (콤보 카운트 표시)
- 에너지 관리 정확화

---

## 📋 Day 7-8: 보스 AI 완성 (3시간)

### 목표
- ✅ 보스 AI Level 3-4 완성
- ✅ Phase별 패턴 변화
- ✅ 약점/내성 시스템
- ✅ 보스 전투 테스트

### Todo
- [ ] BossAI.gd 작성 (Enemy.gd 상속)
- [ ] Phase 1: Aggressive (공격 빈도 60%)
- [ ] Phase 2: Enraged (공격 빈도 80%, 체력 66% 이하)
- [ ] Phase 3: Desperate (공격 빈도 100%, 체력 33% 이하)
- [ ] 원소 약점 시스템 (저항 × 배율)
- [ ] BossCombatTest.gd (보스 전투 시뮬레이션)

### 코드 골격
```gdscript
class_name BossAI
extends Enemy

var current_phase: int = 1
var phase_thresholds = [250, 166, 83]  # HP 기준점

func take_damage(damage):
    super.take_damage(damage)
    update_phase()

func update_phase():
    if current_hp > 166:
        current_phase = 1
    elif current_hp > 83:
        current_phase = 2
    else:
        current_phase = 3

func decide_action():
    match current_phase:
        1: return aggressive_pattern()
        2: return enraged_pattern()
        3: return desperate_pattern()
```

### 결과
- 보스 3단계 전투 가능 ✅
- 난이도 조정 가능 (Phase별)
- 원소 약점 시스템 작동 ✅

---

## 📋 Day 9-10: 첫 던전 완전 구현 (4시간)

### 목표
- ✅ DungeonLevel1.tscn 완성
- ✅ 몬스터 방 구현
- ✅ 보스 방 구현
- ✅ 플레이어 스폰 & 진행

### 구조
```
DungeonLevel1.tscn
├─ Entrance (플레이어 스폰)
├─ MonsterRoom1 (적 3마리)
├─ MonsterRoom2 (적 2마리)
├─ BossRoom (보스 1마리)
└─ DungeonManager (씬 제어)
```

### 씬 구성 (Godot 3D)
```
Node3D (DungeonLevel1)
├─ Player (CharacterBody3D, 스폰 위치)
├─ Enemies (Node3D, 몬스터들)
│  ├─ Enemy1 (레벨 1)
│  ├─ Enemy2 (레벨 1)
│  ├─ Enemy3 (레벨 2)
│  ├─ Enemy4 (레벨 2)
│  └─ Enemy5 (레벨 2)
├─ BossRoom (Node3D)
│  ├─ Boss (BossAI, 늑대왕)
│  └─ Arena (Ground, Wall 박스)
├─ Environment
│  ├─ Ground (CSGBox3D or MeshInstance3D)
│  ├─ Camera3D
│  └─ DirectionalLight3D
└─ UI
   ├─ HUD (HP, Energy, 몬스터 카운트)
   └─ DungeonUI (나가기 버튼)
```

### Todo
- [ ] DungeonLevel1.tscn 생성
- [ ] Player 스폰 위치 설정
- [ ] Enemies 노드 3D 위치 설정
- [ ] BossRoom 보스 스폰
- [ ] 던전 클리어 조건 설정
- [ ] 카메라 설정 (추적 카메라 또는 고정)
- [ ] 조명 설정

### 결과
- 첫 던전 플레이 가능 ✅
- 몬스터 몇 마리 → 보스 진행 가능
- 던전 클리어 조건 작동 ✅

---

## 📋 Day 11-12: 지역 프로토타입 (3시간)

### 목표
- ✅ 중원 기본 맵 (500m × 500m)
- ✅ 무술관 NPC 위치
- ✅ 던전 입구 마크
- ✅ 시작 도시 분위기

### 구조
```
중원 맵:
- [무술관] - 무술 강화 & NPC 상호작용
- [평원] - 잡몹 스폰 (경험치 파밍)
- [던전1 입구] - DungeonLevel1 입장
- [마을] - 쉼터, NPC, 상점
- [산] - 높은 곳, 경치
```

### 요소
- [ ] WorldLevel1.tscn (지역 맵)
- [ ] MartialArtSchool.tscn (NPC 상호작용)
- [ ] DungeonEntrance.tscn (던전 진입 포인트)
- [ ] RegionManager.gd (지역 관리)

### 결과
- 자유 탐색 가능 지역 ✅
- 던전 진입 가능 ✅
- NPC 상호작용 프로토타입 ✅

---

## 📋 Day 13-14: 통합 테스트 & 데모 (4시간)

### 목표
- ✅ End-to-end 테스트 (생성 → 전투 → 던전 → 클리어)
- ✅ 프로토타입 플레이 (30분)
- ✅ 밸런싱 노트 작성
- ✅ 버그 리스트 수집

### 테스트 시나리오
```
1. 게임 시작 → 플레이어 생성
   ✅ 기본 무술 5개 장착
   ✅ HP/에너지 초기화

2. 전투 테스트 (더미)
   ✅ 기본 공격 × 3
   ✅ 콤보 카운트 확인
   ✅ 방어/회피 작동

3. 던전 입장
   ✅ 몬스터 1방 입장
   ✅ 3마리 적 전투
   ✅ 승리 & 보상

4. 보스 전투
   ✅ 보스 HP 250
   ✅ 3단계 페이즈 변화
   ✅ 클리어 & 보상

5. 지역 탐색
   ✅ 맵 이동
   ✅ NPC 상호작용
   ✅ 무술 강화
```

### 플레이 체크리스트
- [ ] 전투가 너무 쉬운가? (밸런스 확인)
- [ ] 에너지 회복이 적절한가?
- [ ] 보스 3단계 체감이 명확한가?
- [ ] UI 정보가 충분한가?
- [ ] 크래시/버그 없나?

### 산출물
- NEXUS_PLAY_NOTES.md (플레이 느낌, 밸런싱 피드백)
- BUG_REPORT.md (발견된 오류들)
- BALANCE_NOTES.md (능력치 조정 필요 항목)

---

## 📊 Week 2 진행도 목표

```
Day 5-6:   플레이어 전투        [██--------] 20% → 23%
Day 7-8:   보스 AI             [██--------] 23% → 26%
Day 9-10:  첫 던전 씬          [██--------] 26% → 30%
Day 11-12: 지역 프로토타입     [██--------] 30% → 34%
Day 13-14: 통합 테스트         [██--------] 34% → 35%

최종:     Week 2 완료          [███-------] 35% ✅
```

---

## 🔧 기술 결정

- **씬 구성**: Node3D + CharacterBody3D (3D 지향)
- **UI**: CanvasLayer + Control 노드들
- **데이터**: JSON (user://로 저장)
- **AI**: 상태 머신 기반
- **애니메이션**: 플레이홀더 박스 모델 (Week 3에서 작업)

---

## ⚠️ 위험 요소

- **헤드리스 제약**: GUI 에디터 없이 씬 구성 어려움
  - 해결: tscn 파일 수동 작성 또는 GDScript로 씬 구성
- **시간 압박**: 14일 내 35% 달성 필요
  - 대응: 병렬 작업, 최소 기능만 구현
- **그래픽 미흡**: 아직 박스 모델
  - 수용: Week 3-4에서 개선하기로

---

## 🎯 Week 2 성공 지표

```
✅ 플레이 가능한 데모 (30분 플레이)
✅ 전투 → 던전 → 보스 → 클리어 전체 루프
✅ 보스 3단계 전투 체감
✅ 기본 밸런싱 완료
✅ 100개 버그 미만
```

---

**Next**: Day 5 시작 (플레이어 전투 고도화)
