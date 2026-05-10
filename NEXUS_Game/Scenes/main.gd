extends Node3D
class_name MainScene
## 게임 메인 씬 - 모든 시스템의 진입점

# 시스템 & 매니저
var game_manager: GameManager
var input_manager: InputManager
var audio_manager: AudioManager
var camera_manager: CameraManager
var world_manager: WorldManager

# 게임 요소
@onready var player: Player = $Player
@onready var hud: GameHUD = $HUD
@onready var pause_menu: PauseMenu = $PauseMenu

# 상태
var is_paused: bool = false
var current_region: String = "中原"  # 중원 (시작 지역)

func _ready():
	"""게임 초기화"""
	# 매니저 초기화
	game_manager = GameManager.new()
	input_manager = InputManager.new()
	audio_manager = AudioManager.new()
	camera_manager = CameraManager.new()
	world_manager = WorldManager.new()
	
	# 플레이어 초기화
	if player:
		player.health = 100
		player.max_health = 100
		player.energy = 50
		player.max_energy = 50
		player.level = 1
	
	# 월드 초기화
	_initialize_world()
	
	# 신호 연결
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	
	# 시작 위치 설정
	player.position = Vector3(0, 1, 0)
	
	print("게임 시작: %s 지역" % current_region)

## ===== 월드 초기화 =====

func _initialize_world():
	"""월드 & 지역 초기화"""
	# 첫 지역 (중원) 로드
	_load_region("中原")
	
	# NPC 배치
	_spawn_npcs()
	
	# 몬스터 배치
	_spawn_enemies()
	
	# 던전 입구 배치
	_spawn_dungeons()

func _load_region(region_name: String):
	"""지역 로드"""
	print("지역 로드: %s" % region_name)
	current_region = region_name
	
	# 지역별 환경 설정 (구현 필요)
	match region_name:
		"中原":
			# 기본 환경
			_setup_central_plain()
		"天山":
			# 산악 환경
			_setup_heavenly_mountain()
		"황무지":
			_setup_wasteland()
		"동해":
			_setup_east_sea()
		"흑룡굴":
			_setup_black_dragon_cave()

func _setup_central_plain():
	"""중원 환경 설정"""
	# 물리 환경
	var ground = CSGBox3D.new()
	ground.size = Vector3(500, 1, 500)
	ground.position.y = -1
	add_child(ground)
	
	# 조명
	var sun = DirectionalLight3D.new()
	sun.transform.basis = Basis.from_euler(Vector3(PI/4, PI/4, 0))
	sun.energy_multiplier = 1.2
	add_child(sun)
	
	# 배경 (하늘)
	var sky = WorldEnvironment.new()
	var env = Environment.new()
	env.ambient_light_source = Environment.AMBIENT_LIGHT_DISABLED
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.SKY_BLUE
	sky.environment = env
	add_child(sky)

func _setup_heavenly_mountain():
	"""천산 환경 설정"""
	# 구현 필요
	pass

func _setup_wasteland():
	"""황무지 환경 설정"""
	pass

func _setup_east_sea():
	"""동해 환경 설정"""
	pass

func _setup_black_dragon_cave():
	"""흑룡굴 환경 설정"""
	pass

## ===== NPC 스포닝 =====

