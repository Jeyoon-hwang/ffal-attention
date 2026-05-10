# item_system.gd - 100+ 아이템 시스템, 드롭, 능력치
# 작성: 천재 ⚡
# 2026-05-07 Day 4

extends Node

# ============================================================
# 아이템 시스템: 100+ 아이템, 드롭, 강화, 능력치
# ============================================================

class Item:
	var id: String
	var name: String
	var category: String  # weapon, armor, accessory, consumable, material
	var rarity: String  # common, uncommon, rare, epic, legendary
	var level: int  # 1-50
	var price: int
	var description: String
	var stats: Dictionary = {}  # str, dex, int, con, spd, etc
	var effect: String = ""  # 특수 효과
	var drop_chance: float = 0.0
	
	func _init(item_id: String, item_name: String, item_category: String,
			   item_rarity: String, item_level: int, item_price: int) -> void:
		self.id = item_id
		self.name = item_name
		self.category = item_category
		self.rarity = item_rarity
		self.level = item_level
		self.price = item_price

class ItemDrop:
	var item_id: String
	var source: String  # enemy, dungeon, boss, quest
	var drop_chance: float  # 0.0 ~ 1.0
	var quantity_min: int
	var quantity_max: int
	var level_range: Array  # [min, max]
	
	func _init(item_id: String, source: String, drop_chance: float,
			   qty_min: int, qty_max: int, level_range: Array) -> void:
		self.item_id = item_id
		self.source = source
		self.drop_chance = drop_chance
		self.quantity_min = qty_min
		self.quantity_max = qty_max
		self.level_range = level_range

# 아이템 저장소
var items: Dictionary = {}  # item_id -> Item
var drops: Array = []  # ItemDrop[]

# 카테고리별 아이템
var category_items: Dictionary = {
	"weapon": [],
	"armor": [],
	"accessory": [],
	"consumable": [],
	"material": []
}

# 희귀도 가중치
var rarity_weights = {
	"common": 60,
	"uncommon": 25,
	"rare": 10,
	"epic": 4,
	"legendary": 1
}

# 능력치
var stat_names = ["str", "dex", "int", "con", "spd", "lck", "res"]

# 아이템 효과
var effects = {
	"weapon": ["회피 +5%", "크리티컬 +10%", "피해 +15%", "흡혈 5%", "마나 회복", "회오리"],
	"armor": ["방어 +10", "체력 +20", "저항 +5%", "재생", "방어자세", "도발"],
	"accessory": ["모든 능력 +1", "골드 획득 +20%", "경험치 +10%", "상태이상 저항"],
	"consumable": ["체력 회복", "마나 회복", "상태이상 제거", "강화 버프"],
	"material": ["합성", "강화", "각인"]
}

# 초기화
func _init() -> void:
	generate_items()
	generate_drops()

# ============================================================
# 100+ 아이템 자동 생성
# ============================================================

func generate_items() -> void:
	var item_counter = 0
	var items_per_category = {
		"weapon": 25,
		"armor": 25,
		"accessory": 15,
		"consumable": 20,
		"material": 15
	}
	
	for category in items_per_category.keys():
		for i in range(items_per_category[category]):
			var rarity = pick_rarity()
			var level = (randi() % 50) + 1  # Level 1-50
			var item_id = "%s_%03d" % [category, i + 1]
			var name = generate_item_name(category, rarity)
			var price = calculate_item_price(category, rarity, level)
			
			var item = Item.new(item_id, name, category, rarity, level, price)
			
			# 능력치 할당
			assign_item_stats(item)
			
			# 효과 할당
			if category in effects:
				item.effect = effects[category].pick_random()
			
			# 드롭율 계산
			var rarity_drop_map = {
				"common": 0.15,
				"uncommon": 0.10,
				"rare": 0.05,
				"epic": 0.02,
				"legendary": 0.001
			}
			item.drop_chance = rarity_drop_map[rarity] * (1.0 + (level / 50.0))
			
			items[item_id] = item
			category_items[category].append(item_id)
			item_counter += 1
	
	print("[Item System] 총 " + str(item_counter) + "개의 아이템 생성 완료")

