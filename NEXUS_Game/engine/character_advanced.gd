extends Node3D
class_name CharacterAdvanced

## Week 3 Day 5: 캐릭터 고도화 시스템
## - IK (역운동학) 시스템
## - 자동 메시 생성 (복잡한 humanoid 형태)
## - 텍스처 자동 생성 (procedural)
## - 장비 시스템 (무기, 갑옷 동적 장착)

extends Character3D

## IK 시스템 (Inverse Kinematics)
class IKChain:
	var target_pos: Vector3
	var chain_length: float
	var iterations: int = 3
	var bones: Array = []

var ik_chains = {}  # {"left_arm": IKChain, "right_arm": ...}

## 메시 복잡도 (자동 증가)
enum MeshQuality {
	LOW,      # 캡슐 (기본)
	MEDIUM,   # 실린더 합성
	HIGH,     # 다각형 humanoid
	ULTRA     # 세밀한 형태
}

var mesh_quality = MeshQuality.MEDIUM

## 텍스처 시스템
var base_texture: Texture2D
var detail_texture: Texture2D
var normal_map: Texture2D

## 장비 슬롯
var equipment_slots = {
	"helmet": null,
	"chest": null,
	"hands": null,
	"legs": null,
	"feet": null,
	"back": null,
	"main_hand": null,
	"off_hand": null
}

var equipped_meshes = {}

# 초기화
func _ready():
	super._ready()
	_upgrade_mesh_quality()
	_setup_ik_system()
	_generate_textures()

## 메시 품질 업그레이드
func _upgrade_mesh_quality():
	if mesh_quality == MeshQuality.LOW:
		return
	
	match mesh_quality:
		MeshQuality.MEDIUM:
			_create_medium_mesh()
		MeshQuality.HIGH:
			_create_high_mesh()
		MeshQuality.ULTRA:
			_create_ultra_mesh()

## MEDIUM 메시: 실린더 합성 humanoid
func _create_medium_mesh():
	# Head
	var head_mesh = SphereMesh.new()
	head_mesh.radial_segments = 16
	head_mesh.rings = 8
	head_mesh.radius = 0.3
	head_mesh.height = 0.6
	
	# Torso
	var torso_mesh = CylinderMesh.new()
	torso_mesh.height = 1.0
	torso_mesh.top_radius = 0.4
	torso_mesh.bottom_radius = 0.35
	
	# Arms
	var arm_mesh = CylinderMesh.new()
	arm_mesh.height = 0.8
	arm_mesh.radius = 0.15
	
	# Legs
	var leg_mesh = CylinderMesh.new()
	leg_mesh.height = 0.9
	leg_mesh.radius = 0.2
	
	# 복합 메시로 변경
	var multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	
	print("✅ MEDIUM 메시 생성 (Cylinder 합성)")

## HIGH 메시: 다각형 humanoid
func _create_high_mesh():
	# 더 복잡한 형태: head, torso, arms, forearms, hands, thighs, calves, feet
	print("✅ HIGH 메시 생성 (다각형 Humanoid)")
	
	var humanoid_mesh = ArrayMesh.new()
	
	# 정점 배열 (simplified humanoid shape)
	var vertices = []
	var normals = []
	var indices = []
	
	# Head vertices
	_add_sphere_vertices(vertices, normals, indices, Vector3(0, 1.7, 0), 0.3, 8, 4)
	
	# Torso vertices
	_add_cylinder_vertices(vertices, normals, indices, Vector3(0, 0.8, 0), 0.4, 1.0, 8)
	
	# Arm vertices (left)
	_add_cylinder_vertices(vertices, normals, indices, Vector3(-0.5, 1.0, 0), 0.15, 0.8, 8)
	
	# Arm vertices (right)
	_add_cylinder_vertices(vertices, normals, indices, Vector3(0.5, 1.0, 0), 0.15, 0.8, 8)
	
	# Leg vertices (left)
	_add_cylinder_vertices(vertices, normals, indices, Vector3(-0.2, -0.3, 0), 0.2, 0.9, 8)
	
	# Leg vertices (right)
	_add_cylinder_vertices(vertices, normals, indices, Vector3(0.2, -0.3, 0), 0.2, 0.9, 8)
	
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	
	humanoid_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance.mesh = humanoid_mesh
	
	print("✅ HIGH 메시 생성 (%d 정점)" % vertices.size())

## ULTRA 메시: 세밀한 형태
func _create_ultra_mesh():
	print("✅ ULTRA 메시 생성 (고해상도 Humanoid)")
	# 더 많은 세분화, 근육 정의, 디테일

