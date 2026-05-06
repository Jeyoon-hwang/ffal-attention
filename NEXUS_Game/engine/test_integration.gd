# NEXUS 통합 테스트 드라이버
# 모든 엔진 시스템을 검증하는 테스트
# Week 1, Day 1-2 테스트

extends Node

class_name TestIntegration

# ============================================================================
# 테스트 케이스
# ============================================================================

func test_all() -> void:
	print("\n" + "=" * 80)
	print("🧪 NEXUS 통합 테스트 시작 (Week 1, Day 1-2)")
	print("=" * 80)
	
	# 테스트 1: 무술 엔진
	test_martial_art_engine()
	
	# 테스트 2: 플레이어 전투 시스템
	test_player_combat()
	
	# 테스트 3: 적 AI 시스템
	test_enemy_ai()
	
	# 테스트 4: 전체 게임 루프
	test_game_loop()
	
	print("\n" + "=" * 80)
	print("✅ 모든 통합 테스트 완료!")
	print("=" * 80 + "\n")

# ============================================================================
# Test 1: 무술 엔진
# ============================================================================

func test_martial_art_engine() -> void:
	print("\n" + "-" * 80)
	print("📋 Test 1: 무술 엔진 (Martial Art Engine)")
	print("-" * 80)
	
	var engine = MartialArtEngine.new()
	engine.initialize_base_arts()
	
	print("\n✓ 무술 DB 초기화: %d개 무술 등록됨" % engine.martial_arts_db.size())
	
	# Test 1.1: 기본 무술 생성
	print("\n[1.1] 기본 무술 생성 테스트:")
	var art_slash = engine.create_martial_art("slash", [])
	engine.print_martial_art(art_slash)
	
	# Test 1.2: Modifier 적용 무술
	print("\n[1.2] Modifier 적용 무술 생성:")
	var art_quick_pierce = engine.create_martial_art("slash", ["quick", "pierce"])
	engine.print_martial_art(art_quick_pierce)
	
	# Test 1.3: 데미지 계산 검증
	print("\n[1.3] 데미지 계산 검증:")
	var stats = {
		"str": 20,
		"dex": 15,
		"int": 10
	}
	var dmg1 = engine.calculate_damage(art_slash, stats)
	var dmg2 = engine.calculate_damage(art_quick_pierce, stats)
	print("  - [베기] 데미지: %.1f" % dmg1)
	print("  - [빠른 관통 베기] 데미지: %.1f" % dmg2)
	
	assert(dmg1 > 0, "데미지가 0보다 커야 함")
	assert(dmg2 > 0, "데미지가 0보다 커야 함")
	print("✓ 데미지 계산 정상")
	
	# Test 1.4: 콤보 시스템
	print("\n[1.4] 콤보 시스템 테스트:")
	var combo_arts = [art_slash, art_quick_pierce, art_slash]
	var combo = engine.create_combo(combo_arts)
	var combo_dmg = engine.calculate_combo_damage(combo, stats)
	print("  - 3단계 콤보 데미지: %.1f (배수: %.2f)" % [combo_dmg, combo.damage_multiplier])
	
	assert(combo_dmg > dmg1 + dmg2, "콤보 데미지가 합산보다 커야 함")
	print("✓ 콤보 시스템 정상")
	
	# Test 1.5: 무술 검색
	print("\n[1.5] 무술 검색:")
	var found_art = engine.get_martial_art("slash_quick_pierce")
	if found_art:
		print("  ✓ [%s] 검색 성공" % found_art.name)
	else:
		print("  ✗ 무술 검색 실패")
		assert(false, "무술 검색이 작동해야 함")

# ============================================================================
# Test 2: 플레이어 전투 시스템
# ============================================================================

func test_player_combat() -> void:
	print("\n" + "-" * 80)
	print("⚔️ Test 2: 플레이어 전투 시스템")
	print("-" * 80)
	
	var engine = MartialArtEngine.new()
	engine.initialize_base_arts()
	
	var player = PlayerCombat.new()
	player.martial_engine = engine
	player._ready()
	
	print("\n✓ 플레이어 초기화 완료")
	
	# Test 2.1: 무술 장착
	print("\n[2.1] 무술 장착:")
	var equip_result = player.equip_martial_art("thrust")
	print("  ✓ 무술 장착 완료: %s" % player.equipped_arts)
	assert(equip_result, "무술 장착 실패")
	assert(player.equipped_arts.size() == 3, "3개 무술이 장착되어야 함 (slash + thrust + 초기값)")
	
	# Test 2.2: 공격 시뮬레이션
	print("\n[2.2] 공격 발동:")
	var art = player.use_martial_art(0)
	assert(art != null, "공격이 발동되어야 함")
	print("  ✓ 공격 발동: %s (%.0f 데미지)" % [art.name, player.martial_engine.calculate_damage(art, player.player_stats)])
	
	# Test 2.3: 쿨타임 검증
	print("\n[2.3] 쿨타임 검증:")
	var art2 = player.use_martial_art(0)
	assert(art2 == null, "쿨타임 중이므로 공격이 실패해야 함")
	print("  ✓ 쿨타임 정상 작동")
	
	# Test 2.4: MP 관리
	print("\n[2.4] MP 관리:")
	var initial_mp = player.mp
	player.mp = 0
	var art_no_mp = player.use_martial_art(0)
	assert(art_no_mp == null, "MP 부족이므로 공격 실패해야 함")
	player.mp = initial_mp
	print("  ✓ MP 관리 정상")
	
	# Test 2.5: 능력치 관리
	print("\n[2.5] 능력치 관리:")
	var before_str = player.player_stats["str"]
	player.add_stat("str", 5)
	var after_str = player.player_stats["str"]
	assert(after_str == before_str + 5, "능력치 증가 실패")
	print("  ✓ 능력치 증가: STR %d → %d" % [before_str, after_str])

