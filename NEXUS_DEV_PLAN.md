# 🔥 NEXUS 개발 진행 현황

**프로젝트:** AAA급 3D 무술 창조 게임  
**엔진:** Godot 4.2  
**목표:** Week 1-2 안에 프로토타입 완성 (20%)  
**에러 정책:** 에러 0, 완벽한 구현  

---

## 📅 일정 (2026-05-12 시작)

### Week 1: 프로젝트 초기화 & 무술 엔진

| 날짜 | Day | 목표 | 상태 |
|------|-----|------|------|
| 05-12 (화) | 1-2 | 프로젝트 초기화, 클래스 설계 | 🔄 진행중 |
| 05-13 (수) | 3-4 | 무술 생성 엔진 (Core) | ⏳ 대기 |
| 05-14 (목) | 5-6 | 플레이어 전투 시스템 | ⏳ 대기 |
| 05-15 (금) | 7 | 통합 테스트 | ⏳ 대기 |

### Week 2: AI & 첫 보스

| 날짜 | Day | 목표 | 상태 |
|------|-----|------|------|
| 05-16 (토) | 8-9 | 적 AI Level 1-2 | ⏳ 대기 |
| 05-17 (일) | 10-11 | 첫 보스 & 중원 프로토타입 | ⏳ 대기 |
| 05-18 (월) | 12-13 | 무술관 & 강화 시스템 | ⏳ 대기 |
| 05-19 (화) | 14 | 통합 테스트 & 플레이 검증 | ⏳ 대기 |

---

## 🛠️ 핵심 설계 (에러 0 원칙)

### 1. 데이터 스키마 (JSON)

#### MartialArt 구조
```json
{
  "id": "martial_001",
  "name": "기본 주먹",
  "baseMotion": 1,           // 0-99 (100가지)
  "tempo": "mid",            // fast, mid, slow
  "defensetype": "dodge",    // dodge, guard, parry, counter
  "defenseLevel": 2,         // 1-5
  "energyCost": 5,           // 1-10
  "hitbox": {
    "type": "hand",          // hand, foot, body
    "range": 2.5,            // meters
    "damage": [5, 8]         // [min, max]
  },
  "addEffect": "none",       // stun, stagger, down, burn, freeze, etc.
  "effectPower": 0,          // 0-10
  "power": 6,                // 1-10 (밸런싱)
  "learnable": true,
  "cost": 0                  // 프래그먼트 필요량
}
```

#### Player 구조
```json
{
  "id": "player_001",
  "name": "캐릭터명",
  "level": 1,
  "stats": {
    "str": 10,
    "dex": 10,
    "con": 10,
    "int": 10,
    "wis": 10,
    "cha": 10
  },
  "hp": 100,
  "energy": 100,
  "skillPoints": 0,
  "martialArts": [
    { "slot": 1, "martialId": "martial_001", "level": 1 },
    { "slot": 2, "martialId": "martial_002", "level": 1 },
    { "slot": 3, "martialId": "martial_003", "level": 1 },
    { "slot": 4, "martialId": "martial_004", "level": 1 },
    { "slot": 5, "martialId": "martial_005", "level": 1 }
  ],
  "equipment": {
    "head": null,
    "chest": null,
    "legs": null,
    "feet": null,
    "hands": null,
    "accessory": null
  },
  "experience": 0,
  "gold": 0,
  "position": { "x": 0, "y": 0, "z": 0 }
}
```

#### Enemy 구조
```json
{
  "id": "enemy_001",
  "name": "일반 늑대",
  "level": 1,
  "aiLevel": 1,           // 1-4 (동물, 기초무술사, 고급무술사, 마스터)
  "stats": {
    "str": 8,
    "dex": 9,
    "con": 8,
    "int": 3,
    "wis": 4,
    "cha": 2
  },
  "hp": 30,
  "energy": 50,
  "martialArts": ["martial_basic_bite", "martial_basic_claw"],
  "behaviorPattern": ["chase", "attack", "idle"],
  "dropTable": {
    "experience": 15,
    "gold": 5,
    "items": []
  }
}
```

### 2. 클래스 다이어그램

```
MartialArt (데이터 모델)
  ├─ id, name
  ├─ baseMotion, tempo, defenseType
  ├─ hitbox (shape, range, damage)
  ├─ addEffect, effectPower
  └─ generateCombo() → MartialArt

Character (베이스)
  ├─ stats (STR, DEX, CON, INT, WIS, CHA)
  ├─ hp, energy, level
  ├─ martialArts[] (5개 슬롯)
  └─ takeDamage(damage) → hp

Player : Character
  ├─ equipment
  ├─ skillPoints, experience, gold
  ├─ useMartialArt(slotId) → damage
  ├─ calculateDamage(martial) → float
  └─ levelUp() → void

Enemy : Character
  ├─ aiLevel (1-4)
  ├─ behaviorTree
  ├─ chooseAction() → MartialArt
  └─ dropReward() → {exp, gold, items}

CombatSystem
  ├─ player: Player
  ├─ enemies: Enemy[]
  ├─ executeAttack(attacker, defender, martial)
  ├─ calculateDamage(attacker, defender, martial) → float
  ├─ applyEffect(target, effect, power)
  └─ updateEnergy(character) → void

MartialArtGenerator
  ├─ baseMotions[] (100가지)
  ├─ generateRandom() → MartialArt
  ├─ generateBalanced() → MartialArt
  └─ saveMartialArt(martial) → void
```

---

## ✅ 완료 체크리스트 (Week 1-2)

### Day 1-2: 프로젝트 초기화
- [ ] Godot 4.2 프로젝트 생성
- [ ] 폴더 구조 (Assets, Scripts, Scenes, Data)
- [ ] Git 초기화 & .gitignore
- [ ] 클래스 설계서 (위의 다이어그램)
- [ ] 데이터 스키마 (위의 JSON)

### Day 3-4: 무술 생성 엔진
- [ ] MartialArt 클래스 구현
- [ ] 기본 동작 100가지 데이터베이스
- [ ] 무술 생성 함수 (난수, 밸런싱)
- [ ] 무술 저장/로드 시스템
- [ ] 무술 에디터 UI

### Day 5-6: 플레이어 전투 시스템
- [ ] Player 클래스
- [ ] 기본 공격 (마우스 좌클릭, 1-4 슬롯)
- [ ] 에너지 시스템
- [ ] 데미지 계산
- [ ] 입력 처리

### Day 7: 통합 테스트
- [ ] Player + MartialArt 통합
- [ ] 기본 전투 시뮬레이션
- [ ] 테스트 씬

### Day 8-9: 적 AI
- [ ] Enemy 클래스
- [ ] AI Level 1-2 (상태 머신)
- [ ] 테스트 (Player vs Enemy)

### Day 10-11: 첫 보스 & 지역
- [ ] 중원 맵 프로토타입
- [ ] 첫 던전
- [ ] 첫 보스 AI & 패턴

### Day 12-13: 무술관 & 강화
- [ ] 무술관 NPC
- [ ] 무술 강화 시스템
- [ ] 강화 UI

### Day 14: 최종 테스트
- [ ] End-to-end 플레이
- [ ] 버그 수집

---

## 🎯 다음 액션

**지금 (05-12 21:56):**
1. ✅ 로드맵 & GDD 확인
2. 🔄 이 파일 작성 (현재)
3. ⏳ 프로젝트 초기화 시작

**내일 (05-13):**
1. Godot 4.2 프로젝트 생성
2. 폴더 구조 & Git 설정
3. MartialArt 클래스 설계 & 구현

---

**목표:** 에러 0, 완벽한 AAA급 게임 🔥
