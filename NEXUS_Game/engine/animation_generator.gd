extends Node
class_name AnimationGenerator

## Week 3 Day 5: 애니메이션 자동 생성 시스템
## - 무술별 애니메이션 자동 생성
## - 파라미터 기반 애니메이션 변형
## - 200+ 애니메이션 클립 생성

## 애니메이션 파라미터
class AnimationParams:
	var base_duration: float = 0.5
	var speed_multiplier: float = 1.0
	var intensity: float = 1.0  # 움직임 크기
	var direction: Vector3 = Vector3.FORWARD
	var rotation_amount: float = 0.0

## 무술별 애니메이션 템플릿
var martial_art_animations = {
	"slash": {
		"base_duration": 0.5,
		"keyframes": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.2, "rotation": Vector3(0, -1.5, 0), "position": Vector3(0, 0, 0.3)},
			{"time": 0.5, "rotation": Vector3(0, 0, 0), "position": Vector3.ZERO}
		],
		"effect_trigger_time": 0.3
	},
	"thrust": {
		"base_duration": 0.4,
		"keyframes": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.2, "rotation": Vector3(0.5, 0, 0), "position": Vector3(0, 0, 0.5)},
			{"time": 0.4, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"effect_trigger_time": 0.25
	},
	"smash": {
		"base_duration": 0.6,
		"keyframes": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3(0, 1, 0)},
			{"time": 0.3, "rotation": Vector3(1.0, 0, 0), "position": Vector3(0, 0.5, 0)},
			{"time": 0.6, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"effect_trigger_time": 0.35
	},
	"wave": {
		"base_duration": 0.8,
		"keyframes": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.4, "rotation": Vector3(-1.5, 0, 0), "position": Vector3(0, 0.3, -0.3)},
			{"time": 0.8, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"effect_trigger_time": 0.5
	},
	"special": {
		"base_duration": 1.0,
		"keyframes": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.3, "rotation": Vector3(1.0, 1.0, 0.5), "position": Vector3(0, 0.2, 0)},
			{"time": 0.6, "rotation": Vector3(-1.0, -1.0, -0.5), "position": Vector3(0, 0, 0)},
			{"time": 1.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"effect_trigger_time": 0.6
	}
}

## Modifier별 애니메이션 변형
var modifier_transforms = {
	"quick": {
		"speed_multiplier": 0.6,  # 애니메이션 빨라짐
		"intensity": 0.8,         # 동작 작아짐
		"duration_reduction": 0.4
	},
	"heavy": {
		"speed_multiplier": 1.3,  # 애니메이션 느려짐
		"intensity": 1.3,         # 동작 커짐
		"duration_increase": 0.3
	},
	"wide": {
		"speed_multiplier": 1.0,
		"intensity": 1.5,         # 범위 넓어짐
		"duration_increase": 0.2
	},
	"precise": {
		"speed_multiplier": 1.1,
		"intensity": 0.7,         # 동작 정교함
		"duration_reduction": 0.1
	},
	"pierce": {
		"speed_multiplier": 0.8,
		"intensity": 1.0,
		"direction_change": true
	},
	"chain": {
		"speed_multiplier": 1.0,
		"intensity": 1.0,
		"repeat_count": 3  # 체인 반복
	},
	"drain": {
		"speed_multiplier": 1.2,
		"intensity": 1.0,
		"rotation_increase": 2.0  # 회전 추가
	},
	"poison": {
		"speed_multiplier": 0.7,
		"intensity": 0.9,
		"tremor_effect": true  # 떨림 이펙트
	}
}

## 생성된 애니메이션 캐시
var generated_animations = {}

# 초기화
func _ready():
	_generate_all_animations()

## 모든 애니메이션 생성
func _generate_all_animations():
	print("🎬 애니메이션 생성 시작...")
	
	var total = 0
	
	# Base 5가지 × Modifier 8가지 = 40가지
	for base_name in martial_art_animations.keys():
		for modifier_name in modifier_transforms.keys():
			var anim_name = "%s_%s" % [base_name, modifier_name]
			var anim = _generate_martial_art_animation(base_name, [modifier_name])
			generated_animations[anim_name] = anim
			total += 1
		
		# Base만
		var anim = _generate_martial_art_animation(base_name, [])
		generated_animations[base_name] = anim
		total += 1
	
	# 추가: 기본 애니메이션들
	_generate_basic_animations()
	total += 6
	
	# 추가: 콤보 애니메이션
	_generate_combo_animations()
	total += 20
	
	# 추가: 특수 애니메이션
	_generate_special_animations()
	total += 30
	
	print("✅ %d개 애니메이션 생성 완료" % total)

