## TestCombat.gd - 기본 전투 테스트 스크립트
## Week 1 프로토타입 검증

extends Node

func _ready() -> void:
	print("\n" + "=" * 60)
	print("🎮 NEXUS v2 - Week 1 Day 1-2 테스트 시작")
	print("=" * 60 + "\n")
	
	# 테스트 1: 캐릭터 생성
	test_character_creation()
	
	# 테스트 2: 무술 시스템
	test_martial_art_system()
	
	# 테스트 3: 플레이어 시스템
	test_player_system()
	
	# 테스트 4: 적 시스템
	test_enemy_system()
	
	# 테스트 5: 전투 시스템
	test_combat_system()
	
	print("\n" + "=" * 60)
	print("✅ 모든 테스트 완료!")
	print("=" * 60 + "\n")

# ===== 테스트 1: 캐릭터 생성 =====

func test_character_creation() -> void:
	print("\n[테스트 1] 캐릭터 생성")
	print("-" * 40)
	
	var character = Character.new()
	character.character_name = "테스트 캐릭터"
	character.level = 1
	character.max_hp = 100
	character.current_hp = 100
	
	print("✓ 캐릭터 생성: %s" % character.character_name)
	print("  - 레벨: %d" % character.level)
	print("  - HP: %d/%d" % [character.current_hp, character.max_hp])
	
	# 스탯 확인
	print("  - STR: %d, DEX: %d, CON: %d" % [character.stats["STR"], character.stats["DEX"], character.stats["CON"]])
	
	# 데미지 처리 테스트
	character.take_damage(20)
	assert(character.current_hp == 80, "데미지 처리 오류")
	print("✓ 데미지 처리: 20 손상 → HP 80")
	
	# 회복 테스트
	character.restore_hp(10)
	assert(character.current_hp == 90, "회복 처리 오류")
	print("✓ 회복: 10 회복 → HP 90")

# ===== 테스트 2: 무술 시스템 =====

func test_martial_art_system() -> void:
	print("\n[테스트 2] 무술 시스템")
	print("-" * 40)
	
	# 무술 생성
	var martial = MartialArt.new()
	martial.martial_id = "test_martial"
	martial.martial_name = "테스트 무술"
	martial.base_damage = 10
	martial.energy_cost = 20
	martial.str_scaling = 0.5
	
	print("✓ 무술 생성: %s" % martial.martial_name)
	print("  - 기본 데미지: %d" % martial.base_damage)
	print("  - 에너지 비용: %d" % martial.energy_cost)
	
	# 데미지 계산
	var attacker = Character.new()
	attacker.stats["STR"] = 10
	attacker.stats["DEX"] = 8
	
	var damage = martial.calculate_damage(attacker)
	print("✓ 데미지 계산: %d (STR 보너스 포함)" % damage)
	
	# 부가 효과 테스트
	martial.effect = MartialArt.Effect.STUN
	martial.effect_chance = 1.0  # 100% 확률
	martial.effect_duration = 2.0
	
	var target = Character.new()
	var has_effect = martial.apply_effect(target)
	assert(has_effect, "부가 효과 적용 오류")
	print("✓ 부가 효과: 스턴 적용")

# ===== 테스트 3: 플레이어 시스템 =====

func test_player_system() -> void:
	print("\n[테스트 3] 플레이어 시스템")
	print("-" * 40)
	
	var player = Player.new()
	player.character_name = "플레이어"
	player.level = 1
	player.max_hp = 100
	player.current_hp = 100
	player.max_energy = 100
	player.current_energy = 100
	
	print("✓ 플레이어 생성: %s" % player.character_name)
	
	# 무술 슬롯 초기화
	for i in range(5):
		player.martial_arts.append(null)
	
	# 무술 추가
	var martial = MartialArt.new()
	martial.martial_id = "martial_test"
	martial.martial_name = "테스트 권법"
	martial.energy_cost = 10
	
	player.add_martial_art(martial, 0)
	assert(player.martial_arts[0] != null, "무술 슬롯 오류")
	print("✓ 무술 슬롯 0에 추가")
	
	# 에너지 사용
	var success = player.use_energy(10)
	assert(success and player.current_energy == 90, "에너지 사용 오류")
	print("✓ 에너지 사용: 10 소비 → 남은 에너지 90")
	
	# 에너지 부족 테스트
	success = player.use_energy(100)
	assert(not success, "에너지 부족 처리 오류")
	print("✓ 에너지 부족 처리: 100 필요 시 실패")

