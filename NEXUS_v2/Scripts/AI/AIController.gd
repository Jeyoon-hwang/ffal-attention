## AIController.gd - 적 AI 상태 머신
## 적의 행동을 제어하는 인공지능

class_name AIController
extends Node

enum AIState { IDLE, CHASE, ATTACK, FLEE, DEAD }

# ===== 캐릭터 참조 =====
var character: Enemy = null
var target: Character = null

# ===== AI 설정 =====
var ai_level: int = 1  # 1-4
var current_state: AIState = AIState.IDLE

# ===== 타이머 =====
var state_timer: float = 0.0
var decision_timer: float = 0.0
var decision_interval: float = 1.0

# ===== AI 속성 =====
var aggression: float = 0.6       # 공격성 (0.0-1.0)
var intelligence: float = 0.3     # 지능 (0.0-1.0)
var caution: float = 0.4          # 조심성 (0.0-1.0)
var preferred_distance: float = 2.0

# ===== 패턴 기억 =====
var pattern_memory: Array[String] = []
var pattern_threshold: int = 3

func _init(p_character: Enemy = null, p_ai_level: int = 1) -> void:
	character = p_character
	ai_level = clampi(p_ai_level, 1, 4)

func update(delta: float) -> void:
	"""AI를 업데이트한다"""
	if not character or not character.is_alive:
		return
	
	state_timer += delta
	decision_timer += delta
	
	# 주기적으로 의사결정
	if decision_timer >= decision_interval:
		make_decision()
		decision_timer = 0.0
	
	# 상태별 행동
	match current_state:
		AIState.IDLE:
			idle_update(delta)
		
		AIState.CHASE:
			chase_update(delta)
		
		AIState.ATTACK:
			attack_update(delta)
		
		AIState.FLEE:
			flee_update(delta)
		
		AIState.DEAD:
			pass

# ===== 의사결정 =====

func make_decision() -> void:
	"""AI가 의사결정을 한다"""
	if not character:
		return
	
	if not target:
		current_state = AIState.IDLE
		return
	
	var distance = character.global_position.distance_to(target.global_position)
	
	match ai_level:
		1:
			decision_level_1(distance)
		2:
			decision_level_2(distance)
		3:
			decision_level_3(distance)
		4:
			decision_level_4(distance)

# ===== AI 레벨 1: 동물형 =====

func decision_level_1(distance: float) -> void:
	"""레벨 1: 동물형 AI (기본 추격 + 공격)"""
	
	if not target or not target.is_alive:
		current_state = AIState.IDLE
		return
	
	if distance < preferred_distance:
		current_state = AIState.ATTACK
	elif distance < 10.0:
		current_state = AIState.CHASE
	else:
		current_state = AIState.IDLE

# ===== AI 레벨 2: 기초 무술사 =====

func decision_level_2(distance: float) -> void:
	"""레벨 2: 기초 무술사 (패턴 감지 + 부분 회피)"""
	
	if not target or not target.is_alive:
		current_state = AIState.IDLE
		return
	
	# HP 낮으면 도망
	if character.current_hp < character.max_hp * 0.2:
		current_state = AIState.FLEE
		return
	
	if distance < preferred_distance:
		current_state = AIState.ATTACK
	elif distance < 10.0:
		# 일부 확률로 회피
		if randf() < intelligence * 0.3:
			# 회피할 목표 없으면 추격
			current_state = AIState.CHASE if randf() > 0.5 else AIState.IDLE
		else:
			current_state = AIState.CHASE
	else:
		current_state = AIState.IDLE

# ===== AI 레벨 3: 고급 무술사 =====

