# NEXUS 존 관리자 (Zone Manager)
# 지역 로드, NPC 관리, 던전 입장
# Week 1-2: 첫 지역 (중원) 완전 통합

extends Node

class_name ZoneManager

# ============================================================================
# 멤버 변수
# ============================================================================

var current_zone: Dictionary = {}
var available_dungeons: Array[Dictionary] = []
var npcs: Array[Dictionary] = []
var quests: Array[Dictionary] = []
var dungeon_generator: DungeonGenerator = DungeonGenerator.new()

# ============================================================================
# 존 로드
# ============================================================================

## JSON 파일로부터 존 데이터 로드
func load_zone(zone_id: String) -> bool:
	var zone_path = "res://content/zones/%s.json" % zone_id
	var file = FileAccess.open(zone_path, FileAccess.READ)
	
	if file == null:
		print("❌ 존 로드 실패: %s" % zone_path)
		return false
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error != OK:
		print("❌ JSON 파싱 오류")
		return false
	
	current_zone = json.get_data()
	print("✅ 존 로드 성공: %s" % current_zone["zone_name"])
	
	# 던전 데이터 로드
	_load_dungeons()
	
	# NPC 데이터 로드
	_load_npcs()
	
	# 퀘스트 데이터 로드
	_load_quests()
	
	return true

## 던전 목록 로드
func _load_dungeons() -> void:
	available_dungeons.clear()
	
	for dungeon_data in current_zone["dungeons"]:
		available_dungeons.append(dungeon_data)
	
	print("\n🏛️ %d개 던전 로드됨:" % available_dungeons.size())
	for dungeon in available_dungeons:
		print("  - %s (난이도: %d, 추천 레벨: %d)" % 
			[dungeon["dungeon_name"], dungeon["difficulty"], dungeon["recommended_level"]])

## NPC 데이터 로드
func _load_npcs() -> void:
	npcs.clear()
	
	for npc_key in current_zone["npc_locations"].keys():
		var npc_data = current_zone["npc_locations"][npc_key]
		npc_data["npc_id"] = npc_key
		npcs.append(npc_data)
	
	print("\n👥 %d명 NPC 로드됨:" % npcs.size())
	for npc in npcs:
		print("  - %s (%s)" % [npc["name"], npc["role"]])

## 퀘스트 데이터 로드
func _load_quests() -> void:
	quests.clear()
	
	for quest_data in current_zone["quests"]:
		quests.append(quest_data)
	
	print("\n📋 %d개 퀘스트 로드됨:" % quests.size())
	for quest in quests:
		print("  - %s (제공자: %s)" % [quest["quest_name"], quest["giver"]])

# ============================================================================
# 던전 접근
# ============================================================================

## 던전 입장 (ID로)
func enter_dungeon(dungeon_id: String) -> Dictionary:
	var dungeon_data = _find_dungeon(dungeon_id)
	
	if dungeon_data == null:
		print("❌ 던전을 찾을 수 없음: %s" % dungeon_id)
		return {}
	
	print("\n⚔️ [%s]에 입장했습니다!" % dungeon_data["dungeon_name"])
	
	# 던전 생성
	var dungeon = dungeon_generator.generate_dungeon(dungeon_data)
	
	# 던전 정보 출력
	dungeon_generator.print_dungeon(dungeon)
	
	return {
		"dungeon": dungeon,
		"data": dungeon_data,
	}

## 던전 찾기
func _find_dungeon(dungeon_id: String) -> Dictionary:
	for dungeon in available_dungeons:
		if dungeon["dungeon_id"] == dungeon_id:
			return dungeon
	return null

## 첫 던전 추천
func get_first_dungeon() -> Dictionary:
	if available_dungeons.is_empty():
		return {}
	return available_dungeons[0]

# ============================================================================
# NPC 상호작용
# ============================================================================

## NPC 찾기
func find_npc(npc_id: String) -> Dictionary:
	for npc in npcs:
		if npc["npc_id"] == npc_id:
			return npc
	return {}

## NPC 대사 출력
func talk_to_npc(npc_id: String) -> String:
	var npc = find_npc(npc_id)
	
	if npc.is_empty():
		return "그런 NPC는 없습니다."
	
	return npc["dialogue"]

# ============================================================================
# 퀘스트 시스템
# ============================================================================

## 특정 NPC로부터 받을 수 있는 퀘스트
func get_quests_from_npc(npc_name: String) -> Array[Dictionary]:
	var npc_quests: Array[Dictionary] = []
	
	for quest in quests:
		if quest["giver"] == npc_name:
			npc_quests.append(quest)
	
	return npc_quests

# ============================================================================
# 존 정보 출력
# ============================================================================

func print_zone_info() -> void:
	print("\n" + "=" * 60)
	print("🌍 %s" % current_zone["zone_name"])
	print("=" * 60)
	print(current_zone["description"])
	print("\n지역 크기: %dx%dx%dm" % 
		[current_zone["size"]["width"], 
		 current_zone["size"]["height"],
		 current_zone["size"]["depth"]])
	print("지형: %s" % current_zone["terrain"]["type"])
	print("=" * 60)

# ============================================================================
# 테스트
# ============================================================================

func test_zone_loading() -> void:
	print("\n" + "=" * 80)
	print("🧪 Zone Manager 테스트 (Week 1, Day 2)")
	print("=" * 80)
	
	# 중원 로드
	if not load_zone("central_plains"):
		return
	
	# 존 정보 출력
	print_zone_info()
	
	# 첫 던전 입장
	var first_dungeon = get_first_dungeon()
	if not first_dungeon.is_empty():
		var result = enter_dungeon(first_dungeon["dungeon_id"])

func _ready() -> void:
	test_zone_loading()
