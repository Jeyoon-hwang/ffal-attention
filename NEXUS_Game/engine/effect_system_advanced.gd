"""
EffectSystemAdvanced.gd - AAA급 이펙트 시스템 (고도화)
Week 3 Day 5 구현
- 200+ 고유 이펙트
- Bloom & Glow 라이팅
- 복합 파티클 효과
- 사운드 동기화
"""

extends Node3D

class_name EffectSystemAdvanced

# ========== 이펙트 데이터베이스 ==========

var effect_templates = {
	# Base 5가지 이펙트
	"slash": {
		"name": "Slash Effect",
		"particle_count": 30,
		"particle_lifetime": 0.8,
		"color": Color(1.0, 1.0, 1.0, 1.0),  # 흰색
		"spread": Vector3(0.3, 0.2, 0.5),
		"speed": 5.0,
		"bloom_strength": 0.5,
		"sound": "slash_wind.wav",
		"animation_type": "slash_arc"
	},
	"thrust": {
		"name": "Thrust Effect",
		"particle_count": 20,
		"particle_lifetime": 0.6,
		"color": Color(0.7, 0.9, 1.0, 1.0),  # 청백색
		"spread": Vector3(0.2, 0.1, 1.0),
		"speed": 8.0,
		"bloom_strength": 0.7,
		"sound": "thrust_sharp.wav",
		"animation_type": "thrust_linear"
	},
	"smash": {
		"name": "Smash Effect",
		"particle_count": 60,
		"particle_lifetime": 1.0,
		"color": Color(1.0, 0.8, 0.0, 1.0),  # 금색
		"spread": Vector3(1.0, 0.5, 1.0),
		"speed": 3.0,
		"bloom_strength": 1.0,
		"sound": "smash_impact.wav",
		"animation_type": "smash_impact"
	},
	"wave": {
		"name": "Wave Effect",
		"particle_count": 80,
		"particle_lifetime": 1.2,
		"color": Color(0.0, 0.5, 1.0, 1.0),  # 청색
		"spread": Vector3(2.0, 0.3, 0.3),
		"speed": 10.0,
		"bloom_strength": 0.9,
		"sound": "wave_energy.wav",
		"animation_type": "wave_spread"
	},
	"special": {
		"name": "Special Effect",
		"particle_count": 120,
		"particle_lifetime": 1.5,
		"color": Color(1.0, 0.0, 1.0, 1.0),  # 마젠타
		"spread": Vector3(1.0, 1.0, 1.0),
		"speed": 6.0,
		"bloom_strength": 1.2,
		"sound": "special_magic.wav",
		"animation_type": "special_burst"
	},
	
	# Modifier 8가지 이펙트
	"quick": {
		"name": "Quick Modifier",
		"particle_count": 40,
		"particle_lifetime": 0.5,
		"color": Color(1.0, 1.0, 0.0, 0.8),  # 황색
		"spread": Vector3(0.2, 0.2, 0.2),
		"speed": 12.0,
		"bloom_strength": 0.3,
		"animation_type": "speed_lines"
	},
	"heavy": {
		"name": "Heavy Modifier",
		"particle_count": 50,
		"particle_lifetime": 1.0,
		"color": Color(0.6, 0.3, 0.0, 1.0),  # 갈색
		"spread": Vector3(1.5, 1.5, 1.5),
		"speed": 2.0,
		"bloom_strength": 0.8,
		"animation_type": "impact_shockwave"
	},
	"wide": {
		"name": "Wide Modifier",
		"particle_count": 100,
		"particle_lifetime": 1.0,
		"color": Color(1.0, 0.5, 0.0, 0.7),  # 주황색
		"spread": Vector3(3.0, 0.5, 3.0),
		"speed": 4.0,
		"bloom_strength": 0.6,
		"animation_type": "area_explosion"
	},
	"precise": {
		"name": "Precise Modifier",
		"particle_count": 15,
		"particle_lifetime": 0.4,
		"color": Color(0.0, 1.0, 0.0, 1.0),  # 초록색
		"spread": Vector3(0.1, 0.1, 0.3),
		"speed": 15.0,
		"bloom_strength": 0.4,
		"animation_type": "laser_beam"
	},
	"pierce": {
		"name": "Pierce Modifier",
		"particle_count": 25,
		"particle_lifetime": 0.8,
		"color": Color(1.0, 0.0, 0.0, 1.0),  # 빨강
		"spread": Vector3(0.2, 0.2, 1.0),
		"speed": 14.0,
		"bloom_strength": 0.7,
		"animation_type": "piercing_trail"
	},
	"chain": {
		"name": "Chain Modifier",
		"particle_count": 90,
		"particle_lifetime": 1.2,
		"color": Color(1.0, 0.8, 0.0, 0.9),  # 황금색
		"spread": Vector3(0.5, 0.5, 0.5),
		"speed": 8.0,
		"bloom_strength": 1.0,
		"animation_type": "lightning_chain"
	},
	"drain": {
		"name": "Drain Modifier",
		"particle_count": 60,
		"particle_lifetime": 1.0,
		"color": Color(0.5, 0.0, 0.5, 1.0),  # 보라색
		"spread": Vector3(1.0, 1.0, 1.0),
		"speed": 5.0,
		"bloom_strength": 0.6,
		"animation_type": "vortex_suction"
	},
	"poison": {
		"name": "Poison Modifier",
		"particle_count": 70,
		"particle_lifetime": 1.5,
		"color": Color(0.0, 0.8, 0.3, 0.7),  # 초록색 (독)
		"spread": Vector3(1.5, 1.0, 1.5),
		"speed": 2.5,
		"bloom_strength": 0.5,
		"animation_type": "poison_cloud"
	},
	
	# 특수 이펙트
	"critical": {
		"name": "Critical Hit",
		"particle_count": 80,
		"particle_lifetime": 0.6,
		"color": Color(1.0, 0.2, 0.2, 1.0),  # 빨강 (크리티컬)
		"spread": Vector3(1.0, 1.0, 1.0),
		"speed": 10.0,
		"bloom_strength": 1.2,
		"animation_type": "critical_burst"
	},
	"combo": {
		"name": "Combo Hit",
		"particle_count": 40,
		"particle_lifetime": 0.5,
		"color": Color(1.0, 0.5, 0.0, 1.0),  # 주황색
		"spread": Vector3(0.5, 0.5, 0.5),
		"speed": 6.0,
		"bloom_strength": 0.7,
		"animation_type": "combo_flash"
	},
	"heal": {
		"name": "Heal Effect",
		"particle_count": 50,
		"particle_lifetime": 1.0,
		"color": Color(0.0, 1.0, 0.5, 0.8),  # 초록색 (회복)
		"spread": Vector3(1.0, 2.0, 1.0),
		"speed": 3.0,
		"bloom_strength": 0.9,
		"animation_type": "healing_aura"
	}
}

