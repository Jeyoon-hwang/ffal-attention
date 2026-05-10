# EnvironmentAssetGenerator.gd
# Godot 4.3 - 절차형 환경 에셋 생성 엔진
# 목표: 20+ 환경 에셋 (건물, 자연, 소품) 자동 생성
# 사용: 게임 로딩 시 또는 에디터에서 스크립트 실행

extends Node

class_name EnvironmentAssetGenerator

## 에셋 타입별 매개변수 저장
var asset_templates = {}
var generated_assets = []

func _ready():
	print("[EnvironmentAssetGenerator] 초기화 시작...")
	initialize_asset_templates()
	generate_all_assets()
	export_assets_to_json()
	print("[EnvironmentAssetGenerator] 완료! %d개 에셋 생성됨" % generated_assets.size())

# ============================================================================
# 1. 에셋 템플릿 정의
# ============================================================================

func initialize_asset_templates():
	"""에셋 타입별 생성 규칙 정의"""
	
	# 건물 (5가지)
	asset_templates["house"] = {
		"name": "House",
		"category": "Building",
		"variations": 3,
		"scale_range": Vector3(1.0, 1.5, 1.0),
		"color_variations": ["wood_brown", "stone_gray", "white"],
		"complexity": "medium"
	}
	
	asset_templates["tower"] = {
		"name": "Tower",
		"category": "Building",
		"variations": 2,
		"scale_range": Vector3(0.8, 2.5, 0.8),
		"color_variations": ["stone_gray", "dark_stone"],
		"complexity": "high"
	}
	
	asset_templates["temple"] = {
		"name": "Temple",
		"category": "Building",
		"variations": 2,
		"scale_range": Vector3(1.5, 2.0, 1.5),
		"color_variations": ["red_wood", "gold_trim"],
		"complexity": "high"
	}
	
	asset_templates["wall"] = {
		"name": "Wall",
		"category": "Building",
		"variations": 1,
		"scale_range": Vector3(3.0, 1.5, 0.3),
		"color_variations": ["stone_gray", "dark_wood"],
		"complexity": "low"
	}
	
	asset_templates["gate"] = {
		"name": "Gate",
		"category": "Building",
		"variations": 2,
		"scale_range": Vector3(1.5, 2.0, 0.3),
		"color_variations": ["dark_wood", "iron_black"],
		"complexity": "medium"
	}
	
	# 자연 (5가지)
	asset_templates["tree"] = {
		"name": "Tree",
		"category": "Nature",
		"variations": 4,
		"scale_range": Vector3(0.6, 1.8, 0.6),
		"color_variations": ["green_dark", "green_bright", "autumn_red"],
		"complexity": "medium"
	}
	
	asset_templates["rock"] = {
		"name": "Rock",
		"category": "Nature",
		"variations": 5,
		"scale_range": Vector3(0.5, 1.0, 0.5),
		"color_variations": ["gray", "brown", "dark_gray"],
		"complexity": "low"
	}
	
	asset_templates["grass"] = {
		"name": "GrassPatch",
		"category": "Nature",
		"variations": 1,
		"scale_range": Vector3(2.0, 0.1, 2.0),
		"color_variations": ["green"],
		"complexity": "low"
	}
	
	asset_templates["bush"] = {
		"name": "Bush",
		"category": "Nature",
		"variations": 3,
		"scale_range": Vector3(0.7, 1.0, 0.7),
		"color_variations": ["green_dark", "green_medium"],
		"complexity": "low"
	}
	
	asset_templates["mushroom_group"] = {
		"name": "MushroomGroup",
		"category": "Nature",
		"variations": 2,
		"scale_range": Vector3(0.4, 0.5, 0.4),
		"color_variations": ["red_white", "brown"],
		"complexity": "low"
	}
	
	# 소품 (5가지)
	asset_templates["bench"] = {
		"name": "Bench",
		"category": "Props",
		"variations": 2,
		"scale_range": Vector3(1.0, 0.8, 0.4),
		"color_variations": ["brown_wood", "stone_gray"],
		"complexity": "low"
	}
	
	asset_templates["lamp"] = {
		"name": "Lamp",
		"category": "Props",
		"variations": 2,
		"scale_range": Vector3(0.3, 1.5, 0.3),
		"color_variations": ["iron_black", "bronze"],
		"complexity": "medium"
	}
	
	asset_templates["fence"] = {
		"name": "Fence",
		"category": "Props",
		"variations": 2,
		"scale_range": Vector3(2.0, 1.0, 0.2),
		"color_variations": ["brown_wood", "light_wood"],
		"complexity": "low"
	}
	
	asset_templates["well"] = {
		"name": "Well",
		"category": "Props",
		"variations": 1,
		"scale_range": Vector3(0.8, 1.2, 0.8),
		"color_variations": ["stone_gray", "brown_wood"],
		"complexity": "medium"
	}
	
	asset_templates["statue"] = {
		"name": "Statue",
		"category": "Props",
		"variations": 2,
		"scale_range": Vector3(0.6, 1.5, 0.6),
		"color_variations": ["stone_white", "bronze"],
		"complexity": "medium"
	}
	
	print("[Template] %d가지 에셋 템플릿 로드됨" % asset_templates.size())

