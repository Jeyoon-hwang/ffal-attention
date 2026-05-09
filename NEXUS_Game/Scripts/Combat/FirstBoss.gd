## FirstBoss.gd - 첫 보스 (천산 검객)
## 중원 던전 보스, 3-Phase 시스템, 고급 AI

class_name FirstBoss
extends Enemy

# ╔═════════════════════════════════════════════════════════╗
# ║          보스 특화 변수 (Boss Specific)                ║
# ╚═════════════════════════════════════════════════════════╝

var phase: int = 1                      # 현재 Phase (1/2/3)
var rage_meter: float = 0.0             # 분노도 (0-100)
var phase_transition_cooldown: float = 0.0

# ─────────────────────────────────────────────────────────

## 초기화 함수
func _init() -> void:
	super()
	
	# 기본 정보
	enemy_name = "천산 검객"
	enemy_type = "boss"
	ai_level = 3                         # 고급 AI
	level = 10
	
	# 능력치 (보스 레벨)
	stats = {
		"STR": 12,
		"DEX": 10,
		"CON": 15,
		"INT": 8,
		"WIS": 8,
		"CHA": 6
	}
	
	# 생명 & 에너지
	max_hp = 200
	current_hp = 200
	max_energy = 100
	current_energy = 100
	
	# 리워드
	experience_reward = 1000
	gold_reward = 500
	
	# Phase 초기화
	phase = 1
	rage_meter = 0.0


## 무술 초기화
func initialize_martial_arts() -> void:
	"""
	6가지 무술 설정:
	0. 천권 (기본 펀치)
	1. 호발 (발차기)
	2. 삼단연격 (콤보)
	3. 천산 폭풍 (광역 공격)
	4. 분신술 (방어 강화)
	5. 최후의 일격 (궁극 스킬)
	"""
	
	# 0. 천권 (기본 펀치)
	var martial_0 = MartialArt.new()
	martial_0.name = "천권"
	martial_0.base_motion = "punch"
	martial_0.tempo = "fast"
	martial_0.damage_value = 10
	martial_0.energy_cost = 3
	martial_0.reach = 2.0
	martial_slots.append(martial_0)
	
	# 1. 호발 (발차기)
	var martial_1 = MartialArt.new()
	martial_1.name = "호발"
	martial_1.base_motion = "kick"
	martial_1.tempo = "mid"
	martial_1.damage_value = 15
	martial_1.energy_cost = 5
	martial_1.reach = 2.5
	martial_slots.append(martial_1)
	
	# 2. 삼단연격 (콤보)
	var martial_2 = MartialArt.new()
	martial_2.name = "삼단연격"
	martial_2.base_motion = "combo"
	martial_2.tempo = "fast"
	martial_2.damage_value = 12
	martial_2.energy_cost = 4
	martial_2.reach = 2.0
	martial_2.combo_hits = 3
	martial_slots.append(martial_2)
	
	# 3. 천산 폭풍 (광역 공격) - Phase 2+ 전용
	var martial_3 = MartialArt.new()
	martial_3.name = "천산 폭풍"
	martial_3.base_motion = "aoe"
	martial_3.tempo = "slow"
	martial_3.damage_value = 20
	martial_3.energy_cost = 8
	martial_3.reach = 4.0
	martial_3.effect_type = "aoe"
	martial_slots.append(martial_3)
	
	# 4. 분신술 (방어 강화)
	var martial_4 = MartialArt.new()
	martial_4.name = "분신술"
	martial_4.base_motion = "buff"
	martial_4.tempo = "mid"
	martial_4.damage_value = 5
	martial_4.energy_cost = 6
	martial_4.reach = 1.0
	martial_4.effect_type = "buff"
	martial_slots.append(martial_4)
	
	# 5. 최후의 일격 (궁극 스킬)
	var martial_5 = MartialArt.new()
	martial_5.name = "최후의 일격"
	martial_5.base_motion = "ultimate"
	martial_5.tempo = "slow"
	martial_5.damage_value = 35
	martial_5.energy_cost = 10
	martial_5.reach = 3.0
	martial_5.effect_type = "ultimate"
	martial_5.cooldown = 10.0
	martial_slots.append(martial_5)


