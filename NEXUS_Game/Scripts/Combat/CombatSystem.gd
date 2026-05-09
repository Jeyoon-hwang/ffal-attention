extends Node3D
class_name CombatSystem
"""
전투 시스템 (Combat System)
- 플레이어 & 적 공격 관리
- 에너지 시스템
- 데미지 계산 & 적용
- 콤보 시스템

상태:
- Idle: 대기
- Attacking: 공격 중
- Defending: 방어 중
- Stunned: 경직
- Dead: 죽음
"""

# 기본 설정
var martial_art_engine: MartialArtEngine
var owner_stats: Dictionary = {
	"str": 10,
	"dex": 10,
	"con": 10,
	"int": 10,
	"wis": 10,
	"cha": 10
}

# 전투 상태
enum CombatState {IDLE, ATTACKING, DEFENDING, STUNNED, DEAD}
var current_state: CombatState = CombatState.IDLE

# HP & 에너지
@export var max_hp: float = 100.0
@export var max_energy: float = 100.0
var current_hp: float
var current_energy: float

# 데미지 딜레이 (중복 타격 방지)
var last_damage_time: float = 0.0
var damage_cooldown: float = 0.1

# 콤보 시스템
var combo_count: int = 0
var last_attack_time: float = 0.0
var combo_timeout: float = 2.0  # 2초 내에 연속 공격하면 콤보

# 현재 공격 정보
var current_attack: MartialArt = null
var attack_hit_frame: float = 0.0
var has_hit: bool = false

# 신호
signal health_changed(old_hp: float, new_hp: float)
signal energy_changed(old_energy: float, new_energy: float)
signal combat_state_changed(old_state: int, new_state: int)
signal attacked(martial_art: MartialArt, damage: float)
signal hit_taken(damage: float, attacker: Node3D)

func _ready():
	current_hp = max_hp
	current_energy = max_energy
	martial_art_engine = MartialArtEngine.new()
	martial_art_engine._ready()
	print("[CombatSystem] 초기화 완료 (HP:%d, Energy:%d)" % [int(current_hp), int(current_energy)])

func _process(delta):
	# 에너지 회복 (3초에 전체 회복)
	if current_state != CombatState.DEAD:
		var energy_regen = max_energy / 3.0 * delta
		recover_energy(energy_regen)
	
	# 경직 상태 해제
	if current_state == CombatState.STUNNED:
		# 경직 로직은 별도로 처리됨 (타이머)
		pass

## 기본 공격 (무술 슬롯)
func attack(martial_slot: int) -> bool:
	"""
	무술 슬롯으로 공격 시작
	
	파라미터:
	- martial_slot: 0-4 (5개 무술 슬롯)
	
	반환:
	- true: 공격 성공
	- false: 에너지 부족 등
	"""
	
	# 전투 상태 확인
	if current_state != CombatState.IDLE:
		print(f"❌ 현재 상태에서 공격 불가: {CombatState.keys()[current_state]}")
		return false
	
	# 무술 슬롯에서 무술 가져오기
	var martial = martial_art_engine.get_player_martial(martial_slot)
	if martial == null:
		print(f"❌ 무술 슬롯 {martial_slot}이 비어있음")
		return false
	
	# 에너지 확인
	if current_energy < martial.energy_cost:
		print(f"❌ 에너지 부족 ({int(current_energy)}/{martial.energy_cost})")
		return false
	
	# 공격 시작
	current_attack = martial
	attack_hit_frame = martial.animation_hit_frame
	has_hit = false
	
	# 상태 변경
	change_combat_state(CombatState.ATTACKING)
	
	# 에너지 소모
	consume_energy(martial.energy_cost)
	
	# 콤보 계산
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time < combo_timeout:
		combo_count += 1
	else:
		combo_count = 1
	last_attack_time = current_time
	
	print(f"▶️  공격: {martial.martial_name} (DMG:{martial.base_damage:.1f}, COMBO:{combo_count})")
	attacked.emit(martial, martial.base_damage)
	
	return true

## 방어 (가드 또는 회피)
func defend(defense_slot: int) -> bool:
	"""방어 무술 사용"""
	
	if current_state != CombatState.IDLE:
		return false
	
	var martial = martial_art_engine.get_player_martial(defense_slot)
	if martial == null:
		return false
	
	if current_energy < martial.energy_cost:
		return false
	
	# 방어 상태로 변경
	change_combat_state(CombatState.DEFENDING)
	consume_energy(martial.energy_cost)
	
	print(f"🛡️  방어: {martial.martial_name} (방어레벨:{martial.defense_level})")
	
	return true

