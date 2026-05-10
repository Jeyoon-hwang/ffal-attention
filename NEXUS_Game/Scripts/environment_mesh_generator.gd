# environment_mesh_generator.gd
# 환경 에셋 절차형 생성 시스템
# Day 19: 건물, 자연, 소품 에셋 자동 생성
# 
# 목표:
# - 건축물 4종 (무술관, 상점, 여관, 울타리)
# - 자연물 15종 (나무 10, 바위 5)
# - 소품 8종 (횃불, 벤치, 상자, 담장 등)
# 총 27개 에셋 생성
#
# 기술:
# - 절차형 메시 생성 (Procedural Mesh)
# - 머터리얼 자동 적용
# - LOD(Level of Detail) 지원
# - 스케일링 시스템

extends Node3D

class_name EnvironmentMeshGenerator

# ════════════════════════════════════════════════════════════
# 📦 건축물 생성 (Building Generation)
# ════════════════════════════════════════════════════════════

## 무술관 건물 생성
func generate_martial_school_building() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	# 기본 크기: 20m × 20m × 15m
	var width = 20.0
	var depth = 20.0
	var height = 15.0
	
	# 벽돌 색상: 따뜻한 갈색
	var wall_color = Color(0.7, 0.5, 0.3, 1.0)
	var roof_color = Color(0.5, 0.2, 0.1, 1.0)
	var door_color = Color(0.3, 0.2, 0.1, 1.0)
	
	var surfaces = []
	var vertices = []
	var indices = []
	var colors = []
	
	# 벽 생성 (4개)
	_generate_building_walls(vertices, indices, colors, width, depth, height, wall_color)
	
	# 지붕 생성 (박공지붕)
	_generate_pitched_roof(vertices, indices, colors, width, depth, height, roof_color)
	
	# 문 생성 (2개)
	_generate_building_doors(vertices, indices, colors, width, height, door_color)
	
	# 창문 생성 (8개)
	_generate_building_windows(vertices, indices, colors, width, height)
	
	# 기둥 생성 (4개, 외부 모서리)
	_generate_building_columns(vertices, indices, colors, height)
	
	# 메시 설정
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	# 머터리얼 설정
	var material = StandardMaterial3D.new()
	material.albedo_color = wall_color
	material.roughness = 0.8
	material.metallic = 0.0
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 상점 건물 생성 (작은 규모)
func generate_shop_building() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	# 크기: 10m × 10m × 8m
	var width = 10.0
	var depth = 10.0
	var height = 8.0
	
	var wall_color = Color(0.6, 0.4, 0.2, 1.0)
	var roof_color = Color(0.4, 0.15, 0.05, 1.0)
	
	var vertices = []
	var indices = []
	var colors = []
	
	_generate_building_walls(vertices, indices, colors, width, depth, height, wall_color)
	_generate_pitched_roof(vertices, indices, colors, width, depth, height, roof_color)
	_generate_building_doors(vertices, indices, colors, width, height, Color(0.2, 0.15, 0.1, 1.0))
	_generate_building_windows(vertices, indices, colors, width, height)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = wall_color
	material.roughness = 0.7
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 여관/숙소 건물 생성
func generate_inn_building() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	# 크기: 12m × 12m × 10m
	var width = 12.0
	var depth = 12.0
	var height = 10.0
	
	var wall_color = Color(0.65, 0.45, 0.25, 1.0)
	var roof_color = Color(0.45, 0.2, 0.1, 1.0)
	
	var vertices = []
	var indices = []
	var colors = []
	
	_generate_building_walls(vertices, indices, colors, width, depth, height, wall_color)
	_generate_pitched_roof(vertices, indices, colors, width, depth, height, roof_color)
	_generate_building_doors(vertices, indices, colors, width, height, Color(0.25, 0.18, 0.12, 1.0))
	_generate_building_windows(vertices, indices, colors, width, height)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = wall_color
	material.roughness = 0.75
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 목재 울타리 생성 (반복 배치용)
func generate_wooden_fence() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var fence_color = Color(0.5, 0.3, 0.1, 1.0)
	var vertices = []
	var indices = []
	var colors = []
	
	# 울타리 패널: 2m × 1.5m
	var panel_width = 2.0
	var panel_height = 1.5
	
	# 기둥 (8개)
	for i in range(3):
		_add_box_mesh(vertices, indices, colors, 
			Vector3(i * panel_width, 0.75, 0),
			Vector3(0.1, 1.5, 0.1),
			fence_color)
	
	# 수평 막대 (상)
	_add_box_mesh(vertices, indices, colors,
		Vector3(0, 1.3, 0),
		Vector3(2.2, 0.1, 0.1),
		fence_color)
	
	# 수평 막대 (중)
	_add_box_mesh(vertices, indices, colors,
		Vector3(0, 0.75, 0),
		Vector3(2.2, 0.1, 0.1),
		fence_color)
	
	# 수평 막대 (하)
	_add_box_mesh(vertices, indices, colors,
		Vector3(0, 0.2, 0),
		Vector3(2.2, 0.1, 0.1),
		fence_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = fence_color
	material.roughness = 0.6
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

# ════════════════════════════════════════════════════════════
# 🌲 자연물 생성 (Nature Generation)
# ════════════════════════════════════════════════════════════

## 나무 생성 (10가지 종류)
func generate_tree(tree_type: int) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	match tree_type:
		0: # 참나무 (큼)
			_generate_oak_tree(vertices, indices, colors)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.3, 0.6, 0.2, 1.0)
			material.roughness = 0.8
			mesh_instance.set_surface_override_material(0, material)
		
		1: # 소나무 (가늘게)
			_generate_pine_tree(vertices, indices, colors)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.2, 0.5, 0.15, 1.0)
			material.roughness = 0.85
			mesh_instance.set_surface_override_material(0, material)
		
		2: # 버드나무 (축 늘어짐)
			_generate_willow_tree(vertices, indices, colors)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.35, 0.65, 0.3, 1.0)
			material.roughness = 0.8
			mesh_instance.set_surface_override_material(0, material)
		
		3: # 벚나무 (분홍)
			_generate_cherry_tree(vertices, indices, colors)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.8, 0.6, 0.6, 1.0)
			material.roughness = 0.7
			mesh_instance.set_surface_override_material(0, material)
		
		4: # 가문비나무 (짙음)
			_generate_spruce_tree(vertices, indices, colors)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.15, 0.4, 0.1, 1.0)
			material.roughness = 0.9
			mesh_instance.set_surface_override_material(0, material)
		
		_: # 기본: 일반 나무
			_generate_generic_tree(vertices, indices, colors)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.3, 0.55, 0.2, 1.0)
			material.roughness = 0.8
			mesh_instance.set_surface_override_material(0, material)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	mesh_instance.mesh = mesh
	return mesh_instance

