extends Control

# ============================================================================
# Inventory System - 무술, 장비, 아이템 관리
# ============================================================================
# Week 3 Day 6: 인벤토리 UI
# 담당: 천재 ⚡
# ============================================================================

# 인벤토리 구조
var martial_arts = []  # 무술 목록
var equipment = {
	"weapon": null,
	"armor": null,
	"gloves": null,
	"boots": null,
	"accessory": null
}
var items = []  # 소비 아이템 (물약, 버프 등)
var quest_items = []  # 퀘스트 아이템

# UI 컴포넌트
var tabs = {}  # 탭 (무술, 장비, 아이템, 퀘스트)
var martial_art_list: VBoxContainer
var equipment_display: VBoxContainer
var item_list: VBoxContainer
var quest_item_list: VBoxContainer
var selected_item = null
var item_detail_label: Label

# 설정
var max_martial_arts = 20
var max_items = 30
var is_open = false

# ============================================================================
# 초기화
# ============================================================================

func _ready():
	# 윈도우 설정
	anchor_left = 0.7
	anchor_top = 0.1
	anchor_right = 0.99
	anchor_bottom = 0.9
	
	# 배경
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 0.9)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	add_child(bg)
	
	# === 제목 ===
	var title = Label.new()
	title.text = "인벤토리"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)
	
	# === 탭 버튼 ===
	var tab_container = HBoxContainer.new()
	tab_container.position = Vector2(10, 40)
	tab_container.size.x = 280
	add_child(tab_container)
	
	var tab_names = ["무술", "장비", "아이템", "퀘스트"]
	for tab_name in tab_names:
		var btn = Button.new()
		btn.text = tab_name
		btn.custom_minimum_size = Vector2(70, 30)
		tab_container.add_child(btn)
		tabs[tab_name] = btn
		btn.pressed.connect(Callable(self, "_on_tab_selected").bind(tab_name))
	
	# === 컨텐츠 영역 ===
	var content = Control.new()
	content.position = Vector2(10, 80)
	content.size = Vector2(280, 400)
	add_child(content)
	
	# 무술 리스트
	martial_art_list = VBoxContainer.new()
	martial_art_list.anchor_right = 1
	martial_art_list.anchor_bottom = 1
	content.add_child(martial_art_list)
	
	# 장비 디스플레이
	equipment_display = VBoxContainer.new()
	equipment_display.anchor_right = 1
	equipment_display.anchor_bottom = 1
	equipment_display.visible = false
	content.add_child(equipment_display)
	_setup_equipment_display()
	
	# 아이템 리스트
	item_list = VBoxContainer.new()
	item_list.anchor_right = 1
	item_list.anchor_bottom = 1
	item_list.visible = false
	content.add_child(item_list)
	
	# 퀘스트 아이템 리스트
	quest_item_list = VBoxContainer.new()
	quest_item_list.anchor_right = 1
	quest_item_list.anchor_bottom = 1
	quest_item_list.visible = false
	content.add_child(quest_item_list)
	
	# === 아이템 상세 정보 ===
	item_detail_label = Label.new()
	item_detail_label.position = Vector2(10, 490)
	item_detail_label.size = Vector2(280, 80)
	item_detail_label.text = "아이템을 선택하면 정보가 표시됩니다."
	item_detail_label.custom_minimum_size = Vector2(280, 80)
	item_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(item_detail_label)
	
	# === 닫기 버튼 ===
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.position = Vector2(260, 10)
	close_btn.custom_minimum_size = Vector2(30, 30)
	add_child(close_btn)
	close_btn.pressed.connect(Callable(self, "hide"))

# ============================================================================
# 탭 전환
# ============================================================================

func _on_tab_selected(tab_name: String):
	"""탭 선택"""
	martial_art_list.visible = (tab_name == "무술")
	equipment_display.visible = (tab_name == "장비")
	item_list.visible = (tab_name == "아이템")
	quest_item_list.visible = (tab_name == "퀘스트")

# ============================================================================
# 무술 관리
# ============================================================================

func add_martial_art(art_data: Dictionary) -> bool:
	"""무술 추가"""
	if martial_arts.size() >= max_martial_arts:
		print("[Inventory] 무술 슬롯이 가득 찼습니다!")
		return false
	
	martial_arts.append(art_data)
	_refresh_martial_art_list()
	return true

func remove_martial_art(art_name: String):
	"""무술 제거"""
	for i in range(martial_arts.size()):
		if martial_arts[i]["name"] == art_name:
			martial_arts.remove_at(i)
			_refresh_martial_art_list()
			return

func _refresh_martial_art_list():
	"""무술 리스트 새로고침"""
	# 기존 항목 제거
	for child in martial_art_list.get_children():
		child.queue_free()
	
	# 새 항목 추가
	for art in martial_arts:
		var item = _create_martial_art_item(art)
		martial_art_list.add_child(item)

func _create_martial_art_item(art: Dictionary) -> Control:
	"""무술 아이템 UI 생성"""
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 50)
	
	# 무술명
	var name_label = Label.new()
	name_label.text = art["name"]
	name_label.custom_minimum_size = Vector2(150, 0)
	container.add_child(name_label)
	
	# 능력치
	var damage_label = Label.new()
	damage_label.text = "DMG: %d" % art.get("damage", 10)
	damage_label.custom_minimum_size = Vector2(60, 0)
	container.add_child(damage_label)
	
	# 클릭 감지
	var btn = Button.new()
	btn.text = "사용"
	btn.custom_minimum_size = Vector2(50, 0)
	container.add_child(btn)
	btn.pressed.connect(Callable(self, "_on_martial_art_selected").bind(art))
	
	return container

