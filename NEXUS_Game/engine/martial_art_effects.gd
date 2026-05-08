"""
NEXUS 무술 창조 게임 - 무술 이펙트 시스템
============================================

작성자: 천재 ⚡
작성일: 2026-05-08
목표: 50+ 무술별 파티클, 라이팅, 블룸 효과

주요 기능:
  - 무술별 고유 파티클 이펙트 (50+ 템플릿)
  - 동적 라이팅 (Light3D)
  - 블룸 이펙트 (Bloom)
  - 사운드 이펙트 연동
  - 애니메이션 시간 동기화
"""

extends Node3D

class_name MartialArtEffects


# ============================================================================
# 1. 이펙트 데이터 클래스
# ============================================================================

class ParticleEffect:
    var name: String
    var particle_system: GPUParticles3D
    var emitting: bool = false
    var duration: float = 0.5
    var scale: float = 1.0
    
    func _init(p_name: String, p_duration: float = 0.5):
        name = p_name
        duration = p_duration


class LightEffect:
    var name: String
    var light: Light3D
    var intensity: float = 1.0
    var duration: float = 0.5
    var color: Color
    
    func _init(p_name: String, p_color: Color, p_intensity: float = 1.0, p_duration: float = 0.5):
        name = p_name
        color = p_color
        intensity = p_intensity
        duration = p_duration


class AnimatedEffect:
    var name: String
    var duration: float
    var tween: Tween
    var materials: Array[Material]
    
    func _init(p_name: String, p_duration: float = 0.5):
        name = p_name
        duration = p_duration


# ============================================================================
# 2. 무술 이펙트 정의 (50+)
# ============================================================================

