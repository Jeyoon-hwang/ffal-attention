extends Node

# ============================================================================
# UI Integration Test - 모든 UI 시스템 통합 테스트
# ============================================================================
# Week 3 Day 6: UI 시스템 통합 테스트
# 담당: 천재 ⚡
# ============================================================================

# 참조
var ui_manager: UIManager
var game_manager: Node

# 테스트 결과
var test_results = []
var test_count = 0
var passed_count = 0

# ============================================================================
# 초기화 & 테스트 실행
# ============================================================================

func _ready():
	print("\n" + "="*60)
	print("🧪 UI Integration Test 시작")
	print("="*60 + "\n")
	
	# UI Manager 인스턴스화
	ui_manager = UIManager.new()
	add_child(ui_manager)
	
	# 테스트 실행
	run_all_tests()
	
	# 결과 출력
	print_results()

func run_all_tests():
	"""모든 테스트 실행"""
	test_ui_manager()
	test_hud_system()
	test_inventory_system()
	test_skill_tree_ui()
	test_map_system()
	test_menu_system()

# ============================================================================
# 테스트 함수들
# ============================================================================

func test_ui_manager():
	"""UIManager 테스트"""
	print("\n📋 UIManager 테스트:")
	
	# 1. UI Manager 초기화
	assert(ui_manager != null, "UIManager 생성 실패")
	_add_test(true, "UIManager 인스턴스 생성")
	
	# 2. 상태 전환 테스트
	ui_manager.show_menu()
	assert(ui_manager.current_state == UIManager.UIState.MENU, "메뉴 상태 전환 실패")
	_add_test(true, "메뉴 상태로 전환")
	
	ui_manager.show_game()
	assert(ui_manager.current_state == UIManager.UIState.HUD, "HUD 상태 전환 실패")
	_add_test(true, "HUD 상태로 전환")

func test_hud_system():
	"""HUD System 테스트"""
	print("\n📊 HUD System 테스트:")
	
	var hud = ui_manager.hud_ui
	assert(hud != null, "HUD 인스턴스 생성 실패")
	_add_test(true, "HUD 인스턴스 생성")
	
	# 1. 플레이어 데이터 초기화
	assert(hud.player_data["hp"] > 0, "체력 초기화 실패")
	_add_test(true, "플레이어 체력 초기화")
	
	# 2. 데미지 테스트
	var initial_hp = hud.player_data["hp"]
	hud.take_damage(10, 100, 100)
	assert(hud.player_data["hp"] == initial_hp - 10, "데미지 계산 실패")
	_add_test(true, "데미지 적용")
	
	# 3. 회복 테스트
	hud.heal(5)
	assert(hud.player_data["hp"] == initial_hp - 10 + 5, "회복 실패")
	_add_test(true, "회복 시스템")
	
	# 4. MP 소비 테스트
	var initial_mp = hud.player_data["mp"]
	var can_cast = hud.spend_mp(10)
	assert(can_cast, "MP 소비 실패")
	assert(hud.player_data["mp"] == initial_mp - 10, "MP 감소 실패")
	_add_test(true, "MP 소비 시스템")
	
	# 5. 골드 테스트
	hud.add_gold(100)
	assert(hud.player_data["gold"] == 100, "골드 추가 실패")
	_add_test(true, "골드 시스템")
	
	# 6. 레벨업 테스트
	hud.show_level_up_popup(2)
	assert(hud.player_data["level"] == 2, "레벨업 실패")
	_add_test(true, "레벨업 시스템")

func test_inventory_system():
	"""Inventory System 테스트"""
	print("\n📦 Inventory System 테스트:")
	
	var inventory = ui_manager.inventory_ui
	assert(inventory != null, "인벤토리 인스턴스 생성 실패")
	_add_test(true, "인벤토리 인스턴스 생성")
	
	# 1. 무술 추가
	var art1 = {"name": "기본 검술", "damage": 10, "description": "가장 기본적인 검술"}
	var success = inventory.add_martial_art(art1)
	assert(success, "무술 추가 실패")
	assert(inventory.martial_arts.size() == 1, "무술 개수 불일치")
	_add_test(true, "무술 추가")
	
	# 2. 중복 무술 추가
	var art2 = {"name": "회전참", "damage": 15}
	inventory.add_martial_art(art2)
	assert(inventory.martial_arts.size() == 2, "무술 개수 증가 실패")
	_add_test(true, "다중 무술 관리")
	
	# 3. 무술 제거
	inventory.remove_martial_art("기본 검술")
	assert(inventory.martial_arts.size() == 1, "무술 제거 실패")
	_add_test(true, "무술 제거")
	
	# 4. 아이템 추가
	var item = {"name": "빨간 물약", "quantity": 3, "description": "체력 50 회복"}
	var item_success = inventory.add_item(item)
	assert(item_success, "아이템 추가 실패")
	assert(inventory.items.size() == 1, "아이템 개수 불일치")
	_add_test(true, "아이템 추가")
	
	# 5. 아이템 사용
	var use_success = inventory.use_item("빨간 물약")
	assert(use_success, "아이템 사용 실패")
	assert(inventory.items.size() == 0, "아이템 제거 실패")
	_add_test(true, "아이템 사용")
	
	# 6. 퀘스트 아이템
	inventory.add_quest_item("황금 열쇠")
	assert(inventory.quest_items.has("황금 열쇠"), "퀘스트 아이템 추가 실패")
	_add_test(true, "퀘스트 아이템")

