# region_manager.gd - 지역 생성 및 관리 시스템
# Week 2: 추가 지역 5개 (중원 포함) 관리
# 각 지역은 환경, NPC, 적, 던전, 퀘스트를 포함

extends Node

# 지역 클래스
class Region:
	var name: String
	var id: String
	var terrain: String  # "plains", "snow", "sand", "mountain", "island"
	var size: Vector3 = Vector3(300, 100, 300)
	var difficulty: int  # 1-4
	
	var buildings: Array = []
	var spawn_points: Array = []
	var npcs: Array = []
	var dungeons: Array = []
	var quests: Array = []
	var bosses: Array = []
	
	func _init(p_name: String, p_id: String, p_terrain: String, p_difficulty: int):
		name = p_name
		id = p_id
		terrain = p_terrain
		difficulty = p_difficulty

class Building:
	var name: String
	var type: String  # "dojo", "shop", "inn", "library"
	var position: Vector3
	var size: Vector3
	
	func _init(p_name: String, p_type: String, p_pos: Vector3):
		name = p_name
		type = p_type
		position = p_pos
		size = Vector3(5, 5, 5)

class NPC:
	var name: String
	var role: String  # "merchant", "master", "sage"
	var level: int
	var region_id: String
	var quests: Array = []
	
	func _init(p_name: String, p_role: String, p_level: int, p_region: String):
		name = p_name
		role = p_role
		level = p_level
		region_id = p_region

class RegionQuest:
	var id: String
	var title: String
	var giver: String  # NPC name
	var objectives: Array
	var rewards: Dictionary
	var level_required: int
	
	func _init(p_id: String, p_title: String, p_giver: String, p_level: int):
		id = p_id
		title = p_title
		giver = p_giver
		level_required = p_level
		rewards = {"exp": 100 * p_level, "gold": 50 * p_level}

# 모든 지역 저장소
var regions: Dictionary = {}

func _ready():
	create_all_regions()

# === 지역 생성 함수들 ===

func create_all_regions():
	"""모든 5개 지역 생성"""
	
	# 1. 중원 (Central Plains) - 기본 지역
	create_zhongyuan_region()
	
	# 2. 동토 (Frostland) - 얼음 지역
	create_dongtu_region()
	
	# 3. 남해 (Southern Sea) - 섬 지역
	create_nanhai_region()
	
	# 4. 서역 (Western Wasteland) - 사막 지역
	create_xiyou_region()
	
	# 5. 북방 (Northern Peak) - 산 지역
	create_beifang_region()
	
	print("[Region Manager] 5개 지역 생성 완료: ", regions.keys())

func create_zhongyuan_region():
	"""중원 - 평원 기반, 난이도 1-2"""
	var region = Region.new("중원", "zhongyuan", "plains", 2)
	region.size = Vector3(300, 100, 300)
	
	# 건물 5개
	region.buildings.append(Building.new("용호도장", "dojo", Vector3(0, 0, 50)))
	region.buildings.append(Building.new("자비여관", "inn", Vector3(40, 0, 30)))
	region.buildings.append(Building.new("약재상점", "shop", Vector3(-40, 0, 30)))
	region.buildings.append(Building.new("고서실", "library", Vector3(0, 0, -50)))
	region.buildings.append(Building.new("명상실", "dojo", Vector3(-50, 0, -40)))
	
	# 스포닝 포인트 10개
	for i in range(10):
		var angle = (i / 10.0) * TAU
		var pos = Vector3(cos(angle) * 80, 0, sin(angle) * 80)
		region.spawn_points.append(pos)
	
	# NPC 5명
	region.npcs.append(NPC.new("은사 청운", "master", 3, "zhongyuan"))
	region.npcs.append(NPC.new("상인 왕자", "merchant", 1, "zhongyuan"))
	region.npcs.append(NPC.new("수행자 진", "sage", 2, "zhongyuan"))
	region.npcs.append(NPC.new("이발소 주인", "merchant", 1, "zhongyuan"))
	region.npcs.append(NPC.new("도사 무", "sage", 2, "zhongyuan"))
	
	# 퀘스트 5개
	region.quests.append(RegionQuest.new("quest_zhongyuan_1", "기본 검술 수련", "은사 청운", 1))
	region.quests.append(RegionQuest.new("quest_zhongyuan_2", "상인 물품 배달", "상인 왕자", 1))
	region.quests.append(RegionQuest.new("quest_zhongyuan_3", "망령 격퇴", "수행자 진", 2))
	region.quests.append(RegionQuest.new("quest_zhongyuan_4", "보물 찾기", "이발소 주인", 2))
	region.quests.append(RegionQuest.new("quest_zhongyuan_5", "도사의 수련", "도사 무", 2))
	
	regions["zhongyuan"] = region

