extends Node
class_name AnimationController

## 애니메이션 상태 머신 및 컨트롤러
## - 캐릭터 상태에 따른 애니메이션 자동 전환
## - 무술 실행 중 애니메이션 동기화
## - 이펙트 타이밍 동기화

@export var character: Character3D
@export var particle_manager: ParticleManager3D

## 애니메이션 상태 정의
enum State {
	IDLE,
	MOVING,
	ATTACKING,
	CASTING,
	HIT,
	DYING,
	VICTORY
}

## 현재 상태
var current_state = State.IDLE
var previous_state = State.IDLE

## 전투 정보
var current_martial_art: Dictionary = {}
var is_attacking: bool = false
var attack_animation_progress: float = 0.0
var attack_duration: float = 0.0

## 움직임 정보
var is_moving: bool = false
var current_velocity: Vector3 = Vector3.ZERO
var move_speed: float = 5.0

# 생명 주기
func _ready():
	if not character:
		push_error("AnimationController: character not assigned!")
		return
	
	if not particle_manager:
		particle_manager = character.particle_manager

func _process(delta):
	_update_state()
	_update_animations(delta)
	_sync_particle_effects(delta)

## 상태 업데이트
func _update_state():
	var new_state = current_state
	
	# 상태 전환 로직
	if is_attacking:
		new_state = State.ATTACKING
	elif is_moving and current_velocity.length() > 0.1:
		new_state = State.MOVING
	else:
		new_state = State.IDLE
	
	# 상태 변경됨
	if new_state != current_state:
		previous_state = current_state
		current_state = new_state
		_on_state_changed()

## 상태 변경 콜백
func _on_state_changed():
	match current_state:
		State.IDLE:
			character.play_animation(Character3D.AnimationState.IDLE)
		State.MOVING:
			character.play_animation(Character3D.AnimationState.WALK)
		State.ATTACKING:
			character.play_animation(Character3D.AnimationState.ATTACK)
		State.CASTING:
			character.play_animation(Character3D.AnimationState.CAST)
		State.HIT:
			character.play_animation(Character3D.AnimationState.HIT)

## 애니메이션 업데이트
func _update_animations(delta):
	match current_state:
		State.ATTACKING:
			_update_attack_animation(delta)
		State.MOVING:
			_update_movement_animation(delta)

## 공격 애니메이션 업데이트
func _update_attack_animation(delta):
	if attack_duration <= 0:
		return
	
	attack_animation_progress += delta
	var progress_ratio = attack_animation_progress / attack_duration
	
	# 공격 애니메이션 진행률 (0.0 ~ 1.0)
	if progress_ratio >= 1.0:
		is_attacking = false
		attack_animation_progress = 0.0
		return
	
	# 공격 중간 (0.3 ~ 0.7)에 이펙트 재생
	if progress_ratio > 0.3 and progress_ratio < 0.7:
		# 이펙트는 처음 한 번만 재생
		if attack_animation_progress - delta <= 0.3:
			_trigger_martial_art_effect()

## 움직임 애니메이션 업데이트
func _update_movement_animation(delta):
	# 이동 속도에 따른 애니메이션 속도 조정
	var speed = current_velocity.length()
	if speed > move_speed * 0.8:  # 달리기
		character.play_animation(Character3D.AnimationState.RUN)
	else:  # 걷기
		character.play_animation(Character3D.AnimationState.WALK)

## 이펙트 동기화
func _sync_particle_effects(delta):
	# 파티클 매니저가 character와 함께 움직임
	if particle_manager:
		particle_manager.global_position = character.global_position

