extends Control
class_name InventoryUI
## 인벤토리 & 무술 관리 UI

enum Tab { MARTIAL_ARTS, EQUIPMENT, ITEMS, STATS }

@onready var tab_bar = $VBoxContainer/TabBar
@onready var content_area = $VBoxContainer/ContentArea
@onready var martial_arts_list = $VBoxContainer/ContentArea/MartialArtsList
@onready var equipment_grid = $VBoxContainer/ContentArea/EquipmentGrid
@onready var items_grid = $VBoxContainer/ContentArea/ItemsGrid
@onready var stats_panel = $VBoxContainer/ContentArea/StatsPanel
@onready var item_detail_panel = $ItemDetailPanel
@onready var close_button = $CloseButton

var player: Player
var current_tab: Tab = Tab.MARTIAL_ARTS
var selected_item: Node = null

signal inventory_closed

func _ready():
	"""초기화"""
	player = get_tree().root.get_child(0).get_node("Player")
	
	# 탭 설정
	tab_bar.clear_tabs()
	tab_bar.add_tab("무술 (%d)" % player.learned_martial_arts.size())
	tab_bar.add_tab("장비")
	tab_bar.add_tab("아이템 (%d)" % player.inventory.size())
	tab_bar.add_tab("스탯")
	tab_bar.tab_changed.connect(_on_tab_changed)
	
	close_button.pressed.connect(_on_close_pressed)
	
	# 초기 탭 표시
	_on_tab_changed(0)

## ===== 탭 전환 =====

func _on_tab_changed(tab_index: int):
	"""탭 변경"""
	current_tab = Tab.values()[tab_index]
	content_area.clear()
	
	match current_tab:
		Tab.MARTIAL_ARTS:
			_show_martial_arts()
		Tab.EQUIPMENT:
			_show_equipment()
		Tab.ITEMS:
			_show_items()
		Tab.STATS:
			_show_stats()

## ===== 무술 탭 =====

func _show_martial_arts():
	"""무술 목록 표시"""
	var vbox = VBoxContainer.new()
	
	for martial in player.learned_martial_arts:
		var item = _create_martial_art_item(martial)
		vbox.add_child(item)
		item.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				_on_martial_art_selected(martial, item)
		)
	
	content_area.add_child(vbox)

func _create_martial_art_item(martial: MartialArt) -> PanelContainer:
	"""무술 아이템 UI 생성"""
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 80)
	
	var hbox = HBoxContainer.new()
	
	# 무술 아이콘 (색상으로 표현)
	var icon = ColorRect.new()
	icon.color = _get_motion_type_color(martial.motion_type)
	icon.custom_minimum_size = Vector2(40, 40)
	hbox.add_child(icon)
	
	# 무술 정보
	var info_vbox = VBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = "%s (Lv.%d)" % [martial.name, martial.level]
	name_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(name_label)
	
	var stats_label = Label.new()
	stats_label.text = "데미지: %d | 비용: %d | 쿨타임: %.2f초" % [
		int(martial.power),
		int(martial.energy_cost),
		martial.cooldown
	]
	stats_label.add_theme_font_size_override("font_size", 10)
	stats_label.modulate = Color.GRAY
	info_vbox.add_child(stats_label)
	
	# 강화도 바
	var level_bar = ProgressBar.new()
	level_bar.value = martial.level % 10 * 10
	level_bar.custom_minimum_size = Vector2(100, 8)
	info_vbox.add_child(level_bar)
	
	hbox.add_child(info_vbox)
	panel.add_child(hbox)
	return panel

func _on_martial_art_selected(martial: MartialArt, item: Node):
	"""무술 선택"""
	if selected_item:
		selected_item.modulate = Color.WHITE
	selected_item = item
	selected_item.modulate = Color.YELLOW
	
	_show_martial_art_detail(martial)

func _show_martial_art_detail(martial: MartialArt):
	"""무술 상세 정보 표시"""
	item_detail_panel.clear()
	
	var vbox = VBoxContainer.new()
	
	# 제목
	var title = Label.new()
	title.text = martial.name
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	# 설명
	var desc = Label.new()
	desc.text = martial.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc)
	
	# 스탯
	var stats_text = """
데미지: %d
에너지: %d
쿨타임: %.2f초
명중률: %.0f%%
치명타: %.0f%%

방어 타입: %s
상태 효과: %s
파워: %.1f
""" % [
		int(martial.power),
		int(martial.energy_cost),
		martial.cooldown,
		martial.accuracy * 100,
		martial.critical_chance * 100,
		martial.defense_type,
		martial.status_effect if martial.status_effect else "없음",
		martial.power_level
	]
	
	var stats_label = Label.new()
	stats_label.text = stats_text
	stats_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(stats_label)
	
	# 버튼
	var hbox = HBoxContainer.new()
	
	var upgrade_button = Button.new()
	upgrade_button.text = "강화 (%d 골드)" % (martial.level * 100)
	upgrade_button.pressed.connect(func(): _upgrade_martial_art(martial))
	hbox.add_child(upgrade_button)
	
	var equip_button = Button.new()
	equip_button.text = "장착"
	equip_button.pressed.connect(func(): _equip_martial_art(martial))
	hbox.add_child(equip_button)
	
	vbox.add_child(hbox)
	item_detail_panel.add_child(vbox)

