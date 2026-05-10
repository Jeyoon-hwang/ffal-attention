# 🏗️ NEXUS v2 아키텍처 설계

**Status:** Week 1 Day 1 설계  
**Purpose:** 핵심 클래스 및 시스템 정의  
**Engine:** Godot 4.2 (GDScript)

---

## 📐 핵심 클래스 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│                      GameManager (싱글톤)                        │
│  - 게임 상태 관리                                                │
│  - 시나리오, 캐릭터, 전투 통제                                  │
└─────────────────────────────────────────────────────────────────┘
         ↓                    ↓                    ↓
    ┌─────────┐         ┌─────────┐         ┌─────────┐
    │ Player  │         │ Enemy   │         │ CombatSys
    │ (캐릭터)│         │ (적)    │         │ (전투)
    └─────────┘         └─────────┘         └─────────┘
         ↓                    ↓                    ↓
    ┌─────────────────────────────────────────────────────┐
    │              Character (베이스 클래스)               │
    │  - stats: STR, DEX, CON, INT, WIS, CHA             │
    │  - hp, energy, level, exp                           │
    │  - martial_arts[]: MartialArt (5개 슬롯)            │
    │  - inventory, equipment                             │
    └─────────────────────────────────────────────────────┘
         ↓
    ┌─────────────────────────────────────────────────────┐
    │           MartialArt (무술 핵심 시스템)             │
    │  - base_motion: int (0-99, 100가지)                │
    │  - tempo: enum (Fast, Mid, Slow)                    │
    │  - defense_type: enum (회피, 가드, 상쇄, 카운터)   │
    │  - defense_level: int (1-5)                         │
    │  - energy_cost: int (1-10)                          │
    │  - damage: int (1-50)                               │
    │  - effect: enum (none, stun, freeze, burn, etc)     │
    │  - hitbox: Rect2 (판정 범위)                        │
    └─────────────────────────────────────────────────────┘
         ↓
    ┌─────────────────────────────────────────────────────┐
    │            AIController (적 AI 상태 머신)           │
    │  - state: enum (Idle, Chase, Attack, Flee)          │
    │  - target: Character                                │
    │  - decision_timer: float                            │
    │  - ai_level: int (1-4)                              │
    │  - behavior_tree: Leaf[]                            │
    └─────────────────────────────────────────────────────┘
```

---

## 🎯 핵심 클래스 상세

### 1. **Character (기본 클래스)**

**파일:** `Scripts/Core/Character.gd`

```gdscript
class_name Character
extends Node3D

# 스탯
var stats = {
    "STR": 10,    # 공격력
    "DEX": 10,    # 회피, 크리티컬
    "CON": 10,    # 체력
    "INT": 10,    # 스킬 파워
    "WIS": 10,    # 지혜, 회복
    "CHA": 10     # 매력
}

# HP & Energy
var max_hp: int = 100
var current_hp: int = 100
var max_energy: int = 100
var current_energy: int = 100

# 레벨 & 경험치
var level: int = 1
var experience: int = 0
var skill_points: int = 0

# 무술 슬롯 (5개)
var martial_arts: Array[MartialArt] = []

# 장비
var equipment = {}
var inventory = []

# 상태
var is_alive: bool = true
var is_in_combat: bool = false

# 신호
signal hp_changed(new_hp)
signal energy_changed(new_energy)
signal level_up(new_level)
```

---

### 2. **MartialArt (무술 시스템)**

**파일:** `Scripts/Core/MartialArt.gd`

```gdscript
class_name MartialArt
extends Resource

# 기본 정보
var id: String  # 무술 고유 ID
var name: String
var description: String

# 기본 동작 (100가지)
var base_motion: int  # 0-99 (손, 발, 몸통 동작)

# 리듬 타입
enum Tempo { FAST, MID, SLOW }
var tempo: Tempo

# 방어 타입
enum DefenseType { DODGE, GUARD, PARRY, COUNTER }
var defense_type: DefenseType
var defense_level: int  # 1-5

# 에너지 비용
var energy_cost: int  # 1-10

# 데미지
var base_damage: int  # 1-50
var str_scaling: float = 0.5  # STR에 따른 스케일
var dex_scaling: float = 0.2  # DEX에 따른 스케일

# 부가 효과
enum Effect { NONE, STUN, FREEZE, BURN, POISON, BLEED, DOWN, STAGGER }
var effect: Effect = Effect.NONE
var effect_duration: float = 0.0
var effect_chance: float = 0.0  # 0.0-1.0

