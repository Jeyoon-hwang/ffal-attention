extends Control

# ============================================================================
# Map System - 월드맵, 미니맵, 던전맵
# ============================================================================
# Week 3 Day 6: 맵 UI 시스템
# 담당: 천재 ⚡
# ============================================================================

# 맵 데이터
var zones = [
	{"name": "중원 (Central Plains)", "color": Color.GREEN, "pos": Vector2(250, 150), "discovered": true},
	{"name": "동산 (East Mountains)", "color": Color.GRAY, "pos": Vector2(400, 150), "discovered": false},
	{"name": "서해 (West Sea)", "color": Color.CYAN, "pos": Vector2(100, 150), "discovered": false},
	{"name": "남빙원 (South Tundra)", "color": Color.LIGHT_BLUE, "pos": Vector2(250, 300), "discovered": false},
	{"name": "북황무지 (North Wasteland)", "color": Color.ORANGE, "pos": Vector2(250, 50), "discovered": false}
]

var dungeons = {
	"central_plains": [
		{"name": "입문자 던전", "level": 1, "pos": Vector2(250, 180), "discovered": true},
		{"name": "중급 던전", "level": 5, "pos": Vector2(270, 150), "discovered": false},
		{"name": "상급 던전", "level": 10, "pos": Vector2(230, 150), "discovered": false},
		{"name": "최종 던전", "level": 20, "pos": Vector2(250, 120), "discovered": false}
	]
}

# UI 컴포넌트
var map_type = "world"  # world, dungeon, minimap
var map_canvas: Control
var player_marker: Control
var selected_zone = 0
var zone_detail_label: Label

# 설정
var tile_size = 20
var minimap_size = Vector2(200, 150)

# ============================================================================
# 초기화
# ============================================================================

func _ready():
	# 윈도우 설정
	anchor_right = 0.5
	anchor_bottom = 1.0
	
	# 배경
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.9)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	add_child(bg)
	
	# === 제목 ===
	var title = Label.new()
	title.text = "월드맵"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)
	
	# === 맵 캔버스 ===
	map_canvas = Control.new()
	map_canvas.position = Vector2(10, 50)
	map_canvas.custom_minimum_size = Vector2(450, 300)
	add_child(map_canvas)
	
	# === 지역 정보 ===
	zone_detail_label = Label.new()
	zone_detail_label.position = Vector2(10, 360)
	zone_detail_label.custom_minimum_size = Vector2(450, 120)
	zone_detail_label.text = "지역을 선택하세요."
	zone_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(zone_detail_label)
	
	# === 닫기 버튼 ===
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.position = Vector2(430, 10)
	close_btn.custom_minimum_size = Vector2(30, 30)
	add_child(close_btn)
	close_btn.pressed.connect(Callable(self, "hide"))
	
	# 맵 그리기
	_draw_world_map()

# ============================================================================
# 월드맵 그리기
# ============================================================================

func _draw_world_map():
	"""월드맵 그리기"""
	# 캔버스 초기화
	for child in map_canvas.get_children():
		child.queue_free()
	
	# 배경 (격자)
	for y in range(0, 300, 20):
		for x in range(0, 450, 20):
			var grid_point = ColorRect.new()
			grid_point.color = Color(0.3, 0.3, 0.3, 0.3)
			grid_point.position = Vector2(x, y)
			grid_point.size = Vector2(1, 1)
			map_canvas.add_child(grid_point)
	
	# 지역 표시
	for i in range(zones.size()):
		var zone = zones[i]
		
		# 지역 원
		var zone_circle = Control.new()
		zone_circle.position = zone["pos"]
		zone_circle.custom_minimum_size = Vector2(50, 50)
		map_canvas.add_child(zone_circle)
		
		# 색상 (발견 여부에 따라)
		var color = zone["color"] if zone["discovered"] else Color(0.5, 0.5, 0.5, 0.5)
		
		# 지역 원형 표시
		var circle = ColorRect.new()
		circle.color = color
		circle.position = zone["pos"] - Vector2(25, 25)
		circle.size = Vector2(50, 50)
		map_canvas.add_child(circle)
		
		# 지역명
		var label = Label.new()
		label.text = zone["name"].split(" ")[0]
		label.position = zone["pos"] - Vector2(15, -30)
		label.add_theme_font_size_override("font_size", 12)
		map_canvas.add_child(label)
		
		# 클릭 감지
		var btn = Button.new()
		btn.position = zone["pos"] - Vector2(25, 25)
		btn.custom_minimum_size = Vector2(50, 50)
		btn.modulate.a = 0.0  # 보이지 않는 버튼
		map_canvas.add_child(btn)
		btn.pressed.connect(Callable(self, "_on_zone_selected").bind(i))

# ============================================================================
# 지역 선택
# ============================================================================

func _on_zone_selected(zone_index: int):
	"""지역 선택"""
	selected_zone = zone_index
	var zone = zones[zone_index]
	
	zone_detail_label.text = ""
	zone_detail_label.text += "이름: " + zone["name"] + "\n"
	zone_detail_label.text += "상태: " + ("발견함" if zone["discovered"] else "미발견") + "\n\n"
	zone_detail_label.text += "던전:\n"
	
	# 던전 목록 (아직 미구현)
	if zone_index == 0:  # 중원
		zone_detail_label.text += "- 입문자 던전 (Lv. 1)\n"
		zone_detail_label.text += "- 중급 던전 (Lv. 5)\n"
		zone_detail_label.text += "- 상급 던전 (Lv. 10)\n"
		zone_detail_label.text += "- 최종 던전 (Lv. 20)\n"

# ============================================================================
# 미니맵 (우측 상단)
# ============================================================================

func draw_minimap():
	"""미니맵 그리기 (HUD의 우측 상단)"""
	# 이는 HUDSystem에서 호출될 수 있음
	pass

func update_minimap_player(x: float, y: float):
	"""플레이어 위치 업데이트"""
	# 미니맵에서 플레이어 마커 업데이트
	pass

# ============================================================================
# 던전맵
# ============================================================================

func show_dungeon_map(zone_index: int, dungeon_index: int):
	"""던전맵 표시"""
	map_type = "dungeon"
	
	# 던전맵 렌더링
	for child in map_canvas.get_children():
		child.queue_free()
	
	# 간단한 던전 맵: 격자 기반
	var dungeon_width = 10
	var dungeon_height = 10
	var cell_size = 30
	
	for y in range(dungeon_height):
		for x in range(dungeon_width):
			var cell = ColorRect.new()
			cell.color = Color(0.3, 0.3, 0.4, 0.7)
			cell.position = Vector2(x * cell_size, y * cell_size)
			cell.size = Vector2(cell_size - 2, cell_size - 2)
			map_canvas.add_child(cell)

# ============================================================================
# 발견
# ============================================================================

func discover_zone(zone_index: int):
	"""지역 발견"""
	if zone_index < zones.size():
		zones[zone_index]["discovered"] = true
		_draw_world_map()
		print("[Map] " + zones[zone_index]["name"] + "을(를) 발견했습니다!")

func discover_dungeon(zone_index: int, dungeon_index: int):
	"""던전 발견"""
	print("[Map] 던전을 발견했습니다!")

# ============================================================================
# 텔레포트
# ============================================================================

func teleport_to_zone(zone_index: int) -> bool:
	"""지역으로 텔레포트"""
	if zones[zone_index]["discovered"]:
		print("[Map] " + zones[zone_index]["name"] + "로 이동했습니다!")
		return true
	else:
		print("[Map] 아직 발견하지 않은 지역입니다!")
		return false

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[Map] " + msg)
