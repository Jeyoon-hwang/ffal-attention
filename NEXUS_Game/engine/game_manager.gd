# NEXUS 게임 관리자
# 게임 루프, 전투 관리, 스테이지 진행
#
# 주요 기능:
# - 게임 시작/종료
# - 플레이어 - 적 전투 시뮬레이션
# - 스테이지 관리
# - 진도 추적

extends Node

class_name GameManager

# ============================================================================
# 멤버 변수
# ============================================================================

var martial_engine: MartialArtEngine
var player_combat: PlayerCombat
var enemy_ai: EnemyAI
var current_stage: int = 1
var is_in_combat: bool = false
var combat_log: Array[String] = []

# 게임 상태
var game_state: String = "MENU" # MENU, PLAYING, PAUSED, GAME_OVER

# ============================================================================
# 초기화
# ============================================================================

func _ready() -> void:
	# 엔진 초기화
	martial_engine = MartialArtEngine.new()
	martial_engine.initialize_base_arts()
	
	# 플레이어 초기화
	player_combat = PlayerCombat.new()
	player_combat.martial_engine = martial_engine
	player_combat._ready()
	
	# 적 AI 초기화
	enemy_ai = EnemyAI.new()
	enemy_ai.martial_engine = martial_engine
	enemy_ai._ready()
	
	print("게임 관리자 초기화 완료")
	print("=" * 60)

# ============================================================================
# 게임 루프
# ============================================================================

func start_game() -> void:
	print("\n🎮 게임 시작!")
	print("=" * 60)
	
	game_state = "PLAYING"
	current_stage = 1
	
	player_combat.hp = player_combat.max_hp
	player_combat.mp = player_combat.max_mp
	player_combat.spirit = 0.0
	
	# 첫 번째 스테이지 시작
	start_stage(1)

func start_stage(stage_number: int) -> void:
	current_stage = stage_number
	is_in_combat = true
	combat_log.clear()
	
	print("\n" + "=" * 60)
	print("🥋 Stage %d 시작!" % stage_number)
	print("=" * 60)
	
	# 플레이어 상태 표시
	print_player_status()
	
	# 적 AI 레벨 결정 (스테이지에 따라)
	var enemy_level = _get_enemy_level_for_stage(stage_number)
	enemy_ai.initialize(enemy_level, player_combat)
	
	# 전투 시뮬레이션
	simulate_combat()

## 적 AI 레벨 결정
func _get_enemy_level_for_stage(stage: int) -> int:
	match stage:
		1, 2:
			return EnemyAI.AILevel.BASIC
		3, 4, 5:
			return EnemyAI.AILevel.TACTICAL
		6, 7, 8, 9:
			return EnemyAI.AILevel.ADAPTIVE
		_:
			return EnemyAI.AILevel.MASTER

# ============================================================================
# 전투 시뮬레이션
# ============================================================================

func simulate_combat() -> void:
	var combat_round = 0
	
	while is_in_combat and player_combat.hp > 0 and enemy_ai.hp > 0:
		combat_round += 1
		
		print("\n[Round %d]" % combat_round)
		print("-" * 40)
		
		# 플레이어 턴
		var player_action = _player_turn()
		await get_tree().create_timer(0.5).timeout
		
		# 적 턴
		if enemy_ai.hp > 0:
			_enemy_turn()
			await get_tree().create_timer(0.5).timeout
		
		# 상황 업데이트
		print_battle_status()
		
		# 너무 길어지면 중단 (테스트용)
		if combat_round > 50:
			print("\n⚠️ 전투가 너무 길어졌습니다. 중단합니다.")
			is_in_combat = false
			break
		
		await get_tree().create_timer(0.3).timeout
	
	# 전투 결과
	_end_combat()

## 플레이어 턴
func _player_turn() -> String:
	# 자동 공격 (첫 번째 장착 무술)
	var art = player_combat.use_martial_art(0)
	
	if art == null:
		# 마나 부족이면 기본 공격
		player_combat.mp = player_combat.max_mp
		art = player_combat.use_martial_art(0)
	
	if art != null:
		# 적 데미지 계산
		var damage = player_combat.martial_engine.calculate_damage(art, player_combat.player_stats)
		enemy_ai.hp = max(0.0, enemy_ai.hp - damage)
		
		log_combat("[플레이어] %s으로 공격 (%.0f 데미지)" % [art.name, damage])
		return "ATTACK"
	else:
		log_combat("[플레이어] 공격 실패 (마나 부족)")
		return "IDLE"

## 적 턴
func _enemy_turn() -> void:
	enemy_ai._make_decision()
	enemy_ai._update_state(0.1)
	
	match enemy_ai.current_state:
		EnemyAI.AIState.ATTACKING:
			var damage = 10.0 + (enemy_ai.ai_level * 5.0)
			player_combat.hp = max(0.0, player_combat.hp - damage)
			log_combat("[적] 공격으로 %.0f 데미지 입힘" % damage)
		
		EnemyAI.AIState.EVADING:
			log_combat("[적] 회피 상태")
		
		EnemyAI.AIState.PURSUING:
			log_combat("[적] 플레이어를 추적 중")

## 전투 종료
func _end_combat() -> void:
	is_in_combat = false
	
	print("\n" + "=" * 60)
	if player_combat.hp <= 0:
		print("💀 패배! 플레이어가 전투에서 졌습니다.")
		game_state = "GAME_OVER"
	elif enemy_ai.hp <= 0:
		print("✨ 승리! 적을 격파했습니다!")
		# 다음 스테이지로
		await get_tree().create_timer(2.0).timeout
		start_stage(current_stage + 1)
	print("=" * 60)

# ============================================================================
# 상태 표시
# ============================================================================

func print_player_status() -> void:
	print("\n[플레이어 상태]")
	print("HP: %.0f/%.0f | MP: %.0f/%.0f | Spirit: %.0f/%.0f" % 
		[player_combat.hp, player_combat.max_hp, 
		 player_combat.mp, player_combat.max_mp,
		 player_combat.spirit, player_combat.max_spirit])
	print("능력치: STR %d | DEX %d | INT %d" % 
		[player_combat.player_stats["str"], 
		 player_combat.player_stats["dex"],
		 player_combat.player_stats["int"]])

func print_battle_status() -> void:
	print("[HP] 플레이어: %.0f/%.0f | 적: %.0f/%.0f" % 
		[player_combat.hp, player_combat.max_hp,
		 enemy_ai.hp, enemy_ai.max_hp])

func log_combat(message: String) -> void:
	combat_log.append(message)
	print(message)

# ============================================================================
# 진도 추적
# ============================================================================

func get_game_progress() -> String:
	return "Stage %d | HP: %.0f%% | 전투 로그: %d줄" % 
		[current_stage, 
		 (player_combat.hp / player_combat.max_hp) * 100,
		 combat_log.size()]

# ============================================================================
# 메인 테스트
# ============================================================================

func test_full_game() -> void:
	print("\n>>> 게임 풀 테스트 시작")
	print("=" * 60)
	
	start_game()
	
	# 게임이 끝날 때까지 대기
	while game_state == "PLAYING":
		await get_tree().create_timer(1.0).timeout
	
	print("\n>>> 게임 테스트 완료")
	print("=" * 60)
