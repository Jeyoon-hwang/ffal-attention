# 🎯 NEXUS v2 Week 1 Day 1-2 상세 계획

**Status:** 진행 중 (05-11 01:56 AM 시작)  
**Goal:** 프로토타입 기초 완성 (0% → 5%)  
**Timeline:** 48시간 (엄격한 집중)

---

## 📊 Day 1-2 산출물 체크리스트

### ✅ 설계 & 아키텍처 (완료)
- [x] ARCHITECTURE.md (클래스 설계)
- [x] DATA_SCHEMA.md (JSON 포맷)
- [ ] WEEK1_DAY1_2_PLAN.md (진행 중)

### 🔨 개발 태스크 (시작 예정)
- [ ] **Character.gd** (기본 클래스, 우선순위 1)
- [ ] **MartialArt.gd** (무술 데이터, 우선순위 1)
- [ ] **Player.gd** (플레이어 제어, 우선순위 2)
- [ ] **Enemy.gd** (적 기본, 우선순위 2)
- [ ] **CombatSystem.gd** (전투 엔진, 우선순위 2)
- [ ] **DataLoader.gd** (데이터 로드, 우선순위 2)
- [ ] **InputHandler.gd** (입력 처리, 우선순위 3)

### 📁 데이터 초기화 (시작 예정)
- [ ] martial_arts.json (기본 무술 10개)
- [ ] character_template.json (플레이어 템플릿)
- [ ] enemy_basic.json (기본 적 3종)
- [ ] boss_first.json (첫 보스)

### 🧪 테스트 & 통합 (시작 예정)
- [ ] 게임 실행 & 초기 로드
- [ ] Character + MartialArt 테스트
- [ ] Player 입력 처리 테스트
- [ ] Combat 시뮬레이션 (Player vs Dummy)

---

## ⏰ 시간 분배 (48시간)

| Phase | Time | Tasks |
|-------|------|-------|
| **Day 1: 00:00-12:00** | 12h | 핵심 클래스 구현 |
| **Day 1: 12:00-24:00** | 12h | 데이터 초기화 + 테스트 |
| **Day 2: 00:00-12:00** | 12h | 통합 & 버그 픽스 |
| **Day 2: 12:00-24:00** | 12h | 최종 검증 & 프로토타입 완성 |

---

## 🔨 Day 1: 핵심 클래스 구현 (0:00-24:00)

### Hour 0-2: 프로젝트 초기화 (완료)
```
✅ 폴더 구조
✅ 아키텍처 설계
✅ 데이터 스키마
```

### Hour 2-5: Character.gd 구현
**목표:** 기본 캐릭터 클래스 동작

```gdscript
# Scripts/Core/Character.gd
class_name Character
extends Node3D

# 1. 스탯 (5분)
var stats = {"STR": 10, "DEX": 10, ...}

# 2. HP & Energy (5분)
var max_hp: int = 100
var current_hp: int = 100

# 3. 무술 슬롯 (10분)
var martial_arts: Array[MartialArt] = []

# 4. 신호 (5분)
signal hp_changed(new_hp)
signal energy_changed(new_energy)

# 5. 메서드 (10분)
func take_damage(damage: int):
    current_hp -= damage
    hp_changed.emit(current_hp)

func restore_hp(amount: int):
    current_hp = min(current_hp + amount, max_hp)
    hp_changed.emit(current_hp)

func restore_energy(amount: int):
    current_energy = min(current_energy + amount, max_energy)
    energy_changed.emit(current_energy)

func use_energy(amount: int) -> bool:
    if current_energy >= amount:
        current_energy -= amount
        energy_changed.emit(current_energy)
        return true
    return false
```

**산출물:** Character.gd (기본 동작)

---

### Hour 5-8: MartialArt.gd 구현
**목표:** 무술 데이터 & 데미지 계산

```gdscript
# Scripts/Core/MartialArt.gd
class_name MartialArt
extends Resource

var id: String
var name: String
var energy_cost: int
var base_damage: int

func calculate_damage(attacker: Character, defender: Character) -> int:
    var str_bonus = attacker.stats["STR"] * 0.5
    var dex_bonus = attacker.stats["DEX"] * 0.2
    var total = int(base_damage + str_bonus + dex_bonus)
    return max(1, total)  # 최소 1 데미지
```

**산출물:** MartialArt.gd (데이터 & 계산)

---

### Hour 8-11: Player.gd 구현
**목표:** 플레이어 입력 처리 & 공격 시스템