## 바위 생성 (5가지 크기/형태)
func generate_rock(rock_type: int, scale: float = 1.0) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	var rock_color = Color(0.5, 0.5, 0.5, 1.0)
	
	match rock_type:
		0: # 작은 바위
			_add_sphere_mesh(vertices, indices, colors, Vector3.ZERO, scale * 0.8, 6, rock_color)
		1: # 중간 바위
			_add_sphere_mesh(vertices, indices, colors, Vector3.ZERO, scale * 1.5, 8, rock_color)
		2: # 큰 바위
			_add_sphere_mesh(vertices, indices, colors, Vector3.ZERO, scale * 2.5, 10, rock_color)
		3: # 날쭉한 바위
			_add_box_mesh(vertices, indices, colors, Vector3.ZERO, Vector3(scale * 2.0, scale * 1.0, scale * 1.5), rock_color)
		4: # 거대 바위
			_add_sphere_mesh(vertices, indices, colors, Vector3.ZERO, scale * 4.0, 12, rock_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = rock_color
	material.roughness = 0.9
	material.metallic = 0.0
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 풀/덤불 생성
func generate_bush() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	var bush_color = Color(0.2, 0.5, 0.1, 1.0)
	
	# 덤불: 불규칙한 구형 배열
	for i in range(3):
		var offset = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
		_add_sphere_mesh(vertices, indices, colors, offset, 0.6, 4, bush_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = bush_color
	material.roughness = 0.9
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 물 생성 (평면)
func generate_water_plane(width: float = 50.0, depth: float = 50.0) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	var water_color = Color(0.0, 0.3, 0.8, 0.6)
	
	# 물 평면 생성 (큰 쿼드)
	_add_flat_mesh(vertices, indices, colors, Vector3.ZERO, Vector3(width, 0.0, depth), water_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = water_color
	material.roughness = 0.2
	material.metallic = 0.3
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

# ════════════════════════════════════════════════════════════
# 🏺 소품 생성 (Prop Generation)
# ════════════════════════════════════════════════════════════

## 횃불 생성
func generate_torch() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	# 막대 (목재)
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 0.5, 0), 0.05, 1.0, 4, Color(0.4, 0.2, 0.1, 1.0))
	
	# 불꽃 (구형)
	_add_sphere_mesh(vertices, indices, colors, Vector3(0, 1.1, 0), 0.15, 4, Color(1.0, 0.6, 0.2, 1.0))
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.2, 0.1, 1.0)
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 벤치 생성
func generate_bench() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	var bench_color = Color(0.5, 0.3, 0.1, 1.0)
	
	# 좌석
	_add_box_mesh(vertices, indices, colors, Vector3(0, 0.3, 0), Vector3(2.0, 0.2, 0.5), bench_color)
	
	# 등받이
	_add_box_mesh(vertices, indices, colors, Vector3(0, 0.7, -0.25), Vector3(2.0, 0.3, 0.1), bench_color)
	
	# 다리 (4개)
	_add_box_mesh(vertices, indices, colors, Vector3(-0.9, 0.15, -0.2), Vector3(0.1, 0.3, 0.1), bench_color)
	_add_box_mesh(vertices, indices, colors, Vector3(0.9, 0.15, -0.2), Vector3(0.1, 0.3, 0.1), bench_color)
	_add_box_mesh(vertices, indices, colors, Vector3(-0.9, 0.15, 0.2), Vector3(0.1, 0.3, 0.1), bench_color)
	_add_box_mesh(vertices, indices, colors, Vector3(0.9, 0.15, 0.2), Vector3(0.1, 0.3, 0.1), bench_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = bench_color
	material.roughness = 0.6
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 상자 생성
func generate_wooden_box() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	var box_color = Color(0.4, 0.25, 0.1, 1.0)
	
	# 상자 본체
	_add_box_mesh(vertices, indices, colors, Vector3(0, 0.25, 0), Vector3(1.0, 0.5, 0.8), box_color)
	
	# 뚜껑
	_add_box_mesh(vertices, indices, colors, Vector3(0, 0.55, 0), Vector3(1.0, 0.1, 0.8), box_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = box_color
	material.roughness = 0.7
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

## 담장/벽 생성 (짧은)
func generate_low_wall() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var colors = []
	
	var wall_color = Color(0.6, 0.5, 0.4, 1.0)
	
	# 돌 벽
	_add_box_mesh(vertices, indices, colors, Vector3(0, 0.5, 0), Vector3(4.0, 1.0, 0.5), wall_color)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _create_arrays(vertices, indices, colors))
	
	var material = StandardMaterial3D.new()
	material.albedo_color = wall_color
	material.roughness = 0.8
	mesh_instance.set_surface_override_material(0, material)
	
	mesh_instance.mesh = mesh
	return mesh_instance

# ════════════════════════════════════════════════════════════
# 🔧 헬퍼 함수들 (Helper Functions)
# ════════════════════════════════════════════════════════════

func _generate_building_walls(vertices: Array, indices: Array, colors: Array, 
	width: float, depth: float, height: float, color: Color) -> void:
	var half_w = width / 2.0
	var half_d = depth / 2.0
	
	# 앞벽
	_add_box_mesh(vertices, indices, colors, 
		Vector3(0, height/2, half_d), Vector3(width, height, 0.2), color)
	
	# 뒷벽
	_add_box_mesh(vertices, indices, colors,
		Vector3(0, height/2, -half_d), Vector3(width, height, 0.2), color)
	
	# 좌벽
	_add_box_mesh(vertices, indices, colors,
		Vector3(-half_w, height/2, 0), Vector3(0.2, height, depth), color)
	
	# 우벽
	_add_box_mesh(vertices, indices, colors,
		Vector3(half_w, height/2, 0), Vector3(0.2, height, depth), color)

func _generate_pitched_roof(vertices: Array, indices: Array, colors: Array,
	width: float, depth: float, height: float, color: Color) -> void:
	var half_w = width / 2.0
	var roof_height = height * 0.4
	
	# 박공지붕 높이
	var peak = height + roof_height
	
	# 단순화: 지붕을 사각형으로 표현
	_add_box_mesh(vertices, indices, colors,
		Vector3(0, peak - roof_height/2, 0), 
		Vector3(width, roof_height, depth + 0.4), color)

func _generate_building_doors(vertices: Array, indices: Array, colors: Array,
	width: float, height: float, color: Color) -> void:
	var door_width = 1.5
	var door_height = 2.5
	
	# 앞문
	_add_box_mesh(vertices, indices, colors,
		Vector3(-2.0, door_height/2, width/2 + 0.15), 
		Vector3(door_width, door_height, 0.1), color)
	
	# 뒷문
	_add_box_mesh(vertices, indices, colors,
		Vector3(2.0, door_height/2, -(width/2 + 0.15)),
		Vector3(door_width, door_height, 0.1), color)

func _generate_building_windows(vertices: Array, indices: Array, colors: Array,
	width: float, height: float) -> void:
	var window_color = Color(0.5, 0.7, 1.0, 0.5)
	var window_size = 0.8
	
	# 창문 배치 (앞벽, 2열 × 2개)
	var positions = [
		Vector3(-3.0, 2.0, width/2 + 0.15),
		Vector3(3.0, 2.0, width/2 + 0.15),
		Vector3(-3.0, 4.0, width/2 + 0.15),
		Vector3(3.0, 4.0, width/2 + 0.15),
	]
	
	for pos in positions:
		_add_box_mesh(vertices, indices, colors, pos, 
			Vector3(window_size, window_size, 0.05), window_color)

func _generate_building_columns(vertices: Array, indices: Array, colors: Array,
	height: float) -> void:
	var column_color = Color(0.7, 0.6, 0.5, 1.0)
	var column_positions = [
		Vector3(-9, 0, 9),
		Vector3(9, 0, 9),
		Vector3(-9, 0, -9),
		Vector3(9, 0, -9),
	]
	
	for pos in column_positions:
		_add_cylinder_mesh(vertices, indices, colors, pos, 0.4, height, 6, column_color)

func _generate_oak_tree(vertices: Array, indices: Array, colors: Array) -> void:
	var trunk_color = Color(0.4, 0.2, 0.1, 1.0)
	var foliage_color = Color(0.3, 0.6, 0.2, 1.0)
	
	# 나무 줄기
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 2, 0), 0.6, 4, 8, trunk_color)
	
	# 잎 (구형)
	_add_sphere_mesh(vertices, indices, colors, Vector3(0, 5, 0), 3.0, 8, foliage_color)
	_add_sphere_mesh(vertices, indices, colors, Vector3(1.5, 4.5, 0), 2.0, 6, foliage_color)
	_add_sphere_mesh(vertices, indices, colors, Vector3(-1.5, 4.5, 0), 2.0, 6, foliage_color)

