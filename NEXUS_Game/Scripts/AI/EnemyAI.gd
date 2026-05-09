extends CharacterBody3D
class_name EnemyAI
"""
적 AI 시스템 (Enemy AI)
4단계 난이도:
- Level 1: 동물형 (몬스터)
- Level 2: 기초 무술사
- Level 3: 고급 무술사 (보스)
- Level 4: 마스터 (최종 보스)

현재: Level 1-2 구현
"""

# AI 레벨 & 난이도
enum AILevel {ANIMAL = 1, NOVICE = 2, ADVANCED = 3, MASTER = 4}
@export var ai_level: AILevel = AILevel.ANIMAL
@export var difficulty: float = 1.0  # 1.0 = 기본, 2.0 = 2배 강함

# 전투 시스템
var combat_system: CombatSystem
var martial_art_engine: MartialArtEngine

# 상태 머신
enum AIState {IDLE, CHASE, ATTACK, DEFEND, FLEE, STUNNED}
var current_state: AIState = AIState.IDLE

# 목표 (플레이어)
var target: Node3D = null
var target_distance: float = 0.0

# 통계
var max_hp: float = 50.0
var current_hp: float
var max_energy: float = 60.0
var current_energy: float

var speed: float = 3.0
var attack_range: float = 2.0
var detection_range: float = 10.0
var chase_time: float = 0.0

# AI 패턴 (Level별)
var attack_pattern: Array[int] = []  # 무술 슬롯 순서
var pattern_index: int = 0
var pattern_timeout: float = 0.0

# 회피 확률 (무술사 레벨에서 증가)
var evade_chance: float = 0.1  # 10% (레벨 1)

# 마지막 공격 시간 (재공격 쿨다운)
var last_attack_time: float = 0.0
var attack_cooldown: float = 1.5

# 신호
signal died(ai: EnemyAI)

func _ready():
	current_hp = max_hp * difficulty
	current_energy = max_energy * difficulty
	
	# 전투 시스템 초기화
	combat_system = CombatSystem.new()
	combat_system._ready()
	combat_system.max_hp = current_hp
	combat_system.max_energy = current_energy
	
	martial_art_engine = MartialArtEngine.new()
	martial_art_engine._ready()
	
	# AI 레벨별 설정
	_setup_by_level()
	
	print(f"[Enemy AI Level {ai_level}] HP:{int(current_hp)} Difficulty:{difficulty}")

func _setup_by_level() -> void:
	"""AI 레벨별 설정"""
	
	match ai_level:
		AILevel.ANIMAL:
			# Level 1: 동물형 (몬스터)
			# - 기본 공격 2-3가지
			# - 추격 후 공격
			# - 회피 없음
			attack_pattern = [0, 1, 0]  # 무술 슬롯 순서
			evade_chance = 0.0
			speed = 3.0
			attack_range = 2.0
			detection_range = 8.0
			max_hp = 30.0
		
		AILevel.NOVICE:
			# Level 2: 기초 무술사
			# - 무술 3-4가지
			# - 패턴 감지 (같은 공격 반복 시 피함)
			# - 회피 & 방어 사용 (10%)
			attack_pattern = [0, 1, 2, 3, 1]
			evade_chance = 0.15
			speed = 4.0
			attack_range = 2.5
			detection_range = 10.0
			max_hp = 50.0
		
		AILevel.ADVANCED:
			# Level 3: 고급 무술사 (보스)
			# - 무술 5-8가지
			# - 약점 감지 & 적응
			# - 회피 & 방어 (20%)
			attack_pattern = [0, 1, 2, 3, 4, 2, 1, 0]
			evade_chance = 0.20
			speed = 5.0
			attack_range = 3.0
			detection_range = 12.0
			max_hp = 100.0
		
		AILevel.MASTER:
			# Level 4: 마스터 (최종 보스)
			# - 모든 무술 사용
			# - 완벽한 적응
			# - 회피 & 방어 (30%)
			attack_pattern = [0, 1, 2, 3, 4, 3, 2, 1, 0, 4]
			evade_chance = 0.30
			speed = 6.0
			attack_range = 3.5
			detection_range = 15.0
			max_hp = 200.0

func _process(delta: float):
	if current_hp <= 0:
		return
	
	# 에너지 회복
	current_energy = min(max_energy, current_energy + (max_energy / 5.0) * delta)
	
	# 상태별 행동
	match current_state:
		AIState.IDLE:
			_ai_idle(delta)
		AIState.CHASE:
			_ai_chase(delta)
		AIState.ATTACK:
			_ai_attack(delta)
		AIState.DEFEND:
			_ai_defend(delta)
		AIState.FLEE:
			_ai_flee(delta)

