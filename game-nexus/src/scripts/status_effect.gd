extends Node

# ⚡ NEXUS Day 5: 상태이상 시스템
# 기절, 경직, 다운, 화염, 빙결, 감전 등의 상태이상 관리

class_name StatusEffect

# 상태이상 타입
enum Type {
	STUN = 0,         # 기절 (공격 불가)
	STAGGER = 1,      # 경직 (느려짐)
	DOWNHIT = 2,      # 다운 (넘어짐)
	BURN = 3,         # 화염 (지속 데미지)
	FREEZE = 4,       # 빙결 (이동 불가)
	SHOCK = 5,        # 감전 (랜덤 실패)
	POISON = 6,       # 독 (지속 약화)
	SLOW = 7,         # 둔화 (속도 감소)
	BLEED = 8,        # 출혈 (지속 데미지)
	DEFENSE_DOWN = 9, # 방어력 저하
}

# 상태이상 지속 시간 (초)
const DURATION_MAP = {
	Type.STUN: 2.0,
	Type.STAGGER: 1.5,
	Type.DOWNHIT: 2.0,
	Type.BURN: 5.0,
	Type.FREEZE: 3.0,
	Type.SHOCK: 2.0,
	Type.POISON: 5.0,
	Type.SLOW: 4.0,
	Type.BLEED: 6.0,
	Type.DEFENSE_DOWN: 4.0,
}

# 상태이상 이름
const NAME_MAP = {
	Type.STUN: "기절",
	Type.STAGGER: "경직",
	Type.DOWNHIT: "다운",
	Type.BURN: "화염",
	Type.FREEZE: "빙결",
	Type.SHOCK: "감전",
	Type.POISON: "독",
	Type.SLOW: "둔화",
	Type.BLEED: "출혈",
	Type.DEFENSE_DOWN: "방어력저하",
}

# 활성 상태이상들 (Dictionary[타입, 남은시간])
var active_effects = {}

# 지속 데미지 타입 (BURN, POISON, BLEED)
var damage_ticks = {}  # Dictionary[타입, {damage_per_second, timer}]

# 신호
signal effect_applied(effect_type: int, duration: float)
signal effect_removed(effect_type: int)
signal effect_tick_damage(damage: float, effect_type: int)  # 지속 데미지

# 통계
var effect_stats = {
	"total_effects_applied": 0,
	"total_damage_from_effects": 0.0,
	"effects_resisted": 0
}

func _ready():
	pass

func _process(delta):
	"""매 프레임 상태이상 타이머 업데이트"""
	# 상태이상 타이머 감소
	var effects_to_remove = []
	for effect_type in active_effects.keys():
		active_effects[effect_type] -= delta
		if active_effects[effect_type] <= 0:
			effects_to_remove.append(effect_type)
	
	# 만료된 상태이상 제거
	for effect_type in effects_to_remove:
		remove_effect(effect_type)
	
	# 지속 데미지 처리
	process_damage_ticks(delta)

# ==================== 상태이상 적용 ====================

func apply_effect(effect_type: int, damage_per_second: float = 0.0) -> bool:
	"""
	상태이상 적용
	damage_per_second: 지속 데미지 타입의 경우 초당 데미지 (0이면 적용 안함)
	"""
	if not Type.values().contains(effect_type):
		print("❌ 잘못된 상태이상 타입: %d" % effect_type)
		return false
	
	var effect_name = NAME_MAP.get(effect_type, "Unknown")
	var duration = DURATION_MAP.get(effect_type, 1.0)
	
	# 이미 같은 상태이상이 있으면 지속시간만 갱신 (중첩 X)
	if active_effects.has(effect_type):
		active_effects[effect_type] = duration
		print("🔄 [%s] 지속시간 갱신 (%.1f초)" % [effect_name, duration])
		return true
	
	# 새로운 상태이상 적용
	active_effects[effect_type] = duration
	effect_stats["total_effects_applied"] += 1
	
	print("💫 [%s] 적용됨! (%.1f초)" % [effect_name, duration])
	emit_signal("effect_applied", effect_type, duration)
	
	# 지속 데미지 설정
	if damage_per_second > 0:
		damage_ticks[effect_type] = {
			"damage_per_second": damage_per_second,
			"timer": 0.0
		}
	
	return true

func remove_effect(effect_type: int) -> bool:
	"""상태이상 제거"""
	if not active_effects.has(effect_type):
		return false
	
	var effect_name = NAME_MAP.get(effect_type, "Unknown")
	active_effects.erase(effect_type)
	damage_ticks.erase(effect_type)
	
	print("✅ [%s] 해제됨" % effect_name)
	emit_signal("effect_removed", effect_type)
	
	return true

func clear_all_effects():
	"""모든 상태이상 제거"""
	active_effects.clear()
	damage_ticks.clear()
	print("🧹 모든 상태이상 해제됨")

# ==================== 지속 데미지 처리 ====================