func _upgrade_martial_art(martial: MartialArt):
	"""무술 강화"""
	var cost = martial.level * 100
	if player.gold >= cost:
		player.gold -= cost
		martial.level += 1
		martial.power *= 1.1
		_show_martial_arts()  # UI 갱신

func _equip_martial_art(martial: MartialArt):
	"""무술 장착"""
	player.equipped_martial_arts.append(martial)
	print("무술 장착: %s" % martial.name)

## ===== 장비 탭 =====

func _show_equipment():
	"""장비 표시"""
	var vbox = VBoxContainer.new()
	
	# 슬롯별 장비 표시
	var slots = {
		"머리": player.equipment.get("head"),
		"몸": player.equipment.get("body"),
		"손": player.equipment.get("hands"),
		"다리": player.equipment.get("legs"),
		"발": player.equipment.get("feet")
	}
	
	for slot_name in slots.keys():
		var item = slots[slot_name]
		var slot_label = Label.new()
		slot_label.text = "%s: %s" % [slot_name, item.name if item else "없음"]
		vbox.add_child(slot_label)
	
	content_area.add_child(vbox)

## ===== 아이템 탭 =====

func _show_items():
	"""아이템 표시"""
	var grid = GridContainer.new()
	grid.columns = 5
	
	for item in player.inventory:
		var grid_item = _create_item_grid_item(item)
		grid.add_child(grid_item)
	
	content_area.add_child(grid)

func _create_item_grid_item(item: Item) -> PanelContainer:
	"""아이템 그리드 아이템 생성"""
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(60, 60)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var icon = Label.new()
	icon.text = item.icon if item.icon else "?"
	icon.add_theme_font_size_override("font_size", 24)
	vbox.add_child(icon)
	
	var count_label = Label.new()
	count_label.text = "x%d" % item.quantity
	count_label.add_theme_font_size_override("font_size", 8)
	vbox.add_child(count_label)
	
	panel.add_child(vbox)
	return panel

## ===== 스탯 탭 =====

func _show_stats():
	"""플레이어 스탯 표시"""
	var vbox = VBoxContainer.new()
	
	var stats_text = """
레벨: %d
경험치: %d / %d (%.1f%%)
골드: %d

== 기본 스탯 ==
STR (힘): %d
DEX (민첩성): %d
CON (건강): %d
INT (지능): %d
WIS (지혜): %d
CHA (매력): %d

== 전투 스탯 ==
체력: %.0f / %.0f
에너지: %.0f / %.0f
물리 방어: %d
마법 방어: %d
회피율: %.0f%%
명중률: %.0f%%
치명타: %.0f%%

== 저항 ==
화염 저항: %.0f%%
냉기 저항: %.0f%%
전기 저항: %.0f%%
독 저항: %.0f%%
""" % [
		player.level,
		int(player.experience),
		int(player.next_level_exp),
		(player.experience / player.next_level_exp) * 100,
		player.gold,
		player.stats.strength,
		player.stats.dexterity,
		player.stats.constitution,
		player.stats.intelligence,
		player.stats.wisdom,
		player.stats.charisma,
		player.health,
		player.max_health,
		player.energy,
		player.max_energy,
		int(player.physical_defense),
		int(player.magical_defense),
		player.evasion_rate * 100,
		player.accuracy_rate * 100,
		player.critical_chance * 100,
		player.resistances.get("fire", 0),
		player.resistances.get("ice", 0),
		player.resistances.get("lightning", 0),
		player.resistances.get("poison", 0)
	]
	
	var label = Label.new()
	label.text = stats_text
	label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(label)
	
	content_area.add_child(vbox)

## ===== 유틸리티 =====

func _get_motion_type_color(motion_type: String) -> Color:
	"""motion_type에 따른 색상"""
	match motion_type:
		"punch":
			return Color.RED
		"kick":
			return Color.BLUE
		"palm":
			return Color.CYAN
		"spin":
			return Color.YELLOW
		"thrust":
			return Color.ORANGE
		"sweep":
			return Color.PURPLE
		_:
			return Color.WHITE

func _on_close_pressed():
	"""인벤토리 닫기"""
	inventory_closed.emit()
	queue_free()

func _process(delta: float):
	"""입력 처리"""
	if Input.is_action_just_pressed("inventory"):
		_on_close_pressed()
