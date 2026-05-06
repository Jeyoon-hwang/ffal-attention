extends CharacterBody3D

# ⚡ 글로벌 상수 참조
var constants = preload("res://src/scripts/constants.gd")
var boss_ai = preload("res://src/scripts/boss_ai.gd").new()

# 무협 적 설정
@export var faction = "사파"
@export var speed = constants.ENEMY_SPEED
@export var gravity = constants.ENEMY_GRAVITY
@export var detection_range = constants.ENEMY_DETECTION_RANGE
@export var attack_range = constants.ENEMY_ATTACK_RANGE
@export var max_health = constants.ENEMY_BASE_HEALTH
@export var attack_damage = constants.ENEMY_BASE_ATTACK_DAMAGE
@export var skill_chance = 0.3  # 무술 레벨별로 override

# 보스 AI 슸스템
var is_boss = false
var current_pattern = "\uae30본_\uacf5\uaca9"
var pattern_timer = 0.0

# 상태
var health = max_health
var target = null
var is_attacking = false
var attack_timer = 0.0
var ai_state = "idle"
var last_skill_time = 0.0
var skill_cooldown = 2.0

# 무술 레벨 (4단계)
var martial_level = 1  # 1 = 초급, 2 = 중급, 3 = 상급, 4 = 신급
var has_ultimate = false

# 신급 AI 전용 속성
var dodge_chance = 0.0  # 회피 확률 (레벨별로 다름)
var reaction_time = 0.5  # 반응 시간 (레벨별로 다름)
var reaction_timer = 0.0  # 반응 대기 타이머
var player_last_action = null  # 플레이어 마지막 행동 추적
var pattern_memory = []  # 패턴 메모리 (신급 AI)
var counter_chance = 0.0  # 카운터 확률 (신급은 높음)

