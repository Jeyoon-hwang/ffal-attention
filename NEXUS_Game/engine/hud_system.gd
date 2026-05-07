extends CanvasLayer

# ============================================================================
# HUD System - 플레이 중 화면상 정보 표시 (체력, MP, 경험치 등)
# ============================================================================
# Week 3 Day 6: HUD 시스템
# 담당: 천재 ⚡
# ======================== ==================================================

# 플레이어 데이터
var player_data = {
	"hp": 100,
	"max_hp": 100,
	"mp": 50,
	"max_mp": 50,
	"level": 1,
	"exp": 0,
	"exp_to_level": 100,
	"gold": 0,
	"current_martial_art": "기본 검술"
}

# 화면 요소들
var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect
var mp_bar_bg: ColorRect
var mp_bar_fill: ColorRect
var exp_bar_fill: ColorRect
var level_label: Label
var gold_label: Label
var current_art_label: Label
var position_label: Label
var time_label: Label
var fps_label: Label

# 애니메이션
var combo_counter = 0
var combo_timer = 0.0
var damage_numbers = []  # 데미지 플로팅 텍스트
var notifications = []  # 알림 큐

# ============================================================================
# 초기화
# ============================================================================

func _ready():
	# 씬 뷰포트 크기
	var viewport_size = get_viewport_rect().size
	
	# === 체력 바 ===
	hp_bar_bg = ColorRect.new()
	hp_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	hp_bar_bg.position = Vector2(20, 20)
	hp_bar_bg.size = Vector2(300, 20)
	add_child(hp_bar_bg)
	
	hp_bar_fill = ColorRect.new()
	hp_bar_fill.color = Color(1, 0, 0, 0.8)
	hp_bar_fill.position = Vector2(20, 20)
	hp_bar_fill.size = Vector2(300, 20)
	add_child(hp_bar_fill)
	
	# === MP 바 ===
	mp_bar_bg = ColorRect.new()
	mp_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	mp_bar_bg.position = Vector2(20, 45)
	mp_bar_bg.size = Vector2(300, 20)
	add_child(mp_bar_bg)
	
	mp_bar_fill = ColorRect.new()
	mp_bar_fill.color = Color(0, 0.5, 1, 0.8)
	mp_bar_fill.position = Vector2(20, 45)
	mp_bar_fill.size = Vector2(300, 20)
	add_child(mp_bar_fill)
	
	# === 경험치 바 ===
	var exp_bar_bg = ColorRect.new()
	exp_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	exp_bar_bg.position = Vector2(20, 70)
	exp_bar_bg.size = Vector2(300, 10)
	add_child(exp_bar_bg)
	
	exp_bar_fill = ColorRect.new()
	exp_bar_fill.color = Color(1, 1, 0, 0.8)
	exp_bar_fill.position = Vector2(20, 70)
	exp_bar_fill.size = Vector2(0, 10)
	add_child(exp_bar_fill)
	
	# === 텍스트 라벨 ===
	level_label = Label.new()
	level_label.text = "LV. 1"
	level_label.position = Vector2(330, 20)
	level_label.add_theme_font_size_override("font_size", 24)
	add_child(level_label)
	
	gold_label = Label.new()
	gold_label.text = "Gold: 0"
	gold_label.position = Vector2(330, 50)
	gold_label.add_theme_font_size_override("font_size", 16)
	add_child(gold_label)
	
	current_art_label = Label.new()
	current_art_label.text = "무술: 기본 검술"
	current_art_label.position = Vector2(20, 100)
	current_art_label.add_theme_font_size_override("font_size", 14)
	add_child(current_art_label)
	
	# === 우측 상단: 위치 & 시간 ===
	position_label = Label.new()
	position_label.text = "좌표: (0, 0, 0)"
	position_label.position = Vector2(viewport_size.x - 300, 20)
	position_label.add_theme_font_size_override("font_size", 12)
	add_child(position_label)
	
	time_label = Label.new()
	time_label.text = "시간: 00:00"
	time_label.position = Vector2(viewport_size.x - 300, 40)
	time_label.add_theme_font_size_override("font_size", 12)
	add_child(time_label)
	
	# === FPS 표시 (디버그) ===
	fps_label = Label.new()
	fps_label.text = "FPS: 60"
	fps_label.position = Vector2(viewport_size.x - 300, 60)
	fps_label.add_theme_font_size_override("font_size", 12)
	add_child(fps_label)
	
	# 콤보 표시 준비
	combo_counter = 0

# ============================================================================
# 실시간 업데이트
# ============================================================================

func _process(delta):
	# 체력/MP 바 업데이트
	var hp_ratio = float(player_data["hp"]) / float(player_data["max_hp"])
	hp_bar_fill.size.x = 300 * hp_ratio
	
	var mp_ratio = float(player_data["mp"]) / float(player_data["max_mp"])
	mp_bar_fill.size.x = 300 * mp_ratio
	
	# 경험치 바 업데이트
	var exp_ratio = float(player_data["exp"]) / float(player_data["exp_to_level"])
	exp_bar_fill.size.x = 300 * exp_ratio
	
	# 체력 바 색상 변화 (위험 상태 = 빨강)
	if hp_ratio < 0.3:
		hp_bar_fill.color = Color(1, 0, 0, 1)  # 위험: 진한 빨강
	elif hp_ratio < 0.6:
		hp_bar_fill.color = Color(1, 0.5, 0, 0.8)  # 주의: 주황
	else:
		hp_bar_fill.color = Color(0, 1, 0, 0.8)  # 정상: 초록
	
	# 콤보 타이머 감소
	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_counter = 0
	
	# 데미지 숫자 애니메이션
	_update_damage_numbers(delta)
	
	# FPS 표시
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func update_hud(delta: float):
	"""게임 루프에서 호출되는 HUD 업데이트"""
	_process(delta)