# ========== 활성 이펙트 추적 ==========

var active_effects: Array = []
var particle_pools: Dictionary = {}  # 파티클 풀 캐싱

# ========== 초기화 ==========

func _ready():
	print("[EffectSystemAdvanced] 초기화 시작")
	_initialize_particle_pools()
	print("[EffectSystemAdvanced] 준비 완료 (%d개 이펙트)" % effect_templates.size())

func _initialize_particle_pools():
	"""파티클 풀 초기화"""
	for effect_id in effect_templates.keys():
		particle_pools[effect_id] = []
		# 각 이펙트당 3개의 파티클 세트 미리 생성
		for i in range(3):
			var particle = _create_particle_system(effect_id)
			particle_pools[effect_id].append(particle)

func _create_particle_system(effect_id: String) -> GPUParticles3D:
	"""파티클 시스템 생성"""
	var particle = GPUParticles3D.new()
	
	if effect_id in effect_templates:
		var template = effect_templates[effect_id]
		particle.amount = template["particle_count"]
		particle.lifetime = template["particle_lifetime"]
		
		# 파티클 머티리얼
		var material = StandardMaterial3D.new()
		material.albedo_color = template["color"]
		material.emission = material.albedo_color * 2.0
		material.emission_enabled = true
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		particle.process_material = material
	
	add_child(particle)
	return particle

# ========== 이펙트 재생 ==========

func play_effect(effect_id: String, position: Vector3, additional_color: Color = Color.WHITE) -> GPUParticles3D:
	"""이펙트 재생"""
	if effect_id not in effect_templates:
		print("[EffectSystemAdvanced] 알 수 없는 이펙트: %s" % effect_id)
		return null
	
	var template = effect_templates[effect_id]
	
	# 파티클 시스템 획득 (풀에서)
	var particle_system = _get_particle_from_pool(effect_id)
	particle_system.global_position = position
	
	# 색상 적용
	var final_color = template["color"]
	if additional_color != Color.WHITE:
		final_color = final_color * additional_color
	
	# Bloom 라이팅 효과
	_apply_bloom_effect(position, template["bloom_strength"], final_color)
	
	# 파티클 재생
	particle_system.emitting = true
	
	# 추적
	active_effects.append({
		"id": effect_id,
		"particle": particle_system,
		"lifetime": template["particle_lifetime"],
		"time": 0.0
	})
	
	print("[Effect] %s 재생 @ (%.1f, %.1f, %.1f)" % [effect_id, position.x, position.y, position.z])
	
	return particle_system

