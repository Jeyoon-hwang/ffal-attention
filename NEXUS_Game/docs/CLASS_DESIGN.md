# 🏗️ NEXUS 핵심 클래스 설계

**Document Version:** 1.0  
**Last Updated:** 2026-05-07  
**Status:** Day 1 완성 ✅

---

## 개요

NEXUS 무술 창조 게임의 핵심 로직을 담당할 클래스들의 설계서.  
모든 클래스는 **Godot 4.2+ GDScript**로 구현.

---

## 1️⃣ 무술 시스템 (Martial Arts)

### 1.1 MartialArt (무술 데이터 클래스)

**역할:** 개별 무술의 데이터와 로직 담당

```gdscript
class_name MartialArt
extends RefCounted

# 기본 정보
var id: String              # "punch_001"
var name: String            # "펀치 (Punch)"
var description: String
var icon_path: String

# 성능 파라미터
var base_power: float       # 기본 데미지 (1-100)
var energy_cost: int        # 필요 에너지 (1-10)
var cooldown: float         # 쿨타임 (초, 0 = 없음)
var range: float            # 공격 범위 (미터)
var animation_name: String  # 애니메이션 ID

# 특성 (Flags)
var is_combo: bool          # 콤보 가능 여부
var max_combo_count: int    # 최대 콤보 횟수 (0 = 단일)
var is_guard_breaking: bool # 방어 무시 여부
var is_knockdown: bool      # 다운 유발 여부

# 효과 (Effect)
var effects: Array = []     # ["stun", "fire_burn", ...]
var effect_duration: float  # 상태이상 지속시간 (초)

# 강화 (Advancement)
var level: int = 1          # 무술 레벨 (1-10)
var mastery: float = 0.0    # 숙련도 (0-100)

# 통계
var use_count: int = 0      # 사용 횟수
var hit_count: int = 0      # 명중 횟수

# 메서드
func calculate_damage(attacker: Node) -> float:
    # STR × power + DEX × 치명타율
    pass

func get_stats() -> Dictionary:
    # 모든 파라미터를 딕셔너리로 반환
    pass

func to_dict() -> Dictionary:
    # 저장용 딕셔너리로 변환
    pass

static func from_dict(data: Dictionary) -> MartialArt:
    # 딕셔너리에서 복원
    pass
```

**주요 메서드:**
- `calculate_damage()` - 데미지 계산
- `get_effects()` - 부가 효과 반환
- `upgrade()` - 무술 레벨 상향
- `get_energy_cost()` - 실시간 에너지 비용 계산 (스탯 영향)

---

### 1.2 MartialArtEngine (무술 생성 엔진)

**역할:** 무술을 동적으로 생성, 로드, 저장

```gdscript
class_name MartialArtEngine
extends RefCounted

# 기본 데이터
var base_motions: Array = []        # 100가지 기본 동작
var effects: Array = []             # 20가지 효과
var tempos: Array = ["fast", "mid", "slow"]
var defense_types: Array = ["evade", "guard", "parry", "counter"]

# 생성된 무술 캐시
var created_arts: Dictionary = {}   # id → MartialArt

# 메서드
func generate_martial_art(rarity: int = 0) -> MartialArt:
    # 난이도별 무술 동적 생성
    # rarity: 0=일반, 1=레어, 2=에픽, 3=레전더리
    pass

func get_martial_art(id: String) -> MartialArt:
    # ID로 무술 검색
    pass

func load_martial_arts_from_json(path: String) -> bool:
    # JSON에서 무술 데이터 로드
    pass

func save_martial_arts_to_json(path: String) -> bool:
    # 현재 무술들을 JSON으로 저장
    pass

func get_all_martial_arts() -> Array:
    # 모든 무술 반환
    pass

func create_custom_art(base: String, effects: Array) -> MartialArt:
    # 사용자 정의 무술 생성
    pass
```

**무술 조합 공식:**
```
총 조합 = 기본동작(100) × 템포(3) × 방어타입(4×5) × 효과(20) × ...
최소 조합: 100 × 3 × 4 × 1 = 1,200 (레벨 제약 제외)
최대 조합: 수백만 (프래그먼트 시스템 포함)
```

---

## 2️⃣ 캐릭터 시스템 (Characters)

### 2.1 Player (플레이어 캐릭터)

**역할:** 플레이어 통제 & 상태 관리

