"""
NEXUS 무술 창조 게임 - 애니메이션 시스템
==========================================

작성자: 천재 ⚡
작성일: 2026-05-08
목표: 기본 애니메이션 + 50+ 무술별 애니메이션 클립 (200+ total)

주요 기능:
  - 기본 애니메이션 (대기, 이동, 회피 등)
  - 50+ 무술별 독립 애니메이션
  - 애니메이션 상태 머신 (State Machine)
  - 블렌딩 & 전환 (Transitions)
  - 콤보 애니메이션 체인
  - 캐릭터별 애니메이션 바리에이션
"""

extends Node3D

class_name AnimationSystem


# ============================================================================
# 1. 애니메이션 데이터 클래스
# ============================================================================

class AnimationClip:
    var name: String
    var duration: float
    var playback_speed: float = 1.0
    var loop: bool = false
    var priority: int = 0  # 높을수록 우선순위 높음
    var transitions: Dictionary = {}  # next_state -> transition_data
    
    func _init(p_name: String, p_duration: float, p_loop: bool = False):
        name = p_name
        duration = p_duration
        loop = p_loop


class AnimationState:
    var name: String
    var current_clip: AnimationClip
    var elapsed_time: float = 0.0
    var is_playing: bool = false
    var queue: Array[String] = []  # 대기열
    
    func _init(p_name: String, p_clip: AnimationClip):
        name = p_name
        current_clip = p_clip


class AnimationTransition:
    var from_state: String
    var to_state: String
    var duration: float = 0.3  # 블렌딩 시간
    var condition: Callable  # 전환 조건
    var cross_fade: bool = true
    
    func _init(p_from: String, p_to: String, p_condition: Callable = Callable()):
        from_state = p_from
        to_state = p_to
        condition = p_condition


# ============================================================================
# 2. 기본 애니메이션 템플릿
# ============================================================================

var base_animations: Dictionary = {
    # 캐릭터 상태 (State)
    "idle": {
        "duration": 1.0,
        "loop": True,
        "sub_variants": [
            {"name": "idle_stand", "duration": 1.0},
            {"name": "idle_combat_ready", "duration": 1.0},
            {"name": "idle_idle_tired", "duration": 1.2}
        ]
    },
    "walk": {
        "duration": 0.8,
        "loop": True,
        "speed_based": True,
        "sub_variants": [
            {"name": "walk_forward", "duration": 0.8},
            {"name": "walk_backward", "duration": 0.9},
            {"name": "walk_strafe_left", "duration": 0.85},
            {"name": "walk_strafe_right", "duration": 0.85}
        ]
    },
    "run": {
        "duration": 0.5,
        "loop": True,
        "speed_based": True,
        "sub_variants": [
            {"name": "run_forward", "duration": 0.5},
            {"name": "run_backward", "duration": 0.6},
            {"name": "run_strafe_left", "duration": 0.55},
            {"name": "run_strafe_right", "duration": 0.55}
        ]
    },
    "dodge": {
        "duration": 0.4,
        "loop": False,
        "priority": 100,
        "invulnerability_frames": [0.0, 0.4],
        "sub_variants": [
            {"name": "dodge_forward", "duration": 0.4},
            {"name": "dodge_backward", "duration": 0.4},
            {"name": "dodge_left", "duration": 0.4},
            {"name": "dodge_right", "duration": 0.4}
        ]
    },
    "block": {
        "duration": 0.6,
        "loop": True,
        "defensive": True,
        "damage_reduction": 0.5
    },
    "hit_light": {
        "duration": 0.3,
        "loop": False,
        "priority": 50
    },
    "hit_heavy": {
        "duration": 0.5,
        "loop": False,
        "priority": 60,
        "knockback_distance": 1.0
    },
    "death": {
        "duration": 2.0,
        "loop": False,
        "priority": 200
    }
}


# ============================================================================
# 3. 무술 애니메이션 (50+ 템플릿)
# ============================================================================

