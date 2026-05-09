# NEXUS 무술 창조 게임 - 데이터 스키마 정의

**Version:** 1.0  
**Format:** JSON (저장소), GDScript Dictionary (런타임)  
**Last Updated:** 2026-05-09

---

## 1. MartialArt (무술) 스키마

```json
{
  "id": "MA_001",
  "name": "기본 펀치",
  "rarity": 1,
  "description": "가장 기초적인 주먹 공격",
  
  "base": {
    "motion_id": 0,
    "tempo": "mid",
    "animation_duration": 0.6,
    "damage_base": 10.0
  },
  
  "energy": {
    "cost": 5,
    "max_cost": 10
  },
  
  "defense": {
    "type": "none",
    "level": 0
  },
  
  "effects": [],
  "effect_power": 1,
  
  "hitbox": {
    "position": {"x": 0.5, "y": 1.5, "z": 0},
    "size": {"x": 0.3, "y": 0.3, "z": 0.5},
    "damage_distribution": [1.0]
  },
  
  "level_data": {
    "current_level": 1,
    "max_level": 10,
    "exp_to_next": 100
  },
  
  "upgrades": {
    "damage_per_level": 2.0,
    "reach_per_level": 0.05,
    "combo_bonus": 0
  },
  
  "combo": {
    "combo_with": ["MA_001"],
    "combo_damage_bonus": 1.1,
    "combo_animation_id": 0
  }
}
```

---

## 2. Player (플레이어) 스키마

```json
{
  "id": "PLAYER_001",
  "name": "플레이어 이름",
  "gender": "male|female",
  
  "level": {
    "current": 1,
    "experience": 0,
    "next_level_exp": 100
  },
  
  "stats": {
    "STR": 10,
    "DEX": 8,
    "CON": 9,
    "INT": 7,
    "WIS": 8,
    "CHA": 6
  },
  
  "health": {
    "current": 100,
    "max": 100,
    "regen_per_sec": 0.1
  },
  
  "energy": {
    "current": 100,
    "max": 100,
    "regen_per_sec": 5.0
  },
  
  "combat": {
    "martial_arts": [
      {
        "slot": 1,
        "martial_id": "MA_001",
        "is_locked": false
      },
      {
        "slot": 2,
        "martial_id": null,
        "is_locked": true
      }
    ],
    "skill_points": 0,
    "total_kills": 0,
    "total_damage_dealt": 0
  },
  
  "position": {
    "region": "중원",
    "x": 0.0,
    "y": 0.0,
    "z": 0.0
  },
  
  "inventory": {
    "gold": 100,
    "items": [
      {
        "item_id": "POTION_HEALTH",
        "quantity": 5
      }
    ]
  },
  
  "progression": {
    "cleared_dungeons": [],
    "completed_quests": [],
    "discovered_regions": ["중원"]
  },
  
  "appearance": {
    "model_preset": "default",
    "hair_color": "#000000",
    "skin_color": "#FFA500"
  }
}
```

---

## 3. Enemy (적) 스키마

```json
{
  "id": "ENEMY_001",
  "name": "늑대",
  "type": "Animal",
  "level": 1,
  
  "stats": {
    "STR": 8,
    "DEX": 10,
    "CON": 7,
    "INT": 2,
    "WIS": 4,
    "CHA": 1
  },
  
  "health": {
    "current": 50,
    "max": 50
  },
  
  "combat": {
    "martial_arts": ["MA_101", "MA_102"],
    "attack_frequency": 1.0,
    "damage_multiplier": 1.0
  },
  
  "ai": {
    "level": 1,
    "behavior": "basic",
    "awareness_range": 20.0,
    "chase_range": 30.0,
    "attack_range": 2.0
  },
  
  "loot": {
    "exp_drop": 50,
    "gold_drop": 10,
    "item_drops": [
      {
        "item_id": "WOLF_FANG",
        "drop_chance": 0.3,
        "quantity_min": 1,
        "quantity_max": 2
      }
    ]
  }
}
```

### Enemy Type Variations:

**Level 1 - Animal:**
```json
{
  "type": "Animal",
  "ai_level": 1,
  "martial_count": 2,
  "patterns": ["attack", "flee"]
}
```

**Level 2 - Basic Martial Artist:**
```json
{
  "type": "Martial",
  "ai_level": 2,
  "martial_count": 4,
  "patterns": ["attack", "defend", "combo", "flee"],
  "adaptation": 0.3
}
```

**Level 3 - Advanced (Dungeon Boss):**
```json
{
  "type": "Boss",
  "ai_level": 3,
  "martial_count": 8,
  "patterns": ["phase1", "phase2", "special_ability"],
  "adaptation": 0.7,
  "phase_transition": 50
}
```

**Level 4 - Master (Final Boss):**
```json
{
  "type": "Master",
  "ai_level": 4,
  "martial_count": 12,
  "patterns": ["all_patterns"],
  "adaptation": 1.0,
  "phase_count": 3
}
```

---

## 4. Dungeon (던전) 스키마