# ============================================================================
# Test 3: 적 AI 시스템
# ============================================================================

func test_enemy_ai() -> void:
	print("\n" + "-" * 80)
	print("🤖 Test 3: 적 AI 시스템")
	print("-" * 80)
	
	var engine = MartialArtEngine.new()
	engine.initialize_base_arts()
	
	var player = PlayerCombat.new()
	player.martial_engine = engine
	player._ready()
	
	# Test 3.1: Level 1 AI
	print("\n[3.1] Level 1 (기본 AI) 테스트:")
	var ai1 = EnemyAI.new()
	ai1.martial_engine = engine
	ai1._ready()
	ai1.initialize(EnemyAI.AILevel.BASIC, player)
	ai1.print_ai_status()
	assert(ai1.ai_level == EnemyAI.AILevel.BASIC, "AI 레벨 설정 실패")
	print("  ✓ Level 1 AI 정상")
	
	# Test 3.2: Level 2 AI
	print("\n[3.2] Level 2 (전술 AI) 테스트:")
	var ai2 = EnemyAI.new()
	ai2.martial_engine = engine
	ai2._ready()
	ai2.initialize(EnemyAI.AILevel.TACTICAL, player)
	ai2.print_ai_status()
	print("  ✓ Level 2 AI 정상")
	
	# Test 3.3: Level 4 (보스) 초기화
	print("\n[3.3] Level 4 (마스터/보스 AI) 테스트:")
	var boss_ai = EnemyAI.new()
	boss_ai.martial_engine = engine
	boss_ai._ready()
	boss_ai.initialize_as_boss()
	boss_ai.print_ai_status()
	assert(boss_ai.hp == 200.0, "보스 HP 설정 실패")
	print("  ✓ 보스 AI 정상")
	
	# Test 3.4: AI 의사결정
	print("\n[3.4] AI 의사결정 로직:")
	ai1._make_decision()
	print("  ✓ AI 의사결정 실행 완료 (현재 상태: %s)" % ["IDLE", "PURSUING", "ATTACKING", "EVADING", "ENRAGED"][ai1.current_state])

# ============================================================================
# Test 4: 게임 루프
# ============================================================================

func test_game_loop() -> void:
	print("\n" + "-" * 80)
	print("🎮 Test 4: 전체 게임 루프 (3라운드 시뮬레이션)")
	print("-" * 80)
	
	var engine = MartialArtEngine.new()
	engine.initialize_base_arts()
	
	var player = PlayerCombat.new()
	player.martial_engine = engine
	player._ready()
	player.hp = 100.0
	
	var enemy = EnemyAI.new()
	enemy.martial_engine = engine
	enemy._ready()
	enemy.initialize(EnemyAI.AILevel.TACTICAL, player)
	
	print("\n초기 상태:")
	print("  - 플레이어: HP %.0f/%.0f" % [player.hp, player.max_hp])
	print("  - 적: HP %.0f/%.0f" % [enemy.hp, enemy.max_hp])
	
	# 3 라운드 시뮬레이션
	for round in range(1, 4):
		print("\n[라운드 %d]" % round)
		
		# 플레이어 공격
		if player.mp > 0:
			var art = player.use_martial_art(0)
			if art != null:
				var damage = engine.calculate_damage(art, player.player_stats)
				enemy.hp = max(0, enemy.hp - damage)
				print("  ► 플레이어 공격: %s (%.0f 데미지)" % [art.name, damage])
		
		# 적 반격
		enemy._make_decision()
		enemy._attempt_attack()
		
		# 상황
		print("  ► 상황: 플레이어 HP %.0f | 적 HP %.0f" % [player.hp, enemy.hp])
	
	print("\n✓ 게임 루프 시뮬레이션 완료")

# ============================================================================
# 메인 실행
# ============================================================================

func _ready() -> void:
	call_deferred("test_all")
