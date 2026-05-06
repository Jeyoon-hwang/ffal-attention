# NEXUS 적 AI 시스템
# 4단계 난이도 AI (기본 → 마스터)
#
# Level 1: 기본 AI (거리 기반 공격)
# Level 2: 전술 AI (패턴 학습)
# Level 3: 적응형 AI (지형 활용, 멀티 페이즈)
# Level 4: 마스터 AI (완전 적응)

extends Node

class_name EnemyAI

# ============================================================================
# 상수
# ============================================================================

enum AILevel {
	BASIC = 1,      # Level 1: 기본
	TACTICAL = 2,   # Level 2: 전술
	ADAPTIVE = 3,   # Level 3: 적응형
	MASTER = 4      # Level 4: 마스터
}

enum AIState {
	IDLE,           # 대기
	PURSUING,       # 추적
	ATTACKING,      # 공격
	EVADING,        # 회피
	ENRAGED,        # 분노 (보스 전용)
}

# AI 파라미터
const AI_PARAMS = {
	AILevel.BASIC: {
		"attack_distance": 2.5,
		"pursuit_distance": 10.0,
		"decision_frequency": 1.0,     # 의사결정 빈도 (초)
		"evasion_chance": 0.1,
		"attack_accuracy": 0.8,
		"pattern_memory": 0,            # 패턴 메모리 없음
	},
	AILevel.TACTICAL: {
		"attack_distance": 3.0,
		"pursuit_distance": 15.0,
		"decision_frequency": 0.8,
		"evasion_chance": 0.25,
		"attack_accuracy": 0.9,
		"pattern_memory": 5,            # 5개 공격 기억
	},
	AILevel.ADAPTIVE: {
		"attack_distance": 3.5,
		"pursuit_distance": 20.0,
		"decision_frequency": 0.6,
		"evasion_chance": 0.4,
		"attack_accuracy": 0.95,
		"pattern_memory": 10,           # 10개 공격 기억
	},
	AILevel.MASTER: {
		"attack_distance": 4.0,
		"pursuit_distance": 25.0,
		"decision_frequency": 0.4,      # 더 자주 결정
		"evasion_chance": 0.7,
		"attack_accuracy": 1.0,
		"pattern_memory": 20,           # 20개 공격 기억
	}
}

# ============================================================================
# 멤버 변수
# ============================================================================

var ai_level: int = AILevel.BASIC
var current_state: int = AIState.IDLE
var martial_engine: MartialArtEngine
var player_combat: PlayerCombat

# AI 상태 변수
var hp: float = 50.0
var max_hp: float = 50.0
var target_position: Vector3 = Vector3.ZERO
var last_attack_time: float = 0.0
var decision_timer: float = 0.0
var pattern_history: Array[String] = [] # 플레이어 공격 패턴 기억
var threat_level: float = 0.0           # 현재 위협 수준
var enrage_threshold: float = 0.3       # HP 30% 이하 시 분노 (보스)

# AI 파라미터 (캐시)
var params: Dictionary = {}

# ============================================================================
# 초기화
# ============================================================================

func _ready() -> void:
	martial_engine = MartialArtEngine.new()
	martial_engine.initialize_base_arts()

func initialize(level: int = AILevel.BASIC, player: PlayerCombat = null) -> void:
	ai_level = level
	player_combat = player
	params = AI_PARAMS[ai_level].duplicate()
	print("적 AI 초기화: Level %d (%s)" % [ai_level, _get_level_name()])

func _get_level_name() -> String:
	match ai_level:
		AILevel.BASIC: return "기본"
		AILevel.TACTICAL: return "전술"
		AILevel.ADAPTIVE: return "적응형"
		AILevel.MASTER: return "마스터"
		_: return "미정"

# ============================================================================
# AI 메인 루프
# ============================================================================

func _process(delta: float) -> void:
	if player_combat == null:
		return
	
	decision_timer += delta
	
	# 의사결정 빈도에 따라 결정
	if decision_timer >= params["decision_frequency"]:
		decision_timer = 0.0
		_make_decision()
	
	# 현재 상태 업데이트
	_update_state(delta)
	
	# 위협 수준 계산
	_update_threat_level()

