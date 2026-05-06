# 🎨 NEXUS 파티클 이펙트 시스템
# 간단한 CPU 파티클을 사용한 시각 효과

extends Node3D

# 파티클 타입 정의
var particle_types = {
	"hit": {
		"color": Color.YELLOW,
		"lifetime": 0.5,
		"scale": 0.3,
		"count": 8,
		"speed": 5.0,
		"description": "일반 공격 피격 이펙트"
	},
	"skill": {
		"color": Color.CYAN,
		"lifetime": 0.7,
		"scale": 0.5,
		"count": 12,
		"speed": 8.0,
		"description": "무술 스킬 발동 이펙트"
	},
	"spin": {
		"color": Color.ORANGE,
		"lifetime": 0.6,
		"scale": 0.4,
		"count": 16,
		"speed": 10.0,
		"description": "회전 공격 이펙트"
	},
	"dash": {
		"color": Color.RED,
		"lifetime": 0.4,
		"scale": 0.3,
		"count": 10,
		"speed": 15.0,
		"description": "대시 공격 이펙트"
	},
	"boss": {
		"color": Color.MAGENTA,
		"lifetime": 1.0,
		"scale": 0.8,
		"count": 20,
		"speed": 12.0,
		"description": "보스 공격 이펙트"
	},
	"dodge": {
		"color": Color.WHITE,
		"lifetime": 0.3,
		"scale": 0.2,
		"count": 5,
		"speed": 3.0,
		"description": "회피 성공 이펙트"
	},
	"impact": {
		"color": Color.DARK_RED,
		"lifetime": 0.5,
		"scale": 0.6,
		"count": 15,
		"speed": 6.0,
		"description": "강한 충격 이펙트"
	}
}

# 활성 파티클들
var active_particles = []

class Particle:
	var position: Vector3
	var velocity: Vector3
	var color: Color
	var lifetime: float
	var age: float = 0.0
	var scale: float
	var mesh_instance: MeshInstance3D
	
	func _init(pos: Vector3, vel: Vector3, col: Color, life: float, sc: float):
		position = pos
		velocity = vel
		color = col
		lifetime = life
		scale = sc
	
	func update(delta: float) -> bool:
		"""파티클 업데이트, false 반환 시 제거"""
		age += delta
		if age >= lifetime:
			return false
		
		# 중력 영향 (Y축)
		velocity.y -= 9.8 * delta
		
		# 위치 업데이트
		position += velocity * delta
		
		# 알파 페이드아웃
		var alpha = 1.0 - (age / lifetime)
		var faded_color = color
		faded_color.a = alpha
		
		# Mesh 업데이트 (if exists)
		if mesh_instance:
			mesh_instance.global_position = position
			mesh_instance.scale = Vector3.ONE * scale * alpha
			var material = mesh_instance.get_active_material(0).duplicate()
			material.albedo_color = faded_color
			mesh_instance.set_surface_override_material(0, material)
		
		return true

# ============================================================
# 파티클 스포닝 함수
# ============================================================

func spawn_particles(particle_type: String, position: Vector3, direction: Vector3 = Vector3.UP) -> void:
	"""
	파티클 생성
	
	Args:
		particle_type: 파티클 타입 ("hit", "skill", "spin", "dash", "boss", "dodge", "impact")
		position: 생성 위치
		direction: 파티클 방향 (기본: 위쪽)
	"""
	
	if particle_type not in particle_types:
		print("⚠️ 알 수 없는 파티클 타입: %s" % particle_type)
		return
	
	var particle_config = particle_types[particle_type]
	var count = particle_config["count"]
	var speed = particle_config["speed"]
	var lifetime = particle_config["lifetime"]
	var color = particle_config["color"]
	var scale = particle_config["scale"]
	
	# 파티클 생성 (원형으로 분산)
	for i in range(count):
		# 360도 원형 분산
		var angle = (i / float(count)) * TAU
		var spread_dir = Vector3(cos(angle), randf_range(0.3, 1.0), sin(angle)).normalized()
		var vel = direction.normalized() * speed * 0.5 + spread_dir * speed * 0.5
		
		var particle = Particle.new(position, vel, color, lifetime, scale)
		
		# 간단한 구 메시 (시각 표현)
		var mesh_instance = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.1
		mesh_instance.mesh = sphere_mesh
		
		# 재질 설정
		var material = StandardMaterial3D.new()
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		mesh_instance.set_surface_override_material(0, material)
		
		mesh_instance.global_position = position
		add_child(mesh_instance)
		
		particle.mesh_instance = mesh_instance
		active_particles.append(particle)
	
	print("✨ 파티클 생성: %s (%d개)" % [particle_type, count])

