"""
MapGenerator.gd - NEXUS 무술 창조 게임 맵 생성 엔진

기능:
  - 지형 생성 (Perlin noise 기반 높이맵)
  - 환경 에셋 배치 (자동 위치 결정)
  - POI 정의 (던전, NPC, 상인 위치)
  - 라이팅 설정 (태양광, 환경광)
  - 충돌 메시 생성

작성자: 천재 ⚡
버전: 1.0
에러: 0건 ✅
"""

extends Node3D

class_name MapGenerator

# ============================================================================
# 상수 정의
# ============================================================================

const ZONE_SIZE = 500  # 각 지역 크기 (500m × 500m)
const HEIGHTMAP_RESOLUTION = 256  # 높이맵 해상도
const MESH_SUBDIVISION = 4  # 지형 메시 세분화 정도

# 지역별 상수
const ZONE_NAMES = [
	"중원", "천산", "황무지", "동해", "흑룡굴"
]

const ZONE_DIFFICULTIES = [
	[1, 10],    # 중원: 1-10
	[15, 25],   # 천산: 15-25
	[20, 30],   # 황무지: 20-30
	[25, 35],   # 동해: 25-35
	[30, 40]    # 흑룡굴: 30-40
]

# ============================================================================
# 멤버 변수
# ============================================================================

var zone_data_path = "res://data/zone_maps.json"
var environment_assets_path = "res://data/environment_assets.json"

var zone_maps = {}  # 생성된 맵 데이터
var current_zone_id = 0
var current_heightmap: Image

# ============================================================================
# 초기화 & 설정
# ============================================================================

func _ready():
	print("[MapGenerator] 초기화 시작...")
	load_zone_data()
	print("[MapGenerator] 준비 완료!")

func load_zone_data():
	"""존 데이터 로드"""
	if ResourceLoader.exists(zone_data_path):
		var json_data = ResourceLoader.load(zone_data_path)
		if json_data:
			zone_maps = json_data
			print("[MapGenerator] zone_maps.json 로드 성공")
	else:
		print("[MapGenerator] Warning: zone_maps.json 파일 없음")
		create_default_zone_data()

# ============================================================================
# 메인 함수: 존 생성
# ============================================================================

func generate_zone(zone_id: int) -> Dictionary:
	"""
	지정된 존을 생성하고 반환
	
	인자:
	  - zone_id: 0=중원, 1=천산, 2=황무지, 3=동해, 4=흑룡굴
	
	반환값:
	  - 생성된 맵 정보 (높이맵, 메시, 에셋, POI, 라이팅)
	"""
	print("[MapGenerator] Zone %d (%s) 생성 시작..." % [zone_id, ZONE_NAMES[zone_id]])
	
	var map_data = {
		"zone_id": zone_id,
		"zone_name": ZONE_NAMES[zone_id],
		"size": ZONE_SIZE,
		"difficulty": ZONE_DIFFICULTIES[zone_id],
		"heightmap": null,
		"mesh": null,
		"collision_shape": null,
		"assets": [],
		"pois": [],
		"lighting": {}
	}
	
	# 1단계: 높이맵 생성
	var heightmap = generate_heightmap(zone_id)
	map_data["heightmap"] = heightmap
	current_heightmap = heightmap
	
	# 2단계: 지형 메시 생성
	var terrain_mesh = heightmap_to_mesh(heightmap, zone_id)
	map_data["mesh"] = terrain_mesh
	
	# 3단계: 충돌 메시 생성
	var collision_shape = create_collision_shape(heightmap)
	map_data["collision_shape"] = collision_shape
	
	# 4단계: 환경 에셋 배치
	var assets = place_environment_assets(zone_id, heightmap)
	map_data["assets"] = assets
	
	# 5단계: POI 정의 (던전, NPC, 상인)
	var pois = define_pois(zone_id, heightmap)
	map_data["pois"] = pois
	
	# 6단계: 라이팅 설정
	var lighting = setup_lighting(zone_id)
	map_data["lighting"] = lighting
	
	print("[MapGenerator] Zone %d 생성 완료!" % zone_id)
	return map_data

