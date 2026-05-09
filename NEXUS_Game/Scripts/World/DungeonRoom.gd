## DungeonRoom.gd - 던전 방 (기초 클래스)
## 
## 던전 내의 개별 방을 나타냅니다.
## 각 방은 몬스터와 함정, 보물 등을 포함할 수 있습니다.

extends Node3D

class_name DungeonRoom

# 방 기본 정보
var room_name: String = "방"
var room_index: int = 0
var room_type: String = "combat"  # "combat", "treasure", "boss", "corridor"

# 적 정보
var enemy_type: String = ""
var enemy_count: int = 1
var enemy_level: int = 1
var enemies: Array = []

# 보스 정보
var is_boss_room: bool = false
var boss_name: String = ""
var boss_level: int = 1
var boss_instance = null

# 상태
var is_cleared: bool = false
var is_visited: bool = false

# 보물/보상
var treasure_rewards: Dictionary = {
	"experience": 0,
	"gold": 0,
	"items": []
}

func _ready() -> void:
	"""초기화"""
	pass

## 방에 진입할 때 호출
func enter_room(player: Node) -> void:
	"""방에 진입"""
	print("[DungeonRoom] %s에 진입했습니다." % room_name)
	is_visited = true
	
	if not is_cleared:
		if is_boss_room:
			spawn_boss()
		else:
			spawn_enemies()

## 몬스터 생성
func spawn_enemies() -> void:
	"""적 생성"""
	print("[DungeonRoom] %s x %d을(를) 소환했습니다." % [enemy_type, enemy_count])
	
	for i in range(enemy_count):
		# 적 인스턴스 생성 (Enemy 클래스 사용)
		var enemy = Enemy.new()
		enemy.name = "%s_%d" % [enemy_type, i + 1]
		enemy.level = enemy_level
		enemies.append(enemy)

## 보스 생성
func spawn_boss() -> void:
	"""보스 생성"""
	print("[DungeonRoom] %s (Lv.%d)을(를) 소환했습니다!" % [boss_name, boss_level])
	
	# FirstBoss 또는 다른 보스 클래스 인스턴스 생성
	# (나중에 보스별로 다르게 처리)
	boss_instance = FirstBoss.new()
	boss_instance.name = boss_name
	boss_instance.level = boss_level

## 방 클리어 확인
func check_cleared(player: Node) -> bool:
	"""방 클리어 여부 확인"""
	if is_boss_room:
		# 보스 전투 확인
		if boss_instance and boss_instance.current_hp <= 0:
			is_cleared = true
			return true
	else:
		# 모든 적이 죽었는지 확인
		var all_dead = true
		for enemy in enemies:
			if enemy.current_hp > 0:
				all_dead = false
				break
		
		if all_dead:
			is_cleared = true
			return true
	
	return false

## 클리어 시 보상 지급
func give_rewards(player: Node) -> void:
	"""클리어 시 보상 지급"""
	if is_cleared:
		print("[DungeonRoom] 보상을 획득했습니다!")
		print("  • 경험치: %d" % treasure_rewards["experience"])
		print("  • 골드: %d" % treasure_rewards["gold"])
		
		# 플레이어에게 보상 지급 (나중에 연결)
		# player.add_experience(treasure_rewards["experience"])
		# player.add_gold(treasure_rewards["gold"])

## 방 정보 출력
func print_room_info() -> void:
	"""방 정보 출력"""
	print("\n[DungeonRoom] %s" % room_name)
	print("  • 타입: %s" % room_type)
	
	if is_boss_room:
		print("  • 보스: %s (Lv.%d)" % [boss_name, boss_level])
	else:
		print("  • 적: %s x %d (Lv.%d)" % [enemy_type, enemy_count, enemy_level])
	
	print("  • 상태: %s" % ("클리어됨" if is_cleared else "미방문"))
	print("  • 보상: 경험치 %d, 골드 %d" % [
		treasure_rewards["experience"],
		treasure_rewards["gold"]
	])

## 방 초기화 (다음 회차)
func reset() -> void:
	"""방 초기화 (다음 회차)"""
	is_cleared = false
	is_visited = false
	enemies.clear()
	boss_instance = null
	print("[DungeonRoom] %s가 초기화되었습니다." % room_name)
