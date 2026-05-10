extends Node
class_name AnimationAssets
## 애니메이션 리소스 관리 및 메타데이터 저장
## 모든 애니메이션의 정보, 특성, 커스터마이제이션 데이터 관리

## 애니메이션 메타데이터
class AnimationMetadata:
	var name: String
	var duration: float
	var fps: float
	var loop: bool
	var speed_modifier: float = 1.0  # 기본 재생 속도 배수
	var blending_in: float = 0.1     # 블렌딩 페이드인 시간
	var blending_out: float = 0.1    # 블렌딩 페이드아웃 시간
	var interrupt_mode: String = "immediate"  # immediate, smooth
	
	# 이펙트 & 사운드
	var attach_effects: Array[String] = []  # 붙일 이펙트 (예: "punch_impact")
	var sound_effects: Array[String] = []   # 재생할 사운드 (예: "punch_sound")
	var sound_timing: Array[float] = []     # 각 사운드의 재생 시점 (0.0 ~ 1.0)
	
	# 시각적 특성
	var motion_blur: bool = false
	var screen_shake: bool = false
	var screen_shake_intensity: float = 0.1
	var glow_effect: bool = false
	var glow_color: Color = Color.WHITE
	
	# 게임플레이 데이터
	var is_vulnerable: bool = false   # 이 애니메이션 중 피해 받을 수 있는가?
	var invincible_frames: float = 0.0  # 무적 시간 (초)
	var can_interrupt: bool = true     # 다른 액션으로 중단 가능?
	var next_actions: Array[String] = []  # 연결 가능한 다음 액션
	
	func _init(p_name: String, p_duration: float, p_fps: float = 30.0, p_loop: bool = false):
		name = p_name
		duration = p_duration
		fps = p_fps
		loop = p_loop

## 캐릭터 유형별 애니메이션 세트
class CharacterAnimationSet:
	var character_type: String  # "human", "wolf", "bat", etc.
	var animations: Dictionary = {}  # name -> AnimationMetadata
	var blend_tree: Dictionary = {}  # state machine
	
	func _init(p_type: String):
		character_type = p_type
	
	func add_animation(meta: AnimationMetadata):
		"""애니메이션 메타데이터 추가"""
		animations[meta.name] = meta
	
	func get_animation(name: String) -> AnimationMetadata:
		"""애니메이션 메타데이터 조회"""
		if animations.has(name):
			return animations[name]
		push_warning("Animation not found: %s" % name)
		return null
	
	func get_all_animations() -> Array[AnimationMetadata]:
		"""모든 애니메이션 목록"""
		var result: Array[AnimationMetadata] = []
		for meta in animations.values():
			result.append(meta)
		return result

## 전역 리소스 관리자
var character_sets: Dictionary = {}  # character_type -> CharacterAnimationSet
var animation_library: Dictionary = {}  # anim_name -> AnimationMetadata (모든 애니메이션)

func _ready():
	"""초기화: 모든 캐릭터 타입의 애니메이션 로드"""
	_load_all_character_animations()

## ===== 초기화 & 로드 =====

func _load_all_character_animations():
	"""모든 캐릭터 타입의 애니메이션 메타데이터 정의"""
	_load_human_animations()
	_load_wolf_animations()
	_load_bat_animations()
	_load_skeleton_animations()
	_load_boss_animations()

func _load_human_animations():
	"""인간형 애니메이션 메타데이터"""
	var set = CharacterAnimationSet.new("human")
	
	# 기본 애니메이션
	set.add_animation(_make_idle_meta())
	set.add_animation(_make_walk_meta())
	set.add_animation(_make_run_meta())
	set.add_animation(_make_jump_meta())
	set.add_animation(_make_fall_meta())
	set.add_animation(_make_land_meta())
	
	# 공격
	set.add_animation(_make_punch_meta())
	set.add_animation(_make_kick_meta())
	set.add_animation(_make_palm_meta())
	set.add_animation(_make_spin_meta())
	
	# 방어
	set.add_animation(_make_block_meta())
	set.add_animation(_make_dodge_meta())
	
	# 피격
	set.add_animation(_make_hit_light_meta())
	set.add_animation(_make_hit_heavy_meta())
	set.add_animation(_make_knockback_meta())
	
	# 상태이상
	set.add_animation(_make_stun_meta())
	set.add_animation(_make_frozen_meta())
	set.add_animation(_make_burn_meta())
	
	# 사망/부활
	set.add_animation(_make_death_meta())
	set.add_animation(_make_revive_meta())
	
	# 이모트
	set.add_animation(_make_celebrate_meta())
	set.add_animation(_make_bow_meta())
	
	character_sets["human"] = set
	_register_all_animations(set)

