# NEXUS 던전 생성 엔진
# 절차적 던전 생성 (Procedural Dungeon Generation)
# 지역 데이터를 기반으로 던전 레이아웃 자동 생성

extends Node

class_name DungeonGenerator

# ============================================================================
# 상수
# ============================================================================

enum DungeonType {
	CAVE = 0,
	TEMPLE = 1,
	CRYPT = 2,
	TOWER = 3,
}

const ROOM_SIZE_MIN = 8
const ROOM_SIZE_MAX = 20
const CORRIDOR_WIDTH = 2

# ============================================================================
# 데이터 구조
# ============================================================================

class Room:
	var id: String
	var x: int
	var y: int
	var width: int
	var height: int
	var room_type: String # "normal", "boss", "treasure", "safe"
	var monsters: Array[String] = []
	var enemies: int = 0
	var loot: Array[String] = []
	
	func _init(p_id: String, p_x: int, p_y: int, p_w: int, p_h: int):
		id = p_id
		x = p_x
		y = p_y
		width = p_w
		height = p_h
		room_type = "normal"

class Dungeon:
	var dungeon_id: String
	var dungeon_name: String
	var floors: int
	var rooms: Array[Room] = []
	var corridors: Array[Dictionary] = []
	var difficulty: int
	var boss_floor: int
	var boss_name: String
	var boss_ai_level: int
	var boss_hp: float
	
	func _init(p_id: String, p_name: String, p_floors: int, p_diff: int):
		dungeon_id = p_id
		dungeon_name = p_name
		floors = p_floors
		difficulty = p_diff
		boss_floor = p_floors

# ============================================================================
# 던전 생성 함수
# ============================================================================

## 던전 데이터를 바탕으로 던전 생성
func generate_dungeon(dungeon_data: Dictionary) -> Dungeon:
	var dungeon = Dungeon.new(
		dungeon_data["dungeon_id"],
		dungeon_data["dungeon_name"],
		dungeon_data["floors"],
		dungeon_data["difficulty"]
	)
	
	dungeon.boss_floor = dungeon_data["boss_floor"]
	dungeon.boss_name = dungeon_data["boss_name"]
	dungeon.boss_ai_level = dungeon_data["boss_ai_level"]
	dungeon.boss_hp = dungeon_data["boss_hp"]
	
	# 각 층별로 방 생성
	for floor in range(1, dungeon.floors + 1):
		var rooms_per_floor = dungeon_data["rooms_per_floor"]
		_generate_floor(dungeon, floor, rooms_per_floor)
	
	return dungeon

## 던전 한 층 생성 (방 + 복도)
func _generate_floor(dungeon: Dungeon, floor: int, room_count: int) -> void:
	var map_width = 100
	var map_height = 100
	
	# 방 배치
	var rooms: Array[Room] = []
	for i in range(room_count):
		var room_width = randi_range(ROOM_SIZE_MIN, ROOM_SIZE_MAX)
		var room_height = randi_range(ROOM_SIZE_MIN, ROOM_SIZE_MAX)
		
		# 랜덤 위치 찾기 (겹치지 않도록)
		var x = randi_range(0, map_width - room_width)
		var y = randi_range(0, map_height - room_height)
		
		var room = Room.new("F%d_R%d" % [floor, i + 1], x, y, room_width, room_height)
		
		# 방 타입 결정
		if floor == dungeon.boss_floor and i == room_count - 1:
			room.room_type = "boss"
			room.enemies = 1 # 보스만
		elif randf() < 0.2:
			room.room_type = "treasure"
			room.enemies = randi_range(1, 3)
		elif randf() < 0.3:
			room.room_type = "safe"
			room.enemies = 0
		else:
			room.room_type = "normal"
			room.enemies = randi_range(2, 5)
		
		# 몬스터 배치 (난이도에 따라)
		_place_monsters(room, dungeon.difficulty)
		
		rooms.append(room)
		dungeon.rooms.append(room)
	
	# 복도 연결 (인접한 방들끼리)
	_connect_rooms(dungeon, rooms)

## 방에 몬스터 배치
func _place_monsters(room: Room, difficulty: int) -> void:
	var monster_types = ["goblin", "orc", "skeleton", "zombie", "demon"]
	
	for i in range(room.enemies):
		var monster_type = monster_types[difficulty % monster_types.size()]
		room.monsters.append(monster_type)
	
	# 보스 방에는 보스만
	if room.room_type == "boss":
		room.monsters.clear()
		room.monsters.append("boss")

## 방들을 복도로 연결
func _connect_rooms(dungeon: Dungeon, rooms: Array[Room]) -> void:
	# 간단한 연결: 인접한 방들끼리 연결
	for i in range(rooms.size() - 1):
		var from_room = rooms[i]
		var to_room = rooms[i + 1]
		
		var corridor = {
			"from": from_room.id,
			"to": to_room.id,
			"from_pos": Vector2(from_room.x + from_room.width / 2, from_room.y + from_room.height / 2),
			"to_pos": Vector2(to_room.x + to_room.width / 2, to_room.y + to_room.height / 2),
		}
		dungeon.corridors.append(corridor)

# ============================================================================
# 던전 정보 출력
# ============================================================================

func print_dungeon(dungeon: Dungeon) -> void:
	print("\n" + "=" * 60)
	print("[%s] %s" % [dungeon.dungeon_id, dungeon.dungeon_name])
	print("=" * 60)
	print("난이도: %d | 층: %d | 방: %d개" % [dungeon.difficulty, dungeon.floors, dungeon.rooms.size()])
	print("보스: %s (AI Level: %d, HP: %.0f)" % [dungeon.boss_name, dungeon.boss_ai_level, dungeon.boss_hp])
	print("\n[방 목록]")
	
	var current_floor = 1
	for room in dungeon.rooms:
		var floor = int(room.id.split("_")[0].substr(1))
		if floor > current_floor:
			current_floor = floor
			print("\n--- Floor %d ---" % floor)
		
		print("  %s (%dx%d) | 타입: %s | 몬스터: %d" % 
			[room.id, room.width, room.height, room.room_type, room.enemies])
		if not room.monsters.is_empty():
			print("    → %s" % ", ".join(PackedStringArray(room.monsters)))
	
	print("\n" + "=" * 60 + "\n")

# ============================================================================
# 테스트
# ============================================================================

func test_dungeon_generation() -> void:
	print("\n🏛️ 던전 생성 테스트")
	print("=" * 60)
	
	# 테스트 데이터
	var dungeon_data = {
		"dungeon_id": "tutorial_cave",
		"dungeon_name": "시작 동굴",
		"floors": 3,
		"rooms_per_floor": 8,
		"difficulty": 1,
		"boss_floor": 3,
		"boss_name": "보스",
		"boss_ai_level": 2,
		"boss_hp": 100,
	}
	
	var dungeon = generate_dungeon(dungeon_data)
	print_dungeon(dungeon)

func _ready() -> void:
	test_dungeon_generation()
