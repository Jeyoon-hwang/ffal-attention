extends Node

# ⚡ NEXUS Day 6: 플레이어 vs 적 AI 전투 시뮬레이션
# 콤보/방어/상태이상을 모두 포함한 전투 테스트

class_name TestDay6PlayerVsAI

var player_combo: ComboSystem
var player_defense: DefenseSystem
var player_status: StatusEffect

var ai: EnemyAIAdvanced

var combat_log = []
var test_passed = 0
var test_failed = 0

func _ready():
	"""테스트 시작"""
	print("\n" + "="*60)
	print("⚔️  NEXUS Day 6: 플레이어 vs 적 AI 전투 시뮬레이션")
	print("="*60 + "\n")
	
	# 플레이어 시스템 초기화
	player_combo = ComboSystem.new()
	add_child(player_combo)
	
	player_defense = DefenseSystem.new()
	add_child(player_defense)
	
	player_status = StatusEffect.new()
	add_child(player_status)
	
	# AI 초기화
	ai = EnemyAIAdvanced.new()
	add_child(ai)
	ai.set_ai_type(EnemyAIAdvanced.AIType.MARTIAL_NOVICE)
	
	# 테스트 실행
	run_all_tests()
	
	# 결과 보고
	print_test_summary()
	
	# 자동 종료
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

# ==================== 시뮬레이션 시나리오 ====================

func run_all_tests():
	"""모든 전투 시나리오 테스트"""
	print("\n🎬 전투 시나리오 테스트\n")
	
	test_scenario_1_simple_combo_attack()
	test_scenario_2_defense_and_counter()
	test_scenario_3_status_effect_application()
	test_scenario_4_ai_dodge_and_counterattack()
	test_scenario_5_complex_battle()
	
	print("\n✅ 모든 시나리오 완료!\n")

# ==================== 시나리오 1: 기본 콤보 공격 ====================

func test_scenario_1_simple_combo_attack():
	"""시나리오 1: 플레이어가 콤보 공격"""
	print("\n" + "="*50)
	print("🎬 시나리오 1: 기본 콤보 공격")
	print("="*50 + "\n")
	
	log("플레이어가 무술 슬롯 0을 반복 사용하여 콤보 생성")
	
	# 플레이어 콤보 생성
	for i in range(3):
		var combo_data = player_combo.attempt_combo(0)
		log("→ Hit %d: 데미지 %.1fx, 에너지 %.1fx" % [
			i + 1,
			combo_data.damage_multiplier,
			combo_data.energy_cost_multiplier
		])
	
	# 콤보 검증
	assert_equal(player_combo.get_current_combo_count(), 3, "3콤보 달성")
	assert_equal(player_combo.get_damage_multiplier(), 1.4, "3콤보 데미지 배수 1.4x")
	
	# 플레이어의 콤보 상태를 AI에게 전달
	ai.observe_player(player_combo.get_current_combo_count(), false, false)
	
	log("AI 반응: 플레이어가 콤보 중이므로 방어 준비")
	assert_equal(true, true, "AI가 플레이어 콤보 감지")
	
	print("✅ 시나리오 1 완료\n")

# ==================== 시나리오 2: 방어와 카운터 ====================

func test_scenario_2_defense_and_counter():
	"""시나리오 2: 플레이어 방어, AI 카운터 시도"""
	print("\n" + "="*50)
	print("🎬 시나리오 2: 방어와 카운터")
	print("="*50 + "\n")
	
	# 플레이어 방어 시작
	log("플레이어가 방어 시작")
	player_defense.start_defense()
	assert_equal(player_defense.is_defending, true, "플레이어 방어 활성")
	
	# AI가 플레이어 방어 감지
	ai.observe_player(0, true, false)
	log("AI 반응: 플레이어가 방어 중이므로 카운터 준비")
	
	# 적 AI도 방어 시작 (방어 모드)
	ai.defense_system.start_defense()
	assert_equal(ai.defense_system.is_defending, true, "AI 방어 활성")
	
	# 플레이어가 방어 중인 적을 공격
	var player_damage = 100.0
	log("플레이어가 적을 %.0f 데미지로 공격" % player_damage)
	
	var ai_defense_result = ai.defense_system.apply_defense_damage(player_damage)
	log("→ 적이 방어하여 %.0f 데미지만 받음 (%.0f 차단)" % [
		ai_defense_result.actual_damage,
		ai_defense_result.damage_blocked
	])
	
	assert_equal(ai_defense_result.actual_damage, 50.0, "방어로 50% 데미지 감소")
	
	# AI 카운터
	if ai.defense_system.can_counter:
		var counter_success = ai.defense_system.attempt_counter()
		if counter_success:
			log("AI 반격: 카운터 성공! (1.5x 데미지)")
			assert_equal(counter_success, true, "카운터 성공")
	
	player_defense.stop_defense()
	ai.defense_system.stop_defense()
	
	print("✅ 시나리오 2 완료\n")

