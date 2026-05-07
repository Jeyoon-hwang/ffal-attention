# dungeon_generator.gd - 던전 생성 및 관리 시스템
# Week 2: 70개 던전 자동 생성
# 각 던전은 여러 층과 방, 적, 보스를 포함

extends Node

# 던전 클래스
class Dungeon:
	var id: String
	var name: String
	var type: String  # "cave", "tower", "temple", "ruin", "tomb"
	var region_id: String
	var difficulty: int  # 1-4
	var entrance_position: Vector3
	
	var layers: int  # 3-5
	var rooms_per_layer: Array  # 각 층의 방 개수
	var enemies: Array = []
	var minibosses: Array = []  # 소형 보스
	var boss: String  # 보스 이름
	var loot: Dictionary = {}  # 보상
	var completion_reward: Dictionary = {}  # 클리어 보상
	
	func _init(p_id: String, p_name: String, p_type: String, p_region: String, p_difficulty: int):
		id = p_id
		name = p_name
		type = p_type
		region_id = p_region
		difficulty = p_difficulty
		
		# 난이도별 층 개수
		layers = 3 + difficulty
		
		# 각 층의 방 개수 (3-15)
		rooms_per_layer = []
		for i in range(layers):
			rooms_per_layer.append(5 + i * 2)

class DungeonRoom:
	var floor: int
	var room_id: int
	var enemies: Array = []
	var treasure: Array = []  # 아이템
	var connections: Array = []  # 다른 방으로의 연결
	
	func _init(p_floor: int, p_room_id: int):
		floor = p_floor
		room_id = p_room_id

class DungeonEnemy:
	var name: String
	var level: int
	var count: int  # 몇 마리
	var weight: float  # 생성 가중치 (0.0-1.0)
	
	func _init(p_name: String, p_level: int, p_count: int, p_weight: float = 0.5):
		name = p_name
		level = p_level
		count = p_count
		weight = p_weight

# 모든 던전 저장소
var dungeons: Dictionary = {}

# 지역별 던전 수
var dungeons_per_region = {
	"zhongyuan": 10,
	"dongtu": 14,
	"nanhai": 14,
	"xiyou": 14,
	"beifang": 18
}

# 던전 타입별 특성
var dungeon_types = {
	"cave": {
		"color": "갈색",
		"terrain": "동굴",
		"enemies": ["박쥐", "거미", "곰", "랜돌"],
		"bosses": ["거대 거미", "검은 베어", "동굴 정령"]
	},
	"tower": {
		"color": "회색",
		"terrain": "탑",
		"enemies": ["수도사", "검사", "마법사", "수호자"],
		"bosses": ["탑의 수호자", "마법 방어자", "탑 마스터"]
	},
	"temple": {
		"color": "흰색",
		"terrain": "사찰",
		"enemies": ["아수라", "귀신", "유령", "축복받지 않은자"],
		"bosses": ["사찰 보호자", "신성한 존재", "아수라 왕"]
	},
	"ruin": {
		"color": "검은색",
		"terrain": "폐허",
		"enemies": ["해골병사", "저주받은 영혼", "고대 로봇", "어둠의 사자"],
		"bosses": ["고대의 왕", "저주의 화신", "폐허의 주인"]
	},
	"tomb": {
		"color": "보라색",
		"terrain": "무덤",
		"enemies": ["미라", "영혼", "석상", "무기 정령"],
		"bosses": ["무덤의 파라오", "영혼의 왕", "부활한 군왕"]
	}
}

func _ready():
	generate_all_dungeons()
	print_dungeon_summary()

# === 던전 생성 함수들 ===

func generate_all_dungeons():
	"""모든 70개 던전 자동 생성"""
	
	var total = 0
	
	# 중원: 10개
	generate_region_dungeons("zhongyuan", 10, 1, 2)
	total += 10
	
	# 동토: 14개
	generate_region_dungeons("dongtu", 14, 2, 3)
	total += 14
	
	# 남해: 14개
	generate_region_dungeons("nanhai", 14, 2, 3)
	total += 14
	
	# 서역: 14개
	generate_region_dungeons("xiyou", 14, 2, 3)
	total += 14
	
	# 북방: 18개
	generate_region_dungeons("beifang", 18, 3, 4)
	total += 18
	
	print("[Dungeon Generator] %d개 던전 생성 완료" % total)

func generate_region_dungeons(region_id: String, count: int, min_diff: int, max_diff: int):
	"""지역별 던전 생성"""
	
	var types_list = dungeon_types.keys()
	var type_index = 0
	var position_offset = 0
	
	for i in range(count):
		# 던전 타입 순회
		var dungeon_type = types_list[type_index % types_list.size()]
		type_index += 1
		
		# 난이도 (최소~최대 사이 랜덤)
		var difficulty = randi_range(min_diff, max_diff)
		
		# 던전 ID와 이름
		var dungeon_id = "%s_dg_%d" % [region_id, i + 1]
		var type_name = dungeon_types[dungeon_type]["terrain"]
		var dungeon_name = "%s - %s %d" % [region_id.to_upper(), type_name, i + 1]
		
		# 입구 위치 (지역 주변)
		var angle = (i / float(count)) * TAU
		var entrance_pos = Vector3(
			cos(angle) * 150 + position_offset,
			10 + difficulty * 5,
			sin(angle) * 150 + position_offset
		)
		position_offset += 5
		
		# 던전 생성
		var dungeon = Dungeon.new(dungeon_id, dungeon_name, dungeon_type, region_id, difficulty)
		dungeon.entrance_position = entrance_pos
		
		# 적 설정
		setup_dungeon_enemies(dungeon, dungeon_type, difficulty)
		
		# 보스 설정
		var boss_options = dungeon_types[dungeon_type]["bosses"]
		dungeon.boss = boss_options[randi() % boss_options.size()]
		
		# 보상 설정
		var base_exp = 100 * difficulty
		var base_gold = 50 * difficulty
		dungeon.completion_reward = {
			"exp": base_exp + randi_range(-20, 50),
			"gold": base_gold + randi_range(-10, 30),
			"items": difficulty
		}
		
		dungeons[dungeon_id] = dungeon