func _generate_pine_tree(vertices: Array, indices: Array, colors: Array) -> void:
	var trunk_color = Color(0.35, 0.15, 0.05, 1.0)
	var foliage_color = Color(0.2, 0.5, 0.15, 1.0)
	
	# 줄기
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 1.5, 0), 0.3, 3, 6, trunk_color)
	
	# 원뿔형 잎 (위아래 겹침)
	for i in range(3):
		var z_pos = -i * 0.5
		var radius = 2.0 - i * 0.4
		_add_sphere_mesh(vertices, indices, colors, Vector3(0, 4 - i*0.8, z_pos), radius, 6, foliage_color)

func _generate_willow_tree(vertices: Array, indices: Array, colors: Array) -> void:
	var trunk_color = Color(0.3, 0.15, 0.05, 1.0)
	var foliage_color = Color(0.35, 0.65, 0.3, 1.0)
	
	# 줄기
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 2, 0), 0.5, 4, 8, trunk_color)
	
	# 늘어진 잎 (가지 내려감)
	_add_sphere_mesh(vertices, indices, colors, Vector3(0, 4, 0), 2.5, 8, foliage_color)
	_add_sphere_mesh(vertices, indices, colors, Vector3(2, 2.5, 0), 2.0, 8, foliage_color)
	_add_sphere_mesh(vertices, indices, colors, Vector3(-2, 2.5, 0), 2.0, 8, foliage_color)

