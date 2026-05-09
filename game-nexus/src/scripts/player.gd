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

# 무술 시스템 (Day 4 업그레이드)
var martial_engine: Node  # MartialArtEngine 싱글톤
var martial_arts_slots = []  # 5개 슬롯 (무술 배치)
var active_martial_art_index = 0  # 현재 활성 무술
var martial_art_cooldowns = [0.0, 0.0, 0.0, 0.0, 0.0]  # 각 슬롯의 쿨다운
var loaded_martial_arts = []  # 로드된 모든 무술

# 무술 스킬 (구식, 호환성)
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

# 방어 시스템 (Day 5)
var is_defending = false  # 현재 방어 중
var defense_energy_cost_timer = 0.0  # 방어 에너지 소비 타이밍

# 회피 시스템 (Day 5)
var is_dodging = false  # 현재 회피 중 (무적 상태)
var dodge_cooldown_timer = 0.0  # 회피 쿨다운 남은 시간
var current_i_frames = 0.0  # 무적 시간 남은 시간

@onready var camera = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health = max_health
	energy = max_energy
	
	# Day 4: 무술 엔진 통합
	load_martial_arts()
	initialize_martial_slots()

# Day 4: 무술 시스템
func load_martial_arts():
	"""MartialArtEngine에서 무술 로드"""
	if has_node("/root/MartialArtEngine"):
		martial_engine = get_node("/root/MartialArtEngine")
	else:
		print("⚠️ MartialArtEngine을 찾을 수 없음 (아직 씬에 추가 안됨)")
		return
	
	# JSON 파일에서 무술 로드
	var json_path = "res://src/data/MartialArts/martial_arts_base_set.json"
	loaded_martial_arts = martial_engine.load_martial_arts_from_json(json_path)
	
	if loaded_martial_arts.size() > 0:
		print("✅ %d개 무술 로드 완료" % loaded_martial_arts.size())
	else:
		print("❌ 무술 로드 실패")

func initialize_martial_slots():
	"""무술 5개 슬롯 초기화 (랜덤 선택)"""
	if loaded_martial_arts.size() == 0:
		print("⚠️ 로드된 무술이 없어서 슬롯 초기화 불가")
		return
	
	for i in range(5):
		var random_index = randi() % loaded_martial_arts.size()
		var selected_martial = loaded_martial_arts[random_index]
		martial_arts_slots.append(selected_martial)
		print("[슬롯 %d] %s 배치" % [i+1, selected_martial.name])

func use_martial_art(slot_index: int) -> bool:
	"""특정 슬롯의 무술 사용"""
	if slot_index < 0 or slot_index >= martial_arts_slots.size():
		return false
	
	if martial_art_cooldowns[slot_index] > 0:
		print("⚠️ [슬롯 %d] 쿨다운 중... (%.1f초)" % [slot_index+1, martial_art_cooldowns[slot_index]])
		return false
	
	var martial = martial_arts_slots[slot_index]
	if energy < martial.damage * 0.5:  # 위력의 50%를 에너지로 사용
		print("⚠️ 에너지 부족! (필요 %.0f)" % (martial.damage * 0.5))
		return false
	
	# 무술 사용
	energy -= martial.damage * 0.5
	martial_art_cooldowns[slot_index] = martial.cooldown
	active_martial_art_index = slot_index
	
	# 대미지 계산 (내공 보너스)
	var final_damage = martial.damage
	if is_spirit_active:
		final_damage *= constants.PLAYER_SPIRIT_DAMAGE_MULTIPLIER
	
	print("🥋 [%s] 발동! (대미지 %.0f, 쿨 %.1f초)" % [martial.name, final_damage, martial.cooldown])
	return true

