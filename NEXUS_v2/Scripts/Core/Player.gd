## Player.gd - 플레이어 캐릭터
## 입력 처리 및 플레이어 전용 로직

class_name Player
extends Character

# ===== 공격 상태 =====
var current_attack_timer: float = 0.0
var current_attack_duration: float = 0.0
var current_stance: int = 0  # 방어 자세

# ===== 콤보 시스템 =====
var last_executed_martial: MartialArt = null
var combo_counter: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0  # 2초 이내에 다음 공격하면 콤보

# ===== 방어 =====
var is_guarding: bool = false

func _ready() -> void:
	super._ready()
	character_name = "플레이어"
	is_in_combat = true
	
	# 기본 무술 슬롯 초기화 (5개)
	for i in range(5):
		martial_arts.append(null)
	
	print("[플레이어] 초기화 완료")

func _process(delta: float) -> void:
	if not is_alive or not is_in_combat:
		return
	
	handle_input()
	update_attack(delta)
	update_energy_recovery(delta)
	update_combo(delta)

# ===== 입력 처리 =====

func handle_input() -> void:
	"""플레이어 입력을 처리한다"""
	
	# 무술 슬롯 1-5
	for i in range(5):
		var action = "martial_slot_%d" % (i + 1)
		if Input.is_action_just_pressed(action):
			execute_martial(i)
	
	# 기본 공격 (마우스 좌클릭, 스페이스)
	if Input.is_action_just_pressed("ui_select"):
		if martial_arts[0]:
			execute_martial(0)
	
	# 방어 (마우스 우클릭, Shift)
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_guard()

# ===== 무술 발동 =====

func execute_martial(slot_index: int) -> bool:
	"""무술을 발동한다"""
	
	# 유효성 검증
	if is_attacking:
		print("[플레이어] 이미 공격 중입니다!")
		return false
	
	if not is_alive or not is_in_combat:
		return false
	
	if slot_index < 0 or slot_index >= martial_arts.size():
		print("[플레이어] 잘못된 슬롯: %d" % slot_index)
		return false
	
	var martial = martial_arts[slot_index]
	if not martial:
		print("[플레이어] 슬롯 %d에 무술이 없습니다" % slot_index)
		return false
	
	# 에너지 확인
	if not use_energy(martial.energy_cost):
		print("[플레이어] 에너지 부족!")
		return false
	
	# 콤보 검증
	if last_executed_martial and combo_counter > 0:
		if not martial.can_execute_after(last_executed_martial):
			print("[플레이어] 콤보 불가: %s 다음에 %s를 사용할 수 없습니다" % [last_executed_martial.martial_name, martial.martial_name])
			return false
	
	# 무술 발동
	print("\n[플레이어] 무술 발동: %s (데미지: %d, 에너지 소비: %d)" % [martial.martial_name, martial.base_damage, martial.energy_cost])
	
	is_attacking = true
	current_attack_timer = 0.0
	current_attack_duration = martial.animation_duration
	last_executed_martial = martial
	
	# 콤보 업데이트
	if combo_counter == 0:
		combo_counter = 1
	else:
		combo_counter += 1
	combo_timer = 0.0
	
	return true

# ===== 공격 업데이트 =====

func update_attack(delta: float) -> void:
	"""공격 상태를 업데이트한다"""
	if not is_attacking:
		return
	
	current_attack_timer += delta
	
	if current_attack_timer >= current_attack_duration:
		is_attacking = false
		print("[플레이어] 공격 종료 (콤보: %d)" % combo_counter)

# ===== 에너지 회복 =====

func update_energy_recovery(delta: float) -> void:
	"""에너지를 자동으로 회복한다"""
	if is_attacking or is_guarding:
		# 공격 중이거나 방어 중이면 회복 느림
		restore_energy(int(2 * delta))
	else:
		# 대기 중이면 빠르게 회복
		restore_energy(int(5 * delta))

# ===== 콤보 시스템 =====

func update_combo(delta: float) -> void:
	"""콤보 타이머를 업데이트한다"""
	if combo_counter <= 0:
		return
	
	combo_timer += delta
	
	if combo_timer >= combo_timeout:
		print("[플레이어] 콤보 리셋 (연속 공격: %d회)" % combo_counter)
		combo_counter = 0
		last_executed_martial = null

func get_combo_count() -> int:
	"""현재 콤보 수"""
	return combo_counter

# ===== 방어 =====

func toggle_guard() -> void:
	"""방어를 토글한다"""
	if is_attacking:
		return
	
	is_guarding = not is_guarding
	
	if is_guarding:
		print("[플레이어] 방어 자세 (에너지 지속 소비)")
	else:
		print("[플레이어] 방어 해제")

func apply_guard_defense() -> int:
	"""방어 중 방어도"""
	if not is_guarding:
		return 0
	
	return int(stats["CON"] * 0.5)

# ===== 데미지 처리 =====

func take_damage(damage: int) -> void:
	"""데미지를 입는다"""
	var actual_damage = damage
	
	# 방어 중이면 데미지 감소
	if is_guarding:
		var defense = apply_guard_defense()
		actual_damage = max(1, damage - defense)
		print("[플레이어] 방어! 데미지 감소: %d → %d" % [damage, actual_damage])
	
	super.take_damage(actual_damage)

# ===== 정보 출력 =====

func print_combat_status() -> void:
	"""전투 상태 출력"""
	print("\n=== 플레이어 전투 상태 ===")
	print("HP: %d/%d | Energy: %d/%d" % [current_hp, max_hp, current_energy, max_energy])
	print("공격 중: %s | 방어 중: %s | 콤보: %d" % [is_attacking, is_guarding, combo_counter])
	print("무술:")
	
	for i in range(martial_arts.size()):
		var martial = martial_arts[i]
		if martial:
			print("  [%d] %s (에너지: %d, 데미지: %d)" % [i, martial.martial_name, martial.energy_cost, martial.base_damage])
		else:
			print("  [%d] (비어있음)" % i)
	
	print("=" * 30 + "\n")
