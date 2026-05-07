"""
AnimationGenerator.gd - 200+ 무술 애니메이션 자동 생성 시스템
Week 3 Day 5 구현
"""

extends Node

class_name AnimationGenerator

# 애니메이션 데이터 구조
var animation_library: Dictionary = {}
var martial_arts_db: Dictionary = {}

# 기본 애니메이션 템플릿 (Base 5가지)
var base_animations = {
	"slash": {
		"name": "Slash",
		"duration": 0.6,
		"key_frames": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.3, "rotation": Vector3(0, 0, 1.57), "position": Vector3(0, 0, 0.2)},
			{"time": 0.6, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"particle_trigger": 0.3,
		"sound": "slash.wav",
		"color": Color.WHITE
	},
	"thrust": {
		"name": "Thrust",
		"duration": 0.5,
		"key_frames": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.25, "rotation": Vector3.ZERO, "position": Vector3(0, 0, 0.5)},
			{"time": 0.5, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"particle_trigger": 0.25,
		"sound": "thrust.wav",
		"color": Color(0.7, 0.9, 1.0, 1.0)  # 청백색
	},
	"smash": {
		"name": "Smash",
		"duration": 0.8,
		"key_frames": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3(0, 0.5, 0)},
			{"time": 0.4, "rotation": Vector3(3.14, 0, 0), "position": Vector3(0, -0.5, 0)},
			{"time": 0.8, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"particle_trigger": 0.4,
		"sound": "smash.wav",
		"color": Color(1.0, 0.8, 0.0, 1.0)  # 금색
	},
	"wave": {
		"name": "Wave",
		"duration": 0.4,
		"key_frames": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.2, "rotation": Vector3(0, 0, 1.57), "position": Vector3(0.3, 0, 0)},
			{"time": 0.4, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"particle_trigger": 0.2,
		"sound": "wave.wav",
		"color": Color(0.0, 0.5, 1.0, 1.0)  # 청색
	},
	"special": {
		"name": "Special",
		"duration": 1.0,
		"key_frames": [
			{"time": 0.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO},
			{"time": 0.5, "rotation": Vector3(3.14, 1.57, 0), "position": Vector3(0, 0.3, 0.3)},
			{"time": 1.0, "rotation": Vector3.ZERO, "position": Vector3.ZERO}
		],
		"particle_trigger": 0.5,
		"sound": "special.wav",
		"color": Color(1.0, 0.0, 1.0, 1.0)  # 마젠타
	}
}

# Modifier별 애니메이션 오버레이 (Base를 변형)
var modifier_overlays = {
	"quick": {
		"speed_multiplier": 1.4,  # 40% 더 빠름
		"color_blend": Color(1.0, 1.0, 0.0, 0.3),  # 황색 혼합
		"duration_reduction": 0.4  # 쿨타임 감소
	},
	"heavy": {
		"speed_multiplier": 0.7,  # 30% 더 느림
		"color_blend": Color(0.6, 0.3, 0.0, 0.3),  # 갈색 혼합
		"duration_increase": 0.3  # 쿨타임 증가
	},
	"wide": {
		"speed_multiplier": 1.0,
		"color_blend": Color(1.0, 0.5, 0.0, 0.3),  # 주황색 혼합
		"scale_increase": 1.5  # 애니메이션 범위 확대
	},
	"precise": {
		"speed_multiplier": 1.2,
		"color_blend": Color(0.0, 1.0, 0.0, 0.3),  # 초록색 혼합
		"scale_reduction": 0.7  # 애니메이션 범위 축소
	},
	"pierce": {
		"speed_multiplier": 1.1,
		"color_blend": Color(1.0, 0.0, 0.0, 0.3),  # 빨강 혼합
		"duration_increase": 0.2
	},
	"chain": {
		"speed_multiplier": 1.3,
		"color_blend": Color(1.0, 0.8, 0.0, 0.3),  # 황금색 혼합
		"repeat_count": 3  # 3번 연속 실행
	},
	"drain": {
		"speed_multiplier": 1.0,
		"color_blend": Color(0.5, 0.0, 0.5, 0.3),  # 보라색 혼합
		"rotation_multiplier": 2.0  # 회전 효과
	},
	"poison": {
		"speed_multiplier": 1.1,
		"color_blend": Color(0.0, 0.8, 0.3, 0.3),  # 초록색 혼합
		"particle_density": 2.0  # 파티클 2배
	}
}

# ============ 초기화 ============

func _ready():
	load_martial_arts_db()
	generate_all_animations()

func load_martial_arts_db():
	"""무술 DB에서 모든 무술 조합을 로드"""
	var file_path = "res://content/martial_arts_db.json"
	if ResourceLoader.exists(file_path):
		var json = JSON.new()
		var content = FileAccess.get_file_as_string(file_path)
		json.parse(content)
		martial_arts_db = json.data
		print("[AnimationGenerator] 무술 DB 로드 완료: %d개 무술" % martial_arts_db.size())
	else:
		print("[AnimationGenerator] 무술 DB 파일 없음, 기본값 사용")
		_create_default_martial_arts()

func _create_default_martial_arts():
	"""기본 무술 데이터 생성"""
	martial_arts_db = {}
	
	# Base 5가지
	for base in base_animations.keys():
		martial_arts_db[base] = {
			"name": base.to_upper(),
			"base": base,
			"modifiers": [],
			"damage": 10,
			"duration": 0.6
		}
	
	# Base + Modifier 조합 (최대 70개)
	var count = 5
	for base in base_animations.keys():
		for modifier in modifier_overlays.keys():
			if count >= 70:
				break
			martial_arts_db["%s_%s" % [base, modifier]] = {
				"name": "%s %s" % [base.to_upper(), modifier.to_upper()],
				"base": base,
				"modifiers": [modifier],
				"damage": 15,
				"duration": 0.6
			}
			count += 1

