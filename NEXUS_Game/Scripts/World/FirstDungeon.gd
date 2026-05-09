## FirstDungeon.gd - 첫 던전 (중원)
##
## 첫 번째 던전: "첫 던전" (중원 지역)
## 난이도: 1-10 레벨
## 구성: 3개 전투 방 + 1개 보스 방

extends Node3D

class_name FirstDungeon

# 던전 기본 정보
var dungeon_name: String = "첫 던전"
var dungeon_id: String = "first_dungeon_01"
var dungeon_level: int = 1
var required_player_level: int = 1
var max_player_level: int = 10

# 던전 방들
var rooms: Array[DungeonRoom] = []
var current_room_index: int = 0

# 던전 상태
var is_cleared: bool = false
var clear_count: int = 0

func _ready() -> void:
	"""초기화"""
	initialize_dungeon()

## 던전 초기화
func initialize_dungeon() -> void:
	"""던전의 모든 방 초기화"""
	
	# 방 1: 입구 (무술 수련생 1명)
	var room1 = DungeonRoom.new()
	room1.room_name = "입구"
	room1.room_index = 0
	room1.room_type = "combat"
	room1.enemy_type = "무술 수련생"
	room1.enemy_count = 1
	room1.enemy_level = 1
	room1.treasure_rewards = {
		"experience": 50,
		"gold": 20,
		"items": []
	}
	rooms.append(room1)
	
	# 방 2: 복도 (무술 수련생 2명)
	var room2 = DungeonRoom.new()
	room2.room_name = "복도"
	room2.room_index = 1
	room2.room_type = "combat"
	room2.enemy_type = "무술 수련생"
	room2.enemy_count = 2
	room2.enemy_level = 1
	room2.treasure_rewards = {
		"experience": 80,
		"gold": 30,
		"items": []
	}
	rooms.append(room2)
	
	# 방 3: 훈련장 (무술 감독 1명)
	var room3 = DungeonRoom.new()
	room3.room_name = "훈련장"
	room3.room_index = 2
	room3.room_type = "combat"
	room3.enemy_type = "무술 감독"
	room3.enemy_count = 1
	room3.enemy_level = 2
	room3.treasure_rewards = {
		"experience": 100,
		"gold": 50,
		"items": []
	}
	rooms.append(room3)
	
	# 방 4: 단련실 (최종 보스)
	var room4 = DungeonRoom.new()
	room4.room_name = "단련실"
	room4.room_index = 3
	room4.room_type = "boss"
	room4.is_boss_room = true
	room4.boss_name = "천산 검객"
	room4.boss_level = 10
	room4.treasure_rewards = {
		"experience": 500,
		"gold": 200,
		"items": []
	}
	rooms.append(room4)
	
	print("[FirstDungeon] '%s' 던전 초기화 완료!" % dungeon_name)
	print("  • 총 방: %d개 (전투 3 + 보스 1)" % rooms.size())

## 던전 진입
func enter_dungeon(player: Node) -> void:
	"""플레이어가 던전에 진입"""
	print("\n[FirstDungeon] '%s'에 진입했습니다!" % dungeon_name)
	print("  • 권장 레벨: %d~%d" % [required_player_level, max_player_level])
	
	current_room_index = 0
	enter_next_room(player)

## 다음 방으로 이동
func enter_next_room(player: Node) -> void:
	"""다음 방으로 이동"""
	if current_room_index < rooms.size():
		var current_room = rooms[current_room_index]
		current_room.enter_room(player)
		print("[FirstDungeon] %d번 방: %s" % [current_room_index + 1, current_room.room_name])
	else:
		# 모든 방 클리어
		complete_dungeon()

## 현재 방 클리어 확인
func check_current_room_cleared(player: Node) -> bool:
	"""현재 방 클리어 여부 확인"""
	if current_room_index < rooms.size():
		var current_room = rooms[current_room_index]
		if current_room.check_cleared(player):
			current_room.give_rewards(player)
			current_room_index += 1
			
			# 다음 방으로 진행
			if current_room_index < rooms.size():
				print("\n[FirstDungeon] 다음 방으로 진행...")
				enter_next_room(player)
			else:
				complete_dungeon()
			
			return true
	
	return false

