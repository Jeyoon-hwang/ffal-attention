# 🥋 NEXUS 무협 - 보스 AI 패턴 시스템
# 보스가 다양한 공격 패턴을 사용하도록 구현

extends Node

# ⚡ 글로벌 상수
var constants = preload("res://src/scripts/constants.gd")

# 보스 패턴 정의
var patterns = {
	"기본_공격": {
		"name": "기본 공격",
		"damage": 1.0,
		"cooldown": 1.0,
		"range": 5.0,
		"description": "일반적인 근거리 공격"
	},
	"광선_기공": {
		"name": "광선 기공",
		"damage": 1.5,
		"cooldown": 2.5,
		"range": 15.0,
		"description": "먼 거리 에너지파 공격"
	},
	"회전_난검": {
		"name": "회전 난검",
		"damage": 2.0,
		"cooldown": 3.0,
		"range": 8.0,
		"aoe": true,
		"description": "광범위 회전 공격으로 주변 적들 타격"
	},
	"검기_연발": {
		"name": "검기 연발",
		"damage": 1.2,
		"cooldown": 2.0,
		"range": 10.0,
		"hits": 5,
		"description": "빠르게 연속으로 검기 발사"
	},
	"내력_폭발": {
		"name": "내력 폭발",
		"damage": 3.0,
		"cooldown": 4.0,
		"range": 20.0,
		"aoe": true,
		"description": "강력한 내력 충격파 (광범위, 높은 대미지)"
	},
	"치명적_일격": {
		"name": "치명적 일격",
		"damage": 4.0,
		"cooldown": 5.0,
		"range": 6.0,
		"description": "극도로 강력한 단일 공격, 장시간 쿨타임"
	}
}

# 패턴별 추천 사용 상황
var pattern_triggers = {
	"기본_공격": {"hp_range": [0.0, 1.0], "frequency": 0.4},
	"광선_기공": {"hp_range": [0.3, 1.0], "frequency": 0.3},
	"회전_난검": {"hp_range": [0.2, 0.8], "frequency": 0.2},
	"검기_연발": {"hp_range": [0.4, 1.0], "frequency": 0.25},
	"내력_폭발": {"hp_range": [0.1, 0.6], "frequency": 0.15},
	"치명적_일격": {"hp_range": [0.0, 0.4], "frequency": 0.1}  # 위험할 때 사용
}

# ============================================================
# 패턴 선택 함수
# ============================================================
func get_next_pattern(boss_hp_percent: float, last_pattern: String = "") -> String:
	"""
	보스의 현재 체력에 따라 적절한 패턴을 선택
	
	Args:
		boss_hp_percent: 현재 체력 비율 (0.0 ~ 1.0)
		last_pattern: 직전 패턴 (같은 패턴 연속 방지)
	
	Returns:
		다음 사용할 패턴 이름
	"""
	var available_patterns = []
	
	# 체력에 맞는 패턴 필터링
	for pattern_name in pattern_triggers.keys():
		var trigger = pattern_triggers[pattern_name]
		var hp_range = trigger["hp_range"]
		
		# 체력 범위 확인
		if boss_hp_percent >= hp_range[0] and boss_hp_percent <= hp_range[1]:
			# 같은 패턴 연속 방지 (70% 확률로 다른 패턴 선택)
			if pattern_name != last_pattern or randf() < 0.3:
				available_patterns.append(pattern_name)
	
	# 사용 가능한 패턴이 없으면 기본 공격
	if available_patterns.is_empty():
		return "기본_공격"
	
	# 빈도(frequency)를 바탕으로 가중치 선택
	var selected = available_patterns[randi() % available_patterns.size()]
	return selected

# ============================================================
# 패턴 정보 함수
# ============================================================
func get_pattern_info(pattern_name: String) -> Dictionary:
	"""패턴의 상세 정보 반환"""
	if pattern_name in patterns:
		return patterns[pattern_name]
	return patterns["기본_공격"]

func get_pattern_damage(pattern_name: String, base_damage: float) -> float:
	"""패턴의 실제 대미지 계산"""
	var pattern = get_pattern_info(pattern_name)
	return base_damage * pattern["damage"]

