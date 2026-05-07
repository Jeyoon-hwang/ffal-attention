extends Node

# 🎬 Animation System - 모든 애니메이션 중앙 관리
# Week 3 Day 6 신규 시스템

class_name AnimationSystem

# 애니메이션 데이터베이스
var animations: Dictionary = {}
var tween_store: Dictionary = {}
var animation_states: Dictionary = {}

# 애니메이션 타입 열거
enum AnimationType {
	CHARACTER,      # 0: 캐릭터 (idle, walk, run, attack, hurt, die)
	EFFECT,         # 1: 이펙트 (slash, fire, ice, lightning)
	UI,             # 2: UI (fade, slide, pop, scale)
	PARTICLE,       # 3: 파티클 (burst, rain, smoke)
	BOSS            # 4: 보스 (slam, spin, roar, special)
}

# 캐릭터 애니메이션 상태
enum CharacterState {
	IDLE = 0,
	WALK = 1,
	RUN = 2,
	ATTACK = 3,
	HURT = 4,
	DIE = 5,
	SPECIAL = 6
}

func _ready() -> void:
	_initialize_animation_database()
	print("[AnimationSystem] 애니메이션 시스템 초기화 완료")

# ════════════════════════════════════════════════════════════════
# 1. 애니메이션 DB 초기화
# ════════════════════════════════════════════════════════════════

func _initialize_animation_database() -> void:
	# 캐릭터 애니메이션
	animations["character_idle"] = {
		"duration": 2.0,
		"loop": true,
		"keyframes": 4
	}
	animations["character_walk"] = {
		"duration": 1.5,
		"loop": true,
		"keyframes": 8,
		"speed_factor": 1.0
	}
	animations["character_run"] = {
		"duration": 1.0,
		"loop": true,
		"keyframes": 6,
		"speed_factor": 1.5
	}
	
	# 공격 애니메이션 (8방향)
	for dir in range(8):
		animations["attack_dir_%d" % dir] = {
			"duration": 0.5,
			"loop": false,
			"keyframes": 3,
			"direction": dir
		}
	
	# 보스 애니메이션
	animations["boss_slam"] = {
		"duration": 1.2,
		"loop": false,
		"keyframes": 4,
		"damage_frame": 2
	}
	animations["boss_spin"] = {
		"duration": 1.5,
		"loop": false,
		"keyframes": 6,
		"damage_frame": 3
	}
	animations["boss_roar"] = {
		"duration": 1.0,
		"loop": false,
		"keyframes": 2
	}
	
	# 이펙트 애니메이션
	animations["slash_effect"] = {
		"duration": 0.3,
		"loop": false,
		"keyframes": 2
	}
	animations["fire_effect"] = {
		"duration": 0.8,
		"loop": false,
		"keyframes": 4
	}
	animations["magic_effect"] = {
		"duration": 1.0,
		"loop": false,
		"keyframes": 5
	}
	
	# UI 애니메이션
	animations["ui_fade_in"] = {
		"duration": 0.3,
		"loop": false,
		"easing": "ease_out"
	}
	animations["ui_slide_left"] = {
		"duration": 0.4,
		"loop": false,
		"distance": 100
	}
	animations["ui_pop"] = {
		"duration": 0.2,
		"loop": false,
		"scale_from": 0.8,
		"scale_to": 1.0
	}

# ════════════════════════════════════════════════════════════════
# 2. 캐릭터 애니메이션 제어
# ════════════════════════════════════════════════════════════════

func animate_character_idle(node: Node3D) -> void:
	if node == null:
		return
	
	var anim_data = animations["character_idle"]
	var tween = create_tween()
	tween.set_loops(0)  # 무한 반복
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 좌우로 미묘하게 흔들기
	tween.tween_property(node, "rotation:y", 0.05, anim_data["duration"] / 2)
	tween.tween_property(node, "rotation:y", -0.05, anim_data["duration"] / 2)
	
	store_tween("idle_%s" % node.name, tween)

func animate_character_walk(node: Node3D, direction: Vector3, speed: float = 1.0) -> void:
	if node == null:
		return
	
	var anim_data = animations["character_walk"]
	var tween = create_tween()
	tween.set_loops(0)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	# 이동 방향 계산
	var move_distance = direction.normalized() * speed
	
	# 다리 흔들기 애니메이션 (상하 움직임)
	tween.tween_property(node, "position", node.position + move_distance, anim_data["duration"])
	
	store_tween("walk_%s" % node.name, tween)

