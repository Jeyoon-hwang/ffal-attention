# 오픈월드 관리자 (Open World Manager)
# 100km² 오픈월드 관리

extends Node3D

class Region:
	var name: String
	var position: Vector3
	var size: Vector2  # 가로, 세로
	var terrain_type: String
	var landmarks: Array = []
	var npcs: Array = []
	var dungeons: Array = []
	var weather: String = "맑음"
	var time_of_day: float = 12.0  # 0-24
	
	func _init(p_name: String, p_position: Vector3, p_size: Vector2, p_terrain: String):
		name = p_name
		position = p_position
		size = p_size
		terrain_type = p_terrain

class Landmark:
	var name: String
	var position: Vector3
	var landmark_type: String  # 마을, 사원, 유적 등
	var description: String
	var discovered: bool = false
	var items: Array = []  # 고서, 무술 요소 등
	var npcs_here: Array = []
	
	func _init(p_name: String, p_position: Vector3, p_type: String):
		name = p_name
		position = p_position
		landmark_type = p_type

class Dungeon:
	var name: String
	var position: Vector3
	var difficulty: int  # 1-100
	var floors: int
	var enemies: Array = []
	var boss: String = ""
	var rewards: Array = []
	var cleared: bool = false
	
	func _init(p_name: String, p_position: Vector3, p_difficulty: int):
		name = p_name
		position = p_position
		difficulty = p_difficulty

# 월드 데이터
var world_size = Vector2(100000, 100000)  # 100km²
var regions: Array[Region] = []
var all_landmarks: Array[Landmark] = []
var all_dungeons: Array[Dungeon] = []

var player_position: Vector3 = Vector3.ZERO
var current_region: Region = null

# 시간 & 날씨 시스템
var world_time: float = 12.0  # 0-24시간
var world_day: int = 1
var current_weather: String = "맑음"
var time_speed: float = 0.1  # 분당 경과 시간

func _ready():
	generate_world()

# 월드 생성
func generate_world():
	print("🌍 오픈월드 생성 중...")
	
	# 5개 지역 생성
	create_regions()
	
	# 랜드마크 배치 (500개)
	generate_landmarks()
	
	# 던전 생성 (50개)
	generate_dungeons()
	
	print("✅ 오픈월드 생성 완료")
	print("  - 지역: %d개" % regions.size())
	print("  - 랜드마크: %d개" % all_landmarks.size())
	print("  - 던전: %d개" % all_dungeons.size())

# 지역 생성
func create_regions():
	# 중원 (메인 지역)
	regions.append(Region.new("중원", Vector3(25000, 0, 25000), Vector2(50000, 50000), "평원"))
	
	# 서역 (사막)
	regions.append(Region.new("서역", Vector3(-25000, 0, 25000), Vector2(30000, 30000), "사막"))
	
	# 남해 (섬)
	regions.append(Region.new("남해", Vector3(25000, 0, -25000), Vector2(30000, 30000), "수중"))
	
	# 북국 (설산)
	regions.append(Region.new("북국", Vector3(-25000, 0, -25000), Vector2(30000, 30000), "산"))
	
	# 동녕 (미스터리)
	regions.append(Region.new("동녕", Vector3(0, 0, 0), Vector2(20000, 20000), "숲"))

# 랜드마크 생성 (500개)
func generate_landmarks():
	var landmark_count = 0
	
	# 지역당 랜드마크 배치
	for region in regions:
		var landmarks_per_region = 100
		
		for i in range(landmarks_per_region):
			var x = region.position.x + randf_range(-region.size.x/2, region.size.x/2)
			var z = region.position.z + randf_range(-region.size.y/2, region.size.y/2)
			var pos = Vector3(x, 0, z)
			
			# 랜드마크 타입 랜덤 선택
			var types = ["도시", "마을", "사원", "유적", "산", "폭포", "호수"]
			var type = types[randi() % types.size()]
			
			var landmark = Landmark.new(
				region.name + " %s %d" % [type, i],
				pos,
				type
			)
			
			all_landmarks.append(landmark)
			region.landmarks.append(landmark)
			landmark_count += 1
	
	print("  랜드마크 %d개 배치 완료" % landmark_count)

