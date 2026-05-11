extends Node

# ⚡ NEXUS Day 5: 방어/회피 시스템
# 플레이어 방어, 회피, 카운터 어택 등을 관리

class_name DefenseSystem

# 방어 상수
const DEFENSE_DAMAGE_REDUCTION = 0.5  # 방어 중 50% 데미지 감소
const DEFENSE_ENERGY_DRAIN = 3.0  # 방어 중 초당 에너지 소비
const DEFENSE_BREAK_THRESHOLD = 20.0  # 방어 파괴되는 데미지 임계값

# 회피 상수
const DODGE_ENERGY_COST = 25.0  # 회피 한 번 에너지 비용
const DODGE_I_FRAMES = 0.5  # 회피 무적 시간 (초)
const DODGE_COOLDOWN = 1.5  # 회피 쿨다운 (초)
const DODGE_DISTANCE = 5.0  # 회피 거리 (m)

# 카운터 상수
const COUNTER_WINDOW = 0.3  # 카운터 가능 시간 (초)
const COUNTER_DAMAGE_MULTIPLIER = 1.5  # 카운터 데미지 배수
const COUNTER_ENERGY_GAIN = 15.0  # 카운터 성공 시 에너지 회복

# 방어 상태
var is_defending = false  # 현재 방어 중
var defense_stamina = 100.0  # 방어 체력 (0이 되면 방어 파괴)
var max_defense_stamina = 100.0

# 회피 상태
var is_dodging = false  # 회피 중 (무적)
var dodge_timer = 0.0  # 회피 무적 시간 남음
var dodge_cooldown_timer = 0.0  # 회피 쿨다운 남음

# 카운터 상태
var can_counter = false  # 카운터 가능 여부
var counter_window_timer = 0.0  # 카운터 윈도우 시간 남음

# 신호
signal defense_started()
signal defense_ended()
signal defense_broken()
signal dodge_performed(position: Vector3)
signal counter_executed(damage_multiplier: float)

# 통계
var defense_stats = {
	"total_blocks": 0,
	"total_damage_blocked": 0.0,
	"defense_breaks": 0,
	"total_dodges": 0,
	"total_counters": 0,
	"counter_damage_dealt": 0.0
}

func _ready():
	defense_stamina = max_defense_stamina

func _process(delta):
	"""매 프레임 방어/회피 타이머 업데이트"""
	# 회피 무적 시간 감소
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
			print("✅ 회피 무적 종료")
	
	# 회피 쿨다운 감소
	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta
	
	# 방어 중 에너지 소비
	if is_defending:
		# (Player에서 에너지 소비하도록 신호를 보내야 함)
		pass
	
	# 카운터 윈도우 감소
	if can_counter:
		counter_window_timer -= delta
		if counter_window_timer <= 0:
			can_counter = false

# ==================== 방어 시스템 ====================

func start_defense() -> bool:
	"""방어 시작"""
	if is_defending:
		return false  # 이미 방어 중
	
	if defense_stamina <= 0:
		print("❌ 방어 체력이 없습니다!")
		return false
	
	is_defending = true
	defense_stamina = max_defense_stamina
	print("🛡️  방어 시작!")
	emit_signal("defense_started")
	
	# 카운터 윈도우 시작
	can_counter = true
	counter_window_timer = COUNTER_WINDOW
	
	return true

func stop_defense() -> bool:
	"""방어 종료"""
	if not is_defending:
		return false
	
	is_defending = false
	can_counter = false
	print("🛡️  방어 종료")
	emit_signal("defense_ended")
	
	return true

func apply_defense_damage(incoming_damage: float) -> DefenseResult:
	"""
	방어 중 데미지 받음
	Return: DefenseResult (감소된 데미지, 방어 파괴 여부 등)
	"""
	var result = DefenseResult.new()
	
	if not is_defending:
		# 방어 중 아님 = 풀 데미지
		result.actual_damage = incoming_damage
		result.was_defended = false
		return result
	
	# 방어 중 = 데미지 감소
	result.actual_damage = incoming_damage * DEFENSE_DAMAGE_REDUCTION
	result.was_defended = true
	result.damage_blocked = incoming_damage - result.actual_damage
	
	# 방어 체력 감소
	defense_stamina -= incoming_damage * 0.5  # 방어 체력은 받은 데미지의 50%만 소비
	
	defense_stats["total_blocks"] += 1
	defense_stats["total_damage_blocked"] += result.damage_blocked
	
	print("🛡️  방어! 원래: %.0f → 실제: %.0f (%.0f 차단)" % [
		incoming_damage,
		result.actual_damage,
		result.damage_blocked
	])
	
	# 방어 파괴 체크
	if defense_stamina <= 0:
		stop_defense()
		result.defense_broken = true
		defense_stats["defense_breaks"] += 1
		print("💥 방어 파괴!")
		emit_signal("defense_broken")
	
	return result