func create_dongtu_region():
	"""동토 - 눈/얼음 지역, 난이도 2-3"""
	var region = Region.new("동토", "dongtu", "snow", 3)
	region.size = Vector3(350, 150, 350)
	
	# 건물 5개
	region.buildings.append(Building.new("얼음탑", "dojo", Vector3(0, 20, 60)))
	region.buildings.append(Building.new("빙설굴", "library", Vector3(50, 0, 50)))
	region.buildings.append(Building.new("추위 제련소", "dojo", Vector3(-60, 0, 40)))
	region.buildings.append(Building.new("얼음 여관", "inn", Vector3(40, 0, -40)))
	region.buildings.append(Building.new("보급소", "shop", Vector3(-50, 0, -50)))
	
	# 스포닝 포인트 12개
	for i in range(12):
		var angle = (i / 12.0) * TAU
		var pos = Vector3(cos(angle) * 100, 10, sin(angle) * 100)
		region.spawn_points.append(pos)
	
	# NPC 4명
	region.npcs.append(NPC.new("얼음 도사 한", "master", 3, "dongtu"))
	region.npcs.append(NPC.new("설인 사냥꾼", "merchant", 2, "dongtu"))
	region.npcs.append(NPC.new("빙설 수사", "sage", 3, "dongtu"))
	region.npcs.append(NPC.new("보급 상인", "merchant", 1, "dongtu"))
	
	# 퀘스트 6개
	region.quests.append(RegionQuest.new("quest_dongtu_1", "얼음정령 격퇴", "얼음 도사 한", 2))
	region.quests.append(RegionQuest.new("quest_dongtu_2", "설인 3마리 사냥", "설인 사냥꾼", 2))
	region.quests.append(RegionQuest.new("quest_dongtu_3", "빙설 부적 수집", "빙설 수사", 3))
	region.quests.append(RegionQuest.new("quest_dongtu_4", "추위 극복 수련", "얼음 도사 한", 3))
	region.quests.append(RegionQuest.new("quest_dongtu_5", "보급품 가져오기", "보급 상인", 1))
	region.quests.append(RegionQuest.new("quest_dongtu_6", "숨겨진 동굴 찾기", "빙설 수사", 3))
	
	regions["dongtu"] = region

