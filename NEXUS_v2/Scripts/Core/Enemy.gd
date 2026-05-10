## Enemy.gd - 적 캐릭터
## AI 제어 및 적 전용 로직

class_name Enemy
extends Character

# ===== AI =====
var ai_controller: AIController = null

# ===== 드롭 =====
var drop_items: Array[String] = []
var drop_experience: int = 0
var drop_fragment_chance: float = 0.1

# ===== 행동 =====
var current_target: Character = null
var decision_timer: float = 0.0
var decision_interval: float = 1.0

# ===== 상태 저장 =====
var spawn_position: Vector3 = Vector3.ZERO
var is_boss: bool = false

func _ready() -> void:
	super._ready()
	
	# AI 컨트롤러 생성
	ai_controller = AIController.new()
	ai_controller.character = self
	ai_controller.ai_level = 1
	
	spawn_position = global_position
	
	print("[적] %s (레벨: %d, AI Level: %d) 초기화" % [character_name, level, ai_controller.ai_level])

func _process(delta: float) -> void:
	if not is_alive or not is_in_combat:
		return
	
	if ai_controller:
		ai_controller.update(delta)
	
	decision_timer += delta
	if decision_timer >= decision_interval:
		make_decision()
		decision_timer = 0.0

# ===== AI 의사결정 =====

func make_decision() -> void:
	"""AI 의사결정을 한다"""
	if not current_target:
		return
	
	var distance = global_position.distance_to(current_target.global_position)
	
	match ai_controller.ai_level:
		1:
			decision_level_1(distance)
		2:
			decision_level_2(distance)
		3:
			decision_level_3(distance)
		4:
			decision_level_4(distance)

# ===== 레벨 1: 동물형 AI =====

func decision_level_1(distance: float) -> void:
	"""레벨 1: 간단한 추격 + 공격"""
	
	if distance < 2.0:
		# 공격 거리 내
		execute_random_attack()
	elif distance < 10.0:
		# 추격 거리 내
		chase_target()
	else:
		# 대기
		idle()

# ===== 레벨 2: 기초 무술사 AI =====

func decision_level_2(distance: float) -> void:
	"""레벨 2: 패턴 감지 + 회피"""
	
	if distance < 2.0:
		execute_random_attack()
	elif distance < 10.0:
		# 일부 확률로 회피
		if randf() < 0.3:
			dodge()
		else:
			chase_target()
	else:
		idle()

# ===== 레벨 3: 고급 무술사 AI =====

func decision_level_3(distance: float) -> void:
	"""레벨 3: 전략적 공격"""
	
	if distance < 2.0:
		# 체력 낮으면 도망
		if current_hp < max_hp * 0.3:
			flee()
		else:
			execute_random_attack()
	elif distance < 10.0:
		chase_target()
	else:
		idle()

# ===== 레벨 4: 마스터 AI =====

func decision_level_4(distance: float) -> void:
	"""레벨 4: 완벽한 적응"""
	
	# 현재는 레벨 3과 동일 (나중에 고도화)
	decision_level_3(distance)

# ===== 행동 =====

func chase_target() -> void:
	"""목표를 추격한다"""
	if not current_target:
		return
	
	var direction = (current_target.global_position - global_position).normalized()
	global_position += direction * 2.0 * 0.016  # 60 FPS 가정

func idle() -> void:
	"""대기한다"""
	pass

func dodge() -> void:
	"""회피한다"""
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	global_position += random_direction * 1.5 * 0.016

func flee() -> void:
	"""도망친다"""
	if not current_target:
		return
	
	var away_direction = (global_position - current_target.global_position).normalized()
	global_position += away_direction * 3.0 * 0.016

# ===== 공격 =====

func execute_random_attack() -> void:
	"""무술을 랜덤으로 발동한다"""
	
	if is_attacking:
		return
	
	# 사용 가능한 무술 찾기
	var available_martials = []
	for martial in martial_arts:
		if martial and use_energy(martial.energy_cost):
			available_martials.append(martial)
	
	if available_martials.is_empty():
		return
	
	var martial = available_martials[randi() % available_martials.size()]
	
	is_attacking = true
	print("[적] %s 공격: %s (데미지: %d)" % [character_name, martial.martial_name, martial.base_damage])
	
	await get_tree().create_timer(martial.animation_duration).timeout
	is_attacking = false

# ===== 보상 =====

func set_as_boss(boss: bool = true) -> void:
	"""보스로 설정한다"""
	is_boss = boss
	if boss:
		level = 10
		max_hp *= 5
		current_hp = max_hp
		drop_experience = 500
		print("[보스] %s 생성! (HP: %d)" % [character_name, max_hp])

func get_drop_items() -> Array[String]:
	"""드롭 아이템을 반환한다"""
	return drop_items

func get_drop_experience() -> int:
	"""드롭 경험치를 반환한다"""
	return drop_experience

func get_drop_fragments() -> int:
	"""드롭 프래그먼트 개수"""
	var fragments = 0
	if randf() < drop_fragment_chance:
		fragments = 1
	if is_boss and randf() < drop_fragment_chance * 2:
		fragments += 1
	return fragments

# ===== 상태 =====

func on_defeated(victor: Character) -> void:
	"""적이 패배한다"""
	is_alive = false
	print("[적] %s가 %s에게 패배했습니다!" % [character_name, victor.character_name])
	
	# 보상 분배
	victor.gain_experience(drop_experience)
	
	for item_id in drop_items:
		print("[드롭] %s 획득" % item_id)
	
	var fragments = get_drop_fragments()
	if fragments > 0:
		print("[드롭] 무술 프래그먼트 %d개 획득" % fragments)
