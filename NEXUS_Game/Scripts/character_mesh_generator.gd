extends Node3D
## 🎨 NEXUS 캐릭터 메시 제너레이터
## Godot 내에서 3D 캐릭터 메시를 생성합니다

class_name CharacterMeshGenerator

# 캐릭터 설정
var character_name: String = "player_male"
var gender: String = "male"  # "male" or "female"
var height: float = 1.8
var color_primary: Color = Color.BROWN
var color_secondary: Color = Color.DARK_GOLDENROD

func _ready() -> void:
	generate_player_model("player_male", "male")
	generate_player_model("player_female", "female")

## 플레이어 모델 생성
func generate_player_model(name: String, gender_type: String) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	
	var vertices = []
	var indices = []
	var normal_idx = 0
	
	# 머리 (구 모양)
	var head_verts = _create_sphere(Vector3(0, height - 0.2, 0), 0.1, 8, 8)
	var head_start = vertices.size()
	vertices.append_array(head_verts)
	indices.append_array(_sphere_indices(head_start, 8, 8))
	
	# 몸통 (박스)
	var torso_verts = _create_box(
		Vector3(0, height * 0.5, 0),
		0.2,  # 너비
		0.15, # 깊이
		0.3   # 높이
	)
	var torso_start = vertices.size()
	vertices.append_array(torso_verts)
	indices.append_array(_box_indices(torso_start))
	
	# 복부 (박스)
	var belly_verts = _create_box(
		Vector3(0, height * 0.2, 0),
		0.18,
		0.14,
		0.25
	)
	var belly_start = vertices.size()
	vertices.append_array(belly_verts)
	indices.append_array(_box_indices(belly_start))
	
	# 팔 (실린더 2개)
	for arm_side in [-1, 1]:
		var arm_verts = _create_cylinder(
			Vector3(arm_side * 0.15, height * 0.5, 0),
			0.035,
			0.35,
			8
		)
		var arm_start = vertices.size()
		vertices.append_array(arm_verts)
		indices.append_array(_cylinder_indices(arm_start, 8))
	
	# 다리 (실린더 2개)
	for leg_side in [-1, 1]:
		var leg_verts = _create_cylinder(
			Vector3(leg_side * 0.08, height * 0.2, 0),
			0.04,
			0.4,
			8
		)
		var leg_start = vertices.size()
		vertices.append_array(leg_verts)
		indices.append_array(_cylinder_indices(leg_start, 8))
	
	# 메시 생성
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	# 머터리얼 적용
	var material = StandardMaterial3D.new()
	material.albedo_color = color_primary
	material.roughness = 0.5
	material.metallic = 0.0
	mesh.surface_set_material(0, material)
	
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	
	print(f"✅ 캐릭터 생성 완료: {name} ({gender_type}) - 정점: {vertices.size()}")
	return mesh_instance

## 구(Sphere) 생성
func _create_sphere(center: Vector3, radius: float, seg_h: int, seg_v: int) -> PackedVector3Array:
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

## 구 인덱스 생성
func _sphere_indices(start: int, seg_h: int, seg_v: int) -> PackedInt32Array:
	var indices = PackedInt32Array()
	
	for i in range(seg_v):
		for j in range(seg_h):
			var a = start + i * seg_h + j
			var b = start + i * seg_h + (j + 1) % seg_h
			var c = start + (i + 1) * seg_h + j
			var d = start + (i + 1) * seg_h + (j + 1) % seg_h
			
			indices.append_array([a, b, c])
			indices.append_array([b, d, c])
	
	return indices

## 박스 생성
func _create_box(center: Vector3, width: float, depth: float, height: float) -> PackedVector3Array:
	var verts = PackedVector3Array()
	var hw = width / 2
	var hd = depth / 2
	var hh = height / 2
	
	# 8개 꼭짓점
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

## 박스 인덱스
func _box_indices(start: int) -> PackedInt32Array:
	var indices = PackedInt32Array()
	
	# 6개 면, 각 면 2개 삼각형
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
	
	return indices

## 실린더 생성
func _create_cylinder(center: Vector3, radius: float, height: float, segments: int) -> PackedVector3Array:
	var verts = PackedVector3Array()
	var hh = height / 2
	
	# 위아래 원
	for i in range(2):
		var y = center.y + (i - 0.5) * height
		for j in range(segments):
			var angle = (float(j) / segments) * TAU
			var x = center.x + cos(angle) * radius
			var z = center.z + sin(angle) * radius
			verts.append(Vector3(x, y, z))
	
	return verts

## 실린더 인덱스
func _cylinder_indices(start: int, segments: int) -> PackedInt32Array:
	var indices = PackedInt32Array()
	
	# 옆면
	for i in range(segments):
		var a = start + i
		var b = start + (i + 1) % segments
		var c = start + segments + i
		var d = start + segments + (i + 1) % segments
		
		indices.append_array([a, b, c])
		indices.append_array([b, d, c])
	
	return indices

## 애니메이션용 스켈레톤 생성
func create_skeleton(mesh_instance: MeshInstance3D) -> Skeleton3D:
	var skeleton = Skeleton3D.new()
	
	# Root 본
	skeleton.add_bone("Root")
	
	# 척추
	for i in range(6):
		skeleton.add_bone(f"Spine_{i}")
		skeleton.set_bone_parent(i + 1, i)
	
	# 양팔
	for side in ["L", "R"]:
		for part in ["Shoulder", "UpperArm", "Forearm", "Wrist"]:
			skeleton.add_bone(f"Arm_{side}_{part}")
	
	# 양다리
	for side in ["L", "R"]:
		for part in ["Hip", "Thigh", "Knee", "Ankle", "Foot"]:
			skeleton.add_bone(f"Leg_{side}_{part}")
	
	mesh_instance.add_child(skeleton)
	return skeleton