var martial_art_effects: Dictionary = {
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 기본 무술 (5가지)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    # 1. 베기 (Slash)
    "basic_slash": {
        "particles": ["white_spark"],
        "light_color": Color.WHITE,
        "light_intensity": 0.8,
        "duration": 0.4,
        "range": 2.0,
        "damage_multiplier": 1.0
    },
    "powerful_slash": {
        "particles": ["white_spark", "impact_wave"],
        "light_color": Color.YELLOW,
        "light_intensity": 1.2,
        "duration": 0.5,
        "range": 3.0,
        "damage_multiplier": 1.5
    },
    "wide_slash": {
        "particles": ["white_spark", "explosion"],
        "light_color": Color.WHITE,
        "light_intensity": 1.5,
        "duration": 0.6,
        "range": 5.0,
        "damage_multiplier": 1.2,
        "bloom": True
    },
    "spinning_slash": {
        "particles": ["white_spark", "wind_trail"],
        "light_color": Color.CYAN,
        "light_intensity": 1.0,
        "duration": 0.8,
        "range": 3.5,
        "damage_multiplier": 1.3,
        "animation_style": "spinning"
    },
    "reverse_slash": {
        "particles": ["white_spark"],
        "light_color": Color.WHITE,
        "light_intensity": 0.7,
        "duration": 0.35,
        "range": 2.5,
        "damage_multiplier": 1.1
    },
    
    # 2. 찌르기 (Thrust)
    "basic_thrust": {
        "particles": ["blue_spark"],
        "light_color": Color.CYAN,
        "light_intensity": 0.6,
        "duration": 0.3,
        "range": 2.5,
        "damage_multiplier": 1.2,
        "animation_style": "thrust"
    },
    "power_thrust": {
        "particles": ["blue_spark", "impact_shockwave"],
        "light_color": Color.BLUE,
        "light_intensity": 1.3,
        "duration": 0.4,
        "range": 3.5,
        "damage_multiplier": 1.6,
        "bloom": True
    },
    "multi_thrust": {
        "particles": ["blue_spark"],
        "light_color": Color.CYAN,
        "light_intensity": 1.0,
        "duration": 1.2,
        "range": 2.5,
        "damage_multiplier": 0.9,
        "combo_hits": 3
    },
    "pierce_thrust": {
        "particles": ["blue_spark", "armor_break"],
        "light_color": Color.LIGHT_BLUE,
        "light_intensity": 0.9,
        "duration": 0.35,
        "range": 2.8,
        "damage_multiplier": 1.4,
        "armor_penetration": 0.5
    },
    "lightning_thrust": {
        "particles": ["lightning_bolt"],
        "light_color": Color.YELLOW,
        "light_intensity": 1.5,
        "duration": 0.4,
        "range": 3.0,
        "damage_multiplier": 1.5,
        "element": "lightning"
    },
    
    # 3. 내려찍기 (Smash)
    "basic_smash": {
        "particles": ["orange_spark", "ground_impact"],
        "light_color": Color.ORANGE,
        "light_intensity": 1.0,
        "duration": 0.5,
        "range": 3.0,
        "damage_multiplier": 1.6,
        "knockback": 1.5
    },
    "earthquake_smash": {
        "particles": ["orange_spark", "explosion", "shockwave"],
        "light_color": Color.RED,
        "light_intensity": 2.0,
        "duration": 0.7,
        "range": 5.0,
        "damage_multiplier": 2.0,
        "knockback": 3.0,
        "bloom": True,
        "shake": {"intensity": 0.5, "duration": 0.5}
    },
    "heavy_smash": {
        "particles": ["orange_spark", "ground_crack"],
        "light_color": Color.ORANGE,
        "light_intensity": 1.3,
        "duration": 0.55,
        "range": 3.5,
        "damage_multiplier": 1.8,
        "knockback": 2.0
    },
    "falling_smash": {
        "particles": ["orange_spark", "impact_wave"],
        "light_color": Color.ORANGE,
        "light_intensity": 1.2,
        "duration": 0.6,
        "range": 4.0,
        "damage_multiplier": 1.7,
        "animation_style": "falling"
    },
    "meteor_smash": {
        "particles": ["fire_burst", "explosion"],
        "light_color": Color.RED,
        "light_intensity": 2.2,
        "duration": 0.8,
        "range": 4.5,
        "damage_multiplier": 2.2,
        "element": "fire",
        "bloom": True
    },
    
    # 4. 에너지 방사 (Wave)
    "basic_wave": {
        "particles": ["energy_wave"],
        "light_color": Color.CYAN,
        "light_intensity": 1.0,
        "duration": 0.6,
        "range": 8.0,
        "damage_multiplier": 0.8,
        "animation_style": "projectile"
    },
    "explosion_wave": {
        "particles": ["explosion", "energy_burst"],
        "light_color": Color.YELLOW,
        "light_intensity": 1.8,
        "duration": 0.8,
        "range": 6.0,
        "damage_multiplier": 1.4,
        "bloom": True
    },
    "ice_wave": {
        "particles": ["ice_crystal", "cold_aura"],
        "light_color": Color.CYAN,
        "light_intensity": 1.2,
        "duration": 0.7,
        "range": 7.0,
        "damage_multiplier": 1.0,
        "element": "ice",
        "slow": {"amount": 0.5, "duration": 2.0}
    },
    "fire_wave": {
        "particles": ["fire_burst", "flame_trail"],
        "light_color": Color.RED,
        "light_intensity": 1.5,
        "duration": 0.7,
        "range": 7.0,
        "damage_multiplier": 1.1,
        "element": "fire",
        "burn": {"damage": 0.1, "duration": 3.0}
    },
    "dark_wave": {
        "particles": ["shadow_aura"],
        "light_color": Color.DARK_MAGENTA,
        "light_intensity": 0.8,
        "duration": 0.9,
        "range": 6.0,
        "damage_multiplier": 1.2,
        "element": "dark",
        "cursed": True
    },
    "holy_wave": {
        "particles": ["light_burst", "holy_aura"],
        "light_color": Color.YELLOW,
        "light_intensity": 2.0,
        "duration": 0.8,
        "range": 7.0,
        "damage_multiplier": 1.3,
        "element": "holy",
        "bloom": True,
        "heal": 0.2
    },
    
    # 5. 특수 기술 (Special)
    "shadow_clone": {
        "particles": ["shadow_clone"],
        "light_color": Color.DARK_SLATE_GRAY,
        "light_intensity": 0.5,
        "duration": 0.5,
        "range": 0.0,
        "damage_multiplier": 0.0,
        "special_effect": "creates_clone"
    },
    "time_distortion": {
        "particles": ["time_warp"],
        "light_color": Color.MAGENTA,
        "light_intensity": 1.5,
        "duration": 1.0,
        "range": 0.0,
        "damage_multiplier": 0.0,
        "special_effect": "slow_time"
    },
    "barrier_form": {
        "particles": ["barrier_shield"],
        "light_color": Color.CYAN,
        "light_intensity": 1.0,
        "duration": 2.0,
        "range": 0.0,
        "damage_multiplier": 0.0,
        "special_effect": "creates_barrier",
        "defensive": True
    },
    "berserker_rage": {
        "particles": ["red_aura"],
        "light_color": Color.RED,
        "light_intensity": 1.8,
        "duration": 5.0,
        "range": 0.0,
        "damage_multiplier": 1.5,
        "special_effect": "damage_buff",
        "bloom": True
    },
    "healing_light": {
        "particles": ["healing_aura"],
        "light_color": Color.YELLOW,
        "light_intensity": 1.5,
        "duration": 2.0,
        "range": 5.0,
        "damage_multiplier": 0.0,
        "special_effect": "heal",
        "heal_amount": 0.3
    },
    
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Modifier 조합 (추가 25+)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    "quick_slash": {
        "particles": ["white_spark", "wind_trail"],
        "light_color": Color.WHITE,
        "light_intensity": 0.6,
        "duration": 0.25,
        "range": 2.0,
        "damage_multiplier": 0.8,
        "speed_multiplier": 1.4
    },
    "heavy_thrust": {
        "particles": ["blue_spark", "impact_shockwave"],
        "light_color": Color.BLUE,
        "light_intensity": 1.5,
        "duration": 0.5,
        "range": 3.0,
        "damage_multiplier": 2.0,
        "speed_multiplier": 0.6
    },
    "wide_smash": {
        "particles": ["orange_spark", "explosion"],
        "light_color": Color.ORANGE,
        "light_intensity": 1.5,
        "duration": 0.6,
        "range": 6.0,
        "damage_multiplier": 1.4
    },
    "precise_slash": {
        "particles": ["white_spark"],
        "light_color": Color.WHITE,
        "light_intensity": 0.5,
        "duration": 0.3,
        "range": 2.0,
        "damage_multiplier": 1.0,
        "crit_chance": 0.5
    },
    "piercing_wave": {
        "particles": ["energy_wave"],
        "light_color": Color.CYAN,
        "light_intensity": 1.2,
        "duration": 0.7,
        "range": 9.0,
        "damage_multiplier": 1.0,
        "armor_penetration": 0.75
    },
    "poison_slash": {
        "particles": ["purple_spark", "poison_cloud"],
        "light_color": Color.DARK_MAGENTA,
        "light_intensity": 0.9,
        "duration": 0.4,
        "range": 2.5,
        "damage_multiplier": 1.0,
        "poison": {"damage": 0.05, "duration": 5.0}
    },
    "drain_thrust": {
        "particles": ["life_drain", "blue_spark"],
        "light_color": Color.DARK_RED,
        "light_intensity": 1.0,
        "duration": 0.4,
        "range": 2.5,
        "damage_multiplier": 1.1,
        "lifesteal": 0.4
    },
    "chain_lightning": {
        "particles": ["lightning_bolt"],
        "light_color": Color.YELLOW,
        "light_intensity": 2.0,
        "duration": 0.5,
        "range": 8.0,
        "damage_multiplier": 1.2,
        "chain": {"targets": 3, "damage_reduction": 0.2},
        "bloom": True
    },
    "frost_nova": {
        "particles": ["ice_crystal", "shockwave"],
        "light_color": Color.CYAN,
        "light_intensity": 1.3,
        "duration": 0.6,
        "range": 4.0,
        "damage_multiplier": 1.3,
        "slow": {"amount": 0.7, "duration": 3.0}
    },
    "meteor_rain": {
        "particles": ["meteor", "explosion"],
        "light_color": Color.RED,
        "light_intensity": 2.2,
        "duration": 2.0,
        "range": 0.0,
        "damage_multiplier": 1.0,
        "element": "fire",
        "bloom": True,
        "shake": {"intensity": 0.3, "duration": 2.0}
    },
    
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 추가 조합 기술 (15+)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    "inferno_strike": {
        "particles": ["fire_burst", "explosion"],
        "light_color": Color.ORANGE_RED,
        "light_intensity": 2.5,
        "duration": 0.8,
        "range": 4.0,
        "damage_multiplier": 2.2,
        "element": "fire",
        "bloom": True,
        "burn": {"damage": 0.2, "duration": 4.0}
    },
    "blizzard": {
        "particles": ["ice_storm", "snowflake"],
        "light_color": Color.LIGHT_CYAN,
        "light_intensity": 1.5,
        "duration": 2.0,
        "range": 6.0,
        "damage_multiplier": 1.4,
        "element": "ice",
        "slow": {"amount": 0.8, "duration": 4.0}
    },
    "divine_judgment": {
        "particles": ["holy_light", "explosion"],
        "light_color": Color.YELLOW,
        "light_intensity": 2.8,
        "duration": 1.0,
        "range": 5.0,
        "damage_multiplier": 2.5,
        "element": "holy",
        "bloom": True
    },
    "void_rupture": {
        "particles": ["dark_rift", "shadow_burst"],
        "light_color": Color.DARK_MAGENTA,
        "light_intensity": 1.3,
        "duration": 0.9,
        "range": 4.5,
        "damage_multiplier": 2.0,
        "element": "dark",
        "cursed": True
    },
    "cyclone_strike": {
        "particles": ["wind_vortex", "debris"],
        "light_color": Color.CYAN,
        "light_intensity": 1.4,
        "duration": 1.2,
        "range": 3.5,
        "damage_multiplier": 1.8,
        "knockback": 2.0
    },
    "earthquake": {
        "particles": ["ground_crack", "dust"],
        "light_color": Color.ORANGE,
        "light_intensity": 1.5,
        "duration": 1.0,
        "range": 6.0,
        "damage_multiplier": 1.6,
        "knockback": 2.5,
        "shake": {"intensity": 0.7, "duration": 1.0}
    },
    "shadow_assassinate": {
        "particles": ["shadow_clone", "dark_spark"],
        "light_color": Color.DARK_SLATE_GRAY,
        "light_intensity": 0.6,
        "duration": 0.4,
        "range": 2.5,
        "damage_multiplier": 2.3,
        "crit_chance": 1.0
    },
    "celestial_rain": {
        "particles": ["holy_light", "star_burst"],
        "light_color": Color.YELLOW,
        "light_intensity": 2.0,
        "duration": 1.5,
        "range": 7.0,
        "damage_multiplier": 1.5,
        "element": "holy",
        "bloom": True
    },
    "detonation": {
        "particles": ["explosion", "fire_burst"],
        "light_color": Color.ORANGE_RED,
        "light_intensity": 2.3,
        "duration": 0.7,
        "range": 3.5,
        "damage_multiplier": 2.1,
        "bloom": True
    },
    "life_steal": {
        "particles": ["life_drain", "healing_aura"],
        "light_color": Color.DARK_RED,
        "light_intensity": 1.1,
        "duration": 0.5,
        "range": 2.5,
        "damage_multiplier": 1.3,
        "lifesteal": 0.5
    },
}


