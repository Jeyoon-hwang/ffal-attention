# 🥋 NEXUS Day 7: 중원 지역 (첫 번째 지역)
# 게임의 첫 번째 플레이 지역, 보스 전투 포함

extends Node3D

class_name CentralRegion

# 지역 정보
const REGION_NAME = "중원"
const REGION_DESCRIPTION = "예로부터 무술의 중심지. 무술대가들이 모여드는 곳이다."
const REGION_SIZE = 500.0  # 500m x 500m

# 스포지션
var region_center = Vector3.ZERO
var player_spawn_point = Vector3(0, 2, -50)
var boss_spawn_point = Vector3(0, 2, 50)

# 적 배치
var enemy_spawns = []
var max_enemies = 10
var active_enemies = []

# 보스
var boss: FirstBoss = null
var boss_arena_center = Vector3(0, 0, 100)
var boss_arena_radius = 30.0
var boss_defeated = false

# 환경
var ground_mesh: MeshInstance3D
var environmental_obstacles = []
var checkpoint_locations = {}

# 플레이어
var player: Node = null

# 상태
var region_cleared = false
var enemies_remaining = 0


func _ready() -> void:
	"""지역 초기화"""
	print("\n🌏 ========== 중원 지역 초기화 ==========")
	print("지역명: %s" % REGION_NAME)
	print("설명: %s" % REGION_DESCRIPTION)
	print("크기: %.0f x %.0f m" % [REGION_SIZE, REGION_SIZE])
	print("=========================================\n")
	
	# 환경 생성
	setup_environment()
	
	# 적 배치
	setup_enemies()
	
	# 보스 생성
	spawn_boss()
	
	# 체크포인트 설정
	setup_checkpoints()


func setup_environment() -> void:
	"""환경 설정"""
	print("[환경 설정]")
	
	# 지면 생성
	create_ground()
	
	# 장애물 생성
	create_obstacles()
	
	# 조명 설정
	setup_lighting()
	
	print("✅ 환경 준비 완료")


func create_ground() -> void:
	"""지면 생성"""
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(REGION_SIZE, REGION_SIZE)
	
	ground.mesh = plane_mesh
	ground.position = Vector3(0, 0, 0)
	
	# 물리 추가
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = Vector3(REGION_SIZE, 1, REGION_SIZE)
	collision_shape.position = Vector3(0, -0.5, 0)
	
	static_body.add_child(collision_shape)
	add_child(ground)
	add_child(static_body)
	
	ground_mesh = ground


func create_obstacles() -> void:
	"""장애물 생성"""
	# 경관 장애물 (돌, 나무 등)
	var obstacle_positions = [
		Vector3(-100, 1, 0),
		Vector3(100, 1, 0),
		Vector3(0, 1, 100),
		Vector3(-50, 1, -50),
		Vector3(50, 1, 50),
		Vector3(-80, 1, -80),
		Vector3(80, 1, -80),
	]
	
	for pos in obstacle_positions:
		var obstacle = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(20, 20, 20)
		
		obstacle.mesh = box_mesh
		obstacle.position = pos
		
		# 물리 추가
		var static_body = StaticBody3D.new()
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = BoxShape3D.new()
		collision_shape.shape.size = Vector3(20, 20, 20)
		
		static_body.add_child(collision_shape)
		obstacle.add_child(static_body)
		
		add_child(obstacle)
		environmental_obstacles.append(obstacle)


func setup_lighting() -> void:
	"""조명 설정"""
	# 주광
	var sun = DirectionalLight3D.new()
	sun.rotation = Vector3(PI / 4, PI / 4, 0)
	add_child(sun)
	
	# 환경광
	var ambient = WorldEnvironment.new()
	add_child(ambient)


func setup_enemies() -> void:
	"""적 배치"""
	print("[적 배치]")
	
	# 적 스폰 지점 설정
	enemy_spawns = [
		{"pos": Vector3(-80, 1, -40), "type": "BEAST", "level": 1},
		{"pos": Vector3(-60, 1, -60), "type": "NOVICE", "level": 2},
		{"pos": Vector3(-40, 1, 0), "type": "NOVICE", "level": 2},
		{"pos": Vector3(0, 1, -80), "type": "NOVICE", "level": 2},
		{"pos": Vector3(40, 1, -40), "type": "EXPERT", "level": 3},
		{"pos": Vector3(60, 1, 0), "type": "EXPERT", "level": 3},
		{"pos": Vector3(-40, 1, 60), "type": "NOVICE", "level": 2},
		{"pos": Vector3(0, 1, 60), "type": "EXPERT", "level": 3},
		{"pos": Vector3(40, 1, 80), "type": "EXPERT", "level": 3},
		{"pos": Vector3(-80, 1, 40), "type": "BEAST", "level": 1},
	]
	
	enemies_remaining = enemy_spawns.size()
	print("총 %d개 적 배치 (보스 제외)" % enemies_remaining)


