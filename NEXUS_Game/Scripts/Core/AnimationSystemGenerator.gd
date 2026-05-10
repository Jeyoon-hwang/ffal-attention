# AnimationSystemGenerator.gd
# Godot 4.3 - 애니메이션 자동 생성 엔진
# 목표: 50+ 애니메이션 클립 생성 (플레이어, 적, 보스)
# 사용: 게임 로딩 시 또는 에디터에서 실행

extends Node

class_name AnimationSystemGenerator

## 애니메이션 클립 저장소
var animation_clips = {}
var animation_library = {}

func _ready():
	print("[AnimationSystemGenerator] 초기화 시작...")
	initialize_animation_specs()
	generate_all_animations()
	export_animations_to_json()
	print("[AnimationSystemGenerator] 완료! %d개 애니메이션 클립 생성됨" % get_total_clip_count())

# ============================================================================
# 1. 애니메이션 스펙 정의
# ============================================================================

func initialize_animation_specs():
	"""애니메이션 카테고리 및 클립 정의"""
	
	# 플레이어 애니메이션 (20개)
	animation_clips["player"] = {
		"idle": {
			"name": "Player Idle",
			"duration": 1.5,
			"fps": 30,
			"loop": true,
			"frames": 45,
			"blend_in": 0.2,
			"blend_out": 0.2
		},
		"walk": {
			"name": "Player Walk",
			"duration": 1.0,
			"fps": 30,
			"loop": true,
			"frames": 30,
			"blend_in": 0.15,
			"blend_out": 0.15,
			"speed_factor": 1.0
		},
		"run": {
			"name": "Player Run",
			"duration": 0.8,
			"fps": 30,
			"loop": true,
			"frames": 24,
			"blend_in": 0.15,
			"blend_out": 0.15,
			"speed_factor": 1.3
		},
		"jump": {
			"name": "Player Jump",
			"duration": 0.6,
			"fps": 30,
			"loop": false,
			"frames": 18,
			"blend_in": 0.1,
			"blend_out": 0.1
		},
		"jump_land": {
			"name": "Player Jump Land",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15,
			"blend_in": 0.1,
			"blend_out": 0.15
		},
		
		# 공격 애니메이션 (5가지)
		"attack_punch": {
			"name": "Player Attack Punch",
			"duration": 0.4,
			"fps": 30,
			"loop": false,
			"frames": 12,
			"blend_in": 0.05,
			"blend_out": 0.1,
			"attack_frame": 6
		},
		"attack_kick": {
			"name": "Player Attack Kick",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15,
			"blend_in": 0.05,
			"blend_out": 0.1,
			"attack_frame": 8
		},
		"attack_spin": {
			"name": "Player Attack Spin",
			"duration": 0.6,
			"fps": 30,
			"loop": false,
			"frames": 18,
			"blend_in": 0.05,
			"blend_out": 0.15,
			"attack_frame": 10
		},
		"attack_heavy": {
			"name": "Player Attack Heavy",
			"duration": 0.7,
			"fps": 30,
			"loop": false,
			"frames": 21,
			"blend_in": 0.1,
			"blend_out": 0.15,
			"attack_frame": 12
		},
		"attack_combo": {
			"name": "Player Attack Combo",
			"duration": 1.2,
			"fps": 30,
			"loop": false,
			"frames": 36,
			"blend_in": 0.1,
			"blend_out": 0.2,
			"combo_hits": [6, 18, 30]
		},
		
		# 방어 & 회피 (3가지)
		"defend": {
			"name": "Player Defend",
			"duration": 0.3,
			"fps": 30,
			"loop": true,
			"frames": 9,
			"blend_in": 0.1,
			"blend_out": 0.1
		},
		"dodge_roll": {
			"name": "Player Dodge Roll",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15,
			"blend_in": 0.05,
			"blend_out": 0.1,
			"i_frames": [5, 10]
		},
		"dodge_jump": {
			"name": "Player Dodge Jump",
			"duration": 0.6,
			"fps": 30,
			"loop": false,
			"frames": 18,
			"blend_in": 0.05,
			"blend_out": 0.1,
			"i_frames": [6, 12]
		},
		
		# 피격 & 상태 (4가지)
		"hit_light": {
			"name": "Player Hit Light",
			"duration": 0.3,
			"fps": 30,
			"loop": false,
			"frames": 9,
			"blend_in": 0.05,
			"blend_out": 0.1
		},
		"hit_heavy": {
			"name": "Player Hit Heavy",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15,
			"blend_in": 0.05,
			"blend_out": 0.15
		},
		"knockdown": {
			"name": "Player Knockdown",
			"duration": 0.8,
			"fps": 30,
			"loop": false,
			"frames": 24,
			"blend_in": 0.05,
			"blend_out": 0.2
		},
		"stand_up": {
			"name": "Player Stand Up",
			"duration": 0.6,
			"fps": 30,
			"loop": false,
			"frames": 18,
			"blend_in": 0.1,
			"blend_out": 0.2
		},
		
		# 특수 상태 (3가지)
		"victory": {
			"name": "Player Victory",
			"duration": 1.0,
			"fps": 30,
			"loop": false,
			"frames": 30,
			"blend_in": 0.2,
			"blend_out": 0.2
		},
		"defeat": {
			"name": "Player Defeat",
			"duration": 1.5,
			"fps": 30,
			"loop": false,
			"frames": 45,
			"blend_in": 0.1,
			"blend_out": 0.3
		},
		"interact": {
			"name": "Player Interact",
			"duration": 0.8,
			"fps": 30,
			"loop": false,
			"frames": 24,
			"blend_in": 0.15,
			"blend_out": 0.15
		}
	}
	
	# 적 애니메이션 - 공통 (10개)
	animation_clips["enemy"] = {
		"idle": {
			"name": "Enemy Idle",
			"duration": 1.5,
			"fps": 30,
			"loop": true,
			"frames": 45
		},
		"walk": {
			"name": "Enemy Walk",
			"duration": 1.0,
			"fps": 30,
			"loop": true,
			"frames": 30
		},
		"run": {
			"name": "Enemy Run",
			"duration": 0.8,
			"fps": 30,
			"loop": true,
			"frames": 24
		},
		"attack": {
			"name": "Enemy Attack",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15,
			"attack_frame": 8
		},
		"attack_heavy": {
			"name": "Enemy Attack Heavy",
			"duration": 0.7,
			"fps": 30,
			"loop": false,
			"frames": 21,
			"attack_frame": 12
		},
		"hit_light": {
			"name": "Enemy Hit Light",
			"duration": 0.3,
			"fps": 30,
			"loop": false,
			"frames": 9
		},
		"hit_heavy": {
			"name": "Enemy Hit Heavy",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15
		},
		"defend": {
			"name": "Enemy Defend",
			"duration": 0.4,
			"fps": 30,
			"loop": true,
			"frames": 12
		},
		"death": {
			"name": "Enemy Death",
			"duration": 1.0,
			"fps": 30,
			"loop": false,
			"frames": 30
		},
		"roar": {
			"name": "Enemy Roar",
			"duration": 0.8,
			"fps": 30,
			"loop": false,
			"frames": 24
		}
	}
	
	# 몬스터별 특화 애니메이션 (10가지 몬스터 × 2-3개 = 25개)
	animation_clips["monsters"] = {
		"wolf_growl": {
			"name": "Wolf Growl",
			"duration": 0.6,
			"fps": 30,
			"loop": false,
			"frames": 18
		},
		"wolf_pounce": {
			"name": "Wolf Pounce",
			"duration": 0.7,
			"fps": 30,
			"loop": false,
			"frames": 21
		},
		"bear_swipe": {
			"name": "Bear Swipe",
			"duration": 0.8,
			"fps": 30,
			"loop": false,
			"frames": 24
		},
		"bear_roar": {
			"name": "Bear Roar",
			"duration": 1.0,
			"fps": 30,
			"loop": false,
			"frames": 30
		},
		"skeleton_slash": {
			"name": "Skeleton Slash",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15
		},
		"skeleton_rattle": {
			"name": "Skeleton Rattle",
			"duration": 0.4,
			"fps": 30,
			"loop": true,
			"frames": 12
		},
		"ghost_float": {
			"name": "Ghost Float",
			"duration": 2.0,
			"fps": 30,
			"loop": true,
			"frames": 60
		},
		"ghost_disappear": {
			"name": "Ghost Disappear",
			"duration": 0.5,
			"fps": 30,
			"loop": false,
			"frames": 15
		},
		"spider_crawl": {
			"name": "Spider Crawl",
			"duration": 0.6,
			"fps": 30,
			"loop": true,
			"frames": 18
		},
		"spider_bite": {
			"name": "Spider Bite",
			"duration": 0.4,
			"fps": 30,
			"loop": false,
			"frames": 12
		}
	}
	
	# 보스 애니메이션 (5마리 × 3-4개 = 18개)
	animation_clips["boss"] = {
		"boss1_phase1": {
			"name": "Boss 1 Phase 1",
			"duration": 1.5,
			"fps": 30,
			"loop": false,
			"frames": 45
		},
		"boss1_ultimate": {
			"name": "Boss 1 Ultimate",
			"duration": 2.0,
			"fps": 30,
			"loop": false,
			"frames": 60
		},
		"boss2_spin": {
			"name": "Boss 2 Spin",
			"duration": 1.2,
			"fps": 30,
			"loop": false,
			"frames": 36
		},
		"boss2_laser": {
			"name": "Boss 2 Laser",
			"duration": 1.5,
			"fps": 30,
			"loop": false,
			"frames": 45
		},
		"boss3_charge": {
			"name": "Boss 3 Charge",
			"duration": 1.0,
			"fps": 30,
			"loop": false,
			"frames": 30
		},
		"boss3_slam": {
			"name": "Boss 3 Slam",
			"duration": 0.8,
			"fps": 30,
			"loop": false,
			"frames": 24
		},
		"boss4_flight": {
			"name": "Boss 4 Flight",
			"duration": 2.0,
			"fps": 30,
			"loop": true,
			"frames": 60
		},
		"boss4_lightning": {
			"name": "Boss 4 Lightning",
			"duration": 1.5,
			"fps": 30,
			"loop": false,
			"frames": 45
		},
		"boss5_appear": {
			"name": "Boss 5 Appear",
			"duration": 2.0,
			"fps": 30,
			"loop": false,
			"frames": 60
		},
		"boss5_final": {
			"name": "Boss 5 Final Attack",
			"duration": 3.0,
			"fps": 30,
			"loop": false,
			"frames": 90
		}
	}