func _spawn_npcs():
	"""NPC 배치"""
	var npcs = [
		{"name": "무술관", "pos": Vector3(10, 0, 10), "type": "martial_master"},
		{"name": "상인", "pos": Vector3(20, 0, 20), "type": "merchant"},
		{"name": "수도사", "pos": Vector3(-10, 0, -10), "type": "monk"},
		{"name": "전사", "pos": Vector3(30, 0, 0), "type": "warrior"},
		{"name": "궁수", "pos": Vector3(-20, 0, 20), "type": "archer"},
		{"name": "마법사", "pos": Vector3(0, 0, -30), "type": "mage"}
	]
	
	for npc_data in npcs:
		var npc = NPC.new()
		npc.name = npc_data.name
		npc.position = npc_data.pos
		npc.npc_type = npc_data.type
		
		# NPC별 스크립트 할당
		match npc_data.type:
			"martial_master":
				npc.dialog_options = [
					{"text": "무술을 배우겠습니까?", "action": "teach_martial_art"},
					{"text": "무술을 강화하겠습니까?", "action": "upgrade_martial_art"}
				]
			"merchant":
				npc.dialog_options = [
					{"text": "물건을 팔겠습니까?", "action": "open_shop"},
					{"text": "창고를 확인하시겠습니까?", "action": "open_storage"}
				]
			"monk":
				npc.dialog_options = [
					{"text": "마음을 수양하겠습니까?", "action": "meditate"},
					{"text": "퀘스트를 받겠습니까?", "action": "quest_offer"}
				]
		
		add_child(npc)

## ===== 몬스터 스포닝 =====

func _spawn_enemies():
	"""적 배치"""
	var enemies_data = [
		{"type": "wolf", "pos": Vector3(50, 0, 50), "level": 1, "count": 3},
		{"type": "bat", "pos": Vector3(-50, 0, 50), "level": 1, "count": 2},
		{"type": "skeleton", "pos": Vector3(50, 0, -50), "level": 2, "count": 2},
		{"type": "bear", "pos": Vector3(-50, 0, -50), "level": 2, "count": 1}
	]
	
	for enemy_group in enemies_data:
		for i in range(enemy_group.count):
			var enemy = Enemy.new()
			enemy.enemy_type = enemy_group.type
			enemy.level = enemy_group.level
			enemy.position = enemy_group.pos + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
			enemy.target = player
			add_child(enemy)

## ===== 던전 스포닝 =====

func _spawn_dungeons():
	"""던전 입구 배치"""
	var dungeons = [
		{"name": "숲의 미로", "pos": Vector3(100, 0, 0), "level": 1},
		{"name": "산적 소굴", "pos": Vector3(0, 0, 100), "level": 2},
		{"name": "폐허", "pos": Vector3(-100, 0, 0), "level": 3},
		{"name": "동굴", "pos": Vector3(0, 0, -100), "level": 2},
		{"name": "고대 사원", "pos": Vector3(70, 0, 70), "level": 3}
	]
	
	for dungeon in dungeons:
		var entrance = DungeonEntrance.new()
		entrance.dungeon_name = dungeon.name
		entrance.position = dungeon.pos
		entrance.difficulty_level = dungeon.level
		entrance.player = player
		add_child(entrance)

## ===== 게임 루프 =====

func _process(delta: float):
	"""매 프레임 업데이트"""
	if is_paused:
		return
	
	# 플레이어 입력 처리
	_handle_player_input()
	
	# 월드 업데이트
	_update_world(delta)

func _handle_player_input():
	"""플레이어 입력 처리"""
	# 이동
	var velocity = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		velocity.z -= 1
	if Input.is_action_pressed("move_backward"):
		velocity.z += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	velocity = velocity.normalized() * 10  # 이동 속도
	player.velocity = velocity
	
	# 공격
	if Input.is_action_just_pressed("attack"):
		var martial = player.equipped_martial_arts[0] if player.equipped_martial_arts.size() > 0 else null
		if martial:
			player.use_martial_art(martial, null)  # null = 자동 조준
	
	# 방어
	if Input.is_action_pressed("defend"):
		player.start_defending()
	elif Input.is_action_just_released("defend"):
		player.stop_defending()
	
	# 메뉴
	if Input.is_action_just_pressed("ui_cancel"):
		_pause_game()
	
	# 인벤토리
	if Input.is_action_just_pressed("inventory"):
		_open_inventory()

func _update_world(delta: float):
	"""월드 업데이트"""
	# 물리 시뮬레이션 (이미 Godot이 처리)
	
	# AI 업데이트
	for child in get_children():
		if child is Enemy:
			child.update_ai(delta, player.position)
	
	# HUD 업데이트
	hud.update_mini_map(player.position, [])