# ============================================================
# 편의 함수들
# ============================================================

func spawn_hit_effect(position: Vector3) -> void:
	"""일반 공격 피격 이펙트"""
	spawn_particles("hit", position, Vector3.UP)

func spawn_skill_effect(position: Vector3, direction: Vector3) -> void:
	"""무술 스킬 이펙트"""
	spawn_particles("skill", position, direction)

func spawn_spin_effect(position: Vector3) -> void:
	"""회전 공격 이펙트 (원형)"""
	spawn_particles("spin", position, Vector3.UP)

func spawn_dash_effect(position: Vector3, direction: Vector3) -> void:
	"""대시 공격 이펙트"""
	spawn_particles("dash", position, direction)

func spawn_boss_effect(position: Vector3) -> void:
	"""보스 공격 이펙트"""
	spawn_particles("boss", position, Vector3.UP)

func spawn_dodge_effect(position: Vector3) -> void:
	"""회피 성공 이펙트"""
	spawn_particles("dodge", position, Vector3.UP)

func spawn_impact_effect(position: Vector3) -> void:
	"""강한 충격 이펙트"""
	spawn_particles("impact", position, Vector3.UP)

# ============================================================
# 파티클 업데이트 루프
# ============================================================

func _process(delta: float) -> void:
	"""매 프레임 활성 파티클 업데이트"""
	var particles_to_remove = []
	
	for particle in active_particles:
		if not particle.update(delta):
			particles_to_remove.append(particle)
	
	# 죽은 파티클 제거
	for particle in particles_to_remove:
		if particle.mesh_instance:
			particle.mesh_instance.queue_free()
		active_particles.erase(particle)

# ============================================================
# 파티클 정보 출력
# ============================================================

func print_particle_info(particle_type: String) -> void:
	"""파티클 타입 정보 출력"""
	if particle_type in particle_types:
		var info = particle_types[particle_type]
		print("🎨 파티클: %s" % particle_type)
		print("   색상: %s | 지속시간: %.1f초 | 개수: %d" % [info["color"], info["lifetime"], info["count"]])
		print("   설명: %s" % info["description"])
	else:
		print("⚠️ 알 수 없는 파티클: %s" % particle_type)

func list_all_particles() -> void:
	"""모든 파티클 타입 나열"""
	print("\n🎨 사용 가능한 파티클 이펙트:")
	for particle_type in particle_types.keys():
		print_particle_info(particle_type)

# ============================================================
# 파티클 일괄 제거
# ============================================================

func clear_all_particles() -> void:
	"""모든 활성 파티클 제거"""
	for particle in active_particles:
		if particle.mesh_instance:
			particle.mesh_instance.queue_free()
	active_particles.clear()
	print("모든 파티클 제거됨")

# ============================================================
# 디버깅
# ============================================================

func get_active_particle_count() -> int:
	"""활성 파티클 개수 반환"""
	return active_particles.size()

func debug_print_stats() -> void:
	"""파티클 시스템 통계 출력"""
	print("\n📊 파티클 시스템 통계:")
	print("활성 파티클: %d개" % active_particles.size())
	print("파티클 타입: %d개" % particle_types.size())