# 희귀도 선택 (가중치 기반)
func pick_rarity() -> String:
	var total = 0
	for rarity in rarity_weights.values():
		total += rarity
	
	var rand = randi() % total
	var cumulative = 0
	
	for rarity in rarity_weights.keys():
		cumulative += rarity_weights[rarity]
		if rand < cumulative:
			return rarity
	
	return "common"

# 아이템 이름 생성
func generate_item_name(category: String, rarity: String) -> String:
	var prefixes = {
		"weapon": ["검", "도", "창", "활", "마법봉", "부채", "채", "쌍검"],
		"armor": ["갑옷", "로브", "외투", "방패", "투구", "장갑", "부츠"],
		"accessory": ["반지", "목걸이", "팔찌", "부적"],
		"consumable": ["포션", "약초", "음식", "스크롤"],
		"material": ["원석", "광석", "목재", "가죽"]
	}
	
	var suffixes = {
		"common": "",
		"uncommon": "의",
		"rare": "위대한",
		"epic": "신성한",
		"legendary": "전설의"
	}
	
	var base_name = prefixes[category].pick_random()
	var suffix = suffixes[rarity]
	
	if suffix:
		return "%s %s" % [suffix, base_name]
	return base_name

# 아이템 가격 계산
func calculate_item_price(category: String, rarity: String, level: int) -> int:
	var base_prices = {
		"weapon": 100,
		"armor": 80,
		"accessory": 50,
		"consumable": 20,
		"material": 30
	}
	
	var rarity_multipliers = {
		"common": 1.0,
		"uncommon": 2.0,
		"rare": 4.0,
		"epic": 8.0,
		"legendary": 15.0
	}
	
	var base = base_prices[category]
	var rarity_mult = rarity_multipliers[rarity]
	var level_mult = 1.0 + (level / 50.0)
	
	return int(base * rarity_mult * level_mult)

# 아이템 능력치 할당
func assign_item_stats(item: Item) -> void:
	var stat_count = 1 + (randi() % 3)  # 1-3개 능력치
	var rarity_stat_bonus = {
		"common": 1,
		"uncommon": 2,
		"rare": 3,
		"epic": 5,
		"legendary": 8
	}
	
	var bonus = rarity_stat_bonus[item.rarity]
	
	# 카테고리별 주요 능력치
	var category_stats = {
		"weapon": ["str", "dex", "spd"],
		"armor": ["con", "res"],
		"accessory": ["str", "dex", "int", "con", "spd", "lck"],
		"consumable": [],
		"material": []
	}
	
	if item.category in category_stats and category_stats[item.category].size() > 0:
		var primary_stats = category_stats[item.category]
		
		for i in range(stat_count):
			var stat = primary_stats[randi() % primary_stats.size()]
			var value = bonus + (randi() % (bonus + 5))
			item.stats[stat] = value

# ============================================================
# 드롭 시스템
# ============================================================

func generate_drops() -> void:
	var drop_counter = 0
	
	# 적 드롭 (40개)
	for item_id in items.keys():
		var item = items[item_id]
		if randi() % 3 == 0:  # 약 33% 아이템이 적 드롭
			var level_range = [item.level - 5, item.level + 5]
			var drop = ItemDrop.new(
				item_id,
				"enemy",
				item.drop_chance * 0.5,
				1,
				1,
				level_range
			)
			drops.append(drop)
			drop_counter += 1
	
	# 보스 드롭 (20개)
	for item_id in items.keys():
		var item = items[item_id]
		if randi() % 5 == 0 and item.rarity in ["rare", "epic", "legendary"]:
			var level_range = [item.level - 2, item.level + 10]
			var drop = ItemDrop.new(
				item_id,
				"boss",
				item.drop_chance * 2.0,
				1,
				2,
				level_range
			)
			drops.append(drop)
			drop_counter += 1
	
	print("[Item Drop] 총 " + str(drop_counter) + "개의 드롭 규칙 생성")