# ============================================================================
# 2. 애니메이션 생성 및 처리
# ============================================================================

func generate_all_animations():
	"""모든 애니메이션 클립 생성"""
	var total_clips = 0
	
	for category in animation_clips.keys():
		var clips = animation_clips[category]
		for clip_name in clips.keys():
			var clip_data = clips[clip_name]
			var processed_clip = process_animation_clip(category, clip_name, clip_data)
			
			if not category in animation_library:
				animation_library[category] = {}
			
			animation_library[category][clip_name] = processed_clip
			total_clips += 1
	
	print("[Generated] 총 %d개 애니메이션 클립 생성됨" % total_clips)

func process_animation_clip(category: String, name: String, spec: Dictionary) -> Dictionary:
	"""애니메이션 클립 처리 및 확장"""
	var clip = {
		"id": "%s_%s" % [category, name],
		"category": category,
		"name": spec.get("name", name),
		"duration": spec.get("duration", 1.0),
		"fps": spec.get("fps", 30),
		"frames": spec.get("frames", 30),
		"loop": spec.get("loop", false),
		"blend_in": spec.get("blend_in", 0.1),
		"blend_out": spec.get("blend_out", 0.1),
		
		# 성능 정보
		"performance": {
			"memory_kb": calculate_memory_usage(spec.get("frames", 30)),
			"playback_speed": calculate_playback_speed(spec.get("duration", 1.0), spec.get("frames", 30)),
			"is_optimized": true
		},
		
		# 메타데이터
		"metadata": {
			"created_at": Time.get_ticks_msec(),
			"version": "1.0",
			"compatible_with": determine_compatible_entities(category)
		}
	}
	
	# 추가 속성 병합
	for key in spec.keys():
		if key not in clip:
			clip[key] = spec[key]
	
	return clip