## 의사결정 로직
func _make_decision() -> void:
	var distance_to_player = target_position.distance_to(player_combat.transform.origin)
	
	# 플레이어 거리에 따른 상태 전환
	if distance_to_player > params["pursuit_distance"]:
		current_state = AIState.IDLE
	elif distance_to_player > params["attack_distance"]:
		current_state = AIState.PURSUING
	else:
		current_state = AIState.ATTACKING
	
	# AI 레벨별 행동
	match ai_level:
		AILevel.BASIC:
			_ai_basic()
		AILevel.TACTICAL:
			_ai_tactical()
		AILevel.ADAPTIVE:
			_ai_adaptive()
		AILevel.MASTER:
			_ai_master()

## 상태 업데이트
func _update_state(delta: float) -> void:
	match current_state:
		AIState.IDLE:
			# 대기 중 — 아무 행동 없음
			pass
		AIState.PURSUING:
			# 플레이어 추적
			_pursue_player(delta)
		AIState.ATTACKING:
			# 공격 시도
			_attempt_attack()
		AIState.EVADING:
			# 회피
			_evade_player(delta)
		AIState.ENRAGED:
			# 분노 상태 — 더 공격적
			_enraged_attack()

# ============================================================================
# AI 레벨별 행동
# ============================================================================

## Level 1: 기본 AI
func _ai_basic() -> void:
	if current_state == AIState.ATTACKING:
		# 80% 확률로 공격
		if randf() < params["attack_accuracy"]:
			_attempt_attack()
		else:
			# 20% 확률로 회피
			_evade_player(0.1)

## Level 2: 전술 AI (패턴 학습)
func _ai_tactical() -> void:
	# 플레이어 공격 패턴 학습
	if player_combat.last_art_used != null:
		var art_name = player_combat.last_art_used.name
		pattern_history.append(art_name)
		
		# 최근 5개만 기억
		if pattern_history.size() > 5:
			pattern_history.pop_front()
	
	if current_state == AIState.ATTACKING:
		# 공격 패턴에 따라 대응
		if pattern_history.size() >= 3:
			# 플레이어가 같은 공격을 반복하면 회피
			if pattern_history[-1] == pattern_history[-2] == pattern_history[-3]:
				_evade_player(0.2)
				return
		
		# 90% 확률로 공격
		if randf() < 0.9:
			_attempt_attack()

## Level 3: 적응형 AI (지형 활용)
func _ai_adaptive() -> void:
	# 플레이어 약점 분석
	var player_vulnerable = player_combat.hp / player_combat.max_hp < 0.4
	
	if current_state == AIState.ATTACKING:
		# 플레이어가 약할 때 강한 공격
		if player_vulnerable and randf() < 0.8:
			_use_strong_attack()
		else:
			_attempt_attack()
	
	# HP가 70% 이하면 회피 시작
	if hp / max_hp < 0.7:
		_evade_player(0.3)

## Level 4: 마스터 AI (완전 적응)
func _ai_master() -> void:
	# 완벽한 위협 분석
	var danger_level = _calculate_danger_level()
	
	if danger_level > 0.7:
		# 매우 위험 — 회피 + 특수 공격
		if randf() < params["evasion_chance"]:
			_evade_player(0.4)
			return
		_use_special_counter_attack()
	elif danger_level > 0.4:
		# 중위험 — 공격 + 회피 조화
		if randf() < 0.5:
			_attempt_attack()
		else:
			_evade_player(0.2)
	else:
		# 저위험 — 공격 집중
		_use_strong_attack()
	
	# 분노 상태 확인
	if hp / max_hp <= enrage_threshold and current_state != AIState.ENRAGED:
		current_state = AIState.ENRAGED
		print("적이 분노 상태로 전환! (HP %.0f%%)" % [(hp / max_hp) * 100])

# ============================================================================
# AI 행동 메서드
# ============================================================================

## 플레이어 추적
func _pursue_player(delta: float) -> void:
	if player_combat == null:
		return
	
	var direction = (player_combat.transform.origin - target_position).normalized()
	target_position += direction * 8.0 * delta