## AI 상태: 대기
func _ai_idle(delta: float) -> void:
	"""대기 상태 - 플레이어 탐지"""
	
	if target == null:
		return
	
	target_distance = global_position.distance_to(target.global_position)
	
	# 탐지 범위 내 플레이어 감지
	if target_distance < detection_range:
		change_state(AIState.CHASE)
		print(f"🔍 [Enemy] 플레이어 탐지! 거리: {target_distance:.1f}m")

## AI 상태: 추격
func _ai_chase(delta: float) -> void:
	"""추격 상태 - 플레이어 접근"""
	
	if target == null:
		change_state(AIState.IDLE)
		return
	
	target_distance = global_position.distance_to(target.global_position)
	
	# 공격 범위 진입
	if target_distance < attack_range:
		change_state(AIState.ATTACK)
		return
	
	# 플레이어 방향으로 이동
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# 추격 시간 증가 (너무 오래 추격하면 포기)
	chase_time += delta
	if chase_time > 10.0:
		change_state(AIState.IDLE)
		chase_time = 0.0

## AI 상태: 공격
func _ai_attack(delta: float) -> void:
	"""공격 상태 - 무술 사용"""
	
	if target == null:
		change_state(AIState.IDLE)
		return
	
	target_distance = global_position.distance_to(target.global_position)
	
	# 범위를 벗어나면 추격으로
	if target_distance > attack_range * 1.5:
		change_state(AIState.CHASE)
		return
	
	# 회피 확률 (무술사 레벨)
	if randf() < evade_chance:
		change_state(AIState.DEFEND)
		return
	
	# 공격 쿨다운 확인
	if Time.get_ticks_msec() / 1000.0 - last_attack_time < attack_cooldown:
		return
	
	# 패턴 기반 공격
	var martial_slot = attack_pattern[pattern_index % attack_pattern.size()]
	pattern_index += 1
	
	# 무술 실행
	if combat_system.attack(martial_slot):
		last_attack_time = Time.get_ticks_msec() / 1000.0
		
		# 히트박스 판정 (간단히 대상에게 직접 데미지)
		if target.has_method("take_damage"):
			var martial = martial_art_engine.get_player_martial(martial_slot)
			if martial != null:
				var damage = martial.base_damage * difficulty
				target.take_damage(damage, self)

## AI 상태: 방어
func _ai_defend(delta: float) -> void:
	"""방어 상태 - 회피 또는 가드"""
	
	# 1초 방어 후 다시 공격
	if Time.get_ticks_msec() / 1000.0 - last_attack_time > 1.0:
		change_state(AIState.ATTACK)

## AI 상태: 도주
func _ai_flee(delta: float) -> void:
	"""도주 상태 - HP 낮을 때"""
	
	if target == null:
		change_state(AIState.IDLE)
		return
	
	# 플레이어 반대 방향으로 이동
	var direction = (global_position - target.global_position).normalized()
	velocity = direction * speed * 1.5  # 도주는 더 빠름
	move_and_slide()
	
	# HP가 회복되면 다시 공격
	if current_hp > max_hp * 0.5:
		change_state(AIState.CHASE)

## 데미지 입기
func take_damage(damage: float, attacker: Node3D = null) -> void:
	"""데미지 입기"""
	current_hp = max(0, current_hp - damage)
	
	print(f"💔 [Enemy] 피해: {damage:.1f} (HP: {int(current_hp)}/{int(max_hp)})")
	
	# HP 50% 이하면 도주
	if current_hp < max_hp * 0.5:
		change_state(AIState.FLEE)
	
	# 죽음 확인
	if current_hp <= 0:
		change_state(AIState.IDLE)
		print(f"💀 [Enemy] 처치됨!")
		died.emit(self)

## 상태 변경
func change_state(new_state: AIState) -> void:
	if current_state == new_state:
		return
	
	var old_state = current_state
	current_state = new_state
	
	if new_state == AIState.CHASE:
		chase_time = 0.0
	
	print(f"🔄 [Enemy] 상태: {AIState.keys()[old_state]} → {AIState.keys()[new_state]}")

## 목표 설정
func set_target(new_target: Node3D) -> void:
	target = new_target
	if target != null:
		print(f"🎯 [Enemy] 목표 설정: {target.name}")

## 디버그 정보
func get_ai_stats() -> Dictionary:
	return {
		"level": ai_level,
		"state": AIState.keys()[current_state],
		"hp": int(current_hp),
		"max_hp": int(max_hp),
		"energy": int(current_energy),
		"distance_to_target": target_distance if target != null else -1
	}

func print_ai_stats() -> void:
	var stats = get_ai_stats()
	print("\n🤖 적 AI 상태:")
	print(f"  Level: {stats['level']}")
	print(f"  State: {stats['state']}")
	print(f"  HP: {stats['hp']}/{stats['max_hp']}")
	print(f"  Energy: {int(current_energy)}/{int(max_energy)}")
	print(f"  Distance: {stats['distance_to_target']:.1f}m")
	print()
