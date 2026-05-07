## Enemy.gd - 적 캐릭터 베이스 클래스
## AI, 능력치, 전투 로직

class_name Enemy
extends CharacterBody3D

# ╔═════════════════════════════════════════════════════════╗
# ║           기본 정보 (Identity)                          ║
# ╚═════════════════════════════════════════════════════════╝

var enemy_name: String = "몬스터"
var enemy_type: String = "generic"      # "goblin", "orc", "boss", etc
var ai_level: int = 1                   # AI 난이도 (1-4)
var level: int = 1

# ╔═════════════════════════════════════════════════════════╗
# ║            능력치 (Stats)                               ║
# ╚═════════════════════════════════════════════════════════╝

var stats: Dictionary = {
	"STR": 8,
	"DEX": 8,
	"CON": 8,
	"INT": 5,
	"WIS": 5,
	"CHA": 3
}

# ╔═════════════════════════════════════════════════════════╗
# ║        생명 & 에너지 (Life & Resources)                ║
# ╚═════════════════════════════════════════════════════════╝

var max_hp: int = 50
var current_hp: int = 50
var max_energy: int = 50
var current_energy: int = 50

# ╔═════════════════════════════════════════════════════════╗
# ║           무술 시스템 (Martial Arts)                   ║
# ╚═════════════════════════════════════════════════════════╝

var martial_slots: Array[MartialArt] = []  # 적은 최대 3개
var last_action_time: float = 0.0

# ╔═════════════════════════════════════════════════════════╗
# ║            전투 상태 (Combat State)                     ║
# ╚═════════════════════════════════════════════════════════╝

var current_state: String = "idle"      # idle, chase, attack, stun, dead
var target: Node = null                 # 목표 (플레이어)
var patrol_range: float = 10.0          # 순찰 범위
var aggro_range: float = 20.0           # 어그로 거리
var detection_loss_time: float = 0.0    # 타겟 감지 해제 타이머

# ╔═════════════════════════════════════════════════════════╗
# ║            AI 관련 (AI Related)                         ║
# ╚═════════════════════════════════════════════════════════╝

var ai_controller: AIController = null
var is_stunned: bool = false
var stun_timer: float = 0.0
var last_combat_time: float = 0.0

# ╔═════════════════════════════════════════════════════════╗
# ║            리워드 (Rewards)                             ║
# ╚═════════════════════════════════════════════════════════╝

var experience_reward: int = 100
var gold_reward: int = 50


# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# 초기 상태 설정
	current_state = "idle"


func _process(delta: float) -> void:
	# 기절 처리
	if is_stunned and stun_timer > 0:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
	
	# 자동 회복 (전투 아닐 때)
	if current_state == "idle" or current_state == "patrol":
		recover_energy(5.0 * delta)
	
	# 타겟 감지 해제 타이머
	if target and detection_loss_time > 0:
		detection_loss_time -= delta
		if detection_loss_time <= 0:
			target = null
			current_state = "idle"


# ╔═════════════════════════════════════════════════════════╗
# ║            능력치 (Stats Functions)                     ║
# ╚═════════════════════════════════════════════════════════╝

## 능력치 조회
func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)


# ╔═════════════════════════════════════════════════════════╗
# ║       생명 & 자원 (Life & Resources Functions)         ║
# ╚═════════════════════════════════════════════════════════╝

## 데미지 입기
func take_damage(amount: float, source: Node = null) -> void:
	if current_state == "dead":
		return
	
	# CON으로 방어력 계산
	var defense = stats["CON"] * 0.2
	var actual_damage = max(1.0, amount - defense)
	
	current_hp -= int(actual_damage)
	last_combat_time = Time.get_ticks_msec() / 1000.0
	
	if current_hp <= 0:
		current_hp = 0
		die()


## 체력 회복
func recover_hp(amount: float) -> void:
	current_hp = min(max_hp, int(current_hp + amount))


## 에너지 사용
func use_energy(amount: float) -> bool:
	if current_energy >= amount:
		current_energy -= int(amount)
		return true
	return false


## 에너지 회복
func recover_energy(amount: float) -> void:
	current_energy = min(max_energy, int(current_energy + amount))


## 사망
func die() -> void:
	current_state = "dead"
	print("%s 사망!" % enemy_name)


# ╔═════════════════════════════════════════════════════════╗
# ║          무술 관리 (Martial Arts Functions)            ║
# ╚═════════════════════════════════════════════════════════╝

