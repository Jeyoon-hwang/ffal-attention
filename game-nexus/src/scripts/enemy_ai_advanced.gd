extends Node

# ⚡ NEXUS Day 6: 고급 적 AI 시스템
# 콤보, 방어, 상태이상을 모두 활용하는 지능형 AI

class_name EnemyAIAdvanced

# AI 타입 (난이도)
enum AIType {
	BEAST = 0,          # Level 1: 기본 동물형
	MARTIAL_NOVICE = 1, # Level 2: 초급 무술사
	MARTIAL_EXPERT = 2, # Level 3: 고급 무술사 (던전 보스)
	MARTIAL_MASTER = 3, # Level 4: 마스터 (최종 보스)
}

# AI 상수
const STATE_UPDATE_INTERVAL = 0.5  # 상태 업데이트 주기 (초)
const DECISION_COOLDOWN = 1.0  # 다음 행동 결정 대기 (초)
const VISION_RANGE = 30.0  # 시야 범위 (m)
const ATTACK_RANGE = 2.0  # 공격 범위 (m)
const FLEE_THRESHOLD = 0.2  # 도망칠 체력 비율 (20%)

# AI 설정
var ai_type: int = AIType.MARTIAL_NOVICE
var ai_aggressiveness = 0.5  # 공격성 (0.0-1.0)
var ai_defensive_ratio = 0.3  # 방어 비율 (0.0-1.0)
var ai_intelligence = 0.5  # 지능 (0.0-1.0) - 패턴 학습 능력

# 현재 상태
var current_state = "idle"  # idle, chase, attack, defend, dodge, flee
var state_timer = 0.0
var decision_timer = 0.0
var target_player: Node = null
var current_distance = 0.0

# 적 능력
var combo_system: ComboSystem
var defense_system: DefenseSystem
var status_effect: StatusEffect
var martial_arts = []  # 보유한 무술 목록
var current_combo_count = 0

# 플레이어 관찰
var player_last_attack_time = 0.0
var player_combo_count = 0
var player_is_defending = false
var player_detected_patterns = []  # 패턴 학습

# 통계
var ai_stats = {
	"attacks_performed": 0,
	"successful_dodges": 0,
	"successful_defenses": 0,
	"successful_counters": 0,
	"damage_dealt": 0.0,
	"damage_taken": 0.0
}

# 신호
signal ai_state_changed(new_state: String)
signal ai_action_performed(action: String)

func _ready():
	"""AI 초기화"""
	combo_system = ComboSystem.new()
	add_child(combo_system)
	
	defense_system = DefenseSystem.new()
	add_child(defense_system)
	
	status_effect = StatusEffect.new()
	add_child(status_effect)
	
	print("🤖 적 AI 초기화 (타입: %s, 공격성: %.1f, 방어: %.1f)" % [
		AIType.keys()[ai_type],
		ai_aggressiveness,
		ai_defensive_ratio
	])

func _process(delta):
	"""매 프레임 AI 처리"""
	state_timer += delta
	decision_timer += delta
	
	# 상태 업데이트
	if state_timer >= STATE_UPDATE_INTERVAL:
		update_ai_state()
		state_timer = 0.0
	
	# 행동 결정
	if decision_timer >= DECISION_COOLDOWN:
		make_decision()
		decision_timer = 0.0

# ==================== 상태 관리 ====================

func update_ai_state():
	"""현재 상태 업데이트"""
	if target_player == null:
		change_state("idle")
		return
	
	# 플레이어 감지 & 거리 계산
	current_distance = global_position.distance_to(target_player.global_position)
	
	# 상태 전이 로직
	if current_distance > VISION_RANGE:
		# 시야 밖
		change_state("idle")
	elif current_distance > ATTACK_RANGE:
		# 추격 거리
		change_state("chase")
	else:
		# 전투 거리
		if current_state != "attack" and current_state != "defend" and current_state != "dodge":
			decide_attack_or_defend()

func change_state(new_state: String):
	"""상태 변경"""
	if current_state != new_state:
		current_state = new_state
		emit_signal("ai_state_changed", new_state)
		print("🤖 AI 상태: %s" % new_state)

# ==================== 의사결정 ====================