func generate_all_animations() -> int:
	"""모든 무술에 대한 애니메이션 생성"""
	var generated_count = 0
	
	for martial_art_id in martial_arts_db.keys():
		var martial_art = martial_arts_db[martial_art_id]
		var animation_data = generate_animation_for_martial_art(martial_art)
		animation_library[martial_art_id] = animation_data
		generated_count += 1
	
	print("[AnimationGenerator] 애니메이션 생성 완료: %d개" % generated_count)
	return generated_count

# ============ 애니메이션 생성 로직 ============

func generate_animation_for_martial_art(martial_art: Dictionary) -> Dictionary:
	"""개별 무술에 대한 애니메이션 생성"""
	var base = martial_art.get("base", "slash")
	var modifiers = martial_art.get("modifiers", [])
	
	# Base 애니메이션 시작
	var animation = base_animations[base].duplicate(true)
	
	# Modifier 오버레이 적용
	for modifier in modifiers:
		_apply_modifier_overlay(animation, modifier)
	
	# 최종 계산
	animation["martial_art_id"] = martial_art.get("name", base)
	animation["base"] = base
	animation["modifiers"] = modifiers
	animation["damage"] = martial_art.get("damage", 10)
	
	return animation

func _apply_modifier_overlay(animation: Dictionary, modifier: String):
	"""Modifier 효과를 애니메이션에 적용"""
	if modifier not in modifier_overlays:
		return
	
	var overlay = modifier_overlays[modifier]
	
	# 1. 속도 조정 (duration 수정)
	if "speed_multiplier" in overlay:
		var speed = overlay["speed_multiplier"]
		animation["duration"] /= speed
		
		# 키프레임 타임 재계산
		for key_frame in animation["key_frames"]:
			key_frame["time"] /= speed
	
	# 2. 색상 혼합
	if "color_blend" in overlay:
		var blend_color = overlay["color_blend"]
		var original_color = animation["color"]
		animation["color"] = original_color.lerp(blend_color, blend_color.a)
	
	# 3. 스케일 조정
	if "scale_increase" in overlay or "scale_reduction" in overlay:
		var scale = overlay.get("scale_increase", overlay.get("scale_reduction", 1.0))
		for key_frame in animation["key_frames"]:
			key_frame["position"] *= scale
	
	# 4. 회전 곱하기
	if "rotation_multiplier" in overlay:
		var multiplier = overlay["rotation_multiplier"]
		for key_frame in animation["key_frames"]:
			key_frame["rotation"] *= multiplier
	
	# 5. 파티클 조정
	if "particle_density" in overlay:
		animation["particle_density"] = overlay.get("particle_density", 1.0)
	
	# 6. 반복 횟수 (Chain 효과)
	if "repeat_count" in overlay:
		animation["repeat_count"] = overlay["repeat_count"]

# ============ 애니메이션 재생 ============

func get_animation(martial_art_id: String) -> Dictionary:
	"""애니메이션 정보 조회"""
	return animation_library.get(martial_art_id, {})

func get_animation_duration(martial_art_id: String) -> float:
	"""애니메이션 길이 조회"""
	var animation = animation_library.get(martial_art_id, {})
	return animation.get("duration", 0.6)

func get_particle_trigger_time(martial_art_id: String) -> float:
	"""파티클 발생 시점 조회"""
	var animation = animation_library.get(martial_art_id, {})
	return animation.get("particle_trigger", 0.3)

func get_animation_color(martial_art_id: String) -> Color:
	"""애니메이션 색상 조회 (파티클 색상)"""
	var animation = animation_library.get(martial_art_id, {})
	return animation.get("color", Color.WHITE)

func get_animation_info(martial_art_id: String) -> Dictionary:
	"""전체 애니메이션 정보"""
	return {
		"id": martial_art_id,
		"duration": get_animation_duration(martial_art_id),
		"color": get_animation_color(martial_art_id),
		"trigger_time": get_particle_trigger_time(martial_art_id),
		"animation": animation_library.get(martial_art_id, {})
	}

# ============ 통계 ============

func get_animation_count() -> int:
	"""생성된 애니메이션 총 개수"""
	return animation_library.size()

func get_animation_stats() -> Dictionary:
	"""애니메이션 통계"""
	return {
		"total_animations": animation_library.size(),
		"base_types": base_animations.size(),
		"modifiers": modifier_overlays.size(),
		"average_duration": _calculate_average_duration(),
		"unique_colors": _count_unique_colors()
	}

func _calculate_average_duration() -> float:
	"""평균 애니메이션 길이"""
	if animation_library.is_empty():
		return 0.0
	
	var total = 0.0
	for animation in animation_library.values():
		total += animation.get("duration", 0.6)
	
	return total / animation_library.size()

func _count_unique_colors() -> int:
	"""고유 색상 개수"""
	var colors = {}
	for animation in animation_library.values():
		var color = animation.get("color", Color.WHITE)
		colors[color] = true
	
	return colors.size()

# ============ 디버깅 ============

func print_animation_library():
	"""애니메이션 라이브러리 출력 (디버깅용)"""
	print("\n=== Animation Library ===")
	print("Total Animations: %d\n" % animation_library.size())
	
	for martial_art_id in animation_library.keys():
		var animation = animation_library[martial_art_id]
		print("%s:" % martial_art_id)
		print("  - Duration: %.2fs" % animation["duration"])
		print("  - Color: %s" % animation["color"])
		print("  - Trigger: %.2fs" % animation["particle_trigger"])
	
	print("\n=== Statistics ===")
	var stats = get_animation_stats()
	for key in stats.keys():
		print("%s: %s" % [key, stats[key]])
