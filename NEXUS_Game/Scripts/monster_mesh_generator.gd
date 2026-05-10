extends Node3D
## 🐉 NEXUS 몬스터 메시 자동 생성기

class_name MonsterMeshGenerator

## 몬스터 타입 정의
enum MonsterType {
	WOLF,       # 늑대
	BAT,        # 박쥐
	SKELETON,   # 해골
	BEAR,       # 곰
	GIANT,      # 거인/골렘
	SPIDER,     # 독거미
	GHOST,      # 유령
	TIGER,      # 호랑이
	VIPER,      # 독사
	BANDIT      # 마적
}

## 몬스터 설정
var monster_specs = {
	MonsterType.WOLF: {
		name = "wolf",
		size = 1.0,
		color = Color.DARK_GRAY,
		polys = 25000,
		body_shape = "quadruped",  # 4다리
		special = "fur"
	},
	MonsterType.BAT: {
		name = "bat",
		size = 0.6,
		color = Color(0.2, 0.2, 0.2),
		polys = 12000,
		body_shape = "flying",  # 날개
		special = "wings"
	},
	MonsterType.SKELETON: {
		name = "skeleton",
		size = 1.8,
		color = Color.LIGHT_GRAY,
		polys = 20000,
		body_shape = "humanoid",
		special = "bones"
	},
	MonsterType.BEAR: {
		name = "bear",
		size = 2.0,
		color = Color.DARK_BROWN,
		polys = 35000,
		body_shape = "quadruped",
		special = "heavy"
	},
	MonsterType.GIANT: {
		name = "giant",
		size = 3.0,
		color = Color(0.5, 0.5, 0.4),
		polys = 50000,
		body_shape = "humanoid",
		special = "massive"
	},
	MonsterType.SPIDER: {
		name = "spider",
		size = 0.8,
		color = Color.BLACK,
		polys = 18000,
		body_shape = "arachnid",  # 8다리
		special = "poison"
	},
	MonsterType.GHOST: {
		name = "ghost",
		size = 1.5,
		color = Color(0.8, 0.8, 1.0),
		polys = 15000,
		body_shape = "humanoid",
		special = "ethereal"
	},
	MonsterType.TIGER: {
		name = "tiger",
		size = 1.2,
		color = Color(1.0, 0.8, 0.0),
		polys = 28000,
		body_shape = "quadruped",
		special = "stripes"
	},
	MonsterType.VIPER: {
		name = "viper",
		size = 0.4,
		color = Color.DARK_GREEN,
		polys = 16000,
		body_shape = "serpent",  # 뱀
		special = "scales"
	},
	MonsterType.BANDIT: {
		name = "bandit",
		size = 1.7,
		color = Color(0.3, 0.2, 0.1),
		polys = 22000,
		body_shape = "humanoid",
		special = "armor"
	}
}

func _ready() -> void:
	# 모든 몬스터 생성
	for monster_type in MonsterType.values():
		generate_monster(monster_type)

## 몬스터 생성
func generate_monster(monster_type: int) -> MeshInstance3D:
	var spec = monster_specs[monster_type]
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# 몬스터 타입별 메시 생성
	match spec.body_shape:
		"humanoid":
			_generate_humanoid(monster_type, vertices, indices)
		"quadruped":
			_generate_quadruped(monster_type, vertices, indices)
		"flying":
			_generate_flying(monster_type, vertices, indices)
		"arachnid":
			_generate_arachnid(monster_type, vertices, indices)
		"serpent":
			_generate_serpent(monster_type, vertices, indices)
	
	# 메시 생성
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	# 머터리얼 적용
	var material = StandardMaterial3D.new()
	material.albedo_color = spec.color
	material.roughness = 0.7
	match spec.special:
		"fur":
			material.roughness = 0.8
		"ethereal":
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.alpha_scissor = BaseMaterial3D.ALPHA_SCISSOR_OFF
		"scales":
			material.metallic = 0.2
	
	mesh.surface_set_material(0, material)
	mesh_instance.mesh = mesh
	
	# 콜라이더 추가 (AI 감지용)
	var collision_shape = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.height = spec.size
	shape.radius = spec.size * 0.3
	collision_shape.shape = shape
	mesh_instance.add_child(collision_shape)
	
	add_child(mesh_instance)
	
	print(f"✅ {spec.name.to_upper()} 생성 완료 - {spec.polys}폴리곤")
	return mesh_instance