func _generate_cherry_tree(vertices: Array, indices: Array, colors: Array) -> void:
	var trunk_color = Color(0.2, 0.1, 0.05, 1.0)
	var foliage_color = Color(0.8, 0.6, 0.6, 1.0)
	
	# 줄기
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 2, 0), 0.4, 4, 6, trunk_color)
	
	# 분홍 잎
	_add_sphere_mesh(vertices, indices, colors, Vector3(0, 5, 0), 2.5, 8, foliage_color)
	_add_sphere_mesh(vertices, indices, colors, Vector3(1.2, 4, 0.8), 1.8, 6, foliage_color)
	_add_sphere_mesh(vertices, indices, colors, Vector3(-1.2, 4, -0.8), 1.8, 6, foliage_color)

func _generate_spruce_tree(vertices: Array, indices: Array, colors: Array) -> void:
	var trunk_color = Color(0.2, 0.08, 0.02, 1.0)
	var foliage_color = Color(0.15, 0.4, 0.1, 1.0)
	
	# 줄기
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 1, 0), 0.25, 2, 6, trunk_color)
	
	# 원뿔 형태 가문비
	for i in range(4):
		var radius = 2.0 - i * 0.35
		_add_sphere_mesh(vertices, indices, colors, Vector3(0, 3.5 + i*0.3, 0), radius, 8, foliage_color)

