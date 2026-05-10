extends CanvasLayer
class_name GameHUD
## 게임 중 HUD (헬스, 마나, 무술, 상태)

# UI 노드
@onready var player_health_bar = $VBoxContainer/HealthBar
@onready var player_energy_bar = $VBoxContainer/EnergyBar
@onready var level_label = $VBoxContainer/LevelLabel
@onready var exp_bar = $VBoxContainer/ExpBar
@onready var martial_art_list = $VBoxContainer/MartialArtList
@onready var status_container = $VBoxContainer/StatusContainer
@onready var enemy_health_bar = $EnemyHealthBar
@onready var damage_popup = $DamagePopup
@onready var mini_map = $MiniMap
@onready var quest_tracker = $QuestTracker

# 데이터
var player: Player
var current_enemy: Enemy

# 상태
var is_visible_hud: bool = true
var show_mini_map: bool = true

func _ready():
	"""초기화"""
	player = get_tree().root.get_child(0).get_node("Player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.energy_changed.connect(_on_player_energy_changed)
		player.level_changed.connect(_on_player_level_changed)
		player.exp_changed.connect(_on_player_exp_changed)
		player.martial_art_learned.connect(_on_martial_art_learned)
		player.status_effect_applied.connect(_on_status_effect_applied)
	
	_update_all_ui()

## ===== 플레이어 스탯 업데이트 =====

func _on_player_health_changed(new_health: float, max_health: float):
	"""플레이어 체력 업데이트"""
	player_health_bar.value = (new_health / max_health) * 100
	player_health_bar.get_node("Label").text = "%d / %d" % [int(new_health), int(max_health)]
	
	# 위험 상태면 색상 변경
	if new_health < max_health * 0.3:
		player_health_bar.modulate = Color.RED
	elif new_health < max_health * 0.6:
		player_health_bar.modulate = Color.YELLOW
	else:
		player_health_bar.modulate = Color.GREEN

func _on_player_energy_changed(new_energy: float, max_energy: float):
	"""플레이어 에너지 업데이트"""
	player_energy_bar.value = (new_energy / max_energy) * 100
	player_energy_bar.get_node("Label").text = "%d / %d" % [int(new_energy), int(max_energy)]

func _on_player_level_changed(new_level: int):
	"""레벨 업데이트"""
	level_label.text = "Level %d" % new_level

func _on_player_exp_changed(new_exp: float, next_exp: float):
	"""경험치 업데이트"""
	exp_bar.value = (new_exp / next_exp) * 100
	exp_bar.get_node("Label").text = "EXP %.0f%%" % exp_bar.value

func _on_martial_art_learned(martial_art: MartialArt):
	"""새로운 무술 배움"""
	var item = _create_martial_art_list_item(martial_art)
	martial_art_list.add_child(item)
	_animate_new_item(item)

func _on_status_effect_applied(effect_name: String, duration: float):
	"""상태 효과 적용"""
	var status_icon = _create_status_icon(effect_name, duration)
	status_container.add_child(status_icon)
	
	# duration이 끝나면 자동 제거
	await get_tree().create_timer(duration).timeout
	status_icon.queue_free()

## ===== 무술 목록 UI =====

func _create_martial_art_list_item(martial_art: MartialArt) -> PanelContainer:
	"""무술 목록 아이템 생성"""
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	
	# 무술 이름 & 레벨
	var name_label = Label.new()
	name_label.text = "%s [Lv.%d]" % [martial_art.name, martial_art.level]
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)
	
	# 무술 정보
	var info_label = Label.new()
	var info_text = "%s | 데미지: %d | 비용: %d 에너지" % [
		martial_art.motion_type.to_upper(),
		int(martial_art.power),
		int(martial_art.energy_cost)
	]
	info_label.text = info_text
	info_label.add_theme_font_size_override("font_size", 10)
	info_label.modulate = Color.GRAY
	vbox.add_child(info_label)
	
	# 프로그레스 바 (강화도)
	var progress = ProgressBar.new()
	progress.value = martial_art.level % 10 * 10  # 1-10 레벨 반복
	progress.custom_minimum_size = Vector2(200, 8)
	vbox.add_child(progress)
	
	panel.add_child(vbox)
	return panel