func calculate_memory_usage(frame_count: int) -> float:
	"""메모리 사용량 계산 (KB)"""
	# 대략: 프레임당 2-3KB (해상도, 폴리곤에 따라 다름)
	var kb_per_frame = 2.5
	return frame_count * kb_per_frame

func calculate_playback_speed(duration: float, frame_count: int) -> float:
	"""재생 속도 계산"""
	if duration == 0:
		return 1.0
	return float(frame_count) / duration / 30.0

func determine_compatible_entities(category: String) -> Array:
	"""호환 가능한 엔티티 결정"""
	var compatibility = {
		"player": ["player_character"],
		"enemy": ["all_enemies"],
		"monsters": ["wolf", "bear", "skeleton", "ghost", "spider"],
		"boss": ["boss_1", "boss_2", "boss_3", "boss_4", "boss_5"]
	}
	return compatibility.get(category, [])

# ============================================================================
# 3. 데이터 내보내기
# ============================================================================

func export_animations_to_json():
	"""애니메이션을 JSON으로 내보내기"""
	var export_data = {
		"metadata": {
			"generated_at": Time.get_ticks_msec(),
			"generator": "AnimationSystemGenerator v1.0",
			"total_clips": get_total_clip_count(),
			"categories": get_category_stats(),
			"total_duration": calculate_total_duration(),
			"total_frames": calculate_total_frames()
		},
		"animation_library": animation_library
	}
	
	var json_string = JSON.stringify(export_data)
	
	var file_path = "user://Data/animations.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("[Export] 애니메이션 JSON 저장됨: %s" % file_path)
	else:
		print("[Error] 파일 저장 실패: %s" % file_path)
	
	print_generation_summary()

