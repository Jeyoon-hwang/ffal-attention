## ChuongyeonZone.gd - 중원 지역
##
## 첫 번째 주요 지역: "중원" (500m × 500m)
## - 무술관, 상점, 몬스터 스폰 포인트, 던전 입구 포함

extends Node3D

class_name ChuongyeonZone

# 지역 기본 정보
var zone_name: String = "중원"
var zone_id: String = "chuongyeon_01"
var zone_level_range: Array[int] = [1, 10]
var zone_size: Vector3 = Vector3(500, 500, 0)  # 500m × 500m

# NPC 배치
var npcs: Dictionary = {}
var npc_count: int = 0

# 몬스터 스폰 포인트
var monster_spawns: Array[Dictionary] = []

# 던전 입구들
var dungeon_entrances: Array[Dictionary] = []

# 지역 상태
var player_level: int = 1
var visited: bool = false

func _ready() -> void:
	"""초기화"""
	initialize_zone()

## 지역 초기화
func initialize_zone() -> void:
	"""지역의 모든 요소 초기화"""
	
	# NPC 배치
	setup_npcs()
	
	# 몬스터 스폰 포인트
	setup_monster_spawns()
	
	# 던전 입구
	setup_dungeon_entrances()
	
	print("[ChuongyeonZone] '%s' 지역 초기화 완료!" % zone_name)
	print("  • 크기: %d × %d 미터" % [int(zone_size.x), int(zone_size.y)])
	print("  • NPC: %d명" % npc_count)
	print("  • 몬스터 스폰 포인트: %d개" % monster_spawns.size())
	print("  • 던전: %d개" % dungeon_entrances.size())

## NPC 배치
func setup_npcs() -> void:
	"""지역의 NPC 배치"""
	
	# NPC 1: 무술관 마스터
	npcs["martial_master"] = {
		"name": "천산 장인",
		"type": "martial_master",
		"description": "중원 무술관의 주인. 무술을 전수합니다.",
		"position": Vector3(100, 0, 100),
		"dialogue": [
			"환영한다, 젊은이.",
			"내가 너에게 무술을 전수하겠노라."
		],
		"services": ["무술 배우기", "무술 강화"]
	}
	
	# NPC 2: 무술관 조수
	npcs["martial_helper"] = {
		"name": "이목구",
		"type": "martial_helper",
		"description": "무술관의 조수. 무술 정보를 제공합니다.",
		"position": Vector3(110, 0, 110),
		"dialogue": [
			"안녕하세요.",
			"마스터를 찾으세요?"
		],
		"services": ["무술 정보", "도움 요청"]
	}
	
	# NPC 3: 상인
	npcs["merchant"] = {
		"name": "장상인",
		"type": "merchant",
		"description": "여행하는 상인. 아이템을 판매합니다.",
		"position": Vector3(150, 0, 200),
		"dialogue": [
			"반갑습니다!",
			"좋은 물건들을 많이 가지고 있습니다."
		],
		"services": ["아이템 구매", "포션 판매"],
		"inventory": [
			{"name": "체력포션", "cost": 20, "quantity": 10},
			{"name": "에너지포션", "cost": 15, "quantity": 10},
			{"name": "부스트포션", "cost": 50, "quantity": 5}
		]
	}
	
	npc_count = npcs.size()

## 몬스터 스폰 포인트 설정
func setup_monster_spawns() -> void:
	"""몬스터 스폰 포인트 설정"""
	
	# 스폰 포인트 1: 초급 늑대 (Level 1)
	monster_spawns.append({
		"name": "Wolf Pack",
		"position": Vector3(200, 0, 200),
		"enemy_type": "늑대",
		"level": 1,
		"count": 3,
		"respawn_time": 60  # 초 단위
	})
	
	# 스폰 포인트 2: 도적 (Level 2)
	monster_spawns.append({
		"name": "Bandit Camp",
		"position": Vector3(300, 0, 300),
		"enemy_type": "도적",
		"level": 2,
		"count": 2,
		"respawn_time": 90
	})
	
	# 스폰 포인트 3: 박쥐 떼 (Level 1)
	monster_spawns.append({
		"name": "Bat Swarm",
		"position": Vector3(400, 0, 100),
		"enemy_type": "박쥐",
		"level": 1,
		"count": 5,
		"respawn_time": 45
	})
	
	# 스폰 포인트 4: 원숭이 (Level 2)
	monster_spawns.append({
		"name": "Monkey Tribe",
		"position": Vector3(50, 0, 400),
		"enemy_type": "원숭이",
		"level": 2,
		"count": 4,
		"respawn_time": 80
	})

## 던전 입구 설정
func setup_dungeon_entrances() -> void:
	"""던전 입구 설정"""
	
	# 입구 1: 첫 던전
	dungeon_entrances.append({
		"name": "첫 던전",
		"description": "초보자를 위한 던전. 기본적인 전투를 배울 수 있습니다.",
		"position": Vector3(50, 0, 50),
		"dungeon_class": "FirstDungeon",
		"required_level": 1,
		"recommended_level": 1,
		"max_level": 10,
		"difficulty": "쉬움",
		"playtime": "15-20분"
	})

