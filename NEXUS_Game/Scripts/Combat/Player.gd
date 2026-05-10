## Player.gd - 플레이어 캐릭터 데이터 & 행동
## 능력치, 무술, 인벤토리, 상태 관리

class_name Player
extends CharacterBody3D

# ╔═════════════════════════════════════════════════════════╗
# ║           기본 정보 (Identity)                          ║
# ╚═════════════════════════════════════════════════════════╝

var player_name: String = "무술인"
var level: int = 1
var experience: float = 0.0
var skill_points: int = 2

# ╔═════════════════════════════════════════════════════════╗
# ║            능력치 (Stats)                               ║
# ╚═════════════════════════════════════════════════════════╝

var stats: Dictionary = {
	"STR": 10,    # 근력 (데미지)
	"DEX": 10,    # 민첩 (회피, 크리)
	"CON": 10,    # 체력 (HP, 방어)
	"INT": 10,    # 지능 (마나)
	"WIS": 10,    # 지혜 (회복)
	"CHA": 10     # 매력 (설득)
}

# ╔═════════════════════════════════════════════════════════╗
# ║        생명 & 에너지 (Life & Resources)                ║
# ╚═════════════════════════════════════════════════════════╝

var max_hp: int = 100
var current_hp: int = 100
var max_energy: int = 100
var current_energy: int = 100
var max_spirit: int = 100
var current_spirit: int = 100

# ╔═════════════════════════════════════════════════════════╗
# ║           무술 시스템 (Martial Arts)                   ║
# ╚═════════════════════════════════════════════════════════╝

var martial_slots: Array[MartialArt] = []  # 최대 5개
var current_stance: String = "neutral"     # 자세: neutral, defensive, aggressive
var last_martial_used: int = -1            # 마지막 사용한 슬롯
var combo_count: int = 0                   # 현재 콤보 수

# ╔═════════════════════════════════════════════════════════╗
# ║           인벤토리 (Inventory)                          ║
# ╚═════════════════════════════════════════════════════════╝

var inventory: Dictionary = {}   # item_id → count
var equipment: Dictionary = {}   # slot_name → item_id

# ╔═════════════════════════════════════════════════════════╗
# ║            상태 (State)                                 ║
# ╚═════════════════════════════════════════════════════════╝

var is_in_combat: bool = false
var is_stunned: bool = false
var is_defending: bool = false
var is_dead: bool = false

# ╔═════════════════════════════════════════════════════════╗
# ║          내부 변수 (Internal)                           ║
# ╚═════════════════════════════════════════════════════════╝

var stun_timer: float = 0.0
var last_damage_source: Node = null


# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# 초기 무술 슬롯 설정 (비어있음)
	for i in range(5):
		martial_slots.append(null)
	
	# HP 초기화
	recalculate_max_hp()
	current_hp = max_hp
	current_energy = max_energy


func _process(delta: float) -> void:
	# 기절 타이머 감소
	if is_stunned and stun_timer > 0:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
	
	# 에너지 자동 회복 (1초당 10, 스탠스에 따라 달라짐)
	if not is_in_combat:
		recover_energy(10.0 * delta)
	else:
		# 전투 중엔 느리게 회복 (1초당 5)
		recover_energy(5.0 * delta)


# ╔═════════════════════════════════════════════════════════╗
# ║            능력치 (Stats Functions)                     ║
# ╚═════════════════════════════════════════════════════════╝

## 능력치 조회
func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)


## 능력치 증가
func increase_stat(stat_name: String, amount: int) -> bool:
	if skill_points < amount:
		return false
	
	if stat_name in stats:
		stats[stat_name] += amount
		skill_points -= amount
		recalculate_max_hp()
		return true
	
	return false


## HP 최대값 재계산 (CON 기반)
func recalculate_max_hp() -> void:
	max_hp = 100 + (stats["CON"] - 10) * 5


## 에너지 최대값 재계산 (STR 기반)
func recalculate_max_energy() -> void:
	max_energy = 100 + (stats["STR"] - 10) * 2


# ╔═════════════════════════════════════════════════════════╗
# ║       생명 & 자원 (Life & Resources Functions)         ║
# ╚═════════════════════════════════════════════════════════╝

## 데미지 입기
func take_damage(amount: float, source: Node = null) -> void:
	if is_dead:
		return
	
	# 방어 중이면 데미지 감소
	var actual_damage = amount
	if is_defending:
		actual_damage *= 0.6  # 40% 감소
	
	# CON 스탯으로 방어력 증가
	var defense = stats["CON"] * 0.3
	actual_damage -= defense
	actual_damage = max(1.0, actual_damage)
	
	current_hp -= int(actual_damage)
	last_damage_source = source
	
	if current_hp <= 0:
		current_hp = 0
		die()


## 체력 회복
func recover_hp(amount: float) -> void:
	current_hp = min(max_hp, int(current_hp + amount))


## 에너지 사용 (가능하면 true)
func use_energy(amount: float) -> bool:
	if current_energy >= amount:
		current_energy -= int(amount)
		return true
	return false


## 에너지 회복
func recover_energy(amount: float) -> void:
	current_energy = min(max_energy, int(current_energy + amount))


## 사망
func die() -> void:
	is_dead = true
	is_in_combat = false
	print("플레이어 사망!")


