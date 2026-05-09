# NEXUS 무술 창조 게임 - 아키텍처 설계서

**Version:** 1.0  
**Last Updated:** 2026-05-09  
**Status:** Day 1 - 설계 중

---

## 핵심 클래스 구조

### 1. Player (플레이어)
**위치:** `Scripts/Core/Player.gd`

```
Player (extends CharacterBody3D)
├── Attributes
│   ├── level: int = 1
│   ├── exp: int = 0
│   ├── hp: float (CON × 10)
│   ├── max_hp: float
│   ├── energy: float (100)
│   ├── max_energy: float
│   ├── stats: Dictionary {STR, DEX, CON, INT, WIS, CHA}
│   └── skill_points: int = 0
│
├── Combat System
│   ├── martial_arts: Array[MartialArt] (5 슬롯)
│   ├── current_martial: int (현재 사용 무술)
│   ├── combo_count: int
│   ├── last_attack_time: float
│   └── is_attacking: bool
│
├── Movement
│   ├── velocity: Vector3
│   ├── speed: float = 7.0 (DEX 영향)
│   └── acceleration: float = 0.3
│
└── Methods
    ├── _process() - 입력 처리
    ├── _physics_process() - 물리 업데이트
    ├── attack(martial_index) → void
    ├── take_damage(amount) → void
    ├── heal(amount) → void
    ├── recover_energy(amount) → void
    ├── level_up() → void
    ├── save_to_file() → void
    └── load_from_file() → void
```

### 2. MartialArt (무술)
**위치:** `Scripts/Martial/MartialArt.gd`

```
MartialArt (extends Resource)
├── Identification
│   ├── id: String (unique)
│   ├── name: String
│   ├── description: String
│   └── rarity: int (1-5)
│
├── Base Properties
│   ├── base_motion_id: int (0-99)
│   ├── tempo: String (Fast/Mid/Slow)
│   ├── energy_cost: int (1-10)
│   └── damage_base: float
│
├── Defense Type (선택 1개)
│   ├── defense_type: String (Dodge/Guard/Counter/Parry)
│   └── defense_level: int (1-5)
│
├── Additional Effects
│   ├── effects: Array[String]
│   │   └── 예: ["stun", "knockdown", "fire_damage"]
│   └── effect_power: int (1-10)
│
├── Hitbox System
│   ├── hitbox_size: Vector3
│   ├── hitbox_position: Vector3
│   └── damage_distribution: Array[float]
│
├── Level & Upgrade
│   ├── current_level: int = 1
│   ├── max_level: int = 10
│   └── upgrades: Dictionary {damage_bonus, reach_bonus, combo_bonus}
│
└── Methods
    ├── get_total_damage() → float
    ├── get_energy_cost() → int
    ├── get_damage_with_stats(stats: Dictionary) → float
    ├── apply_effect(target: Enemy) → void
    └── serialize() → Dictionary
```

### 3. CombatSystem (전투 시스템)
**위치:** `Scripts/Combat/CombatSystem.gd`

```
CombatSystem (extends Node)
├── Combat State
│   ├── attacker: Player/Enemy
│   ├── defender: Enemy/Player
│   ├── is_active: bool
│   └── last_hit_time: float
│
├── Damage Calculation
│   ├── calc_damage(attacker, martial_art) → float
│   ├── calc_crit_chance(attacker_dex) → float
│   ├── apply_stun(target, duration) → void
│   ├── apply_knockdown(target) → void
│   └── apply_status_effect(target, effect) → void
│
└── Methods
    ├── process_hit(attacker, defender, martial) → HitResult
    ├── process_defense(defender) → DefenseResult
    ├── resolve_damage(damage, defense) → int
    └── on_combat_end() → void
```

### 4. Enemy (적)
**위치:** `Scripts/AI/Enemy.gd`

```
Enemy (extends CharacterBody3D)
├── Base Attributes
│   ├── enemy_type: String (Animal/Martial/Boss/Master)
│   ├── level: int
│   ├── hp: float
│   ├── max_hp: float
│   ├── stats: Dictionary
│   └── martial_arts: Array[MartialArt]
│
├── AI State Machine
│   ├── state: String (Idle/Chase/Attack/Flee/Stun)
│   ├── state_timer: float
│   └── last_state_change: float
│
├── Behavior Tree (Level 2+)
│   ├── pattern_memory: Array[String]
│   ├── weakness_detected: Dictionary
│   └── adaptation_level: int
│
└── Methods
    ├── _process() - 상태 갱신
    ├── update_ai_state() → void
    ├── choose_martial_art() → MartialArt
    ├── take_damage(amount) → void
    ├── on_death() → void
    └── get_loot() → Array[Item]
```

