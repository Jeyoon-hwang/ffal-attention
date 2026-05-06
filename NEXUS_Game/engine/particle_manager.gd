extends Node3D
class_name ParticleManager3D

## 무술 이펙트 파티클 시스템
## - Base 5가지 + Modifier 8가지별 시각 효과
## - 재사용 가능한 이펙트 풀
## - 색상, 크기, 방향 동적 조정

## 무술별 이펙트 설정
var martial_art_effects = {
	# Base 5가지 이펙트
	"slash": {
		"color": Color.WHITE,
		"speed": 5.0,
		"lifetime": 0.5,
		"particle_count": 20,
		"shape": "slash_wave"
	},
	"thrust": {
		"color": Color(0.8, 0.9, 1.0),
		"speed": 8.0,
		"lifetime": 0.4,
		"particle_count": 15,
		"shape": "spear_trail"
	},
	"smash": {
		"color": Color(1.0, 0.8, 0.2),
		"speed": 3.0,
		"lifetime": 0.7,
		"particle_count": 30,
		"shape": "shockwave"
	},
	"wave": {
		"color": Color(0.2, 0.8, 1.0),
		"speed": 10.0,
		"lifetime": 1.0,
		"particle_count": 40,
		"shape": "energy_wave"
	},
	"special": {
		"color": Color(1.0, 0.2, 0.8),
		"speed": 6.0,
		"lifetime": 0.8,
		"particle_count": 50,
		"shape": "special_burst"
	},
	
	# Modifier 8가지 이펙트 추가
	"quick": {
		"color": Color(1.0, 1.0, 0.3),
		"speed": 12.0,
		"lifetime": 0.3,
		"particle_count": 10,
		"shape": "speedline"
	},
	"heavy": {
		"color": Color(0.6, 0.3, 0.1),
		"speed": 2.0,
		"lifetime": 1.0,
		"particle_count": 50,
		"shape": "impact_dust"
	},
	"wide": {
		"color": Color(1.0, 0.5, 0.0),
		"speed": 4.0,
		"lifetime": 0.8,
		"particle_count": 60,
		"shape": "explosion"
	},
	"precise": {
		"color": Color(0.0, 1.0, 0.5),
		"speed": 7.0,
		"lifetime": 0.4,
		"particle_count": 12,
		"shape": "laser_beam"
	},
	"pierce": {
		"color": Color(0.8, 0.0, 0.2),
		"speed": 9.0,
		"lifetime": 0.6,
		"particle_count": 25,
		"shape": "piercing_trail"
	},
	"chain": {
		"color": Color(1.0, 0.8, 0.0),
		"speed": 11.0,
		"lifetime": 0.5,
		"particle_count": 35,
		"shape": "lightning_chain"
	},
	"drain": {
		"color": Color(0.8, 0.0, 0.8),
		"speed": 5.0,
		"lifetime": 0.7,
		"particle_count": 40,
		"shape": "drain_vortex"
	},
	"poison": {
		"color": Color(0.2, 0.8, 0.2),
		"speed": 3.0,
		"lifetime": 1.2,
		"particle_count": 45,
		"shape": "poison_cloud"
	}
}

## 파티클 이펙트 풀 (재사용)
var particle_pool = {}
var max_particles_per_effect = 5

# 생명 주기
func _ready():
	_initialize_particle_pools()

func _process(delta):
	_update_particle_effects(delta)

## 파티클 풀 초기화
func _initialize_particle_pools():
	for effect_name in martial_art_effects.keys():
		particle_pool[effect_name] = []
		
		# 이펙트당 5개씩 미리 생성
		for i in range(max_particles_per_effect):
			var particle_instance = GPUParticles3D.new()
			particle_instance.process_material = StandardMaterial3D.new()
			particle_instance.visible = false
			add_child(particle_instance)
			particle_pool[effect_name].append({
				"node": particle_instance,
				"active": false,
				"lifetime": 0.0,
				"elapsed": 0.0
			})

## 무술 이펙트 재생
func play_martial_art_effect(martial_art_name: String, position: Vector3):
	if not martial_art_name in martial_art_effects:
		push_error("Unknown martial art effect: " + martial_art_name)
		return
	
	var effect_data = martial_art_effects[martial_art_name]
	
	# 파티클 풀에서 사용 가능한 것 찾기
	if martial_art_name in particle_pool:
		for particle_info in particle_pool[martial_art_name]:
			if not particle_info["active"]:
				_activate_particle_effect(particle_info["node"], effect_data, position)
				particle_info["active"] = true
				particle_info["elapsed"] = 0.0
				particle_info["lifetime"] = effect_data["lifetime"]
				return
	
	# 풀에 없으면 새로 생성
	var new_particle = GPUParticles3D.new()
	new_particle.global_position = position
	add_child(new_particle)
	_activate_particle_effect(new_particle, effect_data, position)

## 파티클 이펙트 활성화
func _activate_particle_effect(particle_node: GPUParticles3D, effect_data: Dictionary, position: Vector3):
	particle_node.global_position = position
	particle_node.visible = true
	
	# 파티클 설정
	var material = particle_node.process_material as StandardMaterial3D
	material.albedo_color = effect_data["color"]
	
	# 파티클 개수 설정 (간단한 구현)
	particle_node.amount = effect_data["particle_count"]
	particle_node.speed_scale = effect_data["speed"]
	particle_node.lifetime = effect_data["lifetime"]
	
	# 자동 재시작
	particle_node.restart()