## 플레이어가 지역에 진입
func enter_zone(player: Node) -> void:
	"""플레이어가 지역에 진입"""
	visited = true
	
	print("\n" + "="*50)
	print("🗺️  '%s' 지역에 도착했습니다!" % zone_name)
	print("="*50)
	print("\n[지역 정보]")
	print("  • 지역명: %s" % zone_name)
	print("  • 크기: %d × %d 미터" % [int(zone_size.x), int(zone_size.y)])
	print("  • 권장 레벨: %d~%d" % zone_level_range)
	print("  • NPC: %d명" % npc_count)
	print("  • 몬스터 스폰: %d곳" % monster_spawns.size())
	print("  • 던전: %d개" % dungeon_entrances.size())
	print("\n[주요 위치]")
	
	# NPC 정보 출력
	print("\n  📍 NPC:")
	for npc_key in npcs:
		var npc = npcs[npc_key]
		print("    • %s (%s): %s" % [npc["name"], npc["type"], npc["description"]])
	
	# 던전 정보 출력
	print("\n  🏰 던전:")
	for dungeon in dungeon_entrances:
		print("    • %s (권장 %d레벨): %s" % [
			dungeon["name"],
			dungeon["recommended_level"],
			dungeon["description"]
		])
	
	# 몬스터 스폰 포인트 정보 출력
	print("\n  👹 몬스터 스폰:")
	for spawn in monster_spawns:
		print("    • %s (%s Lv.%d): %d마리 | 위치: (%.0f, %.0f)" % [
			spawn["name"],
			spawn["enemy_type"],
			spawn["level"],
			spawn["count"],
			spawn["position"].x,
			spawn["position"].z
		])
	
	print("\n" + "="*50)

## NPC와 상호작용
func interact_with_npc(npc_key: String) -> void:
	"""NPC와 상호작용"""
	if npc_key in npcs:
		var npc = npcs[npc_key]
		print("\n[%s]" % npc["name"])
		print(npc["dialogue"][0])
		print("\n서비스: %s" % ", ".join(npc["services"]))
	else:
		print("해당 NPC를 찾을 수 없습니다.")

## 던전 진입
func enter_dungeon(dungeon_index: int, player: Node) -> void:
	"""던전에 진입"""
	if dungeon_index < dungeon_entrances.size():
		var dungeon_data = dungeon_entrances[dungeon_index]
		print("\n[%s에 진입합니다...]" % dungeon_data["name"])
		print("권장 레벨: %d / 현재 레벨: %d" % [dungeon_data["recommended_level"], player_level])
		
		# 던전 클래스 인스턴스 생성 및 진입
		if dungeon_data["dungeon_class"] == "FirstDungeon":
			var dungeon = FirstDungeon.new()
			dungeon.enter_dungeon(player)

## 몬스터 사냥 (시뮬레이션)
func hunt_monsters(spawn_index: int, count: int = 1) -> Dictionary:
	"""몬스터 사냥 시뮬레이션"""
	if spawn_index >= monster_spawns.size():
		return {"success": false, "message": "스폰 포인트가 없습니다."}
	
	var spawn = monster_spawns[spawn_index]
	
	var result = {
		"success": true,
		"enemy_type": spawn["enemy_type"],
		"level": spawn["level"],
		"count": count,
		"experience_gained": spawn["level"] * 10 * count,
		"gold_gained": spawn["level"] * 5 * count,
		"message": "%s x %d마리를 사냥했습니다!" % [spawn["enemy_type"], count]
	}
	
	print("\n[몬스터 사냥]")
	print("  위치: %s" % spawn["name"])
	print("  적: %s (Lv.%d) x %d" % [spawn["enemy_type"], spawn["level"], count])
	print("  경험치: +%d" % result["experience_gained"])
	print("  골드: +%d" % result["gold_gained"])
	
	return result

## 지역 정보 출력
func print_zone_info() -> void:
	"""지역 정보 출력"""
	print("\n" + "="*50)
	print("📜 지역 정보: %s" % zone_name)
	print("="*50)
	print("ID: %s" % zone_id)
	print("크기: %d × %d 미터" % [int(zone_size.x), int(zone_size.y)])
	print("권장 레벨: %d~%d" % zone_level_range)
	print("방문 여부: %s" % ("방문함" if visited else "미방문"))
	
	print("\n[NPC 목록]")
	for npc_key in npcs:
		var npc = npcs[npc_key]
		print("  • %s (%s)" % [npc["name"], npc["type"]])
	
	print("\n[던전 입구]")
	for i in range(dungeon_entrances.size()):
		var dungeon = dungeon_entrances[i]
		print("  %d. %s (Lv.%d~%d, %s)" % [
			i + 1,
			dungeon["name"],
			dungeon["required_level"],
			dungeon["max_level"],
			dungeon["difficulty"]
		])
	
	print("\n[몬스터 스폰]")
	for i in range(monster_spawns.size()):
		var spawn = monster_spawns[i]
		print("  %d. %s: %s (Lv.%d) x %d마리" % [
			i + 1,
			spawn["name"],
			spawn["enemy_type"],
			spawn["level"],
			spawn["count"]
		])

## 통계 정보
func get_statistics() -> Dictionary:
	"""지역 통계 반환"""
	var total_spawns = 0
	var total_enemies = 0
	
	for spawn in monster_spawns:
		total_spawns += 1
		total_enemies += spawn["count"]
	
	return {
		"zone_name": zone_name,
		"zone_size": zone_size,
		"npc_count": npc_count,
		"dungeon_count": dungeon_entrances.size(),
		"spawn_point_count": total_spawns,
		"total_enemies": total_enemies,
		"visited": visited
	}