# ═══════════════════════════════════════════════════════════════════════════════

## Phase 결정 함수
func update_phase() -> void:
	"""
	HP 비율에 따라 Phase 결정
	"""
	var hp_percent = float(current_hp) / float(max_hp) * 100.0
	
	if hp_percent > 66.7:
		phase = 1
	elif hp_percent > 33.3:
		phase = 2
	else:
		phase = 3
	
	# Phase 전환 시 에너지 회복
	if phase_transition_cooldown <= 0.0:
		current_energy = mini(current_energy + 30, max_energy)
		phase_transition_cooldown = 2.0


## 분노도 업데이트
func update_rage_meter(delta: float) -> void:
	"""
	분노도 증가 로직:
	- 공격을 받을 때마다 +10
	- Phase마다 기본 증가율 다름
	- 최대 100
	"""
	
	# Phase별 기본 증가율
	var rage_increase = 0.5  # 기본
	if phase == 2:
		rage_increase = 1.0
	elif phase == 3:
		rage_increase = 2.0
	
	rage_meter = mini(rage_meter + rage_increase * delta, 100.0)


# ═══════════════════════════════════════════════════════════════════════════════

## 액션 선택 함수 (AI의 핵심)
func select_action(player_target: Node3D) -> Dictionary:
	"""
	AI 로직:
	1. HP 비율과 Phase 확인
	2. 현재 분노도에 따라 행동 결정
	3. 에너지 제약 고려
	4. Phase별 전술 선택
	
	반환: {"action": "attack/defend/ultimate", "martial_index": 0-5}
	"""
	
	var action = {
		"action": "attack",
		"martial_index": 0
	}
	
	# Enraged 상태 (HP 10% 이하 또는 분노도 80+)
	if current_hp <= max_hp / 10 or rage_meter >= 80.0:
		# 궁극 스킬만 사용 시도
		if current_energy >= martial_slots[5].energy_cost:
			return {
				"action": "attack",
				"martial_index": 5
			}
	
	# Phase 1: 기본 공격 (천권, 호발, 삼단연격)
	if phase == 1:
		var choices = [0, 1, 2]  # 천권, 호발, 삼단연격
		action["martial_index"] = choices[randi() % choices.size()]
		
		# 에너지 부족 시 회복
		if current_energy < martial_slots[action["martial_index"]].energy_cost:
			action["action"] = "recover"
	
	# Phase 2: 더 공격적 (광역 공격 추가)
	elif phase == 2:
		var random_val = randf()
		
		if random_val < 0.4:  # 기본 공격 40%
			action["martial_index"] = [0, 1, 2][randi() % 3]
		elif random_val < 0.7:  # 광역 공격 30%
			if current_energy >= martial_slots[3].energy_cost:
				action["martial_index"] = 3
			else:
				action["martial_index"] = 0
		else:  # 방어 강화 30%
			if current_energy >= martial_slots[4].energy_cost:
				action["martial_index"] = 4
			else:
				action["martial_index"] = 0
	
	# Phase 3: 절박함 (모든 공격 활용)
	elif phase == 3:
		var random_val = randf()
		
		if random_val < 0.2:  # 기본 공격 20%
			action["martial_index"] = [0, 1][randi() % 2]
		elif random_val < 0.5:  # 광역 공격 30%
			if current_energy >= martial_slots[3].energy_cost:
				action["martial_index"] = 3
			else:
				action["martial_index"] = 0
		elif random_val < 0.75:  # 궁극 스킬 25%
			if current_energy >= martial_slots[5].energy_cost:
				action["martial_index"] = 5
			else:
				action["martial_index"] = 3
		else:  # 분신술 25%
			if current_energy >= martial_slots[4].energy_cost:
				action["martial_index"] = 4
			else:
				action["martial_index"] = 0
	
	# 에너지 확인
	var selected_martial = martial_slots[action["martial_index"]]
	if current_energy < selected_martial.energy_cost:
		action["action"] = "recover"
		current_energy = mini(current_energy + 20, max_energy)
	
	return action