```gdscript
# Scripts/Core/Player.gd
class_name Player
extends Character

var is_attacking: bool = false
var current_attack_timer: float = 0.0

func _process(delta):
    handle_input()
    update_attack(delta)
    update_energy(delta)

func handle_input():
    if Input.is_action_just_pressed("ui_select"):
        execute_martial(0)

func execute_martial(slot_index: int):
    if is_attacking or not martial_arts[slot_index]:
        return
    
    var martial = martial_arts[slot_index]
    if not use_energy(martial.energy_cost):
        return
    
    is_attacking = true
    current_attack_timer = 0.0
    print("무술 발동: %s" % martial.name)

func update_attack(delta):
    if is_attacking:
        current_attack_timer += delta
        if current_attack_timer > 1.0:  # 1초 후 종료
            is_attacking = false

func update_energy(delta):
    if not is_attacking:
        restore_energy(int(5 * delta))
```

**산출물:** Player.gd (입력 처리)

---

### Hour 11-14: CombatSystem.gd 구현
**목표:** 기본 전투 엔진

```gdscript
# Scripts/Combat/CombatSystem.gd
class_name CombatSystem
extends Node

func calculate_damage(attacker: Character, martial: MartialArt, defender: Character) -> int:
    var damage = martial.calculate_damage(attacker, defender)
    return damage

func apply_damage(attacker: Character, defender: Character, martial: MartialArt):
    var damage = calculate_damage(attacker, martial, defender)
    defender.take_damage(damage)
    print("%s이 %s에게 %d 데미지!" % [attacker.name, defender.name, damage])
```

**산출물:** CombatSystem.gd (기본 전투)

---

### Hour 14-17: Enemy.gd & AIController.gd 구현
**목표:** 적 기본 & Level 1 AI

```gdscript
# Scripts/Core/Enemy.gd
class_name Enemy
extends Character

var ai_controller: AIController

func _ready():
    ai_controller = AIController.new()
    ai_controller.character = self
    ai_controller.ai_level = 1

func _process(delta):
    if is_in_combat:
        ai_controller.update(delta)
```

```gdscript
# Scripts/AI/AIController.gd
class_name AIController
extends Node

var character: Enemy
var ai_level: int = 1
var target: Character = null
var decision_timer: float = 0.0

func update(delta):
    decision_timer += delta
    if decision_timer > 1.0:
        make_decision()
        decision_timer = 0.0

func make_decision():
    if ai_level == 1:
        # 기본: 추격 및 공격
        if target and character.global_position.distance_to(target.global_position) < 2.0:
            execute_attack()
        else:
            chase_target()

func chase_target():
    var direction = (target.global_position - character.global_position).normalized()
    character.global_position += direction * 2.0 * 0.016  # 60 FPS 가정

func execute_attack():
    if character.martial_arts.size() > 0:
        var martial = character.martial_arts[0]
        if character.use_energy(martial.energy_cost):
            print("적 공격: %s" % martial.name)
```

**산출물:** Enemy.gd, AIController.gd (기본 AI)

---

### Hour 17-20: DataLoader.gd 구현
**목표:** JSON 데이터 로드/저장

```gdscript
# Scripts/Core/DataLoader.gd
class_name DataLoader
extends Node

static func load_martial_arts(filepath: String) -> Array[MartialArt]:
    var file = FileAccess.open(filepath, FileAccess.READ)
    if not file:
        return []
    
    var json = JSON.parse_string(file.get_as_text())
    var martial_arts = []
    
    for martial_data in json["martial_arts"]:
        var martial = MartialArt.new()
        martial.id = martial_data["id"]
        martial.name = martial_data["name"]
        martial.energy_cost = martial_data["energy_cost"]
        martial.base_damage = martial_data["base_damage"]
        martial_arts.append(martial)
    
    return martial_arts

static func load_character(filepath: String) -> Character:
    var file = FileAccess.open(filepath, FileAccess.READ)
    if not file:
        return Character.new()
    
    var json = JSON.parse_string(file.get_as_text())
    var character = Character.new()
    character.name = json["name"]
    character.level = json["level"]
    character.stats = json["stats"]
    
    return character
```

**산출물:** DataLoader.gd (로드/저장)

---

### Hour 20-24: InputHandler.gd & 기본 테스트
**목표:** 입력 처리 + 초기 게임 씬

```gdscript
# Scripts/Core/InputHandler.gd
class_name InputHandler
extends Node

var player: Player

func _process(delta):
    if not player:
        return
    
    # 무술 슬롯 1-5
    for i in range(5):
        if Input.is_action_just_pressed("ui_select"):
            player.execute_martial(i)
    
    # 회피
    if Input.is_action_just_pressed("ui_cancel"):
        if player.martial_arts.size() > 0:
            player.execute_martial(0)  # 첫 슬롯 (방어 무술)
```

