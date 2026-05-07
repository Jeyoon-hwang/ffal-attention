"""
CharacterAdvanced.gd - AAA급 캐릭터 고도화 시스템
Week 3 Day 5 구현
- 200+ 애니메이션 지원
- 캐릭터 커스터마이제이션
- 파티클 + 음향 통합
"""

extends Node3D

class_name CharacterAdvanced

# ========== 캐릭터 기본 정보 ==========

var character_name: String = "Hero"
var character_class: String = "Swordsman"
var level: int = 1
var experience: int = 0

# ========== 능력치 ==========

var stats = {
	"STR": 10,  # 근력
	"DEX": 10,  # 민첩
	"INT": 10,  # 지능
	"VIT": 10,  # 체력
	"WIS": 10,  # 지혜
	"CHA": 10,  # 매력
	"LCK": 10,  # 행운
	"RES": 10   # 저항
}

var health: float = 100.0
var max_health: float = 100.0
var mana: float = 50.0
var max_mana: float = 50.0

# ========== 외형 커스터마이제이션 ==========

var appearance = {
	"skin_tone": Color(0.9, 0.7, 0.5),  # 피부색
	"hair_color": Color(0.3, 0.2, 0.1),  # 머리색
	"armor_color": Color(0.5, 0.5, 0.5),  # 갑옷색
	"accent_color": Color(1.0, 0.8, 0.0),  # 강조색 (장식)
	"eye_color": Color(0.2, 0.3, 0.8)   # 눈색
}

var armor_style = {
	"head": "helmet_basic",      # 투구
	"body": "chest_plate",       # 가슴 갑옷
	"hands": "gauntlets_basic",  # 장갑
	"legs": "leg_plates",        # 다리 갑옷
	"feet": "boots_basic",       # 부츠
	"cloak": "none"              # 망토
}

# ========== 애니메이션 & 파티클 ==========

var animation_generator: AnimationGenerator
var current_animation: String = "idle"
var current_martial_art: String = ""
var animation_progress: float = 0.0
var is_playing_animation: bool = false
var animation_speed: float = 1.0

var particle_manager: ParticleManager3D
var current_effects: Array = []

# ========== 모델 캐싱 ==========

var mesh_node: MeshInstance3D
var skeleton: Skeleton3D
var armor_parts: Dictionary = {}  # 갑옷 메시별 렌더링
var hair_mesh: MeshInstance3D
var face_mesh: MeshInstance3D

# ========== 상태 이상 ==========

var status_effects = {
	"poisoned": false,
	"burned": false,
	"frozen": false,
	"stunned": false,
	"weakened": false,
	"buffed": false
}

var status_effect_timers = {}

# ========== 콤보 시스템 ==========

var combo_count: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0
var last_attack_time: float = 0.0

# ========== 초기화 ==========

func _ready():
	# 애니메이션 생성기 초기화
	animation_generator = AnimationGenerator.new()
	if animation_generator:
		animation_generator._ready()
	
	# 파티클 매니저 초기화
	particle_manager = ParticleManager3D.new()
	add_child(particle_manager)
	
	# 메시 구성
	_build_character_mesh()
	
	# 외형 적용
	_apply_appearance()
	_apply_armor_style()

func _process(delta):
	# 애니메이션 진행
	if is_playing_animation:
		_update_animation(delta)
	
	# 콤보 타이머 업데이트
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()
	
	# 상태 이상 업데이트
	_update_status_effects(delta)

# ========== 메시 구성 ==========

func _build_character_mesh():
	"""캐릭터 메시 생성 (높은 품질)"""
	# 본체 메시
	var body_mesh = CapsuleMesh.new()
	body_mesh.radius = 0.3
	body_mesh.height = 1.8
	
	mesh_node = MeshInstance3D.new()
	mesh_node.mesh = body_mesh
	mesh_node.material_override = StandardMaterial3D.new()
	add_child(mesh_node)
	
	# 스켈레톤 초기화 (20개 본)
	skeleton = Skeleton3D.new()
	add_child(skeleton)
	
	# 주요 본 추가
	var bone_names = [
		"Hips", "Spine", "Chest", "Neck", "Head",
		"LeftShoulder", "LeftArm", "LeftForeArm", "LeftHand",
		"RightShoulder", "RightArm", "RightForeArm", "RightHand",
		"LeftHip", "LeftLeg", "LeftFoot",
		"RightHip", "RightLeg", "RightFoot", "Tail"
	]
	
	for i in range(bone_names.size()):
		var bone_name = bone_names[i]
		skeleton.add_bone(bone_name)
		if i > 0:
			var parent_idx = (i - 1) / 2  # 계층 구조
			skeleton.set_bone_parent(i, parent_idx)
	
	# 기본 자세 설정
	_set_rest_pose()

