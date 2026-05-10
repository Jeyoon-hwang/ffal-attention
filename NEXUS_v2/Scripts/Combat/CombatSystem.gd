## CombatSystem.gd - 전투 엔진
## 플레이어와 적 간의 전투 로직 처리

class_name CombatSystem
extends Node

# ===== 참조 =====
var player: Player = null
var current_enemy: Enemy = null

# ===== 로그 =====
var combat_log: Array[String] = []
var max_log_size: int = 100

# ===== 상태 =====
var is_combat_active: bool = false
var combat_round: int = 0

# ===== 신호 =====
signal combat_started(player: Character, enemy: Character)
signal combat_ended(victor: Character, defeated: Character)
signal attack_executed(attacker: Character, damage: int)
signal enemy_defeated(enemy: Character)

func start_combat(p: Player, e: Enemy) -> void:
	"""전투를 시작한다"""
	player = p
	current_enemy = e
	is_combat_active = true
	combat_round = 0
	combat_log.clear()
	
	# AI 타겟 설정
	if e.ai_controller:
		e.ai_controller.set_target(player)
	
	player.is_in_combat = true
	e.is_in_combat = true
	
	add_log("===== 전투 시작: %s vs %s =====" % [player.character_name, e.character_name])
	print("\n[전투 시작] %s(HP: %d) vs %s(HP: %d)\n" % [player.character_name, player.current_hp, e.character_name, e.current_hp])
	
	combat_started.emit(player, e)

func end_combat(victor: Character, defeated: Character) -> void:
	"""전투를 종료한다"""
	if not is_combat_active:
		return
	
	is_combat_active = false
	
	victor.is_in_combat = false
	defeated.is_in_combat = false
	
	add_log("===== 전투 종료 =====")
	add_log("%s가 %s를 격파했습니다!" % [victor.character_name, defeated.character_name])
	
	print("\n[전투 종료] %s가 승리했습니다!\n" % victor.character_name)
	
	# 보상 분배
	if defeated.is_in_group("enemy"):
		victor.gain_experience(defeated.drop_experience)
	
	combat_ended.emit(victor, defeated)

# ===== 공격 처리 =====

func apply_martial_attack(attacker: Character, martial: MartialArt, defender: Character) -> int:
	"""무술 공격을 적용한다"""
	
	# 데미지 계산
	var damage = calculate_damage(attacker, martial, defender)
	
	# 방어 적용
	if defender.is_guarding if defender is Player else false:
		var defense = (defender as Player).apply_guard_defense()
		damage = max(1, damage - defense)
		add_log("%s가 방어 중! 데미지 감소: %d" % [defender.character_name, defense])
	
	# 데미지 적용
	defender.take_damage(damage)
	add_log("%s의 %s! %s에게 %d 데미지!" % [attacker.character_name, martial.martial_name, defender.character_name, damage])
	
	# 부가 효과 적용
	if martial.apply_effect(defender):
		add_log("  → %s 상태이상!" % martial.effect_name(martial.effect))
	
	attack_executed.emit(attacker, damage)
	
	# 전투 종료 확인
	check_combat_end()
	
	return damage

func calculate_damage(attacker: Character, martial: MartialArt, defender: Character) -> int:
	"""데미지를 계산한다"""
	
	var base_damage = martial.calculate_damage(attacker, defender)
	
	# 급격한 변동 추가 (±10%)
	var variance = randf_range(0.9, 1.1)
	var final_damage = int(base_damage * variance)
	
	return max(1, final_damage)

# ===== 전투 상태 확인 =====

func check_combat_end() -> void:
	"""전투 종료 여부를 확인한다"""
	if not player or not current_enemy:
		return
	
	if not player.is_alive:
		end_combat(current_enemy, player)
	elif not current_enemy.is_alive:
		end_combat(player, current_enemy)
		enemy_defeated.emit(current_enemy)

# ===== 라운드 관리 =====

func next_round() -> void:
	"""다음 라운드로 진행한다"""
	combat_round += 1
	add_log("\n=== 라운드 %d ===" % combat_round)

# ===== 로그 =====

func add_log(message: String) -> void:
	"""전투 로그에 메시지를 추가한다"""
	combat_log.append(message)
	
	if combat_log.size() > max_log_size:
		combat_log.pop_front()

func print_log() -> void:
	"""전투 로그를 출력한다"""
	print("\n===== 전투 로그 =====")
	for log in combat_log:
		print(log)
	print("=" * 30 + "\n")

func get_log() -> Array[String]:
	"""전투 로그를 반환한다"""
	return combat_log.duplicate()

# ===== 통계 =====

func get_combat_stats() -> Dictionary:
	"""전투 통계를 반환한다"""
	return {
		"round": combat_round,
		"log_count": combat_log.size(),
		"player_hp": player.current_hp if player else 0,
		"enemy_hp": current_enemy.current_hp if current_enemy else 0
	}

func print_combat_summary() -> void:
	"""전투 요약을 출력한다"""
	if not player or not current_enemy:
		return
	
	print("\n===== 전투 요약 =====")
	print("라운드: %d" % combat_round)
	print("플레이어: HP %d/%d" % [player.current_hp, player.max_hp])
	print("적: HP %d/%d" % [current_enemy.current_hp, current_enemy.max_hp])
	print("로그 항목: %d개" % combat_log.size())
	print("=" * 30 + "\n")
