#!/usr/bin/env godot
# AI Level 4 (마스터) 검증 테스트

extends Node

class_name TestAILevel4

func _ready() -> void:
	print("\n" + "="*80)
	print("🧪 AI Level 4 (마스터) 검증 테스트")
	print("="*80)
	
	# 엔진 & 플레이어 초기화
	var martial_engine = load("res://engine/martial_art_engine.gd").new()
	martial_engine.initialize_base_arts()
	
	var player = load("res://engine/player_combat.gd").new()
	player.martial_engine = martial_engine
	player.player_stats = {"str": 15, "dex": 12, "int": 10, "con": 11, "wis": 9, "cha": 8, "sen": 13, "luc": 10}
	player.hp = 100.0
	player.mp = 100.0
	player.max_hp = 100.0
	player.max_mp = 100.0
	
	# Level 4 AI 초기화
	var boss_ai = load("res://engine/enemy_ai.gd").new()
	boss_ai.initialize(4, player)  # Level 4 = MASTER
	
	print("\n📊 AI Level 4 파라미터 검증:")
	print("  - 회피율: %d%%" % int(boss_ai.params["evasion_chance"] * 100))
	print("  - 반응시간: %.1f초" % boss_ai.params["decision_frequency"])
	print("  - 패턴메모리: %d개" % boss_ai.params["pattern_memory"])
	print("  - 공격거리: %.1f" % boss_ai.params["attack_distance"])
	print("  - 추적거리: %.1f" % boss_ai.params["pursuit_distance"])
	
	# 검증
	var pass_count = 0
	var total_tests = 5
	
	if boss_ai.params["evasion_chance"] == 0.7:
		print("  ✅ 회피율 70% 맞음")
		pass_count += 1
	else:
		print("  ❌ 회피율 오류")
	
	if boss_ai.params["decision_frequency"] == 0.4:
		print("  ✅ 반응시간 0.4초 맞음")
		pass_count += 1
	else:
		print("  ❌ 반응시간 오류")
	
	if boss_ai.params["pattern_memory"] == 20:
		print("  ✅ 패턴메모리 20개 맞음")
		pass_count += 1
	else:
		print("  ❌ 패턴메모리 오류")
	
	if boss_ai.params["attack_accuracy"] == 1.0:
		print("  ✅ 공격정확도 100% 맞음")
		pass_count += 1
	else:
		print("  ❌ 공격정확도 오류")
	
	# 보스 AI 초기화 테스트
	boss_ai.initialize_as_boss()
	if boss_ai.max_hp == 200.0 and boss_ai.hp == 200.0:
		print("  ✅ 보스 HP 200 맞음")
		pass_count += 1
	else:
		print("  ❌ 보스 HP 오류: %.0f/%.0f" % [boss_ai.hp, boss_ai.max_hp])
	
	print("\n📈 검증 결과: %d/%d 통과" % [pass_count, total_tests])
	print("="*80 + "\n")
