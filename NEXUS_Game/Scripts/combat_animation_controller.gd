extends Node3D
class_name CombatAnimationController
## 전투 애니메이션 재생 및 관리
## 무술 동작과 상태에 따라 적절한 애니메이션 전환

@onready var animated_sprite: Node3D = get_node_or_null("Model")  # 3D 모델
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

var anim_generator: AnimationGenerator
var current_anim: String = "Idle"
var is_playing: bool = false
var current_speed_multiplier: float = 1.0

# 애니메이션 캐시
var anim_cache: Dictionary = {}

# 상태
var is_attacking: bool = false
var is_defending: bool = false
var is_hit: bool = false
var current_state: String = "idle"  # idle, moving, attacking, defending, hit, stun, dead

func _ready():
	anim_generator = AnimationGenerator.new()
	_load_all_animations()

func _load_all_animations():
	"""모든 애니메이션을 생성하여 캐시에 저장"""
	if animation_player == null:
		push_warning("AnimationPlayer not found")
		return
	
	var character_type = "human"  # 나중에 동적으로 설정
	var anims = AnimationGenerator.generate_animations(character_type)
	
	for anim_name in anims.keys():
		var clip = anims[anim_name]
		anim_cache[anim_name] = clip
		# 실제 Godot 애니메이션 라이브러리에 추가 (구현 필요)

## ===== 상태 전환 함수 =====

func set_idle():
	"""대기 상태로 전환"""
	if current_state != "idle":
		_play_anim("idle", 1.0, true)
		current_state = "idle"

func set_moving(direction: Vector3, is_running: bool = false):
	"""이동 상태로 전환"""
	current_state = "moving"
	
	var anim_name = "walk_f"
	if direction == Vector3.FORWARD:
		anim_name = "walk_f"
	elif direction == Vector3.BACK:
		anim_name = "walk_b"
	elif direction == Vector3.LEFT:
		anim_name = "walk_l"
	elif direction == Vector3.RIGHT:
		anim_name = "walk_r"
	
	if is_running:
		anim_name = anim_name.replace("walk", "run")
	
	_play_anim(anim_name, 1.5 if is_running else 1.0, true)

func set_jumping():
	"""점프 상태로 전환"""
	current_state = "jumping"
	_play_anim("jump", 1.0)

func set_falling():
	"""낙하 상태로 전환"""
	current_state = "falling"
	_play_anim("fall", 1.0)

func set_landing():
	"""착지 상태로 전환"""
	_play_anim("land", 1.0)
	current_state = "idle"

## ===== 공격 애니메이션 =====

func play_martial_art_attack(martial_art: MartialArt):
	"""무술에 따른 공격 애니메이션 재생"""
	is_attacking = true
	current_state = "attacking"
	
	# 무술의 motion_type에 따라 애니메이션 선택
	var anim_name = _get_attack_anim_name(martial_art.motion_type)
	var duration = martial_art.duration  # 무술의 지속시간
	var speed = duration / 0.4  # 기본 공격 애니메이션은 0.4초 (normalize)
	
	_play_anim(anim_name, speed)
	
	# 애니메이션 완료 후 idle로 복귀
	await get_tree().create_timer(martial_art.duration).timeout
	is_attacking = false
	set_idle()

func play_combo_attack(martial_arts: Array[MartialArt]):
	"""연번 공격 (다른 무술들을 순차적으로 재생)"""
	is_attacking = true
	current_state = "attacking"
	
	for martial_art in martial_arts:
		var anim_name = _get_attack_anim_name(martial_art.motion_type)
		_play_anim(anim_name, 1.0)
		await get_tree().create_timer(martial_art.duration).timeout
	
	is_attacking = false
	set_idle()

func play_ultimate_attack(martial_art: MartialArt):
	"""최종 기술 (특수 효과 포함)"""
	is_attacking = true
	current_state = "attacking"
	
	var anim_name = _get_attack_anim_name(martial_art.motion_type)
	
	# 궁극 기술은 약간 느린 모션으로
	_play_anim(anim_name, 0.7)
	
	# 특수 효과 시작
	_emit_attack_effect(martial_art)
	
	await get_tree().create_timer(martial_art.duration).timeout
	is_attacking = false
	set_idle()

## ===== 방어 애니메이션 =====

func play_defense_block():
	"""방어 자세 (루프)"""
	is_defending = true
	current_state = "defending"
	_play_anim("defense_block", 1.0, true)

func play_defense_dodge():
	"""회피 (한 번만)"""
	is_defending = true
	current_state = "defending"
	_play_anim("defense_dodge", 1.0)
	
	await get_tree().create_timer(0.4).timeout
	is_defending = false
	set_idle()

func stop_defense():
	"""방어 중단"""
	is_defending = false
	set_idle()

## ===== 피격 애니메이션 =====

func play_hit_reaction(damage_amount: float):
	"""피격 반응 (피해량에 따라 다름)"""
	is_hit = true
	current_state = "hit"
	
	if damage_amount < 10:
		_play_anim("hit_light", 1.0)
		await get_tree().create_timer(0.3).timeout
	elif damage_amount < 30:
		_play_anim("hit_heavy", 1.0)
		await get_tree().create_timer(0.5).timeout
	else:
		_play_anim("knockback", 1.0)
		await get_tree().create_timer(0.6).timeout
	
	is_hit = false
	set_idle()

func play_knockback():
	"""넉백 당함"""
	is_hit = true
	current_state = "hit"
	_play_anim("knockback", 1.0)
	
	await get_tree().create_timer(0.6).timeout
	is_hit = false
	set_idle()