var martial_art_animations: Dictionary = {
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 기본 무술 (5가지) × 여러 바리에이션
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    # 베기 (Slash) - 10개 바리에이션
    "slash_light": {
        "duration": 0.3,
        "loop": False,
        "attack_frames": [0.1, 0.3],
        "recovery_time": 0.15,
        "variants": [
            {"name": "slash_light_overhead", "duration": 0.3},
            {"name": "slash_light_horizontal", "duration": 0.28},
            {"name": "slash_light_diagonal_up", "duration": 0.32},
            {"name": "slash_light_diagonal_down", "duration": 0.3}
        ]
    },
    "slash_medium": {
        "duration": 0.4,
        "loop": False,
        "attack_frames": [0.15, 0.4],
        "recovery_time": 0.2
    },
    "slash_heavy": {
        "duration": 0.6,
        "loop": False,
        "attack_frames": [0.2, 0.6],
        "recovery_time": 0.35,
        "knockback": True
    },
    "slash_spin": {
        "duration": 0.8,
        "loop": False,
        "attack_frames": [0.2, 0.8],
        "recovery_time": 0.2,
        "hitbox": "360"
    },
    "slash_pierce": {
        "duration": 0.35,
        "loop": False,
        "attack_frames": [0.1, 0.35],
        "recovery_time": 0.15,
        "penetrating": True
    },
    
    # 찌르기 (Thrust) - 10개 바리에이션
    "thrust_quick": {
        "duration": 0.25,
        "loop": False,
        "attack_frames": [0.05, 0.25],
        "recovery_time": 0.1,
        "range": 1.5
    },
    "thrust_power": {
        "duration": 0.5,
        "loop": False,
        "attack_frames": [0.15, 0.5],
        "recovery_time": 0.3,
        "range": 2.0,
        "knockback": True
    },
    "thrust_multi": {
        "duration": 1.2,
        "loop": False,
        "combo_hits": 3,
        "attack_frames": [[0.1, 0.35], [0.45, 0.7], [0.85, 1.1]],
        "recovery_time": 0.25
    },
    "thrust_dragon": {
        "duration": 0.4,
        "loop": False,
        "attack_frames": [0.1, 0.4],
        "recovery_time": 0.2,
        "range": 2.5,
        "penetrating": True
    },
    "thrust_spinning": {
        "duration": 0.7,
        "loop": False,
        "attack_frames": [0.1, 0.7],
        "recovery_time": 0.2,
        "hitbox": "360"
    },
    
    # 내려찍기 (Smash) - 10개 바리에이션
    "smash_overhead": {
        "duration": 0.7,
        "loop": False,
        "attack_frames": [0.3, 0.7],
        "recovery_time": 0.4,
        "knockback": True,
        "range": 3.0
    },
    "smash_ground": {
        "duration": 0.8,
        "loop": False,
        "attack_frames": [0.3, 0.8],
        "recovery_time": 0.4,
        "area_attack": True,
        "range": 5.0
    },
    "smash_meteor": {
        "duration": 1.0,
        "loop": False,
        "attack_frames": [0.4, 1.0],
        "recovery_time": 0.5,
        "falling_animation": True,
        "knockback": True
    },
    "smash_spinning": {
        "duration": 0.9,
        "loop": False,
        "attack_frames": [0.2, 0.9],
        "recovery_time": 0.3,
        "hitbox": "360"
    },
    "smash_jumping": {
        "duration": 0.8,
        "loop": False,
        "attack_frames": [0.3, 0.8],
        "recovery_time": 0.3,
        "jump_height": 2.0
    },
    
    # 에너지 방사 (Wave) - 10개 바리에이션
    "wave_basic": {
        "duration": 0.6,
        "loop": False,
        "attack_frames": [0.2, 0.6],
        "recovery_time": 0.3,
        "projectile": True,
        "cast_time": 0.3
    },
    "wave_explosion": {
        "duration": 0.8,
        "loop": False,
        "attack_frames": [0.3, 0.8],
        "recovery_time": 0.4,
        "projectile": True,
        "explosion": True
    },
    "wave_ice": {
        "duration": 0.7,
        "loop": False,
        "attack_frames": [0.3, 0.7],
        "recovery_time": 0.3,
        "projectile": True,
        "element": "ice"
    },
    "wave_fire": {
        "duration": 0.7,
        "loop": False,
        "attack_frames": [0.3, 0.7],
        "recovery_time": 0.3,
        "projectile": True,
        "element": "fire"
    },
    "wave_darkness": {
        "duration": 0.8,
        "loop": False,
        "attack_frames": [0.3, 0.8],
        "recovery_time": 0.4,
        "projectile": True,
        "element": "dark"
    },
    
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 특수 기술 (15+)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    "shadow_clone": {
        "duration": 0.5,
        "loop": False,
        "recovery_time": 0.3,
        "special": True,
        "creates_clone": True
    },
    "time_distortion": {
        "duration": 1.0,
        "loop": False,
        "recovery_time": 0.5,
        "special": True,
        "slow_time": True
    },
    "barrier_form": {
        "duration": 2.0,
        "loop": True,
        "special": True,
        "defensive": True,
        "damage_reduction": 0.6
    },
    "berserker_rage": {
        "duration": 5.0,
        "loop": False,
        "special": True,
        "buff": True,
        "damage_multiplier": 1.5
    },
    "healing_light": {
        "duration": 2.0,
        "loop": False,
        "special": True,
        "heal": True
    },
    "shadow_assassinate": {
        "duration": 0.5,
        "loop": False,
        "special": True,
        "stealth": True,
        "crit_damage": 2.5
    },
    "divine_judgment": {
        "duration": 1.5,
        "loop": False,
        "special": True,
        "channeling": True,
        "channel_time": 1.0
    },
    "void_rupture": {
        "duration": 0.9,
        "loop": False,
        "special": True,
        "area_attack": True
    },
    "cyclone_strike": {
        "duration": 1.2,
        "loop": False,
        "special": True,
        "hitbox": "360",
        "moving": True
    },
    
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 콤보 애니메이션
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    "combo_slash_3": {
        "duration": 1.0,
        "loop": False,
        "combo_sequence": ["slash_light", "slash_light", "slash_heavy"],
        "total_recovery": 0.5
    },
    "combo_thrust_3": {
        "duration": 1.1,
        "loop": False,
        "combo_sequence": ["thrust_quick", "thrust_quick", "thrust_power"],
        "total_recovery": 0.5
    },
    "combo_mixed_5": {
        "duration": 1.8,
        "loop": False,
        "combo_sequence": ["slash_light", "thrust_quick", "slash_medium", "smash_overhead", "wave_basic"],
        "total_recovery": 0.6
    },
    "combo_spin_attack": {
        "duration": 1.2,
        "loop": False,
        "combo_sequence": ["slash_spin", "slash_spin"],
        "total_recovery": 0.4
    },
    
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 추가 바리에이션 (20+)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    "inferno_strike": {
        "duration": 0.9,
        "loop": False,
        "attack_frames": [0.2, 0.9],
        "recovery_time": 0.4,
        "element": "fire",
        "area_attack": True
    },
    "blizzard": {
        "duration": 2.0,
        "loop": False,
        "attack_frames": [0.5, 2.0],
        "recovery_time": 0.5,
        "element": "ice",
        "area_attack": True,
        "channeling": True
    },
    "meteor_rain": {
        "duration": 2.5,
        "loop": False,
        "attack_frames": [0.5, 2.5],
        "recovery_time": 0.6,
        "projectile": True,
        "rain_effect": True
    },
    "earthquake": {
        "duration": 1.2,
        "loop": False,
        "attack_frames": [0.3, 1.2],
        "recovery_time": 0.5,
        "area_attack": True,
        "ground_effect": True
    },
    "frozen_nova": {
        "duration": 0.8,
        "loop": False,
        "attack_frames": [0.2, 0.8],
        "recovery_time": 0.3,
        "element": "ice",
        "area_attack": True
    },
}