## 공격 시도
func _attempt_attack() -> void:
	if randf() < params["attack_accuracy"]:
		# 기본 무술 사용
		var damage = 15.0 + ai_level * 5.0
		player_combat.hp -= damage
		print("[적 공격] %.0f 데미지 (현재 HP: %.0f)" % [damage, player_combat.hp])

## 강한 공격 사용
func _use_strong_attack() -> void:
	var damage = 30.0 + ai_level * 10.0
	player_combat.hp -= damage
	print("[적 강공격] %.0f 데미지 (현재 HP: %.0f)" % [damage, player_combat.hp])

## 특수 카운터 공격
func _use_special_counter_attack() -> void:
	# Level 4 전용
	if ai_level == AILevel.MASTER:
		var counter_damage = 25.0
		if player_combat.last_art_used != null:
			# 플레이어 공격을 예측해서 회피 + 반격
			if randf() < 0.7: # 70% 성공률
				counter_damage *= 1.5
				print("[적 카운터] %.0f 데미지!" % counter_damage)
		
		player_combat.hp -= counter_damage

## 회피
func _evade_player(evasion_power: float) -> void:
	# 회피 성공 시 받는 데미지 50% 감소
	threat_level *= (1.0 - evasion_power)
	print("[적 회피] 위협 수준 감소 (%.1f%%)" % [threat_level * 100])

## 분노 상태 공격
func _enraged_attack() -> void:
	# 분노 중: 공격력 1.4배, 공격속도 1.5배
	var enraged_damage = 40.0 + ai_level * 15.0
	player_combat.hp -= enraged_damage
	print("[적 분노 공격!] %.0f 데미지 (현재 HP: %.0f)" % [enraged_damage, player_combat.hp])

# ============================================================================
# 계산 헬퍼 함수
# ============================================================================

## 플레이어에 대한 위협 수준 계산 (0.0 ~ 1.0)
func _calculate_danger_level() -> float:
	if player_combat == null:
		return 0.0
	
	# 플레이어 체력 비율
	var player_hp_ratio = player_combat.hp / player_combat.max_hp
	var player_threat = 1.0 - player_hp_ratio # HP 높을수록 위협
	
	# 플레이어 콤보
	var combo_threat = min(1.0, float(player_combat.combo_chain.size()) / 7.0)
	
	# MP 회복률
	var mp_threat = player_combat.mp / player_combat.max_mp
	
	# 종합 위협도
	var total_threat = (player_threat * 0.4 + combo_threat * 0.3 + mp_threat * 0.3)
	return total_threat

## 위협 수준 업데이트
func _update_threat_level() -> void:
	threat_level = _calculate_danger_level()

# ============================================================================
# 보스 기능 (AILevel.MASTER 전용)
# ============================================================================

## 보스 초기화
func initialize_as_boss() -> void:
	ai_level = AILevel.MASTER
	max_hp = 200.0
	hp = max_hp
	params = AI_PARAMS[AILevel.MASTER].duplicate()
	print("보스 AI 초기화 완료 (HP: %.0f)" % max_hp)

## 보스 멀티 페이즈 전환
func check_phase_transition() -> bool:
	if hp / max_hp <= 0.5 and current_state != AIState.ENRAGED:
		current_state = AIState.ENRAGED
		return true
	return false

# ============================================================================
# 디버그
# ============================================================================

func print_ai_status() -> void:
	print("\n=== 적 AI 상태 ===")
	print("레벨: %s (Level %d)" % [_get_level_name(), ai_level])
	print("현재 상태: %s" % ["IDLE", "PURSUING", "ATTACKING", "EVADING", "ENRAGED"][current_state])
	print("HP: %.0f/%.0f (%.1f%%)" % [hp, max_hp, (hp / max_hp) * 100])
	print("위협 수준: %.1f%%" % [threat_level * 100])
	if not pattern_history.is_empty():
		print("플레이어 공격 패턴: " + ", ".join(PackedStringArray(pattern_history)))

func test_ai_behavior() -> void:
	print("\n>>> AI 행동 테스트 시작 (Level: %s)" % _get_level_name())
	
	for i in range(10):
		_make_decision()
		await get_tree().create_timer(1.0).timeout
	
	print(">>> AI 행동 테스트 완료")
