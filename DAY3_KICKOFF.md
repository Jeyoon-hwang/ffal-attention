# 🥋 DAY 3 킥오프 - 무술 엔진 & 플레이어 전투 구현

**날짜**: 2026-05-08 새벽 (01:56 AM)  
**상태**: ✅ Day 1-2 준비 완료, Day 3 시작 준비 ✅  
**진행도**: 5% → 20% (목표)

---

## 📊 현재 상황 리뷰

### 완료된 작업 (Day 1-2)
- ✅ Godot 4.6.2 프로젝트 구조 생성 (NEXUS_Dev)
- ✅ 폴더 구조 완성 (20개 폴더)
- ✅ CLASS_DESIGN.md 작성 (10개 핵심 클래스 설계)
- ✅ DATA_FORMAT.md 작성 (8가지 데이터 포맷)
- ✅ project.godot 설정 (1920x1080, 60 FPS, Forward+)

### 남은 작업 (Day 3부터)
- [ ] MartialArt.gd 구현 (무술 데이터)
- [ ] Player.gd 구현 (플레이어 전투)
- [ ] Enemy.gd 구현 (적 AI)
- [ ] MartialArtEngine.gd 구현 (무술 생성 엔진)
- [ ] CombatSystem.gd 구현 (전투 시스템)
- [ ] CombatTest.tscn 생성 (테스트 씬)

### 폴더 구조
```
NEXUS_Dev/
├── project.godot              ✅ 완성
├── .gitignore                 ✅ 완성
├── README.md                  ✅ 완성
├── Docs/
│   ├── CLASS_DESIGN.md        ✅ 완성
│   └── DATA_FORMAT.md         ✅ 완성
├── Assets/                    📁 (모델링 나중)
├── Scripts/
│   ├── Core/                  📁 (GameManager 등)
│   ├── Combat/                📁 (Player, Enemy, CombatSystem)
│   ├── Martial/               📁 (MartialArt, MartialArtEngine)
│   ├── AI/                    📁 (AIController - 나중)
│   ├── World/                 📁 (MapManager - 나중)
│   └── UI/                    📁 (UIManager - 나중)
├── Scenes/
│   ├── Test/
│   │   └── CombatTest.tscn    📋 (Day 3에서 생성)
│   ├── Levels/                📁 (나중)
│   ├── Dungeons/              📁 (나중)
│   └── UI/                    📁 (나중)
├── Data/
│   ├── MartialArts/           📁 (무술 데이터)
│   ├── NPCs/                  📁 (NPC 데이터)
│   ├── Quests/                📁 (퀘스트 데이터)
│   └── Zones/                 📁 (지역 데이터)
└── Scenes/                    📁 (Godot 씬)
```

---

## 🎯 Day 3 목표 (지금 시작!)

**시간 예상**: 5-6시간  
**산출물**: 5개 핵심 클래스 + 테스트 씬 → 게임 플레이 가능!

### Task 1: MartialArt.gd (무술 데이터 클래스)
**파일 경로**: `Scripts/Martial/MartialArt.gd`  
**예상 시간**: 30분  
**목표**: 무술 기본 데이터 구조 정의

```gdscript
# MartialArt.gd - 무술 데이터 클래스
class_name MartialArt

var id: String                  # "kick_01", "punch_05" 등
var name: String                # "회전 발차기"
var description: String         # 설명
var base_damage: int            # 기본 데미지 (1-50)
var energy_cost: int            # 에너지 소비 (1-10)
var speed: String               # "fast", "mid", "slow"
var defense_type: String        # "dodge", "guard", "counter"
var effects: Array[String]      # ["stun", "slow", "knockback"]
var power_level: int            # 1-10 (강력함)
var rarity: String              # "common", "rare", "epic", "legend"

func _init(p_id: String = "", p_name: String = "", p_damage: int = 5):
    id = p_id
    name = p_name
    base_damage = p_damage
    energy_cost = 2
    speed = "mid"
    defense_type = "dodge"
    effects = []
    power_level = 1
    rarity = "common"

func calculate_damage(str_bonus: int, dex_bonus: int) -> int:
    return base_damage + (str_bonus / 4) + (dex_bonus / 6)

func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": name,
        "base_damage": base_damage,
        "energy_cost": energy_cost,
        "speed": speed
    }
```

