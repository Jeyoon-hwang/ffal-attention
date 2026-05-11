extends Node

# ⚡ NEXUS Day 5: 콤보 & 방어 & 상태이상 통합 테스트
# ComboSystem + DefenseSystem + StatusEffect 검증

class_name TestDay5ComboDefense

var combo_system: ComboSystem
var defense_system: DefenseSystem
var status_effect: StatusEffect

var test_results = []
var test_passed = 0
var test_failed = 0

func _ready():
	"""테스트 시작"""
	print("\n" + "="*60)
	print("🧪 NEXUS Day 5: 콤보 & 방어 & 상태이상 통합 테스트")
	print("="*60 + "\n")
	
	# 시스템 초기화
	combo_system = ComboSystem.new()
	add_child(combo_system)
	
	defense_system = DefenseSystem.new()
	add_child(defense_system)
	
	status_effect = StatusEffect.new()
	add_child(status_effect)
	
	# 테스트 실행
	run_all_tests()
	
	# 결과 보고
	print_test_summary()
	
	# 자동 종료
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

# ==================== 테스트 실행 ====================

func run_all_tests():
	"""모든 테스트 실행"""
	test_combo_system()
	test_defense_system()
	test_status_effect_system()
	test_integration()

# ==================== 콤보 시스템 테스트 ====================

func test_combo_system():
	"""콤보 시스템 테스트"""
	print("\n🔥 콤보 시스템 테스트\n")
	
	# Test 1: 기본 콤보 생성
	assert_equal(combo_system.get_current_combo_count(), 0, "초기 콤보 카운트는 0")
	
	var combo1 = combo_system.attempt_combo(0)  # 슬롯 0 사용
	assert_equal(combo_system.get_current_combo_count(), 1, "첫 번째 사용 후 콤보 1")
	assert_equal(combo1.combo_count, 1, "ComboData에 콤보 1 기록")
	assert_equal(combo1.damage_multiplier, 1.0, "1콤보는 1.0배 데미지")
	
	# Test 2: 같은 무술로 콤보 연쇄
	var combo2 = combo_system.attempt_combo(0)
	assert_equal(combo_system.get_current_combo_count(), 2, "같은 무술로 2콤보")
	assert_equal(combo2.damage_multiplier, 1.2, "2콤보는 1.2배 데미지")
	
	var combo3 = combo_system.attempt_combo(0)
	assert_equal(combo_system.get_current_combo_count(), 3, "3콤보 달성")
	assert_equal(combo3.damage_multiplier, 1.4, "3콤보는 1.4배 데미지")
	
	# Test 3: 에너지 비용 증가
	assert_equal(combo1.energy_cost_multiplier, 1.0, "1콤보 에너지 1.0배")
	assert_equal(combo2.energy_cost_multiplier, 1.05, "2콤보 에너지 1.05배")
	assert_equal(combo3.energy_cost_multiplier, 1.1, "3콤보 에너지 1.1배")
	
	# Test 4: 다른 무술로 초기화
	var combo4 = combo_system.attempt_combo(1)  # 슬롯 1 사용
	assert_equal(combo_system.get_current_combo_count(), 1, "다른 무술 사용 후 콤보 초기화")
	
	# Test 5: 콤보 보너스 데미지
	assert_equal(combo1.combo_bonus_damage, 0.0, "1콤보는 보너스 없음")
	assert_equal(combo2.combo_bonus_damage, 8.0, "2콤보는 +8 데미지 (5+1*3)")
	assert_equal(combo3.combo_bonus_damage, 11.0, "3콤보는 +11 데미지 (5+2*3)")
	
	# Test 6: 경직 배수
	assert_equal(combo1.stagger_multiplier, 1.0, "1콤보 경직 1.0배")
	assert_equal(combo3.stagger_multiplier, 1.3, "3콤보 경직 1.3배")
	
	print("✅ 콤보 시스템 테스트 완료!\n")

# ==================== 방어 시스템 테스트 ====================

