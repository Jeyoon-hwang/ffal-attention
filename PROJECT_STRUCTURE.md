# 🏗️ NEXUS 프로젝트 구조

**초기 설정 완료일:** 2026-05-07  
**엔진:** Godot 4.2 (권장) 또는 Three.js (WebGL 대안)

---

## 디렉토리 구조

```
NEXUS/
│
├── 📁 Assets/                  # 게임 리소스
│   ├── 📁 Models/             # 3D 모델 (FBX, GLTF)
│   │   ├── Characters/        # 플레이어, NPC
│   │   ├── Monsters/          # 적, 보스
│   │   └── Environment/       # 맵, 건물, 자연물
│   │
│   ├── 📁 Animations/         # 애니메이션 (FBX, GLTF, 또는 Godot 씬)
│   │   ├── Character/         # 이동, 공격, 피해
│   │   ├── Monsters/          # 몬스터 특화
│   │   └── Boss/              # 보스 특수 애니메이션
│   │
│   ├── 📁 Textures/           # 텍스처 (PNG, TGA)
│   │   ├── Characters/
│   │   ├── Monsters/
│   │   ├── Environment/
│   │   └── UI/
│   │
│   ├── 📁 Audio/              # 오디오
│   │   ├── Music/             # 배경음
│   │   ├── SFX/               # 효과음
│   │   └── Voice/             # 음성 (나중)
│   │
│   └── 📁 UI/                 # UI 리소스
│       ├── Textures/          # UI 이미지
│       ├── Fonts/             # 폰트
│       └── Icons/             # 아이콘
│
├── 📁 Scripts/                 # 게임 로직 (GDScript 또는 C#)
│   ├── 📁 Core/               # 핵심 엔진
│   │   ├── GameManager.gd     # 게임 전역 관리
│   │   ├── SceneManager.gd    # 씬 전환
│   │   └── EventBus.gd        # 이벤트 시스템
│   │
│   ├── 📁 Combat/             # 전투 시스템
│   │   ├── Player.gd          # 플레이어 캐릭터
│   │   ├── Enemy.gd           # 적 베이스 클래스
│   │   ├── CombatSystem.gd    # 전투 로직
│   │   ├── DamageCalculator.gd  # 데미지 계산
│   │   └── Effects.gd         # 상태이상, 버프
│   │
│   ├── 📁 Martial/            # 무술 시스템
│   │   ├── MartialArt.gd      # 무술 데이터 클래스
│   │   ├── MartialArtEngine.gd  # 무술 생성 엔진
│   │   ├── MartialArtLibrary.gd # 무술 데이터베이스
│   │   └── SkillPoint.gd      # 스킬 포인트 강화
│   │
│   ├── 📁 AI/                 # 적 AI
│   │   ├── AIController.gd    # AI 기본
│   │   ├── AILevel1.gd        # 동물형
│   │   ├── AILevel2.gd        # 기초 무술사
│   │   ├── AILevel3.gd        # 고급 무술사
│   │   ├── AILevel4.gd        # 마스터
│   │   └── PatternManager.gd  # 패턴 관리
│   │
│   ├── 📁 World/              # 월드 & 맵
│   │   ├── Map.gd            # 맵 관리
│   │   ├── Dungeon.gd        # 던전 관리
│   │   ├── Spawner.gd        # 적 스폰 시스템
│   │   ├── Checkpoint.gd     # 체크포인트
│   │   └── Region.gd         # 지역 데이터
│   │
│   ├── 📁 UI/                 # 게임 UI
│   │   ├── HUD.gd            # 인게임 HUD (체력, 에너지)
│   │   ├── InventoryUI.gd    # 인벤토리
│   │   ├── MartialArtUI.gd   # 무술 관리 UI
│   │   ├── MenuUI.gd         # 메인 메뉴
│   │   ├── DialogueUI.gd     # 대사 UI
│   │   └── PauseMenu.gd      # 일시정지 메뉴
│   │
│   ├── 📁 NPC/                # NPC 시스템
│   │   ├── NPC.gd            # NPC 베이스
│   │   ├── QuestGiver.gd     # 퀘스트 제공자
│   │   ├── Merchant.gd       # 상인
│   │   └── MartialArtMaster.gd  # 무술관 마스터
│   │
│   ├── 📁 Quest/              # 퀘스트 시스템
│   │   ├── Quest.gd          # 퀘스트 데이터
│   │   ├── QuestManager.gd   # 퀘스트 관리
│   │   └── QuestLog.gd       # 퀘스트 로그
│   │
│   ├── 📁 Progression/        # 게임 진행
│   │   ├── Player.gd         # (위와 중복 가능)
│   │   ├── LevelUp.gd        # 레벨업 시스템
│   │   ├── Inventory.gd      # 인벤토리
│   │   └── SaveGame.gd       # 저장/로드
│   │
│   └── 📁 Utils/              # 유틸
│       ├── Logger.gd         # 로깅
│       ├── Helpers.gd        # 헬퍼 함수
│       └── Constants.gd      # 상수 정의
│
├── 📁 Scenes/                  # Godot 씬 파일
│   ├── 📁 Levels/
│   │   ├── Region_Zhongyuan.tscn   # 중원
│   │   ├── Region_Tianshan.tscn    # 천산
│   │   ├── Region_Desert.tscn      # 황무지
│   │   ├── Region_EastSea.tscn     # 동해
│   │   └── Region_BlackDragon.tscn # 흑룡굴
│   │
│   ├── 📁 Dungeons/
│   │   ├── Dungeon_01.tscn
│   │   └── Dungeon_[N].tscn
│   │
│   ├── 📁 Characters/
│   │   ├── Player.tscn
│   │   ├── Enemy.tscn
│   │   └── NPC.tscn
│   │
│   ├── 📁 UI/
│   │   ├── MainMenu.tscn
│   │   ├── HUD.tscn
│   │   ├── PauseMenu.tscn
│   │   └── DialogueBox.tscn
│   │
│   └── 📁 Boss/
│       ├── Boss_Zhongyuan.tscn     # 중원 보스
│       └── Boss_[N].tscn
│
├── 📁 Data/                    # 데이터 파일 (JSON, CSV)
│   ├── 📁 MartialArts/        # 무술 데이터
│   │   ├── base_movements.json   # 기본 동작
│   │   ├── tempos.json           # 리듬
│   │   ├── effects.json          # 효과
│   │   └── martial_arts.json     # 생성된 무술
│   │
│   ├── 📁 NPCs/
│   │   ├── npc_data.json       # NPC 정보
│   │   └── dialogues.json      # 대사
│   │
│   ├── 📁 Quests/
│   │   └── quests.json         # 퀨스트 데이터
│   │
│   ├── 📁 Enemies/
│   │   ├── enemy_types.json    # 적 타입
│   │   ├── boss_patterns.json  # 보스 패턴
│   │   └── ai_config.json      # AI 설정
│   │
│   ├── 📁 Items/
│   │   ├── equipment.json      # 장비
│   │   └── items.json          # 아이템
│   │
│   └── 📁 Levels/
│       ├── level_config.json   # 레벨 설정
│       └── spawn_points.json   # 스폰 포인트
│
├── 📁 Docs/                    # 문서
│   ├── GDD.md                  # 게임 설계 (이 파일)
│   ├── ROADMAP.md              # 로드맵
│   ├── DESIGN_NOTES.md         # 설계 노트
│   ├── API.md                  # API 문서
│   └── CHANGELOG.md            # 변경 로그
│
├── 📁 Build/                   # 빌드 결과물
│   ├── Windows/
│   ├── Mac/
│   └── Linux/
│
├── 📄 project.godot            # Godot 프로젝트 파일
├── 📄 .gitignore               # Git 무시 파일
├── 📄 README.md                # 프로젝트 소개
└── 📄 LICENSE                  # 라이선스
```

