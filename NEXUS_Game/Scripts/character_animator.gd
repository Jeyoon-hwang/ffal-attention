extends Node
class_name CharacterAnimator
## 캐릭터 애니메이션 통합 관리자
## AnimationAssets + CombatAnimationController의 조율

@onready var combat_controller: CombatAnimationController = get_parent()
var animation_assets: AnimationAssets
var character_type: String = "human"
var current_animation_meta: AnimationAssets.AnimationMetadata

# 애니메이션 큐 (중단 없이 자동 재생)
var animation_queue: Array[String] = []
var is_queue_playing: bool = false

# 상태 머신
var state_machine: StateMachine
var current_state: String = "idle"

func _ready():
	animation_assets = AnimationAssets.new()
	_setup_state_machine()

## ===== 상태 머신 설정 =====

func _setup_state_machine():
	"""게임 상태 머신 구축"""
	state_machine = StateMachine.new()
	
	# 상태 정의
	state_machine.add_state("idle", _state_idle_enter, _state_idle_update, _state_idle_exit)
	state_machine.add_state("moving", _state_moving_enter, _state_moving_update, _state_moving_exit)
	state_machine.add_state("attacking", _state_attacking_enter, _state_attacking_update, _state_attacking_exit)
	state_machine.add_state("defending", _state_defending_enter, _state_defending_update, _state_defending_exit)
	state_machine.add_state("hit", _state_hit_enter, _state_hit_update, _state_hit_exit)
	state_machine.add_state("stun", _state_stun_enter, _state_stun_update, _state_stun_exit)
	state_machine.add_state("dead", _state_dead_enter, _state_dead_update, _state_dead_exit)
	
	state_machine.set_initial_state("idle")

## ===== 상태별 함수 =====

func _state_idle_enter():
	"""Idle 상태 진입"""
	combat_controller.set_idle()

func _state_idle_update(delta: float):
	"""Idle 상태 업데이트"""
	pass

func _state_idle_exit():
	"""Idle 상태 탈출"""
	pass

func _state_moving_enter():
	"""Moving 상태 진입"""
	pass

func _state_moving_update(delta: float):
	"""Moving 상태 업데이트"""
	pass

func _state_moving_exit():
	"""Moving 상태 탈출"""
	pass

func _state_attacking_enter():
	"""Attacking 상태 진입"""
	pass

func _state_attacking_update(delta: float):
	"""Attacking 상태 업데이트"""
	pass

func _state_attacking_exit():
	"""Attacking 상태 탈출"""
	pass

func _state_defending_enter():
	"""Defending 상태 진입"""
	pass

func _state_defending_update(delta: float):
	"""Defending 상태 업데이트"""
	pass

func _state_defending_exit():
	"""Defending 상태 탈출"""
	pass

func _state_hit_enter():
	"""Hit 상태 진입"""
	pass

func _state_hit_update(delta: float):
	"""Hit 상태 업데이트"""
	pass

func _state_hit_exit():
	"""Hit 상태 탈출"""
	pass

func _state_stun_enter():
	"""Stun 상태 진입"""
	pass

func _state_stun_update(delta: float):
	"""Stun 상태 업데이트"""
	pass

func _state_stun_exit():
	"""Stun 상태 탈출"""
	pass

func _state_dead_enter():
	"""Dead 상태 진입"""
	pass

func _state_dead_update(delta: float):
	"""Dead 상태 업데이트"""
	pass

func _state_dead_exit():
	"""Dead 상태 탈출"""
	pass

## ===== 애니메이션 제어 =====

func play_animation(anim_name: String):
	"""애니메이션 재생 (메타데이터 포함)"""
	var meta = animation_assets.get_animation_meta(anim_name)
	if meta == null:
		push_warning("Animation not found: %s" % anim_name)
		return
	
	current_animation_meta = meta
	
	# 사운드 효과 재생
	_play_animation_sounds(meta)
	
	# 이펙트 재생
	_play_animation_effects(meta)
	
	# 애니메이션 컨트롤러에 재생 요청
	combat_controller._play_anim(anim_name, meta.speed_modifier, meta.loop)
	
	# 애니메이션이 완료될 때까지 기다리거나 다음 큐 실행
	if not meta.loop:
		await get_tree().create_timer(meta.duration).timeout
		if animation_queue.size() > 0:
			_process_animation_queue()

func queue_animation(anim_name: String):
	"""애니메이션을 큐에 추가"""
	animation_queue.append(anim_name)
	if not is_queue_playing:
		_process_animation_queue()

func queue_animations(anim_names: Array[String]):
	"""여러 애니메이션을 큐에 추가"""
	for anim_name in anim_names:
		animation_queue.append(anim_name)
	if not is_queue_playing:
		_process_animation_queue()

func clear_queue():
	"""애니메이션 큐 비우기"""
	animation_queue.clear()
	is_queue_playing = false

func _process_animation_queue():
	"""큐에 있는 애니메이션들을 순차적으로 재생"""
	if animation_queue.size() == 0:
		is_queue_playing = false
		return
	
	is_queue_playing = true
	var anim_name = animation_queue.pop_front()
	await play_animation(anim_name)

## ===== 특수 애니메이션 시퀀스 =====

