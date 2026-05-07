## MartialArt.gd - 개별 무술 데이터 & 로직
## 모든 무술은 이 클래스의 인스턴스로 관리됨
## 예: 펀치, 회전차기, 화염부호법 등

class_name MartialArt
extends RefCounted

# ╔═════════════════════════════════════════════════════════╗
# ║           기본 정보 (Identity)                          ║
# ╚═════════════════════════════════════════════════════════╝

var id: String                          # 무술 ID: "punch_001"
var name: String                        # 무술 이름: "펀치"
var description: String = ""            # 설명
var icon_path: String = ""              # UI 아이콘 경로

# ╔═════════════════════════════════════════════════════════╗
# ║          성능 파라미터 (Performance)                    ║
# ╚═════════════════════════════════════════════════════════╝

var base_power: float = 10.0            # 기본 데미지 (1-100)
var energy_cost: int = 5                # 필요 에너지 (1-10)
var cooldown: float = 0.0               # 쿨타임 (초, 0=없음)
var range_distance: float = 2.0         # 공격 범위 (미터)
var animation_name: String = ""         # 애니메이션 ID

# ╔═════════════════════════════════════════════════════════╗
# ║           무술 특성 (Characteristics)                  ║
# ╚═════════════════════════════════════════════════════════╝

var is_combo: bool = false              # 콤보 가능 여부
var max_combo_count: int = 1            # 최대 콤보 횟수
var is_guard_breaking: bool = false     # 방어 무시 여부
var is_knockdown: bool = false          # 다운 유발 여부
var attack_type: String = "physical"    # "physical", "magical", "mixed"

# ╔═════════════════════════════════════════════════════════╗
# ║             효과 (Effects)                              ║
# ╚═════════════════════════════════════════════════════════╝

var effects: Array[String] = []         # ["stun", "burn", ...]
var effect_duration: float = 1.0        # 상태이상 지속시간 (초)

# ╔═════════════════════════════════════════════════════════╗
# ║           강화 & 숙련도 (Advancement)                   ║
# ╚═════════════════════════════════════════════════════════╝

var level: int = 1                      # 무술 레벨 (1-10)
var mastery: float = 0.0                # 숙련도 (0-100%)
var learning_cost: int = 0              # 습득 비용 (골드 또는 스킬포인트)

# ╔═════════════════════════════════════════════════════════╗
# ║            능력치 스케일 (Stat Scaling)                ║
# ╚═════════════════════════════════════════════════════════╝

var str_scaling: float = 0.8            # STR 스케일 (0-1.0)
var dex_scaling: float = 0.3            # DEX 스케일
var int_scaling: float = 0.0            # INT 스케일 (마나/특수)
var con_scaling: float = 0.0            # CON 스케일 (방어)

# ╔═════════════════════════════════════════════════════════╗
# ║             통계 (Statistics)                            ║
# ╚═════════════════════════════════════════════════════════╝

var use_count: int = 0                  # 총 사용 횟수
var hit_count: int = 0                  # 명중 횟수
var crit_count: int = 0                 # 크리티컬 횟수


# ═══════════════════════════════════════════════════════════════════════════════

## 초기화 (생성자 역할)
## 예: MartialArt.new().init("punch_001", "펀치", 10)
func init(p_id: String, p_name: String, p_power: float) -> MartialArt:
	id = p_id
	name = p_name
	base_power = p_power
	return self


## 데미지 계산 (공격자 스탯 기반)
## 예: damage = martial.calculate_damage(player)
func calculate_damage(attacker: Node) -> float:
	var damage = base_power
	
	# 공격자 스탯이 있다면 적용
	if attacker.has_method("get_stat"):
		damage += attacker.get_stat("STR") * str_scaling
		damage += attacker.get_stat("DEX") * dex_scaling
		damage += attacker.get_stat("INT") * int_scaling
	
	# 레벨 스케일링
	damage *= (1.0 + (level - 1) * 0.1)
	
	# 숙련도 보너스 (최대 20%)
	damage *= (1.0 + mastery * 0.002)
	
	return max(1.0, damage)


## 에너지 비용 계산 (능력치 영향)
## 우수한 스탯이면 더 적은 에너지 사용
func get_effective_energy_cost(attacker: Node) -> int:
	var cost = energy_cost
	
	# INT가 높으면 비용 감소 (최대 30%)
	if attacker.has_method("get_stat"):
		var int_stat = attacker.get_stat("INT")
		cost = int(cost * (1.0 - min(0.3, int_stat * 0.01)))
	
	return max(1, cost)


## 모든 정보를 딕셔너리로 변환 (저장/전송용)
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"base_power": base_power,
		"energy_cost": energy_cost,
		"cooldown": cooldown,
		"range": range_distance,
		"is_combo": is_combo,
		"max_combo_count": max_combo_count,
		"is_guard_breaking": is_guard_breaking,
		"is_knockdown": is_knockdown,
		"attack_type": attack_type,
		"effects": effects,
		"effect_duration": effect_duration,
		"level": level,
		"mastery": mastery,
		"str_scaling": str_scaling,
		"dex_scaling": dex_scaling,
		"int_scaling": int_scaling
	}


## 딕셔너리에서 복원 (로드용)
static func from_dict(data: Dictionary) -> MartialArt:
	var art = MartialArt.new()
	
	art.id = data.get("id", "unknown")
	art.name = data.get("name", "Unknown Art")
	art.description = data.get("description", "")
	art.base_power = data.get("base_power", 10.0)
	art.energy_cost = data.get("energy_cost", 5)
	art.cooldown = data.get("cooldown", 0.0)
	art.range_distance = data.get("range", 2.0)
	art.is_combo = data.get("is_combo", false)
	art.max_combo_count = data.get("max_combo_count", 1)
	art.is_guard_breaking = data.get("is_guard_breaking", false)
	art.is_knockdown = data.get("is_knockdown", false)
	art.attack_type = data.get("attack_type", "physical")
	art.effects = data.get("effects", [])
	art.effect_duration = data.get("effect_duration", 1.0)
	art.level = data.get("level", 1)
	art.mastery = data.get("mastery", 0.0)
	art.str_scaling = data.get("str_scaling", 0.8)
	art.dex_scaling = data.get("dex_scaling", 0.3)
	art.int_scaling = data.get("int_scaling", 0.0)
	
	return art


## 무술 강화 (레벨 up)
func upgrade(amount: int = 1) -> bool:
	if level + amount > 10:
		return false
	
	level += amount
	mastery = 0.0  # 레벨업하면 숙련도 초기화
	return true


## 숙련도 증가
func increase_mastery(amount: float = 1.0) -> void:
	mastery = min(100.0, mastery + amount)


## 무술 사용 (통계 업데이트)
func on_use() -> void:
	use_count += 1


## 명중 (통계 업데이트)
func on_hit() -> void:
	hit_count += 1
	increase_mastery(0.5)


## 크리티컬 (통계 업데이트)
func on_critical() -> void:
	crit_count += 1
	increase_mastery(1.0)


## 표준 출력 (디버그)
func _to_string() -> String:
	return "MartialArt([%s] %s, Power: %.1f, Energy: %d, Level: %d)" % [
		id, name, base_power, energy_cost, level
	]
