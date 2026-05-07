# 🔥 NEXUS Week 1, Day 1-2: 프로젝트 초기화 & 아키텍처

**목표:** 게임 개발 환경 완벽하게 설정, 핵심 클래스 설계 확정  
**기간:** 2026-05-07 (수요일) ~ 2026-05-08 (목요일)  
**예상 시간:** 8-10시간  

---

## 📋 Day 1 (2026-05-07, 수요일) - 5시간

### Task 1: 엔진 선택 & 설치 (30분)

**선택지:**

| 엔진 | 장점 | 단점 | 권장도 |
|------|------|------|--------|
| **Godot 4.2** | 무료, 오픈소스, 빠른 개발, 3D 충분 | 커뮤니티 작음 | ⭐⭐⭐⭐⭐ |
| **Three.js** | 웹 기반, 배포 쉬움, 모바일 | 모바일 성능 떨어짐 | ⭐⭐⭐ |
| **Unity** | 강력함, 많은 리소스 | 비영리 제한, 무겁다 | ⭐⭐⭐⭐ |

**결정:** **Godot 4.2** 선택 (최신, 빠른 프로토타입, 성능 충분)

**설치 과정:**
```bash
# Godot 4.2 다운로드 (https://godotengine.org)
# 설치 완료 확인
godot --version

# 또는 Steam에서 설치
```

**체크리스트:**
- [ ] Godot 4.2 설치 완료
- [ ] Godot 실행 테스트 (창이 열리는가?)
- [ ] 버전 확인: 4.2.x 이상

---

### Task 2: Git & 프로젝트 폴더 생성 (20분)

**1단계: 프로젝트 디렉토리 생성**
```bash
# 아래 경로에서 진행
cd /Users/hwangjeyeong/.openclaw/workspace

# NEXUS 폴더 생성
mkdir NEXUS
cd NEXUS

# Git 초기화
git init
git config user.name "Hwang Jeyeong"
git config user.email "jeyeong@example.com"
```

**2단계: .gitignore 작성**
```
# .gitignore
.godot/
.vscode/
*.swp
*.swo
*~
.DS_Store
build/
dist/
*.exe
*.elf
*.so
*.dylib
*.a
*.o
*.su
*.gd.bak

# Godot
.godot/
export.cfg
*.tres.bak

# OS
.DS_Store
Thumbs.db

# 에디터
.vscode/
.idea/
*.code-workspace

# 임시 파일
*.log
temp/
tmp/
```

**3단계: 폴더 구조 생성**
```bash
# 주요 폴더 생성
mkdir -p Assets/{Models,Animations,Textures,Audio,UI}
mkdir -p Scripts/{Core,Combat,Martial,AI,World,UI,NPC,Quest,Progression,Utils}
mkdir -p Scenes/{Levels,Dungeons,Characters,UI,Boss}
mkdir -p Data/{MartialArts,NPCs,Quests,Enemies,Items,Levels}
mkdir -p Docs
mkdir -p Build/{Windows,Mac,Linux}
mkdir -p Tools
mkdir -p tests
```

**4단계: 초기 README 작성**
```markdown
# 🥋 NEXUS - 무술 창조 게임

## 프로젝트 정보
- **엔진:** Godot 4.2
- **장르:** 3D 액션 RPG
- **플레이타임:** 30-50시간
- **대상:** PC (Windows/Mac/Linux)

## 상태
🚀 **Week 1-2: 프로토타입 개발**

## 폴더 구조
- Assets/ : 게임 리소스 (모델, 텍스처, 음향)
- Scripts/ : 게임 로직 (GDScript)
- Scenes/ : Godot 씬
- Data/ : 게임 데이터 (JSON, CSV)
- Docs/ : 문서

## 개발 타임라인
- Week 1-2: 엔진 & 기초 (0% → 20%)
- Week 3-4: 그래픽 & 애니메이션 (20% → 35%)
- Week 5-6: 콘텐츠 폭발 (35% → 60%)
- Week 7-8: 심화 & 엔드게임 (60% → 80%)
- Week 9-10: 최적화 & 폴리시 (80% → 95%)
- Week 11-12: 최종 폴리시 & 출시 (95% → 100%)

## 참고 문서
- GDD_OPTION2_FINAL.md : 게임 설계
- ROADMAP_12WEEKS_TIGHT.md : 12주 로드맵
- PROJECT_STRUCTURE.md : 프로젝트 구조
```

**체크리스트:**
- [ ] NEXUS 폴더 생성
- [ ] Git 초기화
- [ ] .gitignore 작성
- [ ] 폴더 구조 생성 완료
- [ ] README.md 작성
- [ ] 첫 커밋: `git add .` → `git commit -m "initial commit"`

---

### Task 3: Godot 프로젝트 초기화 (30분)

**1단계: Godot 프로젝트 생성**
```bash
# Godot를 열어서
# New Project → 
# - Project path: /Users/hwangjeyeong/.openclaw/workspace/NEXUS
# - Renderer: Forward+ (권장)
# - Create & Edit
```