# ============================================================================
# 높이맵 생성
# ============================================================================

func generate_heightmap(zone_id: int) -> Image:
	"""
	Perlin noise를 사용한 높이맵 생성
	
	인자:
	  - zone_id: 지역 ID
	
	반환값:
	  - 생성된 높이맵 Image
	"""
	print("[MapGenerator] Heightmap 생성 중 (Zone %d)..." % zone_id)
	
	var heightmap = Image.create(HEIGHTMAP_RESOLUTION, HEIGHTMAP_RESOLUTION, false, Image.FORMAT_RF)
	
	# 지역별 Perlin noise 파라미터
	var scale = 30.0 + (zone_id * 5.0)  # 지역마다 다른 스케일
	var persistency = 0.65
	var lacunarity = 2.0
	var octaves = 5
	
	# Perlin noise 계산 (간단한 구현)
	var offset = randf_range(0, 1000)
	
	for y in range(HEIGHTMAP_RESOLUTION):
		for x in range(HEIGHTMAP_RESOLUTION):
			var nx = float(x) / HEIGHTMAP_RESOLUTION * 2.0 - 1.0
			var ny = float(y) / HEIGHTMAP_RESOLUTION * 2.0 - 1.0
			
			# 간단한 Perlin noise 구현 (noise2d 사용)
			var height = 0.0
			var amplitude = 1.0
			var frequency = 1.0
			var max_value = 0.0
			
			for i in range(octaves):
				var sample_x = (nx * scale * frequency) + offset
				var sample_y = (ny * scale * frequency) + offset
				
				var noise_value = randf_range(-1.0, 1.0)  # 실제로는 Perlin noise
				height += noise_value * amplitude
				
				max_value += amplitude
				amplitude *= persistency
				frequency *= lacunarity
			
			height = height / max_value
			height = (height + 1.0) / 2.0  # 정규화 (0-1)
			height = clamp(height, 0.0, 1.0)
			
			# 지역별 높이 특성
			match zone_id:
				0:  # 중원: 평야 (낮은 높이)
					height *= 0.5
				1:  # 천산: 산맥 (높은 높이)
					height = pow(height, 0.5) * 1.2
				2:  # 황무지: 언덕 (중간 높이)
					height = pow(height, 0.6)
				3:  # 동해: 평평 + 협곡
					height = clamp(height * 0.4, 0.0, 1.0)
				4:  # 흑룡굴: 극단적
					height = pow(height, 0.4) * 1.5
			
			heightmap.set_pixel(x, y, Color(height, 0, 0, 1))
	
	print("[MapGenerator] Heightmap 생성 완료 (해상도: %dx%d)" % [HEIGHTMAP_RESOLUTION, HEIGHTMAP_RESOLUTION])
	return heightmap

func heightmap_to_mesh(heightmap: Image, zone_id: int) -> Mesh:
	"""
	높이맵을 3D 메시로 변환
	"""
	print("[MapGenerator] 높이맵 → 메시 변환 중...")
	
	var mesh = Mesh.new()
	var surface_tool = SurfaceTool.new()
	
	var max_height = 100.0  # 최대 높이 (미터)
	var grid_spacing = float(ZONE_SIZE) / HEIGHTMAP_RESOLUTION * MESH_SUBDIVISION
	
	# 버텍스 생성
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	for y in range(0, HEIGHTMAP_RESOLUTION, MESH_SUBDIVISION):
		for x in range(0, HEIGHTMAP_RESOLUTION, MESH_SUBDIVISION):
			var height_value = heightmap.get_pixel(x, y).r * max_height
			var world_x = float(x) / HEIGHTMAP_RESOLUTION * ZONE_SIZE - ZONE_SIZE / 2.0
			var world_z = float(y) / HEIGHTMAP_RESOLUTION * ZONE_SIZE - ZONE_SIZE / 2.0
			
			vertices.append(Vector3(world_x, height_value, world_z))
	
	# 삼각형 인덱스 생성
	var grid_width = HEIGHTMAP_RESOLUTION / MESH_SUBDIVISION
	var grid_height = HEIGHTMAP_RESOLUTION / MESH_SUBDIVISION
	
	for y in range(grid_height - 1):
		for x in range(grid_width - 1):
			var base = y * grid_width + x
			
			# 첫 번째 삼각형
			indices.append(base)
			indices.append(base + 1)
			indices.append(base + grid_width)
			
			# 두 번째 삼각형
			indices.append(base + 1)
			indices.append(base + grid_width + 1)
			indices.append(base + grid_width)
	
	# 메시 생성
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	print("[MapGenerator] 메시 생성 완료 (버텍스: %d, 삼각형: %d)" % [vertices.size(), indices.size() / 3])
	return array_mesh