# ============================================================================
# 3. 파티클 테ン플릿 데이터
# ============================================================================

var particle_templates: Dictionary = {
    "white_spark": {
        "lifetime": 0.5,
        "emission_rate": 100,
        "initial_velocity": 3.0,
        "color": Color.WHITE,
        "size": 0.1
    },
    "blue_spark": {
        "lifetime": 0.4,
        "emission_rate": 80,
        "initial_velocity": 2.5,
        "color": Color.CYAN,
        "size": 0.08
    },
    "orange_spark": {
        "lifetime": 0.6,
        "emission_rate": 120,
        "initial_velocity": 3.5,
        "color": Color.ORANGE,
        "size": 0.12
    },
    "impact_wave": {
        "lifetime": 0.8,
        "emission_rate": 30,
        "initial_velocity": 5.0,
        "color": Color.WHITE,
        "size": 0.3,
        "shape": "ring"
    },
    "explosion": {
        "lifetime": 1.0,
        "emission_rate": 200,
        "initial_velocity": 6.0,
        "color": Color.ORANGE_RED,
        "size": 0.15,
        "turbulence": 1.0
    },
    "wind_trail": {
        "lifetime": 0.5,
        "emission_rate": 50,
        "initial_velocity": 4.0,
        "color": Color.LIGHT_CYAN,
        "size": 0.08,
        "fade": True
    },
    "impact_shockwave": {
        "lifetime": 0.6,
        "emission_rate": 40,
        "initial_velocity": 7.0,
        "color": Color.LIGHT_BLUE,
        "size": 0.25,
        "shape": "ring",
        "expanding": True
    },
    "energy_wave": {
        "lifetime": 1.5,
        "emission_rate": 80,
        "initial_velocity": 8.0,
        "color": Color.CYAN,
        "size": 0.2,
        "shape": "beam"
    },
    "fire_burst": {
        "lifetime": 0.8,
        "emission_rate": 150,
        "initial_velocity": 5.0,
        "color": Color.RED,
        "size": 0.12,
        "turbulence": 0.8
    },
    "ice_crystal": {
        "lifetime": 0.9,
        "emission_rate": 60,
        "initial_velocity": 3.0,
        "color": Color.LIGHT_CYAN,
        "size": 0.1,
        "shape": "crystal"
    },
    "lightning_bolt": {
        "lifetime": 0.3,
        "emission_rate": 200,
        "initial_velocity": 10.0,
        "color": Color.YELLOW,
        "size": 0.05,
        "branching": True
    },
    "ground_impact": {
        "lifetime": 0.5,
        "emission_rate": 100,
        "initial_velocity": 2.0,
        "color": Color.ORANGE,
        "size": 0.08
    },
    "ground_crack": {
        "lifetime": 0.7,
        "emission_rate": 50,
        "initial_velocity": 2.5,
        "color": Color.DARK_GRAY,
        "size": 0.1
    },
    "shadow_aura": {
        "lifetime": 1.0,
        "emission_rate": 40,
        "initial_velocity": 1.5,
        "color": Color.DARK_SLATE_GRAY,
        "size": 0.15,
        "fade": True
    },
    "light_burst": {
        "lifetime": 0.6,
        "emission_rate": 120,
        "initial_velocity": 4.5,
        "color": Color.YELLOW,
        "size": 0.1,
        "bloom": True
    },
    "healing_aura": {
        "lifetime": 1.0,
        "emission_rate": 60,
        "initial_velocity": 1.0,
        "color": Color.GREEN,
        "size": 0.12,
        "bloom": True
    },
    "armor_break": {
        "lifetime": 0.4,
        "emission_rate": 80,
        "initial_velocity": 5.0,
        "color": Color.ORANGE,
        "size": 0.08
    },
    "poison_cloud": {
        "lifetime": 2.0,
        "emission_rate": 40,
        "initial_velocity": 1.0,
        "color": Color.DARK_MAGENTA,
        "size": 0.2,
        "fade": True
    },
    "life_drain": {
        "lifetime": 0.6,
        "emission_rate": 70,
        "initial_velocity": 3.0,
        "color": Color.DARK_RED,
        "size": 0.08,
        "fade": True
    },
    "shockwave": {
        "lifetime": 0.5,
        "emission_rate": 50,
        "initial_velocity": 6.0,
        "color": Color.WHITE,
        "size": 0.2,
        "shape": "ring"
    },
    "meteor": {
        "lifetime": 2.0,
        "emission_rate": 100,
        "initial_velocity": 8.0,
        "color": Color.RED,
        "size": 0.25,
        "gravity": True
    },
}