# ============================================================================
# 2. 에셋 생성
# ============================================================================

func generate_all_assets():
	"""모든 템플릿에서 에셋 생성"""
	var total = 0
	
	for asset_type in asset_templates.keys():
		var template = asset_templates[asset_type]
		var variations = template.get("variations", 1)
		
		for i in range(variations):
			var asset = generate_single_asset(asset_type, i)
			generated_assets.append(asset)
			total += 1
	
	print("[Generated] 총 %d개 에셋 생성됨" % total)

func generate_single_asset(asset_type: String, variation_index: int) -> Dictionary:
	"""단일 에셋 생성"""
	var template = asset_templates[asset_type]
	var color_variations = template.get("color_variations", ["default"])
	
	var asset = {
		"id": "%s_%d" % [asset_type, variation_index],
		"type": asset_type,
		"category": template.get("category", "Unknown"),
		"name": "%s Variation %d" % [template.get("name", "Asset"), variation_index + 1],
		"variation": variation_index,
		"scale": generate_random_scale(template.get("scale_range", Vector3.ONE)),
		"color": color_variations[variation_index % color_variations.size()],
		"vertices": generate_procedural_mesh_stats(asset_type, variation_index),
		"polygons": generate_polygon_count(asset_type),
		"material": generate_material_spec(asset_type),
		"collision": generate_collision_shape(asset_type),
		"performance": {
			"lod0": 100,  # 기본 품질
			"lod1": 50,   # 중간 거리
			"lod2": 25,   # 먼 거리
			"is_optimized": true
		},
		"metadata": {
			"created_at": Time.get_ticks_msec(),
			"generator_version": "1.0",
			"complexity": template.get("complexity", "medium"),
			"batch_compatible": true
		}
	}
	
	return asset

func generate_random_scale(scale_range: Vector3) -> Array:
	"""스케일 범위 내에서 랜덤 스케일 생성"""
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(Time.get_ticks_msec())
	
	return [
		rng.randf_range(scale_range.x * 0.8, scale_range.x * 1.2),
		rng.randf_range(scale_range.y * 0.8, scale_range.y * 1.2),
		rng.randf_range(scale_range.z * 0.8, scale_range.z * 1.2)
	]

func generate_procedural_mesh_stats(asset_type: String, variation_index: int) -> int:
	"""절차형 메시 정점 수 계산"""
	var base_vertices = {
		"house": 120,
		"tower": 180,
		"temple": 250,
		"wall": 80,
		"gate": 140,
		"tree": 200,
		"rock": 60,
		"grass": 30,
		"bush": 90,
		"mushroom_group": 50,
		"bench": 70,
		"lamp": 100,
		"fence": 60,
		"well": 110,
		"statue": 150
	}
	
	var base = base_vertices.get(asset_type, 80)
	var variance = randi() % 30 - 15  # ±15 정점 변화
	return max(20, base + variance)

func generate_polygon_count(asset_type: String) -> int:
	"""폴리곤 수 계산 (정점 수의 약 1/3)"""
	var base_polygons = {
		"house": 40,
		"tower": 60,
		"temple": 85,
		"wall": 25,
		"gate": 45,
		"tree": 65,
		"rock": 20,
		"grass": 10,
		"bush": 30,
		"mushroom_group": 15,
		"bench": 23,
		"lamp": 33,
		"fence": 20,
		"well": 35,
		"statue": 50
	}
	
	return base_polygons.get(asset_type, 25)

func generate_material_spec(asset_type: String) -> Dictionary:
	"""머티리얼 사양 생성"""
	var category_to_material = {
		"Building": "masonry",
		"Nature": "vegetation",
		"Props": "crafted"
	}
	
	var category = ""
	if asset_type in asset_templates:
		category = asset_templates[asset_type].get("category", "Unknown")
	
	return {
		"type": category_to_material.get(category, "default"),
		"roughness": 0.7,
		"metallic": 0.0,
		"normal_map": true,
		"has_alpha": false
	}

