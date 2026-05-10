# 📋 NEXUS v2 데이터 스키마 (JSON)

**Purpose:** 게임 데이터 포맷 표준화  
**Format:** JSON  
**Usage:** 무술, 캐릭터, NPC, 던전 데이터 저장/로드

---

## 1️⃣ MartialArt (무술) 데이터

**파일:** `Data/Martial/martial_arts.json`

```json
{
  "martial_arts": [
    {
      "id": "martial_001",
      "name": "기본권",
      "description": "가장 기초적인 권법",
      "base_motion": 0,
      "tempo": "FAST",
      "defense_type": "NONE",
      "defense_level": 0,
      "energy_cost": 10,
      "base_damage": 5,
      "str_scaling": 0.5,
      "dex_scaling": 0.2,
      "effect": "NONE",
      "effect_duration": 0.0,
      "effect_chance": 0.0,
      "hitbox_range": 1.5,
      "hitbox_radius": 0.3,
      "animation_name": "punch_basic",
      "animation_duration": 0.8,
      "startup_frames": 5,
      "active_frames": 8,
      "recovery_frames": 5,
      "can_combo": true,
      "combo_requirements": [],
      "level": 1
    },
    {
      "id": "martial_002",
      "name": "연속권",
      "description": "빠른 연속 권법 (콤보)",
      "base_motion": 1,
      "tempo": "FAST",
      "defense_type": "NONE",
      "defense_level": 0,
      "energy_cost": 15,
      "base_damage": 8,
      "str_scaling": 0.4,
      "dex_scaling": 0.3,
      "effect": "NONE",
      "effect_duration": 0.0,
      "effect_chance": 0.0,
      "hitbox_range": 1.5,
      "hitbox_radius": 0.3,
      "animation_name": "punch_combo",
      "animation_duration": 1.2,
      "startup_frames": 3,
      "active_frames": 12,
      "recovery_frames": 4,
      "can_combo": true,
      "combo_requirements": ["martial_001"],
      "level": 2
    },
    {
      "id": "martial_003",
      "name": "회피",
      "description": "측면으로 재빠르게 회피",
      "base_motion": 50,
      "tempo": "FAST",
      "defense_type": "DODGE",
      "defense_level": 3,
      "energy_cost": 20,
      "base_damage": 0,
      "str_scaling": 0.0,
      "dex_scaling": 0.5,
      "effect": "NONE",
      "effect_duration": 0.0,
      "effect_chance": 0.0,
      "hitbox_range": 0.0,
      "hitbox_radius": 0.0,
      "animation_name": "dodge_side",
      "animation_duration": 0.5,
      "startup_frames": 2,
      "active_frames": 5,
      "recovery_frames": 3,
      "can_combo": true,
      "combo_requirements": [],
      "level": 1
    },
    {
      "id": "martial_004",
      "name": "회오리 발차기",
      "description": "강력한 회오리 발차기 (스턴 효과)",
      "base_motion": 75,
      "tempo": "MID",
      "defense_type": "NONE",
      "defense_level": 0,
      "energy_cost": 30,
      "base_damage": 20,
      "str_scaling": 0.6,
      "dex_scaling": 0.3,
      "effect": "STUN",
      "effect_duration": 1.5,
      "effect_chance": 0.6,
      "hitbox_range": 2.0,
      "hitbox_radius": 0.5,
      "animation_name": "kick_whirlwind",
      "animation_duration": 1.5,
      "startup_frames": 8,
      "active_frames": 15,
      "recovery_frames": 6,
      "can_combo": true,
      "combo_requirements": ["martial_001"],
      "level": 5
    }
  ]
}
```

---

## 2️⃣ Character (캐릭터) 데이터

**파일:** `Data/Characters/character_template.json`

```json
{
  "name": "플레이어",
  "level": 1,
  "experience": 0,
  "skill_points": 0,
  "stats": {
    "STR": 10,
    "DEX": 10,
    "CON": 10,
    "INT": 10,
    "WIS": 10,
    "CHA": 10
  },
  "hp": {
    "max": 100,
    "current": 100
  },
  "energy": {
    "max": 100,
    "current": 100
  },
  "martial_arts": [
    {
      "slot": 0,
      "martial_id": "martial_001",
      "upgrades": {
        "damage": 0,
        "range": 0.0
      }
    },
    {
      "slot": 1,
      "martial_id": null,
      "upgrades": {}
    },
    {
      "slot": 2,
      "martial_id": null,
      "upgrades": {}
    },
    {
      "slot": 3,
      "martial_id": null,
      "upgrades": {}
    },
    {
      "slot": 4,
      "martial_id": null,
      "upgrades": {}
    }
  ],
  "equipment": {
    "head": null,
    "chest": null,
    "legs": null,
    "feet": null,
    "hands": null,
    "accessory": null
  },
  "inventory": [],
  "location": {
    "zone": "중원",
    "x": 0.0,
    "y": 0.0,
    "z": 0.0
  }
}
```