## 무술 공격 실행
func execute_martial_art(martial_art: Dictionary):
	"""
	무술을 실행하고 애니메이션/이펙트 동기화
	
	martial_art 구조:
	{
		"name": "Slash Quick",
		"base": "slash",
		"modifiers": ["quick"],
		"damage": 15,
		"cooldown": 1.5,
		"animation_duration": 0.5
	}
	"""
	current_martial_art = martial_art
	is_attacking = true
	attack_duration = martial_art.get("animation_duration", 0.5)
	attack_animation_progress = 0.0
	
	# 플레이어의 animation_player도 동기화
	if character.animation_player:
		character.animation_player.speed_scale = 1.0 / attack_duration  # 속도 조정

## 무술 이펙트 트리거
func _trigger_martial_art_effect():
	if current_martial_art.is_empty():
		return
	
	var martial_art_name = current_martial_art.get("base", "slash")
	var modifiers = current_martial_art.get("modifiers", [])
	
	# 기본 Base 이펙트
	particle_manager.play_martial_art_effect(martial_art_name, character.global_position + Vector3(0, 1, 0))
	
	# Modifier 이펙트들
	for modifier in modifiers:
		particle_manager.play_martial_art_effect(modifier, character.global_position + Vector3(0, 1, 0))

## 히트 이펙트
func play_hit_animation(damage: int, is_critical: bool = false):
	is_attacking = false
	current_state = State.HIT
	_on_state_changed()
	
	if is_critical:
		particle_manager.play_critical_effect(character.global_position + Vector3(0, 1, 0))
	
	particle_manager.create_damage_text(damage, character.global_position + Vector3(0, 2, 0), is_critical)
	
	# HIT 애니메이션 완료 후 IDLE로
	await get_tree().create_timer(0.3).timeout
	if current_state == State.HIT:
		current_state = State.IDLE
		_on_state_changed()

## 콤보 애니메이션
func play_combo_animation(combo_count: int):
	particle_manager.play_combo_effect(combo_count, character.global_position + Vector3(0, 2, 0))

## 상태 이상 애니메이션
func play_status_effect_animation(status_type: String):
	particle_manager.play_status_effect(status_type, character.global_position + Vector3(0, 1, 0))

## 회복 애니메이션
func play_heal_animation(heal_amount: int):
	particle_manager.play_heal_effect(heal_amount, character.global_position + Vector3(0, 1, 0))

## 움직임 제어
func set_movement(direction: Vector3):
	"""
	-1.0 ~ 1.0 범위의 방향 벡터
	"""
	current_velocity = direction.normalized() * move_speed
	is_moving = current_velocity.length() > 0.1

func stop_movement():
	current_velocity = Vector3.ZERO
	is_moving = false

## 애니메이션 속도 조정
func set_animation_speed(speed_multiplier: float):
	if character.animation_player:
		character.animation_player.speed_scale = speed_multiplier

## 상태 조회
func get_current_state() -> String:
	return State.keys()[current_state]

func is_action_available() -> bool:
	"""
	공격, 스킬 등을 사용할 수 있는가?
	"""
	return current_state == State.IDLE or current_state == State.MOVING

## 죽음 애니메이션
func play_death_animation():
	current_state = State.DYING
	# 죽음 애니메이션 추가 (스케일 축소 등)
	var tween = create_tween()
	tween.tween_property(character, "scale", Vector3(0.5, 0.5, 0.5), 1.0)
	await tween.finished

## 승리 애니메이션
func play_victory_animation():
	current_state = State.VICTORY
	character.play_animation(Character3D.AnimationState.IDLE)
	# 점프/춤 모션 추가 가능
	var tween = create_tween()
	tween.tween_property(character, "position", character.position + Vector3(0, 0.5, 0), 0.5)
	tween.tween_property(character, "position", character.position, 0.5)
	await tween.finished

## 공개 통계
func get_debug_info() -> Dictionary:
	return {
		"state": State.keys()[current_state],
		"is_attacking": is_attacking,
		"is_moving": is_moving,
		"current_velocity": current_velocity,
		"attack_progress": attack_animation_progress / max(attack_duration, 0.1),
		"current_martial_art": current_martial_art.get("name", "None")
	}
