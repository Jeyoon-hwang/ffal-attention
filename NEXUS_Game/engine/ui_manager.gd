extends Node

# ============================================================================
# UI Manager - NEXUS 게임의 모든 UI를 관리하는 중앙 허브
# ============================================================================
# Week 3 Day 6: UI/UX 시스템
# 담당: 천재 ⚡
# 상태: 95% → 99% (UI 완성)
# ============================================================================

# 싱글톤
var _instance = null

# UI 상태
enum UIState {
	MENU,
	HUD,
	INVENTORY,
	SKILL_TREE,
	MAP,
	PAUSED,
	LOADING
}

var current_state = UIState.MENU
var ui_stacks = {}  # UI 스택 관리 (각 상태별)
var visible_uis = {}  # 현재 표시 중인 UI들

# UI 참조
var menu_ui: MenuSystem
var hud_ui: HUDSystem
var inventory_ui: InventorySystem
var skill_tree_ui: SkillTreeUI
var map_ui: MapSystem
var pause_ui: PauseMenuUI

# 게임 데이터 참조
var game_manager = null
var player = null

# ============================================================================
# 초기화 & 라이프사이클
# ============================================================================

func _ready():
	# 싱글톤 패턴
	if _instance == null:
		_instance = self
	else:
		queue_free()
		return
	
	# UI 시스템 인스턴스화
	menu_ui = MenuSystem.new()
	hud_ui = HUDSystem.new()
	inventory_ui = InventorySystem.new()
	skill_tree_ui = SkillTreeUI.new()
	map_ui = MapSystem.new()
	pause_ui = PauseMenuUI.new()
	
	# 모든 UI 초기화
	add_child(menu_ui)
	add_child(hud_ui)
	add_child(inventory_ui)
	add_child(skill_tree_ui)
	add_child(map_ui)
	add_child(pause_ui)
	
	# 초기 상태: 메인 메뉴
	show_menu()

func _process(delta):
	# UI 업데이트
	if current_state == UIState.HUD and hud_ui:
		hud_ui.update_hud(delta)
	
	# ESC 키: 일시정지 메뉴
	if Input.is_action_just_pressed("ui_cancel") and current_state == UIState.HUD:
		show_pause_menu()

# ============================================================================
# 메뉴 시스템
# ============================================================================

func show_menu():
	"""메인 메뉴 표시"""
	current_state = UIState.MENU
	_hide_all_uis()
	if menu_ui:
		menu_ui.show()
		menu_ui.show_main_menu()

func show_game():
	"""게임 플레이 시작 (HUD 표시)"""
	current_state = UIState.HUD
	_hide_all_uis()
	if hud_ui:
		hud_ui.show()

func show_pause_menu():
	"""일시정지 메뉴"""
	if current_state == UIState.HUD:
		current_state = UIState.PAUSED
		if pause_ui:
			pause_ui.show()

func resume_game():
	"""게임 재개"""
	current_state = UIState.HUD
	if pause_ui:
		pause_ui.hide()

# ============================================================================
# 게임 중 UI 전환
# ============================================================================

func toggle_inventory():
	"""인벤토리 토글"""
	if current_state == UIState.HUD:
		if inventory_ui.visible:
			inventory_ui.hide()
		else:
			inventory_ui.show()

func toggle_skill_tree():
	"""스킬 트리 토글"""
	if current_state == UIState.HUD:
		if skill_tree_ui.visible:
			skill_tree_ui.hide()
		else:
			skill_tree_ui.show()

func toggle_map():
	"""맵 토글"""
	if current_state == UIState.HUD:
		if map_ui.visible:
			map_ui.hide()
		else:
			map_ui.show()

# ============================================================================
# 내부 헬퍼 함수
# ============================================================================

func _hide_all_uis():
	"""모든 UI 숨기기"""
	if menu_ui:
		menu_ui.hide()
	if hud_ui:
		hud_ui.hide()
	if inventory_ui:
		inventory_ui.hide()
	if skill_tree_ui:
		skill_tree_ui.hide()
	if map_ui:
		map_ui.hide()
	if pause_ui:
		pause_ui.hide()

# ============================================================================
# 게임 이벤트 핸들러
# ============================================================================

func on_player_level_up(new_level: int):
	"""플레이어 레벨업 이벤트"""
	if hud_ui:
		hud_ui.show_level_up_popup(new_level)
	if skill_tree_ui:
		skill_tree_ui.add_skill_points(1)

func on_player_quest_complete(quest_id: String, reward: Dictionary):
	"""퀘스트 완료 이벤트"""
	if hud_ui:
		hud_ui.show_quest_complete(quest_id, reward)

func on_martial_art_learned(art_name: String):
	"""무술 습득 이벤트"""
	if inventory_ui:
		inventory_ui.add_martial_art(art_name)

func on_boss_defeat(boss_name: String):
	"""보스 격파 이벤트"""
	if hud_ui:
		hud_ui.show_boss_defeat(boss_name)

# ============================================================================
# 정적 접근자 (게임 어디서나 접근 가능)
# ============================================================================

static func get_instance() -> UIManager:
	return _instance

func update_player_stats(stats: Dictionary):
	"""플레이어 능력치 업데이트 (HUD 반영)"""
	if hud_ui:
		hud_ui.update_player_stats(stats)

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[UIManager] " + msg)