**산출물:** InputHandler.gd, 기본 테스트 씬

---

## 🎮 Day 2: 데이터 초기화 & 테스트 (0:00-24:00)

### Hour 0-4: 기본 무술 데이터 작성
**목표:** martial_arts.json (10개 기본 무술)

```json
{
  "martial_arts": [
    {
      "id": "martial_001",
      "name": "기본권",
      "energy_cost": 10,
      "base_damage": 5
    },
    ...
  ]
}
```

**산출물:** Data/Martial/martial_arts.json

---

### Hour 4-8: 적 데이터 초기화
**목표:** 3종 기본 적 + 첫 보스

```json
{
  "wolf_001": {
    "name": "회색 늑대",
    "level": 1,
    "ai_level": 1,
    "max_hp": 50,
    "stats": {"STR": 8, "DEX": 9, "CON": 7, ...}
  },
  ...
}
```

**산출물:** Data/Enemies/*.json

---

### Hour 8-12: 플레이어 템플릿 & 첫 던전
**목표:** 게임 시작 데이터 준비

**산출물:** Data/Characters/player_template.json, Data/Levels/dungeon_001.json

---

### Hour 12-16: 게임 씬 & 매니저 구현
**목표:** GameManager 및 메인 씬

```gdscript
# Scripts/Core/GameManager.gd
class_name GameManager
extends Node

var player: Player
var current_enemy: Enemy
var combat_system: CombatSystem

func _ready():
    player = Player.new()
    player.name = "플레이어"
    player.stats = {"STR": 10, "DEX": 10, "CON": 10, "INT": 10, "WIS": 10, "CHA": 10}
    
    # 무술 로드
    var martial_arts = DataLoader.load_martial_arts("res://Data/Martial/martial_arts.json")
    if martial_arts.size() > 0:
        player.martial_arts = [martial_arts[0], martial_arts[1]]
    
    combat_system = CombatSystem.new()
    add_child(combat_system)
    
    # 첫 적 생성
    current_enemy = Enemy.new()
    current_enemy.name = "늑대"
    current_enemy.level = 1
    current_enemy.martial_arts = [martial_arts[0]]
    
    # 전투 시작
    start_combat()

func start_combat():
    player.is_in_combat = true
    current_enemy.is_in_combat = true
    print("전투 시작: %s vs %s" % [player.name, current_enemy.name])

func _process(delta):
    if not player.is_alive or not current_enemy.is_alive:
        end_combat()

func end_combat():
    print("전투 종료!")
```

**산출물:** GameManager.gd, main_scene.tscn

---

### Hour 16-20: 통합 테스트
**목표:** 모든 시스템 동작 확인

**테스트 항목:**
- [ ] 게임 시작 & 로드
- [ ] 플레이어 입력 처리 (무술 발동)
- [ ] 에너지 소비 & 회복
- [ ] 적 AI 동작
- [ ] 전투 데미지 계산
- [ ] HP 감소 및 패배 판정

**산출물:** 버그 리스트, 테스트 결과

---

### Hour 20-24: 버그 픽스 & 최종 검증
**목표:** 기본 기능 완성도 100%

**체크리스트:**
- [ ] 캐릭터 생성 및 초기화 (에러 0)
- [ ] 무술 발동 (에러 0)
- [ ] 전투 시스템 (에러 0)
- [ ] 적 AI (에러 0)
- [ ] 성능 (60 FPS 유지)

**산출물:** 프로토타입 v0.1 (플레이 가능)

---

## 📈 Day 1-2 완료 기준

✅ **필수 완료:**
- [x] ARCHITECTURE.md
- [x] DATA_SCHEMA.md
- [ ] Character.gd (완전 동작)
- [ ] MartialArt.gd (완전 동작)
- [ ] Player.gd (입력 처리)
- [ ] Enemy.gd (기본 AI)
- [ ] CombatSystem.gd (데미지 계산)
- [ ] DataLoader.gd (로드/저장)
- [ ] 기본 데이터 (10개 무술, 3종 적, 첫 보스)
- [ ] GameManager.gd (씬 관리)
- [ ] main_scene.tscn (테스트 씬)

✅ **검증:**
- [ ] 게임 실행 성공
- [ ] Player vs Enemy 전투 가능
- [ ] 에러 0건

---

## 🎯 다음 Week 1 Day 3-4

**무술 생성 엔진 고도화:**
- 무술 100가지 데이터베이스 완성
- 무술 강화 시스템
- 무술 UI (에디터)

---

**Version:** 1.0  
**Status:** 시작 준비 완료  
**다음 업데이트:** 12시간 후
