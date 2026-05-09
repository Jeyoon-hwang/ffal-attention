## Day8_FirstBossFight.gd - 첫 보스 전투 30라운드 자동 시뮬레이션
## 테스트 플레이어 vs 천산 검객

extends Node

class_name Day8FirstBossFight

# ╔═════════════════════════════════════════════════════════╗
# ║            테스트 플레이어 클래스                        ║
# ╚═════════════════════════════════════════════════════════╝

class TestPlayer:
	var name: String = "테스트 플레이어"
	var stats: Dictionary = {
		"STR": 10,
		"DEX": 10,
		"CON": 10,
		"INT": 8,
		"WIS": 8,
		"CHA": 5
	}
	
	var max_hp: int = 100
	var current_hp: int = 100
	var max_energy: int = 80
	var current_energy: int = 80
	
	var martial_slots: Array = []
	var total_damage_dealt: int = 0
	var total_damage_taken: int = 0
	var actions_taken: int = 0
	
	func _init() -> void:
		# 플레이어 기본 무술 3개
		var martial_0 = {
			"name": "기본펀치",
			"damage": 8,
			"energy": 2,
			"tempo": "fast"
		}
		var martial_1 = {
			"name": "회전발차기",
			"damage": 12,
			"energy": 4,
			"tempo": "mid"
		}
		var martial_2 = {
			"name": "광폭무술",
			"damage": 16,
			"energy": 6,
			"tempo": "slow"
		}
		martial_slots = [martial_0, martial_1, martial_2]
	
	func get_status_string() -> String:
		var hp_bar = ""
		var hp_percent = float(current_hp) / float(max_hp)
		var filled = int(hp_percent * 20)
		for i in range(20):
			if i < filled:
				hp_bar += "█"
			else:
				hp_bar += "░"
		
		return """
		┌─────────────────────────────────────┐
		│ %s (플레이어)
		├─────────────────────────────────────┤
		│ HP: %d/%d %s
		│ EN: %d/%d
		│ 누적 피해: %d | 입은 피해: %d
		│ 시도한 액션: %d
		└─────────────────────────────────────┘
		""" % [
			name,
			current_hp,
			max_hp,
			hp_bar,
			current_energy,
			max_energy,
			total_damage_dealt,
			total_damage_taken,
			actions_taken
		]
	
	func is_alive() -> bool:
		return current_hp > 0


# ╔═════════════════════════════════════════════════════════╗
# ║            전투 시뮬레이션                               ║
# ╚═════════════════════════════════════════════════════════╝

func run_battle_simulation() -> void:
	"""
	30라운드 자동 전투 시뮬레이션
	"""
	
	print("\n")
	print("╔═══════════════════════════════════════════════════════╗")
	print("║       🥋 NEXUS Day 8: 첫 보스 전투 시뮬레이션          ║")
	print("║          테스트 플레이어 vs 천산 검객                  ║")
	print("║          최대 30라운드, 자동 전투                      ║")
	print("╚═══════════════════════════════════════════════════════╝")
	print("\n")
	
	# 보스와 플레이어 생성
	var boss = FirstBoss.new()
	boss.initialize_martial_arts()
	
	var player = TestPlayer.new()
	
	print("═── 초기 상태 ───═")
	print(boss.get_status_string())
	print(player.get_status_string())
	print("\n")
	
	# 30라운드 전투 루프
	var round = 1
	var max_rounds = 30
	
	while round <= max_rounds and boss.is_alive() and player.is_alive():
		print("┌─── 라운드 %d ───┐" % round)
		
		# 1. 보스 액션 선택
		boss.update_phase()
		boss.update_rage_meter(1.0)
		
		var boss_action = boss.select_action(null)
		var boss_result = boss.execute_action(boss_action, null)
		
		# 2. 플레이어가 보스 공격 받음
		var player_defense = player.stats["CON"]
		var actual_damage = maxi(boss_result["damage_dealt"] - player_defense / 3, 1)
		
		player.current_hp -= actual_damage
		player.total_damage_taken += actual_damage
		
		print("  보스의 공격: %s" % boss_result["action_name"])
		print("    → 데미지: %d, 에너지 소비: %d" % [boss_result["damage_dealt"], boss_result["energy_used"]])
		print("  플레이어 실제 받은 피해: %d" % actual_damage)
		
		# 3. 플레이어 액션 선택 (AI)
		var player_action_index = randi() % 3
		var player_martial = player.martial_slots[player_action_index]
		
		# 에너지 확인
		if player.current_energy >= player_martial["energy"]:
			player.current_energy -= player_martial["energy"]
			
			# 데미지 계산
			var player_damage = player_martial["damage"] + player.stats["STR"] / 3
			
			# 크리티컬 (DEX 기반, 20% 확률)
			if randf() < 0.2:
				player_damage = int(player_damage * 1.5)
				print("  플레이어의 공격: %s (크리티컬!)" % player_martial["name"])
			else:
				print("  플레이어의 공격: %s" % player_martial["name"])
			
			player.total_damage_dealt += player_damage
			player.actions_taken += 1
			
			# 보스가 데미지 받음
			boss.take_damage(player_damage, null)
			print("    → 데미지: %d, 에너지 소비: %d" % [player_damage, player_martial["energy"]])
		else:
			# 에너지 회복
			player.current_energy = mini(player.current_energy + 20, player.max_energy)
			print("  플레이어가 에너지를 회복했다!")
		
		# 4. 라운드 정보 출력
		print("  ─────────────────────────────────────")
		print("  보스 HP: %d/%d (%.1f%%)" % [
			boss.current_hp,
			boss.max_hp,
			boss.get_hp_percent() * 100.0
		])
		print("  보스 분노도: %.1f/100" % boss.get_rage_meter())
		print("  보스 Phase: %d | 플레이어 HP: %d/%d" % [
			boss.get_phase(),
			player.current_hp,
			player.max_hp
		])
		print("└" + ("─" * 35) + "┘\n")
		
		round += 1
	
	# 전투 결과
	print("\n")
	print("╔═══════════════════════════════════════════════════════╗")
	print("║              ⚔️ 전투 결과                             ║")
	print("╚═══════════════════════════════════════════════════════╝")
	print("\n")
	
	if boss.is_defeated():
		print("✅ 플레이어 승리!")
		print("   보스를 격파했습니다!")
	elif not player.is_alive():
		print("❌ 플레이어 패배!")
		print("   보스에게 격파당했습니다!")
	else:
		print("⚠️  시간 초과 (30라운드)")
		print("   전투가 너무 오래 진행되었습니다.")
	
	print("\n")
	
	# 최종 통계
	print("┌─── 최종 통계 ───┐")
	print("라운드: %d / 30" % (round - 1))
	print("플레이어 총 피해: %d" % player.total_damage_dealt)
	print("보스 총 피해: %d" % player.total_damage_taken)
	print("플레이어 최종 HP: %d / %d (%.1f%%)" % [
		player.current_hp,
		player.max_hp,
		float(player.current_hp) / float(player.max_hp) * 100.0
	])
	print("보스 최종 HP: %d / %d (%.1f%%)" % [
		boss.current_hp,
		boss.max_hp,
		float(boss.current_hp) / float(boss.max_hp) * 100.0
	])
	print("보스 분노도: %.1f/100" % boss.get_rage_meter())
	print("└──────────────────┘")
	
	print("\n")
	print("━" * 60)
	print("Day 8 시뮬레이션 완료!")
	print("━" * 60)
	print("\n")
	
	# 평가
	evaluate_battle(boss, player, round - 1)