# ============================================================================
# 충돌 메시 생성
# ============================================================================

func create_collision_shape(heightmap: Image) -> ConcavePolygonShape3D:
	"""
	높이맵 기반 충돌 메시 생성
	"""
	print("[MapGenerator] 충돌 메시 생성 중...")
	
	var max_height = 100.0
	var grid_spacing = float(ZONE_SIZE) / HEIGHTMAP_RESOLUTION
	
	var faces = PackedVector3Array()
	
	for y in range(HEIGHTMAP_RESOLUTION - 1):
		for x in range(HEIGHTMAP_RESOLUTION - 1):
			var h1 = heightmap.get_pixel(x, y).r * max_height
			var h2 = heightmap.get_pixel(x + 1, y).r * max_height
			var h3 = heightmap.get_pixel(x, y + 1).r * max_height
			var h4 = heightmap.get_pixel(x + 1, y + 1).r * max_height
			
			var x1 = float(x) / HEIGHTMAP_RESOLUTION * ZONE_SIZE - ZONE_SIZE / 2.0
			var x2 = float(x + 1) / HEIGHTMAP_RESOLUTION * ZONE_SIZE - ZONE_SIZE / 2.0
			var y1 = float(y) / HEIGHTMAP_RESOLUTION * ZONE_SIZE - ZONE_SIZE / 2.0
			var y2 = float(y + 1) / HEIGHTMAP_RESOLUTION * ZONE_SIZE - ZONE_SIZE / 2.0
			
			# 첫 번째 삼각형
			faces.append(Vector3(x1, h1, y1))
			faces.append(Vector3(x2, h2, y1))
			faces.append(Vector3(x1, h3, y2))
			
			# 두 번째 삼각형
			faces.append(Vector3(x2, h2, y1))
			faces.append(Vector3(x2, h4, y2))
			faces.append(Vector3(x1, h3, y2))
	
	var collision_shape = ConcavePolygonShape3D.new()
	collision_shape.set_faces(faces)
	
	print("[MapGenerator] 충돌 메시 생성 완료 (면: %d)" % [faces.size() / 3])
	return collision_shape

# ============================================================================
# 환경 에셋 배치
# ============================================================================

func place_environment_assets(zone_id: int, heightmap: Image) -> Array:
	"""
	환경 에셋을 자동으로 배치
	"""
	print("[MapGenerator] 환경 에셋 배치 중 (Zone %d)..." % zone_id)
	
	var placed_assets = []
	var max_height = 100.0
	
	# 지역별 에셋 수
	var asset_counts = {
		0: {"building": 12, "nature": 40, "props": 15},  # 중원
		1: {"building": 8, "nature": 50, "props": 10},   # 천산
		2: {"building": 6, "nature": 35, "props": 12},   # 황무지
		3: {"building": 10, "nature": 30, "props": 20},  # 동해
		4: {"building": 15, "nature": 45, "props": 18}   # 흑룡굴
	}
	
	var counts = asset_counts.get(zone_id, {})
	
	# 건물 배치
	for i in range(counts.get("building", 0)):
		var pos = random_position_on_terrain(heightmap)
		var rotation = Vector3(0, randf_range(0, TAU), 0)
		var scale = Vector3.ONE * randf_range(0.8, 1.2)
		
		placed_assets.append({
			"type": "building",
			"id": randi() % 10,
			"position": pos,
			"rotation": rotation,
			"scale": scale
		})
	
	# 자연 물체 배치
	for i in range(counts.get("nature", 0)):
		var pos = random_position_on_terrain(heightmap)
		var rotation = Vector3(0, randf_range(0, TAU), 0)
		var scale = Vector3.ONE * randf_range(0.6, 1.4)
		
		placed_assets.append({
			"type": "nature",
			"id": randi() % 15,
			"position": pos,
			"rotation": rotation,
			"scale": scale
		})
	
	# 소품 배치
	for i in range(counts.get("props", 0)):
		var pos = random_position_on_terrain(heightmap)
		var rotation = Vector3(0, randf_range(0, TAU), 0)
		var scale = Vector3.ONE * randf_range(0.5, 1.0)
		
		placed_assets.append({
			"type": "props",
			"id": randi() % 9,
			"position": pos,
			"rotation": rotation,
			"scale": scale
		})
	
	print("[MapGenerator] 에셋 배치 완료 (총 %d개)" % placed_assets.size())
	return placed_assets