func test_skill_tree_ui():
	"""Skill Tree UI 테스트"""
	print("\n🌳 Skill Tree UI 테스트:")
	
	var skill_tree = ui_manager.skill_tree_ui
	assert(skill_tree != null, "스킬 트리 인스턴스 생성 실패")
	_add_test(true, "스킬 트리 인스턴스 생성")
	
	# 1. 스킬 포인트 추가
	skill_tree.add_skill_points(5)
	assert(skill_tree.skill_points == 5, "스킬 포인트 추가 실패")
	_add_test(true, "스킬 포인트 추가")
	
	# 2. 스킬 습득 (STR 브랜치, 레벨 1)
	var learned = skill_tree.learn_skill("STR", 1)
	assert(learned, "스킬 습득 실패")
	assert(skill_tree.skill_points == 4, "스킬 포인트 차감 실패")
	_add_test(true, "스킬 습득")
	
	# 3. 부족한 포인트로 습득 시도
	skill_tree.skill_points = 0
	var fail_learned = skill_tree.learn_skill("INT", 3)
	assert(!fail_learned, "포인트 부족 체크 실패")
	_add_test(true, "포인트 부족 처리")

func test_map_system():
	"""Map System 테스트"""
	print("\n🗺️  Map System 테스트:")
	
	var map = ui_manager.map_ui
	assert(map != null, "맵 인스턴스 생성 실패")
	_add_test(true, "맵 인스턴스 생성")
	
	# 1. 지역 발견
	map.discover_zone(0)
	assert(map.zones[0]["discovered"], "지역 발견 실패")
	_add_test(true, "지역 발견")
	
	# 2. 지역 텔레포트
	var teleport_success = map.teleport_to_zone(0)
	assert(teleport_success, "텔레포트 실패")
	_add_test(true, "지역 텔레포트")
	
	# 3. 미발견 지역 접근 시도
	var fail_teleport = map.teleport_to_zone(4)
	assert(!fail_teleport, "미발견 지역 접근 차단 실패")
	_add_test(true, "미발견 지역 차단")

func test_menu_system():
	"""Menu System 테스트"""
	print("\n🎮 Menu System 테스트:")
	
	var menu = ui_manager.menu_ui
	assert(menu != null, "메뉴 인스턴스 생성 실패")
	_add_test(true, "메뉴 인스턴스 생성")
	
	# 1. 메뉴 상태
	assert(menu.current_menu == MenuSystem.MenuState.MAIN, "메인 메뉴 상태 실패")
	_add_test(true, "메인 메뉴 표시")
	
	# 2. 설정
	menu.show_settings_menu()
	assert(menu.current_menu == MenuSystem.MenuState.SETTINGS, "설정 메뉴 전환 실패")
	_add_test(true, "설정 메뉴 전환")
	
	# 3. 음량 설정
	menu.settings["volume"] = 0.5
	assert(menu.settings["volume"] == 0.5, "음량 설정 실패")
	_add_test(true, "음량 설정")
	
	# 4. 그래픽 품질
	menu.settings["graphics_quality"] = 3
	assert(menu.settings["graphics_quality"] == 3, "그래픽 품질 설정 실패")
	_add_test(true, "그래픽 품질 설정")

# ============================================================================
# 테스트 헬퍼
# ============================================================================

func _add_test(passed: bool, name: String):
	"""테스트 결과 추가"""
	test_count += 1
	if passed:
		passed_count += 1
		print("  ✅ %s" % name)
	else:
		print("  ❌ %s" % name)
	test_results.append({"name": name, "passed": passed})

func assert(condition: bool, message: String):
	"""Assertion 함수"""
	if not condition:
		print("  ❌ ASSERT FAILED: " + message)
		_add_test(false, message)

func print_results():
	"""테스트 결과 출력"""
	print("\n" + "="*60)
	print("📊 테스트 결과")
	print("="*60)
	print("총 테스트: %d" % test_count)
	print("성공: %d (%.1f%%)" % [passed_count, (float(passed_count) / float(test_count)) * 100])
	print("실패: %d" % (test_count - passed_count))
	
	if passed_count == test_count:
		print("\n🎉 모든 테스트 통과!")
	else:
		print("\n⚠️  일부 테스트 실패")
	
	print("="*60 + "\n")

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[UITest] " + msg)
