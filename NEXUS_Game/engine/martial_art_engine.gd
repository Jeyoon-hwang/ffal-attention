# NEXUS 무술 창조 엔진 — 무술 생성 및 조합 시스템
# 목표: 수백만 개의 무술 조합을 동적으로 생성
#
# 구조:
# 무술 = Base (5가지) + Modifier (8가지) + Combo (연쇄) + Stat Scaling
#
# Example:
#   base_type: "slash" (베기)
#   modifiers: ["quick", "pierce"] (빠르게 + 관통)
#   damage = base_damage × (1.0 + modifier_bonus) × stat_scaling

extends Node

class_name MartialArtEngine

# ============================================================================
# 무술 상수 정의
# ============================================================================

# Base 무술 (5가지)
const BASE_TYPES = {
	"slash": {
		"name": "베기",
		"base_damage": 20,
		"cooldown": 0.6,
		"cast_time": 0.2,
		"range": 2.5,
		"aoe": 0.5,
		"description": "일반적이고 빠른 공격"
	},
	"thrust": {
		"name": "찌르기",
		"base_damage": 25,
		"cooldown": 0.8,
		"cast_time": 0.3,
		"range": 3.0,
		"aoe": 0.2,
		"description": "느리지만 정확한 공격"
	},
	"smash": {
		"name": "내려찍기",
		"base_damage": 35,
		"cooldown": 1.2,
		"cast_time": 0.5,
		"range": 2.0,
		"aoe": 1.5,
		"description": "느리지만 높은 데미지와 범위"
	},
	"wave": {
		"name": "에너지 방사",
		"base_damage": 30,
		"cooldown": 1.5,
		"cast_time": 0.4,
		"range": 10.0,
		"aoe": 1.0,
		"description": "원거리 마법 공격"
	},
	"special": {
		"name": "특수 기술",
		"base_damage": 40,
		"cooldown": 2.0,
		"cast_time": 0.8,
		"range": 4.0,
		"aoe": 2.0,
		"description": "복합 효과의 강력한 기술"
	}
}

# Modifier (8가지)
const MODIFIERS = {
	"quick": {
		"name": "빠르게",
		"damage_mult": 0.8,
		"speed_mult": 1.4,
		"cooldown_mult": 0.8,
		"range_mult": 1.0,
		"aoe_mult": 0.8,
		"mana_cost": 5,
		"description": "공격속도 +40%, 데미지 -20%"
	},
	"heavy": {
		"name": "강하게",
		"damage_mult": 1.6,
		"speed_mult": 0.7,
		"cooldown_mult": 1.3,
		"range_mult": 1.0,
		"aoe_mult": 1.2,
		"mana_cost": 15,
		"description": "데미지 +60%, 공격속도 -30%"
	},
	"wide": {
		"name": "넓게",
		"damage_mult": 0.85,
		"speed_mult": 1.0,
		"cooldown_mult": 1.15,
		"range_mult": 1.0,
		"aoe_mult": 2.5,
		"mana_cost": 10,
		"description": "범위 +150%, 데미지 -15%"
	},
	"precise": {
		"name": "좁게",
		"damage_mult": 1.2,
		"speed_mult": 1.2,
		"cooldown_mult": 0.9,
		"range_mult": 1.2,
		"aoe_mult": 0.5,
		"mana_cost": -5,
		"description": "명중률 +50%, 크리티컬 +25%"
	},
	"pierce": {
		"name": "관통",
		"damage_mult": 1.3,
		"speed_mult": 0.9,
		"cooldown_mult": 1.2,
		"range_mult": 1.0,
		"aoe_mult": 0.8,
		"mana_cost": 20,
		"description": "방어 무시 50%"
	},
	"chain": {
		"name": "연쇄",
		"damage_mult": 0.7,
		"speed_mult": 1.0,
		"cooldown_mult": 1.4,
		"range_mult": 2.0,
		"aoe_mult": 1.0,
		"mana_cost": 30,
		"description": "최대 3개 적에게 순차 공격"
	},
	"drain": {
		"name": "회복",
		"damage_mult": 0.9,
		"speed_mult": 0.8,
		"cooldown_mult": 1.5,
		"range_mult": 1.0,
		"aoe_mult": 0.8,
		"mana_cost": 40,
		"description": "데미지의 30% 회복"
	},
	"poison": {
		"name": "독성",
		"damage_mult": 0.8,
		"speed_mult": 1.0,
		"cooldown_mult": 1.25,
		"range_mult": 1.0,
		"aoe_mult": 1.0,
		"mana_cost": 25,
		"description": "3초 독 상태 (초당 10% HP)"
	}
}