## 액션 실행
func execute_action(action: Dictionary, target: Node3D) -> Dictionary:
	"""
	선택된 액션을 실행하고 결과를 반환
	
	반환: {
		"action_name": "천권",
		"damage_dealt": 10,
		"energy_used": 3,
		"success": true
	}
	"""
	
	var result = {
		"action_name": "",
		"damage_dealt": 0,
		"energy_used": 0,
		"success": false
	}
	
	# 회복 액션
	if action["action"] == "recover":
		current_energy = mini(current_energy + 30, max_energy)
		result["action_name"] = "회복"
		result["success"] = true
		return result
	
	# 공격 액션
	if action["action"] == "attack":
		var martial_index = action["martial_index"]
		var martial = martial_slots[martial_index]
		
		# 에너지 소모
		if current_energy >= martial.energy_cost:
			current_energy -= martial.energy_cost
			result["energy_used"] = martial.energy_cost
			result["action_name"] = martial.name
			
			# 데미지 계산
			var damage = martial.damage_value + stats["STR"] / 2
			
			# 크리티컬 확률 (DEX 기반)
			if randf() < float(stats["DEX"]) / 50.0:  # 10% ~ 20%
				damage = int(damage * 1.5)
				result["action_name"] += " (크리티컬!)"
			
			# Phase별 데미지 보정
			if phase >= 2:
				damage = int(damage * 1.1)
			if phase >= 3:
				damage = int(damage * 1.15)
			
			result["damage_dealt"] = damage
			result["success"] = true
			
			# 분노도 증가
			rage_meter = mini(rage_meter + 10.0, 100.0)
		
		return result
	
	return result


## 데미지 수신
func take_damage(damage: int, attacker: Node = null) -> void:
	"""
	데미지를 받고 분노도 증가
	"""
	
	# 방어 계산
	var defense = stats["CON"] * 1.5
	var actual_damage = maxi(damage - int(defense) / 2, 1)
	
	current_hp -= actual_damage
	
	# 분노도 증가 (데미지를 받을 때마다)
	rage_meter = mini(rage_meter + 15.0, 100.0)
	
	# Phase 전환 체크
	update_phase()


## 상태 로그 출력
func get_status_string() -> String:
	"""
	보스의 현재 상태를 문자열로 반환
	"""
	
	var hp_bar = ""
	var hp_percent = float(current_hp) / float(max_hp)
	var filled = int(hp_percent * 20)
	for i in range(20):
		if i < filled:
			hp_bar += "█"
		else:
			hp_bar += "░"
	
	var rage_bar = ""
	var rage_percent = rage_meter / 100.0
	var rage_filled = int(rage_percent * 10)
	for i in range(10):
		if i < rage_filled:
			rage_bar += "⚠"
		else:
			rage_bar += "○"
	
	var phase_text = match(phase):
		1: "[Phase 1 - 기본]",
		2: "[Phase 2 - 공격적]",
		3: "[Phase 3 - 절박]",
		_: "[미정]"
	
	return """
	┌─────────────────────────────────────┐
	│ %s %s
	├─────────────────────────────────────┤
	│ HP: %d/%d %s
	│ EN: %d/%d
	│ 분노도: %.1f/100 %s
	│ 에너지: %.0f%%
	└─────────────────────────────────────┘
	""" % [
		enemy_name,
		phase_text,
		current_hp,
		max_hp,
		hp_bar,
		current_energy,
		max_energy,
		rage_meter,
		rage_bar,
		(float(current_energy) / float(max_energy) * 100.0)
	]


## 상태 체크
func is_alive() -> bool:
	return current_hp > 0


func is_defeated() -> bool:
	return current_hp <= 0


func get_phase() -> int:
	return phase


func get_rage_meter() -> float:
	return rage_meter


func get_hp_percent() -> float:
	return float(current_hp) / float(max_hp)


# ═══════════════════════════════════════════════════════════════════════════════

## 리셋 함수 (테스트용)
func reset() -> void:
	"""
	보스를 초기 상태로 리셋
	"""
	current_hp = max_hp
	current_energy = max_energy
	phase = 1
	rage_meter = 0.0
	phase_transition_cooldown = 0.0