func make_decision():
	"""현재 상태에서 다음 행동 결정"""
	if target_player == null:
		return
	
	# 상태이상 체크
	if status_effect.has_effect(StatusEffect.Type.STUN):
		print("⚠️  AI 기절 중, 행동 불가")
		return
	
	if status_effect.has_effect(StatusEffect.Type.FREEZE):
		print("⚠️  AI 빙결 중, 행동 불가")
		return
	
	match current_state:
		"idle":
			pass  # 대기
		
		"chase":
			perform_chase()
		
		"attack":
			perform_attack()
		
		"defend":
			perform_defend()
		
		"dodge":
			perform_dodge()
		
		"flee":
			perform_flee()

func decide_attack_or_defend():
	"""공격할지 방어할지 결정"""
	# 난이도에 따른 의사결정
	var should_attack = randf() > ai_defensive_ratio
	
	# 플레이어가 방어 중이면 회피 또는 카운터
	if player_is_defending:
		# 높은 AI는 카운터 시도
		if ai_type >= AIType.MARTIAL_EXPERT and randf() < ai_intelligence:
			change_state("defend")  # 카운터 타이밍 준비
		else:
			change_state("dodge")  # 회피
		return
	
	# 플레이어가 콤보 중이면 방어
	if player_combo_count >= 2:
		change_state("defend")
		return
	
	# 정상 공격
	if should_attack:
		change_state("attack")
	else:
		change_state("defend")

# ==================== 행동 수행 ====================

func perform_chase():
	"""플레이어 추격"""
	# 플레이어 쪽으로 이동
	var direction = (target_player.global_position - global_position).normalized()
	# (실제 이동은 CharacterBody3D에서 처리)
	emit_signal("ai_action_performed", "chase")

func perform_attack():
	"""공격 수행"""
	# 무술 선택 (난이도에 따라 다름)
	var martial_art = select_martial_art()
	
	# 콤보 시도
	var combo_data = combo_system.attempt_combo(martial_arts.find(martial_art))
	
	ai_stats["attacks_performed"] += 1
	emit_signal("ai_action_performed", "attack: %s (%.1fx damage)" % [
		martial_art.get("name", "Unknown"),
		combo_data.damage_multiplier
	])
	
	# 공격 후 상태 전이
	var next_action = randf()
	if next_action < 0.4:
		change_state("attack")  # 계속 공격
	elif next_action < 0.7:
		change_state("defend")  # 방어로
	else:
		change_state("idle")  # 잠시 대기

func perform_defend():
	"""방어 수행"""
	defense_system.start_defense()
	
	ai_stats["successful_defenses"] += 1
	emit_signal("ai_action_performed", "defend")
	
	# 방어 후 반응
	if defense_system.can_counter:
		# 카운터 준비 (플레이어의 공격 기다림)
		print("🤖 AI 카운터 준비!")

func perform_dodge():
	"""회피 수행"""
	var dodge_direction = (global_position - target_player.global_position).normalized()
	var success = defense_system.perform_dodge(global_position, dodge_direction)
	
	if success:
		ai_stats["successful_dodges"] += 1
		emit_signal("ai_action_performed", "dodge")
		change_state("attack")  # 회피 후 반격

func perform_flee():
	"""도망 수행"""
	var flee_direction = (global_position - target_player.global_position).normalized()
	# (실제 이동은 CharacterBody3D에서 처리)
	emit_signal("ai_action_performed", "flee")

# ==================== 무술 선택 ====================

func select_martial_art() -> Dictionary:
	"""상황에 맞는 무술 선택"""
	if martial_arts.size() == 0:
		return {"name": "Basic", "damage": 10}
	
	# 기본 AI: 랜덤 선택
	if ai_type == AIType.BEAST or ai_type == AIType.MARTIAL_NOVICE:
		return martial_arts[randi() % martial_arts.size()]
	
	# 고급 AI: 상황에 맞는 선택
	var distance_ratio = current_distance / ATTACK_RANGE
	
	if distance_ratio < 1.0:
		# 가까움 - 빠른 무술 선택
		return martial_arts.filter(func(art): return art.get("tempo", "mid") == "fast")[0] if martial_arts.size() > 0 else martial_arts[0]
	else:
		# 멀음 - 강력한 무술 선택
		return martial_arts.filter(func(art): return art.get("tempo", "mid") == "slow")[0] if martial_arts.size() > 0 else martial_arts[0]