# 판정 박스
var hitbox_range: float = 1.5  # 미터
var hitbox_radius: float = 0.3

# 애니메이션
var animation_name: String
var animation_duration: float = 1.0
var startup_frames: int = 5  # 발동까지 프레임
var active_frames: int = 10  # 판정 지속 프레임
var recovery_frames: int = 5 # 복구 프레임

# 콤보 정보
var can_combo: bool = true
var combo_requirements: Array[String] = []  # 이전 무술 ID

# 레벨 & 강화
var level: int = 1
var upgrade_damage: int = 0
var upgrade_range: float = 0.0
var upgrade_cost: int = 0

func calculate_damage(attacker: Character, defender: Character) -> int:
    var base = base_damage
    var str_bonus = attacker.stats["STR"] * str_scaling
    var dex_bonus = attacker.stats["DEX"] * dex_scaling
    var total = int(base + str_bonus + dex_bonus + upgrade_damage)
    
    # 방어 타입 계산 (나중에)
    return total
```

---

### 3. **Player (플레이어)**

**파일:** `Scripts/Core/Player.gd`

```gdscript
class_name Player
extends Character

# 입력 처리
var input_handler: InputHandler
var current_combo_index: int = 0

# 무술 슬롯 (기본 1 + 고급 4)
var basic_martial: MartialArt
var advanced_martials: Array[MartialArt]

# 전투 상태
var is_attacking: bool = false
var current_attack_duration: float = 0.0
var current_stance: int = 0  # 방어 자세 (0-3)

func _ready():
    max_hp = 100 + stats["CON"] * 5
    current_hp = max_hp
    max_energy = 100 + stats["CON"] * 2
    current_energy = max_energy
    
    # 초기 무술 설정 (기본 권투)
    basic_martial = MartialArt.new()
    basic_martial.name = "기본권"
    basic_martial.energy_cost = 10
    basic_martial.base_damage = 5

func _process(delta):
    if is_in_combat:
        handle_input()
        update_energy(delta)
        update_attack()

func handle_input():
    # 무술 발동
    if Input.is_action_just_pressed("ui_select"):
        execute_martial(0)  # 슬롯 0
    if Input.is_action_just_pressed("ui_focus_next"):
        execute_martial(1)  # 슬롯 1
    # ... 등등

func execute_martial(slot_index: int):
    if is_attacking:
        return
    
    var martial = martial_arts[slot_index]
    
    # 에너지 확인
    if current_energy < martial.energy_cost:
        print("에너지 부족!")
        return
    
    # 무술 발동
    current_energy -= martial.energy_cost
    is_attacking = true
    current_attack_duration = 0.0
    # 애니메이션 시작
    play_martial_animation(martial)

func update_energy(delta):
    # 스탠스 유지 중 회복
    if not is_attacking:
        current_energy = min(current_energy + 5 * delta, max_energy)
    
    energy_changed.emit(current_energy)

func take_damage(damage: int, attacker: Character = null):
    current_hp -= damage
    hp_changed.emit(current_hp)
    
    if current_hp <= 0:
        die()
```

---

### 4. **Enemy (적)**

**파일:** `Scripts/Core/Enemy.gd`

```gdscript
class_name Enemy
extends Character

# AI 컨트롤러
var ai_controller: AIController

# 드롭 아이템
var drop_items: Array[String] = []
var drop_exp: int = 0

func _ready():
    ai_controller = AIController.new()
    ai_controller.character = self
    ai_controller.ai_level = randi() % 2 + 1  # Level 1-2

func _process(delta):
    if is_alive and is_in_combat:
        ai_controller.update(delta)

func on_defeated():
    is_alive = false
    # 드롭 처리
    for item_id in drop_items:
        spawn_item(item_id)
    
    # 경험치 보상
    if is_in_group("enemy_boss"):
        # 보스 드롭: 무술 프래그먼트 등
        pass
```

---

### 5. **CombatSystem (전투 엔진)**

**파일:** `Scripts/Combat/CombatSystem.gd`

```gdscript
class_name CombatSystem
extends Node

var player: Player
var current_enemy: Enemy
var combat_log: Array[String] = []

func start_combat(player: Player, enemy: Enemy):
    self.player = player
    self.current_enemy = enemy
    player.is_in_combat = true
    enemy.is_in_combat = true