# ============================================================
# 조회 함수
# ============================================================

# 아이템 조회
func get_item(item_id: String) -> Item:
	return items.get(item_id)

# 카테고리별 아이템들
func get_items_by_category(category: String) -> Array:
	var result = []
	for item_id in category_items[category]:
		result.append(items[item_id])
	return result

# 희귀도별 아이템들
func get_items_by_rarity(rarity: String) -> Array:
	var result = []
	for item_id in items.keys():
		if items[item_id].rarity == rarity:
			result.append(items[item_id])
	return result

# 레벨 범위 내 아이템들
func get_items_by_level(min_level: int, max_level: int) -> Array:
	var result = []
	for item_id in items.keys():
		var item = items[item_id]
		if item.level >= min_level and item.level <= max_level:
			result.append(item)
	return result

# 아이템 수
func get_item_count() -> int:
	return items.size()

# 카테고리별 아이템 수
func get_category_item_count(category: String) -> int:
	return category_items[category].size()

# 특정 소스의 드롭 규칙들
func get_drops_by_source(source: String) -> Array:
	var result = []
	for drop in drops:
		if drop.source == source:
			result.append(drop)
	return result

# 몬스터 레벨에 맞는 드롭들
func get_monster_drops(monster_level: int) -> Array:
	var result = []
	for drop in drops:
		if drop.source == "enemy":
			if monster_level >= drop.level_range[0] and monster_level <= drop.level_range[1]:
				result.append(drop)
	return result

# 보스 레벨에 맞는 드롭들
func get_boss_drops(boss_level: int) -> Array:
	var result = []
	for drop in drops:
		if drop.source == "boss":
			if boss_level >= drop.level_range[0] and boss_level <= drop.level_range[1]:
				result.append(drop)
	return result

# 드롭 확률 계산 (0.0 ~ 1.0)
func roll_drop(drop: ItemDrop) -> bool:
	return randf() < drop.drop_chance

# 아이템 드롭 시뮬레이션
func simulate_drop(source: String, player_level: int) -> Array:
	var dropped_items = []
	
	if source == "enemy":
		for drop in get_monster_drops(player_level):
			if roll_drop(drop):
				var quantity = drop.quantity_min + randi() % (drop.quantity_max - drop.quantity_min + 1)
				for q in range(quantity):
					dropped_items.append(drop.item_id)
	elif source == "boss":
		for drop in get_boss_drops(player_level):
			if roll_drop(drop):
				var quantity = drop.quantity_min + randi() % (drop.quantity_max - drop.quantity_min + 1)
				for q in range(quantity):
					dropped_items.append(drop.item_id)
	
	return dropped_items

# 게임 통계
func print_game_status() -> void:
	print("\n" + "="*50)
	print("🎁 아이템 시스템 통계")
	print("="*50)
	
	print("\n📊 카테고리별 아이템:")
	for category in category_items.keys():
		var count = get_category_item_count(category)
		print("  " + category + ": " + str(count) + "개")
	
	print("\n📊 희귀도별 아이템:")
	for rarity in ["common", "uncommon", "rare", "epic", "legendary"]:
		var count = get_items_by_rarity(rarity).size()
		print("  " + rarity + ": " + str(count) + "개")
	
	print("\n📊 드롭 규칙:")
	var enemy_drops = get_drops_by_source("enemy").size()
	var boss_drops = get_drops_by_source("boss").size()
	print("  적 드롭: " + str(enemy_drops) + "개")
	print("  보스 드롭: " + str(boss_drops) + "개")
	
	print("\n총 아이템: %d개" % get_item_count())
	print("="*50 + "\n")

# ============================================================
