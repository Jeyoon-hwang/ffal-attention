# 📊 NEXUS 데이터 포맷 정의 (JSON Schemas)

**Document Version:** 1.0  
**Last Updated:** 2026-05-07  
**Format:** JSON (UTF-8)  

---

## 개요

NEXUS의 모든 게임 데이터는 JSON으로 저장되어 에디터에서 쉽게 수정 가능.

**저장 위치:**
- `Data/MartialArts/` - 무술 데이터
- `Data/NPCs/` - NPC 데이터
- `Data/Enemies/` - 적 데이터
- `Data/Quests/` - 퀘스트 데이터
- `Data/Items/` - 아이템 데이터
- `Data/Levels/` - 레벨 맵 데이터

---

## 1️⃣ 무술 (MartialArt)

### 파일: `Data/MartialArts/martial_arts.json`

```json
{
  "version": "1.0",
  "timestamp": "2026-05-07T10:56:00Z",
  "martial_arts": [
    {
      "id": "punch_001",
      "name": "기본 펀치",
      "description": "가장 기본적인 펀치",
      "type": "hand",
      "rarity": "common",
      
      "stats": {
        "base_power": 10,
        "energy_cost": 5,
        "cooldown": 0.0,
        "range": 2.0,
        "attack_speed": 1.0
      },
      
      "flags": {
        "is_combo": true,
        "max_combo_count": 3,
        "is_guard_breaking": false,
        "is_knockdown": false,
        "is_special": false
      },
      
      "effects": [
        {
          "type": "none",
          "duration": 0.0
        }
      ],
      
      "animation": {
        "name": "punch_01",
        "duration": 0.5,
        "hitbox_frame": 0.2
      },
      
      "learning": {
        "required_level": 1,
        "required_location": "starting_area",
        "teacher_npc_id": "master_yang"
      },
      
      "scaling": {
        "str_scaling": 0.8,
        "dex_scaling": 0.3,
        "int_scaling": 0.0
      }
    },
    
    {
      "id": "fire_kick_005",
      "name": "화염 회전차기",
      "description": "불을 피워 회전하며 차는 기술",
      "type": "foot",
      "rarity": "rare",
      
      "stats": {
        "base_power": 35,
        "energy_cost": 15,
        "cooldown": 3.0,
        "range": 4.5,
        "attack_speed": 0.8
      },
      
      "flags": {
        "is_combo": false,
        "max_combo_count": 1,
        "is_guard_breaking": true,
        "is_knockdown": true,
        "is_special": true
      },
      
      "effects": [
        {
          "type": "burn",
          "damage": 5,
          "duration": 3.0,
          "chance": 100
        },
        {
          "type": "knockdown",
          "duration": 2.0,
          "chance": 80
        }
      ],
      
      "animation": {
        "name": "fire_kick_rotational",
        "duration": 1.2,
        "hitbox_frames": [0.3, 0.6, 0.9]
      },
      
      "learning": {
        "required_level": 20,
        "required_fragments": 5,
        "required_location": "fire_temple"
      },
      
      "scaling": {
        "str_scaling": 0.6,
        "dex_scaling": 0.4,
        "int_scaling": 0.2
      }
    }
  ]
}
```

---

## 2️⃣ 플레이어 (Player Profile)

### 파일: `Data/save_game_001.json` (저장 파일)

```json
{
  "player": {
    "id": "player_001",
    "name": "무술인",
    "level": 15,
    "experience": 5000,
    "skill_points": 8,
    
    "stats": {
      "str": 12,
      "dex": 14,
      "con": 10,
      "int": 9,
      "wis": 11,
      "cha": 8
    },
    
    "life": {
      "max_hp": 120,
      "current_hp": 100,
      "max_energy": 120,
      "current_energy": 100,
      "max_spirit": 100,
      "current_spirit": 75
    },
    
    "martial_slots": [
      {
        "slot": 0,
        "martial_id": "punch_001",
        "level": 5,
        "mastery": 75
      },
      {
        "slot": 1,
        "martial_id": "kick_002",
        "level": 3,
        "mastery": 40
      },
      {
        "slot": 2,
        "martial_id": null,
        "level": 0,
        "mastery": 0
      },
      {
        "slot": 3,
        "martial_id": "fire_kick_005",
        "level": 1,
        "mastery": 10
      },
      {
        "slot": 4,
        "martial_id": null,
        "level": 0,
        "mastery": 0
      }
    ],
    
    "inventory": {
      "items": [
        {
          "item_id": "health_potion_001",
          "count": 5,
          "last_used": "2026-05-07T10:00:00Z"
        },
        {
          "item_id": "mana_crystal",
          "count": 2
        }
      ],
      "equipment": {
        "head": "iron_helmet_001",
        "chest": "leather_armor_001",
        "legs": "leather_pants_001",
        "feet": "boots_001",
        "hands": null,
        "weapon": "wooden_staff_001"
      }
    },
    
    "position": {
      "region": "central_plains",
      "x": 100.0,
      "y": 0.0,
      "z": 50.0,
      "direction": 0.0
    },
    
    "quests": {
      "active": ["quest_001", "quest_003"],
      "completed": ["quest_002"],
      "failed": []
    },
    
    "achievements": [
      {
        "id": "first_victory",
        "unlocked_at": "2026-05-06T15:30:00Z"
      }
    ],
    
    "playtime": 3600,
    "last_save": "2026-05-07T10:56:00Z"
  }
}
```