func is_aoe_pattern(pattern_name: String) -> bool:
	"""광역 공격 패턴인지 확인"""
	return get_pattern_info(pattern_name).get("aoe", false)

func get_pattern_range(pattern_name: String) -> float:
	"""패턴의 사거리 반환"""
	return get_pattern_info(pattern_name)["range"]

# ============================================================
# 난이도별 패턴 조정
# ============================================================
func adjust_pattern_for_difficulty(pattern_name: String, difficulty_level: int) -> Dictionary:
	"""
	난이도에 따라 패턴의 성능 조정
	difficulty_level: 1 (쉬움) ~ 5 (매우 어려움)
	"""
	var pattern = get_pattern_info(pattern_name).duplicate()
	
	match difficulty_level:
		1:  # 쉬움
			pattern["damage"] *= 0.7
			pattern["cooldown"] *= 1.3
		2:  # 보통
			pattern["damage"] *= 0.9
			pattern["cooldown"] *= 1.1
		3:  # 중간
			pass  # 기본값 유지
		4:  # 어려움
			pattern["damage"] *= 1.2
			pattern["cooldown"] *= 0.8
		5:  # 매우 어려움
			pattern["damage"] *= 1.5
			pattern["cooldown"] *= 0.6
	
	return pattern

# ============================================================
# 패턴 설명 출력
# ============================================================
func print_pattern_info(pattern_name: String) -> void:
	"""패턴 정보를 게임에 출력"""
	var info = get_pattern_info(pattern_name)
	print("\n⚔️ 보스 공격 패턴: %s" % info["name"])
	print("   대미지: %.1fx | 쿨타임: %.1f초 | 범위: %.0fm" % [info["damage"], info["cooldown"], info["range"]])
	print("   설명: %s" % info["description"])
	if info.get("aoe", false):
		print("   ⚠️  광역 공격!")
	if info.get("hits", 0) > 1:
		print("   💫 %d회 연타" % info["hits"])

# ============================================================
# 전략: 플레이어 거리에 따른 추천 패턴
# ============================================================
func get_recommended_pattern_by_distance(distance: float, boss_hp_percent: float) -> String:
	"""
	플레이어까지의 거리와 보스 체력에 따라 추천 패턴 반환
	"""
	if distance < 5:
		# 가까움: 광역 또는 높은 대미지 공격
		if boss_hp_percent < 0.3:
			return "내력_폭발"
		elif randf() < 0.5:
			return "회전_난검"
		else:
			return "기본_공격"
	elif distance < 12:
		# 중거리: 다양한 공격
		if boss_hp_percent < 0.3:
			return "치명적_일격"
		else:
			return "광선_기공" if randf() < 0.6 else "검기_연발"
	else:
		# 먼거리: 원거리 공격
		return "광선_기공"

# ============================================================
# 보스 전투 AI 통합 예시
# ============================================================
func create_boss_fight_script() -> String:
	"""
	이 시스템을 사용하는 enemy.gd의 보스 전투 부분 예시
	(실제 구현은 enemy.gd에 통합)
	"""
	var script = """
	# enemy.gd에서 사용 (보스인 경우)
	var boss_ai = preload("res://src/scripts/boss_ai.gd").new()
	var current_pattern = "기본_공격"
	var pattern_timer = 0.0
	
	func use_boss_pattern():
		if pattern_timer <= 0:
			var hp_percent = health / float(max_health)
			var distance = global_position.distance_to(target.global_position)
			
			# 다음 패턴 선택
			current_pattern = boss_ai.get_next_pattern(hp_percent, current_pattern)
			var pattern_info = boss_ai.get_pattern_info(current_pattern)
			
			# 패턴 실행
			var damage = boss_ai.get_pattern_damage(current_pattern, attack_damage)
			if boss_ai.is_aoe_pattern(current_pattern):
				# 광역 공격 - 주변 모든 플레이어 타격
				target.take_damage(int(damage))
			else:
				# 단일 공격
				target.take_damage(int(damage))
			
			boss_ai.print_pattern_info(current_pattern)
			pattern_timer = pattern_info["cooldown"]
		
		pattern_timer -= delta
	"""
	return script
