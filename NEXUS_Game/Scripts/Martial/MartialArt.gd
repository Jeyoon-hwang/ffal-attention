extends Resource
class_name MartialArt
"""
무술 시스템 - 기본 데이터 구조
플레이어가 사용할 수 있는 무술 정의 및 속성 관리

구성요소:
1. Base Motion (기본 동작 ID: 0-99)
2. Tempo (리듬: Fast/Mid/Slow)
3. Defense Type (방어: Evade/Guard/Deflect/Counter, 각 레벨 1-5)
4. Energy Cost (에너지 비용: 1-10)
5. Hitbox (판정 박스)
6. Additional Effect (추가 효과: Stun, Knockdown, Burn, Freeze 등)
"""

# 무술 기본 정보
@export var martial_id: String = "default"
@export var martial_name: String = "기본공격"
@export var description: String = ""

# 기본 동작 (0-99)
@export var base_motion: int = 0
@export var motion_name: String = "Punch"

# 리듬 (Fast/Mid/Slow)
enum Tempo {FAST, MID, SLOW}
@export var tempo: Tempo = Tempo.MID

# 데미지 & 파워
@export var base_damage: float = 10.0
@export var damage_scaling: float = 1.0  # STR 스탯 영향도
@export var crit_chance: float = 0.1  # 치명타 확률

# 방어 타입 (회피/가드/상쇄/카운터, 각 레벨 1-5)
enum DefenseType {NONE, EVADE, GUARD, DEFLECT, COUNTER}
@export var defense_type: DefenseType = DefenseType.NONE
@export var defense_level: int = 0  # 0-5

# 에너지 시스템
@export var energy_cost: int = 5  # 1-10
@export var energy_regen_on_hit: int = 0  # 명중 시 에너지 회복

# 판정 박스 (Hitbox)
@export var hitbox_range: float = 1.5  # 판정 거리
@export var hitbox_offset: Vector3 = Vector3(0, 0, 0)  # 판정 위치 오프셋
@export var hit_targets: int = 1  # 동시 타격 가능 수 (1=단일, 999=광역)

# 애니메이션
@export var animation_name: String = "Punch"
@export var animation_duration: float = 0.8
@export var animation_hit_frame: float = 0.4  # 데미지 판정 프레임

# 추가 효과 (Stun/Knockdown/Burn/Freeze 등, 최대 3개)
enum EffectType {NONE, STUN, KNOCKDOWN, BURN, FREEZE, BLEED, POISON, CONFUSE}
@export var effects: Array[EffectType] = []
@export var effect_durations: Array[float] = []  # 각 효과의 지속 시간

# 콤보 설정
@export var can_combo: bool = true  # 콤보 가능 여부
@export var combo_priority: int = 0  # 낮을수록 우선 (스킬 슬롯)

# 레벨 & 강화
@export var martial_level: int = 1
@export var martial_exp: int = 0
@export var martial_exp_required: int = 100

# 비용 & 획득
@export var gold_cost: int = 0  # 구매 가격
@export var fragment_cost: int = 0  # 프래그먼트 필요량
@export var skill_points_required: int = 0  # 강화에 필요한 스킬포인트

func _init():
	resource_path = "res://Data/MartialArts/" + martial_id + ".tres"

## 데미지 계산
func calculate_damage(attacker_stats: Dictionary) -> float:
	"""
	공격자 스탯으로 데미지 계산
	attacker_stats: {"str": 10, "dex": 8, "int": 5, ...}
	"""
	var str_bonus = attacker_stats.get("str", 10) * damage_scaling
	var dex_bonus = attacker_stats.get("dex", 10) * 0.3 * crit_chance
	var final_damage = (base_damage + str_bonus + dex_bonus) * martial_level
	
	# 치명타 계산 (5% ~ 20%)
	if randf() < crit_chance:
		final_damage *= 1.5  # 50% 추가 데미지
	
	return final_damage

## 효과 적용
func apply_effects(target: Node3D) -> void:
	"""효과 적용 (Stun, Burn 등)"""
	for i in range(effects.size()):
		var effect = effects[i]
		var duration = effect_durations[i] if i < effect_durations.size() else 0.0
		
		match effect:
			EffectType.STUN:
				if target.has_method("apply_stun"):
					target.apply_stun(duration)
			EffectType.KNOCKDOWN:
				if target.has_method("apply_knockdown"):
					target.apply_knockdown()
			EffectType.BURN:
				if target.has_method("apply_burn"):
					target.apply_burn(duration)
			EffectType.FREEZE:
				if target.has_method("apply_freeze"):
					target.apply_freeze(duration)

## 강화
func upgrade() -> bool:
	"""스킬포인트 사용하여 무술 강화"""
	if martial_level >= 10:  # 최대 레벨
		return false
	
	martial_level += 1
	base_damage *= 1.1  # 10% 데미지 증가
	energy_cost = max(1, energy_cost - 1)  # 에너지 비용 감소
	
	return true

## 직렬화 (JSON)
func to_dict() -> Dictionary:
	return {
		"martial_id": martial_id,
		"martial_name": martial_name,
		"base_motion": base_motion,
		"tempo": tempo,
		"base_damage": base_damage,
		"energy_cost": energy_cost,
		"animation_name": animation_name,
		"defense_type": defense_type,
		"defense_level": defense_level,
		"martial_level": martial_level,
	}

func from_dict(data: Dictionary) -> void:
	martial_id = data.get("martial_id", "default")
	martial_name = data.get("martial_name", "무술")
	base_motion = data.get("base_motion", 0)
	tempo = data.get("tempo", Tempo.MID)
	base_damage = data.get("base_damage", 10.0)
	energy_cost = data.get("energy_cost", 5)
	animation_name = data.get("animation_name", "")
	defense_type = data.get("defense_type", DefenseType.NONE)
	martial_level = data.get("martial_level", 1)

func _to_string() -> String:
	return f"[{martial_name}] DMG:{base_damage:.1f} COST:{energy_cost} LVL:{martial_level}"