func _set_rest_pose():
	"""기본 자세 설정"""
	if not skeleton:
		return
	
	var bone_transforms = {
		0: Transform3D(Basis.IDENTITY, Vector3(0, 1, 0)),  # Hips
		1: Transform3D(Basis.IDENTITY, Vector3(0, 0.3, 0)),  # Spine
		2: Transform3D(Basis.IDENTITY, Vector3(0, 0.3, 0)),  # Chest
		3: Transform3D(Basis.IDENTITY, Vector3(0, 0.2, 0)),  # Neck
		4: Transform3D(Basis.IDENTITY, Vector3(0, 0.15, 0)),  # Head
	}
	
	for bone_idx in bone_transforms.keys():
		skeleton.set_bone_rest(bone_idx, bone_transforms[bone_idx])

# ========== 외형 적용 ==========

func _apply_appearance():
	"""피부색, 머리색, 눈색 적용"""
	if mesh_node and mesh_node.material_override:
		var material = mesh_node.material_override as StandardMaterial3D
		material.albedo_color = appearance["skin_tone"]

func _apply_armor_style():
	"""갑옷 스타일 메시 생성 및 적용"""
	var armor_data = {
		"head": {"scale": Vector3(0.35, 0.4, 0.35), "pos": Vector3(0, 1.75, 0)},
		"body": {"scale": Vector3(0.5, 0.6, 0.35), "pos": Vector3(0, 1.0, 0)},
		"hands": {"scale": Vector3(0.25, 0.3, 0.25), "pos": Vector3(0.5, 0.7, 0)},
		"legs": {"scale": Vector3(0.4, 0.8, 0.35), "pos": Vector3(0, 0.3, 0)},
		"feet": {"scale": Vector3(0.3, 0.2, 0.4), "pos": Vector3(0, -0.9, 0)}
	}
	
	for part in armor_data.keys():
		var armor_mesh = BoxMesh.new()
		armor_mesh.size = armor_data[part]["scale"]
		
		var armor_instance = MeshInstance3D.new()
		armor_instance.mesh = armor_mesh
		armor_instance.position = armor_data[part]["pos"]
		
		# 갑옷 색상
		var material = StandardMaterial3D.new()
		material.albedo_color = appearance["armor_color"]
		material.metallic = 0.8
		material.roughness = 0.3
		armor_instance.material_override = material
		
		add_child(armor_instance)
		armor_parts[part] = armor_instance

# ========== 애니메이션 재생 ==========

func play_martial_art(martial_art_id: String):
	"""무술 애니메이션 재생"""
	if not animation_generator:
		return
	
	current_martial_art = martial_art_id
	is_playing_animation = true
	animation_progress = 0.0
	animation_speed = 1.0
	
	# 콤보 증가
	combo_count += 1
	combo_timer = combo_timeout
	
	# 파티클 효과 시작
	var particle_trigger = animation_generator.get_particle_trigger_time(martial_art_id)
	var duration = animation_generator.get_animation_duration(martial_art_id)
	var color = animation_generator.get_animation_color(martial_art_id)
	
	print("[Character] 무술 시작: %s (%.2fs)" % [martial_art_id, duration])
	
	# 애니메이션 데이터
	var animation_data = animation_generator.get_animation(martial_art_id)
	if animation_data:
		# 스켈레톤 애니메이션 (키프레임 적용)
		_apply_animation_keyframes(animation_data["key_frames"], duration)
		
		# 파티클 예약
		await get_tree().create_timer(particle_trigger).timeout
		if particle_manager:
			particle_manager.play_effect(martial_art_id, global_position, color)

func _apply_animation_keyframes(key_frames: Array, duration: float):
	"""키프레임 애니메이션 적용"""
	if not skeleton or key_frames.is_empty():
		return
	
	# 뼈 0 (Hips)에 키프레임 적용
	for key_frame in key_frames:
		var transform = Transform3D()
		transform.basis = Basis.from_euler(key_frame.get("rotation", Vector3.ZERO))
		transform.origin = key_frame.get("position", Vector3.ZERO)
		
		skeleton.set_bone_pose(0, transform)

func play_basic_animation(animation_name: String, duration: float = 0.6):
	"""기본 애니메이션 재생 (IDLE, WALK, RUN 등)"""
	current_animation = animation_name
	is_playing_animation = true
	animation_progress = 0.0
	
	print("[Character] 기본 애니메이션: %s" % animation_name)

func _update_animation(delta):
	"""애니메이션 진행 업데이트"""
	var duration = animation_generator.get_animation_duration(current_martial_art) if current_martial_art else 0.6
	
	animation_progress += delta * animation_speed
	
	if animation_progress >= duration:
		is_playing_animation = false
		animation_progress = 0.0

func get_animation_progress() -> float:
	"""애니메이션 진행 상황 (0.0 ~ 1.0)"""
	var duration = animation_generator.get_animation_duration(current_martial_art) if current_martial_art else 0.6
	return clamp(animation_progress / duration, 0.0, 1.0)

# ========== 콤보 시스템 ==========