**2단계: 프로젝트 기본 설정**
- Godot 에디터에서:
  - Project → Project Settings
  - Display → Window:
    - Width: 1920
    - Height: 1080
  - Physics → 3D:
    - Use ThreadedPhysics 체크 (멀티스레드)
  - Rendering:
    - Textures → VRAM Compression → Enable (권장)

**3단계: 씬 생성**
```
# 기본 씬 생성:
res:// (root)
├── Main.tscn (메인 씬)
├── MainMenu.tscn (메인 메뉴)
└── Combat Test.tscn (전투 테스트)
```

**Godot 추천 설정:**
```
Project Settings → GDScript → 
  - Editor → Script Templates Directory: res://scripts/templates
  - General → Warning/Error
```

**체크리스트:**
- [ ] Godot 프로젝트 생성 완료
- [ ] project.godot 파일 생성 확인
- [ ] 기본 설정 완료 (화면 해상도, 물리)
- [ ] Main.tscn, MainMenu.tscn 생성

---

### Task 4: 핵심 클래스 설계서 작성 (1시간)

**문서:** `Docs/CLASS_DESIGN.md` 생성

```markdown
# 핵심 클래스 설계

## 1. MartialArt (무술 데이터 클래스)

### 역할
무술 하나의 데이터를 표현한다.

### 속성
- id: String (고유 ID)
- name: String (무술 이름, 예: "Tiger Claw")
- base_movement: String (기본 동작, 예: "punch")
- tempo: String (Fast / Mid / Slow)
- defense_type: String (회피 / 가드 / 상쇄 / 카운터)
- defense_level: int (1-5, 방어 강도)
- energy_cost: int (1-10, 에너지 소비)
- power: float (1.0-5.0, 위력 배수)
- reach: float (1.0-3.0, 리치)
- effect: String (기절 / 경직 / 다운 / 화염 / 빙결 / None)
- effect_chance: float (0.0-1.0, 확률)

### 메서드
- deal_damage(stats: Dictionary) -> int
  - STR, DEX 스탯과 무술 데이터를 받아 데미지 계산
  - 반환: 최종 데미지

### 예제
```gdscript
var art = MartialArt.new()
art.name = "Tiger Claw"
art.base_movement = "claw"
art.energy_cost = 3
art.power = 1.5
damage = art.deal_damage({"STR": 10, "DEX": 8})
```

---

## 2. Player (플레이어 캐릭터)

### 역할
플레이어를 조종한다.

### 속성
- stats: Dictionary
  - STR, DEX, CON, INT, WIS, CHA (각 1-20)
- hp: int (최대값은 CON × 10)
- energy: int (최대값은 CON × 10)
- level: int (1-60)
- experience: int
- martial_arts: Array[MartialArt] (5개 슬롯)
- inventory: Inventory
- position: Vector3
- rotation: Vector3

### 메서드
- take_damage(damage: int) -> void
- recover_energy(amount: int) -> void
- use_martial_art(slot: int) -> void
- level_up() -> void
- get_stat(stat_name: String) -> int

### 상태 머신
- Idle (대기)
- Moving (이동)
- Attacking (공격)
- Hit (피해)
- Dead (죽음)

---

## 3. Enemy (적 베이스 클래스)

### 역할
모든 적의 기본 클래스다.

### 속성
- stats: Dictionary (STR, DEX 등)
- hp: int
- level: int
- ai_level: int (1-4)
- martial_arts: Array[MartialArt]
- position: Vector3

### 메서드
- take_damage(damage: int) -> void
- choose_action() -> MartialArt
- update_ai() -> void

### 상속 클래스
- EnemyAnimal (Level 1)
- EnemyMartialArtist (Level 2)
- EnemyBoss (Level 3-4)

---

## 4. MartialArtEngine (무술 생성 엔진)

### 역할
무술을 생성하고 관리한다.

### 속성
- base_movements: Array (100가지)
- tempos: Array (["Fast", "Mid", "Slow"])
- defense_types: Array (["회피", "가드", "상쇄", "카운터"])
- defense_levels: Array ([1, 2, 3, 4, 5])
- effects: Array (20가지 특수 효과)
- martial_arts_db: Dictionary (생성된 모든 무술)

### 메서드
- generate_martial_art(difficulty: int = 1) -> MartialArt
  - 난이도에 맞는 무술 생성
  - 난이도 1-10 (1=약함, 10=강함)

- get_martial_art(id: String) -> MartialArt
  - ID로 무술 검색

- save_martial_arts() -> void
  - 무술 데이터베이스를 JSON으로 저장

- load_martial_arts() -> void
  - JSON에서 무술 로드

### 예제
```gdscript
var engine = MartialArtEngine.new()
engine.load_martial_arts()

