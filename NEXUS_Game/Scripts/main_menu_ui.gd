extends Control
class_name MainMenuUI
## 메인 메뉴 UI

@onready var title_label = $VBoxContainer/Title
@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var continue_button = $VBoxContainer/ContinueButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var version_label = $VersionLabel
@onready var background_image = $BackgroundImage

signal start_new_game
signal continue_game
signal open_settings
signal quit_game

func _ready():
	"""초기화"""
	title_label.text = "🥋 NEXUS"
	version_label.text = "v1.0.0-beta (Week 3)"
	
	# 버튼 연결
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# 저장 파일이 없으면 continue 비활성화
	if not _has_save_file():
		continue_button.disabled = true
		continue_button.modulate = Color.GRAY
	
	# 배경 애니메이션
	_animate_background()

func _animate_background():
	"""배경 천천히 회전"""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(background_image, "rotation", TAU, 30.0)

func _on_new_game_pressed():
	"""새 게임 시작"""
	_show_character_creation()

func _show_character_creation():
	"""캐릭터 생성 씬으로"""
	var dialog = ConfirmationDialog.new()
	dialog.title = "캐릭터 생성"
	dialog.text = "게임을 시작합니다.\n캐릭터 이름을 입력하세요."
	
	var name_input = LineEdit.new()
	name_input.placeholder_text = "캐릭터 이름"
	dialog.add_child(name_input)
	
	dialog.confirmed.connect(func():
		var char_name = name_input.text if name_input.text else "용사"
		start_new_game.emit(char_name)
		get_tree().change_scene_to_file("res://Scenes/game.tscn")
	)
	
	add_child(dialog)
	dialog.popup_centered(Vector2(300, 150))

func _on_continue_pressed():
	"""이어하기"""
	continue_game.emit()
	# 저장 파일 로드
	var game_manager = get_tree().root.get_node("GameManager")
	if game_manager:
		game_manager.load_game()
	
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_settings_pressed():
	"""설정 열기"""
	open_settings.emit()
	_show_settings_dialog()

func _show_settings_dialog():
	"""설정 다이얼로그 표시"""
	var dialog = Window.new()
	dialog.title = "설정"
	dialog.size = Vector2i(400, 300)
	
	var vbox = VBoxContainer.new()
	
	# 볼륨 설정
	var volume_label = Label.new()
	volume_label.text = "음량"
	vbox.add_child(volume_label)
	
	var volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.value = 80
	vbox.add_child(volume_slider)
	
	# 그래픽 설정
	var graphics_label = Label.new()
	graphics_label.text = "그래픽"
	vbox.add_child(graphics_label)
	
	var graphics_option = OptionButton.new()
	graphics_option.add_item("낮음")
	graphics_option.add_item("중간")
	graphics_option.add_item("높음")
	graphics_option.select(1)
	vbox.add_child(graphics_option)
	
	# 닫기 버튼
	var close_button = Button.new()
	close_button.text = "닫기"
	close_button.pressed.connect(func(): dialog.queue_free())
	vbox.add_child(close_button)
	
	dialog.add_child(vbox)
	add_child(dialog)
	dialog.popup_centered()

func _on_quit_pressed():
	"""게임 종료"""
	quit_game.emit()
	get_tree().quit()

func _has_save_file() -> bool:
	"""저장 파일 존재 여부"""
	return ResourceLoader.exists("user://savegame.res")

## ===== 버튼 애니메이션 =====

func _on_button_mouse_entered(button: Button):
	"""버튼에 마우스 올렸을 때"""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)

func _on_button_mouse_exited(button: Button):
	"""버튼에서 마우스 떠났을 때"""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.2)

func _process(delta: float):
	"""입력 처리"""
	if Input.is_action_just_pressed("ui_cancel"):
		_on_quit_pressed()