func _input(event):
	if event is InputEventMouseMotion:
		camera_x_rotation -= event.relative.y * mouse_sensitivity * 0.01
		camera_x_rotation = clamp(camera_x_rotation, -PI/2, PI/2)
		camera.rotation.x = camera_x_rotation
		rotate_y(-event.relative.x * mouse_sensitivity * 0.01)
	
	# Day 4: 무술 슬롯 입력 (1-5)
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_5:
			var slot = event.keycode - KEY_1
			use_martial_art(slot)

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
	
	# Day 4: 무술 쿨다운 감소
	for i in range(martial_art_cooldowns.size()):
		if martial_art_cooldowns[i] > 0:
			martial_art_cooldowns[i] -= delta
	
	# 점프
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
	
	# 기본 공격 (좌클릭)
	if Input.is_action_just_pressed("ui_select"):
		basic_attack()
	
	# Day 5: 방어 (우클릭 누르기)
	if Input.is_action_pressed("ui_focus_next"):
		if not is_defending and not is_attacking:
			start_defending()
	else:
		if is_defending:
			stop_defending()
	
	# 내공 활성화 (Q)
	if Input.is_action_just_pressed("ui_cut"):
		toggle_spirit()
	
	# 회전 공격 (E) - 새 기능
	if Input.is_action_just_pressed("ui_spin"):
		spin_attack()
	
	# 대시 공격 (Shift) - 새 기능
	if Input.is_action_just_pressed("ui_dash"):
		dash_attack()
	
	# Day 5: 회피 (Space - 동싏때 보단 동작싱 주의)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		# 방어 중이 아니면 점프, 더 중이면 회피
		if is_defending:
			attempt_dodge()
		else:
			velocity.y = jump_force
	
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
	
	# Day 5: 방어 에너지 소비
	apply_defense_energy_cost(delta)
	
	# Day 5: 회피 쿨다운 감소
	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta
	
	# Day 5: 무적 시간 감소
	if current_i_frames > 0:
		current_i_frames -= delta
		if current_i_frames <= 0:
			is_dodging = false
	
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
	# Day 5: 무적 시간 중인 피해 무시
	if current_i_frames > 0:
		print("🌀 회피 중! 피해 무시")
		return
	
	# Day 5: 방어 중을 때 방어 대미지 감소
	var final_damage = damage
	if is_defending:
		final_damage = int(damage * constants.PLAYER_DEFENSE_DAMAGE_MULTIPLIER)
		print("🛡️ 방어! (%.0f → %.0f)" % [damage, final_damage])
	
	health -= final_damage
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

# ============================================================
# Day 5: 방어 시스템
# ============================================================

func start_defending():
	"""방어 시작 (우클릭 누르기)"""
	if is_defending:
		return
	
	is_defending = true
	defense_energy_cost_timer = 0.0
	print("🛡️ 방어 시작!")

func stop_defending():
	"""방어 해제 (우클릭 떼기)"""
	if not is_defending:
		return
	
	is_defending = false
	defense_energy_cost_timer = 0.0
	print("방어 해제")

func apply_defense_energy_cost(delta: float):
	"""방어 중 에너지 감소"""
	if not is_defending:
		return
	
	defense_energy_cost_timer += delta
	
	# 0.1초마다 에너지 소비
	if defense_energy_cost_timer >= 0.1:
		energy -= constants.PLAYER_DEFENSE_ENERGY_COST_PER_SEC * defense_energy_cost_timer
		defense_energy_cost_timer = 0.0
	
		# 에너지 소진 시 방어 자동 해제
		if energy <= 0:
			energy = 0
			stop_defending()
			print("⚠️ 에너지 소진! 방어 해제됨")

# ============================================================
# Day 5: 회피 시스템
# ============================================================

func attempt_dodge():
	"""회피 시도 (Space 누르기)"""
	# 쿨다운 확인
	if dodge_cooldown_timer > 0:
		print("⚠️ 회피 쿨다운 중... (%.1f초)" % dodge_cooldown_timer)
		return
	
	# 에너지 확인
	if energy < constants.PLAYER_DODGE_ENERGY_COST:
		print("⚠️ 에너지 부족! (현재 %.0f / 필요 %.0f)" % [energy, constants.PLAYER_DODGE_ENERGY_COST])
		return
	
	# 회피 실행
	energy -= constants.PLAYER_DODGE_ENERGY_COST
	dodge_cooldown_timer = constants.PLAYER_DODGE_COOLDOWN
	current_i_frames = constants.PLAYER_DODGE_I_FRAME_DURATION
	is_dodging = true
	is_defending = false  # 방어 자동 해제
	
	# 회피 방향: 카메라가 보는 방향의 반대로 (앞으로)
	var dodge_direction = -transform.basis.z
	velocity.x = dodge_direction.x * constants.PLAYER_SPEED * constants.PLAYER_DODGE_SPEED_MULTIPLIER
	velocity.z = dodge_direction.z * constants.PLAYER_SPEED * constants.PLAYER_DODGE_SPEED_MULTIPLIER
	
	print("🌀 회피! (에너지 소모 %.0f, 무적 시간 %.1f초)" % [constants.PLAYER_DODGE_ENERGY_COST, constants.PLAYER_DODGE_I_FRAME_DURATION])
