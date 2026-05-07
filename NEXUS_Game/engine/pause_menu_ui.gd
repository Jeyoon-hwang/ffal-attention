extends CanvasLayer

# ============================================================================
# Pause Menu UI - 게임 일시정지 메뉴
# ============================================================================
# Week 3 Day 6: 일시정지 메뉴
# 담당: 천재 ⚡
# ============================================================================

var ui_manager = null
var is_visible = false

# ============================================================================
# 초기화
# ============================================================================

func _ready():
	# UI Manager 참조
	ui_manager = UIManager.get_instance() if get_tree().has_meta("UIManager") else null
	
	# 기본적으로 숨김
	hide()

# ============================================================================
# 표시 / 숨김
# ============================================================================

func show():
	"""일시정지 메뉴 표시"""
	is_visible = true
	
	# 기존 UI 제거
	for child in get_children():
		child.queue_free()
	
	var viewport_size = get_viewport_rect().size
	var center_x = viewport_size.x / 2
	var center_y = viewport_size.y / 2
	
	# === 반투명 오버레이 ===
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.anchor_left = 0
	overlay.anchor_top = 0
	overlay.anchor_right = 1
	overlay.anchor_bottom = 1
	add_child(overlay)
	
	# === 제목 ===
	var title = Label.new()
	title.text = "⏸ 일시정지"
	title.position = Vector2(center_x - 100, center_y - 120)
	title.add_theme_font_size_override("font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# === 버튼들 ===
	var buttons_data = [
		{"label": "게임 재개", "callback": "_on_resume"},
		{"label": "설정", "callback": "_on_settings"},
		{"label": "메인 메뉴", "callback": "_on_main_menu"}
	]
	
	var btn_y = center_y - 20
	for btn_data in buttons_data:
		var btn = Button.new()
		btn.text = btn_data["label"]
		btn.position = Vector2(center_x - 100, btn_y)
		btn.custom_minimum_size = Vector2(200, 60)
		btn.add_theme_font_size_override("font_size", 20)
		add_child(btn)
		btn.pressed.connect(Callable(self, btn_data["callback"]))
		btn_y += 80

func _on_resume():
	"""게임 재개"""
	if ui_manager:
		ui_manager.resume_game()
	hide()

func _on_settings():
	"""일시정지 중 설정"""
	print("[PauseMenu] 설정을 엽니다.")
	# 설정 메뉴 표시

func _on_main_menu():
	"""메인 메뉴로"""
	print("[PauseMenu] 메인 메뉴로 이동합니다.")
	get_tree().reload_current_scene()

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[PauseMenu] " + msg)
