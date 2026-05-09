"""
NEXUS 무술 창조 게임 - 고급 파티클 시스템
=========================================

작성자: 천재 ⚡
작성일: 2026-05-09 (Week 3 Day 2)
목표: 5가지 베이스 파티클 템플릿 + 무술별 조합

주요 기능:
  - 5가지 베이스 파티클 (Fire/Ice/Lightning/Wind/Holy)
  - 파티클 풀링 (성능 최적화)
  - 무술 이펙트 조합 시스템
  - 라이팅 & 블룸 동적 생성
  - 리얼타임 커스터마이징
"""

extends Node3D

class_name ParticleSystemAdvanced


# ============================================================================
# 1. 상수 정의
# ============================================================================

const PARTICLE_BASES = {
    "fire": {
        "color": Color(1.0, 0.5, 0.0),      # 주황색
        "lifetime": 1.5,
        "speed": 5.0,
        "spread": 30.0,
        "gravity": -0.5,
        "texture": "res://assets/textures/particle_fire.png",
        "emission_rate": 100
    },
    "ice": {
        "color": Color(0.5, 0.8, 1.0),      # 하늘색
        "lifetime": 2.0,
        "speed": 3.0,
        "spread": 20.0,
        "gravity": 1.0,
        "texture": "res://assets/textures/particle_ice.png",
        "emission_rate": 80
    },
    "lightning": {
        "color": Color(1.0, 1.0, 0.0),      # 노랑
        "lifetime": 0.5,
        "speed": 10.0,
        "spread": 15.0,
        "gravity": 0.0,
        "texture": "res://assets/textures/particle_lightning.png",
        "emission_rate": 200
    },
    "wind": {
        "color": Color(0.7, 0.9, 1.0),      # 밝은 파랑
        "lifetime": 1.0,
        "speed": 8.0,
        "spread": 25.0,
        "gravity": 0.1,
        "texture": "res://assets/textures/particle_wind.png",
        "emission_rate": 120
    },
    "holy": {
        "color": Color(1.0, 0.95, 0.7),     # 황금색
        "lifetime": 2.5,
        "speed": 2.0,
        "spread": 10.0,
        "gravity": -1.0,
        "texture": "res://assets/textures/particle_holy.png",
        "emission_rate": 60
    }
}

const LIGHT_PROPERTIES = {
    "fire": {"color": Color.ORANGE, "energy": 2.0, "range": 5.0},
    "ice": {"color": Color.LIGHT_BLUE, "energy": 1.5, "range": 4.0},
    "lightning": {"color": Color.YELLOW, "energy": 3.0, "range": 6.0},
    "wind": {"color": Color.CYAN, "energy": 1.0, "range": 3.0},
    "holy": {"color": Color.WHITE, "energy": 2.5, "range": 5.0}
}


# ============================================================================
# 2. 데이터 클래스
# ============================================================================

class ParticleEffect:
    var effect_id: String
    var base_type: String         # fire, ice, lightning, wind, holy
    var intensity: float = 1.0    # 0.5 ~ 2.0
    var scale: float = 1.0
    var duration: float
    var has_light: bool = true
    var light_intensity: float = 1.0
    var particle_node: GPUParticles3D
    var light_node: OmniLight3D
    
    func _init(effect_id: String, base_type: String, duration: float = 2.0):
        self.effect_id = effect_id
        self.base_type = base_type
        self.duration = duration


class ParticlePool:
    """파티클 풀링 (성능 최적화)"""
    var pool: Array[GPUParticles3D] = []
    var pool_size: int = 50
    var particle_base: String
    
    func _init(base: String, size: int = 50):
        particle_base = base
        pool_size = size
        _initialize_pool()
    
    func _initialize_pool():
        """파티클 풀 초기화"""
        for i in range(pool_size):
            var particle = GPUParticles3D.new()
            particle.name = "Particle_%s_%d" % [particle_base, i]
            particle.enabled = false
            pool.append(particle)
    
    func get_particle() -> GPUParticles3D:
        """사용 가능한 파티클 얻기"""
        for p in pool:
            if not p.enabled:
                return p
        # 풀이 부족하면 새로 생성
        var new_p = GPUParticles3D.new()
        pool.append(new_p)
        return new_p
    
    func return_particle(particle: GPUParticles3D):
        """사용 완료된 파티클 반환"""
        particle.enabled = false


# ============================================================================
# 3. 파티클 시스템 매니저
# ============================================================================

class_name ParticleSystemManager
extends Node3D


# 멤버 변수
var particle_pools: Dictionary = {}  # base_type -> ParticlePool
var active_effects: Array[ParticleEffect] = []
var effect_registry: Dictionary = {}  # effect_id -> ParticleEffect


func _ready():
    """초기화"""
    _initialize_pools()
    print("[ParticleSystem] 파티클 시스템 초기화 완료")