var art = engine.generate_martial_art(difficulty=3)
print(art.name)  # 예: "Shadow Kick"
```

---

## 5. CombatSystem (전투 시스템)

### 역할
플레이어와 적 간의 전투를 관리한다.

### 메서드
- calculate_damage(attacker_stats: Dictionary, martial_art: MartialArt, defender_stats: Dictionary) -> int
  - 기본 공식: 데미지 = (STR × 무술파워 + DEX × 크리티컬) × 상성

- execute_attack(attacker: Node, slot: int, defender: Node) -> void
  - 공격 실행

- apply_effect(target: Node, effect: String, chance: float) -> void
  - 상태이상 적용

### 예제
```gdscript
var combat = CombatSystem.new()
var damage = combat.calculate_damage(
  player.stats,
  player.martial_arts[0],
  enemy.stats
)
```

---

## 6. AIController (AI 기본 클래스)

### 역할
적의 행동을 제어한다.

### 상태 머신
- Idle (대기)
- Chase (추격)
- Attack (공격)
- Flee (도망)

### 메서드
- update() -> void
  - AI 매 프레임 업데이트

- decide_action() -> MartialArt
  - 다음 행동 결정

### 난이도별 구현
- **Level 1 (동물형):** 
  - 기본 공격만, 추격 후 공격

- **Level 2 (기초 무술사):**
  - 무술 3-4개 사용
  - 패턴 감지 (같은 공격 반복 시 피함)
  - 회피/방어 사용

- **Level 3 (고급 무술사):**
  - 무술 5-8개
  - 약점 적응
  - 보스 패턴 (Phase 변화)

- **Level 4 (마스터):**
  - 무술 10+개
  - 완벽한 적응
  - 멀티페이즈 보스

---

## 7. Map (맵 관리)

### 역할
현재 지역(Region)을 관리한다.

### 속성
- size: Vector2 (500 × 500)
- spawner: Spawner (적 스폰)
- npcs: Array[NPC]
- dungeons: Array[Dungeon]

### 메서드
- load_region(region_name: String) -> void
- spawn_enemies() -> void
- get_nearby_enemies(position: Vector3, radius: float) -> Array[Enemy]

---

## 8. Dungeon (던전)

### 역할
개별 던전을 관리한다.

### 속성
- id: String
- region: String
- difficulty: int (1-40)
- rooms: Array[DungeonRoom]
- boss: Enemy

### 메서드
- enter() -> void
- exit() -> void
- is_cleared() -> bool

---

## 데이터 흐름

```
Player.gd
  ├─ stats (STR, DEX, ...)
  ├─ martial_arts[0-4] → MartialArt
  └─ CombatSystem
      ├─ calculate_damage()
      └─ apply_effect()

Enemy.gd
  ├─ stats
  ├─ martial_arts[0-n]
  └─ AIController
      ├─ decide_action()
      └─ update_state()

MartialArtEngine
  ├─ base_movements (100)
  ├─ tempos (3)
  ├─ effects (20)
  └─ generate_martial_art()

Map
  ├─ Spawner → Enemy 생성
  ├─ Dungeon[0-n]
  │   └─ DungeonRoom → Enemy 배치
  └─ NPC[0-n]
```

---

## 우선순위 구현 순서

### 우선순위 1 (반드시)
1. MartialArt 클래스
2. MartialArtEngine
3. Player 클래스
4. CombatSystem
5. Enemy 클래스

### 우선순위 2 (중요)
6. AIController (Level 1-2)
7. Map & Dungeon
8. UI (HUD, 무술 관리)

### 우선순위 3 (나중)
9. NPC & Quest
10. Progression & SaveGame
```

**파일 생성:**
- [ ] Docs/CLASS_DESIGN.md 작성 완료

---

### Task 5: 데이터 포맷 정의 (1.5시간)

**문서:** `Docs/DATA_FORMAT.md` 생성