---

## 3️⃣ Enemy (적) 데이터

**파일:** `Data/Enemies/enemy_template.json`

```json
{
  "id": "wolf_001",
  "name": "회색 늑대",
  "level": 1,
  "ai_level": 1,
  "is_boss": false,
  "stats": {
    "STR": 8,
    "DEX": 9,
    "CON": 7,
    "INT": 3,
    "WIS": 5,
    "CHA": 2
  },
  "hp": {
    "max": 50,
    "current": 50
  },
  "energy": {
    "max": 50,
    "current": 50
  },
  "martial_arts": [
    {
      "slot": 0,
      "martial_id": "martial_001"
    }
  ],
  "ai_behavior": {
    "aggression": 0.6,
    "intelligence": 0.3,
    "caution": 0.4,
    "preferred_distance": 2.0
  },
  "drop_table": {
    "items": [
      {
        "item_id": "wolf_meat",
        "drop_chance": 0.8,
        "quantity": 1
      }
    ],
    "experience": 50,
    "martial_fragments": [
      {
        "fragment_id": "frag_001",
        "drop_chance": 0.1
      }
    ]
  },
  "animation_set": "wolf_animations",
  "model": "wolf_basic"
}
```

**Boss 예제:**

```json
{
  "id": "boss_wolf_001",
  "name": "폭풍의 늑대왕",
  "level": 10,
  "ai_level": 3,
  "is_boss": true,
  "stats": {
    "STR": 15,
    "DEX": 12,
    "CON": 14,
    "INT": 8,
    "WIS": 10,
    "CHA": 7
  },
  "hp": {
    "max": 500,
    "current": 500
  },
  "phases": [
    {
      "phase": 1,
      "hp_threshold": 100,
      "martial_arts": ["martial_001", "martial_002"],
      "ai_behavior": "aggressive"
    },
    {
      "phase": 2,
      "hp_threshold": 50,
      "martial_arts": ["martial_001", "martial_002", "martial_004"],
      "ai_behavior": "very_aggressive",
      "special_ability": "boss_skill_001"
    }
  ],
  "drop_table": {
    "items": [
      {
        "item_id": "legendary_armor",
        "drop_chance": 0.3
      }
    ],
    "experience": 1000,
    "martial_fragments": [
      {
        "fragment_id": "frag_boss_001",
        "drop_chance": 0.5
      }
    ]
  }
}
```

---

## 4️⃣ NPC (NPC) 데이터

**파일:** `Data/NPCs/npc_template.json`

```json
{
  "id": "npc_001",
  "name": "무술관 마스터 이",
  "type": "martial_master",
  "zone": "중원",
  "location": {
    "x": 10.0,
    "y": 0.0,
    "z": 10.0
  },
  "model": "npc_master_male",
  "dialogue": {
    "greeting": "안녕하신가? 무술을 배우길 원하는가?",
    "farewell": "다시 찾아오게나."
  },
  "teaches_martial": [
    "martial_001",
    "martial_002",
    "martial_003",
    "martial_004"
  ],
  "quest_giver": true,
  "quests": [
    "quest_001",
    "quest_002"
  ],
  "shops": null,
  "trade_rate": 1.0
}
```

**상인 예제:**

```json
{
  "id": "npc_002",
  "name": "잡화점 주인",
  "type": "merchant",
  "zone": "중원",
  "model": "npc_merchant_female",
  "shops": {
    "sell": [
      {
        "item_id": "potion_hp",
        "price": 100,
        "stock": 10
      }
    ],
    "buy": [
      {
        "item_id": "wolf_meat",
        "price": 50
      }
    ]
  },
  "trade_rate": 1.0
}
```

---

## 5️⃣ Quest (퀘스트) 데이터

**파일:** `Data/Quests/quest_template.json`

```json
{
  "id": "quest_001",
  "name": "늑대 사냥",
  "description": "마을 근처의 늑대들을 5마리 사냥해라.",
  "type": "hunt",
  "giver": "npc_001",
  "zone": "중원",
  "objectives": [
    {
      "type": "kill_enemy",
      "target": "wolf_001",
      "count": 5
    }
  ],
  "rewards": {
    "experience": 200,
    "gold": 300,
    "items": [
      {
        "item_id": "armor_leather",
        "quantity": 1
      }
    ],
    "martial_fragments": [
      {
        "fragment_id": "frag_001",
        "quantity": 1
      }
    ]
  },
  "level_requirement": 1,
  "quest_chain": null,
  "repeatable": false
}
```

