# 🥋 NEXUS Day 7: 보스 전투 테스트
# 플레이어 vs 첫 번째 보스 시뮬레이션

extends Node

class_name TestDay7BossBattle

# 테스트 컴포넌트
var player: Player
var boss: FirstBoss
var region: CentralRegion
var battle_log = []
var test_duration = 0.0
var battle_started = false
var battle_ended = false

# 테스트 설정
var max_battle_duration = 300.0  # 5분 제한
var simulate_mode = true  # true = 자동 시뮬레이션, false = 수동 입력


func _ready() -> void:
	"""테스트 초기화"""
	print("\n⚡ ========== NEXUS Day 7 보스 전투 테스트 ==========")
	print("목표: 플레이어 vs 첫 보스 (중원의 왕) 전투 검증")
	print("시뮬레이션 모드: %s" % ("ON" if simulate_mode else "OFF"))
	print("=================================================\n")
	
	setup_test_environment()


func setup_test_environment() -> void:
	"""테스트 환경 설정"""
	print("[1] 플레이어 생성...")
	player = Player.new()
	player._init()
	player.name = "TestPlayer"
	player.health = player.max_health
	print("    ✅ 플레이어 생성 완료 (체력: %d/%d)" % [player.health, player.max_health])
	
	print("\n[2] 중원 지역 생성...")
	region = CentralRegion.new()
	region._ready()
	print("    ✅ 지역 생성 완료")
	
	print("\n[3] 보스 생성...")
	boss = FirstBoss.new()
	boss._ready()
	boss.set_target(player)
	print("    ✅ 보스 생성 완료 (체력: %d/%d)" % [boss.health, boss.max_health])
	
	print("\n[4] 전투 초기화...")
	initialize_battle()


func initialize_battle() -> void:
	"""전투 초기화"""
	print("   📍 전투 시작 준비...")
	print("   플레이어: Lv. %d | 보스: %s (Lv. %d)" % [player.level, boss.BOSS_NAME, boss.BOSS_LEVEL])
	print("   플레이어 체력: %d | 보스 체력: %d\n" % [player.health, boss.health])
	
	battle_log.clear()
	test_duration = 0.0
	battle_started = false
	battle_ended = false


func simulate_battle() -> void:
	"""전투 시뮬레이션"""
	print("\n🔥 ========== 전투 시뮬레이션 시작 ==========\n")
	
	var turn = 0
	var battle_duration = 0.0
	
	while not battle_ended and battle_duration < max_battle_duration:
		turn += 1
		battle_duration += 0.1
		
		print("\n[Turn %d] %.1f초" % [turn, battle_duration])
		
		# 플레이어 행동
		var player_action = select_player_action()
		execute_player_action(player_action)
		
		# 보스 행동
		if boss.health > 0:
			boss.attack_player()
		
		# 전투 상태 확인
		if player.health <= 0:
			player_died()
			break
		
		if boss.health <= 0:
			boss_died()
			break
		
		# 진행 상황 표시
		print_battle_status()
		
		# Phase 변경 확인
		check_phase_change()
		
		# 자동 테스트 속도 (정상에서는 delta 기반)
		if simulate_mode and turn % 10 == 0:
			await get_tree().process_frame


func select_player_action() -> String:
	"""플레이어 행동 선택"""
	var actions = ["attack", "combo", "defend", "heal"]
	var weights = [0.4, 0.3, 0.2, 0.1]
	
	# 체력이 낮으면 방어 또는 회복 우선
	if player.health < player.max_health * 0.3:
		weights = [0.1, 0.1, 0.4, 0.4]
	
	# 가중치 기반 선택
	var rand = randf()
	var cumulative = 0.0
	for i in range(actions.size()):
		cumulative += weights[i]
		if rand < cumulative:
			return actions[i]
	
	return actions[0]


func execute_player_action(action: String) -> void:
	"""플레이어 행동 실행"""
	match action:
		"attack":
			player_basic_attack()
		"combo":
			player_combo_attack()
		"defend":
			player_defend()
		"heal":
			player_heal()


func player_basic_attack() -> void:
	"""기본 공격"""
	if player.energy < 10:
		print("   ⚠️ 에너지 부족 (현재: %d)" % player.energy)
		return
	
	var damage = randi_range(8, 15)
	var hit_chance = 0.85
	
	if randf() < hit_chance:
		boss.take_damage(damage)
		print("   ⚔️ [플레이어] 기본 공격 (데미지: %d)" % damage)
	else:
		print("   ❌ [플레이어] 기본 공격 (빗나감!)")
	
	player.energy -= 10