func test_defense_system():
	"""방어 시스템 테스트"""
	print("\n🛡️  방어 시스템 테스트\n")
	
	# Test 1: 방어 시작/종료
	assert_equal(defense_system.is_defending, false, "초기 방어 상태 OFF")
	var result = defense_system.start_defense()
	assert_equal(result, true, "방어 시작 성공")
	assert_equal(defense_system.is_defending, true, "방어 상태 ON")
	
	# Test 2: 방어 중 데미지 감소
	var damage_result = defense_system.apply_defense_damage(100.0)
	assert_equal(damage_result.was_defended, true, "방어 중 데미지 감소됨")
	assert_equal(damage_result.actual_damage, 50.0, "100 데미지 → 50으로 감소")
	assert_equal(damage_result.damage_blocked, 50.0, "50 차단됨")
	
	# Test 3: 방어 해제
	defense_system.stop_defense()
	assert_equal(defense_system.is_defending, false, "방어 해제됨")
	
	# Test 4: 방어 없을 때 데미지
	var damage_result2 = defense_system.apply_defense_damage(100.0)
	assert_equal(damage_result2.was_defended, false, "방어 없음")
	assert_equal(damage_result2.actual_damage, 100.0, "풀 데미지")
	
	# Test 5: 회피 가능 여부
	assert_equal(defense_system.is_dodge_available(), true, "초기 회피 가능")
	var dodge_success = defense_system.perform_dodge(Vector3.ZERO, Vector3.FORWARD)
	assert_equal(dodge_success, true, "회피 성공")
	assert_equal(defense_system.is_dodging, true, "회피 중")
	assert_equal(defense_system.is_dodge_available(), false, "회피 중에는 불가")
	
	# Test 6: 무적 상태
	assert_equal(defense_system.is_invulnerable(), true, "회피 중 무적")
	assert_equal(defense_system.get_damage_reduction_multiplier(), 0.0, "회피 중 0% 데미지")
	
	# Test 7: 카운터
	defense_system.start_defense()
	var counter = defense_system.attempt_counter()
	assert_equal(counter, true, "카운터 성공")
	
	print("✅ 방어 시스템 테스트 완료!\n")

# ==================== 상태이상 테스트 ====================

func test_status_effect_system():
	"""상태이상 시스템 테스트"""
	print("\n💫 상태이상 시스템 테스트\n")
	
	# Test 1: 상태이상 적용
	assert_equal(status_effect.has_any_effect(), false, "초기 상태이상 없음")
	var result = status_effect.apply_effect(StatusEffect.Type.BURN, 5.0)
	assert_equal(result, true, "화염 상태이상 적용 성공")
	assert_equal(status_effect.has_effect(StatusEffect.Type.BURN), true, "화염 활성")
	
	# Test 2: 같은 상태이상 중복 적용
	var result2 = status_effect.apply_effect(StatusEffect.Type.BURN, 5.0)
	assert_equal(result2, true, "같은 상태이상 재적용 (지속시간 갱신)")
	
	# Test 3: 다른 상태이상 추가
	status_effect.apply_effect(StatusEffect.Type.SLOW)
	assert_equal(status_effect.has_effect(StatusEffect.Type.SLOW), true, "둔화 추가됨")
	
	# Test 4: 활성 상태이상 목록
	var effects = status_effect.get_active_effects()
	assert_equal(effects.size(), 2, "2개 상태이상 활성")
	
	# Test 5: 특정 상태이상 제거
	status_effect.remove_effect(StatusEffect.Type.BURN)
	assert_equal(status_effect.has_effect(StatusEffect.Type.BURN), false, "화염 제거됨")
	assert_equal(status_effect.has_effect(StatusEffect.Type.SLOW), true, "둔화는 유지")
	
	# Test 6: 속성 상태이상 (화염, 얼음 등)
	status_effect.clear_all_effects()
	status_effect.apply_burning(10.0)  # 초당 10 데미지
	status_effect.apply_freeze()
	
	assert_equal(status_effect.can_move(), false, "빙결 중 이동 불가")
	assert_equal(status_effect.can_attack(), false, "빙결 중 공격 불가")
	assert_equal(status_effect.get_speed_multiplier(), 0.0, "이동 속도 0배")
	
	# Test 7: 상태이상 이름
	var burn_name = status_effect.get_effect_name(StatusEffect.Type.BURN)
	assert_equal(burn_name, "화염", "상태이상 이름 조회")
	
	print("✅ 상태이상 시스템 테스트 완료!\n")

# ==================== 통합 테스트 ====================

