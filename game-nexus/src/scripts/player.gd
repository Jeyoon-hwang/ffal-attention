extends CharacterBody3D

# ⚡ 글로벌 상수 참조
var constants = preload("res://src/scripts/constants.gd")

# 플레이어 설정 (상수에서 가져옴)
var speed = constants.PLAYER_SPEED
var jump_force = constants.PLAYER_JUMP_FORCE
var gravity = constants.PLAYER_GRAVITY
var mouse_sensitivity = constants.PLAYER_MOUSE_SENSITIVITY
var max_health = constants.PLAYER_MAX_HEALTH
var max_energy = constants.PLAYER_MAX_ENERGY

# 무술 스킬
var basic_attack_damage = constants.PLAYER_BASIC_ATTACK_DAMAGE
var skill_cooldown = constants.PLAYER_SKILL_COOLDOWN
var energy_per_skill = constants.PLAYER_SKILL_ENERGY_COST
var heavy_attack_damage = constants.PLAYER_SKILL_DAMAGE

# 상태
var health = max_health
var energy = max_energy
var camera_x_rotation = 0.0
var is_attacking = false
var attack_timer = 0.0
var current_combo = 0
var max_combo = 3

# 무술 상태
var spirit = 100  # 내공
var max_spirit = constants.PLAYER_SPIRIT_MAX  # 최대 내공
var is_spirit_active = false
var spin_attack_timer = 0.0  # 회전 공격 쿨다운
var dash_attack_timer = 0.0  # 대시 공격 쿨다운
var is_dashing = false  # 대시 중인 여부

@onready var camera = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health = max_health
	energy = max_energy

func _input(event):
	if event is InputEventMouseMotion:
		camera_x_rotation -= event.relative.y * mouse_sensitivity * 0.01
		camera_x_rotation = clamp(camera_x_rotation, -PI/2, PI/2)
		camera.rotation.x = camera_x_rotation
		rotate_y(-event.relative.x * mouse_sensitivity * 0.01)

func _physics_process(delta):
	# 중력
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# 이동
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if move_dir:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	# 점프
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
	
	# 기본 공격 (좌클릭)
	if Input.is_action_just_pressed("ui_select"):
		basic_attack()
	
	# 무술 스킬 (우클릭)
	if Input.is_action_just_pressed("ui_focus_next"):
		skill_attack()
	
	# 내공 활성화 (Q)
	if Input.is_action_just_pressed("ui_cut"):
		toggle_spirit()
	
	# 회전 공격 (E) - 새 기능
	if Input.is_action_just_pressed("ui_spin"):
		spin_attack()
	
	# 대시 공격 (Shift) - 새 기능
	if Input.is_action_just_pressed("ui_dash"):
		dash_attack()
	
	# 에너지 회복 [개선: 공격 중일 때 비활성화, attack_timer로 정확 제어]
	if attack_timer <= 0 and not is_dashing:
		energy = min(energy + constants.PLAYER_ENERGY_RECOVERY_RATE * delta, max_energy)
	
	# 콤보 타이머 [개선: 0.6 → 0.8]
	if attack_timer > 0:
		attack_timer -= delta
	else:
		current_combo = 0
		is_attacking = false  # 공격 애니메이션 완료 후 상태 리셋
	
	# 회전 공격 쿨다운
	if spin_attack_timer > 0:
		spin_attack_timer -= delta
	
	# 대시 공격 쿨다운
	if dash_attack_timer > 0:
		dash_attack_timer -= delta
	
	# 내공 소비 (활성화 중일 때)
	if is_spirit_active:
		spirit -= constants.PLAYER_SPIRIT_COST_PER_SECOND * delta
		if spirit <= 0:
			spirit = 0
			is_spirit_active = false
			print("⚠️ 내공 고갈! 내공 시스템이 자동으로 해제되었습니다.")
	else:
		# 내공 회복 (활성화 중이 아닐 때만)
		var spirit_recovery = 2.0  # 초당 2 내공 회복
		spirit = min(spirit + spirit_recovery * delta, max_spirit)
	
	# Godot 4 API: move_and_slide()는 자동으로 velocity를 적용
	move_and_slide()

func basic_attack():
	# 이미 공격 중이면 콤보 진행, 아니면 새 공격 시작
	if attack_timer > 0:
		# 콤보 진행
		if current_combo < max_combo:
			current_combo += 1
			attack_timer = constants.PLAYER_COMBO_WINDOW  # 콤보 윈도우 리셋
	else:
		# 새 공격 시작
		current_combo = 1
		attack_timer = constants.PLAYER_COMBO_WINDOW
		is_attacking = true
	
	# 콤보마다 다른 데미지
	var damage = basic_attack_damage * (1 + current_combo * constants.PLAYER_BASIC_ATTACK_COMBO_BONUS)
	
	# 내공 활성화 시 데미지 1.5배
	if is_spirit_active:
		damage *= constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER
	
	# AttackArea 범위 내의 적에게 데미지 입히기 [개선] 신급 AI 회피 로직
	var attack_area = $AttackArea
	if attack_area:
		var enemies_hit = attack_area.get_overlapping_bodies()
		for enemy in enemies_hit:
			if enemy.is_in_group("enemies"):
				# 신급 AI: 회피 시도
				if not enemy.try_dodge():
					enemy.take_damage(int(damage))
					enemy.learn_pattern("basic_attack")
	
	print("콤보 %d: %.0f 대미지 (내공 %s)" % [current_combo, damage, "활성" if is_spirit_active else "미사용"])