---

## 3️⃣ 적 (Enemy Data)

### 파일: `Data/Enemies/enemies.json`

```json
{
  "enemies": [
    {
      "id": "goblin_001",
      "name": "고블린 병사",
      "description": "약간의 무술을 아는 초급 적",
      "type": "goblin",
      "ai_level": 1,
      
      "stats": {
        "level": 3,
        "max_hp": 30,
        "max_energy": 30,
        "str": 6,
        "dex": 8,
        "con": 6,
        "int": 3,
        "wis": 3,
        "cha": 2
      },
      
      "martial_slots": [
        "punch_001",
        "kick_002"
      ],
      
      "rewards": {
        "experience": 100,
        "gold": 50,
        "drop_items": [
          {
            "item_id": "leather_scrap",
            "chance": 80,
            "quantity": 1
          },
          {
            "item_id": "iron_ore",
            "chance": 20,
            "quantity": 1
          }
        ]
      },
      
      "behavior": {
        "patrol_range": 10.0,
        "aggro_range": 15.0,
        "combat_retreat_hp": 0.2,
        "flee_distance": 20.0
      },
      
      "appearance": {
        "model": "models/goblin_soldier.glb",
        "scale": 0.9,
        "color": "00AA00"
      }
    },
    
    {
      "id": "boss_dragon_001",
      "name": "푸른 드래곤",
      "description": "최종 보스 - 하늘을 지배하던 고대 생물",
      "type": "dragon",
      "ai_level": 4,
      
      "stats": {
        "level": 40,
        "max_hp": 500,
        "max_energy": 400,
        "str": 25,
        "dex": 18,
        "con": 22,
        "int": 15,
        "wis": 14,
        "cha": 12
      },
      
      "martial_slots": [
        "claw_strike",
        "fire_breath",
        "ice_storm",
        "wing_beat"
      ],
      
      "phases": [
        {
          "phase": 1,
          "hp_range": [1.0, 0.7],
          "pattern_set": "aggressive",
          "speed_multiplier": 1.0
        },
        {
          "phase": 2,
          "hp_range": [0.7, 0.3],
          "pattern_set": "desperate",
          "speed_multiplier": 1.3
        },
        {
          "phase": 3,
          "hp_range": [0.3, 0.0],
          "pattern_set": "final",
          "speed_multiplier": 1.6
        }
      ],
      
      "rewards": {
        "experience": 5000,
        "gold": 2000,
        "drop_items": [
          {
            "item_id": "dragon_scale",
            "chance": 100,
            "quantity": 10
          },
          {
            "item_id": "ancient_skill_book",
            "chance": 50,
            "quantity": 1
          }
        ]
      },
      
      "behavior": {
        "patrol_range": 50.0,
        "aggro_range": 100.0,
        "combat_retreat_hp": 0.0,
        "phase_change_audio": "boss_roar"
      }
    }
  ]
}
```

---

## 4️⃣ NPC (비플레이어 캐릭터)

### 파일: `Data/NPCs/npcs.json`

```json
{
  "npcs": [
    {
      "id": "master_yang",
      "name": "양 대사",
      "description": "중원의 무술 대사, 플레이어의 스승",
      "type": "master",
      "location": "central_plains",
      "position": {
        "x": 50.0,
        "y": 0.0,
        "z": 50.0
      },
      
      "dialogue": [
        {
          "id": "greeting_001",
          "text": "안녕하게. 넌 무술을 배우고 싶구나?",
          "conditions": ["first_meeting"],
          "next_dialogue": ["greeting_002", "question_001"]
        },
        {
          "id": "greeting_002",
          "text": "좋다. 나는 양 대사라고 한다. 내가 너를 가르쳐주겠노라.",
          "conditions": ["greeting_001_seen"],
          "next_dialogue": ["teaching_001"]
        }
      ],
      
      "interactions": [
        {
          "type": "teach_martial",
          "martial_ids": ["punch_001", "kick_002", "palm_strike_001"],
          "required_level": 1,
          "required_gold": 0
        },
        {
          "type": "buy_items",
          "available_items": [
            {
              "item_id": "health_potion_001",
              "price": 50
            },
            {
              "item_id": "stamina_potion",
              "price": 75
            }
          ]
        }
      ],
      
      "quests": [
        {
          "quest_id": "quest_001",
          "title": "기초 무술 수련",
          "description": "10개의 펀치를 연습해보자"
        }
      ],
      
      "appearance": {
        "model": "models/master_yang.glb",
        "scale": 1.0,
        "animation_idle": "meditation"
      }
    }
  ]
}
```

---

## 5️⃣ 퀘스트 (Quest Data)

### 파일: `Data/Quests/quests.json`