# ==================== 플레이어 관찰 ====================

func observe_player(player_combo: int, player_defending: bool, player_damaged: bool):
	"""플레이어 상태 관찰"""
	player_combo_count = player_combo
	player_is_defending = player_defending
	
	# 패턴 학습 (높은 AI만)
	if ai_type >= AIType.MARTIAL_EXPERT and ai_intelligence > 0.5:
		if player_combo > 0:
			player_last_attack_time = get_tree().get_frame() * get_physics_process_delta_time()
			learn_pattern(player_combo)

func learn_pattern(player_combo: int):
	"""플레이어 공격 패턴 학습"""
	# 콤보 2 이상이면 같은 무술 반복 사용
	if player_combo >= 2:
		# 다음엔 회피를 준비한다
		print("🧠 AI 학습: 플레이어가 콤보 중, 회피 준비")

# ==================== 데미지 처리 ====================

func receive_damage(damage: float, damage_type: String = "normal") -> float:
	"""데미지 받음"""
	var actual_damage = damage
	
	# 방어 중이면 감소
	if defense_system.is_defending:
		var defense_result = defense_system.apply_defense_damage(damage)
		actual_damage = defense_result.actual_damage
	
	# 회피 중이면 무적
	if defense_system.is_dodging:
		actual_damage = 0.0
	
	ai_stats["damage_taken"] += actual_damage
	emit_signal("ai_action_performed", "received_damage: %.0f" % actual_damage)
	
	# 체력 떨어지면 도망
	# (실제 체력 관리는 Enemy 클래스에서 처리)
	
	return actual_damage

func apply_status_effect(effect_type: int):
	"""상태이상 받음"""
	status_effect.apply_effect(effect_type)
	emit_signal("ai_action_performed", "affected_by: %s" % status_effect.get_effect_name(effect_type))

# ==================== AI 타입별 설정 ====================

func set_ai_type(new_type: int):
	"""AI 타입 설정"""
	ai_type = new_type
	
	match ai_type:
		AIType.BEAST:
			ai_aggressiveness = 0.8
			ai_defensive_ratio = 0.9  # 거의 공격만 함
			ai_intelligence = 0.0
			martial_arts = []  # 무술 없음
		
		AIType.MARTIAL_NOVICE:
			ai_aggressiveness = 0.7
			ai_defensive_ratio = 0.6
			ai_intelligence = 0.3
			# 무술 3-4개 설정
		
		AIType.MARTIAL_EXPERT:
			ai_aggressiveness = 0.6
			ai_defensive_ratio = 0.4
			ai_intelligence = 0.7
			# 무술 5-8개 설정
		
		AIType.MARTIAL_MASTER:
			ai_aggressiveness = 0.5
			ai_defensive_ratio = 0.3
			ai_intelligence = 0.95
			# 무술 10+ 설정
	
	print("🤖 AI 타입 설정: %s (공격성: %.1f, 방어: %.1f, 지능: %.1f)" % [
		AIType.keys()[ai_type],
		ai_aggressiveness,
		ai_defensive_ratio,
		ai_intelligence
	])

# ==================== 통계 ====================

func get_ai_stats() -> Dictionary:
	"""AI 통계 반환"""
	return ai_stats.duplicate()

func reset_stats():
	"""통계 리셋"""
	ai_stats = {
		"attacks_performed": 0,
		"successful_dodges": 0,
		"successful_defenses": 0,
		"successful_counters": 0,
		"damage_dealt": 0.0,
		"damage_taken": 0.0
	}

# ==================== 디버그 ====================

func get_debug_info() -> String:
	"""AI 디버그 정보"""
	return """
AI Type: %s
State: %s
Distance: %.1f m
Combo: %d
Defending: %s
Status: %s
Player Combo: %d
Player Defending: %s
	""" % [
		AIType.keys()[ai_type],
		current_state,
		current_distance,
		current_combo_count,
		"Yes" if defense_system.is_defending else "No",
		status_effect.get_status_display(),
		player_combo_count,
		"Yes" if player_is_defending else "No"
	]