**체크리스트**:
- [ ] 파일 생성
- [ ] 모든 변수 정의
- [ ] 메서드 구현 (calculate_damage, to_dict, from_dict)
- [ ] 저장/로드 함수
- [ ] 컴파일 성공

---

### Task 2: Player.gd (플레이어 전투 클래스)
**파일 경로**: `Scripts/Combat/Player.gd`  
**예상 시간**: 1시간  
**목표**: 플레이어 스탯, 무술 슬롯, 입력 처리

```gdscript
# Player.gd - 플레이어 캐릭터
extends CharacterBody3D
class_name Player

# 기본 스탯
var str_stat: int = 10       # 힘 (데미지)
var dex_stat: int = 10       # 민첩 (치명타, 회피)
var con_stat: int = 10       # 체질 (체력)
var int_stat: int = 10       # 지능 (마력)
var wis_stat: int = 10       # 지혜 (감지)
var cha_stat: int = 10       # 매력 (NPC 상호작용)

# 생명 값
var max_hp: int = 100
var current_hp: int = 100
var max_energy: int = 100
var current_energy: int = 100

# 무술 슬롯 (5개)
var martial_arts: Array[MartialArt] = [null, null, null, null, null]
var current_martial_index: int = 0

# 전투 상태
var level: int = 1
var experience: int = 0
var combo_count: int = 0
var is_attacking: bool = false
var is_defending: bool = false

func _ready():
    # 테스트용 초기 무술 설정
    martial_arts[0] = MartialArt("punch_01", "기본 펀치", 10)
    martial_arts[1] = MartialArt("kick_01", "기본 발차기", 15)

func _input(event: InputEvent):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_1:
            use_martial_art(0)
        elif event.keycode == KEY_2:
            use_martial_art(1)
        # 등등...

func use_martial_art(index: int) -> bool:
    if index < 0 or index >= martial_arts.size():
        return false
    
    var ma = martial_arts[index]
    if ma == null:
        return false
    
    if current_energy < ma.energy_cost:
        return false
    
    current_energy -= ma.energy_cost
    current_martial_index = index
    is_attacking = true
    return true

func take_damage(damage: int):
    current_hp = max(0, current_hp - damage)
```

**체크리스트**:
- [ ] 파일 생성
- [ ] 스탯 시스템
- [ ] 에너지 시스템
- [ ] 무술 슬롯 (5개)
- [ ] 입력 처리 (1-5 키)
- [ ] 데미지 계산
- [ ] 컴파일 성공

---

### Task 3: Enemy.gd (적 AI 클래스)
**파일 경로**: `Scripts/Combat/Enemy.gd`  
**예상 시간**: 1시간  
**목표**: 적 기본 AI, 상태 머신

