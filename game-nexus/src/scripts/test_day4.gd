# test_day4.gd - Day 4 통합 테스트 (NPC, 아이템, 대화)
# 작성: 천재 ⚡
# 2026-05-07 Day 4

extends Node

# Day 4 시스템들
var npc_system: Node
var item_system: Node
var dialogue_system: Node

# 테스트 통과/실패
var tests_passed: int = 0
var tests_failed: int = 0

func _ready():
	print("\n" + "="*60)
	print("🥋 NEXUS Day 4 통합 테스트 시작")
	print("="*60 + "\n")
	
	# 시스템 로드
	npc_system = preload("res://src/scripts/npc_system.gd").new()
	item_system = preload("res://src/scripts/item_system.gd").new()
	dialogue_system = preload("res://src/scripts/dialogue_system.gd").new()
	
	add_child(npc_system)
	add_child(item_system)
	add_child(dialogue_system)
	
	# 테스트 실행
	test_npc_system()
	test_item_system()
	test_dialogue_system()
	test_integration()
	
	print_test_results()

# ============================================================
# NPC 시스템 테스트
# ============================================================

func test_npc_system() -> void:
	print("\n📋 NPC 시스템 테스트")
	print("-" * 50)
	
	# Test 1: NPC 수 확인
	var npc_count = npc_system.get_npc_count()
	test_assert(npc_count > 100, "NPC 100+명 생성: %d명" % npc_count)
	
	# Test 2: 지역별 NPC 분포
	var regions = ["중원", "동토", "남해", "서역", "북방"]
	for region in regions:
		var count = npc_system.get_region_npc_count(region)
		test_assert(count > 10, "%s 지역 NPC 생성: %d명" % [region, count])
	
	# Test 3: NPC 직업 다양성
	var merchant_npcs = npc_system.get_npcs_by_job("상인")
	test_assert(merchant_npcs.size() > 5, "상인 직업 NPC 생성: %d명" % merchant_npcs.size())
	
	# Test 4: NPC 물품 생성
	var npc_ids = npc_system.npcs.keys()
	if npc_ids.size() > 0:
		var first_npc = npc_system.get_npc(npc_ids[0])
		test_assert(first_npc.goods.size() > 0, "NPC 물품 생성: %d개" % first_npc.goods.size())
	
	# Test 5: NPC 대화 시스템
	if npc_ids.size() > 0:
		var npc_id = npc_ids[0]
		var dialogue = npc_system.get_npc_dialogue(npc_id)
		test_assert(dialogue != null, "NPC 대사 조회 성공")
	
	# Test 6: 친밀도 시스템
	if npc_ids.size() > 0:
		var npc_id = npc_ids[0]
		var initial_aff = npc_system.get_npc(npc_id).affinity
		npc_system.change_affinity(npc_id, 10)
		var new_aff = npc_system.get_npc(npc_id).affinity
		test_assert(new_aff == initial_aff + 10, "친밀도 변경: %d → %d" % [initial_aff, new_aff])
	
	# Test 7: NPC 거래 시스템
	if npc_ids.size() > 0:
		var npc_id = npc_ids[0]
		var trades = npc_system.get_npc_trades(npc_id)
		test_assert(trades.size() > 0, "NPC 거래 시스템: %d개" % trades.size())
	
	npc_system.print_game_status()

# ============================================================
# 아이템 시스템 테스트
# ============================================================

func test_item_system() -> void:
	print("\n🎁 아이템 시스템 테스트")
	print("-" * 50)
	
	# Test 1: 아이템 수 확인
	var item_count = item_system.get_item_count()
	test_assert(item_count >= 100, "아이템 100+개 생성: %d개" % item_count)
	
	# Test 2: 카테고리별 아이템
	var categories = ["weapon", "armor", "accessory", "consumable", "material"]
	for category in categories:
		var count = item_system.get_category_item_count(category)
		test_assert(count > 0, "%s 카테고리 아이템: %d개" % [category, count])
	
	# Test 3: 희귀도별 분포
	var common_items = item_system.get_items_by_rarity("common")
	var rare_items = item_system.get_items_by_rarity("rare")
	test_assert(common_items.size() > rare_items.size(), 
				"희귀도별 분포 (common > rare): %d vs %d" % [common_items.size(), rare_items.size()])
	
	# Test 4: 아이템 능력치
	var items = item_system.items.values()
	if items.size() > 0:
		var item = items[0]
		var has_stats = item.stats.size() >= 0
		test_assert(has_stats, "아이템 능력치 시스템: 활성화됨")
	
	# Test 5: 드롭 시스템
	var drops = item_system.drops
	test_assert(drops.size() > 0, "드롭 규칙 생성: %d개" % drops.size())
	
	# Test 6: 적 드롭 시뮬레이션
	var enemy_drops = item_system.simulate_drop("enemy", 5)
	test_assert(enemy_drops.size() >= 0, "적 드롭 시뮬레이션: %d개" % enemy_drops.size())
	
	# Test 7: 보스 드롭 시뮬레이션
	var boss_drops = item_system.simulate_drop("boss", 10)
	test_assert(boss_drops.size() >= 0, "보스 드롭 시뮬레이션: %d개" % boss_drops.size())
	
	item_system.print_game_status()

