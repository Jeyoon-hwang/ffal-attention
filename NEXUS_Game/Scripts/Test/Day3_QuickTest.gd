## Day 3 Quick Test - 무술 엔진 & 플레이어 전투 빠른 검증
## 목표: MartialArtEngine + Player + CombatSystem 동작 확인
## 에러: 0건 유지

extends Node

func _ready():
	print("\n🔥 Day 3 Quick Test 시작!")
	print("=" * 60)
	
	# Test 1: MartialArtEngine 초기화
	test_martial_art_engine()
	
	# Test 2: Player 초기화
	test_player_initialization()
	
	# Test 3: Player vs Enemy 전투 시뮬레이션
	test_player_vs_enemy()
	
	print("\n" + "=" * 60)
	print("✅ Day 3 Quick Test 완료!")
	get_tree().quit()


## Test 1: MartialArtEngine 검증
func test_martial_art_engine():
	print("\n📊 Test 1: MartialArtEngine")
	print("-" * 60)
	
	var engine = MartialArtEngine.new()
	engine._ready()
	
	print(f"✅ 기본 동작 개수: {engine.base_motions.size()} (목표: 100+)")
	print(f"✅ 데이터베이스 무술: {engine.martial_arts_db.size()} (기본 무술)")
	
	# Test 1-1: 무술 생성
	var created_count = 0
	for i in range(10):
		var martial = engine.generate_random_martial()
		if martial:
			created_count += 1
	
	print(f"✅ 랜덤 무술 생성: {created_count}/10 성공")
	
	# Test 1-2: 기본 무술 가져오기
	if engine.martial_arts_db.has("basic_punch"):
		var punch = engine.martial_arts_db["basic_punch"]
		print(f"✅ 기본 펀치: {punch.martial_name} (데미지: {punch.base_damage}, 에너지: {punch.energy_cost})")
	else:
		print("❌ 기본 펀치 없음!")


## Test 2: Player 초기화
func test_player_initialization():
	print("\n👤 Test 2: Player Initialization")
	print("-" * 60)
	
	var player = Player.new()
	player._ready()
	
	print(f"✅ 플레이어: {player.player_name} (Lv. {player.level})")
	print(f"✅ HP: {player.current_hp}/{player.max_hp}")
	print(f"✅ 에너지: {player.current_energy}/{player.max_energy}")
	print(f"✅ 능력치: STR {player.stats['STR']}, DEX {player.stats['DEX']}, CON {player.stats['CON']}")
	print(f"✅ 무술 슬롯: {player.martial_slots.size()}/5")
	print(f"✅ 스킬 포인트: {player.skill_points}")


## Test 3: Player vs Enemy 전투
func test_player_vs_enemy():
	print("\n⚔️ Test 3: Player vs Enemy Combat (10턴 시뮬레이션)")
	print("-" * 60)
	
	var engine = MartialArtEngine.new()
	engine._ready()
	
	var player = Player.new()
	player._ready()
	
	# 플레이어에게 기본 무술 추가
	if engine.martial_arts_db.has("basic_punch"):
		player.martial_slots[0] = engine.martial_arts_db["basic_punch"]
	if engine.martial_arts_db.has("kick"):
		player.martial_slots[1] = engine.martial_arts_db["kick"]
	if engine.martial_arts_db.has("guard"):
		player.martial_slots[2] = engine.martial_arts_db["guard"]
	
	var enemy = Enemy.new()
	enemy.max_hp = 50
	enemy.current_hp = 50
	enemy.current_energy = 30
	enemy.ai_level = 1
	enemy.player_name = "좀비"
	
	var combat_system = CombatSystem.new()
	combat_system._ready()
	
	print(f"\n플레이어: {player.player_name} vs 적: {enemy.player_name}")
	print(f"플레이어 HP: {player.current_hp} | 적 HP: {enemy.current_hp}\n")
	
	# 전투 시뮬레이션 (10턴)
	for turn in range(10):
		if player.is_dead or enemy.current_hp <= 0:
			break
		
		print(f"--- Turn {turn + 1} ---")
		
		# 플레이어 공격
		if not player.is_dead:
			var result = player.execute_martial_art(0)  # 기본 펀치
			if result.get("success", false):
				var damage = result.get("damage", 0)
				var critical = result.get("critical", false)
				var crit_text = " (크리티컬!)" if critical else ""
				print(f"  플레이어 공격: {damage:.0f} 데미지{crit_text}")
				enemy.current_hp -= int(damage)
				enemy.current_hp = max(0, enemy.current_hp)
			else:
				print(f"  플레이어 공격 실패: {result.get('reason', '알 수 없음')}")
		
		# 적 공격
		if enemy.current_hp > 0:
			var enemy_damage = randi_range(5, 15)
			print(f"  적 공격: {enemy_damage} 데미지")
			player.take_damage(float(enemy_damage), enemy)
		
		print(f"  HP: 플레이어 {player.current_hp} | 적 {enemy.current_hp}")
	
	# 결과
	print("\n📊 전투 결과:")
	if enemy.current_hp <= 0:
		print("✅ 플레이어 승리!")
	elif player.is_dead:
		print("❌ 플레이어 사망!")
	else:
		print("⚠️ 전투 진행 중...")
	
	print(f"최종 HP: 플레이어 {player.current_hp} | 적 {enemy.current_hp}")