# ===== 테스트 4: 적 시스템 =====

func test_enemy_system() -> void:
	print("\n[테스트 4] 적 시스템")
	print("-" * 40)
	
	var enemy = Enemy.new()
	enemy.character_name = "테스트 몬스터"
	enemy.level = 1
	enemy.max_hp = 50
	enemy.current_hp = 50
	enemy.max_energy = 50
	enemy.current_energy = 50
	
	print("✓ 적 생성: %s (레벨 %d)" % [enemy.character_name, enemy.level])
	print("  - HP: %d/%d" % [enemy.current_hp, enemy.max_hp])
	
	# AI 컨트롤러 확인
	assert(enemy.ai_controller != null, "AI 컨트롤러 초기화 오류")
	print("✓ AI 컨트롤러 생성 (레벨 %d)" % enemy.ai_controller.ai_level)
	
	# 타겟 설정
	var player = Player.new()
	player.character_name = "플레이어"
	enemy.ai_controller.set_target(player)
	assert(enemy.ai_controller.target == player, "타겟 설정 오류")
	print("✓ 타겟 설정: %s" % player.character_name)

# ===== 테스트 5: 전투 시스템 =====

func test_combat_system() -> void:
	print("\n[테스트 5] 전투 시스템")
	print("-" * 40)
	
	# 플레이어 생성
	var player = Player.new()
	player.character_name = "플레이어"
	player.level = 1
	player.max_hp = 100
	player.current_hp = 100
	player.max_energy = 100
	player.current_energy = 100
	
	# 무술 슬롯
	for i in range(5):
		player.martial_arts.append(null)
	
	# 무술 생성
	var martial = MartialArt.new()
	martial.martial_id = "martial_test"
	martial.martial_name = "테스트 권법"
	martial.base_damage = 10
	martial.energy_cost = 20
	martial.str_scaling = 0.5
	
	player.add_martial_art(martial, 0)
	
	# 적 생성
	var enemy = Enemy.new()
	enemy.character_name = "테스트 몬스터"
	enemy.level = 1
	enemy.max_hp = 50
	enemy.current_hp = 50
	enemy.max_energy = 50
	enemy.current_energy = 50
	
	enemy.add_martial_art(martial, 0)
	
	# 전투 시스템
	var combat = CombatSystem.new()
	combat.start_combat(player, enemy)
	assert(combat.is_combat_active, "전투 시작 오류")
	print("✓ 전투 시작")
	
	# 공격 처리
	var damage = combat.apply_martial_attack(player, martial, enemy)
	assert(damage > 0, "데미지 계산 오류")
	assert(enemy.current_hp < 50, "데미지 적용 오류")
	print("✓ 플레이어 공격: %d 데미지 적용" % damage)
	
	# 로그 확인
	var logs = combat.get_log()
	assert(logs.size() > 0, "전투 로그 오류")
	print("✓ 전투 로그: %d항목" % logs.size())

# ===== 총평 =====

func print_summary() -> void:
	print("\n[요약]")
	print("✅ Character.gd - 캐릭터 시스템")
	print("✅ MartialArt.gd - 무술 시스템")
	print("✅ Player.gd - 플레이어 제어")
	print("✅ Enemy.gd - 적 기본 시스템")
	print("✅ AIController.gd - AI 상태 머신")
	print("✅ CombatSystem.gd - 전투 엔진")
	print("✅ DataLoader.gd - 데이터 로드")
	print("✅ GameManager.gd - 게임 관리자")
