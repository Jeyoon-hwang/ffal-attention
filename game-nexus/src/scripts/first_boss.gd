# 🥋 NEXUS Day 7: 첫 번째 보스 - "중원의 왕"
# 중원 지역의 보스, 게임의 첫 번째 도전

extends CharacterBody3D

class_name FirstBoss

# 보스 정보
const BOSS_NAME = "중원의 왕"
const BOSS_LEVEL = 5
const BOSS_DESCRIPTION = "중원 지방을 장악한 무술대가. 정력이 강하고 전투 경험이 풍부하다."

# 스탯
var max_health = 200
var health = 200
var attack_damage = 15
var defense = 10
var speed = 6.0

# 전투 시스템
var boss_ai: BossAIEnhanced
var combat_system: CombatSystem
var combo_system: ComboSystem
var defense_system: DefenseSystem
var status_effect: StatusEffect

# 무술 (보스가 사용할 무술들)
var boss_martial_arts = [
	{
		"id": 101,
		"name": "직선진격",
		"damage": 12,
		"range": 3.0,
		"cooldown": 1.0,
		"level": 5
	},
	{
		"id": 102,
		"name": "회전참",
		"damage": 15,
		"range": 5.0,
		"cooldown": 1.5,
		"level": 5,
		"aoe": true
	},
	{
		"id": 103,
		"name": "운룡검",
		"damage": 18,
		"range": 6.0,
		"cooldown": 2.0,
		"level": 5
	},
	{
		"id": 104,
		"name": "기공파",
		"damage": 16,
		"range": 8.0,
		"cooldown": 2.5,
		"level": 5
	},
]

# 상태
var current_target: Node = null
var attack_timer = 0.0
var last_attack_pattern = ""
var is_defeated = false
var despawn_timer = 0.0

# 사운드/이펙트
var hit_sound: String = "res://assets/sounds/hit.wav"
var death_sound: String = "res://assets/sounds/boss_death.wav"

# 통계
var stats = {
	"damage_dealt": 0,
	"damage_taken": 0,
	"hits_landed": 0,
	"attacks_blocked": 0,
	"combos_used": 0,
	"fight_duration": 0.0,
}

var fight_start_time = 0.0


func _ready() -> void:
	"""초기화"""
	print("\n🥋 ========== 첫 번째 보스 준비 ==========")
	print("보스명: %s (Lv. %d)" % [BOSS_NAME, BOSS_LEVEL])
	print("설명: %s" % BOSS_DESCRIPTION)
	print("체력: %d | 공격력: %d | 방어력: %d" % [max_health, attack_damage, defense])
	print("무술: %d개 보유" % boss_martial_arts.size())
	print("=========================================\n")
	
	# 시스템 초기화
	initialize_systems()
	
	# 보스 AI 시작
	boss_ai = BossAIEnhanced.new()
	boss_ai._init()
	boss_ai.ai_type = BossAIEnhanced.AIType.MARTIAL_MASTER
	boss_ai.martial_arts = boss_martial_arts
	
	health = max_health
	fight_start_time = Time.get_ticks_msec() / 1000.0


func initialize_systems() -> void:
	"""전투 시스템 초기화"""
	# 각 시스템 인스턴스 생성
	combat_system = CombatSystem.new()
	combo_system = ComboSystem.new()
	defense_system = DefenseSystem.new()
	status_effect = StatusEffect.new()
	
	# AI에 시스템 연결
	if boss_ai:
		boss_ai.combat_system = combat_system
		boss_ai.combo_system = combo_system
		boss_ai.defense_system = defense_system
		boss_ai.status_effect = status_effect


func _physics_process(delta: float) -> void:
	"""보스 메인 루프"""
	if is_defeated:
		return
	
	stats["fight_duration"] += delta
	
	# 중력
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	move_and_slide()
	
	# AI 업데이트
	if current_target and boss_ai:
		boss_ai.update(delta, self, current_target)
	
	# 공격 타이머 감소
	attack_timer -= delta


func _process(delta: float) -> void:
	"""프레임 업데이트"""
	if is_defeated:
		despawn_timer -= delta
		if despawn_timer <= 0:
			queue_free()
		return


func attack_player() -> void:
	"""플레이어 공격"""
	if not current_target or attack_timer > 0:
		return
	
	var distance = global_position.distance_to(current_target.global_position)
	
	# 공격 범위 확인
	if distance > 5.0:
		return
	
	# 패턴 선택
	var pattern = select_attack_pattern()
	execute_attack(pattern, distance)
	
	# 쿨타임
	attack_timer = 1.0


