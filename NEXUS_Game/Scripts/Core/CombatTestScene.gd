extends Node3D
"""
전투 시스템 통합 테스트 씬
- 무술 엔진
- 플레이어 전투
- 적 AI 테스트
"""

# 전투 시스템
var player_combat: CombatSystem
var enemy_combat: CombatSystem
var martial_engine: MartialArtEngine

# 적
var enemy: EnemyAI

# 테스트 상태
var is_testing: bool = true
var test_step: int = 0

func _ready():
	print("\n" + "="*60)
	print("🥋 NEXUS 무술 창조 게임 - 전투 시스템 테스트")
	print("="*60 + "\n")
	
	# 1. 무술 엔진 초기화
	print("[Step 1] 무술 엔진 초기화")
	martial_engine = MartialArtEngine.new()
	martial_engine._ready()
	print("✅ 무술 엔진 준비 완료\n")
	
	# 2. 플레이어 전투 시스템 초기화
	print("[Step 2] 플레이어 전투 시스템 초기화")
	player_combat = CombatSystem.new()
	player_combat.add_child(self)
	player_combat._ready()
	player_combat.owner_stats = {
		"str": 12,
		"dex": 10,
		"con": 11,
		"int": 9,
		"wis": 10,
		"cha": 9
	}
	print("✅ 플레이어 전투 시스템 준비 완료\n")
	
	# 3. 플레이어 무술 슬롯 설정
	print("[Step 3] 플레이어 무술 슬롯 설정")
	_setup_player_martials()
	print("✅ 플레이어 무술 슬롯 설정 완료\n")
	
	# 4. 적 AI 초기화
	print("[Step 4] 적 AI 초기화")
	enemy = EnemyAI.new()
	add_child(enemy)
	enemy.ai_level = EnemyAI.AILevel.NOVICE
	enemy.difficulty = 1.0
	enemy._ready()
	
	# 적 무술 슬롯 설정
	_setup_enemy_martials()
	print("✅ 적 AI 준비 완료\n")
	
	# 5. 전투 시뮬레이션 시작
	print("[Step 5] 전투 시뮬레이션 시작\n")
	print("="*60)
	_run_combat_simulation()

## 플레이어 무술 슬롯 설정
func _setup_player_martials() -> void:
	# 기본 무술 4가지 추가
	var martial_configs = [
		{"name": "천권 (기본 펀치)", "damage": 10.0, "cost": 3, "type": 0},
		{"name": "호발 (발차기)", "damage": 15.0, "cost": 5, "type": 1},
		{"name": "금강장 (방어)", "damage": 0.0, "cost": 2, "type": 2},
		{"name": "폭렬권 (강펀치)", "damage": 25.0, "cost": 8, "type": 3},
	]
	
	for i in range(martial_configs.size()):
		var config = martial_configs[i]
		var martial = MartialArt.new()
		martial.martial_id = f"player_martial_{i}"
		martial.martial_name = config["name"]
		martial.base_damage = config["damage"]
		martial.energy_cost = config["cost"]
		martial.animation_name = f"attack_{i}"
		
		# 방어 무술
		if config["type"] == 2:
			martial.defense_type = MartialArt.DefenseType.GUARD
			martial.defense_level = 2
		
		martial_engine.add_martial_to_player(martial)
		print(f"  ✅ [{i}] {config['name']} (DMG:{config['damage']:.0f}, COST:{config['cost']})")

## 적 AI 무술 슬롯 설정
func _setup_enemy_martials() -> void:
	# 적도 4가지 기본 무술
	var martial_configs = [
		{"name": "좌권", "damage": 8.0, "cost": 3},
		{"name": "우발", "damage": 12.0, "cost": 4},
		{"name": "회피", "damage": 0.0, "cost": 2},
		{"name": "광격", "damage": 20.0, "cost": 7},
	]
	
	for config in martial_configs:
		var martial = MartialArt.new()
		martial.martial_id = f"enemy_martial_{config['name']}"
		martial.martial_name = f"[적] {config['name']}"
		martial.base_damage = config["damage"]
		martial.energy_cost = config["cost"]
		
		enemy.combat_system.martial_art_engine.add_martial_to_player(martial)