**메인 퀘스트 예제:**

```json
{
  "id": "quest_main_001",
  "name": "무술의 길",
  "description": "진정한 무술의 길에 발을 들이다.",
  "type": "story",
  "giver": "npc_001",
  "zone": "중원",
  "objectives": [
    {
      "type": "talk_npc",
      "target": "npc_001"
    },
    {
      "type": "reach_location",
      "zone": "중원",
      "location_name": "첫 던전 입구"
    },
    {
      "type": "kill_boss",
      "target": "boss_wolf_001"
    }
  ],
  "rewards": {
    "experience": 1000,
    "gold": 500,
    "martial_fragments": [
      {
        "fragment_id": "frag_boss_001",
        "quantity": 2
      }
    ]
  },
  "quest_chain": "main_chain_01",
  "next_quest": "quest_main_002"
}
```

---

## 6️⃣ Dungeon (던전) 데이터

**파일:** `Data/Levels/dungeon_template.json`

```json
{
  "id": "dungeon_001",
  "name": "중원 첫 던전",
  "zone": "중원",
  "level_range": [1, 5],
  "difficulty": 1,
  "layout": "linear",
  "rooms": [
    {
      "room_id": "room_001",
      "room_type": "spawn",
      "enemies": [],
      "connections": ["room_002"]
    },
    {
      "room_id": "room_002",
      "room_type": "combat",
      "enemies": [
        {
          "enemy_id": "wolf_001",
          "count": 3
        }
      ],
      "connections": ["room_003"]
    },
    {
      "room_id": "room_003",
      "room_type": "combat",
      "enemies": [
        {
          "enemy_id": "bat_001",
          "count": 5
        }
      ],
      "connections": ["room_004"]
    },
    {
      "room_id": "room_004",
      "room_type": "boss",
      "enemies": [
        {
          "enemy_id": "boss_wolf_001",
          "count": 1
        }
      ],
      "connections": ["room_005"]
    },
    {
      "room_id": "room_005",
      "room_type": "reward",
      "enemies": [],
      "connections": []
    }
  ],
  "rewards": {
    "experience": 500,
    "gold": 200,
    "items": [
      {
        "item_id": "armor_leather",
        "drop_chance": 0.5
      }
    ]
  },
  "clear_rewards": {
    "achievement": "cleared_dungeon_001",
    "bonus_experience": 100
  }
}
```

---

## 7️⃣ Item (아이템) 데이터

**파일:** `Data/Items/items.json`

```json
{
  "items": [
    {
      "id": "potion_hp",
      "name": "체력 포션",
      "type": "consumable",
      "effect": "restore_hp",
      "value": 50,
      "price": 100
    },
    {
      "id": "armor_leather",
      "name": "가죽 갑옷",
      "type": "equipment",
      "slot": "chest",
      "stats": {
        "CON": 2,
        "DEX": 1
      },
      "defense": 5,
      "price": 300
    },
    {
      "id": "wolf_meat",
      "name": "늑대 고기",
      "type": "material",
      "rarity": "common",
      "price": 50
    }
  ]
}
```

---

## 📐 JSON 로드 헬퍼

**파일:** `Scripts/Core/DataLoader.gd`

```gdscript
class_name DataLoader
extends Node

static func load_martial_arts() -> Array[MartialArt]:
    var file = FileAccess.open("res://Data/Martial/martial_arts.json", FileAccess.READ)
    var json = JSON.parse_string(file.get_as_text())
    
    var martial_arts = []
    for martial_data in json["martial_arts"]:
        var martial = MartialArt.new()
        # 데이터 바인딩
        martial.id = martial_data["id"]
        martial.name = martial_data["name"]
        # ... 등등
        martial_arts.append(martial)
    
    return martial_arts

static func load_character(character_id: String) -> Character:
    var file = FileAccess.open("res://Data/Characters/%s.json" % character_id, FileAccess.READ)
    var json = JSON.parse_string(file.get_as_text())
    
    var character = Character.new()
    character.name = json["name"]
    character.level = json["level"]
    # ... 등등
    
    return character

static func save_character(character: Character, filename: String):
    var data = {
        "name": character.name,
        "level": character.level,
        "experience": character.experience,
        "stats": character.stats,
        "hp": {"max": character.max_hp, "current": character.current_hp},
        # ... 등등
    }
    
    var json_string = JSON.stringify(data)
    var file = FileAccess.open("res://Data/Characters/%s.json" % filename, FileAccess.WRITE)
    file.store_string(json_string)
```

---

**Version:** 1.0  
**Last Updated:** 2026-05-11  
**Status:** 설계 완료, 구현 준비