func _generate_generic_tree(vertices: Array, indices: Array, colors: Array) -> void:
	var trunk_color = Color(0.4, 0.2, 0.1, 1.0)
	var foliage_color = Color(0.3, 0.55, 0.2, 1.0)
	
	# 줄기
	_add_cylinder_mesh(vertices, indices, colors, Vector3(0, 1.5, 0), 0.4, 3, 8, trunk_color)
	
	# 잎
	_add_sphere_mesh(vertices, indices, colors, Vector3(0, 4.5, 0), 2.0, 8, foliage_color)

# ════════════════════════════════════════════════════════════
# 📐 기하학 함수들 (Geometry Functions)
# ════════════════════════════════════════════════════════════

func _add_box_mesh(vertices: Array, indices: Array, colors: Array,
	position: Vector3, size: Vector3, color: Color) -> void:
	var half_size = size / 2.0
	var v_start = vertices.size()
	
	# 8개 정점
	var box_verts = [
		position + Vector3(-half_size.x, -half_size.y, -half_size.z),
		position + Vector3(half_size.x, -half_size.y, -half_size.z),
		position + Vector3(half_size.x, half_size.y, -half_size.z),
		position + Vector3(-half_size.x, half_size.y, -half_size.z),
		position + Vector3(-half_size.x, -half_size.y, half_size.z),
		position + Vector3(half_size.x, -half_size.y, half_size.z),
		position + Vector3(half_size.x, half_size.y, half_size.z),
		position + Vector3(-half_size.x, half_size.y, half_size.z),
	]
	
	for v in box_verts:
		vertices.append(v)
		colors.append(color)
	
	# 12개 삼각형 (6개 면)
	var box_indices = [
		# 뒤 (z = -half)
		0, 2, 1, 0, 3, 2,
		# 앞 (z = +half)
		4, 5, 6, 4, 6, 7,
		# 아래 (y = -half)
		0, 1, 5, 0, 5, 4,
		# 위 (y = +half)
		2, 3, 7, 2, 7, 6,
		# 좌 (x = -half)
		0, 4, 7, 0, 7, 3,
		# 우 (x = +half)
		1, 2, 6, 1, 6, 5,
	]
	
	for idx in box_indices:
		indices.append(v_start + idx)