---

## 핵심 파일 설명

### Scripts/Core/GameManager.gd
```gd
# 게임 전역 상태 관리
extends Node

var player: Player
var current_map: Map
var current_dungeon: Dungeon
var save_data: Dictionary

func _ready():
    # 게임 초기화
    pass

func load_game():
    # 저장 파일 로드
    pass

func save_game():
    # 게임 저장
    pass
```

### Scripts/Combat/Player.gd
```gd
# 플레이어 캐릭터
extends CharacterBody3D

var stats: Dictionary = {
    "STR": 10,
    "DEX": 10,
    "CON": 10,
    "INT": 10,
    "WIS": 10,
    "CHA": 10
}

var hp: int = 100
var energy: int = 100
var max_energy: int = 100
var martial_arts: Array[MartialArt] = []

func take_damage(damage: int):
    hp -= damage
    if hp <= 0:
        die()

func use_martial_art(slot: int):
    var art = martial_arts[slot]
    if energy >= art.energy_cost:
        energy -= art.energy_cost
        # 공격 실행
        deal_damage(art)
```

### Scripts/Martial/MartialArtEngine.gd
```gd
# 무술 생성 엔진
extends Node

var base_movements: Array = []  # 100가지
var tempos: Array = ["Fast", "Mid", "Slow"]
var defense_types: Array = ["회피", "가드", "상쇄", "카운터"]
var effects: Array = []  # 20가지

func generate_martial_art() -> MartialArt:
    var art = MartialArt.new()
    art.base_movement = base_movements[randi() % base_movements.size()]
    art.tempo = tempos[randi() % tempos.size()]
    art.defense_type = defense_types[randi() % defense_types.size()]
    art.energy_cost = randi_range(1, 10)
    art.effect = effects[randi() % effects.size()] if randf() > 0.7 else null
    
    return art
```

