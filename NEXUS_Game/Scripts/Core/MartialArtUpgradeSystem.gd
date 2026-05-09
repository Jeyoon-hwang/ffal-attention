## MartialArtUpgradeSystem.gd - 무술 강화 시스템
##
## 플레이어의 무술을 강화하는 시스템
## 스킬 포인트를 소비하여 무술의 능력치를 상향

extends Node

class_name MartialArtUpgradeSystem

# 강화 효과 정의
var upgrade_effects: Dictionary = {
	"damage": {
		"name": "데미지 강화",
		"description": "공격력을 1.5배로 증가시킵니다.",
		"cost": 10,  # 스킬 포인트
		"multiplier": 1.5,
		"icon": "⚔️"
	},
	"speed": {
		"name": "속도 강화",
		"description": "공격 속도를 1.25배로 증가시킵니다.",
		"cost": 12,
		"multiplier": 1.25,
		"icon": "⚡"
	},
	"reach": {
		"name": "리치 강화",
		"description": "공격 범위를 1.2배로 증가시킵니다.",
		"cost": 8,
		"multiplier": 1.2,
		"icon": "📏"
	},
	"combo": {
		"name": "콤보 강화",
		"description": "콤보 연결성을 1.3배로 증가시킵니다.",
		"cost": 15,
		"multiplier": 1.3,
		"icon": "🔗"
	},
	"accuracy": {
		"name": "명중도 강화",
		"description": "무술의 명중도를 20% 증가시킵니다.",
		"cost": 10,
		"multiplier": 1.2,
		"icon": "🎯"
	},
	"piercing": {
		"name": "관통력 강화",
		"description": "방어력 무시율을 15% 증가시킵니다.",
		"cost": 13,
		"multiplier": 1.15,
		"icon": "💫"
	}
}

# 강화 통계
var total_upgrades_performed: int = 0
var martial_arts_upgraded: Dictionary = {}  # {martial_id: {upgrade_type: count}}

## 무술 강화
func upgrade_martial_art(player: Node, martial_id: String, upgrade_type: String) -> bool:
	"""무술을 강화합니다."""
	
	if not upgrade_type in upgrade_effects:
		print("[강화 실패] 존재하지 않는 강화 유형: %s" % upgrade_type)
		return false
	
	var upgrade = upgrade_effects[upgrade_type]
	var cost = upgrade["cost"]
	
	# 스킬 포인트 확인
	if player.skill_points < cost:
		print("[강화 실패] 스킬 포인트 부족!")
		print("  필요: %d SP | 보유: %d SP" % [cost, player.skill_points])
		return false
	
	# 강화 실행
	player.skill_points -= cost
	
	# 통계 기록
	total_upgrades_performed += 1
	
	if not martial_id in martial_arts_upgraded:
		martial_arts_upgraded[martial_id] = {}
	
	if not upgrade_type in martial_arts_upgraded[martial_id]:
		martial_arts_upgraded[martial_id][upgrade_type] = 0
	
	martial_arts_upgraded[martial_id][upgrade_type] += 1
	
	# 성공 메시지
	print("\n✅ [강화 성공]")
	print("  무술: %s" % martial_id)
	print("  강화: %s %s" % [upgrade["icon"], upgrade["name"]])
	print("  효과: %s" % upgrade["description"])
	print("  비용: %d SP (남은 포인트: %d)" % [cost, player.skill_points])
	
	return true

## 여러 강화 동시 수행
func upgrade_multiple(player: Node, martial_id: String, upgrades: Array[String]) -> int:
	"""여러 강화를 동시에 수행합니다."""
	
	var success_count = 0
	
	for upgrade_type in upgrades:
		if upgrade_martial_art(player, martial_id, upgrade_type):
			success_count += 1
	
	return success_count

## 강화 정보 조회
func get_upgrade_info(upgrade_type: String) -> Dictionary:
	"""강화 정보를 반환합니다."""
	
	if upgrade_type in upgrade_effects:
		return upgrade_effects[upgrade_type]
	
	return {}

## 강화 비용 조회
func get_upgrade_cost(upgrade_type: String) -> int:
	"""강화 비용을 반환합니다."""
	
	if upgrade_type in upgrade_effects:
		return upgrade_effects[upgrade_type]["cost"]
	
	return -1

