## Character.gd - 캐릭터 기본 클래스
## 플레이어와 적 모두가 상속받는 베이스 클래스

class_name Character
extends Node3D

# ===== 기본 정보 =====
var character_name: String = "캐릭터"
var level: int = 1
var experience: int = 0
var skill_points: int = 0

# ===== 스탯 =====
var stats = {
	"STR": 10,   # 공격력
	"DEX": 10,   # 회피, 크리티컬
	"CON": 10,   # 체력
	"INT": 10,   # 스킬 파워
	"WIS": 10,   # 지혜, 회복
	"CHA": 10    # 매력
}

# ===== HP & Energy =====
var max_hp: int = 100
var current_hp: int = 100
var max_energy: int = 100
var current_energy: int = 100

# ===== 무술 슬롯 (5개) =====
var martial_arts: Array[MartialArt] = []

# ===== 상태 =====
var is_alive: bool = true
var is_in_combat: bool = false
var is_attacking: bool = false
var is_defending: bool = false

# ===== 신호 =====
signal hp_changed(new_hp: int)
signal energy_changed(new_energy: int)
signal level_up(new_level: int)
signal died()

func _ready():
	## 초기화
	current_hp = max_hp
	current_energy = max_energy
	
	print("[%s] 초기화: HP=%d, Energy=%d" % [character_name, current_hp, current_energy])

# ===== HP 관리 =====

func take_damage(damage: int) -> void:
	"""데미지를 입는다"""
	if not is_alive:
		return
	
	var actual_damage = max(1, damage)  # 최소 1 데미지
	current_hp -= actual_damage
	hp_changed.emit(current_hp)
	
	print("[%s] 데미지: -%d (현재 HP: %d/%d)" % [character_name, actual_damage, current_hp, max_hp])
	
	if current_hp <= 0:
		die()

func restore_hp(amount: int) -> void:
	"""체력을 회복한다"""
	if not is_alive:
		return
	
	var heal_amount = amount
	current_hp = min(current_hp + heal_amount, max_hp)
	hp_changed.emit(current_hp)
	
	print("[%s] 회복: +%d (현재 HP: %d/%d)" % [character_name, heal_amount, current_hp, max_hp])

func die() -> void:
	"""사망한다"""
	is_alive = false
	print("[%s] 사망!" % character_name)
	died.emit()

# ===== Energy 관리 =====

func use_energy(amount: int) -> bool:
	"""에너지를 소비한다"""
	if current_energy < amount:
		print("[%s] 에너지 부족! (필요: %d, 현재: %d)" % [character_name, amount, current_energy])
		return false
	
	current_energy -= amount
	energy_changed.emit(current_energy)
	
	return true

func restore_energy(amount: int) -> void:
	"""에너지를 회복한다"""
	if not is_alive:
		return
	
	var restore_amount = amount
	current_energy = min(current_energy + restore_amount, max_energy)
	energy_changed.emit(current_energy)

# ===== 무술 슬롯 관리 =====

func add_martial_art(martial: MartialArt, slot: int = -1) -> bool:
	"""무술을 슬롯에 추가한다"""
	if slot == -1:
		# 빈 슬롯 찾기
		for i in range(martial_arts.size()):
			if not martial_arts[i]:
				martial_arts[i] = martial
				print("[%s] 무술 습득: %s (슬롯 %d)" % [character_name, martial.martial_name, i])
				return true
		
		# 슬롯 꽉 찼으면 에러
		print("[%s] 무술 슬롯이 가득 찼습니다!" % character_name)
		return false
	else:
		if slot < 0 or slot >= martial_arts.size():
			print("[%s] 잘못된 슬롯 번호: %d" % [character_name, slot])
			return false
		
		martial_arts[slot] = martial
		print("[%s] 무술 교체: %s (슬롯 %d)" % [character_name, martial.martial_name, slot])
		return true

func remove_martial_art(slot: int) -> void:
	"""무술을 슬롯에서 제거한다"""
	if slot >= 0 and slot < martial_arts.size():
		martial_arts[slot] = null
		print("[%s] 무술 제거 (슬롯 %d)" % [character_name, slot])

func get_martial_art(slot: int) -> MartialArt:
	"""슬롯의 무술을 반환한다"""
	if slot >= 0 and slot < martial_arts.size():
		return martial_arts[slot]
	return null

# ===== 경험치 & 레벨업 =====

func gain_experience(amount: int) -> void:
	"""경험치를 얻는다"""
	experience += amount
	print("[%s] 경험치 +%d (총: %d)" % [character_name, amount, experience])
	
	# 간단한 레벨업 로직 (100 경험치 = 1 레벨)
	var new_level = 1 + (experience / 100)
	if new_level > level:
		level_up_to(new_level)

func level_up_to(new_level: int) -> void:
	"""레벨을 올린다"""
	if new_level <= level:
		return
	
	var old_level = level
	level = new_level
	skill_points += 2  # 레벨업 시 2포인트 획득
	
	# HP, Energy 증가
	max_hp = 100 + level * 10 + stats["CON"] * 5
	max_energy = 100 + level * 5 + stats["CON"] * 2
	current_hp = max_hp
	current_energy = max_energy
	
	print("[%s] 레벨업! %d → %d (스킬 포인트: %d, 최대HP: %d)" % [character_name, old_level, level, skill_points, max_hp])
	level_up.emit(level)

# ===== 스탯 관리 =====

func add_stat(stat_name: String, amount: int) -> void:
	"""스탯을 올린다"""
	if stat_name in stats:
		stats[stat_name] += amount
		print("[%s] %s +%d (현재: %d)" % [character_name, stat_name, amount, stats[stat_name]])

func get_stat(stat_name: String) -> int:
	"""스탯을 반환한다"""
	if stat_name in stats:
		return stats[stat_name]
	return 0

# ===== 디버깅 =====

func print_status() -> void:
	"""상태 출력"""
	print("\n=== [%s] 상태 ===" % character_name)
	print("레벨: %d | 경험치: %d | 스킬 포인트: %d" % [level, experience, skill_points])
	print("HP: %d/%d | Energy: %d/%d" % [current_hp, max_hp, current_energy, max_energy])
	print("STR: %d | DEX: %d | CON: %d | INT: %d | WIS: %d | CHA: %d" % [
		stats["STR"], stats["DEX"], stats["CON"], 
		stats["INT"], stats["WIS"], stats["CHA"]
	])
	print("무술: %d개 습득" % [count_martial_arts()])
	print("=" * 30 + "\n")

func count_martial_arts() -> int:
	"""습득한 무술 개수"""
	var count = 0
	for martial in martial_arts:
		if martial:
			count += 1
	return count