# ╔═════════════════════════════════════════════════════════╗
# ║          무술 관리 (Martial Arts Functions)            ║
# ╚═════════════════════════════════════════════════════════╝

## 무술 장착 (슬롯에 무술 장착)
func equip_martial_art(slot: int, art: MartialArt) -> bool:
	if slot < 0 or slot >= martial_slots.size():
		return false
	
	martial_slots[slot] = art
	return true


## 무술 제거
func unequip_martial_art(slot: int) -> bool:
	if slot < 0 or slot >= martial_slots.size():
		return false
	
	martial_slots[slot] = null
	return true


## 무술 발동 (에너지 소비 & 데미지 계산)
func execute_martial_art(slot: int) -> Dictionary:
	# 유효성 검사
	if is_stunned or is_dead:
		return {"success": false, "reason": "행동 불가"}
	
	if slot < 0 or slot >= martial_slots.size():
		return {"success": false, "reason": "유효하지 않은 슬롯"}
	
	var art = martial_slots[slot]
	if art == null:
		return {"success": false, "reason": "무술이 장착되지 않음"}
	
	# 에너지 확인
	var energy_needed = art.get_effective_energy_cost(self)
	if not use_energy(energy_needed):
		return {"success": false, "reason": "에너지 부족 (%d 필요)" % energy_needed}
	
	# 콤보 계산
	if art.is_combo and slot == last_martial_used:
		combo_count = min(art.max_combo_count, combo_count + 1)
	else:
		combo_count = 1
	
	last_martial_used = slot
	
	# 데미지 계산
	var damage = art.calculate_damage(self)
	
	# 크리티컬 판정 (DEX 기반, 5% + DEX*0.1%)
	var crit_chance = 5.0 + stats["DEX"] * 0.1
	var is_crit = randf() * 100 < crit_chance
	
	if is_crit:
		damage *= 1.5  # 크리티컬은 1.5배
		art.on_critical()
	else:
		art.on_hit()
	
	art.on_use()
	
	return {
		"success": true,
		"damage": damage,
		"critical": is_crit,
		"combo_count": combo_count,
		"energy_used": energy_needed,
		"effects": art.effects,
		"range": art.range_distance
	}


# ╔═════════════════════════════════════════════════════════╗
# ║              상태 (Status Functions)                    ║
# ╚═════════════════════════════════════════════════════════╝

## 기절 상태 적용
func apply_stun(duration: float) -> void:
	is_stunned = true
	stun_timer = duration
	print("플레이어 기절! %.1f초" % duration)


## 방어 상태 시작
func start_defending() -> void:
	is_defending = true


## 방어 상태 종료
func stop_defending() -> void:
	is_defending = false


## 자세 변경
func change_stance(new_stance: String) -> bool:
	if new_stance in ["neutral", "defensive", "aggressive"]:
		current_stance = new_stance
		return true
	return false


# ╔═════════════════════════════════════════════════════════╗
# ║          레벨업 & 경험치 (Leveling)                    ║
# ╚═════════════════════════════════════════════════════════╝

## 경험치 획득
func gain_experience(amount: float) -> void:
	experience += amount
	
	# 레벨업 필요 경험치: 레벨 × 500
	var exp_needed = level * 500
	
	if experience >= exp_needed:
		level_up()


## 레벨업
func level_up() -> void:
	level += 1
	experience -= level * 500
	skill_points += 2
	recalculate_max_hp()
	current_hp = max_hp
	
	print("레벨업! [Level %d] 스킬포인트 +2" % level)


# ╔═════════════════════════════════════════════════════════╗
# ║           저장/로드 (Save/Load)                         ║
# ╚═════════════════════════════════════════════════════════╝

## 플레이어 데이터를 딕셔너리로 변환 (저장용)
func to_dict() -> Dictionary:
	var martial_ids: Array[String] = []
	for art in martial_slots:
		if art:
			martial_ids.append(art.id)
		else:
			martial_ids.append("")
	
	return {
		"player_name": player_name,
		"level": level,
		"experience": experience,
		"skill_points": skill_points,
		"stats": stats.duplicate(),
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_energy": current_energy,
		"max_energy": max_energy,
		"martial_ids": martial_ids,
		"inventory": inventory.duplicate(),
		"equipment": equipment.duplicate()
	}


## 표준 출력
func _to_string() -> String:
	return "Player([Lv.%d] %s, HP: %d/%d, Energy: %d/%d)" % [
		level, player_name, current_hp, max_hp, current_energy, max_energy
	]


## 게임 시작 시 기본 무술 3개 자동 장착
func load_starting_martial_arts() -> void:
	"""게임 시작 시 기본 무술 자동 장착"""
	var engine = MartialArtEngine.new()
	engine._ready()
	engine.initialize_combat_martial_arts()
	
	# 기본 3개 무술 가져오기
	var martial_ids = ["basic_punch", "kick", "guard"]
	for slot in range(martial_ids.size()):
		if engine.martial_arts_db.has(martial_ids[slot]):
			martial_slots[slot] = engine.martial_arts_db[martial_ids[slot]]
			print(f"✅ [{slot}] {martial_ids[slot]} 장착")
	
	print(f"[Player] 기본 무술 {martial_slots.size()}개 슬롯 초기화 완료")