func _initialize_pools():
    """파티클 풀 초기화"""
    for base_type in PARTICLE_BASES.keys():
        particle_pools[base_type] = ParticlePool.new(base_type, 50)
        print("[ParticleSystem] %s 풀 생성 (50개)" % base_type)


func _process(delta):
    """프레임마다 실행"""
    # 만료된 이펙트 제거
    var expired = []
    for effect in active_effects:
        effect.duration -= delta
        if effect.duration <= 0:
            expired.append(effect)
    
    for effect in expired:
        stop_effect(effect.effect_id)


# ============================================================================
# 4. 이펙트 생성 및 관리
# ============================================================================

func create_effect(effect_id: String, base_type: String, position: Vector3, duration: float = 2.0) -> ParticleEffect:
    """새로운 파티클 이펙트 생성"""
    
    if base_type not in PARTICLE_BASES:
        print("[ERROR] 알 수 없는 파티클 베이스: %s" % base_type)
        return null
    
    var effect = ParticleEffect.new(effect_id, base_type, duration)
    
    # 파티클 생성
    var pool = particle_pools[base_type]
    var particle = pool.get_particle()
    particle.global_position = position
    particle.enabled = true
    effect.particle_node = particle
    
    # 라이트 생성 (선택)
    if effect.has_light:
        var light = OmniLight3D.new()
        var light_props = LIGHT_PROPERTIES[base_type]
        light.light_color = light_props["color"]
        light.light_energy = light_props["energy"] * effect.light_intensity
        light.omni_range = light_props["range"]
        light.global_position = position
        add_child(light)
        effect.light_node = light
    
    add_child(particle)
    active_effects.append(effect)
    effect_registry[effect_id] = effect
    
    print("[ParticleSystem] 이펙트 생성: %s (%s)" % [effect_id, base_type])
    
    return effect


func stop_effect(effect_id: String):
    """파티클 이펙트 중지"""
    if effect_id not in effect_registry:
        return
    
    var effect = effect_registry[effect_id]
    
    # 파티클 풀에 반환
    if effect.particle_node:
        particle_pools[effect.base_type].return_particle(effect.particle_node)
    
    # 라이트 제거
    if effect.light_node:
        effect.light_node.queue_free()
    
    # 목록에서 제거
    active_effects.erase(effect)
    effect_registry.erase(effect_id)
    
    print("[ParticleSystem] 이펙트 중지: %s" % effect_id)


func set_effect_intensity(effect_id: String, intensity: float):
    """이펙트 강도 조정 (0.5 ~ 2.0)"""
    if effect_id not in effect_registry:
        return
    
    var effect = effect_registry[effect_id]
    effect.intensity = clamp(intensity, 0.5, 2.0)
    
    if effect.particle_node:
        effect.particle_node.amount_ratio = effect.intensity


func set_effect_scale(effect_id: String, scale: float):
    """이펙트 크기 조정"""
    if effect_id not in effect_registry:
        return
    
    var effect = effect_registry[effect_id]
    effect.scale = scale
    
    if effect.particle_node:
        effect.particle_node.scale = Vector3.ONE * scale


# ============================================================================
# 5. 무술 이펙트 조합 시스템
# ============================================================================

func create_martial_art_effect(martial_art_id: String, position: Vector3, 
                              bases: Array[String], duration: float = 1.5) -> Array[ParticleEffect]:
    """무술의 베이스 조합으로 이펙트 생성"""
    
    var effects = []
    var offset = 0.0
    
    for base in bases:
        var effect_id = "%s_%s_%d" % [martial_art_id, base, randi()]
        var effect = create_effect(effect_id, base, position + Vector3(offset, 0, 0), duration)
        if effect:
            effects.append(effect)
        offset += 0.5
    
    return effects


# ============================================================================
# 6. 디버그 함수
# ============================================================================

func debug_print_active_effects():
    """현재 활성 이펙트 출력"""
    print("\n=== 활성 파티클 이펙트 ===")
    for effect in active_effects:
        print("  [%s] %s (남은 시간: %.1f초)" % [effect.effect_id, effect.base_type, effect.duration])
    print("========================\n")


func debug_print_pool_status():
    """파티클 풀 상태 출력"""
    print("\n=== 파티클 풀 상태 ===")
    for base_type in particle_pools.keys():
        var pool = particle_pools[base_type]
        var available = 0
        for p in pool.pool:
            if not p.enabled:
                available += 1
        print("  [%s] %d/%d 사용 가능" % [base_type, available, pool.pool_size])
    print("====================\n")


# ============================================================================
# 7. 싱글톤 패턴
# ============================================================================

static var _instance: ParticleSystemManager

static func get_instance() -> ParticleSystemManager:
    if not _instance:
        _instance = ParticleSystemManager.new()
    return _instance