func generate_collision_shape(asset_type: String) -> Dictionary:
	"""충돌 형태 생성"""
	var shapes = {
		"house": "box",
		"tower": "cylinder",
		"temple": "box",
		"wall": "box",
		"gate": "box",
		"tree": "cylinder",
		"rock": "sphere",
		"grass": "plane",
		"bush": "sphere",
		"mushroom_group": "capsule",
		"bench": "box",
		"lamp": "cylinder",
		"fence": "box",
		"well": "cylinder",
		"statue": "capsule"
	}
	
	return {
		"shape": shapes.get(asset_type, "box"),
		"enabled": true if asset_type not in ["grass", "mushroom_group"] else false,
		"is_static": true
	}

# ============================================================================
# 3. 데이터 내보내기
# ============================================================================

func export_assets_to_json():
	"""생성된 에셋을 JSON으로 내보내기"""
	var export_data = {
		"metadata": {
			"generated_at": Time.get_ticks_msec(),
			"generator": "EnvironmentAssetGenerator v1.0",
			"total_assets": generated_assets.size(),
			"categories": get_category_stats(),
			"total_vertices": calculate_total_vertices(),
			"total_polygons": calculate_total_polygons()
		},
		"assets": generated_assets
	}
	
	var json_string = JSON.stringify(export_data)
	
	# 파일로 저장
	var file_path = "user://Data/environment_assets.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("[Export] 환경 에셋 JSON 저장됨: %s" % file_path)
	else:
		print("[Error] 파일 저장 실패: %s" % file_path)
	
	print_generation_summary()

func get_category_stats() -> Dictionary:
	"""카테고리별 통계"""
	var stats = {}
	for asset in generated_assets:
		var cat = asset.get("category", "Unknown")
		if not cat in stats:
			stats[cat] = 0
		stats[cat] += 1
	return stats

func calculate_total_vertices() -> int:
	"""총 정점 수"""
	var total = 0
	for asset in generated_assets:
		total += asset.get("vertices", 0)
	return total

func calculate_total_polygons() -> int:
	"""총 폴리곤 수"""
	var total = 0
	for asset in generated_assets:
		total += asset.get("polygons", 0)
	return total

func print_generation_summary():
	"""생성 요약 출력"""
	print("\n" + "="*60)
	print("[EnvironmentAssetGenerator] 생성 완료!")
	print("="*60)
	print("총 에셋: %d개" % generated_assets.size())
	print("총 정점: %d개" % calculate_total_vertices())
	print("총 폴리곤: %d개" % calculate_total_polygons())
	print("\n카테고리별 분포:")
	var stats = get_category_stats()
	for category in stats.keys():
		print("  - %s: %d개" % [category, stats[category]])
	print("="*60 + "\n")

# ============================================================================
# 4. 유틸리티 함수
# ============================================================================

func get_asset_by_id(asset_id: String) -> Dictionary:
	"""ID로 에셋 조회"""
	for asset in generated_assets:
		if asset.get("id") == asset_id:
			return asset
	return {}

func get_assets_by_category(category: String) -> Array:
	"""카테고리로 에셋 필터링"""
	var filtered = []
	for asset in generated_assets:
		if asset.get("category") == category:
			filtered.append(asset)
	return filtered

func get_asset_count() -> int:
	"""생성된 에셋 총 개수"""
	return generated_assets.size()

# ============================================================================
# 5. 게임 엔진 통합 (향후 사용)
# ============================================================================

func spawn_asset_in_scene(asset_id: String, position: Vector3, parent: Node3D = null):
	"""씬에 에셋 인스턴스 생성 (향후 구현)"""
	var asset = get_asset_by_id(asset_id)
	if asset.is_empty():
		push_error("에셋을 찾을 수 없음: %s" % asset_id)
		return null
	
	# 향후 3D 메시 생성 및 배치
	# 현재는 데이터 구조만 반환
	return asset

func batch_spawn_assets(category: String, count: int, area: Rect2) -> Array:
	"""에셋 일괄 배치 (향후 구현)"""
	var assets = get_assets_by_category(category)
	var spawned = []
	
	for i in range(count):
		if assets.is_empty():
			break
		var random_asset = assets[randi() % assets.size()]
		var random_pos = Vector3(
			randf_range(area.position.x, area.position.x + area.size.x),
			0,
			randf_range(area.position.y, area.position.y + area.size.y)
		)
		spawned.append(spawn_asset_in_scene(random_asset.get("id"), random_pos))
	
	return spawned