### Scripts/AI/AIController.gd
```gd
# 적 AI 기본
extends Node

var enemy: Enemy
var state_machine: StateMachine

func _ready():
    state_machine = StateMachine.new()
    state_machine.add_state("idle", on_idle)
    state_machine.add_state("chase", on_chase)
    state_machine.add_state("attack", on_attack)
    state_machine.add_state("flee", on_flee)

func on_idle():
    # 대기
    pass

func on_chase():
    # 플레이어 추격
    pass

func on_attack():
    # 공격
    pass
```

---

## 데이터 파일 형식

### Data/MartialArts/base_movements.json
```json
[
  {
    "id": 0,
    "name": "Jab",
    "body_part": "hand",
    "reach": 1.5,
    "animation": "jab"
  },
  {
    "id": 1,
    "name": "Kick",
    "body_part": "foot",
    "reach": 2.0,
    "animation": "kick"
  }
  // ... 100가지
]
```

### Data/Enemies/enemy_types.json
```json
[
  {
    "id": "wolf",
    "name": "Wolf",
    "level": 1,
    "hp": 20,
    "stats": {
      "STR": 5,
      "DEX": 8
    },
    "martial_arts": ["basic_bite", "dash"],
    "ai_level": 1
  }
  // ...
]
```

---

## 개발 순서 (Week 1-2 집중)

### Day 1-2: 초기화
- [ ] Godot 프로젝트 생성
- [ ] 폴더 구조 생성
- [ ] .gitignore 설정
- [ ] README 작성
- [ ] 핵심 클래스 다이어그램

### Day 3-4: 무술 엔진
- [ ] MartialArt 클래스 구현
- [ ] MartialArtEngine 구현
- [ ] 데이터 파일 (base_movements.json 등) 작성
- [ ] 무술 로드 & 저장 테스트

### Day 5-6: 플레이어 & 전투
- [ ] Player 클래스 구현
- [ ] CombatSystem 구현
- [ ] 입력 처리 (마우스 클릭, 키입력)
- [ ] 데미지 계산 테스트

### Day 7-8: 적 & AI
- [ ] Enemy 베이스 클래스
- [ ] AIController Level 1-2
- [ ] 테스트 씬 (Player vs Enemy)

### Day 9-14: 보스 & 지역
- [ ] 첫 보스 구현
- [ ] 중원 맵 기본 구현
- [ ] 첫 던전 구현
- [ ] 무술관 NPC & 강화 시스템

---

## 다음 체크포인트

✅ **Day 2 말:** 프로젝트 초기화 완료  
✅ **Day 6 말:** 무술 엔진 & 플레이어 전투 동작  
✅ **Day 8 말:** 적 AI & 전투 테스트 완료  
✅ **Day 14 말:** 프로토타입 플레이 가능 (프로토타입 데모)

---

**Version:** 1.0  
**Created:** 2026-05-07  
**Status:** 구조 확정, 개발 준비 완료