```gdscript
class_name Player
extends CharacterBody3D

# 기본 정보
var player_name: String
var level: int = 1
var experience: float = 0.0
var skill_points: int = 2  # 레벨당 2개

# 능력치 (Stats)
var stats: Dictionary = {
    "STR": 10,    # 근력 (데미지)
    "DEX": 10,    # 민첩 (회피, 크리)
    "CON": 10,    # 체력 (HP, 방어)
    "INT": 10,    # 지능 (마나)
    "WIS": 10,    # 지혜 (회복)
    "CHA": 10     # 매력 (설득)
}

# 생명 & 에너지
var max_hp: int = 100
var current_hp: int = 100
var max_energy: int = 100
var current_energy: int = 100
var max_spirit: int = 100
var current_spirit: int = 100

# 무술 슬롯
var martial_slots: Array[MartialArt] = []  # 최대 5개
var current_stance: String = "neutral"     # 자세

# 인벤토리
var inventory: Dictionary = {}  # item_id → count
var equipment: Dictionary = {}  # body_part → item

# 상태
var is_in_combat: bool = false
var is_stunned: bool = false
var is_defending: bool = false
var combo_count: int = 0

# 메서드
func take_damage(amount: float, source: Node) -> void:
    # 데미지 입기
    pass

func recover_hp(amount: float) -> void:
    # 체력 회복
    pass

func use_energy(amount: float) -> bool:
    # 에너지 소비 (소비 가능하면 true 반환)
    pass

func recover_energy(amount: float) -> void:
    # 에너지 회복
    pass

func equip_martial_art(slot: int, art: MartialArt) -> bool:
    # 무술 장착
    pass

func execute_martial_art(slot: int) -> bool:
    # 무술 발동
    pass

func level_up() -> void:
    # 레벨업 처리
    pass

func add_skill_points(amount: int) -> void:
    # 스킬 포인트 추가
    pass

func upgrade_stat(stat_name: String, amount: int) -> bool:
    # 능력치 강화 (스킬 포인트 소비)
    pass
```

**주요 특징:**
- 5개 무술 슬롯 (기본기 1 + 고급 4)
- 에너지 시스템 (공격/회피 소비, 스탠스 회복)
- 자유로운 빌드 (직업 제약 없음)
- 콤보 시스템 (같은 무술 반복)

---

### 2.2 Enemy (적 베이스 클래스)

**역할:** 모든 적의 공통 기능

```gdscript
class_name Enemy
extends CharacterBody3D

# 기본 정보
var enemy_name: String
var enemy_type: String      # "goblin", "orc", "boss"
var ai_level: int = 1       # AI 난이도 (1-4)
var level: int = 1

# 생명 & 에너지
var max_hp: int = 50
var current_hp: int = 50
var max_energy: int = 50
var current_energy: int = 50

# 능력치
var stats: Dictionary = {
    "STR": 8, "DEX": 8, "CON": 8,
    "INT": 5, "WIS": 5, "CHA": 3
}

# 무술 슬롯 (적은 3개만 사용)
var martial_slots: Array[MartialArt] = []

# 행동 상태
var current_state: String = "idle"  # idle, chase, attack, stun, dead
var target: Node = null
var last_attack_time: float = 0.0

# AI 관련
var ai_controller: AIController = null
var patrol_points: Array = []

# 메서드
func _physics_process(delta: float) -> void:
    # 물리 & AI 루프
    pass

func take_damage(amount: float, source: Node) -> void:
    pass

func die() -> void:
    pass

func choose_action() -> Dictionary:
    # AI가 다음 행동 결정 후 반환
    # {"action": "attack", "slot": 0, "target": target}
    pass

func execute_action(action: Dictionary) -> void:
    pass
```

---

## 3️⃣ 전투 시스템 (Combat)

### 3.1 CombatSystem (전투 중앙 관리)

**역할:** 플레이어-적 전투 로직 통제

```gdscript
class_name CombatSystem
extends Node

# 참여자
var player: Player
var enemies: Array = []  # 현재 전투 중인 적들
var current_turn: String = "player"  # "player" or "enemy"

# 상태
var in_combat: bool = false
var combat_log: Array = []

# 메서드
func start_combat(player: Player, enemy: Enemy) -> void:
    # 전투 시작
    pass

func process_player_action(slot: int) -> void:
    # 플레이어 무술 발동
    pass

func process_enemy_actions() -> void:
    # 모든 적의 행동 처리
    pass

func calculate_hit(attacker: Node, defender: Node, art: MartialArt) -> Dictionary:
    # 명중 판정 & 데미지 계산
    # 반환: {"hit": true, "damage": 25, "crit": false, "effect": "stun"}
    pass

func apply_damage(target: Node, amount: float) -> void:
    pass

func apply_effect(target: Node, effect: String, duration: float) -> void:
    pass

func end_combat(winner: String) -> void:
    # 전투 종료 ("player" or "enemy")
    pass

func get_combat_log() -> String:
    # 전투 로그 반환
    pass
```

**명중 판정:**
```
hit_chance = base_hit_rate(70%) + 
             DEX보정(±5% per 10 DEX차이) - 
             target_evade_rate
crit_chance = DEX / 100 + equipment_bonus
```

---

### 3.2 DamageCalculator (데미지 계산 엔진)

**역할:** 정확한 데미지 계산