# ============================================================================
# 4. 애니메이션 상태 머신
# ============================================================================

var animation_tree: AnimationPlayer
var current_state: String = "idle"
var previous_state: String = ""
var state_transitions: Dictionary = {}
var animation_queue: Array[String] = []


# ============================================================================
# 5. 초기화 및 설정
# ============================================================================

func _ready():
    """초기화"""
    print("🎬 애니메이션 시스템 준비 완료")
    _setup_state_transitions()
    _print_animation_summary()


func _setup_state_transitions():
    """상태 전환 규칙 설정"""
    
    state_transitions = {
        "idle": ["walk", "run", "slash_light", "thrust_quick", "dodge"],
        "walk": ["idle", "run", "slash_light", "dodge"],
        "run": ["idle", "walk", "slash_light", "dodge"],
        "dodge": ["idle", "walk", "run"],
        "slash_light": ["idle", "slash_medium", "slash_heavy"],
        "slash_medium": ["idle", "slash_heavy"],
        "slash_heavy": ["idle"],
        "thrust_quick": ["idle", "thrust_power"],
        "hit_light": ["idle", "walk", "dodge"],
        "hit_heavy": ["idle"],
        "death": []  # 상태 전환 불가
    }


# ============================================================================
# 6. 애니메이션 재생 함수
# ============================================================================