func setup_dungeon_enemies(dungeon: Dungeon, dungeon_type: String, difficulty: int):
	"""던전의 적 설정"""
	
	var enemy_names = dungeon_types[dungeon_type]["enemies"]
	
	# 기본 적들
	for enemy_name in enemy_names:
		var level = difficulty + randi_range(0, 2)
		var count = randi_range(3, 8)
		var weight = randf_range(0.3, 0.8)
		dungeon.enemies.append(DungeonEnemy.new(enemy_name, level, count, weight))
	
	# 소형 보스 (층마다 1개)
	for layer in range(dungeon.layers):
		if layer < dungeon.enemies.size():
			var miniboss = dungeon.enemies[layer]
			dungeon.minibosses.append({
				"name": miniboss.name + " 상급",
				"level": miniboss.level + 2,
				"floor": layer + 1
			})

# === 던전 조회 함수들 ===

func get_dungeon(dungeon_id: String) -> Dungeon:
	"""던전 ID로 던전 조회"""
	return dungeons.get(dungeon_id)

func get_all_dungeons() -> Array:
	"""모든 던전 반환"""
	return dungeons.values()

func get_region_dungeons(region_id: String) -> Array:
	"""지역별 던전 목록"""
	var result = []
	for dungeon in dungeons.values():
		if dungeon.region_id == region_id:
			result.append(dungeon)
	return result

func get_dungeons_by_type(dungeon_type: String) -> Array:
	"""타입별 던전 목록"""
	var result = []
	for dungeon in dungeons.values():
		if dungeon.type == dungeon_type:
			result.append(dungeon)
	return result

func get_dungeons_by_difficulty(difficulty: int) -> Array:
	"""난이도별 던전 목록"""
	var result = []
	for dungeon in dungeons.values():
		if dungeon.difficulty == difficulty:
			result.append(dungeon)
	return result

# === 던전 통계 함수들 ===

func get_total_dungeon_count() -> int:
	"""전체 던전 수"""
	return dungeons.size()

func get_dungeon_count_by_region(region_id: String) -> int:
	"""지역별 던전 수"""
	return get_region_dungeons(region_id).size()

func get_dungeon_count_by_type(dungeon_type: String) -> int:
	"""타입별 던전 수"""
	return get_dungeons_by_type(dungeon_type).size()

func get_dungeon_count_by_difficulty(difficulty: int) -> int:
	"""난이도별 던중 수"""
	return get_dungeons_by_difficulty(difficulty).size()

func print_dungeon_summary():
	"""전체 던중 요약 출력"""
	print("\n=== 던중 요약 ===")
	
	# 지역별
	print("\n[지역별 던중]")
	for region_id in dungeons_per_region.keys():
		var count = get_dungeon_count_by_region(region_id)
		print("  %s: %d개" % [region_id, count])
	
	# 타입별
	print("\n[타입별 던중]")
	for dungeon_type in dungeon_types.keys():
		var count = get_dungeon_count_by_type(dungeon_type)
		print("  %s: %d개" % [dungeon_type, count])
	
	# 난이도별
	print("\n[난이도별 던중]")
	for difficulty in range(1, 5):
		var count = get_dungeon_count_by_difficulty(difficulty)
		print("  Level %d: %d개" % [difficulty, count])
	
	# 전체
	print("\n=== 전체 통계 ===")
	print("총 던중: %d개" % [get_total_dungeon_count()])

func print_dungeon_details(dungeon_id: String):
	"""특정 던중의 상세 정보 출력"""
	var dungeon = get_dungeon(dungeon_id)
	if not dungeon:
		print("[ERROR] 던중을 찾을 수 없음: %s" % dungeon_id)
		return
	
	print("\n=== 던중 상세정보: %s ===" % dungeon.name)
	print("ID: %s" % dungeon.id)
	print("타입: %s" % dungeon.type)
	print("지역: %s" % dungeon.region_id)
	print("난이도: %d" % dungeon.difficulty)
	print("층: %d" % dungeon.layers)
	print("입구: %s" % dungeon.entrance_position)
	print("\n[적]")
	for enemy in dungeon.enemies:
		print("  - %s (Level %d, %d마리, 가중치 %.1f)" % [enemy.name, enemy.level, enemy.count, enemy.weight])
	print("\n[소형 보스]")
	for miniboss in dungeon.minibosses:
		print("  - %s (Layer %d, Level %d)" % [miniboss.name, miniboss.floor, miniboss.level])
	print("\n[최종 보스]")
	print("  - %s" % dungeon.boss)
	print("\n[보상]")
	print("  - 경험치: %d" % dungeon.completion_reward["exp"])
	print("  - 골드: %d" % dungeon.completion_reward["gold"])
	print("  - 아이템: %d개" % dungeon.completion_reward["items"])