func test_integration():
	"""통합 테스트 (콤보 + 방어 + 상태이상)"""
	print("\n🎯 통합 테스트 (시나리오)\n")
	
	# 시나리오: 플레이어가 콤보를 쌓으면서 적에게 데미지를 입음
	
	# 1. 콤보 쌓기
	var combo1 = combo_system.attempt_combo(0)
	var combo2 = combo_system.attempt_combo(0)
	var combo3 = combo_system.attempt_combo(0)
	
	print("플레이어: 3콤보 콤보를 쌓음 (%.1f배 데미지)" % combo3.damage_multiplier)
	
	# 2. 적이 공격 → 플레이어가 방어
	var incoming_damage = 50.0
	defense_system.start_defense()
	var defense_result = defense_system.apply_defense_damage(incoming_damage)
	
	print("적: %.0f 데미지 공격" % incoming_damage)
	print("플레이어: 방어로 %.0f 데미지만 받음 (%.0f 차단)" % [
		defense_result.actual_damage,
		defense_result.damage_blocked
	])
	
	# 3. 적이 화염 공격 → 플레이어가 화염 상태이상
	status_effect.apply_burning(5.0)
	print("적: 화염 공격! 플레이어에게 화염 상태이상 적용")
	
	# 4. 상태이상 확인
	print("플레이어 상태: %s" % status_effect.get_status_display())
	
	# 5. 회피로 탈출
	defense_system.stop_defense()
	defense_system.perform_dodge(Vector3.ZERO, Vector3.FORWARD)
	print("플레이어: 회피로 탈출! (무적 상태)")
	
	print("✅ 통합 테스트 완료!\n")

# ==================== 어셜션 헬퍼 ====================

func assert_equal(actual, expected, message: String):
	"""어셜션"""
	if actual == expected:
		print("✅ %s" % message)
		test_passed += 1
		test_results.append({"passed": true, "message": message})
	else:
		print("❌ %s (예상: %s, 실제: %s)" % [message, expected, actual])
		test_failed += 1
		test_results.append({"passed": false, "message": message, "expected": expected, "actual": actual})

# ==================== 결과 보고 ====================

func print_test_summary():
	"""테스트 결과 요약"""
	print("\n" + "="*60)
	print("📊 테스트 결과 요약")
	print("="*60)
	
	var total = test_passed + test_failed
	var pass_rate = (float(test_passed) / total * 100) if total > 0 else 0.0
	
	print("총 테스트: %d" % total)
	print("통과: %d ✅" % test_passed)
	print("실패: %d ❌" % test_failed)
	print("통과율: %.1f%%" % pass_rate)
	
	if test_failed > 0:
		print("\n❌ 실패한 테스트:")
		for result in test_results:
			if not result["passed"]:
				print("  - %s" % result["message"])
	
	print("\n" + "="*60)
	
	# 통계
	print("\n📈 시스템 통계\n")
	
	var combo_stats = combo_system.get_combo_stats()
	print("콤보 통계:")
	print("  - 총 콤보: %d" % combo_stats["total_combos_landed"])
	print("  - 최고 콤보: %d" % combo_stats["highest_combo"])
	print("  - 콤보 데미지: %.0f" % combo_stats["total_damage_from_combos"])
	
	var defense_stats = defense_system.get_defense_stats()
	print("\n방어 통계:")
	print("  - 총 방어: %d" % defense_stats["total_blocks"])
	print("  - 차단 데미지: %.0f" % defense_stats["total_damage_blocked"])
	print("  - 방어 파괴: %d" % defense_stats["defense_breaks"])
	print("  - 총 회피: %d" % defense_stats["total_dodges"])
	print("  - 카운터: %d" % defense_stats["total_counters"])
	
	var effect_stats = status_effect.get_effect_stats()
	print("\n상태이상 통계:")
	print("  - 적용된 상태이상: %d" % effect_stats["total_effects_applied"])
	print("  - 누적 효과 데미지: %.0f" % effect_stats["total_damage_from_effects"])
	
	print("\n" + "="*60)
	
	if test_failed == 0:
		print("\n🎉 모든 테스트 통과! Day 5 성공!")
	else:
		print("\n⚠️  일부 테스트 실패. 검토 필요.")
