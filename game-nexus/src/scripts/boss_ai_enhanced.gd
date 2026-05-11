# 🥋 NEXUS Day 7: 보스 AI 시스템 (고급)
# Phase 기반 패턴, AOE 공격, 특수 능력

extends "res://src/scripts/enemy_ai_advanced.gd"

class_name BossAIEnhanced

# 보스 Phase
enum BossPhase {
	PHASE_1 = 1,  # HP 100% ~ 60%
	PHASE_2 = 2,  # HP 60% ~ 30%
	PHASE_3 = 3,  # HP 30% ~ 0% (절망 모드)
}

# 보스 설정
var boss_phase: int = BossPhase.PHASE_1
var phase_change_thresholds = {
	BossPhase.PHASE_1: 0.6,
	BossPhase.PHASE_2: 0.3,
	BossPhase.PHASE_3: 0.0,
}

# 특수 능력
var special_abilities = {
	"광역기공": {
		"name": "광역기공",
		"cooldown": 3.0,
		"timer": 0.0,
		"damage_multiplier": 1.5,
		"aoe_radius": 10.0,
		"phase_unlock": BossPhase.PHASE_1,
		"description": "주변에 에너지파 방출"
	},
	"연쇄검기": {
		"name": "연쇄검기",
		"cooldown": 4.0,
		"timer": 0.0,
		"damage_multiplier": 1.2,
		"hit_count": 5,
		"phase_unlock": BossPhase.PHASE_1,
		"description": "빠르게 연속 5회 공격"
	},
	"필살검": {
		"name": "필살검",
		"cooldown": 6.0,
		"timer": 0.0,
		"damage_multiplier": 2.5,
		"hit_count": 1,
		"phase_unlock": BossPhase.PHASE_2,
		"description": "극도로 강력한 일격 (Phase 2 이상)"
	},
	"광장파": {
		"name": "광장파",
		"cooldown": 5.0,
		"timer": 0.0,
		"damage_multiplier": 2.0,
		"aoe_radius": 15.0,
		"phase_unlock": BossPhase.PHASE_2,
		"description": "광범위 에너지 폭발 (Phase 2 이상)"
	},
	"무극회검": {
		"name": "무극회검",
		"cooldown": 8.0,
		"timer": 0.0,
		"damage_multiplier": 3.0,
		"aoe_radius": 12.0,
		"hit_count": 3,
		"phase_unlock": BossPhase.PHASE_3,
		"description": "360도 회전 공격 (Phase 3 이상)"
	},
}

# Phase별 행동 패턴
var phase_behaviors = {
	BossPhase.PHASE_1: {
		"aggressiveness": 0.6,
		"defense_ratio": 0.3,
		"attack_patterns": ["일반공격", "광역기공", "연쇄검기"],
		"description": "공격적이지만 방어도 함"
	},
	BossPhase.PHASE_2: {
		"aggressiveness": 0.8,
		"defense_ratio": 0.2,
		"attack_patterns": ["일반공격", "광역기공", "연쇄검기", "필살검", "광장파"],
		"description": "매우 공격적, 특수 능력 자주 사용"
	},
	BossPhase.PHASE_3: {
		"aggressiveness": 1.0,
		"defense_ratio": 0.1,
		"attack_patterns": ["일반공격", "광역기공", "연쇄검기", "필살검", "광장파", "무극회검"],
		"description": "절망적 공격, 방어 거의 안함"
	},
}

# 플레이어 반응 시스템
var player_pattern_counter = 0
var consecutive_defense_count = 0
var last_player_action_time = 0.0
var player_combo_weakness_detected = false

# 통계
var special_ability_stats = {}


func _init():
	super()
	ai_type = AIType.MARTIAL_MASTER
	current_state = "phase_start"
	
	# 특수 능력 통계 초기화
	for ability_name in special_abilities.keys():
		special_ability_stats[ability_name] = {
			"used": 0,
			"hits": 0,
			"damage_dealt": 0
		}


func update(delta: float, enemy_node: Node, player: Node) -> void:
	"""보스 AI 메인 업데이트"""
	target_player = player
	
	# Phase 확인
	update_phase(enemy_node)
	
	# 특수 능력 타이머 감소
	for ability_name in special_abilities.keys():
		special_abilities[ability_name]["timer"] -= delta
	
	# 플레이어 관찰
	observe_player_patterns(player)
	
	# 상태 업데이트
	update_boss_state(delta, enemy_node, player)
	
	# 다음 행동 결정
	if decision_timer <= 0:
		decide_next_action(enemy_node, player)
		decision_timer = DECISION_COOLDOWN