func create_nanhai_region():
	"""남해 - 섬/해변 지역, 난이도 2-3"""
	var region = Region.new("남해", "nanhai", "island", 3)
	region.size = Vector3(320, 80, 320)
	
	# 건물 5개
	region.buildings.append(Building.new("항구", "shop", Vector3(0, 0, 60)))
	region.buildings.append(Building.new("해적 소굴", "dojo", Vector3(50, 0, 50)))
	region.buildings.append(Building.new("명당", "library", Vector3(-60, 0, 40)))
	region.buildings.append(Building.new("해변 여관", "inn", Vector3(40, 0, -30)))
	region.buildings.append(Building.new("거래소", "shop", Vector3(-50, 0, -50)))
	
	# 스포닝 포인트 11개
	for i in range(11):
		var angle = (i / 11.0) * TAU
		var pos = Vector3(cos(angle) * 90, 0, sin(angle) * 90)
		region.spawn_points.append(pos)
	
	# NPC 4명
	region.npcs.append(NPC.new("해적 두목", "master", 3, "nanhai"))
	region.npcs.append(NPC.new("상인 돌핀", "merchant", 2, "nanhai"))
	region.npcs.append(NPC.new("나침반 제작자", "sage", 2, "nanhai"))
	region.npcs.append(NPC.new("어부 칼", "merchant", 1, "nanhai"))
	
	# 퀘스트 6개
	region.quests.append(RegionQuest.new("quest_nanhai_1", "해적 5명 격퇴", "해적 두목", 2))
	region.quests.append(RegionQuest.new("quest_nanhai_2", "보물지도 찾기", "상인 돌핀", 3))
	region.quests.append(RegionQuest.new("quest_nanhai_3", "바다괴물 격퇴", "어부 칼", 3))
	region.quests.append(RegionQuest.new("quest_nanhai_4", "주옥 3개 수집", "나침반 제작자", 2))
	region.quests.append(RegionQuest.new("quest_nanhai_5", "대량 물품 배달", "상인 돌핀", 2))
	region.quests.append(RegionQuest.new("quest_nanhai_6", "해양 부적 획득", "나침반 제작자", 3))
	
	regions["nanhai"] = region

func create_xiyou_region():
	"""서역 - 사막 지역, 난이도 2-3"""
	var region = Region.new("서역", "xiyou", "sand", 2)
	region.size = Vector3(330, 120, 330)
	
	# 건물 5개
	region.buildings.append(Building.new("대사원", "dojo", Vector3(0, 10, 70)))
	region.buildings.append(Building.new("오아시스", "inn", Vector3(60, 0, 50)))
	region.buildings.append(Building.new("암굴", "library", Vector3(-70, 0, 40)))
	region.buildings.append(Building.new("수도원", "dojo", Vector3(50, 0, -40)))
	region.buildings.append(Building.new("장터", "shop", Vector3(-60, 0, -50)))
	
	# 스포닝 포인트 12개
	for i in range(12):
		var angle = (i / 12.0) * TAU
		var pos = Vector3(cos(angle) * 95, 5, sin(angle) * 95)
		region.spawn_points.append(pos)
	
	# NPC 4명
	region.npcs.append(NPC.new("황금 도사", "master", 3, "xiyou"))
	region.npcs.append(NPC.new("카라반 주인", "merchant", 2, "xiyou"))
	region.npcs.append(NPC.new("사막 가이드", "sage", 2, "xiyou"))
	region.npcs.append(NPC.new("보물 사냥꾼", "merchant", 2, "xiyou"))
	
	# 퀨스트 6개
	region.quests.append(RegionQuest.new("quest_xiyou_1", "사막 도사 격퇴", "황금 도사", 2))
	region.quests.append(RegionQuest.new("quest_xiyou_2", "스콜핀 5마리 처치", "보물 사냥꾼", 2))
	region.quests.append(RegionQuest.new("quest_xiyou_3", "오아시스 물 가져오기", "카라반 주인", 1))
	region.quests.append(RegionQuest.new("quest_xiyou_4", "사막 보물 찾기", "사막 가이드", 3))
	region.quests.append(RegionQuest.new("quest_xiyou_5", "모래폭풍 극복", "황금 도사", 3))
	region.quests.append(RegionQuest.new("quest_xiyou_6", "비문 해석", "황금 도사", 2))
	
	regions["xiyou"] = region