# Stat Scaling (능력치 가중치)
const STAT_SCALING = {
	"slash": {"str": 0.8, "dex": 0.2},
	"thrust": {"str": 0.5, "dex": 0.6},
	"smash": {"str": 0.9, "dex": 0.1},
	"wave": {"str": 0.0, "int": 1.0},
	"special": {"str": 0.5, "dex": 0.3, "int": 0.3}
}

# ============================================================================
# 무술 클래스 정의
# ============================================================================

class MartialArt:
	var id: String
	var name: String
	var base_type: String
	var modifiers: Array[String]
	var base_damage: float
	var cooldown: float
	var cast_time: float
	var range: float
	var aoe: float
	var mana_cost: float
	var description: String
	var effects: Array[String]
	var stat_scaling: Dictionary
	
	func _init(p_id: String, p_name: String, p_base: String, p_mods: Array[String]):
		id = p_id
		name = p_name
		base_type = p_base
		modifiers = p_mods
		effects = []
		stat_scaling = {}

# ============================================================================
# 무술 생성 함수
# ============================================================================

## 무술을 새로 생성
## Example: create_martial_art("slash", ["quick", "precise"])
func create_martial_art(base_type: String, modifiers: Array[String] = []) -> MartialArt:
	# Validation
	if not BASE_TYPES.has(base_type):
		push_error("Invalid base type: " + base_type)
		return null
	
	for mod in modifiers:
		if not MODIFIERS.has(mod):
			push_error("Invalid modifier: " + mod)
			return null
	
	# Create martial art
	var art = MartialArt.new(
		_generate_id(base_type, modifiers),
		_generate_name(base_type, modifiers),
		base_type,
		modifiers
	)
	
	# Calculate stats
	_calculate_stats(art)
	_apply_effects(art)
	
	return art

## ID 생성 (고유 식별자)
func _generate_id(base_type: String, modifiers: Array[String]) -> String:
	var id = base_type
	for mod in modifiers:
		id += "_" + mod
	return id

## 무술 이름 생성
func _generate_name(base_type: String, modifiers: Array[String]) -> String:
	var name = BASE_TYPES[base_type]["name"]
	
	if modifiers.is_empty():
		return name
	
	var mod_names = []
	for mod in modifiers:
		mod_names.append(MODIFIERS[mod]["name"])
	
	return "[" + ", ".join(PackedStringArray(mod_names)) + "] " + name

## 무술 능력치 계산
func _calculate_stats(art: MartialArt) -> void:
	# Base stats
	var base = BASE_TYPES[art.base_type]
	art.base_damage = base["base_damage"]
	art.cooldown = base["cooldown"]
	art.cast_time = base["cast_time"]
	art.range = base["range"]
	art.aoe = base["aoe"]
	art.mana_cost = 0.0
	
	# Apply modifiers
	for mod_name in art.modifiers:
		var mod = MODIFIERS[mod_name]
		art.base_damage *= mod["damage_mult"]
		art.cooldown *= mod["cooldown_mult"]
		art.range *= mod["range_mult"]
		art.aoe *= mod["aoe_mult"]
		art.mana_cost += mod["mana_cost"]
	
	# Description
	art.description = base["description"]
	if not art.modifiers.is_empty():
		for mod in art.modifiers:
			art.description += "\n+ " + MODIFIERS[mod]["description"]
	
	# Stat scaling
	art.stat_scaling = STAT_SCALING[art.base_type].duplicate()

## 특수 효과 적용
func _apply_effects(art: MartialArt) -> void:
	for mod in art.modifiers:
		match mod:
			"chain":
				art.effects.append("multi_target:3")
			"drain":
				art.effects.append("lifesteal:0.3")
			"poison":
				art.effects.append("damage_over_time:poison,3,0.1")
			"pierce":
				art.effects.append("armor_penetration:0.5")