## 던전 완료
func complete_dungeon() -> void:
	"""던전 완료"""
	is_cleared = true
	clear_count += 1
	
	print("\n" + "="*50)
	print("✨ '%s' 던전을 클리어했습니다!" % dungeon_name)
	print("="*50)
	print("클리어 횟수: %d회" % clear_count)

## 모든 방 정보 출력
func print_dungeon_info() -> void:
	"""던전 정보 출력"""
	print("\n" + "="*50)
	print("📜 던전 정보: %s" % dungeon_name)
	print("="*50)
	print("ID: %s" % dungeon_id)
	print("권장 레벨: %d~%d" % [required_player_level, max_player_level])
	print("상태: %s" % ("클리어됨 (%d회)" % clear_count if is_cleared else "미클리어"))
	print("\n[방 목록]")
	
	for i in range(rooms.size()):
		var room = rooms[i]
		print("\n%d. %s" % [i + 1, room.room_name])
		
		if room.is_boss_room:
			print("   보스: %s (Lv.%d)" % [room.boss_name, room.boss_level])
		else:
			print("   적: %s x %d (Lv.%d)" % [room.enemy_type, room.enemy_count, room.enemy_level])
		
		print("   상태: %s" % ("클리어" if room.is_cleared else "미방문"))
		print("   보상: 경험치 %d, 골드 %d" % [
			room.treasure_rewards["experience"],
			room.treasure_rewards["gold"]
		])

## 던전 초기화 (다시 플레이)
func reset() -> void:
	"""던전 초기화 (다시 플레이)"""
	print("[FirstDungeon] '%s'를 초기화합니다..." % dungeon_name)
	
	for room in rooms:
		room.reset()
	
	current_room_index = 0
	is_cleared = false
	
	print("[FirstDungeon] 초기화 완료. 다시 진입 가능합니다.")

## 통계 정보
func get_statistics() -> Dictionary:
	"""던전 통계 반환"""
	var total_exp = 0
	var total_gold = 0
	var total_enemies = 0
	
	for room in rooms:
		total_exp += room.treasure_rewards["experience"]
		total_gold += room.treasure_rewards["gold"]
		if not room.is_boss_room:
			total_enemies += room.enemy_count
	
	return {
		"dungeon_name": dungeon_name,
		"total_rooms": rooms.size(),
		"total_enemies": total_enemies,
		"boss_name": rooms[rooms.size() - 1].boss_name,
		"total_experience": total_exp,
		"total_gold": total_gold,
		"playtime_estimate": "15-20분",
		"difficulty": "쉬움 (초보자)"
	}

## 던전 시뮬레이션 (테스트용)
func simulate_dungeon() -> void:
	"""던전 전체 자동 시뮬레이션"""
	print("\n" + "="*50)
	print("🎮 던전 시뮬레이션 시작: %s" % dungeon_name)
	print("="*50 + "\n")
	
	var stats = get_statistics()
	
	print("[시뮬레이션 정보]")
	print("  • 던전명: %s" % stats["dungeon_name"])
	print("  • 총 방: %d개" % stats["total_rooms"])
	print("  • 예상 적: %d마리" % stats["total_enemies"])
	print("  • 최종 보스: %s" % stats["boss_name"])
	print("  • 예상 보상: 경험치 %d, 골드 %d" % [
		stats["total_experience"],
		stats["total_gold"]
	])
	print("  • 예상 플레이타임: %s" % stats["playtime_estimate"])
	print("  • 난이도: %s\n" % stats["difficulty"])
	
	# 각 방을 자동으로 통과
	for i in range(rooms.size()):
		var room = rooms[i]
		print("[방 %d: %s]" % [i + 1, room.room_name])
		
		if room.is_boss_room:
			print("  ⚔️  보스 전투: %s (Lv.%d)" % [room.boss_name, room.boss_level])
		else:
			print("  🗡️  적 전투: %s x %d (Lv.%d)" % [room.enemy_type, room.enemy_count, room.enemy_level])
		
		print("  📊 보상: 경험치 %d, 골드 %d" % [
			room.treasure_rewards["experience"],
			room.treasure_rewards["gold"]
		])
		print("  ✅ 클리어!\n")
	
	is_cleared = true
	clear_count += 1
	
	print("="*50)
	print("✨ 던전 클리어! (클리어 횟수: %d)" % clear_count)
	print("="*50)