func skill_attack():
	if energy >= energy_per_skill:
		energy -= energy_per_skill
		is_attacking = true
		attack_timer = 1.2
		
		# 스킬 데미지
		var damage = heavy_attack_damage
		
		# 내공 활성화 시 데미지 1.5배
		if is_spirit_active:
			damage *= constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER
		
		# AttackArea 범위 내의 적에게 데미지 입히기 [개선] 신급 AI 회피 로직
		var attack_area = $AttackArea
		if attack_area:
			var enemies_hit = attack_area.get_overlapping_bodies()
			for enemy in enemies_hit:
				if enemy.is_in_group("enemies"):
					# 신급 AI: 회피 시도
					if not enemy.try_dodge():
						enemy.take_damage(int(damage))
						enemy.learn_pattern("skill_attack")
		
		print("무술 스킬 발동! (%.0f 대미지, 에너지 소모 %.0f)" % [damage, energy_per_skill])
	else:
		print("⚠️ 에너지 부족! (현재 %.0f / 필요 %.0f)" % [energy, energy_per_skill])

func toggle_spirit():
	if is_spirit_active:
		is_spirit_active = false
		print("내공 해제 (현재 내공: %.0f / %.0f)" % [spirit, max_spirit])
	else:
		if spirit >= 1.0:  # 최소 1 이상 필요
			is_spirit_active = true
			print("내공 활성화! (공격력 %.1fx, 소비: %.0f/초, 남은 내공: %.0f)" % [constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER, constants.PLAYER_SPIRIT_COST_PER_SECOND, spirit])
		else:
			print("⚠️ 내공이 부족합니다! (현재 내공: %.0f / %.0f)" % [spirit, max_spirit])

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()
	print("체력: %.0f / %.0f" % [health, max_health])

func die():
	print("패배... 게임 오버")
	get_tree().reload_current_scene()

func heal(amount: int):
	health = min(health + amount, max_health)
	print("회복! 현재 체력: %.0f" % health)

func spin_attack():
	"""회전 공격 - 모든 방향의 적에게 데미지"""
	if spin_attack_timer > 0:
		print("⚠️ 회전 공격 쿨다운 중... (%.1f초)" % spin_attack_timer)
		return
	
	if energy >= constants.PLAYER_SPIN_ATTACK_ENERGY_COST:
		energy -= constants.PLAYER_SPIN_ATTACK_ENERGY_COST
		spin_attack_timer = constants.PLAYER_SPIN_ATTACK_COOLDOWN
		is_attacking = true
		attack_timer = 0.6
		
		# 회전 공격 데미지
		var damage = constants.PLAYER_SPIN_ATTACK_DAMAGE
		
		# 내공 활성화 시 데미지 1.5배
		if is_spirit_active:
			damage *= constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER
		
		# 주변 모든 적에게 데미지 입히기 (넓은 범위) [개선] 신급 AI 회피 로직
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsShapeQueryParameters3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = constants.PLAYER_SPIN_ATTACK_RANGE
		query.shape = sphere
		query.transform.origin = global_position
		
		var results = space_state.intersect_shape(query)
		var enemies_hit = 0
		
		for result in results:
			if result.collider.is_in_group("enemies"):
				# 신급 AI: 회피 시도
				if not result.collider.try_dodge():
					result.collider.take_damage(int(damage))
					result.collider.learn_pattern("spin_attack")
			enemies_hit += 1
		
		print("💫 회전 공격 발동! (%.0f 대미지, %d마리 적 타격, 에너지 소모 %.0f)" % [damage, enemies_hit, constants.PLAYER_SPIN_ATTACK_ENERGY_COST])
	else:
		print("⚠️ 에너지 부족! (현재 %.0f / 필요 %.0f)" % [energy, constants.PLAYER_SPIN_ATTACK_ENERGY_COST])

func dash_attack():
	"""대시 공격 - 앞으로 돌진하며 적에게 데미지"""
	if dash_attack_timer > 0:
		print("⚠️ 대시 공격 쿨다운 중... (%.1f초)" % dash_attack_timer)
		return
	
	if energy >= constants.PLAYER_DASH_ATTACK_ENERGY_COST:
		energy -= constants.PLAYER_DASH_ATTACK_ENERGY_COST
		dash_attack_timer = constants.PLAYER_DASH_ATTACK_COOLDOWN
		is_attacking = true
		attack_timer = constants.PLAYER_DASH_DURATION
		is_dashing = true
		
		# 대시 공격 데미지
		var damage = constants.PLAYER_DASH_ATTACK_DAMAGE
		
		# 내공 활성화 시 데미지 1.5배
		if is_spirit_active:
			damage *= constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER
		
		# 앞 방향으로 돌진
		var direction = -transform.basis.z  # 카메라가 보는 방향
		velocity = direction * constants.PLAYER_DASH_SPEED
		
		# 돌진 중 범위 내 적에게 데미지 [개선] 대시는 회피 불가 (빠른 돌진)
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsShapeQueryParameters3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = 5.0  # 돌진 범위
		query.shape = sphere
		query.transform.origin = global_position
		
		var results = space_state.intersect_shape(query)
		var enemies_hit = 0
		
		for result in results:
			if result.collider.is_in_group("enemies"):
				result.collider.take_damage(int(damage))
				enemies_hit += 1
		
		print("⚡ 대시 공격 발동! (%.0f 대미지, %d마리 적 타격, 에너지 소모 %.0f)" % [damage, enemies_hit, constants.PLAYER_DASH_ATTACK_ENERGY_COST])
	else:
		print("⚠️ 에너지 부족! (현재 %.0f / 필요 %.0f)" % [energy, constants.PLAYER_DASH_ATTACK_ENERGY_COST])

func get_actual_damage(base_damage: float) -> float:
	"""내공 상태를 고려한 실제 대미지 계산"""
	var final_damage = base_damage
	if is_spirit_active:
		final_damage *= constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER
	return final_damage
