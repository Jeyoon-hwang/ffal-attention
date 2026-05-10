## MartialArt.gd - 무술 데이터 & 계산 시스템
## 모든 무술의 데이터와 효과 처리

class_name MartialArt
extends Resource

# ===== 기본 정보 =====
var martial_id: String = "martial_000"
var martial_name: String = "무술"
var description: String = "설명 없음"

# ===== 기본 동작 =====
var base_motion: int = 0  # 0-99 (손, 발, 몸통 등)

# ===== 리듬 타입 =====
enum Tempo { FAST, MID, SLOW }
var tempo: Tempo = Tempo.FAST

# ===== 방어 타입 =====
enum DefenseType { NONE, DODGE, GUARD, PARRY, COUNTER }
var defense_type: DefenseType = DefenseType.NONE
var defense_level: int = 0  # 0-5

# ===== 에너지 =====
var energy_cost: int = 10

# ===== 데미지 =====
var base_damage: int = 5
var str_scaling: float = 0.5    # STR에 따른 스케일
var dex_scaling: float = 0.2    # DEX에 따른 스케일
var con_scaling: float = 0.0    # CON에 따른 스케일

# ===== 부가 효과 =====
enum Effect { NONE, STUN, FREEZE, BURN, POISON, BLEED, DOWN, STAGGER }
var effect: Effect = Effect.NONE
var effect_duration: float = 0.0
var effect_chance: float = 0.0  # 0.0-1.0

# ===== 판정 박스 =====
var hitbox_range: float = 1.5  # 미터
var hitbox_radius: float = 0.3

# ===== 애니메이션 =====
var animation_name: String = "attack_basic"
var animation_duration: float = 1.0
var startup_frames: int = 5     # 발동까지 프레임
var active_frames: int = 10     # 판정 지속 프레임
var recovery_frames: int = 5    # 복구 프레임

# ===== 콤보 =====
var can_combo: bool = true
var combo_requirements: Array[String] = []  # 이전 무술 ID

# ===== 강화 레벨 =====
var martial_level: int = 1
var upgrade_damage: int = 0
var upgrade_range: float = 0.0
var upgrade_cost: int = 0

# ===== 초기화 함수 =====

func _init(p_id: String = "", p_name: String = "") -> void:
	martial_id = p_id
	martial_name = p_name
	martial_arts.append(self) if self is MartialArt else null

func initialize_basic(
	p_name: String,
	p_damage: int,
	p_energy: int,
	p_tempo: Tempo = Tempo.FAST,
	p_animation: String = "attack_basic"
) -> void:
	"""기본 무술 초기화"""
	martial_name = p_name
	base_damage = p_damage
	energy_cost = p_energy
	tempo = p_tempo
	animation_name = p_animation
	description = "%s 무술" % p_name

# ===== 데미지 계산 =====

func calculate_damage(attacker: Character, defender: Character = null) -> int:
	"""데미지를 계산한다"""
	var base = base_damage
	
	# 공격자 스탯 보너스
	var str_bonus = attacker.stats["STR"] * str_scaling
	var dex_bonus = attacker.stats["DEX"] * dex_scaling
	var con_bonus = attacker.stats["CON"] * con_scaling
	
	# 최종 데미지
	var total = int(base + str_bonus + dex_bonus + con_bonus + upgrade_damage)
	
	# 방어자 방어도 계산
	var defense = 0
	if defender:
		defense = calculate_defense(defender)
	
	# 최종 적용
	var final_damage = max(1, total - defense)
	
	return final_damage

func calculate_defense(defender: Character) -> int:
	"""방어도를 계산한다"""
	var defense = 0
	
	match defense_type:
		DefenseType.DODGE:
			# DEX 기반 회피 (상대의 데미지 일부 무시)
			defense = int(defender.stats["DEX"] * 0.3)
		
		DefenseType.GUARD:
			# CON 기반 방어
			defense = int(defender.stats["CON"] * 0.4)
		
		DefenseType.PARRY:
			# DEX 기반 상쇄
			defense = int(defender.stats["DEX"] * 0.5)
		
		DefenseType.COUNTER:
			# 회피 후 역공격 (나중 구현)
			defense = int(defender.stats["DEX"] * 0.4)
	
	# 방어 레벨 반영
	defense += defense_level * 2
	
	return defense

# ===== 부가 효과 =====

func apply_effect(target: Character) -> bool:
	"""부가 효과를 적용한다"""
	if effect == Effect.NONE:
		return false
	
	if randf() > effect_chance:
		return false
	
	print("[효과] %s에게 %s 적용! (지속: %.1f초)" % [target.character_name, effect_name(effect), effect_duration])
	
	# 효과 처리 (나중에 더 상세히)
	match effect:
		Effect.STUN:
			target.is_defending = true
		
		Effect.FREEZE:
			target.is_defending = true
		
		Effect.BURN:
			target.is_defending = true
		
		Effect.DOWN:
			target.is_defending = true
	
	return true

func effect_name(e: Effect) -> String:
	"""효과 이름"""
	match e:
		Effect.NONE: return "없음"
		Effect.STUN: return "스턴"
		Effect.FREEZE: return "빙결"
		Effect.BURN: return "화염"
		Effect.POISON: return "독"
		Effect.BLEED: return "출혈"
		Effect.DOWN: return "다운"
		Effect.STAGGER: return "경직"
		_: return "불명"

# ===== 강화 =====

func upgrade(upgrade_type: String) -> bool:
	"""무술을 강화한다"""
	match upgrade_type:
		"damage":
			upgrade_damage += 2
			upgrade_cost += 10
		
		"range":
			upgrade_range += 0.1
			upgrade_cost += 10
		
		"level":
			martial_level += 1
			upgrade_cost += 20
		
		_:
			return false
	
	print("[강화] %s 강화 완료! (비용: %d)" % [martial_name, upgrade_cost])
	return true

# ===== 콤보 검증 =====

func can_execute_after(previous_martial: MartialArt) -> bool:
	"""이전 무술 후 이 무술을 사용할 수 있는가?"""
	if not can_combo:
		return false
	
	if combo_requirements.is_empty():
		return true
	
	if previous_martial:
		return previous_martial.martial_id in combo_requirements
	
	return false

# ===== 디버깅 =====

func print_info() -> void:
	"""무술 정보 출력"""
	print("\n=== [%s] ===" % martial_name)
	print("ID: %s" % martial_id)
	print("설명: %s" % description)
	print("데미지: %d (STR:%.1fx, DEX:%.1fx)" % [base_damage, str_scaling, dex_scaling])
	print("에너지: %d | 템포: %s" % [energy_cost, tempo_name(tempo)])
	print("리치: %.1f | 반경: %.1f" % [hitbox_range, hitbox_radius])
	
	if effect != Effect.NONE:
		print("효과: %s (%.0f%% 확률, %.1f초)" % [effect_name(effect), effect_chance * 100, effect_duration])
	
	print("강화 레벨: %d (보너스 데미지: %d)" % [martial_level, upgrade_damage])
	print("=" * 30 + "\n")

func tempo_name(t: Tempo) -> String:
	"""템포 이름"""
	match t:
		Tempo.FAST: return "빠름"
		Tempo.MID: return "중간"
		Tempo.SLOW: return "느림"
		_: return "불명"