func _animate_new_item(item: Node):
	"""새 아이템 애니메이션 (스케일 & 페이드인)"""
	item.scale = Vector2.ZERO
	item.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "scale", Vector2.ONE, 0.3)
	tween.tween_property(item, "modulate:a", 1.0, 0.3)

## ===== 상태 효과 아이콘 =====

func _create_status_icon(effect_name: String, duration: float) -> TextureRect:
	"""상태 효과 아이콘 생성"""
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(40, 40)
	
	# 효과별 색상
	var color = Color.WHITE
	match effect_name:
		"stun":
			color = Color.YELLOW
		"frozen":
			color = Color.CYAN
		"burn":
			color = Color.ORANGE_RED
		"poison":
			color = Color.GREEN
		"bleed":
			color = Color.RED
	
	icon.modulate = color
	
	# 타이머 표시 (타이머 추가 가능)
	var timer_label = Label.new()
	timer_label.text = effect_name.to_upper()[0]  # 첫글자
	timer_label.add_theme_font_size_override("font_size", 20)
	icon.add_child(timer_label)
	
	return icon

## ===== 적 정보 =====

func set_current_enemy(enemy: Enemy):
	"""전투 중인 적 설정"""
	current_enemy = enemy
	enemy_health_bar.visible = true
	enemy_health_bar.get_node("Label").text = enemy.name
	_update_enemy_health()

func _update_enemy_health():
	"""적 체력 업데이트"""
	if current_enemy == null:
		enemy_health_bar.visible = false
		return
	
	enemy_health_bar.value = (current_enemy.health / current_enemy.max_health) * 100

func show_damage_popup(position: Vector2, damage: float, is_crit: bool = false):
	"""데미지 팝업 표시"""
	var popup = Label.new()
	popup.text = str(int(damage))
	popup.add_theme_font_size_override("font_size", 24)
	popup.modulate = Color.RED if is_crit else Color.WHITE
	popup.position = position
	
	damage_popup.add_child(popup)
	
	# 위로 떠올랐다가 사라짐
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", position.y - 50, 1.0)
	tween.tween_property(popup, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	popup.queue_free()

## ===== 미니맵 =====

func update_mini_map(player_pos: Vector3, enemies: Array[Enemy]):
	"""미니맵 업데이트"""
	mini_map.queue_redraw()  # 재그리기 신호
	# 실제 그리기는 _draw_mini_map()에서

func _draw_mini_map():
	"""미니맵 그리기 (커스텀)"""
	# 플레이어 위치를 미니맵 중심에
	# 적 위치 표시
	# 환경 표시
	pass

## ===== 퀘스트 추적 =====

func track_quest(quest: Quest):
	"""퀘스트 추적 시작"""
	var quest_item = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "[%s] %s" % [quest.category, quest.name]
	title.add_theme_font_size_override("font_size", 12)
	quest_item.add_child(title)
	
	var description = Label.new()
	description.text = quest.description
	description.add_theme_font_size_override("font_size", 10)
	description.modulate = Color.GRAY
	description.custom_minimum_size = Vector2(200, 0)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	quest_item.add_child(description)
	
	quest_tracker.add_child(quest_item)

func update_quest_progress(quest: Quest, progress: int, total: int):
	"""퀘스트 진행도 업데이트"""
	# quest_tracker에서 해당 퀘스트 찾아서 진행도 업데이트
	pass

## ===== 토글 =====

func toggle_hud():
	"""HUD 토글"""
	is_visible_hud = !is_visible_hud
	player_health_bar.visible = is_visible_hud
	player_energy_bar.visible = is_visible_hud
	level_label.visible = is_visible_hud
	martial_art_list.visible = is_visible_hud

func toggle_mini_map():
	"""미니맵 토글"""
	show_mini_map = !show_mini_map
	mini_map.visible = show_mini_map

## ===== 전체 업데이트 =====

func _update_all_ui():
	"""모든 UI 업데이트"""
	if player:
		_on_player_health_changed(player.health, player.max_health)
		_on_player_energy_changed(player.energy, player.max_energy)
		_on_player_level_changed(player.level)
		_on_player_exp_changed(player.experience, player.next_level_exp)
		
		# 무술 목록
		martial_art_list.clear()
		for martial in player.learned_martial_arts:
			var item = _create_martial_art_list_item(martial)
			martial_art_list.add_child(item)

func _process(delta: float):
	"""매 프레임 업데이트"""
	if current_enemy:
		_update_enemy_health()