# 던전 생성 (50개)
func generate_dungeons():
	for i in range(50):
		var region = regions[randi() % regions.size()]
		var x = region.position.x + randf_range(-region.size.x/2, region.size.x/2)
		var z = region.position.z + randf_range(-region.size.y/2, region.size.y/2)
		var pos = Vector3(x, 0, z)
		
		var difficulty = randi() % 100 + 1  # 1-100
		var dungeon = Dungeon.new(
			"던전-%d" % i,
			pos,
			difficulty
		)
		
		dungeon.floors = (difficulty / 20) + 1
		dungeon.rewards = generate_dungeon_rewards(difficulty)
		
		all_dungeons.append(dungeon)

# 던전 보상 생성
func generate_dungeon_rewards(difficulty: int) -> Array:
	var rewards = []
	var reward_count = (difficulty / 20) + 1
	
	for i in range(reward_count):
		var reward_type = ["무술요소", "고서", "장비", "금전"][randi() % 4]
		rewards.append({
			"type": reward_type,
			"value": difficulty * 10
		})
	
	return rewards

func _process(delta):
	# 시간 경과
	world_time += delta * time_speed
	if world_time >= 24:
		world_time = 0
		world_day += 1

# 플레이어 이동 (오픈월드 스트리밍)
func move_player(new_position: Vector3):
	player_position = new_position
	
	# 현재 지역 결정
	for region in regions:
		var rel_x = new_position.x - region.position.x
		var rel_z = new_position.z - region.position.z
		
		if abs(rel_x) < region.size.x/2 and abs(rel_z) < region.size.y/2:
			current_region = region
			break
	
	# 스트리밍: 근처 랜드마크만 로드
	stream_nearby_landmarks()

# 근처 랜드마크 스트리밍 (성능 최적화)
func stream_nearby_landmarks(load_radius: float = 10000.0):
	if current_region == null:
		return
	
	for landmark in current_region.landmarks:
		var distance = player_position.distance_to(landmark.position)
		
		if distance < load_radius:
			landmark.discovered = true
		# 먼 거리는 언로드 (메모리 절약)

# 주변 랜드마크 조회
func get_nearby_landmarks(radius: float = 5000.0) -> Array:
	var nearby = []
	
	for landmark in all_landmarks:
		if player_position.distance_to(landmark.position) < radius:
			nearby.append(landmark)
	
	return nearby

# 주변 던전 조회
func get_nearby_dungeons(radius: float = 5000.0) -> Array:
	var nearby = []
	
	for dungeon in all_dungeons:
		if player_position.distance_to(dungeon.position) < radius:
			nearby.append(dungeon)
	
	return nearby

# 시간대별 설명
func get_time_of_day_description() -> String:
	if world_time >= 5 and world_time < 9:
		return "새벽"
	elif world_time >= 9 and world_time < 12:
		return "아침"
	elif world_time >= 12 and world_time < 15:
		return "오후"
	elif world_time >= 15 and world_time < 18:
		return "저녁"
	elif world_time >= 18 and world_time < 21:
		return "해질녘"
	else:
		return "밤"

# 날씨 변경
func change_weather(new_weather: String):
	current_weather = new_weather
	print("날씨 변경: %s" % new_weather)

# 월드 정보 출력
func print_world_info():
	print("\n=== 오픈월드 정보 ===")
	print("월드 크기: %.0f × %.0f km²" % [world_size.x/1000, world_size.y/1000])
	print("지역: %d개" % regions.size())
	print("랜드마크: %d개" % all_landmarks.size())
	print("던전: %d개" % all_dungeons.size())
	print("\n현재 상태:")
	print("플레이어 위치: (%.0f, %.0f)" % [player_position.x, player_position.z])
	if current_region:
		print("현재 지역: %s" % current_region.name)
	print("게임 시간: %.1f시 (%s)" % [world_time, get_time_of_day_description()])
	print("게임 일: %d일" % world_day)
	print("날씨: %s" % current_weather)

# 지역 정보 출력
func print_region_info(region: Region):
	print("\n=== %s 정보 ===" % region.name)
	print("지형: %s" % region.terrain_type)
	print("크기: %.0f × %.0f" % [region.size.x, region.size.y])
	print("랜드마크: %d개" % region.landmarks.size())
	print("던전: %d개" % region.landmarks.size())
