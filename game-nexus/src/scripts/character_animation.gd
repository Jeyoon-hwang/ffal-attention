extends Node3D

# 🎮 Character Animation System - 플레이어/NPC/보스 애니메이션
# Week 3 Day 6

class_name CharacterAnimation

@onready var animation_system: AnimationSystem = get_node("/root/Game/AnimationSystem")

# 캐릭터 타입
enum CharacterType {
	PLAYER = 0,
	NPC = 1,
	ENEMY = 2,
	BOSS = 3
}

# 각 캐릭터의 상태 추적
var character_states: Dictionary = {}
var animation_queues: Dictionary = {}
var facing_directions: Dictionary = {}

func _ready() -> void:
	print("[CharacterAnimation] 캐릭터 애니메이션 시스템 초기화")

# ════════════════════════════════════════════════════════════════
# 1. 기본 애니메이션 설정
# ════════════════════════════════════════════════════════════════

func register_character(char_id: String, char_type: int, node: Node3D) -> void:
	if node == null:
		return
	
	character_states[char_id] = {
		"type": char_type,
		"node": node,
		"current_state": "idle",
		"is_animating": false,
		"animation_queue": [],
		"facing_direction": 0
	}
	
	animation_queues[char_id] = []
	facing_directions[char_id] = 0

func unregister_character(char_id: String) -> void:
	if character_states.has(char_id):
		character_states.erase(char_id)
	if animation_queues.has(char_id):
		animation_queues.erase(char_id)
	if facing_directions.has(char_id):
		facing_directions.erase(char_id)

# ════════════════════════════════════════════════════════════════
# 2. 플레이어 애니메이션
# ════════════════════════════════════════════════════════════════