# ============================================================================
# 무술 검색 및 관리
# ============================================================================

var martial_arts_db: Dictionary = {} # ID → MartialArt

## 모든 기본 무술 생성 (게임 시작 시 호출)
func initialize_base_arts() -> void:
	# 각 Base 타입마다 Modifier 0~2개 조합으로 기본 무술 생성
	var base_types_array = BASE_TYPES.keys()
	
	for base in base_types_array:
		# No modifier
		var art0 = create_martial_art(base, [])
		martial_arts_db[art0.id] = art0
		
		# 1 modifier
		for mod in MODIFIERS.keys():
			var art1 = create_martial_art(base, [mod])
			martial_arts_db[art1.id] = art1

## 무술 검색 (ID로)
func get_martial_art(id: String) -> MartialArt:
	return martial_arts_db.get(id)

## 플레이어가 습득할 수 있는 무술 리스트
func get_learnable_arts(player_level: int = 1) -> Array[MartialArt]:
	var arts: Array[MartialArt] = []
	for art_id in martial_arts_db.keys():
		arts.append(martial_arts_db[art_id])
	return arts

# ============================================================================
# 능력치 기반 데미지 계산
# ============================================================================

## 최종 데미지 계산 (플레이어 능력치 포함)
## damage = base_damage × (1 + STR×scaling_str + DEX×scaling_dex + INT×scaling_int)
func calculate_damage(
	martial_art: MartialArt,
	player_stats: Dictionary,
	crit_multiplier: float = 1.0
) -> float:
	if martial_art == null:
		return 0.0
	
	var base_dmg = martial_art.base_damage
	var scaling = martial_art.stat_scaling
	
	var stat_bonus = 1.0
	if scaling.has("str") and player_stats.has("str"):
		stat_bonus += player_stats["str"] * scaling["str"] * 0.01
	if scaling.has("dex") and player_stats.has("dex"):
		stat_bonus += player_stats["dex"] * scaling["dex"] * 0.01
	if scaling.has("int") and player_stats.has("int"):
		stat_bonus += player_stats["int"] * scaling["int"] * 0.01
	
	return base_dmg * stat_bonus * crit_multiplier

# ============================================================================
# 콤보 시스템 (Combo System)
# ============================================================================

class ComboChain:
	var arts: Array[MartialArt]
	var damage_multiplier: float
	var timing_window: float # 연속 공격 시간 제한
	
	func _init(p_arts: Array[MartialArt]):
		arts = p_arts
		damage_multiplier = 1.0 + (float(p_arts.size()) * 0.1) # 5개 = 1.5배
		timing_window = 1.0

## 콤보 체인 생성 (최대 7개 무술)
func create_combo(martial_arts: Array[MartialArt]) -> ComboChain:
	if martial_arts.size() > 7:
		push_error("Combo can have max 7 martial arts")
		return null
	if martial_arts.is_empty():
		return null
	
	var combo = ComboChain.new(martial_arts)
	combo.timing_window = 1.0 + (float(martial_arts.size()) * 0.2) # 더 많을수록 타이밍 윈도우 커짐
	return combo

## 콤보 데미지 계산
func calculate_combo_damage(combo: ComboChain, player_stats: Dictionary) -> float:
	var total_damage = 0.0
	for art in combo.arts:
		total_damage += calculate_damage(art, player_stats)
	return total_damage * combo.damage_multiplier

# ============================================================================
# 디버그 & 테스트
# ============================================================================

func print_martial_art(art: MartialArt) -> void:
	print("=" * 50)
	print("[%s] %s" % [art.id, art.name])
	print("데미지: %.1f | 쿨타임: %.1fs | 범위: %.1fm | AOE: %.1fm" % 
		[art.base_damage, art.cooldown, art.range, art.aoe])
	print("마나: %.0f" % art.mana_cost)
	print(art.description)
	if not art.effects.is_empty():
		print("효과: " + ", ".join(PackedStringArray(art.effects)))
	print("=" * 50)

func _ready() -> void:
	# Initialize database
	initialize_base_arts()
	print("무술 DB 초기화 완료: %d개 무술 등록됨" % martial_arts_db.size())
	
	# Test: Create and print a martial art
	var test_art = create_martial_art("slash", ["quick", "pierce"])
	print_martial_art(test_art)
