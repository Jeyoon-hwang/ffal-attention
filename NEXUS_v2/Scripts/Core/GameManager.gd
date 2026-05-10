## GameManager.gd - 게임 전체 관리자
## 싱글톤 패턴으로 게임 상태 관리

class_name GameManager
extends Node

# ===== 싱글톤 =====
static var instance: GameManager = null

# ===== 게임 상태 =====
var game_state: String = "menu"  # menu, playing, paused, game_over
var is_running: bool = false

# ===== 캐릭터 =====
var player: Player = null
var current_enemy: Enemy = null
var all_enemies: Array[Enemy] = []

# ===== 시스템 =====
var combat_system: CombatSystem = null
var data_loader: DataLoader = null

# ===== 무술 데이터 =====
var all_martial_arts: Array[MartialArt] = []

# ===== 신호 =====
signal game_started()
signal game_over(victor: Character)
signal round_ended()

func _ready() -> void:
	"""게임 매니저 초기화"""
	
	# 싱글톤 패턴
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	
	print("[GameManager] 초기화 중...")
	
	# 데이터 로더 생성
	data_loader = DataLoader.new()
	
	# 무술 데이터 로드
	load_game_data()
	
	# 전투 시스템 생성
	combat_system = CombatSystem.new()
	add_child(combat_system)
	
	print("[GameManager] 초기화 완료!")

# ===== 게임 데이터 로드 =====

func load_game_data() -> void:
	"""게임 데이터를 로드한다"""
	
	print("[GameManager] 게임 데이터 로드 중...")
	
	# 무술 데이터 로드
	all_martial_arts = DataLoader.load_martial_arts()
	print("[GameManager] 로드된 무술: %d개" % all_martial_arts.size())
	
	# 각 무술 정보 출력
	for martial in all_martial_arts:
		print("  - %s (데미지: %d, 에너지: %d)" % [martial.martial_name, martial.base_damage, martial.energy_cost])

# ===== 게임 시작 =====

func start_game() -> void:
	"""게임을 시작한다"""
	
	if game_state != "menu":
		print("[GameManager] 게임이 이미 실행 중입니다!")
		return
	
	print("\n========================================")
	print("🎮 NEXUS v2 게임 시작!")
	print("========================================\n")
	
	# 플레이어 생성
	player = DataLoader.create_default_player()
	player.add_child(player)
	
	# 첫 번째 무술 장착
	for i in range(min(all_martial_arts.size(), 5)):
		player.add_martial_art(all_martial_arts[i], i)
	
	print("[GameManager] 플레이어 생성: %s" % player.character_name)
	player.print_status()
	
	game_state = "playing"
	is_running = true
	game_started.emit()

# ===== 전투 시작 =====

func start_combat_with_enemy(enemy_name: String = "회색 늑대", enemy_level: int = 1, is_boss: bool = false) -> void:
	"""적과의 전투를 시작한다"""
	
	if not player or not is_running:
		print("[GameManager] 게임이 진행 중이 아닙니다!")
		return
	
	# 적 생성
	current_enemy = Enemy.new()
	current_enemy.character_name = enemy_name
	current_enemy.level = enemy_level
	current_enemy.max_hp = 50 + enemy_level * 10
	current_enemy.current_hp = current_enemy.max_hp
	current_enemy.max_energy = 50
	current_enemy.current_energy = 50
	current_enemy.drop_experience = 50 * enemy_level
	
	# 스탯 설정
	current_enemy.stats = {
		"STR": 8 + enemy_level,
		"DEX": 9 + enemy_level,
		"CON": 7 + enemy_level,
		"INT": 3,
		"WIS": 5,
		"CHA": 2
	}
	
	# 무술 할당
	var num_martials = min(enemy_level, all_martial_arts.size())
	for i in range(num_martials):
		current_enemy.add_martial_art(all_martial_arts[i], i)
	
	# AI 레벨 설정 (적 레벨에 따라)
	if current_enemy.ai_controller:
		current_enemy.ai_controller.ai_level = clamp((enemy_level - 1) / 5 + 1, 1, 4)
		current_enemy.ai_controller.set_target(player)
	
	# 보스 설정
	if is_boss:
		current_enemy.set_as_boss(true)
	
	# 전투 시스템에 전달
	combat_system.start_combat(player, current_enemy)
	
	# 전투 루프 시작
	await execute_combat_loop()

# ===== 전투 루프 =====

async func execute_combat_loop() -> void:
	"""전투 루프를 실행한다"""
	
	var turn_count = 0
	var max_turns = 100  # 최대 100턴
	
	while combat_system.is_combat_active and turn_count < max_turns:
		turn_count += 1
		
		# 플레이어 턴 (입력 대기)
		print("\n[턴 %d] 플레이어의 차례 (무술 선택: 1-5번 키, Q: 상태 보기)" % turn_count)
		
		# 플레이어 입력 대기 (약간의 대기 시간)
		await get_tree().create_timer(1.0).timeout
		
		# 플레이어가 입력하지 않으면 회피
		if player.last_executed_martial == null:
			print("[플레이어] 입력 없음 - 기본권 발동")
			var basic = all_martial_arts[0] if all_martial_arts.size() > 0 else null
			if basic:
				combat_system.apply_martial_attack(player, basic, current_enemy)
		
		# 적 턴
		if combat_system.is_combat_active and current_enemy.is_alive:
			await get_tree().create_timer(0.5).timeout
			
			print("[턴 %d] 적의 차례" % turn_count)
			
			# AI가 공격
			if current_enemy.ai_controller:
				current_enemy.ai_controller.update(0.016)
				
				# 적이 공격하면
				var enemy_martial = current_enemy.martial_arts[0] if current_enemy.martial_arts.size() > 0 else null
				if enemy_martial and randf() > 0.3:
					combat_system.apply_martial_attack(current_enemy, enemy_martial, player)
	
	# 전투 종료
	if not combat_system.is_combat_active:
		handle_combat_end()
	else:
		print("[GameManager] 턴 초과 - 전투 종료")
		combat_system.end_combat(player, current_enemy)
		handle_combat_end()

# ===== 전투 종료 =====

func handle_combat_end() -> void:
	"""전투 종료 처리"""
	
	if not player.is_alive:
		print("\n[게임 오버] 플레이어가 패배했습니다!")
		game_state = "game_over"
		is_running = false
		game_over.emit(current_enemy)
	else:
		print("\n[승리!] %s를 격파했습니다!" % current_enemy.character_name)
		combat_system.print_log()
		
		# 플레이어 상태 출력
		player.print_status()

# ===== 게임 상태 =====

func get_game_state() -> String:
	"""게임 상태를 반환한다"""
	return game_state

func print_game_status() -> void:
	"""게임 상태를 출력한다"""
	print("\n===== 게임 상태 =====")
	print("상태: %s" % game_state)
	print("플레이어: %s" % (player.character_name if player else "없음"))
	
	if player:
		print("  HP: %d/%d" % [player.current_hp, player.max_hp])
		print("  Level: %d | Exp: %d" % [player.level, player.experience])
	
	if current_enemy:
		print("현재 적: %s" % current_enemy.character_name)
		print("  HP: %d/%d" % [current_enemy.current_hp, current_enemy.max_hp])
	
	print("=" * 30 + "\n")

# ===== 싱글톤 접근 =====

static func get_instance() -> GameManager:
	"""게임 매니저 인스턴스 반환"""
	return instance