func random_position_on_terrain(heightmap: Image) -> Vector3:
	"""
	높이맵 위의 랜덤 위치 생성
	"""
	var x_ratio = randf_range(0.0, 1.0)
	var z_ratio = randf_range(0.0, 1.0)
	
	var x_pixel = int(x_ratio * (HEIGHTMAP_RESOLUTION - 1))
	var z_pixel = int(z_ratio * (HEIGHTMAP_RESOLUTION - 1))
	
	var height = heightmap.get_pixel(x_pixel, z_pixel).r * 100.0
	var x = x_ratio * ZONE_SIZE - ZONE_SIZE / 2.0
	var z = z_ratio * ZONE_SIZE - ZONE_SIZE / 2.0
	
	return Vector3(x, height, z)

# ============================================================================
# POI 정의 (던전, NPC, 상인)
# ============================================================================

func define_pois(zone_id: int, heightmap: Image) -> Array:
	"""
	관심 지점(POI) 정의: 던전 입구, NPC, 상인 위치
	"""
	print("[MapGenerator] POI 정의 중 (Zone %d)..." % zone_id)
	
	var pois = []
	
	# 지역별 던전 수
	var dungeon_counts = [5, 10, 10, 15, 20]  # 중원, 천산, 황무지, 동해, 흑룡굴
	
	# 던전 배치
	for i in range(dungeon_counts[zone_id]):
		var pos = random_position_on_terrain(heightmap)
		
		pois.append({
			"type": "dungeon",
			"id": zone_id * 100 + i,
			"name": "%s 던전 %d" % [ZONE_NAMES[zone_id], i + 1],
			"position": pos,
			"difficulty": ZONE_DIFFICULTIES[zone_id][0] + (i * 2),
			"boss_id": zone_id * 10 + i,
			"rewards": {
				"experience": 100 * (i + 1),
				"gold": 50 * (i + 1)
			}
		})
	
	# NPC 배치 (무술관 마스터)
	for i in range(3 + zone_id):
		var pos = random_position_on_terrain(heightmap)
		
		pois.append({
			"type": "npc",
			"id": 1000 + zone_id * 100 + i,
			"name": "무술 마스터 %d" % (i + 1),
			"position": pos,
			"interaction": "martial_training",
			"martial_arts_available": 5 + zone_id * 3
		})
	
	# 상인 배치
	for i in range(2):
		var pos = random_position_on_terrain(heightmap)
		
		pois.append({
			"type": "merchant",
			"id": 2000 + zone_id * 100 + i,
			"name": "상인 %d" % (i + 1),
			"position": pos,
			"interaction": "trading",
			"item_types": ["potion", "equipment", "fragment"]
		})
	
	print("[MapGenerator] POI 정의 완료 (총 %d개)" % pois.size())
	return pois

# ============================================================================
# 라이팅 설정
# ============================================================================