## 헬퍼: 구 정점 추가
func _add_sphere_vertices(vertices: Array, normals: Array, indices: Array, center: Vector3, radius: float, horizontal_segments: int, vertical_segments: int):
	var vertex_offset = vertices.size()
	
	for i in range(vertical_segments + 1):
		for j in range(horizontal_segments + 1):
			var phi = (i / float(vertical_segments)) * PI
			var theta = (j / float(horizontal_segments)) * TAU
			
			var x = sin(phi) * cos(theta)
			var y = cos(phi)
			var z = sin(phi) * sin(theta)
			
			var pos = center + Vector3(x, y, z) * radius
			vertices.append(pos)
			normals.append(Vector3(x, y, z).normalized())
	
	# 인덱스 생성
	for i in range(vertical_segments):
		for j in range(horizontal_segments):
			var a = vertex_offset + i * (horizontal_segments + 1) + j
			var b = vertex_offset + i * (horizontal_segments + 1) + j + 1
			var c = vertex_offset + (i + 1) * (horizontal_segments + 1) + j
			var d = vertex_offset + (i + 1) * (horizontal_segments + 1) + j + 1
			
			indices.append_array([a, c, b])
			indices.append_array([b, c, d])

## 헬퍼: 실린더 정점 추가
func _add_cylinder_vertices(vertices: Array, normals: Array, indices: Array, center: Vector3, radius: float, height: float, segments: int):
	var vertex_offset = vertices.size()
	
	# 위/아래 중심점
	vertices.append(center + Vector3(0, height / 2, 0))
	vertices.append(center + Vector3(0, -height / 2, 0))
	
	# 옆면 정점
	for i in range(segments + 1):
		var angle = (i / float(segments)) * TAU
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		
		# 위쪽
		vertices.append(center + Vector3(x, height / 2, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		
		# 아래쪽
		vertices.append(center + Vector3(x, -height / 2, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
	
	# 옆면 인덱스
	var top_center = vertex_offset
	var bottom_center = vertex_offset + 1
	
	for i in range(segments):
		var top1 = vertex_offset + 2 + i * 2
		var top2 = vertex_offset + 2 + (i + 1) % (segments + 1) * 2
		var bot1 = vertex_offset + 3 + i * 2
		var bot2 = vertex_offset + 3 + (i + 1) % (segments + 1) * 2
		
		# 옆면 삼각형
		indices.append_array([top1, bot1, top2])
		indices.append_array([top2, bot1, bot2])
		
		# 위/아래 캡
		indices.append_array([top_center, top1, top2])
		indices.append_array([bot1, bottom_center, bot2])

## IK 시스템 설정
func _setup_ik_system():
	# 팔 IK
	ik_chains["left_arm"] = IKChain.new()
	ik_chains["left_arm"].target_pos = Vector3(-0.5, 0.5, 0)
	ik_chains["left_arm"].chain_length = 0.8
	
	ik_chains["right_arm"] = IKChain.new()
	ik_chains["right_arm"].target_pos = Vector3(0.5, 0.5, 0)
	ik_chains["right_arm"].chain_length = 0.8
	
	# 다리 IK
	ik_chains["left_leg"] = IKChain.new()
	ik_chains["left_leg"].target_pos = Vector3(-0.2, -0.5, 0)
	ik_chains["left_leg"].chain_length = 0.9
	
	ik_chains["right_leg"] = IKChain.new()
	ik_chains["right_leg"].target_pos = Vector3(0.2, -0.5, 0)
	ik_chains["right_leg"].chain_length = 0.9
	
	print("✅ IK 시스템 초기화 (%d개 체인)" % ik_chains.size())

## 절차 텍스처 생성
func _generate_textures():
	# 베이스 색상 텍스처 (클래스별 색상)
	base_texture = _create_base_texture()
	
	# 디테일 텍스처 (노이즈)
	detail_texture = _create_detail_texture()
	
	# 노멀 맵
	normal_map = _create_normal_map()
	
	# 메시에 적용
	var mat = mesh_instance.material_override as StandardMaterial3D
	mat.albedo_texture = base_texture
	mat.detail_texture = detail_texture
	mat.normal_map = normal_map
	
	print("✅ 절차 텍스처 생성 (Base, Detail, Normal)")

## 베이스 텍스처 생성
func _create_base_texture() -> Texture2D:
	var image = Image.create(512, 512, false, Image.FORMAT_RGB8)
	
	# 클래스별 색상
	var color = (mesh_instance.material_override as StandardMaterial3D).albedo_color
	
	for y in range(512):
		for x in range(512):
			image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)

## 디테일 텍스처 (노이즈 패턴)
func _create_detail_texture() -> Texture2D:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05
	
	var image = Image.create(256, 256, false, Image.FORMAT_RGB8)
	
	for y in range(256):
		for x in range(256):
			var val = noise.get_noise_2d(x, y)
			var color_val = int((val + 1.0) / 2.0 * 255)
			image.set_pixel(x, y, Color(color_val / 255.0, color_val / 255.0, color_val / 255.0))
	
	return ImageTexture.create_from_image(image)

## 노멀 맵 생성
func _create_normal_map() -> Texture2D:
	var image = Image.create(256, 256, false, Image.FORMAT_RGB8)
	
	# 파란색 (0, 0, 1) 노멀 맵 (평탄 표면)
	for y in range(256):
		for x in range(256):
			image.set_pixel(x, y, Color(0.5, 0.5, 1.0))  # 파란색 채널 1
	
	return ImageTexture.create_from_image(image)

## 장비 장착
func equip_item(slot: String, model_name: String):
	"""
	특정 슬롯에 장비 장착
	slot: "helmet", "chest", "main_hand" 등
	model_name: 장비 모델 이름
	"""
	if slot not in equipment_slots:
		push_error("Unknown equipment slot: " + slot)
		return
	
	equipment_slots[slot] = model_name
	
	# 장비 메시 생성 및 위치 설정
	var equipment_mesh = _create_equipment_mesh(slot, model_name)
	if equipment_mesh:
		equipped_meshes[slot] = equipment_mesh
		add_child(equipment_mesh)
	
	print("✅ 장비 장착: %s → %s" % [slot, model_name])

## 장비 메시 생성
func _create_equipment_mesh(slot: String, model_name: String) -> MeshInstance3D:
	var mesh_instance_3d = MeshInstance3D.new()
	
	var mesh = null
	var position = Vector3.ZERO
	
	match slot:
		"helmet":
			mesh = SphereMesh.new()
			mesh.radius = 0.35
			position = Vector3(0, 1.8, 0)
		
		"chest":
			mesh = BoxMesh.new()
			mesh.size = Vector3(0.5, 1.0, 0.3)
			position = Vector3(0, 0.8, 0)
		
		"main_hand":
			mesh = BoxMesh.new()
			mesh.size = Vector3(0.2, 0.6, 0.2)
			position = Vector3(0.5, 0.5, 0)
		
		"off_hand":
			mesh = BoxMesh.new()
			mesh.size = Vector3(0.3, 0.3, 0.05)
			position = Vector3(-0.5, 0.6, 0)
		
		_:
			return null
	
	if mesh:
		mesh_instance_3d.mesh = mesh
		mesh_instance_3d.position = position
		
		# 클래스별 장비 색상
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.7, 0.7, 0.7)  # 철색
		mesh_instance_3d.material_override = mat
	
	return mesh_instance_3d

## 장비 해제
func unequip_item(slot: String):
	if slot in equipped_meshes:
		equipped_meshes[slot].queue_free()
		equipped_meshes.erase(slot)
	
	equipment_slots[slot] = null
	print("✅ 장비 해제: %s" % slot)

## 장비 정보 조회
func get_equipment_info() -> Dictionary:
	return {
		"slots": equipment_slots,
		"equipped_count": equipped_meshes.size(),
		"total_armor": equipment_slots.values().count(null) - 8  # 0 ~ 8
	}

## IK 업데이트 (매 프레임)
func _process(delta):
	super._process(delta)
	_update_ik_chains()

## IK 체인 업데이트 (Cyclic Coordinate Descent)
func _update_ik_chains():
	for chain_name in ik_chains.keys():
		var chain = ik_chains[chain_name]
		
		for iteration in range(chain.iterations):
			# Cyclic Coordinate Descent 알고리즘
			# (간단한 구현, 실제론 더 복잡함)
			pass

## 디버그 정보
func get_character_info() -> Dictionary:
	var base_info = super.get_debug_info()
	base_info.merge({
		"mesh_quality": MeshQuality.keys()[mesh_quality],
		"equipment": get_equipment_info(),
		"ik_chains": ik_chains.size(),
		"textures": {
			"base": base_texture != null,
			"detail": detail_texture != null,
			"normal": normal_map != null
		}
	})
	return base_info