```json
{
  "quests": [
    {
      "id": "quest_001",
      "title": "기초 무술 수련",
      "description": "양 대사에게서 기본 펀치를 배우자",
      "type": "main",
      "chapter": 1,
      
      "giver_npc": "master_yang",
      "giver_location": "central_plains",
      
      "objectives": [
        {
          "id": "obj_001",
          "type": "learn_martial",
          "martial_id": "punch_001",
          "description": "펀치 기술 배우기"
        },
        {
          "id": "obj_002",
          "type": "defeat_enemy",
          "enemy_id": "goblin_001",
          "count": 5,
          "description": "고블린 5마리 처치"
        }
      ],
      
      "rewards": {
        "experience": 500,
        "gold": 100,
        "items": [
          {
            "item_id": "health_potion_001",
            "quantity": 3
          }
        ],
        "skill_points": 2
      },
      
      "requirements": {
        "min_level": 1,
        "required_quests": [],
        "required_items": []
      },
      
      "flow": {
        "accepted_dialogue": "greeting_002",
        "progress_dialogue": "teaching_002",
        "completion_dialogue": "teaching_003"
      }
    }
  ]
}
```

---

## 6️⃣ 아이템 (Item Data)

### 파일: `Data/Items/items.json`

```json
{
  "items": [
    {
      "id": "health_potion_001",
      "name": "체력 포션",
      "description": "체력을 30 회복한다",
      "type": "consumable",
      "rarity": "common",
      
      "stats": {
        "healing": 30,
        "max_stack": 10
      },
      
      "pricing": {
        "buy_price": 50,
        "sell_price": 25
      }
    },
    
    {
      "id": "iron_helmet_001",
      "name": "철제 투구",
      "description": "기본적인 철제 투구, 약간의 방어력을 제공한다",
      "type": "equipment",
      "rarity": "common",
      "slot": "head",
      
      "stats": {
        "defense": 5,
        "con_bonus": 2
      },
      
      "requirements": {
        "min_level": 5,
        "str_requirement": 10
      }
    }
  ]
}
```

---

## 7️⃣ 레벨 (Level/Map Data)

### 파일: `Data/Levels/central_plains.json`

```json
{
  "level_id": "central_plains",
  "name": "중원",
  "description": "무술 학파의 중심지",
  "type": "open_world",
  
  "dimensions": {
    "width": 500,
    "height": 100,
    "depth": 500
  },
  
  "environment": {
    "terrain_type": "grass",
    "sky_color": "87CEEB",
    "ambient_light": 0.8,
    "music": "central_plains_theme"
  },
  
  "spawn_points": [
    {
      "id": "spawn_001",
      "position": [100, 0, 100],
      "type": "player"
    },
    {
      "id": "spawn_002",
      "position": [150, 0, 150],
      "enemy_type": "goblin",
      "count": 3,
      "respawn_time": 300
    }
  ],
  
  "buildings": [
    {
      "id": "dojo_001",
      "name": "도장",
      "position": [50, 0, 50],
      "model": "models/dojo.glb",
      "npcs": ["master_yang"],
      "dungeon_entrance": null
    },
    {
      "id": "cave_001",
      "name": "시작 동굴",
      "position": [200, 0, 200],
      "model": null,
      "dungeon_entrance": "dungeon_starting_cave"
    }
  ],
  
  "waypoints": [
    {
      "id": "wp_001",
      "position": [100, 0, 100],
      "name": "도장"
    },
    {
      "id": "wp_002",
      "position": [300, 0, 300],
      "name": "숲"
    }
  ]
}
```

---

## 일반 규칙

### 1. ID 포맷
```
[domain]_[type]_[number]
마술: martial_punch_001
NPC: npc_master_yang
아이템: item_health_potion_001
퀘스트: quest_main_001
```

### 2. 능력치 스케일
```
플레이어 능력치: 1-100 범위
적 능력치: 1-50 범위 (재스케일 가능)
```

### 3. 데미지 공식
```
데미지 = (능력치 × 스케일) + 무술파워 - 방어력
최소: 1
최대: 무제한 (밸런싱 필요)
```

---

## 데이터 로드/저장

### GDScript 예제

```gdscript
# JSON 로드
func load_martial_arts() -> Array:
    var file = FileAccess.open("user://data/martial_arts.json", FileAccess.READ)
    if file:
        var json = JSON.new()
        var result = json.parse(file.get_as_text())
        if result == OK:
            return json.data["martial_arts"]
    return []

# JSON 저장
func save_player_data(player: Player) -> bool:
    var data = {
        "player": {
            "name": player.player_name,
            "level": player.level,
            "stats": player.stats,
            # ... 더 많은 데이터
        }
    }
    
    var file = FileAccess.open("user://save/game_001.json", FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(data))
        return true
    return false
```

---

## 다음 단계

✅ **완료:** 데이터 포맷 정의  
📋 **다음:** Day 2 실제 코드 구현 (MartialArt.gd, Player.gd 등)

---

_문서 작성자: 천재 (AI Assistant)_  
_Updated: 2026-05-07_