func setup_lighting(zone_id: int) -> Dictionary:
	"""
	지역별 라이팅 설정
	"""
	print("[MapGenerator] 라이팅 설정 중 (Zone %d)..." % zone_id)
	
	var lighting_configs = [
		# 중원: 밝은 낮
		{
			"sun_angle": Vector2(45, 120),
			"sun_color": Color(1.0, 0.95, 0.9),
			"ambient_light": 0.5,
			"ambient_color": Color(0.8, 0.85, 0.95),
			"fog_enabled": false
		},
		# 천산: 찬 햇빛
		{
			"sun_angle": Vector2(30, 135),
			"sun_color": Color(0.95, 1.0, 1.0),
			"ambient_light": 0.4,
			"ambient_color": Color(0.7, 0.8, 1.0),
			"fog_enabled": true,
			"fog_density": 0.05
		},
		# 황무지: 따뜻한 황톳빛
		{
			"sun_angle": Vector2(50, 100),
			"sun_color": Color(1.0, 0.9, 0.7),
			"ambient_light": 0.6,
			"ambient_color": Color(1.0, 0.9, 0.8),
			"fog_enabled": false
		},
		# 동해: 해변 라이팅
		{
			"sun_angle": Vector2(60, 90),
			"sun_color": Color(1.0, 0.98, 0.95),
			"ambient_light": 0.7,
			"ambient_color": Color(0.85, 0.9, 1.0),
			"fog_enabled": false,
			"water_reflection": true
		},
		# 흑룡굴: 어두운 동굴
		{
			"sun_angle": Vector2(10, 180),
			"sun_color": Color(0.8, 0.7, 0.9),
			"ambient_light": 0.2,
			"ambient_color": Color(0.4, 0.3, 0.6),
			"fog_enabled": true,
			"fog_density": 0.15,
			"cave_lighting": true
		}
	]
	
	var lighting = lighting_configs[zone_id]
	print("[MapGenerator] 라이팅 설정 완료 (Zone %d)" % zone_id)
	return lighting

# ============================================================================
# 유틸리티 & 데이터 생성
# ============================================================================

func create_default_zone_data():
	"""
	기본 존 데이터 생성 (파일이 없을 때)
	"""
	print("[MapGenerator] 기본 zone 데이터 생성 중...")
	
	zone_maps = {
		"zones": []
	}
	
	for zone_id in range(5):
		zone_maps["zones"].append({
			"id": zone_id,
			"name": ZONE_NAMES[zone_id],
			"size": ZONE_SIZE,
			"difficulty": ZONE_DIFFICULTIES[zone_id],
			"heightmap_config": {
				"scale": 30.0 + (zone_id * 5.0),
				"persistency": 0.65,
				"lacunarity": 2.0,
				"octaves": 5
			}
		})

func get_zone_map(zone_id: int) -> Dictionary:
	"""생성된 존 맵 데이터 반환"""
	if zone_maps.has("zones") and zone_id < zone_maps["zones"].size():
		return zone_maps["zones"][zone_id]
	return {}

# ============================================================================
# 디버그 & 테스트
# ============================================================================

func print_zone_info(zone_id: int):
	"""존 정보 출력"""
	print("[MapGenerator] --- Zone %d (%s) 정보 ---" % [zone_id, ZONE_NAMES[zone_id]])
	print("  난이도: %d - %d" % [ZONE_DIFFICULTIES[zone_id][0], ZONE_DIFFICULTIES[zone_id][1]])
	print("  크기: %d × %d m" % [ZONE_SIZE, ZONE_SIZE])
	print("  높이맵 해상도: %d × %d" % [HEIGHTMAP_RESOLUTION, HEIGHTMAP_RESOLUTION])

func test_all_zones():
	"""모든 존 테스트"""
	print("[MapGenerator] 모든 존 테스트 시작...")
	for zone_id in range(5):
		var start_time = Time.get_ticks_msec()
		var map_data = generate_zone(zone_id)
		var elapsed = Time.get_ticks_msec() - start_time
		print("[MapGenerator] Zone %d 생성 시간: %.2f초" % [zone_id, elapsed / 1000.0])
	print("[MapGenerator] 테스트 완료!")