func calculate_damage(attacker: Character, martial: MartialArt, defender: Character) -> int:
    var damage = martial.calculate_damage(attacker, defender)
    
    # 방어 계산
    var defense = calculate_defense(defender, martial.defense_type)
    var final_damage = max(1, damage - defense)
    
    # 부가 효과 처리
    if randf() < martial.effect_chance:
        apply_effect(defender, martial.effect, martial.effect_duration)
    
    combat_log.append("%s의 %s로 %s에게 %d 데미지!" % [
        attacker.name, martial.name, defender.name, final_damage
    ])
    
    return final_damage

func calculate_defense(defender: Character, attack_type) -> int:
    # 방어 타입에 따른 계산
    # 회피: DEX 기반
    # 가드: CON 기반
    # ... 나중에 구현
    return 0

func apply_effect(target: Character, effect_type, duration: float):
    # 효과 적용 (스턴, 빙결 등)
    pass

func end_combat():
    player.is_in_combat = false
    current_enemy.is_in_combat = false
```

---

### 6. **AIController (적 AI 상태 머신)**

**파일:** `Scripts/AI/AIController.gd`

```gdscript
class_name AIController
extends Node

enum AIState { IDLE, CHASE, ATTACK, FLEE, DEAD }

var character: Enemy
var ai_level: int = 1  # 1-4
var current_state: AIState = AIState.IDLE
var target: Character = null

var state_timer: float = 0.0
var decision_timer: float = 0.0
var decision_interval: float = 1.0

var pattern_memory: Array[String] = []  # 최근 공격 기억
var pattern_threshold: int = 3

func update(delta):
    state_timer += delta
    decision_timer += delta
    
    if decision_timer >= decision_interval:
        make_decision()
        decision_timer = 0.0
    
    match current_state:
        AIState.IDLE:
            idle_update(delta)
        AIState.CHASE:
            chase_update(delta)
        AIState.ATTACK:
            attack_update(delta)
        AIState.FLEE:
            flee_update(delta)

func make_decision():
    # AI 레벨별 의사결정
    match ai_level:
        1:  # 동물형 AI
            decision_level_1()
        2:  # 기초 무술사 AI
            decision_level_2()
        3:  # 고급 무술사 AI
            decision_level_3()
        4:  # 마스터 AI
            decision_level_4()

func decision_level_1():
    # 기본: 가까우면 공격, 멀면 추격, 무조건 쫓아감
    if target and not character.is_alive:
        return
    
    var distance = character.global_position.distance_to(target.global_position)
    
    if distance < 2.0:
        current_state = AIState.ATTACK
    else:
        current_state = AIState.CHASE

func decision_level_2():
    # 패턴 감지 + 회피 능력
    # 같은 공격이 3번 반복되면 피함
    # ... 구현

func decision_level_3():
    # 약점 감지 + 적응 능력
    # ... 구현

func decision_level_4():
    # 완벽한 적응 + 예측 능력
    # ... 구현

func idle_update(delta):
    pass

func chase_update(delta):
    # 목표 추격
    var direction = (target.global_position - character.global_position).normalized()
    character.global_position += direction * 3.0 * delta

func attack_update(delta):
    # 무술 공격
    var martial = character.martial_arts[randi() % character.martial_arts.size()]
    # execute_martial(martial)
    pass

func flee_update(delta):
    # 도망
    if target:
        var away_direction = (character.global_position - target.global_position).normalized()
        character.global_position += away_direction * 2.0 * delta
```

---

## 📊 데이터 흐름

```
Player Input
    ↓
InputHandler
    ↓
Player.execute_martial()
    ↓
CombatSystem.calculate_damage()
    ↓
Enemy.take_damage()
    ↓
Enemy.is_alive? → AIController.update()
    ↓
Enemy.execute_martial() 또는 flee/block
```

---

## 🔄 초기화 순서 (Week 1 Day 1-2)

1. **Character.gd** (기본 클래스) ← 우선순위 1
2. **MartialArt.gd** (무술 시스템) ← 우선순위 1
3. **Player.gd** (플레이어) ← 우선순위 2
4. **Enemy.gd** (적) ← 우선순위 2
5. **CombatSystem.gd** (전투) ← 우선순위 2
6. **AIController.gd** (AI) ← 우선순위 2
7. **InputHandler.gd** (입력) ← 우선순위 3

---

**다음 단계:** DATA_SCHEMA.md (JSON 포맷 정의)
