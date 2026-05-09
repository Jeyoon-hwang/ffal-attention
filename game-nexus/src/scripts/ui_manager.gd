extends CanvasLayer

@onready var game_manager = get_node("/root/Main/GameManager")
@onready var player = get_node("/root/Main/Player")

var hud_label: Label
var info_label: Label
var boss_label: Label  # 보스 정보
var combat_log: Label  # 전투 로그

func _ready():
	# UI 라벨 생성
	hud_label = Label.new()
	hud_label.anchor_left = 0.02
	hud_label.anchor_top = 0.02
	hud_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(hud_label)
	
	# 게임 정보 (우측 상단)
	info_label = Label.new()
	info_label.anchor_left = 0.75
	info_label.anchor_top = 0.02
	add_child(info_label)
	
	# 보스 정보 (상단 중앙)
	boss_label = Label.new()
	boss_label.anchor_left = 0.35
	boss_label.anchor_top = 0.02
	add_child(boss_label)
	
	# 전투 로그 (하단)
	combat_log = Label.new()
	combat_log.anchor_left = 0.02
	combat_log.anchor_top = 0.85
	combat_log.custom_minimum_size = Vector2(500, 100)
	add_child(combat_log)

func _process(delta):
	if not player or not game_manager:
		return
	
	# ============================================================
	# 플레이어 정보 (좌측)
	# ============================================================
	var health_percent = float(player.health) / player.max_health * 100
	var energy_percent = float(player.energy) / player.max_energy * 100
	var spirit_percent = float(player.spirit) / player.max_spirit * 100
	
	# 체력 바 시각화
	var health_bar = create_bar(health_percent)
	var energy_bar = create_bar(energy_percent)
	var spirit_bar = create_bar(spirit_percent)
	
	# Day 5: 방어/회피 상태
	var defense_status = "🛡️ 방어 중" if player.is_defending else ""
	var dodge_status = ""
	if player.dodge_cooldown_timer > 0:
		dodge_status = " | 🏃 회피 (%.1f초)" % player.dodge_cooldown_timer
	elif player.current_i_frames > 0:
		dodge_status = " | 🌀 무적 중"
	
	var combat_status = defense_status + dodge_status
	
	hud_label.text = """
[🥋 무사의 상태]
체력: %s %.0f%% (%d/%d)
에너지: %s %.0f%% (%d/%d)
내공: %s %.0f%% (%d/%d)
%s
""" % [
		health_bar, health_percent, player.health, player.max_health,
		energy_bar, energy_percent, player.energy, player.max_energy,
		spirit_bar, spirit_percent, player.spirit, player.max_spirit,
		combat_status
	]
	
	# ============================================================
	# 게임 정보 (우측 상단)
	# ============================================================
	info_label.text = """
[📊 게임 현황]
스테이지: %d
점수: %d
처치: %d마리
난이도: %.1f배
파당: %s
""" % [
		game_manager.stage,
		game_manager.score,
		game_manager.enemies_defeated,
		game_manager.difficulty_multiplier,
		game_manager.current_faction
	]
	
	# ============================================================
	# 보스 정보 (있으면 표시)
	# ============================================================
	var boss_list = get_tree().get_nodes_in_group("enemies")
	var has_boss = false
	for enemy in boss_list:
		if enemy.is_boss:
			var boss_health_percent = float(enemy.health) / enemy.max_health * 100
			var boss_bar = create_bar(boss_health_percent)
			boss_label.text = """
[👹 보스: %s]
체력: %s %.0f%% (%d/%d)
""" % [
				enemy.faction,
				boss_bar,
				boss_health_percent,
				enemy.health,
				enemy.max_health
			]
			has_boss = true
			break
	
	if not has_boss:
		boss_label.text = ""

# ============================================================
# 유틸리티 함수
# ============================================================

func create_bar(percent: float, width: int = 20) -> String:
	"""백분율을 바로 시각화"""
	var filled = int(percent / 5)  # 5% = 1칸
	var empty = width - filled
	return "[" + "■".repeat(filled) + "□".repeat(empty) + "]"

func show_combo(combo: int) -> void:
	"""콤보 표시"""
	print("⚔️ 콤보 %d!!!" % combo)
	update_combat_log("🔥 콤보 %d 히트!" % combo)

func show_skill_used(skill_name: String, damage: int) -> void:
	"""스킬 사용 표시"""
	print("⚡ 무술 발동: %s (대미지 %d)" % [skill_name, damage])
	update_combat_log("⚡ %s 발동 (+%d 대미지)" % [skill_name, damage])

func show_boss_phase(phase: int) -> void:
	"""보스 페이즈 변경"""
	print("👹 보스 페이즈 %d 시작!" % phase)
	update_combat_log("👹 보스 페이즈 %d!" % phase)

func show_skill_warning() -> void:
	"""에너지 부족 경고"""
	print("⚠️ 에너지 부족!")
	update_combat_log("⚠️ 에너지 부족!")

func update_combat_log(message: String) -> void:
	"""전투 로그 업데이트"""
	var timestamp = Time.get_ticks_msec()
	var current_log = combat_log.text
	var lines = current_log.split("\n")
	
	# 최대 5줄까지만 표시
	if lines.size() >= 5:
		lines.pop_front()
	
	lines.append(message)
	combat_log.text = "\n".join(lines)

func game_over_screen(reason: String = "") -> void:
	"""게임 오버 화면"""
	var go_label = Label.new()
	go_label.text = "🎬 게임 오버"
	if reason:
		go_label.text += "\n사유: " + reason
	go_label.anchor_left = 0.35
	go_label.anchor_top = 0.4
	add_child(go_label)
	print("게임 오버: %s" % reason)

func game_clear_screen() -> void:
	"""게임 클리어 화면"""
	var clear_label = Label.new()
	clear_label.text = "🎉 게임 클리어!\n점수: %d" % game_manager.score
	clear_label.anchor_left = 0.35
	clear_label.anchor_top = 0.4
	add_child(clear_label)
	print("게임 클리어! 최종 점수: %d" % game_manager.score)
