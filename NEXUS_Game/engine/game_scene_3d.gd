extends Node3D
class_name GameScene3D

## 3D 게임 씬 관리자
## - 카메라, 조명, 환경
## - 플레이어 캐릭터
## - 적 캐릭터
## - 일일이펙트 (파티클, 라이팅)

@export var scene_name: String = "Central Plains"
@export var difficulty: int = 1

## 기본 요소
var camera_3d: Camera3D
var player: Character3D
var enemies: Array[Character3D] = []
var lights: Array[Light3D] = []
var environment: WorldEnvironment

## 카메라 설정
var camera_distance: float = 5.0
var camera_height: float = 2.0
var camera_angle: float = -30.0

# 생명 주기
func _ready():
	_setup_environment()
	_setup_lighting()
	_setup_camera()
	_spawn_player()
	_setup_ground()

func _process(delta):
	_update_camera_position()

## 환경 설정
func _setup_environment():
	environment = WorldEnvironment.new()
	var env = Environment.new()
	
	# 하늘색 배경
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.5, 0.7, 1.0)
	
	# 환경 조명
	env.ambient_light_source = Environment.AMBIENT_LIGHT_DISABLED
	
	environment.environment = env
	add_child(environment)

## 조명 설정
func _setup_lighting():
	# 메인 라이트 (태양)
	var sun_light = DirectionalLight3D.new()
	sun_light.transform.basis = Basis()
	sun_light.transform.origin = Vector3(10, 15, 10)
	sun_light.rotation_degrees = Vector3(-45, 45, 0)
	sun_light.energy = 2.0
	sun_light.shadow_enabled = true
	add_child(sun_light)
	lights.append(sun_light)
	
	# 채우기 라이트 (앞쪽)
	var fill_light = OmniLight3D.new()
	fill_light.global_position = Vector3(0, 5, 5)
	fill_light.omni_range = 20.0
	fill_light.energy = 0.5
	fill_light.omni_attenuation = 2.0
	add_child(fill_light)
	lights.append(fill_light)
	
	# 백라이트 (뒤쪽)
	var back_light = OmniLight3D.new()
	back_light.global_position = Vector3(0, 3, -10)
	back_light.omni_range = 20.0
	back_light.energy = 0.3
	back_light.omni_attenuation = 2.0
	back_light.light_color = Color(0.5, 0.5, 1.0)
	add_child(back_light)
	lights.append(back_light)

## 카메라 설정
func _setup_camera():
	camera_3d = Camera3D.new()
	add_child(camera_3d)
	camera_3d.make_current()
	
	# 카메라 위치 초기화
	_update_camera_position()

## 카메라 위치 업데이트 (플레이어 추적)
func _update_camera_position():
	if not player:
		return
	
	# 플레이어 위에서 보는 카메라
	var target_pos = player.global_position
	var camera_offset = Vector3(
		sin(deg_to_rad(camera_angle)) * camera_distance,
		camera_height,
		cos(deg_to_rad(camera_angle)) * camera_distance
	)
	
	camera_3d.global_position = target_pos + camera_offset
	camera_3d.look_at(target_pos + Vector3(0, 1, 0), Vector3.UP)

## 지면 생성
func _setup_ground():
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(100, 100)
	ground.mesh = plane_mesh
	ground.position.y = -1
	add_child(ground)
	
	# 지면 물리 (콜라이더)
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = Vector3(100, 2, 100)
	static_body.add_child(collision_shape)
	ground.add_child(static_body)
	
	# 지면 색상
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.7, 0.2)
	ground.material_override = material

## 플레이어 스폰
func _spawn_player():
	player = Character3D.new()
	player.character_name = "Player"
	player.character_class = "Swordsman"
	player.level = 1
	player.global_position = Vector3(0, 1, 0)
	add_child(player)

## 적 스폰
func spawn_enemy(enemy_name: String, enemy_class: String, position: Vector3, ai_level: int = 1) -> Character3D:
	var enemy = Character3D.new()
	enemy.character_name = enemy_name
	enemy.character_class = enemy_class
	enemy.global_position = position
	enemy.level = ai_level
	add_child(enemy)
	enemies.append(enemy)
	
	return enemy

## 지역 테마 설정
func set_zone_theme(zone_name: String):
	"""
	지역별 조명, 배경색 설정
	"""
	var themes = {
		"central_plains": {
			"bg_color": Color(0.5, 0.7, 1.0),
			"sun_angle": Vector3(-45, 45, 0),
			"sun_energy": 2.0,
			"ground_color": Color(0.2, 0.7, 0.2)
		},
		"frozen_peak": {
			"bg_color": Color(0.8, 0.9, 1.0),
			"sun_angle": Vector3(-60, 30, 0),
			"sun_energy": 1.5,
			"ground_color": Color(0.8, 0.9, 1.0)
		},
		"magma_crater": {
			"bg_color": Color(1.0, 0.4, 0.1),
			"sun_angle": Vector3(-30, 45, 0),
			"sun_energy": 2.5,
			"ground_color": Color(0.4, 0.2, 0.1)
		},
		"dark_forest": {
			"bg_color": Color(0.2, 0.2, 0.2),
			"sun_angle": Vector3(-20, 60, 0),
			"sun_energy": 1.0,
			"ground_color": Color(0.1, 0.3, 0.1)
		},
		"divine_realm": {
			"bg_color": Color(0.7, 0.5, 1.0),
			"sun_angle": Vector3(-60, 0, 0),
			"sun_energy": 3.0,
			"ground_color": Color(0.8, 0.7, 1.0)
		}
	}
	
	if zone_name in themes:
		var theme = themes[zone_name]
		
		# 배경색
		environment.environment.background_color = theme["bg_color"]
		
		# 태양 각도 & 강도
		if lights.size() > 0:
			var sun_light = lights[0] as DirectionalLight3D
			sun_light.rotation_degrees = theme["sun_angle"]
			sun_light.energy = theme["sun_energy"]
		
		# 지면 색상
		var ground_meshes = get_tree().get_nodes_in_group("ground")
		for mesh in ground_meshes:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = theme["ground_color"]
			mesh.material_override = mat

## 공개 유틸리티
func get_player() -> Character3D:
	return player

func get_all_enemies() -> Array[Character3D]:
	return enemies

func remove_enemy(enemy: Character3D):
	if enemy in enemies:
		enemies.erase(enemy)
		enemy.queue_free()

## 디버그 정보
func get_debug_info() -> Dictionary:
	return {
		"scene_name": scene_name,
		"difficulty": difficulty,
		"player": player.get_debug_info() if player else null,
		"enemy_count": enemies.size(),
		"light_count": lights.size(),
		"camera_distance": camera_distance,
		"camera_angle": camera_angle
	}
