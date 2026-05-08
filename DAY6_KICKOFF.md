# 🥋 Day 6 킥오프 - GameManager & 첫 지역

**날짜**: 2026-05-08 (Friday) PM  
**진행도**: 28% (Week 2 진행 중)  
**목표**: 28% → 40% (+12%)  
**예상 시간**: 3-4시간  

---

## 📊 현재 상황 요약

### ✅ Week 1-2 완료된 것 (28%)

**핵심 엔진**
- ✓ MartialArt.gd - 무술 데이터 (600+ 조합)
- ✓ Player.gd - 플레이어 전투 (레벨, 스탯, 콤보)
- ✓ Enemy.gd - 적 AI (Level 1-4, 패턴 학습)
- ✓ Boss.gd - 보스 시스템 (3-Phase, 약점)
- ✓ MartialArtEngine.gd - 무술 생성 엔진
- ✓ CombatSystem.gd - 전투 관리
- ✓ 테스트 스크립트 - 자동 검증

**코드 통계**
- 총 2,245줄
- 10개 GDScript 파일
- 35+개 테스트 케이스
- 모든 테스트 통과 ✓

---

## 🎯 Day 6 목표 (지금 시작)

### Task 1: GameManager 확장 (60분, ~150줄)

**파일**: `Scripts/Core/GameManager.gd`  
**목표**: 게임 전체 상태 관리

```gdscript
# GameManager.gd
extends Node
class_name GameManager

# 싱글톤
static var instance: GameManager = null

# 게임 상태
var current_scene: String = "main"  # main, zone, combat, menu
var current_zone: String = "center"  # center, mountain, desert, sea, dragon
var player: Player = null
var current_level: int = 1

# 진행도
var zones_discovered: Array[String] = []
var dungeons_completed: int = 0
var bosses_defeated: int = 0
var npcs_met: int = 0

# 설정
var auto_save_enabled: bool = true
var difficulty: int = 1  # 1-4
var master_volume: float = 0.8

func _init():
    if instance == null:
        instance = self
    add_to_group("autoload")

func _ready():
    load_game()

# 새 게임 시작
func new_game() -> void:
    player = Player.new()
    player.level = 1
    player.current_hp = player.max_hp
    current_scene = "zone"
    current_zone = "center"
    zones_discovered.clear()
    dungeons_completed = 0

# 게임 저장
func save_game() -> void:
    var save_data = {
        "player_level": player.level,
        "player_hp": player.current_hp,
        "player_exp": player.experience,
        "zones_discovered": zones_discovered,
        "dungeons_completed": dungeons_completed,
        "current_zone": current_zone
    }
    # JSON 저장 (user://nexus_save.json)

# 게임 로드
func load_game() -> void:
    # JSON 로드 (user://nexus_save.json)
    pass

# 지역 입장
func enter_zone(zone_name: String) -> void:
    current_zone = zone_name
    if zone_name not in zones_discovered:
        zones_discovered.append(zone_name)

# 던전 완료
func complete_dungeon() -> void:
    dungeons_completed += 1

# 게임 상태 조회
func get_stats() -> Dictionary:
    return {
        "level": player.level if player else 1,
        "zones": zones_discovered.size(),
        "dungeons": dungeons_completed,
        "bosses": bosses_defeated,
        "npcs": npcs_met
    }
```

**체크리스트**:
- [ ] 파일 생성
- [ ] 싱글톤 구현
- [ ] 게임 상태 관리
- [ ] 저장/로드 기능 기초
- [ ] 통계 조회
- [ ] 컴파일 성공

---

### Task 2: 첫 지역 씬 (60분, ~500줄)

**파일**: `Scenes/Zones/CenterZone.tscn`  
**목표**: 중원 지역 기본 맵

**씬 구조**:
```
CenterZone (Node3D)
├── WorldEnvironment
│   ├── DirectionalLight3D
│   └── WorldEnvironment (하늘)
├── TerrainMeshInstance3D
│   ├── MeshInstance3D (바닥)
│   ├── Collider (물리)
│   └── Material (지형)
├── Player (CharacterBody3D)
│   └── CollisionShape3D
├── NPCs (Node3D)
│   ├── MartialMaster
│   ├── QuestGiver
│   └── ItemSeller
├── Dungeons (Node3D)
│   ├── FirstDungeon (entrance marker)
│   └── BossDungeon (entrance marker)
└── GameManager (Node)
```

**맵 사양**:
- 크기: 500m × 500m
- 플레이어 스폰: (0, 0, 0)
- 3-5개 기본 구조물
- 4-5개 던전 입구
- 3-5개 NPC

**체크리스트**:
- [ ] 씬 생성
- [ ] 3D 지형 생성 (간단한 메시)
- [ ] 플레이어 스폰 설정
- [ ] 게임 매니저 연결
- [ ] NPC 마커 배치
- [ ] 던전 입구 마커
- [ ] 컴파일 성공

---

### Task 3: 전투 UI (40분, ~200줄)

**파일**: `Scripts/UI/CombatUI.gd`  
**목표**: HP/Energy 바 및 무술 슬롯 표시

