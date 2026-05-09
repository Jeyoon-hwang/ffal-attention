## Quest.gd - 기본 퀘스트 클래스
##
## 모든 퀘스트의 기초 클래스
## 수락, 진행, 완료 시스템 포함

extends Node

class_name Quest

# 퀘스트 기본 정보
var quest_id: String = ""
var quest_name: String = "퀘스트"
var quest_description: String = ""
var quest_type: String = "generic"  # "monster_hunt", "collect", "delivery", "explore"
var quest_level: int = 1

# 상태
var is_accepted: bool = false
var is_completed: bool = false
var is_failed: bool = false

# 조건
var objective_target: String = ""  # "몬스터 이름" 또는 "아이템 이름"
var objective_count: int = 1
var objective_current: int = 0

# 보상
var rewards: Dictionary = {
	"experience": 100,
	"gold": 50,
	"items": []
}

# 통계
var accepted_at: float = 0.0
var completed_at: float = 0.0

func _init(p_name: String = "퀘스트", p_type: String = "generic") -> void:
	"""퀘스트 초기화"""
	quest_name = p_name
	quest_type = p_type
	quest_id = "%s_%d" % [p_type, randi()]

## 퀨스트 수락
func accept_quest() -> bool:
	"""퀘스트를 수락합니다."""
	
	if is_accepted:
		print("[퀘스트] 이미 수락한 퀘스트입니다.")
		return false
	
	is_accepted = true
	accepted_at = Time.get_ticks_msec()
	
	print("\n✅ [퀘스트 수락]")
	print("  이름: %s" % quest_name)
	print("  설명: %s" % quest_description)
	print("  목표: %s x %d개" % [objective_target, objective_count])
	
	return true

## 진행도 업데이트
func update_progress(amount: int = 1) -> void:
	"""퀘스트 진행도를 업데이트합니다."""
	
	if not is_accepted or is_completed:
		return
	
	objective_current += amount
	
	if objective_current >= objective_count:
		objective_current = objective_count
		complete_quest()

## 퀘스트 완료
func complete_quest() -> void:
	"""퀘스트를 완료합니다."""
	
	if is_completed:
		return
	
	is_completed = true
	completed_at = Time.get_ticks_msec()
	
	print("\n🎉 [퀘스트 완료]")
	print("  이름: %s" % quest_name)
	print("  보상:")
	print("    • 경험치: %d XP" % rewards["experience"])
	print("    • 골드: %d원" % rewards["gold"])

## 퀘스트 실패
func fail_quest() -> void:
	"""퀘스트를 실패합니다."""
	
	if is_failed or is_completed:
		return
	
	is_failed = true
	
	print("\n❌ [퀘스트 실패]")
	print("  이름: %s" % quest_name)

## 퀘스트 포기
func abandon_quest() -> void:
	"""퀘스트를 포기합니다."""
	
	is_accepted = false
	objective_current = 0
	
	print("\n⚠️ [퀘스트 포기]")
	print("  이름: %s" % quest_name)

## 퀘스트 정보 출력
func print_quest_info() -> void:
	"""�에스트 정보를 출력합니다."""
	
	print("\n" + "="*50)
	print("📜 %s" % quest_name)
	print("="*50)
	print("ID: %s" % quest_id)
	print("타입: %s" % quest_type)
	print("레벨: %d" % quest_level)
	print("\n설명:")
	print("  %s" % quest_description)
	print("\n목표:")
	print("  %s (%d/%d)" % [objective_target, objective_current, objective_count])
	print("\n보상:")
	print("  • 경험치: %d XP" % rewards["experience"])
	print("  • 골드: %d원" % rewards["gold"])
	print("\n상태:")
	
	if is_completed:
		print("  ✅ 완료")
	elif is_failed:
		print("  ❌ 실패")
	elif is_accepted:
		print("  🟡 진행 중 (%.1f%%)" % ((float(objective_current) / float(objective_count)) * 100))
	else:
		print("  ⚪ 미수락")

## 통계
func get_statistics() -> Dictionary:
	"""퀘스트 통계를 반환합니다."""
	
	return {
		"quest_id": quest_id,
		"quest_name": quest_name,
		"quest_type": quest_type,
		"quest_level": quest_level,
		"is_completed": is_completed,
		"progress": float(objective_current) / float(objective_count),
		"total_rewards": rewards["experience"] + rewards["gold"]
	}
