#!/usr/bin/env -S /opt/homebrew/bin/godot --script
# Day 3: 무술 로드 함수 테스트 (스탠드얼론 스크립트)
# Godot headless 모드에서 실행

extends SceneTree

func _ready():
	print("\n=== Day 3: 무술 JSON 로드 테스트 시작 ===\n")
	
	test_json_loading()
	
	quit()

func test_json_loading():
	# 프로젝트 폴더 확인
	var project_dir = "."
	var json_path = project_dir + "/src/data/MartialArts/martial_arts_base_set.json"
	
	print("📂 파일 경로: %s" % json_path)
	
	# 파일 읽기
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("❌ 파일을 찾을 수 없음!")
		return
	
	print("✅ 파일 발견")
	
	# JSON 파싱
	var json_text = file.get_as_text()
	print("📋 파일 크기: %d 바이트" % json_text.length())
	
	var json = JSON.new()
	if json.parse(json_text) != OK:
		print("❌ JSON 파싱 실패!")
		return
	
	print("✅ JSON 파싱 성공")
	
	var data = json.data
	if !data.has("martial_arts"):
		print("❌ 'martial_arts' 키를 찾을 수 없음!")
		return
	
	var martial_arts = data["martial_arts"]
	print("✅ 무술 배열 발견")
	print("\n📊 무술 개수: %d개\n" % martial_arts.size())
	
	# 각 무술 정보 출력
	print("=== 로드된 무술 목록 ===\n")
	
	for i in range(martial_arts.size()):
		var ma = martial_arts[i]
		var id = ma.get("id", "?")
		var name = ma.get("name", "?")
		var base_type = ma.get("base_type", "?")
		var power = ma.get("power", 0)
		var cooldown = ma.get("cooldown", 0.0)
		var effects_str = ", ".join(ma.get("effects", []))
		
		print("[%d] %s (ID: %s)" % [i+1, name, id])
		print("    ├─ 기초: %s" % base_type)
		print("    ├─ 위력: %d" % power)
		print("    ├─ 쿨: %.1f초" % cooldown)
		print("    └─ 효과: %s" % effects_str)
		
		if i < martial_arts.size() - 1:
			print()
	
	print("\n=== 통계 ===")
	print("✅ 총 %d개의 무술이 성공적으로 로드되었습니다." % martial_arts.size())
	print("✅ Day 3 테스트 완료!")
	print()