func create_beifang_region():
	"""북방 - 산/설산 지역, 난이도 3-4"""
	var region = Region.new("북방", "beifang", "mountain", 4)
	region.size = Vector3(340, 200, 340)
	
	# 건물 5개
	region.buildings.append(Building.new("산봉우리 도장", "dojo", Vector3(0, 80, 70)))
	region.buildings.append(Building.new("고대 사찰", "library", Vector3(70, 50, 50)))
	region.buildings.append(Building.new("비밀 동굴", "dojo", Vector3(-80, 40, 40)))
	region.buildings.append(Building.new("산장", "inn", Vector3(50, 60, -40)))
	region.buildings.append(Building.new("약초 창고", "shop", Vector3(-60, 50, -50)))
	
	# 스포닝 포인트 13개
	for i in range(13):
		var angle = (i / 13.0) * TAU
		var y = sin(angle) * 20 + 40  # 높이 변동
		var pos = Vector3(cos(angle) * 100, y, sin(angle) * 100)
		region.spawn_points.append(pos)
	
	# NPC 4명
	region.npcs.append(NPC.new("노 도사", "master", 4, "beifang"))
	region.npcs.append(NPC.new("산 정령 보호자", "sage", 3, "beifang"))
	region.npcs.append(NPC.new("약초 채집꾼", "merchant", 2, "beifang"))
	region.npcs.append(NPC.new("비밀 수행자", "sage", 3, "beifang"))
	
	# 퀘스트 7개
	region.quests.append(RegionQuest.new("quest_beifang_1", "산 정령 격퇴", "산 정령 보호자", 3))
	region.quests.append(RegionQuest.new("quest_beifang_2", "거대 새 사냥", "산 정령 보호자", 4))
	region.quests.append(RegionQuest.new("quest_beifang_3", "약초 100개 수집", "약초 채집꾼", 2))
	region.quests.append(RegionQuest.new("quest_beifang_4", "산봉우리 제전", "노 도사", 4))
	region.quests.append(RegionQuest.new("quest_beifang_5", "비밀 경전 찾기", "비밀 수행자", 3))
	region.quests.append(RegionQuest.new("quest_beifang_6", "하늘 돌 수집", "노 도사", 3))
	region.quests.append(RegionQuest.new("quest_beifang_7", "최강 수련", "노 도사", 4))
	
	regions["beifang"] = region

# === 조회 함수들 ===

func get_region(region_id: String) -> Region:
	"""지역 ID로 지역 조회"""
	return regions.get(region_id)

func get_all_regions() -> Array:
	"""모든 지역 반환"""
	return regions.values()

func get_region_npcs(region_id: String) -> Array:
	"""지역의 NPC 목록"""
	var region = get_region(region_id)
	if region:
		return region.npcs
	return []

func get_region_quests(region_id: String) -> Array:
	"""지역의 퀘스트 목록"""
	var region = get_region(region_id)
	if region:
		return region.quests
	return []

func get_region_spawn_points(region_id: String) -> Array:
	"""지역의 적 스포닝 포인트"""
	var region = get_region(region_id)
	if region:
		return region.spawn_points
	return []

func get_region_buildings(region_id: String) -> Array:
	"""지역의 건물 목록"""
	var region = get_region(region_id)
	if region:
		return region.buildings
	return []

# === 통계 함수들 ===

func get_total_npc_count() -> int:
	"""전체 NPC 수"""
	var count = 0
	for region in regions.values():
		count += region.npcs.size()
	return count

func get_total_quest_count() -> int:
	"""전체 퀘스트 수"""
	var count = 0
	for region in regions.values():
		count += region.quests.size()
	return count

func print_region_summary():
	"""전체 지역 요약 출력"""
	print("\n=== 지역 요약 ===")
	for region in regions.values():
		print("지역: %s (ID: %s)" % [region.name, region.id])
		print("  - 난이도: %d" % [region.difficulty])
		print("  - 크기: %s" % [region.size])
		print("  - 건물: %d개" % [region.buildings.size()])
		print("  - NPC: %d명" % [region.npcs.size()])
		print("  - 퀘스트: %d개" % [region.quests.size()])
		print("  - 스포닝: %d포인트" % [region.spawn_points.size()])
	
	print("\n=== 전체 통계 ===")
	print("총 지역: %d개" % [regions.size()])
	print("총 NPC: %d명" % [get_total_npc_count()])
	print("총 퀘스트: %d개" % [get_total_quest_count()])