## 전투 평가
func evaluate_battle(boss: FirstBoss, player: TestPlayer, rounds_played: int) -> void:
	"""
	전투 밸런싱 평가
	"""
	
	print("📊 밸런싱 평가:")
	print("")
	
	var success = false
	var damage_ratio = float(player.total_damage_dealt) / float(player.total_damage_taken)
	
	if boss.is_defeated():
		print("✅ 성공: 플레이어가 보스를 격파했습니다!")
		print("")
		
		if rounds_played <= 15:
			print("⚠️  경고: 전투가 너무 빨리 끝났습니다. (너무 쉬움)")
			print("   보스의 HP를 증가시키거나 데미지를 증가시키세요.")
		elif rounds_played <= 20:
			print("👍 좋음: 적절한 난이도입니다. (약간 쉬움)")
		elif rounds_played <= 25:
			print("✨ 우수: 매우 잘 밸런싱됨! (적당함)")
		elif rounds_played <= 30:
			print("💪 도전적: 플레이어가 힘들어했습니다. (약간 어려움)")
		
		if damage_ratio > 2.0:
			print("   플레이어의 DPS가 좋습니다 (비율: %.2f)" % damage_ratio)
		elif damage_ratio < 1.0:
			print("   플레이어의 DPS가 낮습니다 (비율: %.2f)" % damage_ratio)
		
		success = true
	else:
		print("❌ 실패: 플레이어가 보스에게 패배했습니다!")
		print("   보스가 너무 강합니다. 조정이 필요합니다.")
		print("")
		print("   플레이어가 입은 피해: %d" % player.total_damage_taken)
		print("   플레이어가 준 피해: %d" % player.total_damage_dealt)
		print("   DPS 비율: %.2f (플레이어 / 보스)" % damage_ratio)
	
	print("")
	print("📝 분석:")
	print("")
	
	# Phase별 분석
	if rounds_played > 10:
		print("• 보스의 Phase 시스템이 정상 작동했습니다.")
	
	if player.total_damage_dealt >= 50:
		print("• 플레이어의 공격 패턴이 효과적이었습니다.")
	
	print("• 평균 라운드당 피해: %.1f (플레이어), %.1f (보스)" % [
		float(player.total_damage_dealt) / float(rounds_played),
		float(player.total_damage_taken) / float(rounds_played)
	])
	
	print("\n")
	
	if success:
		print("🎉 Day 8 성공! FirstBoss 시스템이 완벽하게 작동합니다!")
	else:
		print("⚙️  Day 8 검토 필요. FirstBoss 밸런싱을 조정하세요.")
	
	print("\n")