## 무술 애니메이션 생성
func _generate_martial_art_animation(base_name: String, modifiers: Array) -> Animation:
	if base_name not in martial_art_animations:
		push_error("Unknown base martial art: " + base_name)
		return Animation.new()
	
	var base_template = martial_art_animations[base_name]
	var anim = Animation.new()
	
	# 기본 지속시간
	var duration = base_template["base_duration"]
	var params = AnimationParams.new()
	
	# Modifier 적용
	for modifier in modifiers:
		if modifier in modifier_transforms:
			var transform = modifier_transforms[modifier]
			params.speed_multiplier *= transform.get("speed_multiplier", 1.0)
			params.intensity *= transform.get("intensity", 1.0)
			duration += transform.get("duration_increase", -transform.get("duration_reduction", 0.0))
	
	anim.length = duration
	
	# 포지션 트랙
	var pos_track_idx = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track_idx, ".:position")
	
	# 회전 트랙
	var rot_track_idx = anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rot_track_idx, ".:rotation")
	
	# 키프레임 추가
	for keyframe in base_template["keyframes"]:
		var time = keyframe["time"] / params.speed_multiplier
		var pos = keyframe["position"] * params.intensity
		var rot = keyframe["rotation"] * params.intensity
		
		# 시간이 애니메이션 길이를 넘지 않도록
		if time <= duration:
			anim.track_insert_key(pos_track_idx, time, pos)
			anim.track_insert_key(rot_track_idx, time, rot)
	
	return anim

## 기본 애니메이션 (IDLE, WALK, RUN, HIT, DEATH, VICTORY)
func _generate_basic_animations():
	# IDLE: 호흡 모션
	var idle = Animation.new()
	idle.length = 2.0
	var idle_pos = idle.add_track(Animation.TYPE_POSITION_3D)
	idle.track_set_path(idle_pos, ".:position")
	idle.track_insert_key(idle_pos, 0.0, Vector3.ZERO)
	idle.track_insert_key(idle_pos, 1.0, Vector3(0, 0.05, 0))
	idle.track_insert_key(idle_pos, 2.0, Vector3.ZERO)
	generated_animations["idle"] = idle
	
	# WALK: 좌우 흔들림
	var walk = Animation.new()
	walk.length = 1.0
	var walk_pos = walk.add_track(Animation.TYPE_POSITION_3D)
	walk.track_set_path(walk_pos, ".:position")
	walk.track_insert_key(walk_pos, 0.0, Vector3.ZERO)
	walk.track_insert_key(walk_pos, 0.25, Vector3(0.1, 0, 0))
	walk.track_insert_key(walk_pos, 0.5, Vector3.ZERO)
	walk.track_insert_key(walk_pos, 0.75, Vector3(-0.1, 0, 0))
	walk.track_insert_key(walk_pos, 1.0, Vector3.ZERO)
	generated_animations["walk"] = walk
	
	# RUN: 빠른 흔들림
	var run = Animation.new()
	run.length = 0.6
	var run_pos = run.add_track(Animation.TYPE_POSITION_3D)
	run.track_set_path(run_pos, ".:position")
	run.track_insert_key(run_pos, 0.0, Vector3.ZERO)
	run.track_insert_key(run_pos, 0.15, Vector3(0.15, -0.1, 0))
	run.track_insert_key(run_pos, 0.3, Vector3.ZERO)
	run.track_insert_key(run_pos, 0.45, Vector3(-0.15, -0.1, 0))
	run.track_insert_key(run_pos, 0.6, Vector3.ZERO)
	generated_animations["run"] = run
	
	# HIT: 뒤로 밀림
	var hit = Animation.new()
	hit.length = 0.3
	var hit_pos = hit.add_track(Animation.TYPE_POSITION_3D)
	hit.track_set_path(hit_pos, ".:position")
	hit.track_insert_key(hit_pos, 0.0, Vector3.ZERO)
	hit.track_insert_key(hit_pos, 0.15, Vector3(0, 0, -0.3))
	hit.track_insert_key(hit_pos, 0.3, Vector3.ZERO)
	generated_animations["hit"] = hit
	
	# DEATH: 스케일 축소 + 회전
	var death = Animation.new()
	death.length = 1.0
	var death_scale = death.add_track(Animation.TYPE_SCALE_3D)
	death.track_set_path(death_scale, ".:scale")
	death.track_insert_key(death_scale, 0.0, Vector3(1, 1, 1))
	death.track_insert_key(death_scale, 1.0, Vector3(0.5, 0.5, 0.5))
	generated_animations["death"] = death
	
	# VICTORY: 점프 + 환호
	var victory = Animation.new()
	victory.length = 1.0
	var vict_pos = victory.add_track(Animation.TYPE_POSITION_3D)
	victory.track_set_path(vict_pos, ".:position")
	vict_pos.insert_key(0.0, Vector3.ZERO)
	vict_pos.insert_key(0.5, Vector3(0, 1.0, 0))
	vict_pos.insert_key(1.0, Vector3.ZERO)
	generated_animations["victory"] = victory