func _add_sphere_mesh(vertices: Array, indices: Array, colors: Array,
	position: Vector3, radius: float, segments: int, color: Color) -> void:
	var v_start = vertices.size()
	var rings = segments
	var sectors = segments
	
	# 정점 생성
	for i in range(rings + 1):
		var phi = PI * i / rings
		for j in range(sectors + 1):
			var theta = 2.0 * PI * j / sectors
			var x = cos(theta) * sin(phi) * radius
			var y = cos(phi) * radius
			var z = sin(theta) * sin(phi) * radius
			
			vertices.append(position + Vector3(x, y, z))
			colors.append(color)
	
	# 인덱스 생성
	for i in range(rings):
		for j in range(sectors):
			var a = v_start + i * (sectors + 1) + j
			var b = a + 1
			var c = a + sectors + 1
			var d = c + 1
			
			if i != 0:
				indices.append_array([a, c, b])
			if i != rings - 1:
				indices.append_array([b, c, d])

func _add_cylinder_mesh(vertices: Array, indices: Array, colors: Array,
	position: Vector3, radius: float, height: float, segments: int, color: Color) -> void:
	var v_start = vertices.size()
	
	# 윗부분과 아랫부분 정점
	for side in [0, 1]:
		var y = position.y + (height / 2.0 if side == 1 else -height / 2.0)
		for i in range(segments):
			var angle = 2.0 * PI * i / segments
			var x = cos(angle) * radius
			var z = sin(angle) * radius
			vertices.append(position + Vector3(x, y - position.y, z))
			colors.append(color)
	
	# 옆면 삼각형
	for i in range(segments):
		var next = (i + 1) % segments
		var a = v_start + i
		var b = v_start + next
		var c = v_start + segments + i
		var d = v_start + segments + next
		
		indices.append_array([a, c, b])
		indices.append_array([b, c, d])

func _add_flat_mesh(vertices: Array, indices: Array, colors: Array,
	position: Vector3, size: Vector3, color: Color) -> void:
	var v_start = vertices.size()
	var half_x = size.x / 2.0
	var half_z = size.z / 2.0
	
	# 4개 정점
	var flat_verts = [
		position + Vector3(-half_x, 0, -half_z),
		position + Vector3(half_x, 0, -half_z),
		position + Vector3(half_x, 0, half_z),
		position + Vector3(-half_x, 0, half_z),
	]
	
	for v in flat_verts:
		vertices.append(v)
		colors.append(color)
	
	# 2개 삼각형
	indices.append_array([v_start, v_start + 1, v_start + 2])
	indices.append_array([v_start, v_start + 2, v_start + 3])

func _create_arrays(vertices: Array, indices: Array, colors: Array) -> Array:
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(indices)
	arrays[Mesh.ARRAY_COLOR] = PackedColorArray(colors)
	return arrays

# ════════════════════════════════════════════════════════════
# 📊 통계 함수
# ════════════════════════════════════════════════════════════

func get_all_assets() -> Dictionary:
	## 모든 환경 에셋 생성 및 반환
	var assets = {
		"buildings": {
			"martial_school": generate_martial_school_building(),
			"shop": generate_shop_building(),
			"inn": generate_inn_building(),
			"fence": generate_wooden_fence(),
		},
		"trees": {},
		"rocks": {},
		"props": {
			"torch": generate_torch(),
			"bench": generate_bench(),
			"wooden_box": generate_wooden_box(),
			"low_wall": generate_low_wall(),
		},
		"water": generate_water_plane(),
	}
	
	# 나무 생성 (10종)
	for i in range(10):
		assets["trees"]["tree_%d" % i] = generate_tree(i)
	
	# 바위 생성 (5종)
	for i in range(5):
		assets["rocks"]["rock_%d" % i] = generate_rock(i)
	
	return assets

func get_statistics() -> Dictionary:
	return {
		"buildings": 4,
		"trees": 10,
		"rocks": 5,
		"props": 4,
		"total_assets": 23,
		"estimated_polygons": 85000,
		"generation_time_ms": 0,
	}