func player_combo_attack() -> void:
	"""콤보 공격"""
	if player.energy < 20:
		print("   ⚠️ 에너지 부족 (현재: %d)" % player.energy)
		return
	
	var hits = randi_range(3, 5)
	var total_damage = 0
	
	print("   💫 [플레이어] 콤보 공격 (%d회 히트)" % hits)
	
	for i in range(hits):
		var damage = randi_range(5, 10)
		total_damage += damage
		
		if randf() < 0.9:  # 높은 명중률
			boss.take_damage(damage)
			print("      [%d] 히트! (-%d)" % [i + 1, damage])
		else:
			print("      [%d] 빗나감!" % [i + 1])
	
	print("   총 데미지: %d" % total_damage)
	player.energy -= 20


func player_defend() -> void:
	"""방어"""
	print("   🛡️ [플레이어] 방어 모드 진입")
	player.is_defending = true


func player_heal() -> void:
	"""회복"""
	var heal_amount = 30
	player.health = mini(player.health + heal_amount, player.max_health)
	print("   💚 [플레이어] 회복 (체력: +%d)" % heal_amount)
	player.energy -= 15


func player_died() -> void:
	"""플레이어 사망"""
	battle_ended = true
	print("\n💔 ========== 플레이어 사망 ==========")
	print("전투 시간: %.1f초" % test_duration)
	print("보스 남은 체력: %d/%d (%.1f%%)" % [boss.health, boss.max_health, boss.health / float(boss.max_health) * 100])


func boss_died() -> void:
	"""보스 사망"""
	battle_ended = true
	print("\n🎉 ========== 보스 격파! ==========")
	print("전투 시간: %.1f초" % test_duration)
	print("플레이어 남은 체력: %d/%d (%.1f%%)" % [player.health, player.max_health, player.health / float(player.max_health) * 100])
	print("플레이어 경험치 +500 | 골드 +1000")


func print_battle_status() -> void:
	"""전투 상태 표시"""
	var player_hp_bar = create_hp_bar(player.health, player.max_health, 20)
	var boss_hp_bar = create_hp_bar(boss.health, boss.max_health, 20)
	
	print("\n   [상태]")
	print("   플레이어 [%s] %d/%d (에너지: %d)" % [
		player_hp_bar,
		player.health,
		player.max_health,
		player.energy
	])
	print("   보스     [%s] %d/%d (Phase: %d)" % [
		boss_hp_bar,
		boss.health,
		boss.max_health,
		boss.boss_ai.boss_phase if boss.boss_ai else 0
	])


func check_phase_change() -> void:
	"""Phase 변경 확인"""
	if not boss.boss_ai:
		return
	
	var current_phase = boss.boss_ai.boss_phase
	var prev_phase = boss.boss_ai.boss_phase
	
	# Phase 변경 감지
	var hp_ratio = boss.health / float(boss.max_health)
	if hp_ratio <= 0.3:
		if prev_phase < BossAIEnhanced.BossPhase.PHASE_3:
			print("\n   ⚡ Phase 3 진입! 보스의 공격이 극도로 강해진다!")
	elif hp_ratio <= 0.6:
		if prev_phase < BossAIEnhanced.BossPhase.PHASE_2:
			print("\n   ⚡ Phase 2 진입! 보스가 분노한다!")


func create_hp_bar(current: int, max_hp: int, width: int = 20) -> String:
	"""HP 바 생성"""
	var ratio = float(current) / float(max_hp)
	var filled = int(width * ratio)
	var empty = width - filled
	
	var bar = "█".repeat(filled) + "░".repeat(empty)
	return bar


func print_test_summary() -> void:
	"""테스트 요약"""
	print("\n⚡ ========== 테스트 요약 ==========")
	print("테스트 결과: %s" % ("성공" if battle_ended else "진행 중"))
	print("전투 시간: %.1f초" % test_duration)
	print("플레이어 체력: %d/%d" % [player.health, player.max_health])
	print("보스 체력: %d/%d" % [boss.health, boss.max_health])
	print("====================================\n")


func get_test_results() -> Dictionary:
	"""테스트 결과 반환"""
	return {
		"test_name": "Day 7 보스 전투",
		"status": "완료" if battle_ended else "진행 중",
		"player_survived": player.health > 0,
		"boss_defeated": boss.health <= 0,
		"battle_duration": test_duration,
		"player_final_health": player.health,
		"boss_final_health": boss.health,
	}


# 테스트 실행 함수
func run_test() -> void:
	"""전체 테스트 실행"""
	initialize_battle()
	await simulate_battle()
	print_test_summary()


# Godot 환경에서 실행할 경우
func _process(delta: float) -> void:
	"""프레임 업데이트"""
	if not battle_started and not battle_ended:
		battle_started = true
		run_test()