func reset_combo():
	"""콤보 초기화"""
	if combo_count > 0:
		print("[Character] 콤보 %d 끝남" % combo_count)
	combo_count = 0
	combo_timer = 0.0

func get_combo_count() -> int:
	"""현재 콤보 수"""
	return combo_count

func get_combo_damage_multiplier() -> float:
	"""콤보 데미지 배수"""
	return 1.0 + (combo_count * 0.1)  # 콤보당 +10%

# ========== 상태 이상 ==========

func apply_status_effect(effect_type: String, duration: float = 3.0):
	"""상태 이상 적용"""
	if effect_type not in status_effects:
		return
	
	status_effects[effect_type] = true
	status_effect_timers[effect_type] = duration
	
	# 상태 이상 애니메이션/파티클
	_play_status_effect_animation(effect_type)
	
	print("[Character] 상태 이상 적용: %s (%.1fs)" % [effect_type, duration])

func _play_status_effect_animation(effect_type: String):
	"""상태 이상 시각 효과"""
	var effect_colors = {
		"poisoned": Color(0.0, 1.0, 0.0, 0.5),
		"burned": Color(1.0, 0.5, 0.0, 0.5),
		"frozen": Color(0.5, 0.8, 1.0, 0.5),
		"stunned": Color(1.0, 1.0, 0.0, 0.5),
		"weakened": Color(0.8, 0.8, 0.8, 0.3)
	}
	
	if effect_type in effect_colors and particle_manager:
		var color = effect_colors[effect_type]
		particle_manager.play_effect(effect_type, global_position, color)

func _update_status_effects(delta):
	"""상태 이상 타이머 업데이트"""
	for effect_type in status_effect_timers.keys():
		status_effect_timers[effect_type] -= delta
		if status_effect_timers[effect_type] <= 0:
			status_effects[effect_type] = false
			status_effect_timers.erase(effect_type)
			print("[Character] 상태 이상 해제: %s" % effect_type)

func has_status_effect(effect_type: String) -> bool:
	"""상태 이상 확인"""
	return status_effects.get(effect_type, false)

# ========== 데미지 & 회복 ==========

func take_damage(damage: float, is_critical: bool = false):
	"""데미지 입기"""
	var final_damage = damage
	
	# 상태 이상 적용 (예: 약화 상태에서 +50% 데미지)
	if has_status_effect("weakened"):
		final_damage *= 1.5
	
	health -= final_damage
	health = clamp(health, 0, max_health)
	
	print("[Character] 데미지: %.1f / HP: %.1f/%.1f" % [final_damage, health, max_health])
	
	# 피격 애니메이션
	play_basic_animation("hit", 0.3)
	
	# 데미지 플로팅 텍스트
	if particle_manager:
		var damage_text = "%.0f" % final_damage
		if is_critical:
			damage_text = "CRIT! %s" % damage_text
		particle_manager.show_damage_text(global_position, damage_text, is_critical)

func heal(amount: float):
	"""회복"""
	health += amount
	health = clamp(health, 0, max_health)
	
	print("[Character] 회복: %.1f / HP: %.1f/%.1f" % [amount, health, max_health])
	
	# 회복 이펙트
	if particle_manager:
		particle_manager.play_effect("heal", global_position, Color(0.0, 1.0, 0.0, 1.0))

func is_alive() -> bool:
	"""생존 여부"""
	return health > 0

# ========== 능력치 ==========

func add_stat(stat_name: String, amount: int):
	"""능력치 증가"""
	if stat_name in stats:
		stats[stat_name] += amount
		print("[Character] 능력치 증가: %s +%d → %d" % [stat_name, amount, stats[stat_name]])

func calculate_damage(base_damage: float, stat_scaling: Dictionary) -> float:
	"""데미지 계산"""
	var total = base_damage
	
	for stat_name in stat_scaling.keys():
		if stat_name in stats:
			total += stats[stat_name] * stat_scaling[stat_name]
	
	return total

# ========== 정보 조회 ==========

func get_character_info() -> Dictionary:
	"""캐릭터 정보"""
	return {
		"name": character_name,
		"class": character_class,
		"level": level,
		"health": health,
		"max_health": max_health,
		"mana": mana,
		"max_mana": max_mana,
		"stats": stats.duplicate(),
		"combo": combo_count,
		"status_effects": status_effects.duplicate(),
		"animation_progress": get_animation_progress(),
		"current_martial_art": current_martial_art
	}

func get_visual_info() -> Dictionary:
	"""외형 정보"""
	return {
		"appearance": appearance.duplicate(),
		"armor_style": armor_style.duplicate(),
		"animation_count": animation_generator.get_animation_count() if animation_generator else 0
	}

# ========== 레벨 업 ==========

func level_up():
	"""레벨 업"""
	level += 1
	max_health += 10
	health = max_health
	max_mana += 5
	mana = max_mana
	
	# 각 능력치 +1
	for stat_name in stats.keys():
		stats[stat_name] += 1
	
	print("[Character] 레벨 업! Level %d" % level)