func update_phase(enemy_node: Node) -> void:
	"""현재 Phase 확인 및 변경"""
	var hp_ratio = enemy_node.health / float(enemy_node.max_health)
	var new_phase = BossPhase.PHASE_1
	
	if hp_ratio <= phase_change_thresholds[BossPhase.PHASE_3]:
		new_phase = BossPhase.PHASE_3
	elif hp_ratio <= phase_change_thresholds[BossPhase.PHASE_2]:
		new_phase = BossPhase.PHASE_2
	
	if new_phase != boss_phase:
		boss_phase = new_phase
		on_phase_changed(enemy_node)


func on_phase_changed(enemy_node: Node) -> void:
	"""Phase 변경 이벤트"""
	print("\n🔥 보스 PHASE %d 시작!" % boss_phase)
	print("   상태: %s" % phase_behaviors[boss_phase]["description"])
	
	# Phase 변경 시 일시적으로 더 공격적으로
	current_state = "phase_start"
	state_timer = 2.0
	
	# AI 설정 업데이트
	ai_aggressiveness = phase_behaviors[boss_phase]["aggressiveness"]
	ai_defensive_ratio = phase_behaviors[boss_phase]["defense_ratio"]


func observe_player_patterns(player: Node) -> void:
	"""플레이어 패턴 관찰"""
	if not player:
		return
	
	# 콤보 감지
	if combo_system and combo_system.combo_count > current_combo_count:
		player_combo_weakness_detected = true
		current_combo_count = combo_system.combo_count
		print("   📍 플레이어 콤보 감지: %d개 연쇄" % combo_system.combo_count)
	
	# 연속 방어 감지
	if defense_system and defense_system.is_defending:
		consecutive_defense_count += 1
	else:
		consecutive_defense_count = 0
		player_combo_weakness_detected = false


func decide_next_action(enemy_node: Node, player: Node) -> void:
	"""다음 행동 결정"""
	if not player:
		return
	
	var distance = enemy_node.global_position.distance_to(player.global_position)
	var hp_ratio = enemy_node.health / float(enemy_node.max_health)
	
	# 상태 결정
	if hp_ratio < 0.2:
		# 절망 모드: 필살기 연속 사용
		if try_use_special_ability(enemy_node, ["무극회검", "필살검"]):
			current_state = "special_attack"
			state_timer = 2.0
			return
	
	# Phase별 행동
	match boss_phase:
		BossPhase.PHASE_1:
			decide_phase1_action(distance, hp_ratio)
		BossPhase.PHASE_2:
			decide_phase2_action(distance, hp_ratio)
		BossPhase.PHASE_3:
			decide_phase3_action(distance, hp_ratio)


func decide_phase1_action(distance: float, hp_ratio: float) -> void:
	"""Phase 1: 기본 공격과 광역기공 혼합"""
	if distance > ATTACK_RANGE:
		current_state = "chase"
		state_timer = 1.0
	else:
		# 50% 광역기공, 50% 일반공격
		if randf() < 0.5 and try_use_special_ability(target_player, ["광역기공"]):
			current_state = "special_attack"
			state_timer = 1.5
		else:
			current_state = "attack"
			state_timer = 1.0


func decide_phase2_action(distance: float, hp_ratio: float) -> void:
	"""Phase 2: 특수 능력 자주 사용"""
	if distance > ATTACK_RANGE:
		current_state = "chase"
		state_timer = 1.0
	else:
		# 특수 능력 사용 확률 높음
		if randf() < 0.6:
			if try_use_special_ability(target_player, ["필살검", "광장파", "광역기공"]):
				current_state = "special_attack"
				state_timer = 2.0
				return
		
		# 플레이어가 연속 방어하면 필살검
		if consecutive_defense_count > 2:
			if try_use_special_ability(target_player, ["필살검"]):
				current_state = "special_attack"
				state_timer = 2.0
				return
		
		current_state = "attack"
		state_timer = 1.0


func decide_phase3_action(distance: float, hp_ratio: float) -> void:
	"""Phase 3: 절망적 공격, 방어 거의 안함"""
	if distance > ATTACK_RANGE:
		current_state = "chase"
		state_timer = 0.8
	else:
		# 무극회검 우선 사용
		if try_use_special_ability(target_player, ["무극회검", "필살검", "광장파"]):
			current_state = "special_attack"
			state_timer = 2.0
			return
		
		current_state = "attack"
		state_timer = 0.8