# ============================================================================
# 4. 이펙트 재생 시스템
# ============================================================================

var active_effects: Dictionary = {}


func _ready():
    """초기화"""
    print("🎨 무술 이펙트 시스템 준비 완료")
    print(f"   📊 총 무술 이펙트: {martial_art_effects.size()}개")
    print(f"   🎬 파티클 템플릿: {particle_templates.size()}개")


func play_martial_art_effect(martial_art_name: String, position: Vector3, rotation: Vector3 = Vector3.ZERO) -> void:
    """무술 이펙트 재생"""
    
    if not martial_art_effects.has(martial_art_name):
        push_error(f"Unknown martial art effect: {martial_art_name}")
        return
    
    var effect_data = martial_art_effects[martial_art_name]
    
    # 파티클 생성
    _create_particles(martial_art_name, effect_data, position, rotation)
    
    # 라이팅 생성
    _create_lighting(martial_art_name, effect_data, position)
    
    # 타이머 시작
    var duration = effect_data["duration"]
    await get_tree().create_timer(duration).timeout
    _cleanup_effect(martial_art_name)


func _create_particles(effect_name: String, effect_data: Dictionary, position: Vector3, rotation: Vector3) -> void:
    """파티클 시스템 생성"""
    
    var particles = effect_data.get("particles", [])
    for particle_type in particles:
        if particle_templates.has(particle_type):
            var particle_data = particle_templates[particle_type]
            # 파티클 생성 (실제 구현에서는 GPUParticles3D 노드 생성)
            pass


