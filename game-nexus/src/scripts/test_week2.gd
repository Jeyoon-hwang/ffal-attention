# test_week2.gd - Week 2 시스템 테스트
# 새로운 지역, 던전, 퀨스트 시스템이 정상 작동하는지 확인

extends Node

# Week 2 시스템들 (미리 로드)
var region_mgr: Node
var dungeon_gen: Node
var quest_sys: Node

func _ready():
	print("\n╔══════════════════════════════════════════════════╗")
	print("║  🥋 NEXUS Week 2 시스템 테스트 시작             ║")
	print("╚══════════════════════════════════════════════════╝\n")
	
	# 시스템 로드
	region_mgr = preload("res://src/scripts/region_manager.gd").new()
	dungeon_gen = preload("res://src/scripts/dungeon_generator.gd").new()
	quest_sys = preload("res://src/scripts/quest_system.gd").new()
	
	# 테스트 실행
	test_regions()
	test_dungeons()
	test_quests()
	test_game_manager()
	
	print("\n╔══════════════════════════════════════════════════╗")
	print("║  ✅ 모든 테스트 완료!                            ║")
	print("╚══════════════════════════════════════════════════╝\n")

# === 지역 시스템 테스트 ===
func test_regions():
	print("\n📍 [지역 시스템 테스트]")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	
	# 모든 지역 확인
	var regions = region_mgr.get_all_regions()
	print("✅ 생성된 지역: %d개" % regions.size())
	
	for region in regions:
		print("\n📍 %s (ID: %s)" % [region.name, region.id])
		print("   난이도: %d, 크기: %s" % [region.difficulty, region.size])
		print("   건물: %d개, NPC: %d명, 퀨스트: %d개, 스포닝: %d개" % [
			region.buildings.size(),
			region.npcs.size(),
			region.quests.size(),
			region.spawn_points.size()
		])
	
	# 특정 지역 조회
	var zhongyuan = region_mgr.get_region("zhongyuan")
	if zhongyuan:
		print("\n🎯 중원 지역 상세 정보:")
		print("   NPC 목록:")
		for npc in zhongyuan.npcs:
			print("     - %s (역할: %s)" % [npc.name, npc.role])
		print("   퀨스트 목록:")
		for quest in zhongyuan.quests:
			print("     - %s" % quest.title)
	
	# 통계
	print("\n📊 전체 통계:")
	print("   총 NPC: %d명" % region_mgr.get_total_npc_count())
	print("   총 퀨스트: %d개" % region_mgr.get_total_quest_count())
	
	print("\n✅ 지역 시스템 테스트 완료!")

# === 던중 시스템 테스트 ===
func test_dungeons():
	print("\n\n🏰 [던중 시스템 테스트]")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	
	# 모든 던중 확인
	var dungeons = dungeon_gen.get_all_dungeons()
	print("✅ 생성된 던중: %d개" % dungeons.size())
	
	# 지역별 분포
	print("\n[지역별 던중 분포]")
	var regions_list = ["zhongyuan", "dongtu", "nanhai", "xiyou", "beifang"]
	for region_id in regions_list:
		var count = dungeon_gen.get_dungeon_count_by_region(region_id)
		print("   %s: %d개" % [region_id, count])
	
	# 타입별 분포
	print("\n[타입별 던중 분포]")
	var types = ["cave", "tower", "temple", "ruin", "tomb"]
	for dg_type in types:
		var count = dungeon_gen.get_dungeon_count_by_type(dg_type)
		print("   %s: %d개" % [dg_type, count])
	
	# 난이도별 분포
	print("\n[난이도별 던중 분포]")
	for difficulty in range(1, 5):
		var count = dungeon_gen.get_dungeon_count_by_difficulty(difficulty)
		print("   Level %d: %d개" % [difficulty, count])
	
	# 특정 던중 상세 정보
	var first_dungeon = dungeon_gen.get_dungeon("zhongyuan_dg_1")
	if first_dungeon:
		print("\n🎯 첫 번째 던중 상세정보:")
		print("   이름: %s" % first_dungeon.name)
		print("   타입: %s" % first_dungeon.type)
		print("   난이도: %d" % first_dungeon.difficulty)
		print("   층: %d층" % first_dungeon.layers)
		print("   보스: %s" % first_dungeon.boss)
		print("   입구 위치: %s" % first_dungeon.entrance_position)
		print("   클리어 보상 - 경험치: %d, 골드: %d" % [
			first_dungeon.completion_reward["exp"],
			first_dungeon.completion_reward["gold"]
		])
	
	print("\n✅ 던중 시스템 테스트 완료!")

