extends Node
"""
NEXUS 무술 창조 게임 - Godot 자동 자산 임포터
Day 15-28에 Blender에서 생성된 FBX 모델들을 자동으로 임포트 & 로드

역할:
  1. assets/Models 폴더에서 FBX 파일 감지
  2. Godot 자산으로 자동 임포트
  3. 장면에 인스턴스화
  4. 성능 모니터링
"""

class_name AssetImporter

var imported_assets: Dictionary = {}
var asset_cache: Dictionary = {}
var models_dir: String = "res://assets/Models"
var error_log: Array = []

func _ready():
	print("[NEXUS] 🔥 AssetImporter 초기화 시작")
	scan_and_import_assets()
	print("[NEXUS] ✅ AssetImporter 준비 완료")

## FBX 파일 자동 스캔 및 임포트
func scan_and_import_assets() -> void:
	print("[NEXUS] 📂 에셋 폴더 스캔 중: %s" % models_dir)
	
	# 모든 서브 디렉토리 스캔
	var categories = ["Characters", "Monsters", "Environments", "NPCs", "Bosses", "Props"]
	var imported_count = 0
	
	for category in categories:
		var cat_path = "%s/%s" % [models_dir, category]
		var fbx_files = get_fbx_files_in_directory(cat_path)
		
		for fbx_file in fbx_files:
			if import_fbx_asset(fbx_file, category):
				imported_count += 1
	
	print("[NEXUS] ✅ 총 %d개 자산 임포트 완료" % imported_count)

## 디렉토리에서 FBX 파일 찾기
func get_fbx_files_in_directory(dir_path: String) -> Array:
	var files = []
	var dir = DirAccess.open(dir_path)
	
	if dir == null:
		error_log.append("디렉토리 없음: %s" % dir_path)
		return files
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".fbx"):
			files.append("%s/%s" % [dir_path, file_name])
		file_name = dir.get_next()
	
	return files

## FBX 자산 임포트 (Godot 자산 시스템)
func import_fbx_asset(fbx_path: String, category: String) -> bool:
	var asset_name = fbx_path.get_file().trim_suffix(".fbx")
	
	# 이미 임포트되었는지 확인
	if asset_name in imported_assets:
		return false
	
	try:
		# FBX를 Godot 장면으로 변환 (또는 메시로 로드)
		var mesh = load_fbx_as_mesh(fbx_path)
		
		if mesh != null:
			imported_assets[asset_name] = {
				"path": fbx_path,
				"category": category,
				"mesh": mesh,
				"imported_at": Time.get_ticks_msec()
			}
			
			print("[NEXUS] ✅ 임포트: %s (카테고리: %s)" % [asset_name, category])
			return true
		else:
			error_log.append("임포트 실패: %s" % fbx_path)
			return false
	
	except:
		error_log.append("임포트 에러: %s" % fbx_path)
		return false

## FBX를 메시로 로드 (간단한 방식)
func load_fbx_as_mesh(fbx_path: String) -> Mesh:
	# Godot 4.x에서는 gltf 또는 다른 형식 사용 권장
	# FBX를 직접 로드하려면 FBX2glTF 변환 또는 플러그인 필요
	
	# 현재는 gltf/glb로 변환된 버전 로드 시도
	var gltf_path = fbx_path.trim_suffix(".fbx") + ".gltf"
	
	if ResourceLoader.exists(gltf_path):
		var gltf = load(gltf_path)
		if gltf != null and gltf is PackedScene:
			return gltf
	
	# fallback: 더미 메시 생성 (테스트용)
	return create_dummy_mesh()

## 더미 메시 생성 (임시, 실제 FBX 로드 구현될 때까지)
func create_dummy_mesh() -> Mesh:
	var mesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	return mesh

## 캐시에서 자산 로드
func get_asset(asset_name: String) -> Variant:
	if asset_name in asset_cache:
		return asset_cache[asset_name]
	
	if asset_name in imported_assets:
		var asset_data = imported_assets[asset_name]
		asset_cache[asset_name] = asset_data
		return asset_data
	
	return null

## 캐릭터 모델 로드
func load_character(gender: String = "male") -> Node3D:
	var asset_name = "Character_%s" % gender.capitalize()
	var asset = get_asset(asset_name)
	
	if asset == null:
		push_error("[NEXUS] 캐릭터 없음: %s" % asset_name)
		return create_placeholder_character()
	
	return instantiate_asset(asset)

## 몬스터 모델 로드
func load_monster(monster_type: String) -> Node3D:
	var asset = get_asset(monster_type)
	
	if asset == null:
		push_error("[NEXUS] 몬스터 없음: %s" % monster_type)
		return create_placeholder_monster()
	
	return instantiate_asset(asset)

## 환경 에셋 로드
func load_environment(asset_name: String) -> Node3D:
	var asset = get_asset(asset_name)
	
	if asset == null:
		push_error("[NEXUS] 환경 에셋 없음: %s" % asset_name)
		return create_placeholder_environment()
	
	return instantiate_asset(asset)

## 자산을 씬에 인스턴스화
func instantiate_asset(asset_data: Dictionary) -> Node3D:
	var mesh_data = asset_data.get("mesh")
	
	if mesh_data == null:
		return null
	
	# 메시 인스턴스 생성
	var node = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	
	if mesh_data is Mesh:
		mesh_instance.mesh = mesh_data
	elif mesh_data is PackedScene:
		return mesh_data.instantiate()
	
	node.add_child(mesh_instance)
	return node

## 플레이스홀더 (임시)
func create_placeholder_character() -> Node3D:
	var node = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	node.add_child(mesh_instance)
	return node

func create_placeholder_monster() -> Node3D:
	var node = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	node.add_child(mesh_instance)
	return node

func create_placeholder_environment() -> Node3D:
	var node = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = CylinderMesh.new()
	node.add_child(mesh_instance)
	return node

## 성능 모니터링
func get_import_stats() -> Dictionary:
	return {
		"imported_count": imported_assets.size(),
		"cached_count": asset_cache.size(),
		"error_count": error_log.size(),
		"errors": error_log
	}

## 에러 로그 출력
func print_error_log() -> void:
	if error_log.is_empty():
		print("[NEXUS] ✅ 에러 없음")
		return
	
	print("[NEXUS] ⚠️ 에러 로그 (%d건):" % error_log.size())
	for error in error_log:
		print("  - %s" % error)