func process_damage_ticks(delta: float) -> float:
	"""지속 데미지 처리 및 총 데미지 반환"""
	var total_damage = 0.0
	
	for effect_type in damage_ticks.keys():
		if not active_effects.has(effect_type):
			continue
		
		var tick_data = damage_ticks[effect_type]
		tick_data["timer"] += delta
		
		# 1초마다 데미지 틱
		if tick_data["timer"] >= 1.0:
			var damage = tick_data["damage_per_second"]
			total_damage += damage
			effect_stats["total_damage_from_effects"] += damage
			
			var effect_name = NAME_MAP.get(effect_type, "Unknown")
			print("💔 [%s] 지속 데미지: %.0f" % [effect_name, damage])
			emit_signal("effect_tick_damage", damage, effect_type)
			
			tick_data["timer"] -= 1.0
	
	return total_damage

# ==================== 상태 쿼리 ====================

func has_effect(effect_type: int) -> bool:
	"""특정 상태이상 있는지 확인"""
	return active_effects.has(effect_type)

func has_any_effect() -> bool:
	"""어떤 상태이상이든 있는지 확인"""
	return active_effects.size() > 0

func get_active_effects() -> Array:
	"""활성 상태이상 목록 반환"""
	return active_effects.keys()

func get_effect_remaining_time(effect_type: int) -> float:
	"""특정 상태이상의 남은 시간"""
	if not active_effects.has(effect_type):
		return 0.0
	return active_effects[effect_type]

func get_effect_name(effect_type: int) -> String:
	"""상태이상 이름 반환"""
	return NAME_MAP.get(effect_type, "Unknown")

# ==================== 특수 효과 ====================

func can_move() -> bool:
	"""이동 가능한지 (FREEZE, STUN 체크)"""
	return not has_effect(Type.FREEZE) and not has_effect(Type.STUN)

func can_attack() -> bool:
	"""공격 가능한지 (STUN, FREEZE 체크)"""
	return not has_effect(Type.STUN) and not has_effect(Type.FREEZE)

func get_speed_multiplier() -> float:
	"""이동 속도 배수"""
	var multiplier = 1.0
	
	if has_effect(Type.SLOW):
		multiplier *= 0.6  # 40% 느려짐
	
	if has_effect(Type.FREEZE):
		multiplier *= 0.0  # 완전히 정지
	
	if has_effect(Type.STAGGER):
		multiplier *= 0.7  # 30% 느려짐
	
	return multiplier

func get_defense_multiplier() -> float:
	"""방어력 배수"""
	var multiplier = 1.0
	
	if has_effect(Type.DEFENSE_DOWN):
		multiplier *= 0.6  # 40% 감소
	
	return multiplier

func get_accuracy_multiplier() -> float:
	"""명중률 배수"""
	var multiplier = 1.0
	
	if has_effect(Type.SHOCK):
		multiplier *= 0.7  # 30% 감소
	
	return multiplier

# ==================== 디버그 UI ====================

func get_status_display() -> String:
	"""상태이상 디버그 표시"""
	if active_effects.size() == 0:
		return "[상태이상 없음]"
	
	var display = "["
	var count = 0
	for effect_type in active_effects.keys():
		if count > 0:
			display += ", "
		var effect_name = NAME_MAP.get(effect_type, "Unknown")
		var remaining = active_effects[effect_type]
		display += "%s(%.1f초)" % [effect_name, remaining]
		count += 1
	display += "]"
	
	return display

# ==================== 통계 ====================

func get_effect_stats() -> Dictionary:
	"""상태이상 통계"""
	return effect_stats.duplicate()

func reset_stats():
	"""통계 리셋"""
	effect_stats = {
		"total_effects_applied": 0,
		"total_damage_from_effects": 0.0,
		"effects_resisted": 0
	}

# ==================== 헬퍼 함수 ====================

static func get_type_from_name(name: String) -> int:
	"""이름으로 타입 찾기"""
	for type_val in Type.values():
		if NAME_MAP.get(type_val, "") == name:
			return type_val
	return -1

func apply_burning(damage_per_second: float = 5.0) -> bool:
	"""화염 상태이상 편의 함수"""
	return apply_effect(Type.BURN, damage_per_second)

func apply_poison(damage_per_second: float = 3.0) -> bool:
	"""독 상태이상 편의 함수"""
	return apply_effect(Type.POISON, damage_per_second)

func apply_bleed(damage_per_second: float = 4.0) -> bool:
	"""출혈 상태이상 편의 함수"""
	return apply_effect(Type.BLEED, damage_per_second)

func apply_stun() -> bool:
	"""기절 상태이상 편의 함수"""
	return apply_effect(Type.STUN)

func apply_freeze() -> bool:
	"""빙결 상태이상 편의 함수"""
	return apply_effect(Type.FREEZE)

func apply_slow() -> bool:
	"""둔화 상태이상 편의 함수"""
	return apply_effect(Type.SLOW)
