# Day 3: 무술 JSON 로드 테스트
# 무술 30개가 정상적으로 로드되는지 확인

extends Node

var martial_engine: Node

func _ready():
	print("\n=== Day 3: 무술 JSON 로드 테스트 시작 ===")
	
	# MartialArtEngine 싱글톤 접근
	# (주의: 씬에 추가되어야 함)
	if has_node("/root/MartialArtEngine"):
		martial_engine = get_node("/root/MartialArtEngine")
	else:
		print("경고: MartialArtEngine을 찾을 수 없음. 테스트를 위해 생성합니다.")
		# 임시로 테스트용 스크립트 인스턴스 사용
		test_load_directly()
		return
	
	# JSON 파일 경로 (Godot res:// 형식 또는 절대 경로)
	var json_path = "res://src/data/MartialArts/martial_arts_base_set.json"
	
	print("로드 시작: ", json_path)
	
	# 무술 로드
	var loaded_arts = martial_engine.load_martial_arts_from_json(json_path)
	
	print("\n로드된 무술 수: %d" % loaded_arts.size())
	
	# 각 무술 정보 출력 (첫 5개만)
	if loaded_arts.size() > 0:
		print("\n=== 로드된 무술 샘플 ===")
		for i in range(min(5, loaded_arts.size())):
			var ma = loaded_arts[i]
			print("\n[%d] %s" % [i+1, ma.name])
			print("  - ID: %s" % ma.id)
			print("  - 기초: %s" % ma.bases)
			print("  - 스타일: %s" % ma.styles)
			print("  - 패턴: %s" % ma.patterns)
			print("  - 효과: %s" % ma.effects)
			print("  - 위력: %d, 쿨: %.1f초" % [ma.damage, ma.cooldown])
	
	# 통계 출력
	martial_engine.print_statistics()
	
	print("\n=== Day 3 테스트 완료 ===\n")

# JSON 파일이 있는지 직접 확인
func test_load_directly():
	print("\n=== 직접 로드 테스트 ===")
	
	# 파일 존재 확인
	var file_path = "res://src/data/MartialArts/martial_arts_base_set.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		print("파일을 찾을 수 없음: ", file_path)
		print("Godot 프로젝트 경로를 확인하세요.")
		return
	
	var json_text = file.get_as_text()
	print("파일 크기: %d 바이트" % json_text.length())
	
	# JSON 파싱
	var json = JSON.new()
	if json.parse(json_text) == OK:
		var data = json.data
		if data.has("martial_arts"):
			print("무술 개수: %d" % data["martial_arts"].size())
			print("\n첫 3개 무술:")
			for i in range(min(3, data["martial_arts"].size())):
				var ma_data = data["martial_arts"][i]
				print("\n  [%d] %s" % [i+1, ma_data.get("name", "?")])
				print("      기초: %s" % ma_data.get("base_type", "?"))
				print("      스타일: %s" % ma_data.get("style", "?"))
	else:
		print("JSON 파싱 실패")