func play_martial_art_combo(martial_arts: Array[MartialArt]):
	"""무술 콤보 재생 (여러 무술을 순차적으로)"""
	var anim_sequence: Array[String] = []
	
	for martial_art in martial_arts:
		var anim_name = _get_motion_anim_name(martial_art.motion_type)
		anim_sequence.append(anim_name)
	
	queue_animations(anim_sequence)

func play_special_skill(skill_name: String):
	"""특수 스킬 애니메이션 (보스 기술 등)"""
	match skill_name:
		"ultimate":
			queue_animation("UltimateAttack")
		"super_kick":
			queue_animations(["AttackKick", "Spin", "AttackKick"])
		"palm_combo":
			queue_animations(["AttackPalm", "AttackPalm", "AttackPalm"])
		_:
			push_warning("Unknown skill: %s" % skill_name)

func play_victory_sequence():
	"""승리 시퀀스"""
	queue_animations(["Celebrate", "Bow"])

func play_defeat_sequence():
	"""패배 시퀀스"""
	queue_animation("Death")

## ===== 효과 재생 =====

func _play_animation_sounds(meta: AnimationAssets.AnimationMetadata):
	"""애니메이션 메타데이터의 사운드 효과 재생"""
	for i in range(meta.sound_effects.size()):
		var sound_name = meta.sound_effects[i]
		var timing = meta.sound_timing[i] if i < meta.sound_timing.size() else 0.0
		var delay = meta.duration * timing
		
		await get_tree().create_timer(delay).timeout
		# 실제 사운드 재생은 게임 오디오 매니저가 처리

func _play_animation_effects(meta: AnimationAssets.AnimationMetadata):
	"""애니메이션 메타데이터의 시각 효과 재생"""
	# 화면 흔들림
	if meta.screen_shake:
		_trigger_screen_shake(meta.screen_shake_intensity)
	
	# 글로우 효과
	if meta.glow_effect:
		_trigger_glow_effect(meta.glow_color)
	
	# 모션 블러
	if meta.motion_blur:
		_trigger_motion_blur()
	
	# 파티클 이펙트
	for effect_name in meta.attach_effects:
		_trigger_particle_effect(effect_name)

func _trigger_screen_shake(intensity: float):
	"""화면 흔들림 효과"""
	# CameraManager에 신호 보내기
	print("Screen shake: %.2f" % intensity)

func _trigger_glow_effect(color: Color):
	"""글로우 이펙트"""
	print("Glow effect: %s" % color)

func _trigger_motion_blur():
	"""모션 블러 효과"""
	print("Motion blur applied")

func _trigger_particle_effect(effect_name: String):
	"""파티클 이펙트 생성"""
	print("Particle effect: %s" % effect_name)

## ===== 유틸리티 =====

func _get_motion_anim_name(motion_type: String) -> String:
	"""motion_type을 애니메이션 이름으로 변환"""
	match motion_type:
		"punch":
			return "AttackPunch"
		"kick":
			return "AttackKick"
		"palm":
			return "AttackPalm"
		"spin":
			return "AttackSpin"
		"thrust":
			return "AttackPunch"
		"sweep":
			return "AttackKick"
		_:
			return "AttackPunch"

func set_character_type(new_type: String):
	"""캐릭터 타입 변경"""
	character_type = new_type
	var set = animation_assets.get_character_set(character_type)
	if set == null:
		push_warning("Character type not supported: %s" % new_type)

func get_current_animation_name() -> String:
	"""현재 재생 중인 애니메이션 이름"""
	return combat_controller.get_current_animation()

func get_current_animation_duration() -> float:
	"""현재 애니메이션의 지속시간"""
	if current_animation_meta == null:
		return 0.0
	return current_animation_meta.duration

func is_animation_vulnerable() -> bool:
	"""현재 애니메이션이 피해를 받을 수 있는 상태인가"""
	if current_animation_meta == null:
		return true
	return current_animation_meta.is_vulnerable

func get_invincible_frames() -> float:
	"""현재 애니메이션의 무적 시간"""
	if current_animation_meta == null:
		return 0.0
	return current_animation_meta.invincible_frames

func debug_play_animation(anim_name: String):
	"""디버그용: 애니메이션 직접 재생"""
	play_animation(anim_name)

func debug_list_animations():
	"""디버그용: 모든 애니메이션 목록 출력"""
	animation_assets.debug_list_character_animations(character_type)

## ===== 상태 머신 헬퍼 클래스 =====

class StateMachine:
	var states: Dictionary = {}
	var current_state: String = ""
	
	func add_state(name: String, enter_func: Callable, update_func: Callable, exit_func: Callable):
		"""상태 추가"""
		states[name] = {
			"enter": enter_func,
			"update": update_func,
			"exit": exit_func
		}
	
	func set_initial_state(state_name: String):
		"""초기 상태 설정"""
		current_state = state_name
		if states.has(state_name):
			states[state_name]["enter"].call()
	
	func change_state(new_state: String):
		"""상태 전환"""
		if new_state == current_state:
			return
		
		if states.has(current_state):
			states[current_state]["exit"].call()
		
		current_state = new_state
		if states.has(new_state):
			states[new_state]["enter"].call()
	
	func update(delta: float):
		"""상태 업데이트"""
		if states.has(current_state):
			states[current_state]["update"].call(delta)
	
	func get_state() -> String:
		"""현재 상태 반환"""
		return current_state