# ==================== 회피 시스템 ====================

func perform_dodge(player_position: Vector3, dodge_direction: Vector3) -> bool:
	"""
	회피 수행
	dodge_direction은 정규화된 방향 벡터
	"""
	if is_dodging:
		print("❌ 이미 회피 중입니다!")
		return false
	
	if dodge_cooldown_timer > 0:
		print("❌ 회피 쿨다운 중 (%.1f초)" % dodge_cooldown_timer)
		return false
	
	# 회피 성공
	is_dodging = true
	dodge_timer = DODGE_I_FRAMES
	dodge_cooldown_timer = DODGE_COOLDOWN
	
	# 회피 위치 계산
	var dodge_position = player_position + (dodge_direction * DODGE_DISTANCE)
	
	defense_stats["total_dodges"] += 1
	print("⚡ 회피! 무적 시간: %.1f초, 쿨다운: %.1f초" % [DODGE_I_FRAMES, DODGE_COOLDOWN])
	
	emit_signal("dodge_performed", dodge_position)
	
	return true

func is_dodge_available() -> bool:
	"""회피 가능한지 확인"""
	return not is_dodging and dodge_cooldown_timer <= 0

func get_dodge_cooldown_remaining() -> float:
	"""회피 남은 쿨다운 반환"""
	return max(0.0, dodge_cooldown_timer)

# ==================== 카운터 시스템 ====================

func attempt_counter() -> bool:
	"""
	카운터 어택 시도
	카운터 윈도우 내에만 성공
	"""
	if not can_counter:
		print("❌ 현재 카운터 불가능!")
		return false
	
	# 카운터 성공!
	can_counter = false
	defense_stats["total_counters"] += 1
	
	print("🗡️  카운터 성공! %.1f배 데미지!" % COUNTER_DAMAGE_MULTIPLIER)
	emit_signal("counter_executed", COUNTER_DAMAGE_MULTIPLIER)
	
	return true

func get_counter_damage_multiplier() -> float:
	"""카운터 데미지 배수"""
	return COUNTER_DAMAGE_MULTIPLIER

# ==================== 상태 쿼리 ====================

func is_invulnerable() -> bool:
	"""현재 무적인지 (회피 중)"""
	return is_dodging

func is_protected() -> bool:
	"""현재 보호 중인지 (방어 또는 회피)"""
	return is_defending or is_dodging

func get_damage_reduction_multiplier() -> float:
	"""현재 데미지 감소 배수"""
	if is_defending:
		return DEFENSE_DAMAGE_REDUCTION
	elif is_dodging:
		return 0.0  # 무적 = 0% 데미지
	return 1.0  # 방어 아님 = 풀 데미지

# ==================== 통계 ====================

func get_defense_stats() -> Dictionary:
	"""방어 통계 반환"""
	return defense_stats.duplicate()

func reset_stats():
	"""통계 리셋"""
	defense_stats = {
		"total_blocks": 0,
		"total_damage_blocked": 0.0,
		"defense_breaks": 0,
		"total_dodges": 0,
		"total_counters": 0,
		"counter_damage_dealt": 0.0
	}

# ==================== 결과 클래스 ====================

class DefenseResult:
	var was_defended: bool = false
	var actual_damage: float = 0.0
	var damage_blocked: float = 0.0
	var defense_broken: bool = false
	
	func _to_string() -> String:
		var status = "defended" if was_defended else "no_defense"
		var broken = " [BROKEN]" if defense_broken else ""
		return "DefenseResult[%s Blocked:%.0f Actual:%.0f%s]" % [status, damage_blocked, actual_damage, broken]