## 강화 가능 여부
func can_upgrade(player: Node, upgrade_type: String) -> bool:
	"""강화 가능 여부를 확인합니다."""
	
	var cost = get_upgrade_cost(upgrade_type)
	
	if cost == -1:
		return false
	
	return player.skill_points >= cost

## 가능한 강화 목록
func get_available_upgrades(player: Node) -> Array[String]:
	"""현재 가능한 모든 강화를 반환합니다."""
	
	var available: Array[String] = []
	
	for upgrade_type in upgrade_effects:
		if can_upgrade(player, upgrade_type):
			available.append(upgrade_type)
	
	return available

## 강화 비용 계산
func calculate_total_cost(upgrades: Array[String]) -> int:
	"""여러 강화의 총 비용을 계산합니다."""
	
	var total = 0
	
	for upgrade_type in upgrades:
		total += get_upgrade_cost(upgrade_type)
	
	return total

## 강화 효과 시뮬레이션
func simulate_upgrade(martial_data: Dictionary, upgrade_type: String) -> Dictionary:
	"""강화 후 무술의 능력치를 계산합니다."""
	
	var upgrade = upgrade_effects[upgrade_type]
	var result = martial_data.duplicate(true)
	
	match upgrade_type:
		"damage":
			result["damage"] = martial_data["damage"] * upgrade["multiplier"]
		"speed":
			result["speed"] = martial_data["speed"] * upgrade["multiplier"]
		"reach":
			result["reach"] = martial_data["reach"] * upgrade["multiplier"]
		"combo":
			result["combo"] = martial_data.get("combo", 1.0) * upgrade["multiplier"]
		"accuracy":
			result["accuracy"] = martial_data.get("accuracy", 1.0) * upgrade["multiplier"]
		"piercing":
			result["piercing"] = martial_data.get("piercing", 0.0) * upgrade["multiplier"]
	
	return result

## 전체 강화 목록 출력
func print_upgrade_list() -> void:
	"""모든 강화를 출력합니다."""
	
	print("\n" + "="*50)
	print("🔧 무술 강화 시스템 - 강화 목록")
	print("="*50)
	
	for upgrade_key in upgrade_effects:
		var upgrade = upgrade_effects[upgrade_key]
		print("\n%s %s" % [upgrade["icon"], upgrade["name"]])
		print("  설명: %s" % upgrade["description"])
		print("  비용: %d SP" % upgrade["cost"])
		print("  효과: %.1f배 증가" % upgrade["multiplier"])

## 플레이어의 강화 현황 출력
func print_upgrade_status(player: Node) -> void:
	"""플레이어의 강화 현황을 출력합니다."""
	
	print("\n" + "="*50)
	print("📊 강화 현황")
	print("="*50)
	print("보유 스킬 포인트: %d SP" % player.skill_points)
	
	print("\n[사용 가능한 강화]")
	var available = get_available_upgrades(player)
	
	if available.size() == 0:
		print("  (스킬 포인트 부족)")
	else:
		for upgrade_type in available:
			var upgrade = upgrade_effects[upgrade_type]
			print("  %s %s (%d SP)" % [upgrade["icon"], upgrade["name"], upgrade["cost"]])
	
	print("\n[강화 이력]")
	
	if martial_arts_upgraded.size() == 0:
		print("  (강화한 무술이 없습니다)")
	else:
		for martial_id in martial_arts_upgraded:
			var upgrades = martial_arts_upgraded[martial_id]
			print("  • %s:" % martial_id)
			
			for upgrade_type in upgrades:
				var count = upgrades[upgrade_type]
				var upgrade = upgrade_effects[upgrade_type]
				print("    - %s: %d회" % [upgrade["name"], count])

## 통계
func get_statistics() -> Dictionary:
	"""강화 시스템의 통계를 반환합니다."""
	
	var upgrade_count = 0
	for martial_id in martial_arts_upgraded:
		for upgrade_type in martial_arts_upgraded[martial_id]:
			upgrade_count += martial_arts_upgraded[martial_id][upgrade_type]
	
	return {
		"total_upgrades": total_upgrades_performed,
		"upgraded_martial_arts": martial_arts_upgraded.size(),
		"total_individual_upgrades": upgrade_count,
		"available_upgrade_types": upgrade_effects.size()
	}

## 강화 시스템 초기화
func reset_statistics() -> void:
	"""통계를 초기화합니다."""
	total_upgrades_performed = 0
	martial_arts_upgraded.clear()
	print("[강화 시스템] 통계가 초기화되었습니다.")