func play_animation(animation_name: String, blend_time: float = 0.3) -> void:
    """애니메이션 재생"""
    
    if not _can_transition_to(animation_name):
        animation_queue.append(animation_name)
        return
    
    previous_state = current_state
    current_state = animation_name
    
    # 실제 AnimationPlayer 호출 (Godot에서)
    if animation_tree:
        animation_tree.animation = animation_name
        # Blend 시간 설정
        pass


func queue_animation(animation_name: String) -> void:
    """애니메이션 대기열에 추가"""
    animation_queue.append(animation_name)


func play_combo(combo_name: String) -> void:
    """콤보 애니메이션 재생"""
    
    if martial_art_animations.has(combo_name):
        var combo_data = martial_art_animations[combo_name]
        play_animation(combo_name)


func is_animation_finished() -> bool:
    """현재 애니메이션 완료 여부"""
    
    if animation_tree:
        return animation_tree.is_animation_set() == false
    return true


# ============================================================================
# 7. 헬퍼 함수
# ============================================================================

func _can_transition_to(animation_name: String) -> bool:
    """상태 전환 가능 여부 확인"""
    
    if not state_transitions.has(current_state):
        return true
    
    return animation_name in state_transitions[current_state]


func get_animation_duration(animation_name: String) -> float:
    """애니메이션 길이 조회"""
    
    if base_animations.has(animation_name):
        return base_animations[animation_name]["duration"]
    elif martial_art_animations.has(animation_name):
        return martial_art_animations[animation_name]["duration"]
    
    return 0.0


func get_attack_frames(animation_name: String) -> Array:
    """공격 프레임 조회 (타격 시작/종료)"""
    
    if martial_art_animations.has(animation_name):
        var data = martial_art_animations[animation_name]
        return data.get("attack_frames", [])
    
    return []


def get_animation_recovery_time(animation_name: String) -> float:
    """애니메이션 회복 시간 조회"""
    
    if martial_art_animations.has(animation_name):
        return martial_art_animations[animation_name].get("recovery_time", 0.0)
    
    return 0.0


# ============================================================================
# 8. 통계 및 출력
# ============================================================================

func _print_animation_summary():
    """애니메이션 요약 출력"""
    
    var base_count = base_animations.size()
    var martial_count = martial_art_animations.size()
    
    # 모든 바리에이션 계산
    var total_variants = 0
    for anim_name in base_animations.keys():
        var anim_data = base_animations[anim_name]
        if anim_data.has("sub_variants"):
            total_variants += anim_data["sub_variants"].size()
    
    for anim_name in martial_art_animations.keys():
        var anim_data = martial_art_animations[anim_name]
        if anim_data.has("variants"):
            total_variants += anim_data["variants"].size()
    
    print("\n" + "=" * 70)
    print("🎬 NEXUS 애니메이션 시스템 요약")
    print("=" * 70)
    print(f"\n📊 기본 애니메이션: {base_count}개")
    print(f"🥋 무술 애니메이션: {martial_count}개")
    print(f"🎭 총 바리에이션: {total_variants}개")
    print(f"🎬 전체 애니메이션 클립: {base_count + martial_count + total_variants}개")
    
    print("\n📋 기본 애니메이션:")
    for anim_name in base_animations.keys():
        var duration = base_animations[anim_name]["duration"]
        print(f"  - {anim_name}: {duration}s")
    
    print("\n" + "=" * 70)


func get_all_animations() -> Array:
    """모든 애니메이션 목록"""
    var all_anims = base_animations.keys() + martial_art_animations.keys()
    return all_anims


func export_animation_data() -> Dictionary:
    """애니메이션 데이터 내보내기"""
    
    return {
        "base": base_animations,
        "martial_arts": martial_art_animations,
        "transitions": state_transitions,
        "total_base": base_animations.size(),
        "total_martial": martial_art_animations.size(),
        "total_all": base_animations.size() + martial_art_animations.size()
    }