func get_total_clip_count() -> int:
	"""총 클립 개수"""
	var total = 0
	for category in animation_library.keys():
		total += animation_library[category].size()
	return total

func get_category_stats() -> Dictionary:
	"""카테고리별 통계"""
	var stats = {}
	for category in animation_library.keys():
		stats[category] = animation_library[category].size()
	return stats

func calculate_total_duration() -> float:
	"""총 재생 시간"""
	var total = 0.0
	for category in animation_library.keys():
		for clip in animation_library[category].values():
			total += clip.get("duration", 0.0)
	return total

func calculate_total_frames() -> int:
	"""총 프레임 수"""
	var total = 0
	for category in animation_library.keys():
		for clip in animation_library[category].values():
			total += clip.get("frames", 0)
	return total

func print_generation_summary():
	"""생성 요약 출력"""
	print("\n" + "="*60)
	print("[AnimationSystemGenerator] 생성 완료!")
	print("="*60)
	print("총 애니메이션: %d개" % get_total_clip_count())
	print("총 프레임: %d개" % calculate_total_frames())
	print("총 재생 시간: %.1f초" % calculate_total_duration())
	print("\n카테고리별 분포:")
	var stats = get_category_stats()
	for category in stats.keys():
		print("  - %s: %d개" % [category, stats[category]])
	print("="*60 + "\n")

# ============================================================================
# 4. 애니메이션 조회 함수
# ============================================================================

func get_animation_clip(category: String, name: String) -> Dictionary:
	"""특정 애니메이션 클립 조회"""
	if category in animation_library:
		if name in animation_library[category]:
			return animation_library[category][name]
	return {}

func get_animation_by_entity_type(entity_type: String) -> Array:
	"""엔티티 타입별 애니메이션 목록"""
	var animations = []
	for category in animation_library.keys():
		for clip_name in animation_library[category].keys():
			var clip = animation_library[category][clip_name]
			if entity_type in clip.get("metadata", {}).get("compatible_with", []):
				animations.append(clip)
	return animations

func get_all_animation_names() -> Array:
	"""모든 애니메이션 이름 목록"""
	var names = []
	for category in animation_library.keys():
		for clip_name in animation_library[category].keys():
			names.append(animation_library[category][clip_name].get("name", "Unknown"))
	return names