func play_player_idle(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "idle"
	animation_system.animate_character_idle(node)

func play_player_walk(char_id: String, direction: Vector3) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	# 방향에 따라 회전
	update_facing_direction(char_id, direction)
	
	state["current_state"] = "walk"
	animation_system.animate_character_walk(node, direction, 1.0)

func play_player_run(char_id: String, direction: Vector3) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	update_facing_direction(char_id, direction)
	
	state["current_state"] = "run"
	animation_system.animate_character_run(node, direction)

func play_player_attack(char_id: String, attack_dir: int, attack_type: String = "basic") -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "attack"
	state["is_animating"] = true
	
	# 8방향 공격
	animation_system.animate_character_attack(node, attack_dir % 8)
	
	# 공격 이펙트 추가
	match attack_type:
		"slash":
			create_slash_effect(node, attack_dir)
		"magic":
			create_magic_effect(node)
		"combo":
			create_combo_effect(node, attack_dir)

func play_player_hurt(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "hurt"
	state["is_animating"] = true
	
	animation_system.animate_character_hurt(node)
	
	# 0.5초 후 복구
	await get_tree().create_timer(0.5).timeout
	state["is_animating"] = false

func play_player_die(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "die"
	state["is_animating"] = true
	
	animation_system.animate_character_die(node)

# ════════════════════════════════════════════════════════════════
# 3. NPC 애니메이션
# ════════════════════════════════════════════════════════════════

func play_npc_idle(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "idle"
	animation_system.animate_character_idle(node)

func play_npc_walk(char_id: String, path: Array) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null or path.is_empty():
		return
	
	state["current_state"] = "walk"
	
	for point in path:
		var direction = (point - node.position).normalized()
		animation_system.animate_character_walk(node, direction, 2.0)
		await get_tree().create_timer(2.0).timeout
	
	state["current_state"] = "idle"

func play_npc_talk(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "talk"
	
	# 끄덕이는 모션 (2초)
	var tween = create_tween()
	tween.set_loops(1)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(node, "rotation:x", 0.2, 0.5)
	tween.tween_property(node, "rotation:x", 0.0, 0.5)

# ════════════════════════════════════════════════════════════════
# 4. 보스 애니메이션 (6가지 패턴)
# ════════════════════════════════════════════════════════════════

func play_boss_slam(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "attack"
	state["is_animating"] = true
	
	animation_system.animate_boss_slam(node)
	create_slam_effect(node)
	
	await get_tree().create_timer(1.2).timeout
	state["is_animating"] = false

func play_boss_spin(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "attack"
	state["is_animating"] = true
	
	animation_system.animate_boss_spin(node)
	create_spin_effect(node)
	
	await get_tree().create_timer(1.5).timeout
	state["is_animating"] = false

func play_boss_roar(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["current_state"] = "special"
	state["is_animating"] = true
	
	animation_system.animate_boss_roar(node)
	create_roar_effect(node)
	
	await get_tree().create_timer(1.0).timeout
	state["is_animating"] = false

func play_boss_triple_strike(char_id: String) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["is_animating"] = true
	
	# 3회 연속 공격
	for i in range(3):
		animation_system.animate_character_attack(node, i * 2)
		await get_tree().create_timer(0.4).timeout
	
	state["is_animating"] = false

func play_boss_jump_attack(char_id: String, target_pos: Vector3) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["is_animating"] = true
	
	# 점프하며 대상으로 이동
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 점프 (위-아래)
	tween.tween_property(node, "position:y", node.position.y + 3.0, 0.4)
	tween.tween_property(node, "position", target_pos, 0.4)
	tween.tween_property(node, "position:y", target_pos.y, 0.3)
	
	create_jump_effect(node)
	
	await get_tree().create_timer(1.1).timeout
	state["is_animating"] = false

func play_boss_laser(char_id: String, direction: Vector3) -> void:
	if not character_states.has(char_id):
		return
	
	var state = character_states[char_id]
	var node = state["node"]
	
	if node == null:
		return
	
	state["is_animating"] = true
	
	# 차징 모션
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(node, "scale", node.scale * 1.3, 0.5)
	tween.tween_property(node, "scale", node.scale, 0.5)
	
	create_laser_effect(node, direction)
	
	await get_tree().create_timer(1.0).timeout
	state["is_animating"] = false

# ════════════════════════════════════════════════════════════════
# 5. 이펙트 생성 함수
# ════════════════════════════════════════════════════════════════

func create_slash_effect(node: Node3D, direction: int) -> void:
	# 슬래시 이펙트 생성
	var effect = Node3D.new()
	effect.position = node.position + Vector3.UP
	get_parent().add_child(effect)
	
	animation_system.animate_slash_effect(
		effect,
		effect.position,
		effect.position + (Vector3.FORWARD * direction / 4).normalized() * 2
	)
	
	await get_tree().create_timer(0.3).timeout
	effect.queue_free()

func create_magic_effect(node: Node3D) -> void:
	var effect = Node3D.new()
	effect.position = node.position + Vector3.UP
	effect.scale = Vector3(0.5, 0.5, 0.5)
	get_parent().add_child(effect)
	
	animation_system.animate_magic_effect(effect)
	
	await get_tree().create_timer(1.0).timeout
	effect.queue_free()

func create_combo_effect(node: Node3D, direction: int) -> void:
	for i in range(3):
		var effect = Node3D.new()
		effect.position = node.position + Vector3.UP * (i + 1)
		get_parent().add_child(effect)
		
		animation_system.animate_slash_effect(
			effect,
			effect.position,
			effect.position + Vector3.FORWARD * (i + 1)
		)
		
		await get_tree().create_timer(0.15).timeout

func create_slam_effect(node: Node3D) -> void:
	# 지면에 충격 이펙트
	var effect = Node3D.new()
	effect.position = node.position
	effect.position.y = 0
	get_parent().add_child(effect)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(effect, "scale", Vector3(3, 0.2, 3), 0.5)
	tween.tween_property(effect, "modulate:a", 0.0, 0.3)
	
	await get_tree().create_timer(0.8).timeout
	effect.queue_free()

func create_spin_effect(node: Node3D) -> void:
	var effect = Node3D.new()
	effect.position = node.position
	get_parent().add_child(effect)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(effect, "rotation:y", TAU * 3, 1.5)
	tween.tween_property(effect, "scale", Vector3(2, 2, 2), 1.5)
	tween.tween_property(effect, "modulate:a", 0.0, 1.5)
	
	await get_tree().create_timer(1.5).timeout
	effect.queue_free()

func create_roar_effect(node: Node3D) -> void:
	var effect = Node3D.new()
	effect.position = node.position
	get_parent().add_child(effect)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(effect, "scale", Vector3(4, 4, 4), 0.5)
	tween.tween_property(effect, "modulate:a", 0.0, 0.5)
	
	await get_tree().create_timer(0.5).timeout
	effect.queue_free()

func create_jump_effect(node: Node3D) -> void:
	var effect = Node3D.new()
	effect.position = node.position
	get_parent().add_child(effect)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(effect, "scale", Vector3(2.5, 0.2, 2.5), 0.6)
	tween.tween_property(effect, "modulate:a", 0.0, 0.4)
	
	await get_tree().create_timer(0.6).timeout
	effect.queue_free()

func create_laser_effect(node: Node3D, direction: Vector3) -> void:
	var effect = Node3D.new()
	effect.position = node.position
	get_parent().add_child(effect)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var target = node.position + direction * 20
	tween.tween_property(effect, "position", target, 0.8)
	tween.tween_property(effect, "modulate:a", 0.0, 0.6)
	
	await get_tree().create_timer(0.8).timeout
	effect.queue_free()

# ════════════════════════════════════════════════════════════════
# 6. 유틸리티
# ════════════════════════════════════════════════════════════════

func update_facing_direction(char_id: String, direction: Vector3) -> void:
	if not character_states.has(char_id):
		return
	
	var angle = atan2(direction.x, direction.z)
	var dir_index = int(((angle + PI) / TAU) * 8) % 8
	
	facing_directions[char_id] = dir_index
	character_states[char_id]["facing_direction"] = dir_index

func get_character_state(char_id: String) -> String:
	if character_states.has(char_id):
		return character_states[char_id]["current_state"]
	return "unknown"

func is_character_animating(char_id: String) -> bool:
	if character_states.has(char_id):
		return character_states[char_id]["is_animating"]
	return false

func stop_character_animation(char_id: String) -> void:
	if character_states.has(char_id):
		var node = character_states[char_id]["node"]
		if node != null:
			animation_system.stop_animation(node)
		character_states[char_id]["is_animating"] = false

func queue_animation(char_id: String, anim_name: String) -> void:
	if animation_queues.has(char_id):
		animation_queues[char_id].append(anim_name)

func get_animation_queue(char_id: String) -> Array:
	if animation_queues.has(char_id):
		return animation_queues[char_id]
	return []

func clear_animation_queue(char_id: String) -> void:
	if animation_queues.has(char_id):
		animation_queues[char_id].clear()