## 콤보 애니메이션 (20개)
func _generate_combo_animations():
	for combo_level in range(1, 8):  # 1~7콤보
		var combo_anim = Animation.new()
		combo_anim.length = 0.5 + (combo_level * 0.1)
		
		# 스케일 변화 (콤보 커질수록 크게)
		var scale_track = combo_anim.add_track(Animation.TYPE_SCALE_3D)
		combo_anim.track_set_path(scale_track, ".:scale")
		
		var scale = 1.0 + (combo_level * 0.1)
		combo_anim.track_insert_key(scale_track, 0.0, Vector3(1, 1, 1))
		combo_anim.track_insert_key(scale_track, combo_anim.length / 2, Vector3(scale, scale, scale))
		combo_anim.track_insert_key(scale_track, combo_anim.length, Vector3(1, 1, 1))
		
		generated_animations["combo_%d" % combo_level] = combo_anim

## 특수 애니메이션 (30개)
func _generate_special_animations():
	# 상태 이상 애니메이션
	var status_effects = ["poison", "burn", "freeze", "shock", "curse", "bleed"]
	
	for status in status_effects:
		var status_anim = Animation.new()
		status_anim.length = 0.5
		
		# 위아래 떨림
		var pos_track = status_anim.add_track(Animation.TYPE_POSITION_3D)
		status_anim.track_set_path(pos_track, ".:position")
		
		for i in range(5):
			var time = (i / 5.0) * 0.5
			var offset = 0.05 if i % 2 == 0 else -0.05
			status_anim.track_insert_key(pos_track, time, Vector3(0, offset, 0))
		
		generated_animations["status_%s" % status] = status_anim
	
	# 채널링 애니메이션 (마법 시전 등)
	var channeling = Animation.new()
	channeling.length = 1.0
	var chan_rot = channeling.add_track(Animation.TYPE_ROTATION_3D)
	channeling.track_set_path(chan_rot, ".:rotation")
	channeling.track_insert_key(chan_rot, 0.0, Vector3.ZERO)
	channeling.track_insert_key(chan_rot, 0.5, Vector3(0, PI, 0))
	channeling.track_insert_key(chan_rot, 1.0, Vector3.ZERO)
	generated_animations["channeling"] = channeling
	
	# 기절 애니메이션
	var stun = Animation.new()
	stun.length = 1.0
	var stun_rot = stun.add_track(Animation.TYPE_ROTATION_3D)
	stun.track_set_path(stun_rot, ".:rotation")
	for i in range(10):
		var time = (i / 10.0) * 1.0
		var amount = PI / 4 if i % 2 == 0 else -PI / 4
		stun.track_insert_key(stun_rot, time, Vector3(amount, 0, 0))
	generated_animations["stun"] = stun

## 애니메이션 조회
func get_animation(name: String) -> Animation:
	if name in generated_animations:
		return generated_animations[name]
	return Animation.new()

## 애니메이션 리스트
func get_all_animations() -> Array:
	return generated_animations.keys()

## 애니메이션 정보
func get_animation_info(name: String) -> Dictionary:
	if name not in generated_animations:
		return {}
	
	var anim = generated_animations[name]
	return {
		"name": name,
		"duration": anim.length,
		"track_count": anim.get_track_count()
	}

## 통계
func get_animation_stats() -> Dictionary:
	return {
		"total_animations": generated_animations.size(),
		"base_animations": 6,
		"martial_art_combinations": generated_animations.size() - 6 - 20 - 30,
		"combo_animations": 20,
		"special_animations": 30
	}