func _on_martial_art_selected(art: Dictionary):
	"""무술 선택"""
	selected_item = art
	_update_item_detail(art)

# ============================================================================
# 장비 관리
# ============================================================================

func _setup_equipment_display():
	"""장비 표시 UI 초기화"""
	var slots = ["weapon", "armor", "gloves", "boots", "accessory"]
	var slot_names = ["무기", "방어구", "장갑", "부츠", "액세서리"]
	
	for i in range(slots.size()):
		var container = HBoxContainer.new()
		container.custom_minimum_size = Vector2(0, 40)
		
		var label = Label.new()
		label.text = slot_names[i] + ":"
		label.custom_minimum_size = Vector2(80, 0)
		container.add_child(label)
		
		var item_label = Label.new()
		item_label.text = "비어있음"
		item_label.custom_minimum_size = Vector2(120, 0)
		container.add_child(item_label)
		
		var btn = Button.new()
		btn.text = "장착"
		btn.custom_minimum_size = Vector2(50, 0)
		container.add_child(btn)
		
		equipment_display.add_child(container)

func equip_item(slot: String, item: Dictionary):
	"""장비 장착"""
	equipment[slot] = item
	_refresh_equipment_display()

# ============================================================================
# 아이템 관리
# ============================================================================

func add_item(item_data: Dictionary) -> bool:
	"""아이템 추가"""
	if items.size() >= max_items:
		print("[Inventory] 아이템 슬롯이 가득 찼습니다!")
		return false
	
	items.append(item_data)
	_refresh_item_list()
	return true

func use_item(item_name: String) -> bool:
	"""아이템 사용"""
	for i in range(items.size()):
		if items[i]["name"] == item_name:
			var item = items[i]
			items.remove_at(i)
			_refresh_item_list()
			print("[Inventory] " + item_name + "을(를) 사용했습니다.")
			return true
	return false

func _refresh_item_list():
	"""아이템 리스트 새로고침"""
	for child in item_list.get_children():
		child.queue_free()
	
	for item in items:
		var container = HBoxContainer.new()
		container.custom_minimum_size = Vector2(0, 40)
		
		var name_label = Label.new()
		name_label.text = item["name"]
		name_label.custom_minimum_size = Vector2(150, 0)
		container.add_child(name_label)
		
		var qty_label = Label.new()
		qty_label.text = "x" + str(item.get("quantity", 1))
		qty_label.custom_minimum_size = Vector2(40, 0)
		container.add_child(qty_label)
		
		var use_btn = Button.new()
		use_btn.text = "사용"
		use_btn.custom_minimum_size = Vector2(50, 0)
		container.add_child(use_btn)
		use_btn.pressed.connect(Callable(self, "_on_item_selected").bind(item))
		
		item_list.add_child(container)

func _on_item_selected(item: Dictionary):
	"""아이템 선택"""
	selected_item = item
	_update_item_detail(item)

# ============================================================================
# 퀘스트 아이템
# ============================================================================

func add_quest_item(item_name: String):
	"""퀘스트 아이템 추가"""
	if not quest_items.has(item_name):
		quest_items.append(item_name)
		_refresh_quest_item_list()

func _refresh_quest_item_list():
	"""퀘스트 아이템 리스트 새로고침"""
	for child in quest_item_list.get_children():
		child.queue_free()
	
	for item_name in quest_items:
		var label = Label.new()
		label.text = "- " + item_name
		label.custom_minimum_size = Vector2(0, 30)
		quest_item_list.add_child(label)

# ============================================================================
# 내부 헬퍼
# ============================================================================

func _update_item_detail(item: Dictionary):
	"""아이템 상세 정보 업데이트"""
	var detail_text = ""
	detail_text += "이름: " + item.get("name", "Unknown") + "\n"
	detail_text += "설명: " + item.get("description", "설명이 없습니다.") + "\n"
	
	if "damage" in item:
		detail_text += "데미지: " + str(item["damage"]) + "\n"
	if "effect" in item:
		detail_text += "효과: " + item["effect"] + "\n"
	
	item_detail_label.text = detail_text

func _refresh_equipment_display():
	"""장비 정보 새로고침"""
	var equipment_display_text = ""
	for slot in ["weapon", "armor", "gloves", "boots", "accessory"]:
		if equipment[slot]:
			equipment_display_text += slot + ": " + equipment[slot]["name"] + "\n"
		else:
			equipment_display_text += slot + ": (없음)\n"

# ============================================================================
# 디버그 / 테스트 데이터
# ============================================================================

func _add_test_data():
	"""테스트 데이터 추가"""
	add_martial_art({
		"name": "기본 검술",
		"damage": 10,
		"description": "가장 기본적인 검술"
	})
	add_martial_art({
		"name": "회전참",
		"damage": 15,
		"description": "빙글 돌면서 치는 검술"
	})
	
	add_item({
		"name": "빨간 물약",
		"description": "체력을 50 회복",
		"quantity": 3,
		"effect": "HP +50"
	})
	
	add_quest_item("황금 열쇠")

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[Inventory] " + msg)