```gdscript
# Enemy.gd - 적 캐릭터
extends CharacterBody3D
class_name Enemy

var ai_level: int = 1       # 1-4 (동물형 ~ 마스터)
var hp: int = 50
var max_hp: int = 50
var martial_arts: Array[MartialArt] = []
var state: String = "idle"  # idle, chase, attack, flee

var target: Player = null
var detection_range: float = 20.0
var attack_range: float = 5.0

func _ready():
    # 테스트용 기본 무술
    martial_arts.append(MartialArt("punch_01", "펀치", 8))

func _process(delta: float):
    match state:
        "idle":
            check_for_player()
        "chase":
            chase_player(delta)
        "attack":
            attack_player(delta)
        "flee":
            flee_from_player(delta)

func check_for_player():
    # 플레이어 감지 (거리 기반)
    if target == null:
        return
    
    var distance = global_position.distance_to(target.global_position)
    if distance < detection_range:
        state = "chase"

func chase_player(delta: float):
    if target == null:
        state = "idle"
        return
    
    var distance = global_position.distance_to(target.global_position)
    if distance < attack_range:
        state = "attack"
    else:
        # 플레이어 쪽으로 이동
        var direction = (target.global_position - global_position).normalized()
        velocity = direction * 5.0

func attack_player(delta: float):
    if target == null:
        state = "idle"
        return
    
    # 간단한 공격 (매 1초마다)
    if randf() > 0.95:  # 5% 확률로 공격
        var ma = martial_arts[0]
        var damage = ma.calculate_damage(10, 5)
        target.take_damage(damage)

func take_damage(damage: int):
    hp = max(0, hp - damage)
    if hp <= 0:
        die()

func die():
    print("적이 죽었다!")
    queue_free()
```

**체크리스트**:
- [ ] 파일 생성
- [ ] AI 상태 머신
- [ ] 플레이어 감지
- [ ] 추격 로직
- [ ] 공격 로직
- [ ] 컴파일 성공

---

### Task 4: MartialArtEngine.gd (무술 생성 엔진)
**파일 경로**: `Scripts/Martial/MartialArtEngine.gd`  
**예상 시간**: 1시간  
**목표**: 무술 생성, 저장/로드, 데이터 관리

```gdscript
# MartialArtEngine.gd - 무술 생성 및 관리 엔진
extends Node
class_name MartialArtEngine

# 기본 동작 목록 (100가지)
var base_motions: Array[String] = [
    "punch_01", "punch_02", "kick_01", "kick_02", "spin_kick",
    "palm_strike", "elbow_strike", "knee_strike", "sweep", "throw"
    # 등등... 100가지까지 확장
]

# 리듬 (3가지)
var tempos: Array[String] = ["fast", "mid", "slow"]

# 방어 타입 (4가지)
var defense_types: Array[String] = ["dodge", "guard", "counter", "parry"]

# 효과 (20가지)
var effects: Array[String] = [
    "stun", "slow", "knockback", "bleed", "burn",
    "freeze", "poison", "confusion", "silence", "weakness",
    "vulnerable", "armor_break", "crit_up", "def_down", "seal",
    "bind", "fear", "charm", "sleep", "invincible"
]

func _ready():
    load_martial_arts()

func generate_martial_art(difficulty: int = 1) -> MartialArt:
    var base = base_motions[randi() % base_motions.size()]
    var tempo = tempos[randi() % tempos.size()]
    var defense = defense_types[randi() % defense_types.size()]
    
    var ma = MartialArt(
        "ma_" + str(randi()),
        "자동 생성 무술 " + base,
        5 + difficulty * 3
    )
    ma.speed = tempo
    ma.defense_type = defense
    
    # 랜덤 효과 추가
    if randf() > 0.5:
        ma.effects.append(effects[randi() % effects.size()])
    
    return ma

func load_martial_arts() -> Array[MartialArt]:
    # JSON에서 무술 로드 (나중 구현)
    return []

func save_martial_art(ma: MartialArt):
    # JSON으로 무술 저장 (나중 구현)
    pass

func get_all_martial_arts() -> Array[MartialArt]:
    # 모든 무술 반환 (나중 구현)
    return []
```

**체크리스트**:
- [ ] 파일 생성
- [ ] 기본 동작 목록 (최소 50개)
- [ ] 무술 생성 함수
- [ ] 저장/로드 함수 기초
- [ ] 컴파일 성공

---

### Task 5: CombatSystem.gd (전투 시스템)
**파일 경로**: `Scripts/Combat/CombatSystem.gd`  
**예상 시간**: 45분  
**목표**: 전투 로직, 데미지 계산, 효과 적용