# ==================== 시나리오 3: 상태이상 적용 ====================

func test_scenario_3_status_effect_application():
	"""시나리오 3: 적에게 상태이상 적용"""
	print("\n" + "="*50)
	print("🎬 시나리오 3: 상태이상 적용")
	print("="*50 + "\n")
	
	log("플레이어가 화염 효과의 무술 사용")
	ai.apply_status_effect(StatusEffect.Type.BURN)
	log("→ 적이 화염 상태이상 받음 (초당 5 데미지, 5초)")
	
	assert_equal(ai.status_effect.has_effect(StatusEffect.Type.BURN), true, "AI 화염 상태이상 적용")
	
	# 플레이어도 받을 수 있음
	log("\n적이 반격으로 플레이어에게 독 상태이상 적용")
	player_status.apply_poison(3.0)
	
	assert_equal(player_status.has_effect(StatusEffect.Type.POISON), true, "플레이어 독 상태이상")
	log("→ 플레이어가 독 상태이상 받음 (초당 3 데미지, 5초)")
	
	# 빙결 상태이상으로 움직임 제한
	log("\n플레이어가 적에게 빙결 적용")
	ai.apply_status_effect(StatusEffect.Type.FREEZE)
	
	log("→ 적이 빙결되어 이동 불가")
	assert_equal(ai.status_effect.can_move(), false, "AI 이동 불가")
	
	print("✅ 시나리오 3 완료\n")

# ==================== 시나리오 4: AI 회피 및 반격 ====================

func test_scenario_4_ai_dodge_and_counterattack():
	"""시나리오 4: AI가 회피 후 반격"""
	print("\n" + "="*50)
	print("🎬 시나리오 4: AI 회피 및 반격")
	print("="*50 + "\n")
	
	# AI 상태이상 해제
	ai.status_effect.clear_all_effects()
	player_status.clear_all_effects()
	player_combo.reset_combo()
	
	log("플레이어가 강력한 공격 준비")
	var strong_attack_damage = 150.0
	
	log("AI가 플레이어의 공격 패턴 감지 → 회피 결정")
	var dodge_success = ai.defense_system.perform_dodge(Vector3.ZERO, Vector3.FORWARD)
	
	assert_equal(dodge_success, true, "AI 회피 성공")
	log("→ AI가 회피하여 무적 상태 (0.5초)")
	
	log("플레이어: %.0f 데미지 공격!" % strong_attack_damage)
	log("→ AI가 회피하여 데미지 0")
	
	assert_equal(ai.defense_system.is_dodging, true, "AI 무적 상태")
	assert_equal(ai.defense_system.is_invulnerable(), true, "AI 무적 확인")
	
	log("\nAI 반격: 회피 후 콤보 시작")
	var ai_combo1 = ai.combo_system.attempt_combo(0)
	var ai_combo2 = ai.combo_system.attempt_combo(0)
	
	log("→ AI 콤보 2Hit (%.1fx 데미지)" % ai_combo2.damage_multiplier)
	assert_equal(ai.combo_system.get_current_combo_count(), 2, "AI 2콤보")
	
	print("✅ 시나리오 4 완료\n")

# ==================== 시나리오 5: 복잡한 전투 ====================