```gdscript
# CombatUI.gd
extends CanvasLayer
class_name CombatUI

# 참조
var player: Player = null
var enemy: Enemy = null

# UI 노드
var player_hp_label: Label
var player_hp_bar: ProgressBar
var player_energy_bar: ProgressBar
var enemy_hp_bar: ProgressBar

# 무술 슬롯
var martial_slot_buttons: Array[Button] = []

# 전투 로그
var combat_log_text: TextEdit

func _ready():
    create_ui()
    player = GameManager.instance.player

func create_ui() -> void:
    # HP 바 (플레이어)
    player_hp_bar = ProgressBar.new()
    player_hp_bar.min_value = 0
    player_hp_bar.max_value = 100
    player_hp_bar.value = 100
    add_child(player_hp_bar)
    
    # 에너지 바
    player_energy_bar = ProgressBar.new()
    player_energy_bar.modulate.color = Color.YELLOW
    add_child(player_energy_bar)
    
    # 무술 슬롯 (1-5)
    for i in range(5):
        var button = Button.new()
        button.text = "Slot %d" % (i + 1)
        button.pressed.connect(func(): player.current_martial_index = i)
        add_child(button)
        martial_slot_buttons.append(button)
    
    # 전투 로그
    combat_log_text = TextEdit.new()
    combat_log_text.editable = false
    add_child(combat_log_text)

func _process(delta: float):
    if player == null:
        return
    
    # HP 바 업데이트
    player_hp_bar.value = int(player.current_hp * 100 / player.max_hp)
    
    # 에너지 바 업데이트
    player_energy_bar.value = int(player.current_energy * 100 / player.max_energy)
    
    # 무술 슬롯 업데이트
    for i in range(5):
        if player.martial_arts[i] == null:
            martial_slot_buttons[i].text = "Empty"
        else:
            martial_slot_buttons[i].text = player.martial_arts[i].name

func update_combat_log(message: String) -> void:
    combat_log_text.text += message + "\n"
```

**체크리스트**:
- [ ] UI 스크립트 생성
- [ ] HP 바 구현
- [ ] 에너지 바 구현
- [ ] 무술 슬롯 표시
- [ ] 전투 로그 표시
- [ ] 실시간 업데이트
- [ ] 컴파일 성공

---

### Task 4: NPC & 퀘스트 기초 (20분, ~100줄)

**파일**: 
- `Scripts/World/NPC.gd`
- `Scripts/World/Quest.gd`

```gdscript
# NPC.gd
extends Node3D
class_name NPC

var npc_name: String = "NPC"
var npc_type: String = "master"  # master, quest_giver, merchant
var dialogue: Array[String] = ["Hello!"]
var quests: Array[Quest] = []
var position_3d: Vector3 = Vector3.ZERO

func _init(p_name: String = "NPC", p_type: String = "master"):
    npc_name = p_name
    npc_type = p_type

func talk() -> String:
    return dialogue[randi() % dialogue.size()]

func offer_quest(quest: Quest) -> void:
    quests.append(quest)

# Quest.gd
class_name Quest

var id: String
var title: String
var description: String
var objective: String
var reward_exp: int
var reward_gold: int
var is_completed: bool = false

func _init(p_id: String, p_title: String):
    id = p_id
    title = p_title
```

**체크리스트**:
- [ ] NPC 클래스 생성
- [ ] Quest 클래스 생성
- [ ] 기본 대사 시스템
- [ ] 퀘스트 오퍼 메커니즘
- [ ] 컴파일 성공

---

## 📅 작업 순서

1. **GameManager.gd** (60분)
   - 게임 상태 관리
   - 저장/로드 기능

2. **CenterZone.tscn** (60분)
   - 첫 지역 맵
   - NPC 배치
   - 던전 입구

3. **CombatUI.gd** (40분)
   - HP/Energy 바
   - 무술 슬롯
   - 전투 로그

4. **NPC.gd & Quest.gd** (20분)
   - 기본 NPC 시스템
   - 퀘스트 구조

---

## 🎯 Day 6 완료 기준

✅ **모든 Task 완료**
- GameManager.gd 작성 (상태 관리)
- CenterZone.tscn 생성 (첫 지역)
- CombatUI.gd 구현 (전투 UI)
- NPC/Quest 클래스 생성
- 코드 총 2,245 → 2,645줄
- Git 커밋 (Day 6: GameManager + 첫 지역)

✅ **테스트**
- GameManager 기초 테스트
- 지역 입장 로직
- UI 업데이트 확인
- 에러 0

---

## 📊 진행도 예상

```
Day 6 완료 후:
진행도: 28% → 40% (+12%)

Week 2 누적:
[████████████████████████████----] 40%
└─ Week 1: 20%
└─ Day 5: +8%
└─ Day 6: +12%
```

---

## 💡 주의사항

1. **GameManager**: 싱글톤으로 구현 (게임 전체에서 접근 가능)
2. **지역 씬**: 간단한 메시로 시작 (나중에 모델링 추가)
3. **UI**: Canvas Layer 사용 (화면 위에 표시)
4. **NPC**: 기본 클래스만 구현 (대사는 JSON 데이터로)
5. **Git**: 매 Task마다 커밋

---

## 🚀 다음 단계 (Day 7+)

- Day 7: 던전 시스템 + 몬스터 스폰
- Day 8: UI 개선 + 아이템 시스템
- Day 9-10: 더 많은 지역 + 보스 대신
- Week 3+: 그래픽, 애니메이션, 사운드

---

**Status**: 🚀 **Day 6 준비 완료! 시작하자!**

_작성: 천재_  
_시간: 2026-05-08 PM_
