## CombatSystem.gd - 전투 중앙 관리 시스템
## 플레이어 vs 적 (또는 적 vs 적) 전투 처리

class_name CombatSystem
extends Node

# ╔═════════════════════════════════════════════════════════╗
# ║           참여자 (Combatants)                          ║
# ╚═════════════════════════════════════════════════════════╝

var player: Player = null
var enemies: Array[Enemy] = []
var current_turn: String = "player"  # "player" or "enemy"

# ╔═════════════════════════════════════════════════════════╗
# ║            전투 상태 (Combat State)                     ║
# ╚═════════════════════════════════════════════════════════╝

var in_combat: bool = false
var combat_turn: int = 0
var combat_log: Array[String] = []

# ╔═════════════════════════════════════════════════════════╗
# ║          보상 추적 (Reward Tracking)                    ║
# ╚═════════════════════════════════════════════════════════╝

var total_damage_dealt: float = 0.0
var total_damage_taken: float = 0.0
var kills: int = 0


# ═══════════════════════════════════════════════════════════════════════════════

## 전투 시작
func start_combat(p_player: Player, p_enemies: Array[Enemy]) -> void:
	if in_combat:
		print("이미 전투 중!")
		return
	
	player = p_player
	enemies = p_enemies
	in_combat = true
	combat_turn = 0
	combat_log.clear()
	total_damage_dealt = 0.0
	total_damage_taken = 0.0
	kills = 0
	
	player.is_in_combat = true
	for enemy in enemies:
		enemy.current_state = "attack"
	
	_log("========== 전투 시작! ==========")
	_log("플레이어 vs %s" % [", ".join(enemies.map(func(e): return e.enemy_name))])


## 플레이어 행동 처리
func process_player_action(slot: int) -> bool:
	if not in_combat or player == null:
		return false
	
	if not player.is_alive() if player.has_method("is_alive") else player.current_hp > 0:
		end_combat("enemy")
		return false
	
	# 무술 발동
	var action_result = player.execute_martial_art(slot)
	
	if not action_result.get("success", false):
		_log("플레이어: %s" % action_result.get("reason", "행동 실패"))
		return false
	
	var damage = action_result.get("damage", 0.0)
	var effects = action_result.get("effects", [])
	var range_dist = action_result.get("range", 2.0)
	
	_log("플레이어: 무술 발동 (슬롯 %d) → %d 데미지" % [slot, int(damage)])
	
	# 적에게 데미지 적용 (범위 내 모든 적)
	var hits = 0
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) <= range_dist:
			apply_damage(enemy, damage)
			hits += 1
			
			# 효과 적용
			for effect in effects:
				apply_effect(enemy, effect)
	
	if hits == 0:
		_log("  (범위 내 적 없음)")
	else:
		_log("  → %d마리 적에게 명중" % hits)
	
	total_damage_dealt += damage
	current_turn = "enemy"
	return true


## 모든 적 행동 처리
func process_enemy_actions() -> void:
	if not in_combat:
		return
	
	for enemy in enemies:
		if enemy.current_state == "dead":
			continue
		
		if enemy.is_stunned:
			_log("%s: 기절 상태 (행동 불가)" % enemy.enemy_name)
			continue
		
		# AI 행동 결정
		var action = enemy.decide_action()
		if action.is_empty():
			continue
		
		# 행동 실행
		match action.get("action", ""):
			"attack":
				var slot = action.get("slot", 0)
				var target = action.get("target", player)
				
				var result = enemy.execute_martial_art(slot)
				if result.get("success", false):
					var damage = result.get("damage", 0.0)
					var effects = result.get("effects", [])
					
					_log("%s: 무술 발동 → %d 데미지" % [enemy.enemy_name, int(damage)])
					
					# 플레이어에게 데미지
					apply_damage(player, damage)
					
					# 효과 적용
					for effect in effects:
						apply_effect(player, effect)
					
					total_damage_taken += damage
			
			"chase":
				_log("%s: 추격 중..." % enemy.enemy_name)
			
			"defend":
				_log("%s: 방어 준비" % enemy.enemy_name)
	
	current_turn = "player"


## 데미지 적용
func apply_damage(target: Node, damage: float) -> void:
	if target is Player:
		target.take_damage(damage)
	elif target is Enemy:
		target.take_damage(damage)