```gdscript
# CombatSystem.gd - 전투 시스템
extends Node
class_name CombatSystem

func calculate_damage(attacker: CharacterBody3D, martial_art: MartialArt, defender: CharacterBody3D) -> int:
    var base_damage = martial_art.base_damage
    
    # 공격자 스탯 보너스
    var str_bonus = 0
    if attacker is Player:
        str_bonus = attacker.str_stat / 4
    
    # 방어자 저항 (나중 구현)
    var defense_reduction = 0
    
    var final_damage = base_damage + str_bonus - defense_reduction
    
    # 치명타 (DEX 기반)
    if attacker is Player and randf() < (attacker.dex_stat / 100.0):
        final_damage *= 2
    
    return max(1, final_damage)

func execute_attack(attacker: CharacterBody3D, martial_art: MartialArt, defender: CharacterBody3D) -> bool:
    if martial_art == null:
        return false
    
    var damage = calculate_damage(attacker, martial_art, defender)
    defender.take_damage(damage)
    
    # 효과 적용
    apply_effects(martial_art, defender)
    
    print_debug("%s이(가) %s를 사용! 데미지: %d" % [attacker.name, martial_art.name, damage])
    return true

func apply_effects(martial_art: MartialArt, target: CharacterBody3D):
    # 효과 적용 (나중 구현)
    for effect in martial_art.effects:
        print_debug("효과 적용: %s" % effect)
```

**체크리스트**:
- [ ] 파일 생성
- [ ] 데미지 계산 함수
- [ ] 공격 실행 함수
- [ ] 효과 적용 함수
- [ ] 컴파일 성공

---

### Task 6: CombatTest.tscn (테스트 씬)
**파일 경로**: `Scenes/Test/CombatTest.tscn`  
**예상 시간**: 1시간  
**목표**: 플레이어 vs 적 테스트, 기본 UI

**씬 구조**:
```
CombatTest (Node3D)
├── WorldEnvironment
│   └── DirectionalLight3D
├── Player (CharacterBody3D)
│   └── CollisionShape3D
├── Enemy (CharacterBody3D)
│   └── CollisionShape3D
├── CombatSystem (Node)
├── CanvasLayer (UI)
│   ├── PlayerHPLabel (Label)
│   ├── EnemyHPLabel (Label)
│   └── ActionLog (TextEdit)
└── GameController (Node)
```

**테스트 항목**:
- [ ] 게임 실행 가능
- [ ] 플레이어 이동 (WASD)
- [ ] 플레이어 공격 (1-5 키)
- [ ] 적 AI 동작 (추격, 공격)
- [ ] 데미지 표시
- [ ] HP 감소
- [ ] 사망 판정

---

### Task 7: 초기 테스트 & 커밋
**예상 시간**: 30분

```bash
cd ~/.openclaw/workspace/NEXUS_Dev

# Git 초기화 (아직 안 됐으면)
git init
git add .
git commit -m "Day 3: Core classes implementation (MartialArt, Player, Enemy, CombatSystem, MartialArtEngine)"

# 테스트 실행
godot --path . Scenes/Test/CombatTest.tscn

# 기본 게임플레이 확인
# - 플레이어 이동 (WASD)
# - 공격 (1-5 키)
# - 적 AI 추격 & 공격
# - HP 변화
```

---

## 🎯 Day 3 완료 체크리스트

### 코드 작성
- [ ] MartialArt.gd (완성)
- [ ] Player.gd (완성)
- [ ] Enemy.gd (완성)
- [ ] MartialArtEngine.gd (완성)
- [ ] CombatSystem.gd (완성)

### 씬 구성
- [ ] CombatTest.tscn (완성)
- [ ] 플레이어 노드 추가
- [ ] 적 노드 추가
- [ ] UI 레이아웃

### 테스트
- [ ] 게임 실행 가능
- [ ] 입력 응답 (WASD, 1-5 키)
- [ ] 전투 로직 동작
- [ ] AI 추격 & 공격 동작
- [ ] 데미지 계산 정상