func try_use_special_ability(player: Node, ability_list: Array) -> bool:
	"""특수 능력 사용 시도"""
	for ability_name in ability_list:
		if ability_name not in special_abilities:
			continue
		
		var ability = special_abilities[ability_name]
		
		# Phase 확인
		if ability["phase_unlock"] > boss_phase:
			continue
		
		# 쿨다운 확인
		if ability["timer"] > 0:
			continue
		
		# 능력 사용
		use_special_ability(ability_name)
		return true
	
	return false


func use_special_ability(ability_name: String) -> void:
	"""특수 능력 실제 사용"""
	if ability_name not in special_abilities:
		return
	
	var ability = special_abilities[ability_name]
	
	print("\n⚡ 보스 특수 능력 발동: %s" % ability["name"])
	print("   설명: %s" % ability["description"])
	
	# 쿨다운 시작
	ability["timer"] = ability["cooldown"]
	
	# 통계 업데이트
	special_ability_stats[ability_name]["used"] += 1
	
	# 능력 효과 처리
	match ability_name:
		"광역기공":
			execute_aoe_attack(ability, ability["damage_multiplier"])
		"연쇄검기":
			execute_multi_hit_attack(ability, ability["hit_count"])
		"필살검":
			execute_single_hit_attack(ability, ability["damage_multiplier"] * 1.5)
		"광장파":
			execute_aoe_attack(ability, ability["damage_multiplier"] * 1.2)
		"무극회검":
			execute_aoe_attack(ability, ability["damage_multiplier"], true)


func execute_aoe_attack(ability: Dictionary, damage_multiplier: float, multi_hit: bool = false) -> void:
	"""광역 공격 실행"""
	print("   💥 광역 공격 (반경: %.0fm)" % ability["aoe_radius"])
	
	# 실제 게임에서는 Area3D 또는 충돌 검사로 주변 적/플레이어 타격
	var damage = ability.get("damage_multiplier", 1.0) * 10.0  # 기본 대미지
	damage *= damage_multiplier
	
	special_ability_stats[ability["name"]]["damage_dealt"] += damage
	
	if multi_hit:
		print("   ⚔️ %d회 연계 광역 공격" % ability.get("hit_count", 1))


func execute_multi_hit_attack(ability: Dictionary, hit_count: int) -> void:
	"""연쇄 공격 실행"""
	print("   💫 %d회 연쇄 공격 개시" % hit_count)
	
	var damage_per_hit = ability["damage_multiplier"] * 5.0
	for i in range(hit_count):
		special_ability_stats[ability["name"]]["hits"] += 1
		print("      [%d] 히트!" % (i + 1))


func execute_single_hit_attack(ability: Dictionary, damage_multiplier: float) -> void:
	"""단일 강공격 실행"""
	var damage = damage_multiplier * 15.0
	print("   💣 강공격 (대미지: %.0f)" % damage)
	special_ability_stats[ability["name"]]["damage_dealt"] += damage


func update_boss_state(delta: float, enemy_node: Node, player: Node) -> void:
	"""보스 상태 업데이트"""
	state_timer -= delta
	
	match current_state:
		"phase_start":
			# Phase 시작 효과
			pass
		"chase":
			# 플레이어 추격
			enemy_node.velocity = (player.global_position - enemy_node.global_position).normalized() * 8.0
		"attack":
			# 기본 공격
			pass
		"special_attack":
			# 특수 능력 사용 중 (잠시 정지)
			enemy_node.velocity = Vector3.ZERO
		"defend":
			# 방어
			enemy_node.velocity = Vector3.ZERO


func get_phase_info() -> Dictionary:
	"""현재 Phase 정보 반환"""
	return {
		"phase": boss_phase,
		"description": phase_behaviors[boss_phase]["description"],
		"aggressiveness": ai_aggressiveness,
		"defense_ratio": ai_defensive_ratio,
	}


func get_stats() -> Dictionary:
	"""보스 통계 반환"""
	return {
		"phase": boss_phase,
		"special_abilities_used": special_ability_stats,
		"total_special_attacks": special_ability_stats.values().map(func(x): return x["used"]).reduce(func(a, b): return a + b, 0),
	}
