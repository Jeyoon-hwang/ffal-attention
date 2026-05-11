extends Node

# ⚡ NEXUS Day 5: 콤보 시스템
# 같은 무술을 연속으로 사용할 때 데미지/판정을 점진적으로 강화

class_name ComboSystem

# 콤보 상수
const COMBO_TIMEOUT = 2.0  # 콤보 유지 시간 (초)
const COMBO_DAMAGE_MULTIPLIER = [1.0, 1.2, 1.4, 1.6, 1.9, 2.2]  # Hit 1-6+
const COMBO_ENERGY_COST_MODIFIER = [1.0, 1.05, 1.1, 1.15, 1.2, 1.25]  # 에너지는 더 비싸짐
const COMBO_STAGGER_MULTIPLIER = [1.0, 1.1, 1.3, 1.5, 1.7, 2.0]  # 경직 배수
const MAX_COMBO_COUNT = 6  # 최대 콤보 카운트 (6+는 모두 같은 배수)

# 콤보 추적
var current_combo_count = 0  # 현재 콤보 수
var last_combo_martial_index = -1  # 마지막으로 사용한 무술 슬롯
var combo_timer = 0.0  # 콤보 타이머
var combo_active = false  # 콤보 활성 여부

# 신호
signal combo_changed(count: int)
signal combo_reset()

# 콤보 통계
var combo_stats = {
	"total_combos_landed": 0,
	"highest_combo": 0,
	"total_damage_from_combos": 0.0
}

func _ready():
	pass

func _process(delta):
	"""매 프레임 콤보 타이머 업데이트"""
	if combo_active:
		combo_timer -= delta
		
		# 타임아웃되면 콤보 리셋
		if combo_timer <= 0:
			reset_combo()

# ==================== 콤보 처리 ====================

func attempt_combo(martial_slot_index: int) -> ComboData:
	"""
	무술 사용 시도 시 호출
	같은 무술이면 콤보 증가, 다르면 리셋
	
	Return: ComboData (배수, 에너지 수정자 등)
	"""
	var combo_data = ComboData.new()
	
	# 같은 무술 연속 사용 = 콤보!
	if martial_slot_index == last_combo_martial_index and combo_active:
		# 콤보 증가
		current_combo_count = min(current_combo_count + 1, MAX_COMBO_COUNT)
		combo_timer = COMBO_TIMEOUT  # 타이머 리셋
		combo_stats["total_combos_landed"] += 1
		
		# 통계 업데이트
		if current_combo_count > combo_stats["highest_combo"]:
			combo_stats["highest_combo"] = current_combo_count
		
		print("🔥 콤보 %d HIT! 데미지 배수: %.1f배" % [current_combo_count, get_damage_multiplier()])
	else:
		# 다른 무술이거나 처음 = 콤보 시작 (1)
		reset_combo()
		current_combo_count = 1
		last_combo_martial_index = martial_slot_index
		combo_active = true
		combo_timer = COMBO_TIMEOUT
		print("💥 새로운 콤보 시작! [무술 슬롯 %d]" % [martial_slot_index + 1])
	
	# ComboData 생성
	combo_data.combo_count = current_combo_count
	combo_data.damage_multiplier = get_damage_multiplier()
	combo_data.energy_cost_multiplier = get_energy_cost_multiplier()
	combo_data.stagger_multiplier = get_stagger_multiplier()
	combo_data.combo_bonus_damage = get_combo_bonus_damage()
	
	emit_signal("combo_changed", current_combo_count)
	
	return combo_data

func reset_combo():
	"""콤보 리셋"""
	if current_combo_count > 0:
		print("⏱️  콤보 타임아웃! %d HIT 종료" % current_combo_count)
	
	current_combo_count = 0
	last_combo_martial_index = -1
	combo_active = false
	combo_timer = 0.0
	
	emit_signal("combo_reset")

# ==================== 콤보 배수 계산 ====================

func get_damage_multiplier() -> float:
	"""현재 콤보의 데미지 배수 반환"""
	if current_combo_count == 0:
		return 1.0
	
	var index = min(current_combo_count - 1, COMBO_DAMAGE_MULTIPLIER.size() - 1)
	return COMBO_DAMAGE_MULTIPLIER[index]

func get_energy_cost_multiplier() -> float:
	"""현재 콤보의 에너지 비용 배수 반환"""
	if current_combo_count == 0:
		return 1.0
	
	var index = min(current_combo_count - 1, COMBO_ENERGY_COST_MODIFIER.size() - 1)
	return COMBO_ENERGY_COST_MODIFIER[index]

func get_stagger_multiplier() -> float:
	"""현재 콤보의 경직 배수 반환"""
	if current_combo_count == 0:
		return 1.0
	
	var index = min(current_combo_count - 1, COMBO_STAGGER_MULTIPLIER.size() - 1)
	return COMBO_STAGGER_MULTIPLIER[index]

func get_combo_bonus_damage() -> float:
	"""콤보로부터의 추가 고정 데미지"""
	# 콤보 2부터 시작해서 점진적으로 증가 (5 + 콤보수*3)
	if current_combo_count <= 1:
		return 0.0
	return 5.0 + (current_combo_count - 1) * 3.0

func is_combo_active() -> bool:
	"""현재 콤보가 활성인지 반환"""
	return combo_active and current_combo_count > 0

func get_current_combo_count() -> int:
	"""현재 콤보 수 반환"""
	return current_combo_count

# ==================== 통계 ====================

func get_combo_stats() -> Dictionary:
	"""콤보 통계 반환"""
	return combo_stats.duplicate()

func reset_stats():
	"""통계 리셋"""
	combo_stats = {
		"total_combos_landed": 0,
		"highest_combo": 0,
		"total_damage_from_combos": 0.0
	}

func add_combo_damage(damage: float):
	"""콤보 데미지 통계에 추가"""
	combo_stats["total_damage_from_combos"] += damage

# ==================== 콤보 데이터 클래스 ====================

class ComboData:
	var combo_count: int = 0
	var damage_multiplier: float = 1.0
	var energy_cost_multiplier: float = 1.0
	var stagger_multiplier: float = 1.0
	var combo_bonus_damage: float = 0.0
	
	func _to_string() -> String:
		return "ComboData[Hit:%d Dmg:%.1fx Eng:%.1fx Stagger:%.1fx +%d Dmg]" % [
			combo_count,
			damage_multiplier,
			energy_cost_multiplier,
			stagger_multiplier,
			combo_bonus_damage
		]