## 효과 적용
func apply_effect(target: Node, effect: String) -> void:
	match effect:
		"stun":
			if target is Player:
				target.apply_stun(2.0)
				_log("  → 플레이어 기절 (2초)")
			elif target is Enemy:
				target.apply_stun(2.0)
				_log("  → %s 기절 (2초)" % target.enemy_name)
		
		"knockdown":
			_log("  → 다운 유발!")
		
		"burn":
			_log("  → 화염 데미지 시작!")
		
		"freeze":
			_log("  → 얼음 상태!")
		
		_:
			pass


## 데미지 계산 (명중 판정 포함)
func calculate_hit(attacker: Node, defender: Node, art: MartialArt) -> Dictionary:
	# 기본 명중률 70%
	var hit_chance = 70.0
	
	# 공격자 DEX로 증가
	if attacker.has_method("get_stat"):
		var dex_diff = attacker.get_stat("DEX") - (defender.get_stat("DEX") if defender.has_method("get_stat") else 0)
		hit_chance += dex_diff * 0.5
	
	# 실제 명중 판정
	var is_hit = randf() * 100 < clampf(hit_chance, 0.0, 100.0)
	
	var damage = 0.0
	var is_crit = false
	
	if is_hit:
		# 크리티컬 판정
		var crit_chance = 5.0
		if attacker.has_method("get_stat"):
			crit_chance += attacker.get_stat("DEX") * 0.1
		
		is_crit = randf() * 100 < crit_chance
		
		# 데미지 계산
		damage = art.calculate_damage(attacker)
		if is_crit:
			damage *= 1.5
	
	return {
		"hit": is_hit,
		"damage": damage,
		"crit": is_crit
	}


## 전투 종료
func end_combat(winner: String) -> void:
	if not in_combat:
		return
	
	in_combat = false
	player.is_in_combat = false
	
	_log("========== 전투 종료! ==========")
	
	if winner == "player":
		_log("승리!")
		
		# 보상 계산
		var total_exp = 0
		var total_gold = 0
		
		for enemy in enemies:
			if enemy.current_state == "dead":
				total_exp += enemy.experience_reward
				total_gold += enemy.gold_reward
				kills += 1
		
		player.gain_experience(float(total_exp))
		_log("경험치 +%d, 골드 +%d" % [total_exp, total_gold])
	
	else:
		_log("패배...")


## 전투 진행 시뮬레이션 (테스트용)
func simulate_combat() -> String:
	if player == null or enemies.is_empty():
		return "전투 준비 안 됨"
	
	start_combat(player, enemies)
	
	var max_turns = 50
	var turn = 0
	
	while in_combat and turn < max_turns:
		turn += 1
		
		# 플레이어 턴 (랜덤 행동)
		var slot = randi() % min(5, player.martial_slots.size())
		process_player_action(slot)
		
		# 전투 종료 확인
		if not in_combat:
			break
		
		# 적 턴
		process_enemy_actions()
		
		# 전투 종료 확인
		if not in_combat:
			break
		
		# 적 모두 죽음 확인
		var all_dead = true
		for enemy in enemies:
			if enemy.current_state != "dead":
				all_dead = false
				break
		
		if all_dead:
			end_combat("player")
			break
		
		# 플레이어 죽음 확인
		if player.current_hp <= 0:
			end_combat("enemy")
			break
	
	return get_combat_log()


# ╔═════════════════════════════════════════════════════════╗
# ║           전투 로그 (Combat Log)                        ║
# ╚═════════════════════════════════════════════════════════╝

## 로그 추가
func _log(message: String) -> void:
	combat_log.append(message)
	print(message)


## 전체 로그 반환
func get_combat_log() -> String:
	return "\n".join(combat_log)


## 현재 상태 정보
func get_status() -> String:
	var status = "전투 상태:\n"
	
	if player:
		status += "플레이어: HP %d/%d, Energy %d/%d\n" % [
			player.current_hp, player.max_hp,
			player.current_energy, player.max_energy
		]
	
	for enemy in enemies:
		if enemy.current_state != "dead":
			status += "%s: HP %d/%d\n" % [
				enemy.enemy_name,
				enemy.current_hp, enemy.max_hp
			]
	
	status += "\n턴: %d | 피해입음: %.0f | 피해줌: %.0f" % [
		combat_turn, total_damage_taken, total_damage_dealt
	]
	
	return status


## 표준 출력
func _to_string() -> String:
	return "CombatSystem(In Combat: %s, Enemies: %d, Turn: %d)" % [
		in_combat, enemies.size(), combat_turn
	]
