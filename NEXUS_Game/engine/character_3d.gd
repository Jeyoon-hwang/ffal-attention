extends Node3D
class_name Character3D

## 3D 캐릭터 모델 및 렌더링 시스템
## - 캐릭터 메시, 스켈레톤, 애니메이션 관리
## - 무술 이펙트 통합
## - 클래스별 외형 변형

@export var character_name: String = "Player"
@export var character_class: String = "Swordsman"  # 6가지 클래스
@export var level: int = 1

## 3D 모델 참조
var skeleton: Skeleton3D
var mesh_instance: MeshInstance3D
var animation_player: AnimationPlayer
var particle_manager: ParticleManager3D

## 클래스별 비주얼 설정
var class_visuals = {
	"Swordsman": {
		"color": Color(0.8, 0.6, 0.3),  # Gold
		"armor": "sword_armor",
		"weapon": "longsword"
	},
	"Archer": {
		"color": Color(0.3, 0.8, 0.5),  # Green
		"armor": "leather_armor",
		"weapon": "bow"
	},
	"Mage": {
		"color": Color(0.5, 0.3, 0.8),  # Purple
		"armor": "robe",
		"weapon": "staff"
	},
	"Rogue": {
		"color": Color(0.2, 0.2, 0.2),  # Black
		"armor": "shadow_armor",
		"weapon": "dagger"
	},
	"Paladin": {
		"color": Color(0.9, 0.9, 0.1),  # Yellow
		"armor": "plate_armor",
		"weapon": "holy_sword"
	},
	"Bard": {
		"color": Color(0.8, 0.3, 0.6),  # Pink
		"armor": "performer_coat",
		"weapon": "lute"
	}
}

## 애니메이션 상태
enum AnimationState {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	HIT,
	DEATH,
	CAST
}

var current_animation_state = AnimationState.IDLE

# 생명 주기
func _ready():
	_setup_3d_model()
	_setup_skeleton()
	_setup_animations()
	_apply_class_visuals()
	_setup_particle_manager()

func _process(delta):
	_update_animation_blend()

## 3D 모델 구성
func _setup_3d_model():
	# 메인 메시 (기본 캐릭터 형태)
	mesh_instance = MeshInstance3D.new()
	
	# 기본 캡슐 메시 (임시, 실제론 Blender 모델)
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 2.0
	
	mesh_instance.mesh = capsule_mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	add_child(mesh_instance)
	
	# 그림자 설정
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

## 스켈레톤 설정 (간단한 본 구조)
func _setup_skeleton():
	skeleton = Skeleton3D.new()
	add_child(skeleton)
	
	# 간단한 본 구조: Root -> Body -> Arms/Legs
	var root_bone = skeleton.create_bone()
	var body_bone = skeleton.create_bone()
	var left_arm = skeleton.create_bone()
	var right_arm = skeleton.create_bone()
	var left_leg = skeleton.create_bone()
	var right_leg = skeleton.create_bone()
	
	# 스켈레톤 초기화
	skeleton.set_bone_parent(body_bone, root_bone)
	skeleton.set_bone_parent(left_arm, body_bone)
	skeleton.set_bone_parent(right_arm, body_bone)
	skeleton.set_bone_parent(left_leg, body_bone)
	skeleton.set_bone_parent(right_leg, body_bone)

## 애니메이션 설정
func _setup_animations():
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	
	# 기본 애니메이션 클립 생성
	_create_animation_clip("idle", _generate_idle_animation())
	_create_animation_clip("walk", _generate_walk_animation())
	_create_animation_clip("run", _generate_run_animation())
	_create_animation_clip("attack", _generate_attack_animation())
	_create_animation_clip("hit", _generate_hit_animation())
	_create_animation_clip("cast", _generate_cast_animation())

func _create_animation_clip(anim_name: String, animation: Animation):
	var anim_lib = AnimationLibrary.new()
	anim_lib.add_animation(anim_name, animation)
	animation_player.add_animation_library("", anim_lib)

## 애니메이션 생성 함수들
func _generate_idle_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 2.0
	
	# 약간의 호흡 모션
	var track_idx = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(track_idx, "./MeshInstance3D:position")
	anim.track_insert_key(track_idx, 0.0, position)
	anim.track_insert_key(track_idx, 1.0, position + Vector3(0, 0.05, 0))
	anim.track_insert_key(track_idx, 2.0, position)
	
	return anim