## 무술 장착
func equip_martial_art(slot: int, art: MartialArt) -> bool:
	if slot < 0 or slot >= martial_slots.size():
		# 슬롯이 없으면 자동 추가
		if slot == martial_slots.size():
			martial_slots.append(art)
			return true
		return false
	
	martial_slots[slot] = art
	return true


## 무술 발동
func execute_martial_art(slot: int) -> Dictionary:
	if is_stunned or current_state == "dead":
		return {"success": false}
	
	if slot < 0 or slot >= martial_slots.size():
		return {"success": false}
	
	var art = martial_slots[slot]
	if art == null:
		return {"success": false}
	
	# 에너지 확인
	if not use_energy(art.energy_cost):
		return {"success": false}
	
	# 데미지 계산
	var damage = art.calculate_damage(self)
	art.on_use()
	
	return {
		"success": true,
		"damage": damage,
		"effects": art.effects,
		"range": art.range_distance
	}


# ╔═════════════════════════════════════════════════════════╗
# ║              상태 (Status Functions)                    ║
# ╚═════════════════════════════════════════════════════════╝

## 기절 상태 적용
func apply_stun(duration: float) -> void:
	is_stunned = true
	stun_timer = duration


## 타겟 감지
func detect_target(potential_target: Node) -> bool:
	var distance = global_position.distance_to(potential_target.global_position)
	
	if distance <= aggro_range:
		target = potential_target
		detection_loss_time = 10.0  # 10초 동안 감지 유지
		if current_state == "idle":
			current_state = "chase"
		return true
	
	return false


# ╔═════════════════════════════════════════════════════════╗
# ║          AI 행동 (AI Actions)                           ║
# ╚═════════════════════════════════════════════════════════╝

## AI가 다음 행동을 결정
func decide_action() -> Dictionary:
	# AI 컨트롤러가 있으면 사용
	if ai_controller:
		return ai_controller.decide_action()
	
	# 기본 AI: 간단한 추격
	if target == null:
		return {"action": "idle"}
	
	var distance = global_position.distance_to(target.global_position)
	
	if distance <= 5.0:
		# 충분히 가까우면 공격
		return {
			"action": "attack",
			"slot": randi() % min(martial_slots.size(), 2),
			"target": target
		}
	else:
		# 아니면 추격
		return {
			"action": "chase",
			"target": target
		}


## 행동 실행
func execute_action(action: Dictionary) -> void:
	match action.get("action", "idle"):
		"idle":
			current_state = "idle"
		
		"chase":
			current_state = "chase"
			if action.has("target"):
				target = action["target"]
		
		"attack":
			current_state = "attack"
			var slot = action.get("slot", 0)
			execute_martial_art(slot)


# ╔═════════════════════════════════════════════════════════╗
# ║         초기화 헬퍼 (Initialization Helpers)            ║
# ╚═════════════════════════════════════════════════════════╝

## 적 정보 초기화
func init_enemy(p_name: String, p_type: String, p_level: int, p_ai_level: int) -> Enemy:
	enemy_name = p_name
	enemy_type = p_type
	level = p_level
	ai_level = p_ai_level
	
	# 레벨에 따라 스탯 조정
	for stat in stats.keys():
		stats[stat] += p_level - 1
	
	# HP, 에너지 초기화
	max_hp = 50 + (p_level - 1) * 10
	current_hp = max_hp
	max_energy = 30 + (p_level - 1) * 5
	current_energy = max_energy
	
	# 리워드 계산
	experience_reward = 100 * p_level
	gold_reward = 50 * p_level
	
	return self


# ╔═════════════════════════════════════════════════════════╗
# ║           저장/로드 (Save/Load)                         ║
# ╚═════════════════════════════════════════════════════════╝

## 딕셔너리로 변환
func to_dict() -> Dictionary:
	var martial_ids: Array[String] = []
	for art in martial_slots:
		if art:
			martial_ids.append(art.id)
		else:
			martial_ids.append("")
	
	return {
		"enemy_name": enemy_name,
		"enemy_type": enemy_type,
		"ai_level": ai_level,
		"level": level,
		"stats": stats.duplicate(),
		"current_hp": current_hp,
		"max_hp": max_hp,
		"martial_ids": martial_ids,
		"experience_reward": experience_reward,
		"gold_reward": gold_reward
	}


## 표준 출력
func _to_string() -> String:
	return "Enemy([Lv.%d AI%d] %s, HP: %d/%d)" % [
		level, ai_level, enemy_name, current_hp, max_hp
	]