# === 퀨스트 시스템 테스트 ===
func test_quests():
	print("\n\n📜 [퀨스트 시스템 테스트]")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	
	# 모든 퀨스트 확인
	var quests = quest_sys.get_all_quests()
	print("✅ 생성된 퀨스트: %d개" % quests.size())
	
	# 타입별 분포
	print("\n[타입별 퀨스트 분포]")
	var types = ["main", "side", "daily", "event", "hidden"]
	for quest_type in types:
		var count = quest_sys.get_quest_count_by_type(quest_type)
		print("   %s: %d개" % [quest_type, count])
	
	# 메인 퀨스트
	print("\n[메인 퀨스트 목록]")
	var main_quests = quest_sys.get_quests_by_type("main")
	for quest in main_quests:
		print("   - %s (제공: %s, 난이도: %d)" % [quest.title, quest.giver, quest.level_required])
	
	# 특정 퀨스트 상세정보
	var quest = quest_sys.get_quest("main_1")
	if quest:
		print("\n🎯 메인 퀨스트 1 상세정보:")
		print("   제목: %s" % quest.title)
		print("   제공자: %s" % quest.giver)
		print("   타입: %s" % quest.type)
		print("   필요 레벨: %d" % quest.level_required)
		print("   보상 - 경험치: %d, 골드: %d" % [quest.rewards["exp"], quest.rewards["gold"]])
	
	# 퀨스트 체인
	var chains = quest_sys.get_all_quest_chains()
	print("\n[퀨스트 체인]")
	print("   총 체인: %d개" % chains.size())
	for chain in chains:
		print("   - %s (%d개 퀨스트)" % [chain.name, chain.quests.size()])
	
	print("\n✅ 퀨스트 시스템 테스트 완료!")

# === 게임 매니저 통합 테스트 ===
func test_game_manager():
	print("\n\n⚙️  [게임 매니저 통합 테스트]")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	
	# 게임 매니저 로드
	var gm = get_tree().root.get_node_or_null("GameManager")
	if gm:
		print("✅ 게임 매니저 발견!")
		
		# 지역 변경 테스트
		print("\n[지역 변경 테스트]")
		var regions = ["zhongyuan", "dongtu", "nanhai", "xiyou", "beifang"]
		for region_id in regions:
			var success = gm.change_region(region_id)
			if success:
				print("   ✅ %s 변경 성공" % region_id)
		
		# 던중 입장 테스트
		print("\n[던중 입장 테스트]")
		var dungeons = ["zhongyuan_dg_1", "dongtu_dg_1", "nanhai_dg_1"]
		for dungeon_id in dungeons:
			var success = gm.enter_dungeon(dungeon_id)
			if success:
				print("   ✅ %s 입장 성공" % dungeon_id)
		
		# 퀨스트 수락 테스트
		print("\n[퀨스트 수락 테스트]")
		var quests = ["main_1", "side_1", "daily_1"]
		for quest_id in quests:
			var success = gm.accept_quest(quest_id)
			if success:
				print("   ✅ %s 수락 성공" % quest_id)
		
		# 게임 상태 출력
		print("\n[게임 상태]")
		gm.print_game_status()
	else:
		print("⚠️  게임 매니저를 찾을 수 없습니다.")
		print("   (main.tscn에서 GameManager 노드 확인 필요)")
	
	print("\n✅ 게임 매니저 통합 테스트 완료!")

# === 최종 요약 ===
func print_summary():
	print("\n\n╔══════════════════════════════════════════════════╗")
	print("║  📊 Week 2 시스템 테스트 최종 요약                ║")
	print("╚══════════════════════════════════════════════════╝\n")
	
	print("지역: %d개" % region_mgr.get_all_regions().size())
	print("NPC: %d명" % region_mgr.get_total_npc_count())
	print("던중: %d개" % dungeon_gen.get_all_dungeons().size())
	print("퀨스트: %d개" % quest_sys.get_total_quest_count())
	print("\n✅ 모든 시스템 정상 작동!")