func animate_character_run(node: Node3D, direction: Vector3) -> void:
	if node == null:
		return
	
	var anim_data = animations["character_run"]
	var tween = create_tween()
	tween.set_loops(0)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var move_distance = direction.normalized() * 3.0
	tween.tween_property(node, "position", node.position + move_distance, anim_data["duration"])
	
	store_tween("run_%s" % node.name, tween)

func animate_character_attack(node: Node3D, direction: int) -> void:
	if node == null:
		return
	
	var anim_key = "attack_dir_%d" % direction
	var anim_data = animations[anim_key]
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 공격 방향으로 회전
	var target_rotation = (direction / 8.0) * TAU
	tween.tween_property(node, "rotation:y", target_rotation, anim_data["duration"] / 2)
	
	# 공격 모션 (전진)
	tween.tween_property(node, "position", node.position + Vector3.FORWARD * 0.5, anim_data["duration"] / 2)
	
	store_tween("attack_%s" % node.name, tween)

func animate_character_hurt(node: Node3D) -> void:
	if node == null:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 뒤로 밀려나기
	tween.tween_property(node, "position", node.position + Vector3.BACK * 0.3, 0.3)
	tween.tween_property(node, "position", node.position, 0.2)
	
	store_tween("hurt_%s" % node.name, tween)

func animate_character_die(node: Node3D) -> void:
	if node == null:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	
	# 회전하며 사라지기
	tween.tween_property(node, "rotation:x", TAU, 0.8)
	tween.tween_property(node, "scale", Vector3.ZERO, 0.5)
	
	store_tween("die_%s" % node.name, tween)

# ════════════════════════════════════════════════════════════════
# 3. 보스 애니메이션
# ════════════════════════════════════════════════════════════════

func animate_boss_slam(node: Node3D) -> void:
	if node == null:
		return
	
	var anim_data = animations["boss_slam"]
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 위로 점프
	tween.tween_property(node, "position:y", node.position.y + 2.0, 0.4)
	# 내려찍기
	tween.tween_property(node, "position:y", node.position.y, 0.6)
	
	store_tween("boss_slam_%s" % node.name, tween)

func animate_boss_spin(node: Node3D) -> void:
	if node == null:
		return
	
	var anim_data = animations["boss_spin"]
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	# 360도 회전
	tween.tween_property(node, "rotation:y", node.rotation.y + TAU, anim_data["duration"])
	
	store_tween("boss_spin_%s" % node.name, tween)

func animate_boss_roar(node: Node3D) -> void:
	if node == null:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 크기 변화 (호흡)
	var original_scale = node.scale
	tween.tween_property(node, "scale", original_scale * 1.2, 0.3)
	tween.tween_property(node, "scale", original_scale, 0.3)
	
	store_tween("boss_roar_%s" % node.name, tween)

# ════════════════════════════════════════════════════════════════
# 4. 효과 애니메이션
# ════════════════════════════════════════════════════════════════

func animate_slash_effect(node: Node3D, start_pos: Vector3, end_pos: Vector3) -> void:
	if node == null:
		return
	
	var anim_data = animations["slash_effect"]
	node.position = start_pos
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "position", end_pos, anim_data["duration"])
	tween.tween_property(node, "modulate:a", 0.0, anim_data["duration"])
	
	store_tween("slash_%s" % node.name, tween)

func animate_fire_effect(node: Node3D) -> void:
	if node == null:
		return
	
	var anim_data = animations["fire_effect"]
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 위로 올라가며 사라지기
	var target_pos = node.position + Vector3.UP * 2.0
	tween.tween_property(node, "position", target_pos, anim_data["duration"])
	tween.tween_property(node, "modulate:a", 0.0, anim_data["duration"])
	
	store_tween("fire_%s" % node.name, tween)

func animate_magic_effect(node: Node3D) -> void:
	if node == null:
		return
	
	var anim_data = animations["magic_effect"]
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 확대하며 사라지기
	tween.tween_property(node, "scale", node.scale * 2.0, anim_data["duration"])
	tween.tween_property(node, "modulate:a", 0.0, anim_data["duration"])
	
	store_tween("magic_%s" % node.name, tween)

# ════════════════════════════════════════════════════════════════
# 5. UI 애니메이션
# ════════════════════════════════════════════════════════════════

func animate_ui_fade_in(node: Control) -> void:
	if node == null:
		return
	
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
	
	store_tween("ui_fade_%s" % node.name, tween)