func _generate_walk_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 1.0
	
	# 좌우 흔들림 모션
	var track_idx = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(track_idx, "./MeshInstance3D:position")
	anim.track_insert_key(track_idx, 0.0, position)
	anim.track_insert_key(track_idx, 0.25, position + Vector3(0.1, 0, 0))
	anim.track_insert_key(track_idx, 0.5, position)
	anim.track_insert_key(track_idx, 0.75, position + Vector3(-0.1, 0, 0))
	anim.track_insert_key(track_idx, 1.0, position)
	
	return anim

func _generate_run_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 0.6
	
	# 더 빠른 흔들림
	var track_idx = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(track_idx, "./MeshInstance3D:position")
	anim.track_insert_key(track_idx, 0.0, position)
	anim.track_insert_key(track_idx, 0.15, position + Vector3(0.15, -0.1, 0))
	anim.track_insert_key(track_idx, 0.3, position)
	anim.track_insert_key(track_idx, 0.45, position + Vector3(-0.15, -0.1, 0))
	anim.track_insert_key(track_idx, 0.6, position)
	
	return anim

func _generate_attack_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 0.5
	
	# 공격 모션 (회전 + 앞으로)
	var pos_track = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track, "./MeshInstance3D:position")
	anim.track_insert_key(pos_track, 0.0, position)
	anim.track_insert_key(pos_track, 0.3, position + Vector3(0, 0, 0.2))
	anim.track_insert_key(pos_track, 0.5, position)
	
	return anim

func _generate_hit_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 0.3
	
	# 히트 반응 (뒤로 밀림)
	var pos_track = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track, "./MeshInstance3D:position")
	anim.track_insert_key(pos_track, 0.0, position)
	anim.track_insert_key(pos_track, 0.15, position + Vector3(0, 0, -0.3))
	anim.track_insert_key(pos_track, 0.3, position)
	
	return anim

func _generate_cast_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 1.0
	
	# 시전 모션 (팔 올림)
	var scale_track = anim.add_track(Animation.TYPE_SCALE_3D)
	anim.track_set_path(scale_track, "./MeshInstance3D:scale")
	anim.track_insert_key(scale_track, 0.0, Vector3(1, 1, 1))
	anim.track_insert_key(scale_track, 0.5, Vector3(1.1, 1.2, 1))
	anim.track_insert_key(scale_track, 1.0, Vector3(1, 1, 1))
	
	return anim

## 클래스별 외형 적용
func _apply_class_visuals():
	if not character_class in class_visuals:
		return
	
	var visuals = class_visuals[character_class]
	
	# 메시 색상 적용
	var mat = mesh_instance.material_override as StandardMaterial3D
	mat.albedo_color = visuals["color"]
	mat.metallic = 0.3
	mat.roughness = 0.6

## 파티클 시스템 초기화
func _setup_particle_manager():
	particle_manager = ParticleManager3D.new()
	add_child(particle_manager)

## 애니메이션 상태 업데이트
func _update_animation_blend():
	match current_animation_state:
		AnimationState.IDLE:
			if not animation_player.is_playing() or animation_player.current_animation != "idle":
				animation_player.play("idle")
		AnimationState.ATTACK:
			animation_player.play("attack")
		AnimationState.HIT:
			animation_player.play("hit")
		AnimationState.CAST:
			animation_player.play("cast")

## 공개 인터페이스
func play_animation(anim_state: AnimationState):
	current_animation_state = anim_state

func play_martial_art_effect(martial_art_name: String, position_offset: Vector3 = Vector3.ZERO):
	particle_manager.play_martial_art_effect(martial_art_name, global_position + position_offset)

func set_class(new_class: String):
	character_class = new_class
	_apply_class_visuals()

## 디버그 정보
func get_debug_info() -> Dictionary:
	return {
		"name": character_name,
		"class": character_class,
		"level": level,
		"animation_state": AnimationState.keys()[current_animation_state],
		"position": global_position,
		"has_skeleton": skeleton != null
	}