## 파티클 업데이트
func _update_particle_effects(delta: float):
	for effect_name in particle_pool.keys():
		for particle_info in particle_pool[effect_name]:
			if particle_info["active"]:
				particle_info["elapsed"] += delta
				if particle_info["elapsed"] >= particle_info["lifetime"]:
					particle_info["active"] = false
					particle_info["node"].visible = false

## 특수 이펙트: 콤보 이펙트
func play_combo_effect(combo_level: int, position: Vector3):
	"""
	콤보 레벨별 시각 효과
	"""
	var combo_colors = [
		Color(1.0, 1.0, 1.0),  # 1콤보
		Color(1.0, 0.8, 0.0),  # 2콤보 (황금색)
		Color(1.0, 0.0, 0.0),  # 3콤보 (빨강)
		Color(1.0, 0.0, 1.0),  # 4콤보 (마젠타)
		Color(0.0, 1.0, 1.0),  # 5콤보 (청록)
		Color(1.0, 0.5, 0.0),  # 6콤보 (주황)
		Color(0.5, 0.0, 1.0)   # 7콤보 (보라)
	]
	
	var color = combo_colors[min(combo_level - 1, combo_colors.size() - 1)]
	
	var combo_particle = GPUParticles3D.new()
	combo_particle.global_position = position
	combo_particle.amount = combo_level * 10
	combo_particle.lifetime = 0.5 + (combo_level * 0.1)
	combo_particle.speed_scale = 2.0 + (combo_level * 0.5)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	combo_particle.process_material = material
	
	add_child(combo_particle)
	combo_particle.restart()
	
	# 자동 삭제
	await get_tree().create_timer(combo_particle.lifetime + 0.1).timeout
	combo_particle.queue_free()

## 크리티컬 이펙트
func play_critical_effect(position: Vector3):
	var crit_particle = GPUParticles3D.new()
	crit_particle.global_position = position
	crit_particle.amount = 30
	crit_particle.lifetime = 0.6
	crit_particle.speed_scale = 6.0
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.0, 0.0)  # 빨강
	crit_particle.process_material = material
	
	add_child(crit_particle)
	crit_particle.restart()
	
	# 자동 삭제
	await get_tree().create_timer(0.7).timeout
	crit_particle.queue_free()

## 피해 표시 (FlyingText)
func create_damage_text(damage: int, position: Vector3, is_critical: bool = false):
	var label = Label3D.new()
	label.global_position = position + Vector3(0, 1, 0)
	label.text = str(damage)
	
	if is_critical:
		label.text = "[CRITICAL!] " + label.text
		label.modulate = Color.RED
	else:
		label.modulate = Color.WHITE
	
	label.font_size = 32
	add_child(label)
	
	# 위로 떠올림 + 페이드 아웃
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", position + Vector3(0, 3, 0), 1.0)
	tween.tween_property(label, "modulate", Color.TRANSPARENT, 1.0)
	
	await tween.finished
	label.queue_free()

## 상태 이상 이펙트
func play_status_effect(status_type: String, position: Vector3):
	"""
	상태 이상별 시각 효과 (독, 화상 등)
	"""
	var status_effects = {
		"poison": Color(0.2, 0.8, 0.2),      # 초록색
		"burn": Color(1.0, 0.5, 0.0),        # 주황색
		"freeze": Color(0.5, 0.8, 1.0),      # 하늘색
		"shock": Color(1.0, 1.0, 0.0),       # 황금색
		"curse": Color(0.5, 0.0, 0.5),       # 보라색
		"bleed": Color(1.0, 0.0, 0.2)        # 짙은 빨강
	}
	
	var color = status_effects.get(status_type, Color.WHITE)
	
	var status_particle = GPUParticles3D.new()
	status_particle.global_position = position
	status_particle.amount = 20
	status_particle.lifetime = 0.5
	status_particle.speed_scale = 1.0
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	status_particle.process_material = material
	
	add_child(status_particle)
	status_particle.restart()
	
	# 자동 삭제
	await get_tree().create_timer(0.6).timeout
	status_particle.queue_free()

## 헬스 리젠 이펙트 (Drain 무술용)
func play_heal_effect(heal_amount: int, position: Vector3):
	var heal_particle = GPUParticles3D.new()
	heal_particle.global_position = position
	heal_particle.amount = 15
	heal_particle.lifetime = 0.8
	heal_particle.speed_scale = 2.0
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 1.0, 0.2)  # 초록색
	heal_particle.process_material = material
	
	add_child(heal_particle)
	heal_particle.restart()
	
	# 텍스트 표시
	create_damage_text(heal_amount, position, false)
	
	# 자동 삭제
	await get_tree().create_timer(0.9).timeout
	heal_particle.queue_free()

## 공개 통계
func get_available_effects() -> Array:
	return martial_art_effects.keys()

func get_effect_info(effect_name: String) -> Dictionary:
	return martial_art_effects.get(effect_name, {})