func spawn_boss() -> void:
	"""보스 생성"""
	print("\n[보스 소환]")
	
	boss = FirstBoss.new()
	boss.global_position = boss_spawn_point
	
	print("✅ 보스 소환: %s (Lv. %d)" % [boss.BOSS_NAME, boss.BOSS_LEVEL])
	print("   위치: %.0f, %.0f, %.0f" % [boss_spawn_point.x, boss_spawn_point.y, boss_spawn_point.z])


func setup_checkpoints() -> void:
	"""체크포인트 설정"""
	checkpoint_locations = {
		"entrance": player_spawn_point,
		"mid_point": Vector3(0, 2, 0),
		"boss_arena": boss_arena_center,
	}
	
	print("\n[체크포인트]")
	for name in checkpoint_locations.keys():
		print("  - %s" % name)


func set_player(player_node: Node) -> void:
	"""플레이어 설정"""
	player = player_node
	if player:
		player.global_position = player_spawn_point
		boss.set_target(player)
		print("\n플레이어 스폰: (%.0f, %.0f, %.0f)" % [player.global_position.x, player.global_position.y, player.global_position.z])


func _physics_process(delta: float) -> void:
	"""프레임 업데이트"""
	if not player or boss_defeated:
		return
	
	# 플레이어가 보스 영역에 진입했는지 확인
	check_boss_arena_entry()
	
	# 보스 업데이트
	if boss and boss.current_target == null:
		boss.set_target(player)
	
	# 남은 적 확인
	update_enemy_count()


func check_boss_arena_entry() -> void:
	"""플레이어가 보스 영역에 진입했는지 확인"""
	if not player:
		return
	
	var distance_to_boss = player.global_position.distance_to(boss_arena_center)
	
	if distance_to_boss < boss_arena_radius:
		# 보스 전투 시작
		if not boss.current_target:
			print("\n🔥 ========== 보스 전투 시작! ==========")
			print("상대: %s (Lv. %d)" % [boss.BOSS_NAME, boss.BOSS_LEVEL])
			print("=====================================\n")
			boss.set_target(player)


func update_enemy_count() -> void:
	"""남은 적 수 업데이트"""
	# 실제 게임에서는 active_enemies 배열을 유지하고 업데이트
	pass


func on_boss_defeated() -> void:
	"""보스 격파 이벤트"""
	boss_defeated = true
	region_cleared = true
	
	print("\n🎉 ========== 중원 지역 클리어! ==========")
	print("다음 지역으로 진출 가능")
	print("============================================\n")


func get_region_info() -> Dictionary:
	"""지역 정보 반환"""
	return {
		"name": REGION_NAME,
		"description": REGION_DESCRIPTION,
		"size": REGION_SIZE,
		"player_position": player.global_position if player else Vector3.ZERO,
		"boss_health": boss.health if boss else 0,
		"boss_max_health": boss.max_health if boss else 0,
		"enemies_remaining": enemies_remaining,
		"cleared": region_cleared,
	}


func get_boss_arena_info() -> Dictionary:
	"""보스 영역 정보 반환"""
	return {
		"center": boss_arena_center,
		"radius": boss_arena_radius,
		"boss_name": boss.BOSS_NAME if boss else "",
		"boss_level": boss.BOSS_LEVEL if boss else 0,
	}


func get_checkpoint_location(checkpoint_name: String) -> Vector3:
	"""체크포인트 위치 반환"""
	return checkpoint_locations.get(checkpoint_name, Vector3.ZERO)


func respawn_player_at_checkpoint(checkpoint_name: String) -> void:
	"""체크포인트에서 플레이어 부활"""
	if not player:
		return
	
	var checkpoint_pos = get_checkpoint_location(checkpoint_name)
	if checkpoint_pos != Vector3.ZERO:
		player.global_position = checkpoint_pos
		print("플레이어 부활: %s (%.0f, %.0f, %.0f)" % [checkpoint_name, checkpoint_pos.x, checkpoint_pos.y, checkpoint_pos.z])