```json
{
  "id": "D_001",
  "name": "중원 던전 1",
  "region": "중원",
  "level_range": {
    "min": 1,
    "max": 5
  },
  
  "rooms": [
    {
      "room_id": "R_001",
      "enemy_count": 3,
      "enemies": ["ENEMY_001", "ENEMY_002", "ENEMY_001"],
      "boss": null
    },
    {
      "room_id": "R_002",
      "enemy_count": 5,
      "enemies": ["ENEMY_003", "ENEMY_003", "ENEMY_004", "ENEMY_002", "ENEMY_001"],
      "boss": null
    },
    {
      "room_id": "R_BOSS",
      "enemy_count": 1,
      "enemies": [],
      "boss": "BOSS_001"
    }
  ],
  
  "rewards": {
    "exp_per_room": 200,
    "exp_boss": 500,
    "gold_per_room": 50,
    "gold_boss": 200,
    "item_drops": [
      {
        "item_id": "MARTIAL_FRAGMENT",
        "drop_chance": 0.5
      }
    ]
  },
  
  "difficulty_multiplier": 1.0
}
```

---

## 5. Quest (퀘스트) 스키마

```json
{
  "id": "Q_001",
  "name": "첫 번째 던전 정복",
  "type": "main",
  "description": "중원 던전 1을 클리어하세요",
  
  "objectives": [
    {
      "objective_id": "OBJ_001",
      "type": "defeat_enemies",
      "count": 3,
      "target": "dungeon_enemies"
    }
  ],
  
  "rewards": {
    "exp": 500,
    "gold": 100,
    "items": [
      {
        "item_id": "MARTIAL_FRAGMENT",
        "quantity": 1
      }
    ]
  },
  
  "requirements": {
    "min_level": 1,
    "previous_quests": []
  },
  
  "status": "not_started"
}
```

---

## 6. Item (아이템) 스키마

```json
{
  "id": "ITEM_001",
  "name": "빨간 포션",
  "type": "consumable",
  "rarity": 1,
  
  "effect": {
    "type": "heal",
    "value": 50
  },
  
  "consumable": {
    "max_stack": 99,
    "cooldown": 0
  }
}
```

**Equipment Example:**
```json
{
  "id": "ARMOR_001",
  "name": "무술복",
  "type": "equipment",
  "slot": "chest",
  "rarity": 2,
  
  "stats": {
    "STR": 2,
    "CON": 3
  },
  
  "durability": {
    "current": 100,
    "max": 100
  }
}
```

---

## 7. NPC (NPC) 스키마

```json
{
  "id": "NPC_001",
  "name": "무술관 마스터",
  "role": "martial_teacher",
  "region": "중원",
  
  "dialogue": {
    "greeting": "안녕하세요, 무술을 배우고 싶으신가요?",
    "quests": ["Q_001", "Q_002"]
  },
  
  "services": {
    "type": "teach_martial",
    "teaches": ["MA_001", "MA_002", "MA_003"]
  },
  
  "position": {
    "x": 50.0,
    "y": 0.0,
    "z": 50.0
  }
}
```

---

## 8. SaveGame (저장 파일) 스키마

```json
{
  "version": "1.0",
  "save_time": "2026-05-09T12:00:00Z",
  "playtime_seconds": 3600,
  
  "player": {
    // Full Player schema
  },
  
  "world": {
    "current_region": "중원",
    "cleared_dungeons": ["D_001"],
    "completed_quests": ["Q_001"],
    "discovered_regions": ["중원"],
    "visited_npcs": ["NPC_001"]
  },
  
  "progress": {
    "completion_percentage": 5,
    "total_enemies_defeated": 50,
    "total_bosses_defeated": 1
  }
}
```

---

## 파일 저장 경로

```
/Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game/Data/
├── martial_arts/        (무술 데이터베이스)
│   ├── MA_001.json
│   ├── MA_002.json
│   └── ...
├── enemies/             (적 데이터베이스)
│   ├── ENEMY_001.json
│   ├── BOSS_001.json
│   └── ...
├── dungeons/            (던전 데이터)
│   ├── D_001.json
│   └── ...
├── quests/              (퀘스트 데이터)
│   ├── Q_001.json
│   └── ...
├── items/               (아이템 데이터)
│   ├── ITEM_001.json
│   └── ...
├── npcs/                (NPC 데이터)
│   ├── NPC_001.json
│   └── ...
└── saves/               (플레이어 저장 파일)
    └── save_001.json
```

---

## 데이터 로딩 순서

1. **시작**: `project.godot` 로드
2. **기본 데이터**: `martial_arts/`, `enemies/`, `items/` 로드
3. **월드 데이터**: `dungeons/`, `quests/`, `npcs/` 로드
4. **저장 파일**: `saves/save_001.json` 로드 (선택)
5. **게임 시작**: Player 초기화, 첫 장면 로드

---

## 유효성 검사 (Validation)

각 데이터 로드 시 검사:
- ✅ 필수 필드 존재 여부
- ✅ 타입 일치 (int, float, string, array)
- ✅ 값 범위 (레벨, 스탯 등)
- ✅ 참조 무결성 (무술 ID, NPC ID 등)

**Validation Helper Class:**
```gdscript
class_name DataValidator
extends Node

static func validate_martial_art(data: Dictionary) -> bool:
    return data.has("id") and data.has("name") and data.has("base")

static func validate_player(data: Dictionary) -> bool:
    return data.has("level") and data.has("stats") and data.has("combat")
```

---

## 다음 단계

1. **Data Loader 구현** (Day 2)
   - JSON 파일 읽기/쓰기
   - Data Validator 구현

2. **MartialArt 샘플 데이터 생성** (Day 3)
   - 기본 무술 10가지
   - 테스트 무술 5가지

3. **Enemy 샘플 데이터 생성** (Day 8)
   - 레벨 1-5 적 10가지

4. **Dungeon 샘플 데이터 생성** (Day 10)
   - 첫 던전 1개
   - 보스 데이터 1개