```markdown
# 데이터 포맷 정의

## 1. 무술 데이터 (MartialArt)

### JSON 스키마
```json
{
  "id": "tiger_claw",
  "name": "Tiger Claw",
  "base_movement": "claw",
  "tempo": "fast",
  "defense_type": "dodge",
  "defense_level": 2,
  "energy_cost": 3,
  "power": 1.5,
  "reach": 1.8,
  "effect": "stun",
  "effect_chance": 0.3,
  "description": "빠른 호랑이 발톱 공격"
}
```

### 기본 동작 (Base Movement) - 100가지
```json
{
  "id": "punch",
  "name": "Punch",
  "body_part": "hand",
  "reach_modifier": 1.0,
  "animation": "punch_basic"
}
```

### 특수 효과 (Effects) - 20가지
```json
[
  "stun",      // 기절 (2초)
  "knockdown",  // 다운 (3초)
  "burn",      // 화염 (5초)
  "freeze",    // 빙결 (3초)
  "bleed",     // 출혈 (5초)
  ...
]
```

---

## 2. 적 데이터 (Enemy Type)

```json
{
  "id": "wolf",
  "name": "Wolf",
  "level": 1,
  "experience": 50,
  "hp": 20,
  "stats": {
    "STR": 5,
    "DEX": 8,
    "CON": 4,
    "INT": 2,
    "WIS": 3,
    "CHA": 2
  },
  "martial_arts": ["bite_basic", "dash"],
  "ai_level": 1,
  "drop_table": [
    {
      "item": "martial_fragment",
      "chance": 0.3,
      "amount": 1
    }
  ]
}
```

---

## 3. NPC 데이터

```json
{
  "id": "master_zhang",
  "name": "Master Zhang",
  "region": "Zhongyuan",
  "type": "martial_art_master",
  "dialogue": "Welcome to the dojo!",
  "quests": ["quest_001", "quest_002"]
}
```

---

## 4. 퀘스트 데이터

```json
{
  "id": "quest_001",
  "name": "First Steps",
  "giver": "master_zhang",
  "description": "Learn 3 basic martial arts",
  "objectives": [
    {
      "type": "learn_martial_art",
      "target": 3
    }
  ],
  "rewards": {
    "experience": 100,
    "gold": 50,
    "martial_fragments": 5
  }
}
```

---

## 5. 아이템 데이터

```json
{
  "id": "sword_iron",
  "name": "Iron Sword",
  "type": "weapon",
  "rarity": "common",
  "stats": {
    "STR": 2,
    "DEX": 1
  },
  "value": 100
}
```

---

## GDScript 연동

### 파일 로드 함수
```gdscript
func load_json(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        print("Error loading file: ", path)
        return {}
    var json = JSON.new()
    return json.parse_string(file.get_as_text())

# 사용 예
var martial_arts_data = load_json("res://Data/MartialArts/martial_arts.json")
```

### 파일 저장 함수
```gdscript
func save_json(path: String, data: Dictionary) -> bool:
    var json = JSON.stringify(data)
    var file = FileAccess.open(path, FileAccess.WRITE)
    file.store_string(json)
    return true
```
```

**파일 생성:**
- [ ] Docs/DATA_FORMAT.md 작성 완료

---

### Task 6: 첫 커밋 & 검증 (30분)

```bash
# 현재 상태 확인
git status

# 모든 파일 스테이지
git add .

# 커밋
git commit -m "Initial project setup: Godot 4.2, project structure, documentation"

# 로그 확인
git log --oneline
```

**체크리스트:**
- [ ] Git 커밋 완료
- [ ] GitHub (또는 로컬 Git) 연결 (선택)
- [ ] Godot 프로젝트 정상 작동

---

## Day 1 완료 체크리스트

- ✅ Godot 4.2 설치 & 확인
- ✅ 프로젝트 폴더 구조 생성
- ✅ Git 초기화 & .gitignore 작성
- ✅ Godot 프로젝트 생성
- ✅ 핵심 클래스 설계서 (CLASS_DESIGN.md)
- ✅ 데이터 포맷 정의서 (DATA_FORMAT.md)
- ✅ 첫 Git 커밋

**예상 완료 시간:** 5시간 ✅

---

## 📋 Day 2 (2026-05-08, 목요일) - 5시간

### Task 1: GDScript 코드 템플릿 생성 (30분)

**MartialArt 클래스 템플릿**

파일: `Scripts/Martial/MartialArt.gd`

```gdscript
# 무술 데이터 클래스
# 역할: 무술 하나를 표현한다

class_name MartialArt
extends Resource

# 기본 정보
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""

# 무술 구성
@export var base_movement: String = ""  # punch, kick, claw, etc.
@export var tempo: String = "mid"  # fast, mid, slow
@export var defense_type: String = "dodge"  # dodge, guard, counter, etc.
@export var defense_level: int = 1  # 1-5

# 수치
@export var energy_cost: int = 1  # 1-10
@export var power: float = 1.0  # 위력 배수 (1.0-5.0)
@export var reach: float = 1.0  # 리치 배수 (1.0-3.0)
@export var hit_frames: int = 15  # 판정 프레임 수 (60fps 기준)

# 추가 효과
@export var effect: String = ""  # stun, knock_down, burn, etc.
@export var effect_chance: float = 0.0  # 확률 (0.0-1.0)

# 메타 정보
@export var animation_name: String = ""
@export var sound_effect: String = ""

func _init(p_id: String = "", p_name: String = "") -> void:
    id = p_id
    name = p_name

# 데미지 계산
func calculate_damage(stats: Dictionary) -> int:
    var base_damage = power * (stats.get("STR", 10) + stats.get("DEX", 10) / 2)
    var critical = 1.0 + (stats.get("DEX", 10) / 100.0)
    return int(base_damage * critical)

# 데이터 문자열 표현
func _to_string() -> String:
    return "[MartialArt %s: %s (Cost: %d, Power: %.1f)]" % [id, name, energy_cost, power]

# JSON 변환
func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": name,
        "description": description,
        "base_movement": base_movement,
        "tempo": tempo,
        "defense_type": defense_type,
        "defense_level": defense_level,
        "energy_cost": energy_cost,
        "power": power,
        "reach": reach,
        "hit_frames": hit_frames,
        "effect": effect,
        "effect_chance": effect_chance,
        "animation_name": animation_name,
        "sound_effect": sound_effect
    }

func from_dict(data: Dictionary) -> void:
    for key in data.keys():
        if key in ["id", "name", "description", "base_movement", "tempo", "defense_type", "animation_name", "sound_effect"]:
            set(key, data[key])
        elif key in ["energy_cost", "defense_level", "hit_frames"]:
            set(key, int(data[key]))
        elif key in ["power", "reach", "effect_chance"]:
            set(key, float(data[key]))
        else:
            set(key, data[key])
```

**체크리스트:**
- [ ] Scripts/Martial/MartialArt.gd 작성 완료
- [ ] Godot에서 파일 생성 후 탭에서 열기

---

### Task 2: Player 클래스 스켈레톤 (1시간)

파일: `Scripts/Combat/Player.gd`

```gdscript
# 플레이어 캐릭터
class_name Player
extends CharacterBody3D

# 스탯
var stats: Dictionary = {
    "STR": 10,
    "DEX": 10,
    "CON": 10,
    "INT": 10,
    "WIS": 10,
    "CHA": 10
}

# 상태
var hp: int = 100
var max_hp: int = 100
var energy: int = 100
var max_energy: int = 100
var level: int = 1
var experience: int = 0

# 무술 슬롯
var martial_arts: Array[MartialArt] = []
var selected_slot: int = 0

# 위치 & 회전
var move_speed: float = 5.0
var current_state: String = "idle"

func _ready() -> void:
    max_hp = stats["CON"] * 10
    max_energy = stats["CON"] * 10
    hp = max_hp
    energy = max_energy
    
    # 초기 무술 5개 슬롯 생성
    for i in range(5):
        martial_arts.append(null)

func _process(delta: float) -> void:
    if current_state == "idle":
        _handle_input()
    
    # 에너지 회복 (대기 중일 때)
    if current_state == "idle":
        energy = min(energy + 10 * delta, max_energy)

func _handle_input() -> void:
    # 이동
    var direction = Vector3.ZERO
    if Input.is_action_pressed("ui_up"):
        direction.z -= 1
    if Input.is_action_pressed("ui_down"):
        direction.z += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    
    if direction.length() > 0:
        direction = direction.normalized()
        velocity = direction * move_speed
        current_state = "moving"
    else:
        velocity = Vector3.ZERO
        current_state = "idle"
    
    move_and_slide()
    
    # 무술 입력
    if Input.is_action_just_pressed("attack_slot_1"):
        use_martial_art(0)
    if Input.is_action_just_pressed("attack_slot_2"):
        use_martial_art(1)
    if Input.is_action_just_pressed("attack_slot_3"):
        use_martial_art(2)
    if Input.is_action_just_pressed("attack_slot_4"):
        use_martial_art(3)
    if Input.is_action_just_pressed("attack_slot_5"):
        use_martial_art(4)

func use_martial_art(slot: int) -> void:
    if slot < 0 or slot >= martial_arts.size():
        return
    
    var art = martial_arts[slot]
    if art == null:
        return
    
    # 에너지 확인
    if energy < art.energy_cost:
        print("Not enough energy!")
        return
    
    # 에너지 소비
    energy -= art.energy_cost
    
    # 공격 실행 (아직 구현 안 함)
    print("Using martial art: %s" % art.name)
    current_state = "attacking"

func take_damage(damage: int) -> void:
    hp -= damage
    if hp <= 0:
        hp = 0
        die()

func recover_hp(amount: int) -> void:
    hp = min(hp + amount, max_hp)

func recover_energy(amount: int) -> void:
    energy = min(energy + amount, max_energy)

func level_up() -> void:
    level += 1
    # 스탯 상향 (스킬 포인트는 나중)
    stats["STR"] += 1
    stats["DEX"] += 1
    stats["CON"] += 1
    max_hp = stats["CON"] * 10
    max_energy = stats["CON"] * 10

func die() -> void:
    print("Player died!")
    current_state = "dead"

# 무술 장착
func equip_martial_art(martial_art: MartialArt, slot: int) -> void:
    if slot < 0 or slot >= 5:
        return
    martial_arts[slot] = martial_art

# 입력 맵핑 설정 함수
func setup_input_map() -> void:
    # Godot 에디터에서 설정해도 되지만, 코드로도 가능
    var actions = [
        "attack_slot_1",
        "attack_slot_2",
        "attack_slot_3",
        "attack_slot_4",
        "attack_slot_5"
    ]
    
    for action in actions:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
    
    # 키 바인딩
    var keymap = {
        "attack_slot_1": KEY_1,
        "attack_slot_2": KEY_2,
        "attack_slot_3": KEY_3,
        "attack_slot_4": KEY_4,
        "attack_slot_5": KEY_5,
    }
    
    for action in keymap.keys():
        var event = InputEventKey.new()
        event.physical_keycode = keymap[action]
        InputMap.action_add_event(action, event)
```

**체크리스트:**
- [ ] Scripts/Combat/Player.gd 작성 완료
- [ ] 컴파일 에러 없는지 확인

---

### Task 3: Enemy 클래스 스켈레톤 (45분)

파일: `Scripts/Combat/Enemy.gd`

```gdscript
# 적 베이스 클래스
class_name Enemy
extends CharacterBody3D

# 스탯
var stats: Dictionary = {
    "STR": 5,
    "DEX": 5,
    "CON": 5,
    "INT": 2,
    "WIS": 2,
    "CHA": 1
}

# 상태
var hp: int = 20
var max_hp: int = 20
var level: int = 1
var ai_level: int = 1  # 1-4

# 무술
var martial_arts: Array[MartialArt] = []

# AI 상태
var current_state: String = "idle"
var target: Player = null
var move_speed: float = 3.0
var detection_range: float = 10.0
var attack_range: float = 2.0

func _ready() -> void:
    max_hp = stats["CON"] * 5
    hp = max_hp

func _process(delta: float) -> void:
    match current_state:
        "idle":
            _ai_idle()
        "chase":
            _ai_chase(delta)
        "attack":
            _ai_attack()
        "dead":
            _ai_dead()

func _ai_idle() -> void:
    # 주변에 플레이어가 있는가?
    if target == null:
        return
    
    var distance = global_position.distance_to(target.global_position)
    if distance < detection_range:
        current_state = "chase"

func _ai_chase(delta: float) -> void:
    if target == null:
        current_state = "idle"
        return
    
    var distance = global_position.distance_to(target.global_position)
    
    if distance < attack_range:
        current_state = "attack"
    else:
        # 플레이어를 향해 이동
        var direction = (target.global_position - global_position).normalized()
        velocity = direction * move_speed
        move_and_slide()

func _ai_attack() -> void:
    if target == null:
        current_state = "idle"
        return
    
    var distance = global_position.distance_to(target.global_position)
    
    if distance > attack_range * 1.5:
        current_state = "chase"
    else:
        # 공격 (무술 선택)
        if martial_arts.size() > 0:
            var art = martial_arts[randi() % martial_arts.size()]
            attack_target(art)

func attack_target(art: MartialArt) -> void:
    if target == null:
        return
    
    var damage = art.calculate_damage(stats)
    target.take_damage(damage)
    print("Enemy attacks with %s, damage: %d" % [art.name, damage])

func _ai_dead() -> void:
    pass  # 나중에 구현

func take_damage(damage: int) -> void:
    hp -= damage
    print("Enemy takes damage: %d, remaining HP: %d" % [damage, hp])
    
    if hp <= 0:
        hp = 0
        current_state = "dead"
        die()

func die() -> void:
    print("Enemy died!")
    # 나중: 드롭, 경험치 등

# 무술 추가
func add_martial_art(art: MartialArt) -> void:
    martial_arts.append(art)

# 목표 설정
func set_target(player: Player) -> void:
    target = player
```

**체크리스트:**
- [ ] Scripts/Combat/Enemy.gd 작성 완료

---

### Task 4: MartialArtEngine 스켈레톤 (1시간)

파일: `Scripts/Martial/MartialArtEngine.gd`

```gdscript
# 무술 생성 엔진
class_name MartialArtEngine
extends Node

# 데이터베이스
var base_movements: Array[String] = []  # 100가지
var tempos: Array[String] = ["fast", "mid", "slow"]
var defense_types: Array[String] = ["dodge", "guard", "counter", "parry"]
var effects: Array[String] = ["stun", "knock_down", "burn", "freeze", "bleed"]

# 생성된 무술 저장소
var martial_arts_db: Dictionary = {}

func _ready() -> void:
    # 초기 데이터 로드
    load_martial_arts()

# 무술 생성 (난이도 기반)
func generate_martial_art(difficulty: int = 1) -> MartialArt:
    # 난이도 1-10 (높을수록 강함)
    var art = MartialArt.new()
    
    # 기본 설정
    art.id = "martial_%d_%d" % [difficulty, randi()]
    art.name = _generate_name(difficulty)
    art.base_movement = base_movements[randi() % base_movements.size()] if base_movements.size() > 0 else "punch"
    art.tempo = tempos[randi() % tempos.size()]
    art.defense_type = defense_types[randi() % defense_types.size()]
    art.defense_level = clampi(randi_range(1, difficulty + 2), 1, 5)
    
    # 수치 (난이도와 연동)
    art.energy_cost = clampi(difficulty, 1, 10)
    art.power = 1.0 + (difficulty / 10.0)
    art.reach = 1.0 + (difficulty / 20.0)
    
    # 특수 효과
    if randf() > (1.0 - difficulty / 20.0):  # 난이도가 높을수록 확률 상향
        art.effect = effects[randi() % effects.size()]
        art.effect_chance = 0.1 * difficulty
    
    # 저장
    martial_arts_db[art.id] = art
    
    return art

# 이름 생성 (난이도별)
func _generate_name(difficulty: int) -> String:
    var prefixes = ["", "Shadow", "Golden", "Dark", "Swift", "Mighty"]
    var names = ["Punch", "Kick", "Claw", "Palm", "Strike", "Slash"]
    var suffixes = ["", " Technique", " Style", " Arts", " Form"]
    
    var prefix = prefixes[randi() % prefixes.size()]
    var name = names[randi() % names.size()]
    var suffix = suffixes[randi() % suffixes.size()]
    
    return "%s %s %s" % [prefix, name, suffix]

# 무술 검색
func get_martial_art(id: String) -> MartialArt:
    if id in martial_arts_db:
        return martial_arts_db[id]
    return null

# 무술 데이터베이스 로드
func load_martial_arts() -> void:
    # 기본 동작 100가지 로드
    var base_movements_file = "res://Data/MartialArts/base_movements.json"
    if ResourceLoader.exists(base_movements_file):
        var data = _load_json(base_movements_file)
        if data is Array:
            for item in data:
                if "name" in item:
                    base_movements.append(item["name"])
    
    # 기본 무술 데이터 로드
    var martial_arts_file = "res://Data/MartialArts/martial_arts.json"
    if ResourceLoader.exists(martial_arts_file):
        var data = _load_json(martial_arts_file)
        if data is Array:
            for item in data:
                var art = MartialArt.new()
                art.from_dict(item)
                martial_arts_db[art.id] = art

# 무술 데이터 저장
func save_martial_arts() -> void:
    var data: Array[Dictionary] = []
    for art in martial_arts_db.values():
        data.append(art.to_dict())
    
    var path = "res://Data/MartialArts/martial_arts.json"
    _save_json(path, data)

# JSON 파일 로드
func _load_json(path: String):
    if not ResourceLoader.exists(path):
        return null
    
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        print("Error loading file: ", path)
        return null
    
    var json = JSON.new()
    var result = json.parse_string(file.get_as_text())
    return result

# JSON 파일 저장
func _save_json(path: String, data) -> bool:
    var json_string = JSON.stringify(data)
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        print("Error saving file: ", path)
        return false
    
    file.store_string(json_string)
    return true

# 무술 목록 반환
func get_all_martial_arts() -> Array[MartialArt]:
    var arts: Array[MartialArt] = []
    for art in martial_arts_db.values():
        arts.append(art)
    return arts
```

**체크리스트:**
- [ ] Scripts/Martial/MartialArtEngine.gd 작성 완료

---

### Task 5: CombatSystem 스켈레톤 (45분)

파일: `Scripts/Combat/CombatSystem.gd`

```gdscript
# 전투 시스템
class_name CombatSystem
extends Node

# 싱글톤 (옵션)
static var instance: CombatSystem

func _ready() -> void:
    if instance == null:
        instance = self

# 데미지 계산
func calculate_damage(attacker_stats: Dictionary, martial_art: MartialArt, defender_stats: Dictionary) -> int:
    # 기본 공식: 데미지 = (STR × 무술파워 + DEX × 크리티컬) × 상성
    var base_damage = martial_art.power * (attacker_stats.get("STR", 10) + attacker_stats.get("DEX", 10) / 2.0)
    
    # 크리티컬
    var crit_multiplier = 1.0 + (attacker_stats.get("DEX", 10) / 100.0)
    if randf() < crit_multiplier * 0.1:  # 크리티컬 10% 확률 + DEX
        crit_multiplier *= 1.5
    
    # 방어 감소
    var defense = defender_stats.get("CON", 10) * 0.5
    var final_damage = base_damage * crit_multiplier - defense
    
    return maxi(int(final_damage), 1)  # 최소 1 데미지

# 공격 실행
func execute_attack(attacker: Node, martial_art: MartialArt, defender: Node) -> void:
    if not (attacker is Player or attacker is Enemy):
        return
    
    if not (defender is Player or defender is Enemy):
        return
    
    var damage = calculate_damage(attacker.stats, martial_art, defender.stats)
    defender.take_damage(damage)
    
    # 특수 효과 적용
    if martial_art.effect != "" and martial_art.effect_chance > 0:
        apply_effect(defender, martial_art.effect, martial_art.effect_chance)

# 특수 효과 적용
func apply_effect(target: Node, effect: String, chance: float) -> void:
    if randf() > chance:
        return
    
    match effect:
        "stun":
            print("Target is stunned!")
            # 나중: 상태이상 시스템
        "knock_down":
            print("Target is knocked down!")
        "burn":
            print("Target is burned!")
        "freeze":
            print("Target is frozen!")
        "bleed":
            print("Target is bleeding!")

# 전투 종료
func end_combat(winner: Node, loser: Node) -> void:
    print("Combat ended! Winner: ", winner, " Loser: ", loser)
```

**체크리스트:**
- [ ] Scripts/Combat/CombatSystem.gd 작성 완료

---

### Task 6: 테스트 씬 생성 (1시간)

**씬 이름:** `Scenes/CombatTest.tscn`

**Godot 에디터에서:**

1. `새 씬 생성` → `Node3D` (루트)
2. 이름: `CombatTest`
3. 하위 노드 추가:
   - `Player` (Node3D → Player.gd 스크립트 할당)
   - `Enemy` (Node3D → Enemy.gd 스크립트 할당)
   - `CombatSystem` (Node → CombatSystem.gd 스크립트 할당)
   - `Camera3D` (카메라 설정)
   - `DirectionalLight3D` (조명)

**GDScript 씬 초기화 코드:**

파일: `Scenes/CombatTest.gd`

```gdscript
extends Node3D

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy
@onready var combat_system: CombatSystem = $CombatSystem
@onready var camera: Camera3D = $Camera3D
@onready var light: DirectionalLight3D = $DirectionalLight3D

func _ready() -> void:
    # 플레이어 초기화
    player.position = Vector3(0, 1, 0)
    player.setup_input_map()
    
    # 적 초기화
    enemy.position = Vector3(5, 1, 0)
    enemy.set_target(player)
    
    # 무술 엔진 로드
    var engine = MartialArtEngine.new()
    engine.load_martial_arts()
    
    # 기본 무술 할당 (임시)
    var basic_punch = MartialArt.new()
    basic_punch.id = "punch_basic"
    basic_punch.name = "Basic Punch"
    basic_punch.power = 1.0
    basic_punch.energy_cost = 2
    
    player.equip_martial_art(basic_punch, 0)
    enemy.add_martial_art(basic_punch)
    
    # 카메라 설정
    camera.position = Vector3(-10, 3, 5)
    camera.look_at(Vector3(0, 1, 0), Vector3.UP)
    
    # 조명 설정
    light.rotation_degrees = Vector3(30, 45, 0)
    
    print("Combat test scene ready!")

func _process(delta: float) -> void:
    # 게임 상태 출력
    if Input.is_action_just_pressed("ui_accept"):
        print("Player HP: %d/%d, Energy: %d/%d" % [player.hp, player.max_hp, player.energy, player.max_energy])
        print("Enemy HP: %d/%d" % [enemy.hp, enemy.max_hp])
```

**체크리스트:**
- [ ] Scenes/CombatTest.tscn 씬 생성
- [ ] 노드 계층 확인
- [ ] 스크립트 할당 확인

---

### Task 7: 최초 테스트 실행 (30분)

**Godot 에디터에서:**

1. `Scenes/CombatTest.tscn` 열기
2. ▶️ 실행 버튼 클릭 (또는 F5)
3. 확인할 사항:
   - 게임 창이 열리는가?
   - 플레이어가 WASD로 이동하는가?
   - 숫자 1-5를 누르면 "Using martial art" 메시지가 나타나는가?
   - 콘솔에 디버그 메시지가 출력되는가?

**예상 로그:**
```
Combat test scene ready!
Player HP: 100/100, Energy: 100/100
Enemy HP: 20/20
Using martial art: Basic Punch
```

**버그 수정:**
- 에러 메시지가 나타나면 메모해두기
- 간단한 문제는 즉시 수정
- 복잡한 문제는 Day 3에 처리

**체크리스트:**
- [ ] 게임 실행 성공
- [ ] 기본 입력 작동 (WASD 이동, 1-5 공격)
- [ ] 콘솔 로그 출력 확인

---

### Task 8: 두 번째 Git 커밋 (15분)

```bash
# 상태 확인
git status

# 모든 파일 스테이지
git add .

# 커밋
git commit -m "Day 1: Core classes (MartialArt, Player, Enemy, CombatSystem, Engine), combat test scene"

# 로그 확인
git log --oneline -5
```

**체크리스트:**
- [ ] Git 커밋 완료

---

## Day 2 완료 체크리스트

- ✅ MartialArt 클래스 구현
- ✅ Player 클래스 구현
- ✅ Enemy 클래스 구현
- ✅ MartialArtEngine 기본 구현
- ✅ CombatSystem 기본 구현
- ✅ 테스트 씬 생성 & 실행
- ✅ 두 번째 커밋

**예상 완료 시간:** 5시간 ✅

---

## ✅ Week 1 Day 1-2 완료!

### 달성 사항:
1. ✅ Godot 4.2 프로젝트 완전 초기화
2. ✅ 프로젝트 폴더 구조 (Assets, Scripts, Scenes, Data, Docs)
3. ✅ Git 저장소 생성 & 초기 커밋
4. ✅ 핵심 클래스 설계 (CLASS_DESIGN.md)
5. ✅ 데이터 포맷 정의 (DATA_FORMAT.md)
6. ✅ MartialArt, Player, Enemy, CombatSystem, MartialArtEngine 구현
7. ✅ 테스트 씬 생성 & 동작 확인

### 다음 단계:
**Day 3-7:** 무술 엔진 고도화, 플레이어 전투 완성, 적 AI 강화, 첫 보스 구현

---

**Version:** 1.0  
**Timeline:** 2026-05-07 ~ 2026-05-08  
**Status:** 준비 완료, 개발 시작! 🔥