## 피해 입기
func take_damage(damage: float, attacker: Node3D = null) -> void:
	"""
	데미지 입기
	
	파라미터:
	- damage: 데미지 양
	- attacker: 공격자 (null 가능)
	"""
	
	# 중복 타격 방지 (cooldown)
	if Time.get_ticks_msec() / 1000.0 - last_damage_time < damage_cooldown:
		return
	last_damage_time = Time.get_ticks_msec() / 1000.0
	
	# 방어 상태면 데미지 감소
	if current_state == CombatState.DEFENDING:
		damage *= 0.5  # 50% 감소
	
	# HP 감소
	var old_hp = current_hp
	current_hp = max(0, current_hp - damage)
	
	# HP 변화 신호 발생
	health_changed.emit(old_hp, current_hp)
	hit_taken.emit(damage, attacker)
	
	print(f"💔 피해: {damage:.1f} (HP: {int(old_hp)} → {int(current_hp)})")
	
	# 죽음 확인
	if current_hp <= 0:
		change_combat_state(CombatState.DEAD)
		print(f"💀 죽음!")

## 에너지 소비
func consume_energy(amount: int) -> void:
	var old_energy = current_energy
	current_energy = max(0, current_energy - amount)
	energy_changed.emit(old_energy, current_energy)

## 에너지 회복
func recover_energy(amount: float) -> void:
	var old_energy = current_energy
	current_energy = min(max_energy, current_energy + amount)
	if old_energy != current_energy:
		energy_changed.emit(old_energy, current_energy)

## 경직 상태 적용
func apply_stun(duration: float) -> void:
	"""경직 상태 적용 (지정된 시간 동안 이동/공격 불가)"""
	change_combat_state(CombatState.STUNNED)
	
	# 지정 시간 후 상태 해제
	await get_tree().create_timer(duration).timeout
	change_combat_state(CombatState.IDLE)
	print(f"✅ 경직 해제")

## 회복
func heal(amount: float) -> void:
	"""HP 회복"""
	var old_hp = current_hp
	current_hp = min(max_hp, current_hp + amount)
	health_changed.emit(old_hp, current_hp)
	print(f"💚 회복: +{amount:.1f}HP (HP: {int(old_hp)} → {int(current_hp)})")

## 전투 상태 변경
func change_combat_state(new_state: CombatState) -> void:
	if current_state == new_state:
		return
	
	var old_state = current_state
	current_state = new_state
	combat_state_changed.emit(old_state, new_state)
	print(f"🔄 상태: {CombatState.keys()[old_state]} → {CombatState.keys()[new_state]}")

## 공격 적중 (히트박스 판정)
func on_attack_hit(target: Node3D) -> void:
	"""
	공격이 적중했을 때 호출
	히트박스 판정 후 대상에게 데미지 전달
	"""
	if has_hit or current_attack == null:
		return
	
	has_hit = true
	
	var damage = current_attack.calculate_damage(owner_stats)
	damage *= (1.0 + combo_count * 0.1)  # 콤보 보너스 10%씩
	
	if target.has_method("take_damage"):
		target.take_damage(damage, self)
	
	print(f"✅ 명중! {damage:.1f} 데미지 (콤보: {combo_count}x)")

## 전투 종료
func end_combat() -> void:
	"""전투 상태 초기화"""
	if current_state == CombatState.ATTACKING:
		change_combat_state(CombatState.IDLE)
	combo_count = 0
	current_attack = null
	has_hit = false

## 상태 조회
func get_combat_stats() -> Dictionary:
	return {
		"hp": int(current_hp),
		"max_hp": int(max_hp),
		"energy": int(current_energy),
		"max_energy": int(max_energy),
		"state": CombatState.keys()[current_state],
		"combo": combo_count,
		"stats": owner_stats
	}

## 디버그 출력
func print_combat_stats() -> void:
	var stats = get_combat_stats()
	print("\n⚔️  전투 상태:")
	print(f"  HP: {stats['hp']}/{stats['max_hp']}")
	print(f"  Energy: {stats['energy']}/{stats['max_energy']}")
	print(f"  State: {stats['state']}")
	print(f"  Combo: {stats['combo']}")
	print(f"  Stats: STR{stats['stats']['str']} DEX{stats['stats']['dex']} CON{stats['stats']['con']}")
	print()
