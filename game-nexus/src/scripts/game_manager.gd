extends Node

# ⚡ 글로벌 상수
var constants = preload("res://src/scripts/constants.gd")
var particle_effects = null  # 파티클 이펙트 시스템

# Week 2: 새로운 시스템 로드
var region_manager: Node
var dungeon_generator: Node
var quest_system: Node

# Day 4: 콘텐츠 확장
var npc_system: Node
var item_system: Node
var dialogue_system: Node

# 게임 상태
var score = 0
var stage = 1
var enemies_defeated = 0
var is_game_over = false
var current_region = "zhongyuan"
var current_dungeon = null
var active_quests = []
var player_inventory: Dictionary = {}  # item_id -> quantity
var player_gold: int = 1000
var current_dialogue_npc: String = ""

# 파당 시스템
var current_faction = "정파"
var faction_power = constants.FACTIONS

@export var enemies_per_stage = constants.GAME_ENEMIES_PER_STAGE
@export var difficulty_multiplier = 1.0
@export var stage_duration = constants.GAME_STAGE_DURATION

var enemy_scene = preload("res://src/scenes/enemy.tscn")
var spawn_points = []
var stage_timer = 0.0
var enemies_in_stage = 0
var boss_spawned = false

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Day 4: MartialArtEngine 로드
	var martial_engine = preload("res://src/scripts/martial_art_engine.gd").new()
	martial_engine.name = "MartialArtEngine"
	add_child(martial_engine)
	print("✅ MartialArtEngine 로드 완료")
	
	# Week 2: 새로운 시스템 로드
	region_manager = preload("res://src/scripts/region_manager.gd").new()
	dungeon_generator = preload("res://src/scripts/dungeon_generator.gd").new()
	quest_system = preload("res://src/scripts/quest_system.gd").new()
	add_child(region_manager)
	add_child(dungeon_generator)
	add_child(quest_system)
	
	# Day 4: 콘텐츠 확장
	npc_system = preload("res://src/scripts/npc_system.gd").new()
	item_system = preload("res://src/scripts/item_system.gd").new()
	dialogue_system = preload("res://src/scripts/dialogue_system.gd").new()
	add_child(npc_system)
	add_child(item_system)
	add_child(dialogue_system)
	
	print("\n=== Week 2-Day 4 시스템 초기화 ===")
	print("[시스템] 지역, 던전, 퀘스트 로드 완료")
	print("[시스템] NPC, 아이템, 대화 시스템 로드 완료")
	
	# 동적으로 spawn_points 그룹 설정
	var spawn_points_node = get_tree().get_root().find_child("SpawnPoints", true, false)
	if spawn_points_node:
		for child in spawn_points_node.get_children():
			child.add_to_group("spawn_points")
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	start_stage()

func _process(delta):
	if is_game_over:
		return
	
	stage_timer += delta
	
	# 적 스폰
	if enemies_in_stage < enemies_per_stage and not boss_spawned:
		spawn_enemy(false)
		enemies_in_stage += 1
	
	# 보스 스폰 (시간에 따라)
	if stage_timer > stage_duration * constants.GAME_BOSS_SPAWN_TIMING and not boss_spawned:
		spawn_enemy(true)
		boss_spawned = true
	
	# 스테이지 완료 체크
	if get_tree().get_nodes_in_group("enemies").size() == 0 and stage_timer > 5:
		next_stage()

func start_stage():
	stage = 1
	enemies_in_stage = 0
	boss_spawned = false
	stage_timer = 0.0

func spawn_enemy(is_boss: bool = false):
	if spawn_points.is_empty():
		return
	
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	
	if is_boss:
		# 보스 설정 [개선: 200 → 280]
		enemy.martial_level = constants.BOSS_LEVEL
		enemy.max_health = constants.BOSS_BASE_HEALTH
		enemy.health = constants.BOSS_BASE_HEALTH
		enemy.attack_damage = constants.BOSS_BASE_DAMAGE
		enemy.skill_chance = constants.BOSS_SKILL_CHANCE
		enemy.faction = "보스"
		enemy.is_boss = true  # [새 기능] 보스 AI 패턴 시스템 활성화
		print("=== 보스 출현! (HP: %d) ===" % constants.BOSS_BASE_HEALTH)
	else:
		# 일반 적 난이도 조정
		var level = randi() % 3 + 1
		enemy.martial_level = level
		enemy.max_health = constants.get_enemy_health(constants.ENEMY_BASE_HEALTH, level, stage)
		enemy.health = enemy.max_health
		enemy.attack_damage = constants.get_enemy_damage(constants.ENEMY_BASE_ATTACK_DAMAGE, level, stage)
		
		# 파당 선택
		var factions = ["정파", "사파", "독립"]
		enemy.faction = factions[randi() % factions.size()]
	
	add_child(enemy)