func animate_ui_fade_out(node: Control) -> void:
	if node == null:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "modulate:a", 0.0, 0.3)
	
	store_tween("ui_fade_%s" % node.name, tween)

func animate_ui_slide_left(node: Control, distance: int = 100) -> void:
	if node == null:
		return
	
	var original_x = node.position.x
	node.position.x = original_x + distance
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "position:x", original_x, 0.4)
	
	store_tween("ui_slide_%s" % node.name, tween)

func animate_ui_pop(node: Control) -> void:
	if node == null:
		return
	
	node.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "scale", Vector2.ONE, 0.2)
	
	store_tween("ui_pop_%s" % node.name, tween)

func animate_ui_bounce(node: Control) -> void:
	if node == null:
		return
	
	var original_scale = node.scale
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "scale", original_scale * 1.1, 0.15)
	tween.tween_property(node, "scale", original_scale, 0.15)
	
	store_tween("ui_bounce_%s" % node.name, tween)

# ════════════════════════════════════════════════════════════════
# 6. 애니메이션 제어
# ════════════════════════════════════════════════════════════════

func play_animation(anim_type: AnimationType, anim_name: String, node: Node) -> void:
	match anim_type:
		AnimationType.CHARACTER:
			play_character_animation(anim_name, node)
		AnimationType.EFFECT:
			play_effect_animation(anim_name, node)
		AnimationType.UI:
			play_ui_animation(anim_name, node)
		AnimationType.BOSS:
			play_boss_animation(anim_name, node)

func play_character_animation(anim_name: String, node: Node) -> void:
	if node == null:
		return
	
	match anim_name:
		"idle":
			animate_character_idle(node)
		"walk":
			animate_character_walk(node, Vector3.FORWARD)
		"run":
			animate_character_run(node, Vector3.FORWARD)
		"hurt":
			animate_character_hurt(node)
		"die":
			animate_character_die(node)

func play_boss_animation(anim_name: String, node: Node) -> void:
	if node == null:
		return
	
	match anim_name:
		"slam":
			animate_boss_slam(node)
		"spin":
			animate_boss_spin(node)
		"roar":
			animate_boss_roar(node)

func play_effect_animation(anim_name: String, node: Node) -> void:
	if node == null:
		return
	
	match anim_name:
		"slash":
			animate_slash_effect(node, node.position, node.position + Vector3.FORWARD * 2)
		"fire":
			animate_fire_effect(node)
		"magic":
			animate_magic_effect(node)

func play_ui_animation(anim_name: String, node: Node) -> void:
	if node == null:
		return
	
	match anim_name:
		"fade_in":
			animate_ui_fade_in(node)
		"fade_out":
			animate_ui_fade_out(node)
		"slide_left":
			animate_ui_slide_left(node)
		"pop":
			animate_ui_pop(node)
		"bounce":
			animate_ui_bounce(node)

func stop_animation(node: Node) -> void:
	var tween_key = ""
	for key in tween_store.keys():
		if key.contains(node.name):
			tween_key = key
			break
	
	if tween_key != "" and tween_store[tween_key] != null:
		tween_store[tween_key].kill()
		tween_store.erase(tween_key)

# ════════════════════════════════════════════════════════════════
# 7. 유틸리티 함수
# ════════════════════════════════════════════════════════════════

func store_tween(key: String, tween: Tween) -> void:
	tween_store[key] = tween

func create_tween() -> Tween:
	return create_tween()

func get_animation_duration(anim_name: String) -> float:
	if animations.has(anim_name):
		return animations[anim_name]["duration"]
	return 0.0

func is_animation_looping(anim_name: String) -> bool:
	if animations.has(anim_name):
		return animations[anim_name].get("loop", false)
	return false

func clear_all_animations() -> void:
	for tween in tween_store.values():
		if tween != null:
			tween.kill()
	tween_store.clear()

func get_animation_data(anim_name: String) -> Dictionary:
	if animations.has(anim_name):
		return animations[anim_name].duplicate()
	return {}

func set_animation_speed(anim_name: String, speed: float) -> void:
	if animations.has(anim_name):
		animations[anim_name]["speed_factor"] = speed

func batch_animate(nodes: Array, anim_names: Array) -> void:
	if nodes.size() != anim_names.size():
		print("[AnimationSystem] 노드 수와 애니메이션 수가 다릅니다!")
		return
	
	for i in range(nodes.size()):
		play_animation(AnimationType.CHARACTER, anim_names[i], nodes[i])