func _load_wolf_animations():
	"""늑대형 애니메이션 (사족동물)"""
	var set = CharacterAnimationSet.new("wolf")
	
	# 기본 애니메이션 (walk 더 빠름)
	var idle = _make_idle_meta()
	idle.duration = 1.2
	set.add_animation(idle)
	
	var walk = _make_walk_meta()
	walk.duration = 0.6
	walk.speed_modifier = 1.3
	set.add_animation(walk)
	
	var run = _make_run_meta()
	run.duration = 0.4
	run.speed_modifier = 1.5
	set.add_animation(run)
	
	# 사족동물은 점프 없음 (대신 leap)
	var leap = AnimationMetadata.new("LeapAttack", 0.5)
	leap.sound_effects = ["wolf_growl", "leap_impact"]
	leap.sound_timing = [0.0, 0.4]
	leap.screen_shake = true
	leap.next_actions = ["Bite", "Scratch"]
	set.add_animation(leap)
	
	# 물기
	var bite = AnimationMetadata.new("Bite", 0.35)
	bite.sound_effects = ["bite_sound"]
	bite.attach_effects = ["bite_flash"]
	set.add_animation(bite)
	
	# 할퀴기
	var scratch = AnimationMetadata.new("Scratch", 0.4)
	scratch.sound_effects = ["scratch_sound"]
	scratch.attach_effects = ["claw_slash"]
	scratch.next_actions = ["Bite"]
	set.add_animation(scratch)
	
	# 피격
	set.add_animation(_make_hit_light_meta())
	set.add_animation(_make_hit_heavy_meta())
	
	# 사망
	set.add_animation(_make_death_meta())
	
	character_sets["wolf"] = set
	_register_all_animations(set)

func _load_bat_animations():
	"""박쥐형 애니메이션 (비행)"""
	var set = CharacterAnimationSet.new("bat")
	
	# 비행 애니메이션
	var hover = AnimationMetadata.new("Hover", 1.0)
	hover.loop = true
	set.add_animation(hover)
	
	var fly_forward = AnimationMetadata.new("FlyForward", 0.8)
	fly_forward.speed_modifier = 1.2
	set.add_animation(fly_forward)
	
	var fly_spin = AnimationMetadata.new("FlySpin", 0.6)
	fly_spin.sound_effects = ["bat_screech"]
	fly_spin.screen_shake = true
	set.add_animation(fly_spin)
	
	# 공격
	var bite = AnimationMetadata.new("BatBite", 0.3)
	bite.sound_effects = ["bite_sound"]
	set.add_animation(bite)
	
	var dive = AnimationMetadata.new("Dive", 0.5)
	dive.sound_effects = ["whoosh"]
	dive.screen_shake = true
	set.add_animation(dive)
	
	# 피격 & 사망
	set.add_animation(_make_hit_light_meta())
	set.add_animation(_make_death_meta())
	
	character_sets["bat"] = set
	_register_all_animations(set)

func _load_skeleton_animations():
	"""해골형 애니메이션"""
	var set = CharacterAnimationSet.new("skeleton")
	
	# 기본 (느린 움직임)
	var idle = _make_idle_meta()
	idle.duration = 1.5
	set.add_animation(idle)
	
	var walk = _make_walk_meta()
	walk.duration = 1.0
	walk.speed_modifier = 0.8
	set.add_animation(walk)
	
	# 공격
	var bone_swing = AnimationMetadata.new("BoneSwing", 0.5)
	bone_swing.sound_effects = ["bone_clang"]
	set.add_animation(bone_swing)
	
	# 특수: 뼈 흩어짐 (피격 무적)
	var disintegrate = AnimationMetadata.new("Disintegrate", 0.8)
	disintegrate.sound_effects = ["bone_scatter"]
	disintegrate.screen_shake = true
	disintegrate.invincible_frames = 0.8
	set.add_animation(disintegrate)
	
	set.add_animation(_make_death_meta())
	
	character_sets["skeleton"] = set
	_register_all_animations(set)