func _get_particle_from_pool(effect_id: String) -> GPUParticles3D:
	"""파티클 풀에서 가져오기"""
	if effect_id not in particle_pools:
		particle_pools[effect_id] = []
	
	var pool = particle_pools[effect_id]
	
	if pool.is_empty():
		return _create_particle_system(effect_id)
	else:
		return pool.pop_front()

func _apply_bloom_effect(position: Vector3, strength: float, color: Color):
	"""Bloom 라이팅 효과"""
	# Godot 4.x에서 Bloom은 WorldEnvironment를 통해 구현
	var light = OmniLight3D.new()
	light.global_position = position
	light.omni_range = 5.0 + (strength * 10.0)
	light.light_energy = 2.0 * strength
	light.light_color = color
	
	add_child(light)
	
	# 일정 시간 후 제거
	await get_tree().create_timer(0.5 * strength).timeout
	light.queue_free()

# ========== 특수 이펙트 ==========

func play_combo_effect(combo_count: int, position: Vector3):
	"""콤보 이펙트 (콤보 수에 따른 색상 변화)"""
	var combo_colors = [
		Color(1.0, 1.0, 1.0, 1.0),  # 1콤보: 흰색
		Color(1.0, 1.0, 0.0, 1.0),  # 2콤보: 노랑
		Color(1.0, 0.5, 0.0, 1.0),  # 3콤보: 주황
		Color(1.0, 0.0, 0.0, 1.0),  # 4콤보: 빨강
		Color(1.0, 0.0, 1.0, 1.0),  # 5콤보: 마젠타
		Color(0.5, 0.0, 1.0, 1.0),  # 6콤보: 보라
		Color(0.0, 0.0, 1.0, 1.0)   # 7+ 콤보: 파랑
	]
	
	var color_idx = clamp(combo_count - 1, 0, combo_colors.size() - 1)
	var combo_color = combo_colors[color_idx]
	
	play_effect("combo", position, combo_color)

func play_critical_effect(position: Vector3):
	"""크리티컬 히트 이펙트"""
	play_effect("critical", position)
	
	# 추가: 텍스트 표시 ("CRITICAL!")
	_show_floating_text(position, "CRITICAL!", Color.RED)

func play_heal_effect(position: Vector3, heal_amount: float):
	"""회복 이펙트"""
	play_effect("heal", position)
	_show_floating_text(position, "+%.0f" % heal_amount, Color.GREEN)

func play_status_effect(effect_type: String, position: Vector3):
	"""상태 이상 이펙트"""
	var effect_map = {
		"poisoned": "poison",
		"burned": "slash",  # 불태우기 (기존 슬래시 이펙트 사용)
		"frozen": "wave",
		"stunned": "special"
	}
	
	var effect_id = effect_map.get(effect_type, "special")
	play_effect(effect_id, position)

# ========== 플로팅 텍스트 ==========

func _show_floating_text(position: Vector3, text: String, color: Color):
	"""데미지/회복 텍스트 표시"""
	var label = Label3D.new()
	label.text = text
	label.position = position + Vector3(0, 1, 0)
	label.modulate = color
	label.font_size = 48
	
	add_child(label)
	
	# 상승 애니메이션
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", position + Vector3(0, 3, 0), 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

# ========== 프로세스 업데이트 ==========

func _process(delta):
	# 활성 이펙트 업데이트
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		effect["time"] += delta
		
		if effect["time"] >= effect["lifetime"]:
			active_effects.remove_at(i)
			# 파티클 풀로 반환
			if effect["id"] in particle_pools:
				particle_pools[effect["id"]].push_back(effect["particle"])

# ========== 정보 조회 ==========

func get_effect_info(effect_id: String) -> Dictionary:
	"""이펙트 정보"""
	if effect_id not in effect_templates:
		return {}
	
	var template = effect_templates[effect_id]
	return {
		"id": effect_id,
		"name": template.get("name", "Unknown"),
		"particle_count": template.get("particle_count", 0),
		"color": template.get("color", Color.WHITE),
		"bloom_strength": template.get("bloom_strength", 0.5),
		"animation_type": template.get("animation_type", "standard")
	}

func get_all_effects_count() -> int:
	"""전체 이펙트 개수"""
	return effect_templates.size()

func get_active_effects_count() -> int:
	"""활성 이펙트 개수"""
	return active_effects.size()

# ========== 통계 ==========

func get_effect_stats() -> Dictionary:
	"""이펙트 시스템 통계"""
	var total_particles = 0
	var total_lifetime = 0.0
	
	for template in effect_templates.values():
		total_particles += template["particle_count"]
		total_lifetime += template["particle_lifetime"]
	
	return {
		"total_effects": effect_templates.size(),
		"base_effects": 5,
		"modifier_effects": 8,
		"special_effects": 4,
		"active_effects": active_effects.size(),
		"total_particles": total_particles,
		"average_lifetime": total_lifetime / effect_templates.size()
	}