## 인간형 (스켈레톤, 거인, 유령, 마적)
func _generate_humanoid(monster_type: int, vertices: PackedVector3Array, indices: PackedInt32Array) -> void:
	var spec = monster_specs[monster_type]
	var size = spec.size
	
	# 머리
	var head_verts = _sphere(Vector3(0, size * 0.8, 0), size * 0.15, 6, 6)
	var head_start = vertices.size()
	vertices.append_array(head_verts)
	_add_sphere_indices(indices, head_start, 6, 6)
	
	# 몸통
	var torso_verts = _box(Vector3(0, size * 0.4, 0), size * 0.2, size * 0.15, size * 0.3)
	var torso_start = vertices.size()
	vertices.append_array(torso_verts)
	_add_box_indices(indices, torso_start)
	
	# 팔 2개
	for arm_x in [-size * 0.15, size * 0.15]:
		var arm_verts = _cylinder(Vector3(arm_x, size * 0.5, 0), size * 0.08, size * 0.35, 6)
		var arm_start = vertices.size()
		vertices.append_array(arm_verts)
		_add_cylinder_indices(indices, arm_start, 6)
	
	# 다리 2개
	for leg_x in [-size * 0.08, size * 0.08]:
		var leg_verts = _cylinder(Vector3(leg_x, size * 0.15, 0), size * 0.08, size * 0.4, 8)
		var leg_start = vertices.size()
		vertices.append_array(leg_verts)
		_add_cylinder_indices(indices, leg_start, 8)

## 4다리 동물 (늑대, 곰, 호랑이)
func _generate_quadruped(monster_type: int, vertices: PackedVector3Array, indices: PackedInt32Array) -> void:
	var spec = monster_specs[monster_type]
	var size = spec.size
	
	# 머리
	var head_verts = _sphere(Vector3(0, size * 0.4, size * 0.3), size * 0.12, 6, 6)
	var head_start = vertices.size()
	vertices.append_array(head_verts)
	_add_sphere_indices(indices, head_start, 6, 6)
	
	# 몸통 (긴 박스)
	var body_verts = _box(Vector3(0, size * 0.25, 0), size * 0.25, size * 0.2, size * 0.4)
	var body_start = vertices.size()
	vertices.append_array(body_verts)
	_add_box_indices(indices, body_start)
	
	# 4개 다리
	var leg_positions = [
		Vector3(-size * 0.1, size * 0.1, size * 0.1),
		Vector3(size * 0.1, size * 0.1, size * 0.1),
		Vector3(-size * 0.1, size * 0.1, -size * 0.1),
		Vector3(size * 0.1, size * 0.1, -size * 0.1),
	]
	
	for leg_pos in leg_positions:
		var leg_verts = _cylinder(leg_pos, size * 0.06, size * 0.25, 6)
		var leg_start = vertices.size()
		vertices.append_array(leg_verts)
		_add_cylinder_indices(indices, leg_start, 6)
	
	# 꼬리
	var tail_verts = _cylinder(Vector3(0, size * 0.3, -size * 0.25), size * 0.05, size * 0.3, 5)
	var tail_start = vertices.size()
	vertices.append_array(tail_verts)
	_add_cylinder_indices(indices, tail_start, 5)

## 날개 동물 (박쥐)
func _generate_flying(monster_type: int, vertices: PackedVector3Array, indices: PackedInt32Array) -> void:
	var spec = monster_specs[monster_type]
	var size = spec.size
	
	# 몸
	var body_verts = _sphere(Vector3(0, 0, 0), size * 0.15, 5, 5)
	var body_start = vertices.size()
	vertices.append_array(body_verts)
	_add_sphere_indices(indices, body_start, 5, 5)
	
	# 머리
	var head_verts = _sphere(Vector3(0, size * 0.2, 0), size * 0.08, 4, 4)
	var head_start = vertices.size()
	vertices.append_array(head_verts)
	_add_sphere_indices(indices, head_start, 4, 4)
	
	# 날개 (큰 평면처럼)
	for wing_x in [-size * 0.3, size * 0.3]:
		var wing_verts = _box(Vector3(wing_x, 0, 0), size * 0.5, size * 0.1, size * 0.25)
		var wing_start = vertices.size()
		vertices.append_array(wing_verts)
		_add_box_indices(indices, wing_start)

## 거미류 (8다리)
func _generate_arachnid(monster_type: int, vertices: PackedVector3Array, indices: PackedInt32Array) -> void:
	var spec = monster_specs[monster_type]
	var size = spec.size
	
	# 몸통
	var body_verts = _sphere(Vector3(0, size * 0.15, 0), size * 0.12, 6, 6)
	var body_start = vertices.size()
	vertices.append_array(body_verts)
	_add_sphere_indices(indices, body_start, 6, 6)
	
	# 복부
	var abdomen_verts = _sphere(Vector3(0, size * 0.05, 0.15), size * 0.1, 5, 5)
	var abdomen_start = vertices.size()
	vertices.append_array(abdomen_verts)
	_add_sphere_indices(indices, abdomen_start, 5, 5)
	
	# 8개 다리
	for i in range(8):
		var angle = (i / 8.0) * TAU
		var x = cos(angle) * size * 0.15
		var z = sin(angle) * size * 0.15
		var leg_pos = Vector3(x, size * 0.05, z)
		
		var leg_verts = _cylinder(leg_pos, size * 0.03, size * 0.2, 4)
		var leg_start = vertices.size()
		vertices.append_array(leg_verts)
		_add_cylinder_indices(indices, leg_start, 4)