func next_stage():
	stage += 1
	enemies_in_stage = 0
	boss_spawned = false
	stage_timer = 0.0
	difficulty_multiplier += 0.15
	
	# 파당 변경
	if stage % 2 == 0:
		current_faction = "사파" if current_faction == "정파" else "정파"
	
	print("=== 스테이지 %d 시작! (난이도: %.1f) ===" % [stage, difficulty_multiplier])

func enemy_defeated(enemy):
	enemies_defeated += 1
	score += 100 * stage
	print("적 처치! 총 처치: %d, 점수: %d" % [enemies_defeated, score])

func add_score(points: int):
	score += points

func game_over(reason: String):
	is_game_over = true
	print("\n=== 게임 오버 ===")
	print("최종 점수: %d" % score)
	print("도달 스테이지: %d" % stage)
	print("처치한 적: %d" % enemies_defeated)
	print("패배 이유: %s" % reason)

# === Week 2: 지역/던전/퀘스트 함수들 ===

func change_region(region_id: String) -> bool:
	"""지역 변경"""
	if not region_manager:
		return false
	
	var region = region_manager.get_region(region_id)
	if not region:
		print("[ERROR] 지역을 찾을 수 없음: %s" % region_id)
		return false
	
	current_region = region_id
	print("\n=== 지역 변경: %s ==="% region.name)
	print("  난이도: %d" % region.difficulty)
	print("  NPC: %d명" % region.npcs.size())
	print("  퀘스트: %d개" % region.quests.size())
	return true

func enter_dungeon(dungeon_id: String) -> bool:
	"""던전 입장"""
	if not dungeon_generator:
		return false
	
	var dungeon = dungeon_generator.get_dungeon(dungeon_id)
	if not dungeon:
		print("[ERROR] 던중을 찾을 수 없음: %s" % dungeon_id)
		return false
	
	current_dungeon = dungeon
	print("\n=== 던중 입장: %s ==="% dungeon.name)
	print("  타입: %s" % dungeon.type)
	print("  난이도: %d" % dungeon.difficulty)
	print("  층: %d" % dungeon.layers)
	print("  보스: %s" % dungeon.boss)
	return true

func get_active_region() -> Dictionary:
	"""현재 지역 정보 반환"""
	if not region_manager:
		return {}
	var region = region_manager.get_region(current_region)
	if region:
		return {
			"name": region.name,
			"id": region.id,
			"difficulty": region.difficulty,
			"npcs": region.npcs.size(),
			"quests": region.quests.size()
		}
	return {}

func get_region_quests(region_id: String = "") -> Array:
	"""지역 퀘스트 목록"""
	if region_id == "":
		region_id = current_region
	
	if not region_manager:
		return []
	var region = region_manager.get_region(region_id)
	if region:
		return region.quests
	return []

func accept_quest(quest_id: String) -> bool:
	"""퀘스트 수락"""
	if not quest_system:
		return false
	
	var quest = quest_system.get_quest(quest_id)
	if not quest:
		print("[ERROR] 퀘스트를 찾을 수 없음: %s" % quest_id)
		return false
	
	if not quest_id in active_quests:
		active_quests.append(quest_id)
		print("\n[퀘스트 수락] %s" % quest.title)
		print("  주는 NPC: %s" % quest.giver)
		print("  필요 레벨: %d" % quest.level_required)
		return true
	return false

# === Day 4: NPC & 아이템 & 대화 시스템 ===

func start_dialogue_with_npc(npc_id: String) -> void:
	"""NPC와 대화 시작"""
	if not npc_system:
		return
	
	var npc = npc_system.get_npc(npc_id)
	if not npc:
		print("[ERROR] NPC를 찾을 수 없음: %s" % npc_id)
		return
	
	current_dialogue_npc = npc_id
	var dialogue_node = dialogue_system.start_dialogue(npc_id, npc.job)
	
	print("\n=== %s와 대화 시작 ===" % npc.name)
	if dialogue_node:
		print("%s: %s" % [npc.name, dialogue_node.text])
		dialogue_system.print_dialogue_options()