func decision_level_3(distance: float) -> void:
	"""레벨 3: 고급 무술사 (전략적 공격 + 패턴 학습)"""
	
	if not target or not target.is_alive:
		current_state = AIState.IDLE
		return
	
	# HP 20% 이하 = 도망
	if character.current_hp < character.max_hp * 0.2:
		current_state = AIState.FLEE
		return
	
	# HP 50% 이상 = 공격적
	if character.current_hp > character.max_hp * 0.5:
		aggression = 0.8
	else:
		aggression = 0.5
	
	if distance < preferred_distance:
		current_state = AIState.ATTACK
	elif distance < 10.0:
		current_state = AIState.CHASE
	else:
		current_state = AIState.IDLE

# ===== AI 레벨 4: 마스터 =====

func decision_level_4(distance: float) -> void:
	"""레벨 4: 마스터 (완벽한 적응 + 예측)"""
	
	# 현재는 레벨 3과 동일 (나중에 고도화)
	decision_level_3(distance)

# ===== 상태 행동 =====

func idle_update(delta: float) -> void:
	"""대기 상태"""
	pass

func chase_update(delta: float) -> void:
	"""추격 상태"""
	if not target:
		return
	
	var direction = (target.global_position - character.global_position).normalized()
	var speed = 2.0 + ai_level * 0.5  # AI 레벨에 따라 속도 증가
	character.global_position += direction * speed * delta

func attack_update(delta: float) -> void:
	"""공격 상태"""
	if character.is_attacking:
		return
	
	# 공격 실행
	execute_attack()

func flee_update(delta: float) -> void:
	"""도망 상태"""
	if not target:
		return
	
	var away_direction = (character.global_position - target.global_position).normalized()
	var speed = 1.5 + ai_level * 0.3
	character.global_position += away_direction * speed * delta

# ===== 공격 실행 =====

func execute_attack() -> void:
	"""무술 공격을 실행한다"""
	if character.is_attacking:
		return
	
	# 사용 가능한 무술 찾기
	var available_martials = []
	for martial in character.martial_arts:
		if martial and character.current_energy >= martial.energy_cost:
			available_martials.append(martial)
	
	if available_martials.is_empty():
		return
	
	# 무술 선택 (AI 레벨에 따라)
	var martial: MartialArt
	
	match ai_level:
		1:
			# 레벨 1: 랜덤
			martial = available_martials[randi() % available_martials.size()]
		
		2, 3, 4:
			# 레벨 2-4: 전략적 선택 (현재는 랜덤)
			martial = available_martials[randi() % available_martials.size()]
	
	# 무술 발동
	character.is_attacking = true
	character.use_energy(martial.energy_cost)
	
	# 애니메이션 재생 (나중에)
	# play_animation(martial)
	
	# 공격 종료 대기
	await character.get_tree().create_timer(martial.animation_duration).timeout
	character.is_attacking = false

# ===== 패턴 추적 =====

func remember_pattern(attack_id: String) -> void:
	"""상대의 공격 패턴을 기억한다"""
	pattern_memory.append(attack_id)
	
	if pattern_memory.size() > 5:
		pattern_memory.pop_front()

func detect_pattern() -> String:
	"""상대의 공격 패턴을 감지한다"""
	if pattern_memory.size() < pattern_threshold:
		return ""
	
	# 최근 3개 패턴이 같으면 감지
	if pattern_memory[-1] == pattern_memory[-2] and pattern_memory[-2] == pattern_memory[-3]:
		return pattern_memory[-1]
	
	return ""

# ===== 타겟 설정 =====

func set_target(t: Character) -> void:
	"""타겟을 설정한다"""
	target = t
	if target:
		print("[AI] %s가 %s를 목표로 설정" % [character.character_name, target.character_name])

func clear_target() -> void:
	"""타겟을 제거한다"""
	target = null
	current_state = AIState.IDLE

# ===== 디버깅 =====

func print_status() -> void:
	"""AI 상태 출력"""
	var state_name = ["IDLE", "CHASE", "ATTACK", "FLEE", "DEAD"][current_state]
	print("[AI] %s - 상태: %s, 타겟: %s" % [
		character.character_name if character else "없음",
		state_name,
		target.character_name if target else "없음"
	])
