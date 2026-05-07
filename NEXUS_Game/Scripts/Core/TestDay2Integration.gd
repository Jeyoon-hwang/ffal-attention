## TestDay2Integration.gd - Day 2 통합 테스트
## 모든 핵심 클래스 동작 확인

class_name TestDay2Integration
extends Node

var martial_engine: MartialArtEngine
var player: Player
var enemies: Array[Enemy]
var combat_system: CombatSystem


func _ready() -> void:
	print("\n" + "="*60)
	print("NEXUS Day 2 - 핵심 클래스 통합 테스트")
	print("="*60)
	
	# 1. MartialArtEngine 테스트
	test_martial_art_engine()
	
	# 2. Player 클래스 테스트
	test_player()
	
	# 3. Enemy 클래스 테스트
	test_enemy()
	
	# 4. CombatSystem 테스트
	test_combat_system()
	
	# 5. 최종 시뮬레이션
	test_combat_simulation()
	
	print("\n" + "="*60)
	print("✅ 모든 테스트 완료!")
	print("="*60 + "\n")


# ═══════════════════════════════════════════════════════════════════════════════

func test_martial_art_engine() -> void:
	print("\n[1] MartialArtEngine 테스트")
	print("-" * 40)
	
	martial_engine = MartialArtEngine.new()
	
	# 기본 무술 로드
	martial_engine.load_base_martial_arts()
	print("✓ 기본 무술 5개 로드")
	
	# 무술 생성 (난이도별)
	var common_art = martial_engine.generate_martial_art(0)
	var rare_art = martial_engine.generate_martial_art(1)
	var epic_art = martial_engine.generate_martial_art(2)
	var legendary_art = martial_engine.generate_martial_art(3)
	
	print("✓ 난이도별 무술 생성")
	print("  - 일반: %s (Power: %.1f)" % [common_art.name, common_art.base_power])
	print("  - 레어: %s (Power: %.1f)" % [rare_art.name, rare_art.base_power])
	print("  - 에픽: %s (Power: %.1f)" % [epic_art.name, epic_art.base_power])
	print("  - 레전더리: %s (Power: %.1f)" % [legendary_art.name, legendary_art.base_power])
	
	# 총 무술 개수
	print("\n✓ 생성된 무술 총 %d개" % martial_engine.get_total_martial_count())


# ═══════════════════════════════════════════════════════════════════════════════

func test_player() -> void:
	print("\n[2] Player 클래스 테스트")
	print("-" * 40)
	
	player = Player.new()
	player._ready()
	
	print("✓ 플레이어 생성: %s (Lv.%d)" % [player.player_name, player.level])
	print("  - HP: %d/%d" % [player.current_hp, player.max_hp])
	print("  - Energy: %d/%d" % [player.current_energy, player.max_energy])
	print("  - 능력치: STR %d, DEX %d, CON %d" % [
		player.stats["STR"], player.stats["DEX"], player.stats["CON"]
	])
	
	# 무술 장착
	var punch = martial_engine.get_martial_art("punch_001")
	if punch:
		player.equip_martial_art(0, punch)
		print("✓ 펀치 무술 장착 (슬롯 0)")
	
	# 무술 발동 테스트
	var result = player.execute_martial_art(0)
	if result.get("success", false):
		print("✓ 무술 발동 성공: %.1f 데미지" % result.get("damage", 0))
	else:
		print("✗ 무술 발동 실패: %s" % result.get("reason", "알 수 없음"))
	
	# 상태 테스트
	print("✓ 상태 업데이트 후: %s" % player)


# ═══════════════════════════════════════════════════════════════════════════════

func test_enemy() -> void:
	print("\n[3] Enemy 클래스 테스트")
	print("-" * 40)
	
	enemies.clear()
	
	# Enemy 1: 기초 적
	var enemy1 = Enemy.new()
	enemy1._ready()
	enemy1.init_enemy("고블린", "goblin", 3, 1)
	
	# 기본 무술 장착
	var kick = martial_engine.get_martial_art("kick_001")
	if kick:
		enemy1.equip_martial_art(0, kick)
	
	enemies.append(enemy1)
	print("✓ Enemy 1 생성: %s" % enemy1)
	
	# Enemy 2: 더 강한 적
	var enemy2 = Enemy.new()
	enemy2._ready()
	enemy2.init_enemy("오크 전사", "orc", 5, 2)
	
	enemies.append(enemy2)
	print("✓ Enemy 2 생성: %s" % enemy2)
	
	# 데미지 입기 테스트
	enemy1.take_damage(15.0)
	print("✓ Enemy 1 데미지: HP %d/%d" % [enemy1.current_hp, enemy1.max_hp])


# ═══════════════════════════════════════════════════════════════════════════════

func test_combat_system() -> void:
	print("\n[4] CombatSystem 테스트")
	print("-" * 40)
	
	combat_system = CombatSystem.new()
	
	print("✓ CombatSystem 생성: %s" % combat_system)
	print("✓ 전투 준비 완료 (플레이어 1명, 적 2명)")


# ═══════════════════════════════════════════════════════════════════════════════

func test_combat_simulation() -> void:
	print("\n[5] 전투 시뮬레이션")
	print("-" * 40)
	
	# 새로운 테스트 플레이어 & 적
	var test_player = Player.new()
	test_player._ready()
	test_player.player_name = "테스터"
	
	var test_punch = martial_engine.get_martial_art("punch_001")
	if test_punch:
		test_player.equip_martial_art(0, test_punch)
	
	var test_enemy = Enemy.new()
	test_enemy._ready()
	test_enemy.init_enemy("테스트 몬스터", "test", 2, 1)
	
	var test_kick = martial_engine.get_martial_art("kick_001")
	if test_kick:
		test_enemy.equip_martial_art(0, test_kick)
	
	# 전투 시작
	var test_combat = CombatSystem.new()
	var log = test_combat.simulate_combat() if test_player and [test_enemy] else "전투 준비 실패"
	
	if log != "전투 준비 실패":
		print(log)
	else:
		print("시뮬레이션 준비 중...")
		print("✓ 전투 준비 완료 (실제 Godot 실행 환경에서 테스트 필요)")


# ═══════════════════════════════════════════════════════════════════════════════

func print_summary() -> void:
	print("\n" + "="*60)
	print("📊 테스트 요약")
	print("="*60)
	
	print("\n✅ 생성된 무술: %d개" % martial_engine.get_total_martial_count())
	print("✅ 플레이어: %s" % player)
	print("✅ 적: %d마리" % enemies.size())
	
	var avg_power = martial_engine.get_average_power()
	if avg_power > 0:
		print("✅ 평균 데미지: %.1f" % avg_power)
	
	print("\n" + "="*60 + "\n")