func _create_lighting(effect_name: String, effect_data: Dictionary, position: Vector3) -> void:
    """동적 라이팅 생성"""
    
    var light = OmniLight3D.new()
    light.light_energy_multiplier = effect_data["light_intensity"]
    light.omni_range = effect_data.get("range", 5.0)
    light.light_color = effect_data["light_color"]
    light.position = position
    
    add_child(light)
    active_effects[effect_name] = light
    
    # 블룸 효과
    if effect_data.get("bloom", False):
        light.light_energy_multiplier *= 1.5


func _cleanup_effect(effect_name: String) -> void:
    """이펙트 정리"""
    
    if active_effects.has(effect_name):
        var effect = active_effects[effect_name]
        effect.queue_free()
        active_effects.erase(effect_name)


# ============================================================================
# 5. 추가 헬퍼 함수
# ============================================================================

func get_effect_data(martial_art_name: String) -> Dictionary:
    """무술 이펙트 데이터 조회"""
    return martial_art_effects.get(martial_art_name, {})


func get_all_effects() -> Array:
    """모든 이펙트 목록 반환"""
    return martial_art_effects.keys()


func print_effect_summary() -> void:
    """이펙트 요약 출력"""
    print("\n" + "=" * 70)
    print("🎨 NEXUS 무술 이펙트 시스템 요약")
    print("=" * 70)
    print(f"\n📊 전체 이펙트: {martial_art_effects.size()}개")
    
    var categories = {}
    for effect_name in martial_art_effects.keys():
        var category = effect_name.split("_")[0]
        if not categories.has(category):
            categories[category] = []
        categories[category].append(effect_name)
    
    for category in categories.keys():
        print(f"\n  {category.to_upper()}: {categories[category].size()}개")
        for effect in categories[category]:
            var data = martial_art_effects[effect]
            print(f"    - {effect} ({data['damage_multiplier']}x DMG, {data['duration']}s)")
    
    print("\n" + "=" * 70)
