extends CanvasLayer

# ============================================================================
# Menu System - 메인 메뉴, 설정
# ============================================================================
# Week 3 Day 6: 메뉴 UI
# 담당: 천재 ⚡
# ============================================================================

# 메뉴 상태
enum MenuState {
	MAIN,
	SETTINGS,
	CREDITS
}

var current_menu = MenuState.MAIN
var ui_manager = null

# 설정
var settings = {
	"volume": 0.8,
	"brightness": 1.0,
	"graphics_quality": 2  # 0=LOW, 1=MEDIUM, 2=HIGH, 3=ULTRA
}

# ============================================================================
# 초기화
# ============================================================================

func _ready():
	# UI Manager 참조
	ui_manager = UIManager.get_instance() if get_tree().has_meta("UIManager") else null
	
	# 이 메뉴는 게임 시작 시 표시됨
	show_main_menu()

# ============================================================================
# 메인 메뉴
# ============================================================================

func show_main_menu():
	"""메인 메뉴 표시"""
	# 기존 UI 제거
	for child in get_children():
		child.queue_free()
	
	current_menu = MenuState.MAIN
	
	var viewport_size = get_viewport_rect().size
	var center_x = viewport_size.x / 2
	var center_y = viewport_size.y / 2
	
	# === 배경 ===
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	add_child(bg)
	
	# === 제목 ===
	var title = Label.new()
	title.text = "⚡ NEXUS 무술 창조 ⚡"
	title.position = Vector2(center_x - 200, center_y - 150)
	title.custom_minimum_size = Vector2(400, 80)
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# === 버튼들 ===
	var buttons_data = [
		{"label": "새 게임", "callback": "_on_new_game"},
		{"label": "계속", "callback": "_on_continue"},
		{"label": "설정", "callback": "_on_settings"},
		{"label": "종료", "callback": "_on_quit"}
	]
	
	var button_y = center_y
	for btn_data in buttons_data:
		var btn = Button.new()
		btn.text = btn_data["label"]
		btn.position = Vector2(center_x - 100, button_y)
		btn.custom_minimum_size = Vector2(200, 50)
		btn.add_theme_font_size_override("font_size", 20)
		add_child(btn)
		btn.pressed.connect(Callable(self, btn_data["callback"]))
		button_y += 70

# ============================================================================
# 메인 메뉴 콜백
# ============================================================================

func _on_new_game():
	"""새 게임 시작"""
	print("[Menu] 새 게임을 시작합니다...")
	# 게임 시작 로직
	if ui_manager:
		ui_manager.show_game()

func _on_continue():
	"""게임 계속"""
	print("[Menu] 게임을 계속합니다...")
	# 저장된 게임 로드
	if ui_manager:
		ui_manager.show_game()

func _on_settings():
	"""설정 메뉴로"""
	show_settings_menu()

func _on_quit():
	"""게임 종료"""
	print("[Menu] 게임을 종료합니다...")
	get_tree().quit()

# ============================================================================
# 설정 메뉴
# ============================================================================

func show_settings_menu():
	"""설정 메뉴 표시"""
	for child in get_children():
		child.queue_free()
	
	current_menu = MenuState.SETTINGS
	
	var viewport_size = get_viewport_rect().size
	var center_x = viewport_size.x / 2
	var center_y = viewport_size.y / 2
	
	# === 배경 ===
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	add_child(bg)
	
	# === 제목 ===
	var title = Label.new()
	title.text = "설정"
	title.position = Vector2(center_x - 100, center_y - 150)
	title.add_theme_font_size_override("font_size", 36)
	add_child(title)
	
	var y = center_y - 80
	
	# === 음량 ===
	var vol_label = Label.new()
	vol_label.text = "음량: %.0f%%" % (settings["volume"] * 100)
	vol_label.position = Vector2(center_x - 150, y)
	add_child(vol_label)
	
	var vol_slider = HSlider.new()
	vol_slider.position = Vector2(center_x - 150, y + 30)
	vol_slider.custom_minimum_size = Vector2(300, 30)
	vol_slider.value = settings["volume"] * 100
	vol_slider.min_value = 0
	vol_slider.max_value = 100
	add_child(vol_slider)
	vol_slider.value_changed.connect(Callable(self, "_on_volume_changed").bind(vol_label))
	y += 80
	
	# === 밝기 ===
	var bright_label = Label.new()
	bright_label.text = "밝기: %.1fx" % settings["brightness"]
	bright_label.position = Vector2(center_x - 150, y)
	add_child(bright_label)
	
	var bright_slider = HSlider.new()
	bright_slider.position = Vector2(center_x - 150, y + 30)
	bright_slider.custom_minimum_size = Vector2(300, 30)
	bright_slider.value = settings["brightness"] * 10
	bright_slider.min_value = 5
	bright_slider.max_value = 20
	add_child(bright_slider)
	bright_slider.value_changed.connect(Callable(self, "_on_brightness_changed").bind(bright_label))
	y += 80
	
	# === 그래픽 품질 ===
	var gfx_label = Label.new()
	var quality_names = ["LOW", "MEDIUM", "HIGH", "ULTRA"]
	gfx_label.text = "그래픽: " + quality_names[settings["graphics_quality"]]
	gfx_label.position = Vector2(center_x - 150, y)
	add_child(gfx_label)
	
	var quality_buttons = []
	for i in range(quality_names.size()):
		var btn = Button.new()
		btn.text = quality_names[i]
		btn.position = Vector2(center_x - 150 + i * 75, y + 30)
		btn.custom_minimum_size = Vector2(70, 30)
		add_child(btn)
		btn.pressed.connect(Callable(self, "_on_quality_changed").bind(i, gfx_label))
	
	y += 80
	
	# === 뒤로가기 ===
	var back_btn = Button.new()
	back_btn.text = "뒤로가기"
	back_btn.position = Vector2(center_x - 100, y)
	back_btn.custom_minimum_size = Vector2(200, 50)
	back_btn.add_theme_font_size_override("font_size", 18)
	add_child(back_btn)
	back_btn.pressed.connect(Callable(self, "show_main_menu"))

# ============================================================================
# 설정 콜백
# ============================================================================

func _on_volume_changed(value: float, label: Label):
	"""음량 변경"""
	settings["volume"] = value / 100.0
	label.text = "음량: %.0f%%" % (settings["volume"] * 100)

func _on_brightness_changed(value: float, label: Label):
	"""밝기 변경"""
	settings["brightness"] = value / 10.0
	label.text = "밝기: %.1fx" % settings["brightness"]

func _on_quality_changed(quality: int, label: Label):
	"""그래픽 품질 변경"""
	settings["graphics_quality"] = quality
	var quality_names = ["LOW", "MEDIUM", "HIGH", "ULTRA"]
	label.text = "그래픽: " + quality_names[quality]

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[Menu] " + msg)