## ===== UI 관리 =====

func _pause_game():
	"""게임 일시정지"""
	is_paused = true
	pause_menu.show()

func _resume_game():
	"""게임 재개"""
	is_paused = false
	pause_menu.hide()

func _open_inventory():
	"""인벤토리 열기"""
	_pause_game()
	var inventory_ui = InventoryUI.new()
	add_child(inventory_ui)
	inventory_ui.inventory_closed.connect(func(): _resume_game())

## ===== 이벤트 핸들러 =====

func _on_player_health_changed(new_health: float, max_health: float):
	"""플레이어 체력 변화"""
	hud.player_health_bar.value = (new_health / max_health) * 100

func _on_player_died():
	"""플레이어 사망"""
	print("플레이어 사망!")
	_show_game_over_screen()

func _show_game_over_screen():
	"""게임 오버 화면"""
	var game_over = Control.new()
	var label = Label.new()
	label.text = "게임 오버"
	label.add_theme_font_size_override("font_size", 48)
	game_over.add_child(label)
	add_child(game_over)
	
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

## ===== 세이브/로드 =====

func save_game():
	"""게임 저장"""
	var save_data = {
		"player": {
			"position": player.position,
			"level": player.level,
			"health": player.health,
			"experience": player.experience,
			"gold": player.gold,
			"martial_arts": player.learned_martial_arts,
			"inventory": player.inventory
		},
		"region": current_region,
		"playtime": get_tree().get_frame()
	}
	
	var error = ResourceSaver.save(save_data, "user://savegame.res")
	if error != OK:
		print("저장 실패: ", error)
	else:
		print("게임 저장됨")

func load_game():
	"""게임 로드"""
	if ResourceLoader.exists("user://savegame.res"):
		var save_data = ResourceLoader.load("user://savegame.res")
		if save_data:
			player.position = save_data.player.position
			player.level = save_data.player.level
			player.health = save_data.player.health
			player.experience = save_data.player.experience
			player.gold = save_data.player.gold
			print("게임 로드됨")

## ===---- 도움말 클래스들 ----

## 단순 NPC 클래스
class NPC:
	extends Node3D
	var name: String
	var npc_type: String
	var dialog_options: Array = []
	var is_interactive: bool = true

## 단순 Enemy 클래스
class Enemy:
	extends Node3D
	var enemy_type: String
	var level: int = 1
	var health: float = 20
	var max_health: float = 20
	var target: Node3D = null
	var ai_state: String = "idle"
	
	func update_ai(delta: float, target_pos: Vector3):
		"""AI 업데이트"""
		if target == null:
			return
		
		var distance = position.distance_to(target_pos)
		if distance < 50:
			ai_state = "chase"
			# 플레이어 방향으로 이동
		elif distance < 100:
			ai_state = "alert"
		else:
			ai_state = "idle"

## DungeonEntrance 클래스
class DungeonEntrance:
	extends Node3D
	var dungeon_name: String
	var difficulty_level: int = 1
	var player: Node3D = null
	var is_open: bool = true
	
	func _ready():
		# 시각화 (구현 필요)
		pass
	
	func enter_dungeon():
		"""던전 진입"""
		if player and is_open:
			print("던전 진입: %s" % dungeon_name)
			# 던전 씬 로드

## 단순 GameManager 클래스
class GameManager:
	var playtime: float = 0.0
	
	func save():
		pass
	
	func load():
		pass

## 단순 InputManager 클래스
class InputManager:
	pass

## 단순 AudioManager 클래스
class AudioManager:
	pass

## 단순 CameraManager 클래스
class CameraManager:
	pass

## 단순 WorldManager 클래스
class WorldManager:
	pass

## 단순 PauseMenu 클래스
class PauseMenu:
	extends Control
	var is_visible: bool = false
	
	func show():
		is_visible = true
		visible = true
	
	func hide():
		is_visible = false
		visible = false