func _ready():
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player")
	health = max_health
	
	# 레벨별 AI 속성 초기화
	dodge_chance = constants.get_dodge_chance(martial_level)
	reaction_time = constants.get_reaction_time(martial_level)
	
	# 신급 AI 추가 설정
	if martial_level == 4:
		counter_chance = 0.6  # 60% 카운터 확률
		pattern_memory = []  # 패턴 메모리 초기화
		print("%s 신급 AI 활성화 (회피: %.0f%%, 반응시간: %.2f초, 카운터: %.0f%%)" % [faction, dodge_chance * 100, reaction_time, counter_chance * 100])

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not target:
		return
	
	# 신급 AI: 반응 시간 적용
	if martial_level == 4:
		reaction_timer -= delta
		if reaction_timer > 0:
			return  # 반응 시간 동안 대기
	
	var distance = global_position.distance_to(target.global_position)
	
	# AI 상태 결정
	if distance <= attack_range:
		ai_state = "attack"
	elif distance <= detection_range:
		ai_state = "chase"
	else:
		ai_state = "idle"
	
	# 상태별 행동
	match ai_state:
		"idle":
			velocity.x = 0
			velocity.z = 0
		
		"chase":
			var direction = (target.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			look_at(target.global_position + Vector3(0, 1, 0), Vector3.UP)
		
		"attack":
			velocity.x = 0
			velocity.z = 0
			
			if is_boss:
				# 보스: pattern_timer 사용
				if pattern_timer <= 0:
					use_boss_pattern()
				pattern_timer -= delta
			else:
				# 일반 적: attack_timer 사용
				if attack_timer <= 0:
					# 신급 AI: 카운터 시도
					if martial_level == 4 and randf() < counter_chance:
						attempt_counter()
					else:
						# 무술 레벨에 따른 스킬 확률
						var actual_skill_chance = constants.get_skill_chance(martial_level)
						if randf() < actual_skill_chance and get_time_ms() - last_skill_time > constants.ENEMY_SKILL_COOLDOWN * 1000:
							use_skill()
							last_skill_time = get_time_ms()
							attack_timer = constants.ENEMY_SKILL_COOLDOWN
						else:
							basic_attack()
							attack_timer = constants.ENEMY_SKILL_COOLDOWN / 2
				
				attack_timer -= delta
	
	# Godot 4 API: move_and_slide()는 자동으로 velocity를 적용
	move_and_slide()

func basic_attack():
	# 레벨별 다중율 적용
	var level_multiplier = constants.ENEMY_DAMAGE_MULTIPLIERS.get(martial_level, 1.0)
	var damage = attack_damage * level_multiplier
	if target:
		target.take_damage(int(damage))
	print("%s 적(%d레벨)의 기본 공격: %.0f 대미지" % [faction, martial_level, damage])

func use_skill():
	var damage = attack_damage * constants.ENEMY_SKILL_DAMAGE_MULTIPLIER
	if target:
		target.take_damage(int(damage))
	print("%s 적의 무술 스킬 발동: %.0f 대미지!" % [faction, damage])

func attempt_counter():
	"""[신급 AI] 플레이어 공격 읽고 카운터하기"""
	var counter_damage = attack_damage * 2.5  # 카운터 데미지 2.5배
	print("%s 신급 적의 카운터! (%.0f 대미지)" % [faction, counter_damage])
	if target:
		target.take_damage(int(counter_damage))
		# 신급 AI는 카운터 후 반응 시간 짧게 적용
		attack_timer = 0.5

# 신급 AI 패턴 학습 함수
func learn_pattern(action: String) -> void:
	"""[신급 AI] 플레이어 패턴 기억"""
	if martial_level == 4:
		pattern_memory.append(action)
		if pattern_memory.size() > 20:  # 최대 20개까지만 기억
			pattern_memory.pop_front()

# 플레이어 공격 수신 시 회피 시도
func try_dodge() -> bool:
	"""[신급 AI] 공격 회피 시도 (take_damage 호출 전에 사용)"""
	if martial_level < 1:
		return false
	
	var dodge_roll = randf()
	if dodge_roll < dodge_chance:
		print("%s 적(%d레벨) 회피 성공! (%.0f%% 회피율)" % [faction, martial_level, dodge_chance * 100])
		# 신급 AI: 반응 시간 적용
		if martial_level == 4:
			reaction_timer = reaction_time  # 0.1초 동안 다른 행동 중단
		return true
	return false

func use_boss_pattern():
	"""[새 기능] 보스 AI 패턴 시스템"""
	if pattern_timer <= 0:
		# 다음 패턴 선택
		var hp_percent = health / float(max_health)
		var distance = global_position.distance_to(target.global_position)
		
		# 거리에 따른 추천 패턴
		current_pattern = boss_ai.get_recommended_pattern_by_distance(distance, hp_percent)
		var pattern_info = boss_ai.get_pattern_info(current_pattern)
		
		# 패턴 실행
		var damage = boss_ai.get_pattern_damage(current_pattern, attack_damage)
		if target:
			target.take_damage(int(damage))
		
		boss_ai.print_pattern_info(current_pattern)
		pattern_timer = pattern_info["cooldown"]
	
	pattern_timer -= get_physics_process_delta_time()

func take_damage(damage: int):
	# 신급 AI: 대아\gf늑 시도 (회피 로직은 이제 여기서 처리)
	# 참고: try_dodge()는 도움말 함수이고, 실제 회피는 여기서 처리
	health -= damage
	print("%s 적 체력: %.0f / %.0f" % [faction, health, max_health])
	if health <= 0:
		die()

func die():
	print("%s 적 처치! (파당: %s)" % [martial_level_name(), faction])
	queue_free()

func martial_level_name() -> String:
	match martial_level:
		1:
			return "초급 고수"
		2:
			return "중급 고수"
		3:
			return "상급 고수"
		4:
			return "신급 대가"
		_:
			return "미스터리 인물"

func get_time_ms() -> int:
	return int(Time.get_ticks_msec())