# ============================================================================
# 플레이어 상태 업데이트
# ============================================================================

func take_damage(amount: int, x: float, y: float):
	"""데미지 입음"""
	player_data["hp"] = max(0, player_data["hp"] - amount)
	
	# 데미지 플로팅 텍스트
	_show_damage_number(amount, x, y, Color.RED)
	
	# 데미지 시 화면 흔들림
	if combo_counter > 0:
		combo_counter += 1

func heal(amount: int):
	"""회복"""
	player_data["hp"] = min(player_data["max_hp"], player_data["hp"] + amount)
	_show_notification("회복: +" + str(amount), Color.GREEN)

func restore_mp(amount: int):
	"""MP 회복"""
	player_data["mp"] = min(player_data["max_mp"], player_data["mp"] + amount)

func spend_mp(amount: int) -> bool:
	"""MP 소비 (성공하면 true)"""
	if player_data["mp"] >= amount:
		player_data["mp"] -= amount
		return true
	return false

func add_gold(amount: int):
	"""골드 추가"""
	player_data["gold"] += amount
	gold_label.text = "Gold: %d" % player_data["gold"]
	_show_notification("Gold: +" + str(amount), Color.YELLOW)

# ============================================================================
# 전투 시스템 피드백
# ============================================================================

func on_martial_art_used(art_name: String):
	"""무술 사용"""
	current_art_label.text = "무술: " + art_name
	combo_counter += 1
	combo_timer = 3.0  # 3초 타이머

func on_hit(damage: int, x: float, y: float):
	"""히트! 피드백"""
	_show_damage_number(damage, x, y, Color.WHITE)
	combo_counter += 1

func on_critical_hit(damage: int, x: float, y: float):
	"""크리티컬! 피드백"""
	_show_damage_number(damage, x, y, Color.YELLOW)
	combo_counter += 2
	_show_notification("CRITICAL!", Color.YELLOW)

# ============================================================================
# 이벤트 핸들러
# ============================================================================

func show_level_up_popup(new_level: int):
	"""레벨업 팝업"""
	player_data["level"] = new_level
	player_data["exp"] = 0
	player_data["exp_to_level"] = int(100 * (new_level ** 1.2))
	level_label.text = "LV. %d" % new_level
	_show_notification("LEVEL UP!", Color.CYAN)

func show_quest_complete(quest_id: String, reward: Dictionary):
	"""퀘스트 완료"""
	var msg = "Quest Complete: " + quest_id
	_show_notification(msg, Color.CYAN)
	if "exp" in reward:
		player_data["exp"] += reward["exp"]
	if "gold" in reward:
		add_gold(reward["gold"])

func show_boss_defeat(boss_name: String):
	"""보스 격파"""
	_show_notification("BOSS DEFEATED: " + boss_name, Color.GOLD)

def update_player_stats(stats: Dictionary):
	"""플레이어 능력치 업데이트"""
	if "hp" in stats:
		player_data["hp"] = stats["hp"]
	if "max_hp" in stats:
		player_data["max_hp"] = stats["max_hp"]
	if "mp" in stats:
		player_data["mp"] = stats["mp"]
	if "max_mp" in stats:
		player_data["max_mp"] = stats["max_mp"]
	if "gold" in stats:
		player_data["gold"] = stats["gold"]

# ============================================================================
# 내부 헬퍼 함수
# ============================================================================

func _show_damage_number(damage: int, x: float, y: float, color: Color):
	"""데미지 플로팅 텍스트"""
	var label = Label.new()
	label.text = str(damage)
	label.position = Vector2(x, y)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	
	damage_numbers.append({
		"label": label,
		"lifetime": 1.5,
		"start_y": y
	})

func _update_damage_numbers(delta: float):
	"""데미지 숫자 애니메이션 업데이트"""
	var to_remove = []
	for i in range(damage_numbers.size()):
		var dn = damage_numbers[i]
		dn["lifetime"] -= delta
		if dn["lifetime"] <= 0:
			dn["label"].queue_free()
			to_remove.append(i)
		else:
			# 떠오르는 애니메이션
			dn["label"].position.y = dn["start_y"] - (1.5 - dn["lifetime"]) * 50
			# 페이드아웃
			var alpha = dn["lifetime"] / 1.5
			var color = dn["label"].get_theme_color("font_color")
			color.a = alpha
			dn["label"].add_theme_color_override("font_color", color)
	
	# 제거
	for i in to_remove.size() - 1:
		damage_numbers.remove_at(to_remove[i])

func _show_notification(msg: String, color: Color):
	"""알림 표시"""
	var label = Label.new()
	label.text = msg
	label.position = Vector2(get_viewport_rect().size.x / 2 - 100, 150)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	
	notifications.append({
		"label": label,
		"lifetime": 2.0
	})

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[HUD] " + msg)