### Git
- [ ] 모든 파일 커밋
- [ ] 커밋 메시지 명확

---

## 📈 진행도 기대치

**Day 3 시작 전**: 5% (구조만 생성)  
**Day 3 완료 시**: 20% (기초 게임플레이 가능)

```
Week 1-2 진행도:
[████████----] 20%
  ├─ 무술 엔진      [████------] 50% (기초)
  ├─ 플레이어 전투  [████------] 50% (기초)
  ├─ 적 AI          [███-------] 30% (Level 1-2)
  ├─ 첫 보스        [----------] 0%
  └─ 콘텐츠 & 맵    [----------] 0%
```

---

## 🔥 황제영, 지금 이 순간 해야 할 일

### 즉시 (오늘)
1. **터미널 열기**
   ```bash
   cd ~/.openclaw/workspace/NEXUS_Dev
   godot
   ```

2. **각 Task 순서대로 구현**
   - Task 1: MartialArt.gd
   - Task 2: Player.gd
   - Task 3: Enemy.gd
   - Task 4: MartialArtEngine.gd
   - Task 5: CombatSystem.gd
   - Task 6: CombatTest.tscn
   - Task 7: 테스트

3. **편하게 진행**
   - 각 파일은 독립적
   - 에러 나면 수정하고 진행
   - 매 파일마다 저장 & 커밋

---

## 💡 팁

### Godot 단축키
- **Ctrl+S**: 저장
- **Ctrl+Shift+B**: 빌드
- **F5**: 플레이
- **F6**: 현재 씬 플레이

### GDScript 유의사항
- 클래스 이름은 PascalCase (`class_name Player`)
- 함수/변수는 snake_case (`func _ready()`, `var max_hp`)
- 타입 힌팅 필수 (`var hp: int = 100`)

### 커밋 메시지
```
Day 3: Core classes implementation
- MartialArt.gd: 무술 데이터
- Player.gd: 플레이어 전투
- Enemy.gd: 적 AI (Level 1-2)
- CombatSystem.gd: 전투 로직
- CombatTest.tscn: 테스트 씬
```

---

## ⏰ 예상 일정

| Task | 시간 | 상태 |
|------|------|------|
| 1. MartialArt.gd | 30분 | 📋 준비됨 |
| 2. Player.gd | 1시간 | 📋 준비됨 |
| 3. Enemy.gd | 1시간 | 📋 준비됨 |
| 4. MartialArtEngine.gd | 1시간 | 📋 준비됨 |
| 5. CombatSystem.gd | 45분 | 📋 준비됨 |
| 6. CombatTest.tscn | 1시간 | 📋 준비됨 |
| 7. 테스트 & 커밋 | 30분 | 📋 준비됨 |
| **합계** | **6시간** | 🚀 **시작 준비!** |

---

## 🎮 Day 3 이후 (Week 1 후반)

### Day 4-5: 고급 무술 & 플레이어 심화
- 무술 100+ 기본 데이터베이스 구축
- 플레이어 콤보 시스템
- 무술 강화 (레벨업 시스템)

### Day 6-7: 적 AI & 첫 보스
- 적 AI Level 3-4 구현 (고급 무술사, 마스터)
- 첫 보스 패턴 설계
- 다중 페이즈 보스 시스템

---

## 🚀 최종 목표 (Week 12)

**2026-07-29 완성 예정:**
- ✅ 에러 0
- ✅ AAA급 그래픽 & 폴리시
- ✅ 3-5개 지역, 50-70개 던전
- ✅ 100+ NPC, 200+ 퀘스트
- ✅ 수백만 무술 조합
- ✅ 30-50시간 플레이타임

---

**Version**: 1.0  
**Status**: 🚀 **Day 3 시작 준비 완료!**  
**다음 단계**: MartialArt.gd 구현 시작

_작성자: 천재 ⚡_  
_작성 시간: 2026-05-08 01:56 AM (새벽)_
