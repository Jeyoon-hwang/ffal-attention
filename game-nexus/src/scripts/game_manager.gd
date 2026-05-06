extends Node

# ⚡ 글로벌 상수
var constants = preload("res://src/scripts/constants.gd")
var particle_effects = null  # 파티클 이펙트 시스템

# 게임 상태
var score = 0
var stage = 1
var enemies_defeated = 0
var is_game_over = false

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