### 5. DungeonManager (던전 관리)
**위치:** `Scripts/World/DungeonManager.gd`

```
DungeonManager (extends Node)
├── Dungeon Data
│   ├── dungeon_id: String
│   ├── level_range: Vector2i (min, max)
│   ├── enemy_count: int
│   ├── boss: Enemy
│   └── rewards: Dictionary
│
├── Rooms
│   ├── rooms: Array[DungeonRoom]
│   ├── current_room: int
│   └── is_cleared: bool
│
└── Methods
    ├── spawn_room(room_index) → void
    ├── check_room_cleared() → bool
    ├── spawn_boss() → void
    ├── on_boss_defeated() → void
    └── distribute_rewards(player) → void
```

### 6. WorldManager (세계 관리)
**위置:** `Scripts/World/WorldManager.gd`

```
WorldManager (extends Node)
├── Regions
│   ├── regions: Dictionary[String, Region]
│   │   ├── "중원" → Region
│   │   ├── "천산" → Region
│   │   ├── "황무지" → Region
│   │   ├── "동해" → Region
│   │   └── "흑룡굴" → Region
│   └── current_region: String
│
├── Spawning
│   ├── spawn_points: Array[SpawnPoint]
│   ├── enemy_spawner: EnemySpawner
│   └── npc_manager: NPCManager
│
└── Methods
    ├── load_region(region_name) → void
    ├── unload_region(region_name) → void
    ├── get_spawned_enemies() → Array[Enemy]
    └── save_world_state() → void
```

### 7. UIManager (UI 관리)
**위치:** `Scripts/UI/UIManager.gd`

```
UIManager (extends CanvasLayer)
├── HUD
│   ├── health_bar: ProgressBar
│   ├── energy_bar: ProgressBar
│   ├── level_label: Label
│   ├── exp_bar: ProgressBar
│   └── martial_art_slots: Array[MartialArtSlot]
│
├── Menus
│   ├── pause_menu: Node
│   ├── martial_editor: MartialArtEditor
│   ├── inventory: InventoryUI
│   └── status_screen: StatusScreen
│
└── Methods
    ├── update_hud(player) → void
    ├── show_combat_damage(damage_amount) → void
    ├── show_effect_indicator(effect_name) → void
    └── open_martial_editor() → void
```

---

## 데이터 흐름

```
Player Input
    ↓
InputHandler
    ↓
CombatSystem
    ├→ Check Energy Cost
    ├→ Calculate Damage
    ├→ Check Hitbox
    └→ Apply Effects
    ↓
Enemy AI
    ├→ Evaluate Defense
    ├→ Choose Response
    └→ Counter Attack
    ↓
WorldManager (Loot/XP Distribution)
    ↓
UIManager (HUD Update)
```

---

## 파일 저장 구조

**SaveGame Format (JSON):**
```
{
  "player": {
    "level": 10,
    "exp": 5000,
    "hp": 100,
    "max_hp": 100,
    "energy": 100,
    "max_energy": 100,
    "stats": {
      "STR": 10,
      "DEX": 8,
      "CON": 9,
      "INT": 7,
      "WIS": 8,
      "CHA": 6
    },
    "martial_arts": [
      {
        "id": "MA_001",
        "name": "기본 펀치",
        "level": 5,
        ...
      }
    ]
  },
  "world": {
    "current_region": "중원",
    "cleared_dungeons": ["D001", "D002"],
    ...
  }
}
```

---

## 엔진 선택 근거

**Godot 4.2 선택:**
- ✅ 3D 성능 충분 (GLES 3.0)
- ✅ 빠른 개발 (GDScript 단순함)
- ✅ 무료 & 오픈소스
- ✅ 빌드 빠름 (핫 리로드 지원)
- ✅ 커뮤니티 활발

---

## 다음 단계

1. **Data Schema 정의** (이번 Day 1)
2. **MartialArt 클래스 구현** (Day 3-4)
3. **Player 클래스 구현** (Day 5-6)
4. **CombatSystem 구현** (Day 5-6)
5. **Enemy AI 구현** (Day 8-9)
