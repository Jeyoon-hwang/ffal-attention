## NPC.gd - 기본 NPC 클래스
##
## 모든 NPC의 기초 클래스
## 상호작용, 대화, 서비스 제공 기능 포함

extends Node3D

class_name NPC

# NPC 기본 정보
var npc_name: String = "NPC"
var npc_type: String = "generic"  # "martial_master", "merchant", "quest_giver"
var npc_id: String = ""
var description: String = ""

# 위치 및 상태
var world_position: Vector3 = Vector3.ZERO
var interaction_distance: float = 5.0
var is_active: bool = true

# 대화 시스템
var dialogue: Array[String] = [
	"안녕하세요.",
	"뭘 도와드릴까요?"
]
var current_dialogue_index: int = 0

# 상호작용 옵션
var interaction_options: Array[String] = []
var interaction_callback: Callable = Callable()

# 감정 상태
var mood: String = "neutral"  # "happy", "sad", "angry", "neutral"
var affinity: int = 0  # -100 to 100

# NPC 초기화
func _init(p_name: String = "NPC", p_type: String = "generic") -> void:
	"""NPC 초기화"""
	npc_name = p_name
	npc_type = p_type
	npc_id = "%s_%d" % [p_type, randi()]

func _ready() -> void:
	"""Godot 초기화"""
	pass

## 플레이어와 상호작용
func interact(player: Node) -> void:
	"""플레이어와 상호작용"""
	print("[%s]" % npc_name)
	speak_dialogue()

## 대화 출력
func speak_dialogue() -> void:
	"""대사 출력"""
	if dialogue.size() > 0:
		var text = dialogue[current_dialogue_index % dialogue.size()]
		print("  → %s" % text)
		current_dialogue_index += 1

## 대화 옵션 반환
func get_dialogue_options() -> Array[String]:
	"""상호작용 옵션 반환"""
	return interaction_options

## 특정 옵션 선택
func select_option(option_index: int, player: Node) -> void:
	"""플레이어가 옵션 선택"""
	if option_index < interaction_options.size():
		print("  플레이어: %s" % interaction_options[option_index])
		handle_option(option_index, player)
	else:
		print("  [존재하지 않는 선택]")

## 옵션 처리 (서브클래스에서 오버라이드)
func handle_option(option_index: int, player: Node) -> void:
	"""옵션 처리 (오버라이드 필요)"""
	pass

## 감정 변화
func change_mood(new_mood: String) -> void:
	"""NPC의 감정 변화"""
	mood = new_mood
	print("[%s의 감정이 '%s'로 변했습니다.]" % [npc_name, mood])

## 호감도 변화
func change_affinity(amount: int) -> void:
	"""호감도 변화"""
	affinity = clamp(affinity + amount, -100, 100)
	print("[%s와의 호감도: %d]" % [npc_name, affinity])

## NPC 정보 출력
func print_info() -> void:
	"""NPC 정보 출력"""
	print("\n[NPC 정보: %s]" % npc_name)
	print("  • 타입: %s" % npc_type)
	print("  • ID: %s" % npc_id)
	print("  • 설명: %s" % description)
	print("  • 위치: (%.1f, %.1f, %.1f)" % [world_position.x, world_position.y, world_position.z])
	print("  • 감정: %s" % mood)
	print("  • 호감도: %d" % affinity)
	print("  • 상태: %s" % ("활성화" if is_active else "비활성화"))
	
	if interaction_options.size() > 0:
		print("  • 옵션:")
		for i in range(interaction_options.size()):
			print("    %d. %s" % [i + 1, interaction_options[i]])

## NPC 비활성화
func disable() -> void:
	"""NPC 비활성화"""
	is_active = false
	print("[%s가 자리를 떠났습니다.]" % npc_name)

## NPC 활성화
func enable() -> void:
	"""NPC 활성화"""
	is_active = true
	print("[%s가 나타났습니다.]" % npc_name)

## 거리 확인
func is_player_in_range(player_pos: Vector3) -> bool:
	"""플레이어가 상호작용 거리 내인지 확인"""
	return world_position.distance_to(player_pos) <= interaction_distance

## 상호작용 가능 여부
func can_interact() -> bool:
	"""상호작용 가능 여부"""
	return is_active and interaction_options.size() > 0
