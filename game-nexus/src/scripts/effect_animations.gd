extends Node

# ✨ Effect Animations System - 모든 공격 & 주술 이펙트
# Week 3 Day 6

class_name EffectAnimations

# 이펙트 타입
enum EffectType {
	SLASH = 0,          # 칼질 이펙트
	THRUST = 1,         # 찌르기
	SPIN = 2,           # 회전 공격
	FIRE = 3,           # 화염술
	ICE = 4,            # 얼음술
	LIGHTNING = 5,      # 번개술
	POISON = 6,         # 독술
	WIND = 7,           # 풍술
	HEAL = 8,           # 회복술
	DEBUFF = 9          # 약화술
}

# 이펙트 데이터베이스
var effect_database: Dictionary = {}
var active_effects: Dictionary = {}

func _ready() -> void:
	_initialize_effects()
	print("[EffectAnimations] 이펙트 애니메이션 시스템 초기화")

# ════════════════════════════════════════════════════════════════
# 1. 이펙트 DB 초기화
# ════════════════════════════════════════════════════════════════

func _initialize_effects() -> void:
	# 기본 공격 이펙트 (칼질, 찌르기, 회전)
	effect_database["slash"] = {
		"type": EffectType.SLASH,
		"duration": 0.3,
		"color": Color.WHITE,
		"scale": Vector3(1.0, 1.0, 1.0),
		"particles": 10,
		"trail": true
	}
	
	effect_database["thrust"] = {
		"type": EffectType.THRUST,
		"duration": 0.4,
		"color": Color.LIGHT_GRAY,
		"scale": Vector3(0.8, 0.8, 0.8),
		"particles": 8,
		"trail": true
	}
	
	effect_database["spin"] = {
		"type": EffectType.SPIN,
		"duration": 0.6,
		"color": Color.WHITE,
		"scale": Vector3(1.5, 1.5, 1.5),
		"particles": 15,
		"trail": true
	}
	
	# 화염술 이펙트
	effect_database["fire_bolt"] = {
		"type": EffectType.FIRE,
		"duration": 0.8,
		"color": Color.ORANGE_RED,
		"scale": Vector3(0.5, 0.5, 0.5),
		"particles": 20,
		"trail": true,
		"explosion": true
	}
	
	effect_database["fireball"] = {
		"type": EffectType.FIRE,
		"duration": 1.2,
		"color": Color.RED,
		"scale": Vector3(1.0, 1.0, 1.0),
		"particles": 30,
		"trail": true,
		"explosion": true,
		"radius": 3.0
	}
	
	effect_database["flame_wave"] = {
		"type": EffectType.FIRE,
		"duration": 1.5,
		"color": Color.ORANGE,
		"scale": Vector3(3.0, 1.0, 3.0),
		"particles": 50,
		"trail": false,
		"wave": true
	}
	
	# 얼음술 이펙트
	effect_database["ice_bolt"] = {
		"type": EffectType.ICE,
		"duration": 0.8,
		"color": Color.LIGHT_BLUE,
		"scale": Vector3(0.5, 0.5, 0.5),
		"particles": 20,
		"trail": true,
		"explosion": true
	}
	
	effect_database["blizzard"] = {
		"type": EffectType.ICE,
		"duration": 2.0,
		"color": Color.CYAN,
		"scale": Vector3(2.0, 2.0, 2.0),
		"particles": 60,
		"trail": false,
		"freeze": true,
		"radius": 4.0
	}
	
	# 번개술 이펙트
	effect_database["lightning_bolt"] = {
		"type": EffectType.LIGHTNING,
		"duration": 0.5,
		"color": Color.YELLOW,
		"scale": Vector3(0.3, 2.0, 0.3),
		"particles": 15,
		"trail": false,
		"chain": false
	}
	
	effect_database["chain_lightning"] = {
		"type": EffectType.LIGHTNING,
		"duration": 1.0,
		"color": Color.LIGHT_YELLOW,
		"scale": Vector3(0.4, 1.5, 0.4),
		"particles": 25,
		"trail": false,
		"chain": true,
		"chain_count": 3
	}
	
	# 독술 이펙트
	effect_database["poison_cloud"] = {
		"type": EffectType.POISON,
		"duration": 1.5,
		"color": Color.GREEN,
		"scale": Vector3(2.0, 2.0, 2.0),
		"particles": 40,
		"trail": false,
		"dot": true,
		"dot_duration": 5.0
	}
	
	# 풍술 이펙트
	effect_database["wind_slash"] = {
		"type": EffectType.WIND,
		"duration": 0.7,
		"color": Color.LIGHT_CYAN,
		"scale": Vector3(2.0, 1.0, 2.0),
		"particles": 25,
		"trail": true,
		"knockback": true
	}
	
	# 회복술 이펙트
	effect_database["heal"] = {
		"type": EffectType.HEAL,
		"duration": 1.0,
		"color": Color.GREEN,
		"scale": Vector3(1.0, 1.0, 1.0),
		"particles": 20,
		"trail": false,
		"heal_amount": 30
	}
	
	effect_database["grand_heal"] = {
		"type": EffectType.HEAL,
		"duration": 1.5,
		"color": Color.LIGHT_GREEN,
		"scale": Vector3(1.5, 1.5, 1.5),
		"particles": 40,
		"trail": false,
		"heal_amount": 100,
		"radius": 5.0
	}