func get_npc_info(npc_id: String) -> Dictionary:
	"""NPC 정보 조회"""
	if not npc_system:
		return {}
	
	var npc = npc_system.get_npc(npc_id)
	if npc:
		return {
			"id": npc.id,
			"name": npc.name,
			"job": npc.job,
			"region": npc.region,
			"level": npc.level,
			"personality": npc.personality,
			"affinity": npc.affinity,
			"goods": npc.goods.size()
		}
	
	return {}

func get_region_npcs_list(region: String = "") -> Array:
	"""지역 내 NPC 목록"""
	if region == "":
		region = current_region
	
	if not npc_system:
		return []
	
	return npc_system.get_region_npcs(region)

func trade_with_npc(npc_id: String, trade_id: String, quantity: int) -> bool:
	"""NPC와 거래"""
	if not npc_system or not item_system:
		return false
	
	var cost = npc_system.buy_from_npc(npc_id, trade_id, quantity)
	if cost > 0 and player_gold >= cost:
		player_gold -= cost
		var item_id = trade_id  # 간단한 버전
		if player_inventory.has(item_id):
			player_inventory[item_id] += quantity
		else:
			player_inventory[item_id] = quantity
		
		print("[거래] NPC %s에게서 구매 완료 (비용: %d 골드)" % [npc_id, cost])
		npc_system.change_affinity(npc_id, 5)
		return true
	
	return false

# === 아이템 시스템 ===

func get_item_info(item_id: String) -> Dictionary:
	"""아이템 정보 조회"""
	if not item_system:
		return {}
	
	var item = item_system.get_item(item_id)
	if item:
		return {
			"id": item.id,
			"name": item.name,
			"category": item.category,
			"rarity": item.rarity,
			"level": item.level,
			"price": item.price,
			"stats": item.stats,
			"effect": item.effect
		}
	
	return {}

func add_item(item_id: String, quantity: int = 1) -> void:
	"""인벤토리에 아이템 추가"""
	if player_inventory.has(item_id):
		player_inventory[item_id] += quantity
	else:
		player_inventory[item_id] = quantity
	
	print("[아이템] %s × %d 획득" % [item_id, quantity])

func remove_item(item_id: String, quantity: int = 1) -> bool:
	"""인벤토리에서 아이템 제거"""
	if player_inventory.has(item_id) and player_inventory[item_id] >= quantity:
		player_inventory[item_id] -= quantity
		if player_inventory[item_id] == 0:
			player_inventory.erase(item_id)
		return true
	return false

func get_player_inventory() -> Dictionary:
	"""인벤토리 조회"""
	return player_inventory.duplicate()

func get_player_gold() -> int:
	"""골드 조회"""
	return player_gold

func add_gold(amount: int) -> void:
	"""골드 추가"""
	player_gold += amount
	print("[골드] %d 골드 획득 (보유: %d)" % [amount, player_gold])

func drop_items(player_level: int) -> Array:
	"""적 처치 시 아이템 드롭"""
	if not item_system:
		return []
	
	var dropped = item_system.simulate_drop("enemy", player_level)
	for item_id in dropped:
		add_item(item_id)
	
	return dropped

func drop_items_from_boss(player_level: int) -> Array:
	"""보스 처치 시 아이템 드롭"""
	if not item_system:
		return []
	
	var dropped = item_system.simulate_drop("boss", player_level)
	for item_id in dropped:
		add_item(item_id)
	
	return dropped

func print_game_status():
	"""게임 상태 출력"""
	print("\n=== 게임 상태 ===")
	print("점수: %d" % score)
	print("스테이지: %d" % stage)
	print("처치한 적: %d" % enemies_defeated)
	print("현재 지역: %s" % current_region)
	if current_dungeon:
		print("현재 던중: %s" % current_dungeon.name)
	print("진행 중인 퀘스트: %d개" % active_quests.size())
	print("\n=== 플레이어 정보 ===")
	print("골드: %d" % player_gold)
	print("인벤토리: %d개" % player_inventory.size())