func _load_boss_animations():
	"""보스형 애니메이션 (특수 기술)"""
	var set = CharacterAnimationSet.new("boss")
	
	# 기본
	set.add_animation(_make_idle_meta())
	set.add_animation(_make_walk_meta())
	
	# 보스만의 특수 기술
	var ultimate = AnimationMetadata.new("UltimateAttack", 2.0)
	ultimate.sound_effects = ["boss_roar", "energy_charge", "ultimate_release"]
	ultimate.sound_timing = [0.0, 0.8, 1.8]
	ultimate.screen_shake = true
	ultimate.screen_shake_intensity = 0.3
	ultimate.glow_effect = true
	ultimate.glow_color = Color.YELLOW
	ultimate.invincible_frames = 0.5
	set.add_animation(ultimate)
	
	# 보스 피격 (특별함)
	var hit = AnimationMetadata.new("BossHit", 0.6)
	hit.motion_blur = true
	hit.screen_shake = true
	set.add_animation(hit)
	
	# 보스 사망 (극적)
	var death = AnimationMetadata.new("BossDeath", 3.0)
	death.glow_effect = true
	death.glow_color = Color.RED
	death.screen_shake = true
	death.sound_effects = ["boss_death_scream", "explosion"]
	death.sound_timing = [0.0, 1.0]
	set.add_animation(death)
	
	character_sets["boss"] = set
	_register_all_animations(set)

## ===== 메타데이터 생성 헬퍼 =====

func _make_idle_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Idle", 1.0, 30.0, true)
	meta.is_vulnerable = false
	meta.can_interrupt = true
	meta.next_actions = ["Walk", "Run", "AttackPunch", "AttackKick", "DefenseBlock"]
	return meta

func _make_walk_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Walk", 0.8, 30.0, true)
	meta.speed_modifier = 1.0
	meta.is_vulnerable = true
	meta.can_interrupt = true
	meta.next_actions = ["Idle", "Run", "AttackPunch", "DefenseBlock"]
	return meta

func _make_run_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Run", 0.5, 30.0, true)
	meta.speed_modifier = 1.5
	meta.is_vulnerable = true
	meta.can_interrupt = true
	meta.next_actions = ["Idle", "Walk", "Jump"]
	return meta

func _make_jump_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Jump", 0.6, 30.0, false)
	meta.is_vulnerable = true
	meta.can_interrupt = false
	meta.next_actions = ["Fall", "AttackKick"]
	return meta

func _make_fall_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Fall", 0.8, 30.0, false)
	meta.is_vulnerable = true
	meta.can_interrupt = false
	meta.next_actions = ["Land"]
	return meta

func _make_land_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Land", 0.4, 30.0, false)
	meta.screen_shake = true
	meta.screen_shake_intensity = 0.05
	meta.sound_effects = ["landing"]
	meta.can_interrupt = true
	meta.next_actions = ["Idle", "Walk", "Run"]
	return meta