```gdscript
class_name DamageCalculator
extends RefCounted

static func calculate_damage(
    attacker: Node,
    defender: Node,
    art: MartialArt
) -> float:
    # 기본 데미지
    var base = art.base_power
    
    # 스탯 영향
    var str_mod = attacker.stats["STR"] * 0.8
    var dex_mod = attacker.stats["DEX"] * 0.3
    
    # 방어 계산
    var defense = defender.stats["CON"] * 0.5
    if defender.is_defending:
        defense *= 1.5
    
    # 최종 계산
    var damage = base + str_mod + dex_mod - defense
    damage = max(1.0, damage)  # 최소 1 데미지
    
    return damage

static func calculate_healing(
    healer: Node,
    art: MartialArt
) -> float:
    # WIS 스탯 기반 회복량
    return art.base_power + healer.stats["WIS"] * 0.8
```

---

## 4️⃣ AI 시스템 (Artificial Intelligence)

### 4.1 AIController (AI 베이스 클래스)

**역할:** 모든 AI의 기본 프레임워크

```gdscript
class_name AIController
extends Node

var enemy: Enemy
var player: Player
var level: int = 1  # 1-4

# 메모리
var combat_log: Array = []
var learned_patterns: Dictionary = {}

# 메서드
func _ready() -> void:
    pass

func decide_action() -> Dictionary:
    # 다음 행동 결정 (서브클래스에서 오버라이드)
    return {"action": "attack", "slot": 0}

func learn_from_combat() -> void:
    # 플레이어의 패턴 분석
    pass

func get_action_delay() -> float:
    # AI 반응 시간 (레벨별 다름)
    return 1.0 - (level * 0.15)
```

### 4.2 AILevel1, AILevel2, AILevel3, AILevel4

**Level 1 - 동물형** (회피율: 10%)
```gdscript
func decide_action() -> Dictionary:
    if enemy.current_hp < enemy.max_hp * 0.3:
        return {"action": "attack", "slot": 0}
    return {"action": "idle"}
```

**Level 2 - 기초 무술사** (회피율: 25%)
- 플레이어의 마지막 공격 패턴 감지
- 약한 무술 회피
- 에너지 관리

**Level 3 - 고급 무술사** (회피율: 40%)
- 플레이어 약점 분석
- 멀티 패턴 조합
- 전략적 이동

**Level 4 - 마스터** (회피율: 70%)
- 모든 패턴 학습
- 카운터 공격
- 페이즈 전환 (보스)

---

## 5️⃣ 세부 시스템

### 5.1 EffectSystem (상태이상/버프)

```gdscript
class_name EffectSystem
extends Node

# 활성 효과들
var active_effects: Dictionary = {}  # effect_name → {duration, data}

func apply_effect(effect: String, duration: float, data: Dictionary) -> void:
    pass

func remove_effect(effect: String) -> void:
    pass

func process_effects(delta: float) -> void:
    # 매 프레임 효과 업데이트
    pass

func get_stat_modifiers() -> Dictionary:
    # 활성 버프/디버프에 따른 스탯 수정
    pass
```

**효과 목록:**
- Stun (기절, 행동 불가 1-3초)
- Knockdown (다운, 일어나는 애니메이션 2초)
- Burn (화염, 매 초 데미지)
- Freeze (빙결, 이동 속도 50% 감소)
- Bleed (출혈, 지속 데미지)
- Poison (독, 모든 스탯 감소)
- Buff_ATK (공격력 증가)
- Buff_DEF (방어력 증가)

---

## 데이터 흐름

```
Player Input
    ↓
CombatSystem.process_player_action()
    ↓
MartialArtEngine.get_martial_art(slot)
    ↓
DamageCalculator.calculate_damage()
    ↓
Enemy.take_damage() → EffectSystem.apply_effect()
    ↓
AIController.decide_action()
    ↓
(반복)
```

---

## 파일 배치 계획

```
Scripts/
├── Martial/
│   ├── MartialArt.gd           (Day 2)
│   ├── MartialArtEngine.gd     (Day 3-4)
│   └── MartialArtLibrary.gd    (Day 5)
│
├── Combat/
│   ├── Player.gd               (Day 2)
│   ├── Enemy.gd                (Day 2)
│   ├── CombatSystem.gd         (Day 5-6)
│   ├── DamageCalculator.gd     (Day 5-6)
│   └── EffectSystem.gd         (Day 7)
│
└── AI/
    ├── AIController.gd         (Day 6)
    ├── AILevel1.gd             (Day 6)
    ├── AILevel2.gd             (Day 6)
    ├── AILevel3.gd             (Day 7)
    └── AILevel4.gd             (Day 7)
```

---

## 다음 단계

✅ **완료:** 클래스 설계  
📋 **다음:** DATA_FORMAT.md (데이터 포맷 정의)  
🔨 **그 다음:** Day 2 실제 코드 구현

---

_문서 작성자: 천재 (AI Assistant)_  
_Updated: 2026-05-07_