func play_launch():
	"""날아감"""
	is_hit = true
	current_state = "hit"
	_play_anim("fall", 1.0)
	# 중력으로 낙하, 착지 애니메이션 자동 재생

## ===== 상태이상 애니메이션 =====

func play_stun(duration: float = 2.0):
	"""스턴 상태 (움직일 수 없음)"""
	current_state = "stun"
	_play_anim("stun", 1.0, true)
	
	await get_tree().create_timer(duration).timeout
	set_idle()

func play_frozen(duration: float = 3.0):
	"""냉동 상태 (살짝 떨림)"""
	current_state = "frozen"
	_play_anim("frozen", 1.0, true)
	
	await get_tree().create_timer(duration).timeout
	set_idle()

func play_burn(duration: float = 2.0):
	"""화염 상태 (기본 불타는 포즈 + 파티클)"""
	current_state = "burn"
	_play_anim("idle", 1.0, true)  # idle 상태 유지 + 화염 파티클
	_emit_burn_effect()
	
	await get_tree().create_timer(duration).timeout
	set_idle()

## ===== 사망/부활 =====

func play_death():
	"""사망 애니메이션 (루프 없음)"""
	current_state = "dead"
	_play_anim("death", 1.0, false)

func play_revive():
	"""부활 애니메이션"""
	current_state = "idle"
	_play_anim("revive", 1.0)
	
	await get_tree().create_timer(1.0).timeout
	set_idle()

## ===== 승리/패배 =====

func play_celebrate():
	"""승리 애니메이션"""
	current_state = "celebrate"
	_play_anim("celebrate", 1.0, true)

func play_defeat():
	"""패배 애니메이션 (death와 동일)"""
	play_death()

## ===== 기타 애니메이션 =====

func play_emote(emote_type: String):
	"""이모트 애니메이션 (보우, 웃음, 수긍 등)"""
	match emote_type:
		"bow":
			_play_anim("emote_bow", 1.0)
		"laugh":
			_play_anim("emote_laugh", 1.0, true)
		"celebrate":
			play_celebrate()
		_:
			push_warning("Unknown emote: " + emote_type)

func play_npc_interaction_anim(interaction_type: String):
	"""NPC와의 상호작용 애니메이션"""
	match interaction_type:
		"bow":
			_play_anim("emote_bow", 1.0)
		"receive_martial_art":
			_play_anim("emote_celebrate", 1.0)
		"receive_item":
			_play_anim("emote_bow", 1.0)

## ===== 유틸리티 함수 =====

func _get_attack_anim_name(motion_type: String) -> String:
	"""무술의 motion_type을 애니메이션 이름으로 변환"""
	match motion_type:
		"punch":
			return "attack_punch"
		"kick":
			return "attack_kick"
		"palm":
			return "attack_palm"
		"spin":
			return "attack_spin"
		"thrust":
			return "attack_punch"  # 찌르기는 펀치 애니메이션 사용
		"sweep":
			return "attack_kick"   # 휘두르기는 킥 애니메이션 사용
		_:
			return "attack_punch"  # 기본값

func _play_anim(anim_name: String, speed: float = 1.0, loop: bool = false):
	"""애니메이션 재생 (저수준)"""
	if animation_player == null:
		return
	
	current_anim = anim_name
	current_speed_multiplier = speed
	is_playing = true
	
	# 실제 재생은 Godot AnimationPlayer 사용 (스켈레톤 + 스키닝)
	# 여기서는 프로토타입 구현만
	print("Playing animation: %s (speed: %.2f)" % [anim_name, speed])

func _emit_attack_effect(martial_art: MartialArt):
	"""공격 이펙트 방출 (파티클, 사운드)"""
	# 공격 타입에 따라 이펙트 생성
	match martial_art.motion_type:
		"punch":
			_emit_particle_effect("punch_impact", Vector3.FORWARD)
			_play_sound_effect("punch")
		"kick":
			_emit_particle_effect("kick_impact", Vector3.FORWARD)
			_play_sound_effect("kick")
		"palm":
			_emit_particle_effect("palm_wave", Vector3.FORWARD)
			_play_sound_effect("palm_energy")
		"spin":
			_emit_particle_effect("spin_slash", Vector3.UP)
			_play_sound_effect("spin")

func _emit_burn_effect():
	"""화염 이펙트"""
	_emit_particle_effect("burn_loop", Vector3.UP)
	_play_sound_effect("burn")

func _emit_particle_effect(effect_name: String, direction: Vector3):
	"""파티클 이펙트 생성 (구현 필요)"""
	# 실제 구현: GPUParticles3D 노드 생성 및 재생
	print("Emitting particle effect: %s" % effect_name)

func _play_sound_effect(sound_name: String):
	"""사운드 이펙트 재생 (구현 필요)"""
	# 실제 구현: AudioStreamPlayer 노드로 재생
	print("Playing sound effect: %s" % sound_name)

## ===== 디버그 =====

func get_current_animation() -> String:
	"""현재 재생 중인 애니메이션 이름"""
	return current_anim

func get_current_state() -> String:
	"""현재 상태 반환"""
	return current_state

func get_all_animations() -> Dictionary:
	"""캐시된 모든 애니메이션 반환"""
	return anim_cache.duplicate()

func debug_list_animations():
	"""등록된 모든 애니메이션 출력"""
	print("=== Registered Animations ===")
	for anim_name in anim_cache.keys():
		print("  - %s" % anim_name)
	print("Total: %d animations" % anim_cache.size())