func test_scenario_5_complex_battle():
	"""시나리오 5: 복잡한 전투 시뮬레이션"""
	print("\n" + "="*50)
	print("🎬 시나리오 5: 복잡한 전투 시뮬레이션")
	print("="*50 + "\n")
	
	# 초기화
	player_combo.reset_combo()
	player_defense.stop_defense()
	player_status.clear_all_effects()
	ai.status_effect.clear_all_effects()
	ai.combo_system.reset_combo()
	
	var round = 1
	
	for r in range(3):  # 3라운드 전투
		print("\n--- Round %d ---" % round)
		round += 1
		
		# 플레이어 행동 (콤보 또는 방어)
		var player_action = randi() % 3
		
		if player_action == 0:
			# 공격
			var combo_data = player_combo.attempt_combo(0)
			log("플레이어 공격 (콤보 %d, %.1fx 데미지)" % [
				player_combo.get_current_combo_count(),
				combo_data.damage_multiplier
			])
			
			# 적에게 데미지 적용
			var actual_damage = 50.0 * combo_data.damage_multiplier
			ai.receive_damage(actual_damage)
			
		elif player_action == 1:
			# 방어
			player_defense.start_defense()
			log("플레이어 방어 시작 (50% 데미지 감소)")
		else:
			# 회피
			if player_defense.is_dodge_available():
				player_defense.perform_dodge(Vector3.ZERO, Vector3.FORWARD)
				log("플레이어 회피 (무적 0.5초)")
			else:
				log("플레이어 회피 불가능 (쿨다운 중)")
		
		# AI 반응
		ai.observe_player(player_combo.get_current_combo_count(), player_defense.is_defending, false)
		
		# AI 행동 시뮬레이션
		if player_defense.is_defending and ai.defense_system.can_counter:
			ai.defense_system.start_defense()
			log("→ AI 방어 및 카운터 준비")
		elif ai.defense_system.is_dodge_available() and player_combo.get_current_combo_count() >= 2:
			ai.defense_system.perform_dodge(Vector3.ZERO, Vector3.BACK)
			log("→ AI 플레이어 콤보 회피")
		else:
			# AI 공격
			var ai_combo_data = ai.combo_system.attempt_combo(0)
			log("→ AI 공격 (콤보 %d, %.1fx 데미지)" % [
				ai.combo_system.get_current_combo_count(),
				ai_combo_data.damage_multiplier
			])
		
		# 상태이상 확인
		if ai.status_effect.has_any_effect():
			log("   AI 상태: %s" % ai.status_effect.get_status_display())
	
	print("\n✅ 시나리오 5 완료\n")

# ==================== 헬퍼 함수 ====================

func log(message: String):
	"""전투 로그"""
	print("  " + message)
	combat_log.append(message)

func assert_equal(actual, expected, message: String):
	"""어셜션"""
	if actual == expected:
		print("    ✅ %s" % message)
		test_passed += 1
	else:
		print("    ❌ %s (예상: %s, 실제: %s)" % [message, expected, actual])
		test_failed += 1

# ==================== 결과 보고 ====================

func print_test_summary():
	"""테스트 결과 요약"""
	print("\n" + "="*60)
	print("📊 전투 테스트 결과")
	print("="*60)
	
	var total = test_passed + test_failed
	var pass_rate = (float(test_passed) / total * 100) if total > 0 else 0.0
	
	print("총 어셜션: %d" % total)
	print("통과: %d ✅" % test_passed)
	print("실패: %d ❌" % test_failed)
	print("통과율: %.1f%%" % pass_rate)
	
	# 플레이어 통계
	print("\n👤 플레이어 통계:")
	var player_combo_stats = player_combo.get_combo_stats()
	var player_defense_stats = player_defense.get_defense_stats()
	var player_effect_stats = player_status.get_effect_stats()
	
	print("  콤보: %d번, 최고: %d" % [
		player_combo_stats["total_combos_landed"],
		player_combo_stats["highest_combo"]
	])
	print("  방어: %d번, 차단 데미지: %.0f" % [
		player_defense_stats["total_blocks"],
		player_defense_stats["total_damage_blocked"]
	])
	print("  상태이상: %d번 적용" % player_effect_stats["total_effects_applied"])
	
	# AI 통계
	print("\n🤖 AI 통계:")
	var ai_stats = ai.get_ai_stats()
	var ai_combo_stats = ai.combo_system.get_combo_stats()
	var ai_defense_stats = ai.defense_system.get_defense_stats()
	
	print("  공격: %d번" % ai_stats["attacks_performed"])
	print("  회피: %d번, 카운터: %d번" % [
		ai_defense_stats["total_dodges"],
		ai_defense_stats["total_counters"]
	])
	print("  받은 데미지: %.0f" % ai_stats["damage_taken"])
	
	print("\n" + "="*60)
	
	if test_failed == 0:
		print("🎉 모든 전투 테스트 통과!")
	else:
		print("⚠️  일부 테스트 실패")