func select_attack_pattern() -> Dictionary:
	"""공격 패턴 선택"""
	var hp_ratio = health / float(max_health)
	var distance = global_position.distance_to(current_target.global_position)
	
	# Phase에 따른 패턴 선택
	var available_patterns = []
	
	match boss_ai.boss_phase:
		BossAIEnhanced.BossPhase.PHASE_1:
			# Phase 1: 기본 공격 중심
			available_patterns = ["직선진격", "회전참"]
		BossAIEnhanced.BossPhase.PHASE_2:
			# Phase 2: 다양한 공격
			available_patterns = ["회전참", "운룡검", "기공파"]
		BossAIEnhanced.BossPhase.PHASE_3:
			# Phase 3: 강력한 공격
			available_patterns = ["운룡검", "기공파"]
	
	# 랜덤 선택
	if available_patterns.is_empty():
		return boss_martial_arts[0]
	
	var pattern_name = available_patterns[randi() % available_patterns.size()]
	
	for ma in boss_martial_arts:
		if ma["name"] == pattern_name:
			return ma
	
	return boss_martial_arts[0]


func execute_attack(pattern: Dictionary, distance: float) -> void:
	"""공격 실행"""
	var damage = calculate_damage(pattern["damage"])
	var hit_chance = calculate_hit_chance(distance)
	
	print("\n⚡ 보스 공격: %s (거리: %.1fm)" % [pattern["name"], distance])
	print("   기본 데미지: %d | 실제 데미지: %.0f" % [pattern["damage"], damage])
	
	if randf() < hit_chance:
		# 맞음
		print("   ✅ 명중!")
		current_target.take_damage(int(damage))
		stats["hits_landed"] += 1
		stats["damage_dealt"] += int(damage)
		
		# 콤보 추가
		if combo_system:
			combo_system.add_hit()
			stats["combos_used"] += 1
	else:
		# 빗나감
		print("   ❌ 빗나감!")


func calculate_damage(base_damage: float) -> float:
	"""데미지 계산"""
	var phase_multiplier = 0.8 + (boss_ai.boss_phase - 1) * 0.3  # Phase당 30% 증가
	var hp_multiplier = 0.8 + (1.0 - health / float(max_health)) * 0.5  # 체력 낮을수록 높음
	var critical = randf() < 0.2  # 20% 크리티컬
	
	var final_damage = base_damage * phase_multiplier * hp_multiplier
	if critical:
		final_damage *= 1.5
		print("   ⚠️ 크리티컬!")
	
	return final_damage


func calculate_hit_chance(distance: float) -> float:
	"""명중률 계산"""
	var base_hit = 0.8
	var distance_penalty = max(0.0, (distance - 2.0) * 0.1)  # 거리당 10% 감소
	var hp_bonus = (1.0 - health / float(max_health)) * 0.1  # 체력 낮을수록 명중률 증가
	
	return base_hit - distance_penalty + hp_bonus


func take_damage(damage: int) -> void:
	"""데미지 입음"""
	if is_defeated:
		return
	
	health -= damage
	stats["damage_taken"] += damage
	
	print("💔 보스 피격! (-%d) 현재: %d/%d" % [damage, health, max_health])
	
	# 상태 이상 체크
	if status_effect and status_effect.active_effects.size() > 0:
		print("   상태이상: %d개 활성" % status_effect.active_effects.size())
	
	# 보스 사망
	if health <= 0:
		die()


func die() -> void:
	"""보스 사망"""
	is_defeated = true
	despawn_timer = 3.0
	
	print("\n🎉 ========== 보스 격파! ==========")
	print("전투 시간: %.1f초" % stats["fight_duration"])
	print("피격: %d | 명중: %d번" % [stats["damage_taken"], stats["hits_landed"]])
	print("사용 무술: %d개" % stats["combos_used"])
	print("===================================\n")
	
	# 보스 패배 이벤트
	emit_signal("boss_defeated")


func on_player_attack(attack_data: Dictionary) -> void:
	"""플레이어 공격 받음"""
	var damage = attack_data.get("damage", 10)
	take_damage(damage)


func set_target(target: Node) -> void:
	"""목표 설정"""
	current_target = target
	if boss_ai:
		boss_ai.target_player = target


func get_boss_info() -> Dictionary:
	"""보스 정보 반환"""
	return {
		"name": BOSS_NAME,
		"level": BOSS_LEVEL,
		"description": BOSS_DESCRIPTION,
		"health": health,
		"max_health": max_health,
		"health_percent": health / float(max_health),
		"phase": boss_ai.boss_phase if boss_ai else 0,
		"stats": stats,
	}


signal boss_defeated
signal boss_phase_changed(new_phase: int)


func get_phase_display() -> String:
	"""Phase 표시"""
	if not boss_ai:
		return "초기화 중..."
	
	var phase_names = {
		BossAIEnhanced.BossPhase.PHASE_1: "Phase 1 - 정상 모드",
		BossAIEnhanced.BossPhase.PHASE_2: "Phase 2 - 분노 모드",
		BossAIEnhanced.BossPhase.PHASE_3: "Phase 3 - 절망 모드",
	}
	
	return phase_names.get(boss_ai.boss_phase, "불명")