## 전투 시뮬레이션
func _run_combat_simulation() -> void:
	print("\n🔥 전투 시뮬레이션 시작!\n")
	
	print(f"플레이어: HP {int(player_combat.current_hp)} | Energy {int(player_combat.current_energy)}")
	print(f"적 (Level 2):  HP {int(enemy.current_hp)} | Energy {int(enemy.current_energy)}\n")
	
	# 10라운드 전투 시뮬레이션
	var turn = 1
	while turn <= 10 and player_combat.current_hp > 0 and enemy.current_hp > 0:
		print(f"\n--- 라운드 {turn} ---")
		
		# 플레이어 공격 (랜덤 무술)
		var player_martial_slot = randi() % 4
		var success = player_combat.attack(player_martial_slot)
		
		if success:
			# 데미지 계산 & 적에게 전달
			var martial = martial_engine.get_player_martial(player_martial_slot)
			var damage = martial.calculate_damage(player_combat.owner_stats)
			enemy.take_damage(damage)
			
			print(f"플레이어: {martial.martial_name} 명중! {damage:.1f} 데미지")
			print(f"→ 적 HP: {int(enemy.current_hp)}")
		
		# 적 반격 (AI)
		if enemy.current_hp > 0:
			await get_tree().create_timer(0.5).timeout  # 약간의 딜레이
			
			enemy.current_state = EnemyAI.AIState.ATTACK
			var enemy_martial_slot = randi() % 3  # 0-2 범위
			
			if enemy.combat_system.attack(enemy_martial_slot):
				var enemy_martial = enemy.combat_system.martial_art_engine.get_player_martial(enemy_martial_slot)
				var enemy_damage = enemy_martial.calculate_damage({"str": 10, "dex": 10})
				player_combat.take_damage(enemy_damage)
				
				print(f"적: {enemy_martial.martial_name} 명중! {enemy_damage:.1f} 데미지")
				print(f"→ 플레이어 HP: {int(player_combat.current_hp)}")
		
		# 상태 출력
		print(f"\n📊 상태 업데이트:")
		print(f"  플레이어: HP {int(player_combat.current_hp)}/{int(player_combat.max_hp)} | Energy {int(player_combat.current_energy)}/{int(player_combat.max_energy)}")
		print(f"  적:      HP {int(enemy.current_hp)}/{int(enemy.max_hp)} | Energy {int(enemy.current_energy)}/{int(enemy.max_energy)}")
		
		turn += 1
		await get_tree().create_timer(1.0).timeout  # 라운드 사이 딜레이

	# 전투 결과
	print("\n" + "="*60)
	print("🏁 전투 시뮬레이션 종료\n")
	
	if player_combat.current_hp > 0:
		print(f"✅ 플레이어 승리! (남은 HP: {int(player_combat.current_hp)})")
	else:
		print(f"❌ 플레이어 패배 (남은 HP: {int(player_combat.current_hp)})")
	
	print(f"적: {int(enemy.current_hp)} HP\n")
	
	# 최종 통계
	print("📊 최종 전투 통계:")
	print(f"  라운드: {turn - 1}")
	print(f"  플레이어 최종 HP: {int(player_combat.current_hp)}/{int(player_combat.max_hp)}")
	print(f"  적 최종 HP: {int(enemy.current_hp)}/{int(enemy.max_hp)}")
	print(f"  플레이어 콤보 최대: {player_combat.combo_count}")
	
	print("\n" + "="*60)
	print("✨ 무술 엔진 & 전투 시스템 테스트 완료!")
	print("="*60 + "\n")

func _process(delta):
	# 메모리 상태 모니터링
	if is_testing:
		pass  # 테스트 진행 중