func _make_punch_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("AttackPunch", 0.4, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["punch_sound"]
	meta.attach_effects = ["punch_impact"]
	meta.sound_timing = [0.35]
	meta.can_interrupt = true
	meta.invincible_frames = 0.1
	meta.next_actions = ["Idle", "AttackKick", "AttackPalm"]
	return meta

func _make_kick_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("AttackKick", 0.5, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["kick_sound"]
	meta.attach_effects = ["kick_impact"]
	meta.screen_shake = true
	meta.screen_shake_intensity = 0.1
	meta.can_interrupt = true
	meta.next_actions = ["Idle", "AttackPunch"]
	return meta

func _make_palm_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("AttackPalm", 0.45, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["palm_energy"]
	meta.attach_effects = ["palm_wave"]
	meta.glow_effect = true
	meta.glow_color = Color.CYAN
	meta.can_interrupt = true
	meta.next_actions = ["Idle"]
	return meta

func _make_spin_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("AttackSpin", 0.6, 30.0, false)
	meta.is_vulnerable = false  # 회전 중 무적
	meta.invincible_frames = 0.6
	meta.sound_effects = ["spin_sound"]
	meta.motion_blur = true
	meta.can_interrupt = false
	meta.next_actions = ["Idle"]
	return meta

func _make_block_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("DefenseBlock", 0.5, 30.0, true)
	meta.is_vulnerable = false
	meta.can_interrupt = true
	meta.next_actions = ["Idle", "DefenseDodge"]
	return meta

func _make_dodge_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("DefenseDodge", 0.4, 30.0, false)
	meta.is_vulnerable = false
	meta.invincible_frames = 0.4
	meta.can_interrupt = true
	meta.next_actions = ["Idle", "DefenseBlock"]
	return meta

func _make_hit_light_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("HitLight", 0.3, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["hit_light"]
	meta.motion_blur = true
	meta.can_interrupt = true
	meta.next_actions = ["Idle"]
	return meta

func _make_hit_heavy_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("HitHeavy", 0.5, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["hit_heavy"]
	meta.screen_shake = true
	meta.screen_shake_intensity = 0.15
	meta.motion_blur = true
	meta.can_interrupt = true
	meta.next_actions = ["Idle"]
	return meta

func _make_knockback_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Knockback", 0.6, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["knockback"]
	meta.screen_shake = true
	meta.motion_blur = true
	meta.can_interrupt = false
	meta.next_actions = ["Idle"]
	return meta

func _make_stun_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Stun", 1.0, 30.0, true)
	meta.is_vulnerable = true
	meta.can_interrupt = false
	meta.sound_effects = ["stun_loop"]
	return meta

func _make_frozen_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Frozen", 0.5, 30.0, true)
	meta.is_vulnerable = true
	meta.can_interrupt = false
	meta.glow_effect = true
	meta.glow_color = Color.CYAN
	meta.sound_effects = ["frozen_loop"]
	return meta

func _make_burn_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Burn", 0.6, 30.0, true)
	meta.is_vulnerable = true
	meta.can_interrupt = false
	meta.glow_effect = true
	meta.glow_color = Color.ORANGE_RED
	meta.attach_effects = ["burn_loop"]
	return meta

func _make_death_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Death", 1.0, 30.0, false)
	meta.is_vulnerable = true
	meta.sound_effects = ["death_scream"]
	meta.glow_effect = true
	meta.glow_color = Color.DARK_RED
	meta.can_interrupt = false
	return meta

func _make_revive_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Revive", 1.0, 30.0, false)
	meta.invincible_frames = 1.0
	meta.glow_effect = true
	meta.glow_color = Color.GREEN
	meta.sound_effects = ["revive_light"]
	meta.can_interrupt = false
	meta.next_actions = ["Idle"]
	return meta

func _make_celebrate_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Celebrate", 1.0, 30.0, true)
	meta.sound_effects = ["victory"]
	meta.glow_effect = true
	meta.glow_color = Color.GOLD
	return meta

func _make_bow_meta() -> AnimationMetadata:
	var meta = AnimationMetadata.new("Bow", 1.0, 30.0, false)
	meta.sound_effects = ["bow_sound"]
	meta.can_interrupt = true
	meta.next_actions = ["Idle"]
	return meta

## ===== 등록 & 조회 =====

func _register_all_animations(set: CharacterAnimationSet):
	"""모든 애니메이션을 전역 라이브러리에 등록"""
	for meta in set.get_all_animations():
		animation_library[meta.name] = meta

func get_character_set(character_type: String) -> CharacterAnimationSet:
	"""캐릭터 타입별 애니메이션 세트 조회"""
	if character_sets.has(character_type):
		return character_sets[character_type]
	push_warning("Character set not found: %s" % character_type)
	return null

func get_animation_meta(anim_name: String) -> AnimationMetadata:
	"""애니메이션 메타데이터 조회"""
	if animation_library.has(anim_name):
		return animation_library[anim_name]
	return null

func can_interrupt_animation(current_anim: String, next_anim: String) -> bool:
	"""현재 애니메이션을 중단하고 다음 애니메이션으로 전환 가능한지 확인"""
	var meta = get_animation_meta(current_anim)
	if meta == null:
		return true
	return meta.can_interrupt

func get_next_actions(anim_name: String) -> Array[String]:
	"""애니메이션 다음에 가능한 액션 목록"""
	var meta = get_animation_meta(anim_name)
	if meta == null:
		return []
	return meta.next_actions

## ===== 유틸리티 =====

func debug_list_character_animations(character_type: String):
	"""캐릭터 애니메이션 목록 출력"""
	var set = get_character_set(character_type)
	if set == null:
		return
	
	print("=== %s Animations ===" % character_type)
	for meta in set.get_all_animations():
		print("  - %s (%.2fs, loop: %s)" % [meta.name, meta.duration, meta.loop])

func debug_list_all_animations():
	"""모든 애니메이션 목록 출력"""
	print("=== All Registered Animations ===")
	print("Total: %d animations" % animation_library.size())
	for name in animation_library.keys():
		print("  - %s" % name)