# ════════════════════════════════════════════════════════════════
# 2. 기본 공격 이펙트 (Slash, Thrust, Spin)
# ════════════════════════════════════════════════════════════════

func play_slash_effect(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["slash"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin + direction.normalized() * 1.0
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 폭발하며 사라지기
	tween.tween_property(effect_node, "scale", Vector3(2.0, 2.0, 2.0), effect_data["duration"] * 0.6)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.4)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_thrust_effect(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["thrust"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 전진하며 사라지기
	var target_pos = origin + direction.normalized() * 3.0
	tween.tween_property(effect_node, "position", target_pos, effect_data["duration"])
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"])
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_spin_effect(origin: Vector3) -> void:
	var effect_data = effect_database["spin"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	# 회전하며 확대
	tween.tween_property(effect_node, "rotation:y", TAU * 2, effect_data["duration"])
	tween.tween_property(effect_node, "scale", Vector3(3.0, 3.0, 3.0), effect_data["duration"])
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.5)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

# ════════════════════════════════════════════════════════════════
# 3. 화염술 이펙트 (Fire Bolt, Fireball, Flame Wave)
# ════════════════════════════════════════════════════════════════

func play_fire_bolt(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["fire_bolt"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var target_pos = origin + direction.normalized() * 15.0
	tween.tween_property(effect_node, "position", target_pos, effect_data["duration"] * 0.8)
	
	# 폭발
	var explosion_tween = create_tween()
	explosion_tween.set_trans(Tween.TRANS_QUAD)
	explosion_tween.set_ease(Tween.EASE_OUT)
	explosion_tween.set_parallel(true)
	
	explosion_tween.tween_property(effect_node, "scale", Vector3(2.0, 2.0, 2.0), 0.3)
	explosion_tween.tween_property(effect_node, "modulate:a", 0.0, 0.3)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_fireball(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["fireball"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.5, 0.5, 0.5)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var target_pos = origin + direction.normalized() * 20.0
	tween.tween_property(effect_node, "position", target_pos, effect_data["duration"] * 0.8)
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.6)
	
	# 폭발
	var explosion_tween = create_tween()
	explosion_tween.set_trans(Tween.TRANS_QUAD)
	explosion_tween.set_ease(Tween.EASE_OUT)
	explosion_tween.set_parallel(true)
	
	explosion_tween.tween_property(effect_node, "scale", Vector3(3.0, 3.0, 3.0), 0.4)
	explosion_tween.tween_property(effect_node, "modulate:a", 0.0, 0.4)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_flame_wave(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["flame_wave"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.5, 0.5, 0.5)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var target_pos = origin + direction.normalized() * 25.0
	tween.tween_property(effect_node, "position", target_pos, effect_data["duration"])
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.7)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.3)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

# ════════════════════════════════════════════════════════════════
# 4. 얼음술 이펙트 (Ice Bolt, Blizzard)
# ════════════════════════════════════════════════════════════════

func play_ice_bolt(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["ice_bolt"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var target_pos = origin + direction.normalized() * 15.0
	tween.tween_property(effect_node, "position", target_pos, effect_data["duration"] * 0.8)
	
	var explosion_tween = create_tween()
	explosion_tween.set_trans(Tween.TRANS_QUAD)
	explosion_tween.set_ease(Tween.EASE_OUT)
	explosion_tween.set_parallel(true)
	
	explosion_tween.tween_property(effect_node, "scale", Vector3(2.5, 2.5, 2.5), 0.3)
	explosion_tween.tween_property(effect_node, "modulate:a", 0.0, 0.3)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_blizzard(origin: Vector3) -> void:
	var effect_data = effect_database["blizzard"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.3, 0.3, 0.3)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.6)
	tween.tween_property(effect_node, "modulate:a", 0.3, effect_data["duration"] * 0.4)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.4)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

# ════════════════════════════════════════════════════════════════
# 5. 번개술 이펙트 (Lightning Bolt, Chain Lightning)
# ════════════════════════════════════════════════════════════════

func play_lightning_bolt(origin: Vector3, target: Vector3) -> void:
	var effect_data = effect_database["lightning_bolt"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 번개는 즉시 나타났다 사라짐
	tween.tween_property(effect_node, "position", target, 0.1)
	tween.tween_property(effect_node, "modulate:a", 0.0, 0.1)
	
	await get_tree().create_timer(0.2).timeout
	effect_node.queue_free()

func play_chain_lightning(origin: Vector3, targets: Array) -> void:
	var effect_data = effect_database["chain_lightning"]
	
	if targets.is_empty():
		return
	
	var current_pos = origin
	
	for target in targets:
		var effect_node = Node3D.new()
		effect_node.position = current_pos
		effect_node.modulate = effect_data["color"]
		add_child(effect_node)
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(effect_node, "position", target, 0.15)
		tween.tween_property(effect_node, "modulate:a", 0.0, 0.15)
		
		current_pos = target
		await get_tree().create_timer(0.2).timeout
		effect_node.queue_free()

# ════════════════════════════════════════════════════════════════
# 6. 독술 & 풍술 & 회복술
# ════════════════════════════════════════════════════════════════

func play_poison_cloud(origin: Vector3) -> void:
	var effect_data = effect_database["poison_cloud"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.2, 0.2, 0.2)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.6)
	tween.tween_property(effect_node, "modulate:a", 0.5, effect_data["duration"] * 0.4)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.6)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_wind_slash(origin: Vector3, direction: Vector3) -> void:
	var effect_data = effect_database["wind_slash"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.5, 0.5, 0.5)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var target_pos = origin + direction.normalized() * 15.0
	tween.tween_property(effect_node, "position", target_pos, effect_data["duration"] * 0.7)
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.5)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.3)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_heal(origin: Vector3) -> void:
	var effect_data = effect_database["heal"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.5, 0.5, 0.5)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(effect_node, "position:y", origin.y + 2.0, effect_data["duration"])
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.6)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.4)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