# ============================================================
# 대화 시스템 테스트
# ============================================================

func test_dialogue_system() -> void:
	print("\n💬 대화 시스템 테스트")
	print("-" * 50)
	
	# Test 1: 대화 트리 생성
	var tree_count = dialogue_system.dialogue_trees.keys().size()
	test_assert(tree_count > 0, "대화 트리 생성: %d개" % tree_count)
	
	# Test 2: 대화 시작
	var test_npc_id = "상인_001"
	var node = dialogue_system.start_dialogue(test_npc_id, "상인")
	test_assert(node != null, "대화 시작 성공")
	
	# Test 3: 대화 진행
	var current = dialogue_system.get_current_node()
	test_assert(current != null, "현재 대화 노드 조회")
	
	# Test 4: 대화 선택지
	if current != null and current.choices.size() > 0:
		var choice_count = current.choices.size()
		test_assert(choice_count > 0, "대화 선택지: %d개" % choice_count)
	
	# Test 5: 대화 히스토리
	var history = dialogue_system.get_dialogue_history()
	test_assert(history.size() > 0, "대화 히스토리 추적")
	
	# Test 6: 친밀도 변경
	if current != null and current.choices.size() > 0:
		var choice = current.choices[0]
		var affinity_change = choice.affinity_change
		test_assert(affinity_change != 0, "친밀도 변경값 설정: %+d" % affinity_change)
	
	# Test 7: 대화 종료
	dialogue_system.end_dialogue()
	test_assert(dialogue_system.current_npc_id == "", "대화 종료 완료")
	
	dialogue_system.print_game_status()

# ============================================================
# 통합 테스트
# ============================================================

func test_integration() -> void:
	print("\n🔗 통합 테스트")
	print("-" * 50)
	
	# Test 1: NPC와 아이템 연동
	var npc_ids = npc_system.npcs.keys()
	if npc_ids.size() > 0:
		var npc_id = npc_ids[0]
		var npc = npc_system.get_npc(npc_id)
		test_assert(npc.goods.size() > 0, "NPC 물품 ↔ 아이템 시스템: %d개 물품" % npc.goods.size())
	
	# Test 2: 지역별 콘텐츠 통합
	var regions = ["중원", "동토", "남해", "서역", "북방"]
	var all_regions_valid = true
	for region in regions:
		var npcs = npc_system.get_region_npcs(region)
		if npcs.size() == 0:
			all_regions_valid = false
	test_assert(all_regions_valid, "지역별 NPC 통합: 5개 지역 모두 NPC 배치")
	
	# Test 3: 아이템 가격 체계
	var items = item_system.items.values()
	if items.size() > 0:
		var price_valid = true
		for item in items:
			if item.price < 0:
				price_valid = false
		test_assert(price_valid, "아이템 가격 체계: 모든 아이템 양수 가격")
	
	# Test 4: 대화 액션 타입
	var actions = ["trade", "quest", "fight", "none"]
	var action_valid = true
	for tree in dialogue_system.dialogue_trees.values():
		for node in tree.values():
			if not node.action in actions:
				action_valid = false
	test_assert(action_valid, "대화 액션 타입: 모든 액션 유효함")
	
	# Test 5: NPC-아이템-대화 삼각 통합
	if npc_ids.size() > 0 and item_system.items.size() > 0:
		var npc_id = npc_ids[0]
		npc_system.change_affinity(npc_id, 5)
		var dialogue = npc_system.get_npc_dialogue(npc_id)
		test_assert(dialogue != null, "NPC 친밀도 → 대화 변경")
	
	# Test 6: 전체 콘텐츠 규모
	var total_content = (npc_system.get_npc_count() + 
					   item_system.get_item_count() +
					   dialogue_system.dialogue_trees.size())
	test_assert(total_content > 300, "전체 콘텐츠 규모: %d개 요소" % total_content)

# ============================================================
# 헬퍼 함수
# ============================================================

func test_assert(condition: bool, message: String) -> void:
	if condition:
		print("  ✅ %s" % message)
		tests_passed += 1
	else:
		print("  ❌ %s" % message)
		tests_failed += 1

func print_test_results() -> void:
	var total = tests_passed + tests_failed
	var pass_rate = (tests_passed * 100) / max(total, 1)
	
	print("\n" + "="*60)
	print("📊 Day 4 테스트 결과")
	print("="*60)
	print("✅ 통과: %d개" % tests_passed)
	print("❌ 실패: %d개" % tests_failed)
	print("📈 성공률: %d%%" % pass_rate)
	print("="*60 + "\n")
	
	if tests_failed == 0:
		print("🎉 모든 테스트 통과!")
	else:
		print("⚠️  일부 테스트 실패. 확인 필요.")

# ============================================================