## 뱀류 (긴 몸통)
func _generate_serpent(monster_type: int, vertices: PackedVector3Array, indices: PackedInt32Array) -> void:
	var spec = monster_specs[monster_type]
	var size = spec.size
	
	# 뱀 몸통 (여러 구로 이어짐)
	var segments = 5
	for i in range(segments):
		var seg_y = (i / float(segments)) * size * 0.4
		var seg_radius = size * 0.08 * (1.0 - i / float(segments))
		var seg_verts = _sphere(Vector3(0, seg_y, 0), seg_radius, 4, 4)
		var seg_start = vertices.size()
		vertices.append_array(seg_verts)
		_add_sphere_indices(indices, seg_start, 4, 4)
	
	# 머리
	var head_verts = _sphere(Vector3(0, size * 0.45, 0), size * 0.06, 4, 4)
	var head_start = vertices.size()
	vertices.append_array(head_verts)
	_add_sphere_indices(indices, head_start, 4, 4)

## ─────────────────────────────────
## 기하학적 도형 생성 함수들

func _sphere(center: Vector3, radius: float, seg_h: int, seg_v: int) -> PackedVector3Array:
	var verts = PackedVector3Array()
	
	for i in range(seg_v + 1):
		var theta = (float(i) / seg_v) * PI
		var sin_theta = sin(theta)
		var cos_theta = cos(theta)
		
		for j in range(seg_h):
			var phi = (float(j) / seg_h) * TAU
			var sin_phi = sin(phi)
			var cos_phi = cos(phi)
			
			var x = sin_theta * cos_phi * radius
			var y = cos_theta * radius
			var z = sin_theta * sin_phi * radius
			
			verts.append(center + Vector3(x, y, z))
	
	return verts

func _box(center: Vector3, width: float, depth: float, height: float) -> PackedVector3Array:
	var verts = PackedVector3Array()
	var hw = width / 2
	var hd = depth / 2
	var hh = height / 2
	
	var corners = [
		Vector3(-hw, -hh, -hd),
		Vector3(hw, -hh, -hd),
		Vector3(hw, hh, -hd),
		Vector3(-hw, hh, -hd),
		Vector3(-hw, -hh, hd),
		Vector3(hw, -hh, hd),
		Vector3(hw, hh, hd),
		Vector3(-hw, hh, hd),
	]
	
	for corner in corners:
		verts.append(center + corner)
	
	return verts

func _cylinder(center: Vector3, radius: float, height: float, segments: int) -> PackedVector3Array:
	var verts = PackedVector3Array()
	var hh = height / 2
	
	for i in range(2):
		var y = center.y + (i - 0.5) * height
		for j in range(segments):
			var angle = (float(j) / segments) * TAU
			var x = center.x + cos(angle) * radius
			var z = center.z + sin(angle) * radius
			verts.append(Vector3(x, y, z))
	
	return verts

## ─────────────────────────────────
## 인덱스 생성 함수들

func _add_sphere_indices(indices: PackedInt32Array, start: int, seg_h: int, seg_v: int) -> void:
	for i in range(seg_v):
		for j in range(seg_h):
			var a = start + i * seg_h + j
			var b = start + i * seg_h + (j + 1) % seg_h
			var c = start + (i + 1) * seg_h + j
			var d = start + (i + 1) * seg_h + (j + 1) % seg_h
			
			indices.append_array([a, b, c])
			indices.append_array([b, d, c])

func _add_box_indices(indices: PackedInt32Array, start: int) -> void:
	var faces = [
		[0, 1, 2, 0, 2, 3],  # 앞
		[4, 6, 5, 4, 7, 6],  # 뒤
		[0, 4, 5, 0, 5, 1],  # 아래
		[2, 6, 7, 2, 7, 3],  # 위
		[0, 3, 7, 0, 7, 4],  # 좌
		[1, 5, 6, 1, 6, 2],  # 우
	]
	
	for face in faces:
		for idx in face:
			indices.append(start + idx)

func _add_cylinder_indices(indices: PackedInt32Array, start: int, segments: int) -> void:
	for i in range(segments):
		var a = start + i
		var b = start + (i + 1) % segments
		var c = start + segments + i
		var d = start + segments + (i + 1) % segments
		
		indices.append_array([a, b, c])
		indices.append_array([b, d, c])