func play_grand_heal(origin: Vector3) -> void:
	var effect_data = effect_database["grand_heal"]
	
	var effect_node = Node3D.new()
	effect_node.position = origin
	effect_node.scale = Vector3(0.3, 0.3, 0.3)
	effect_node.modulate = effect_data["color"]
	add_child(effect_node)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(effect_node, "position:y", origin.y + 3.0, effect_data["duration"])
	tween.tween_property(effect_node, "scale", effect_data["scale"], effect_data["duration"] * 0.7)
	tween.tween_property(effect_node, "modulate:a", 0.0, effect_data["duration"] * 0.3)
	
	await get_tree().create_timer(effect_data["duration"]).timeout
	effect_node.queue_free()

# ════════════════════════════════════════════════════════════════
# 7. 유틸리티
# ════════════════════════════════════════════════════════════════

func get_effect_data(effect_name: String) -> Dictionary:
	if effect_database.has(effect_name):
		return effect_database[effect_name].duplicate()
	return {}

func has_effect(effect_name: String) -> bool:
	return effect_database.has(effect_name)

func get_all_effects() -> Array:
	return effect_database.keys()

func play_effect_by_name(effect_name: String, origin: Vector3, direction: Vector3 = Vector3.ZERO) -> void:
	if not effect_database.has(effect_name):
		print("[EffectAnimations] 존재하지 않는 이펙트: %s" % effect_name)
		return
	
	match effect_name:
		"slash":
			play_slash_effect(origin, direction)
		"thrust":
			play_thrust_effect(origin, direction)
		"spin":
			play_spin_effect(origin)
		"fire_bolt":
			play_fire_bolt(origin, direction)
		"fireball":
			play_fireball(origin, direction)
		"flame_wave":
			play_flame_wave(origin, direction)
		"ice_bolt":
			play_ice_bolt(origin, direction)
		"blizzard":
			play_blizzard(origin)
		"wind_slash":
			play_wind_slash(origin, direction)
		"poison_cloud":
			play_poison_cloud(origin)
		"heal":
			play_heal(origin)
		"grand_heal":
			play_grand_heal(origin)
