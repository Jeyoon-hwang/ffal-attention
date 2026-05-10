"""
test_map_generator.gd - MapGenerator 테스트 및 검증

기능:
  - MapGenerator 로드 테스트
  - 각 존(Zone) 생성 테스트
  - 성능 측정 (FPS, 생성 시간)
  - 데이터 무결성 검증
  - 출력: 테스트 리포트

작성자: 천재 ⚡
버전: 1.0
"""

extends Node3D

class_name TestMapGenerator

# ============================================================================
# 상수 정의
# ============================================================================

const TEST_ALL_ZONES = true
const DETAILED_REPORT = true
const SAVE_REPORT_FILE = true

# ============================================================================
# 멤버 변수
# ============================================================================

var map_generator: MapGenerator
var test_results = {
	"total_tests": 0,
	"passed": 0,
	"failed": 0,
	"zones": [],
	"performance": {
		"total_time": 0.0,
		"avg_time_per_zone": 0.0
	}
}

var report_text = ""

# ============================================================================
# 초기화 & 실행
# ============================================================================

func _ready():
	print("\n" + "="*80)
	print("🧪 NEXUS MapGenerator 테스트 시작 (Day 22)")
	print("="*80 + "\n")
	
	report_text = "[NEXUS MapGenerator Test Report]\n"
	report_text += "Time: %s\n" % Time.get_datetime_string_from_system()
	report_text += "="*80 + "\n\n"
	
	# MapGenerator 생성 및 로드
	map_generator = MapGenerator.new()
	add_child(map_generator)
	
	# 테스트 실행
	if TEST_ALL_ZONES:
		test_all_zones()
	else:
		test_single_zone(0)
	
	# 결과 출력
	print_test_results()
	
	# 리포트 저장
	if SAVE_REPORT_FILE:
		save_report()
	
	print("\n" + "="*80)
	print("🧪 테스트 완료!")
	print("="*80 + "\n")

# ============================================================================
# 테스트 함수
# ============================================================================

func test_all_zones():
	"""모든 존 테스트"""
	print("[TEST] 모든 존(Zone) 테스트 시작...\n")
	
	var total_start_time = Time.get_ticks_msec()
	
	for zone_id in range(5):
		var zone_result = test_single_zone(zone_id)
		test_results["zones"].append(zone_result)
	
	var total_elapsed = Time.get_ticks_msec() - total_start_time
	test_results["performance"]["total_time"] = total_elapsed / 1000.0
	test_results["performance"]["avg_time_per_zone"] = total_elapsed / (5.0 * 1000.0)
	
	print("\n[TEST] 모든 존 테스트 완료!")

func test_single_zone(zone_id: int) -> Dictionary:
	"""단일 존 테스트"""
	print("[TEST] Zone %d (%s) 테스트 중..." % [zone_id, ["중원", "천산", "황무지", "동해", "흑룡굴"][zone_id]])
	
	var zone_test_result = {
		"zone_id": zone_id,
		"tests_passed": 0,
		"tests_failed": 0,
		"details": []
	}
	
	var start_time = Time.get_ticks_msec()
	
	# 1. 존 생성 테스트
	var test1 = test_zone_generation(zone_id)
	zone_test_result["tests_passed"] += 1 if test1 else 0
	zone_test_result["tests_failed"] += 0 if test1 else 1
	zone_test_result["details"].append(test1)
	
	# 2. 높이맵 검증
	var test2 = test_heightmap_validity(zone_id)
	zone_test_result["tests_passed"] += 1 if test2 else 0
	zone_test_result["tests_failed"] += 0 if test2 else 1
	zone_test_result["details"].append(test2)
	
	# 3. 에셋 배치 검증
	var test3 = test_asset_placement(zone_id)
	zone_test_result["tests_passed"] += 1 if test3 else 0
	zone_test_result["tests_failed"] += 0 if test3 else 1
	zone_test_result["details"].append(test3)
	
	# 4. POI 생성 검증
	var test4 = test_poi_generation(zone_id)
	zone_test_result["tests_passed"] += 1 if test4 else 0
	zone_test_result["tests_failed"] += 0 if test4 else 1
	zone_test_result["details"].append(test4)
	
	# 5. 라이팅 설정 검증
	var test5 = test_lighting_setup(zone_id)
	zone_test_result["tests_passed"] += 1 if test5 else 0
	zone_test_result["tests_failed"] += 0 if test5 else 1
	zone_test_result["details"].append(test5)
	
	var elapsed = Time.get_ticks_msec() - start_time
	zone_test_result["elapsed_time"] = elapsed / 1000.0
	
	# 결과 요약
	var status = "✅ PASS" if zone_test_result["tests_failed"] == 0 else "❌ FAIL"
	print("  → %s (소요시간: %.2f초, 통과: %d, 실패: %d)\n" % [
		status,
		zone_test_result["elapsed_time"],
		zone_test_result["tests_passed"],
		zone_test_result["tests_failed"]
	])
	
	test_results["total_tests"] += 5
	test_results["passed"] += zone_test_result["tests_passed"]
	test_results["failed"] += zone_test_result["tests_failed"]
	
	return zone_test_result

# ============================================================================
# 개별 테스트 케이스
# ============================================================================

func test_zone_generation(zone_id: int) -> bool:
	"""존 생성 테스트"""
	try:
		var map_data = map_generator.generate_zone(zone_id)
		
		# 필수 필드 확인
		assert(map_data.has("zone_id"), "zone_id 필드 누락")
		assert(map_data.has("heightmap"), "heightmap 필드 누락")
		assert(map_data.has("mesh"), "mesh 필드 누락")
		assert(map_data.has("assets"), "assets 필드 누락")
		assert(map_data.has("pois"), "pois 필드 누락")
		assert(map_data.has("lighting"), "lighting 필드 누락")
		
		# 데이터 유효성 확인
		assert(map_data["zone_id"] == zone_id, "zone_id 불일치")
		assert(map_data["size"] == 500, "지역 크기 불일치")
		
		print("    ✓ 존 생성 성공")
		return true
		
	except:
		print("    ✗ 존 생성 실패: %s" % error_text)
		return false

func test_heightmap_validity(zone_id: int) -> bool:
	"""높이맵 유효성 테스트"""
	try:
		var map_data = map_generator.generate_zone(zone_id)
		var heightmap = map_data["heightmap"]
		
		# 이미지 존재 확인
		assert(heightmap != null, "높이맵이 null")
		assert(heightmap is Image, "높이맵이 Image 타입이 아님")
		
		# 해상도 확인
		assert(heightmap.get_width() == 256, "높이맵 너비 불일치")
		assert(heightmap.get_height() == 256, "높이맵 높이 불일치")
		
		# 픽셀 값 범위 확인 (0.0 ~ 1.0)
		var valid_pixels = 0
		for y in range(heightmap.get_height()):
			for x in range(heightmap.get_width()):
				var pixel = heightmap.get_pixel(x, y)
				if 0.0 <= pixel.r <= 1.0:
					valid_pixels += 1
		
		var validity_ratio = float(valid_pixels) / (256 * 256)
		assert(validity_ratio >= 0.99, "유효한 픽셀 비율이 낮음: %.2f%%" % (validity_ratio * 100))
		
		print("    ✓ 높이맵 검증 성공 (유효도: %.2f%%)" % (validity_ratio * 100))
		return true
		
	except:
		print("    ✗ 높이맵 검증 실패: %s" % error_text)
		return false

func test_asset_placement(zone_id: int) -> bool:
	"""에셋 배치 검증"""
	try:
		var map_data = map_generator.generate_zone(zone_id)
		var assets = map_data["assets"]
		
		# 에셋 배열 존재 확인
		assert(assets is Array, "assets가 Array 타입이 아님")
		assert(assets.size() > 0, "배치된 에셋이 없음")
		
		# 각 에셋의 필수 필드 확인
		for asset in assets:
			assert(asset.has("type"), "에셋 type 필드 누락")
			assert(asset.has("position"), "에셋 position 필드 누락")
			assert(asset.has("rotation"), "에셋 rotation 필드 누락")
			assert(asset.has("scale"), "에셋 scale 필드 누락")
			
			# 위치 값 유효성
			var pos = asset["position"]
			assert(pos is Vector3, "position이 Vector3 아님")
		
		print("    ✓ 에셋 배치 검증 성공 (배치된 에셋: %d개)" % assets.size())
		return true
		
	except:
		print("    ✗ 에셋 배치 검증 실패: %s" % error_text)
		return false

func test_poi_generation(zone_id: int) -> bool:
	"""POI 생성 검증"""
	try:
		var map_data = map_generator.generate_zone(zone_id)
		var pois = map_data["pois"]
		
		# POI 배열 존재 확인
		assert(pois is Array, "pois가 Array 타입이 아님")
		assert(pois.size() > 0, "생성된 POI가 없음")
		
		# 지역별 최소 POI 수 확인
		var expected_pois = [5 + 3 + 2, 10 + 4 + 2, 10 + 3 + 1, 15 + 4 + 2, 20 + 5 + 2]
		assert(pois.size() == expected_pois[zone_id], "POI 수 불일치")
		
		# 각 POI의 유효성 확인
		var dungeon_count = 0
		var npc_count = 0
		var merchant_count = 0
		
		for poi in pois:
			assert(poi.has("type"), "POI type 필드 누락")
			assert(poi.has("position"), "POI position 필드 누락")
			assert(poi.has("id"), "POI id 필드 누락")
			
			match poi["type"]:
				"dungeon": dungeon_count += 1
				"npc": npc_count += 1
				"merchant": merchant_count += 1
		
		print("    ✓ POI 생성 검증 성공 (던전: %d, NPC: %d, 상인: %d)" % [dungeon_count, npc_count, merchant_count])
		return true
		
	except:
		print("    ✗ POI 생성 검증 실패: %s" % error_text)
		return false

func test_lighting_setup(zone_id: int) -> bool:
	"""라이팅 설정 검증"""
	try:
		var map_data = map_generator.generate_zone(zone_id)
		var lighting = map_data["lighting"]
		
		# 라이팅 정보 존재 확인
		assert(lighting is Dictionary, "lighting이 Dictionary 아님")
		assert(lighting.has("sun_angle"), "sun_angle 필드 누락")
		assert(lighting.has("sun_color"), "sun_color 필드 누락")
		assert(lighting.has("ambient_light"), "ambient_light 필드 누락")
		assert(lighting.has("ambient_color"), "ambient_color 필드 누락")
		
		# 라이팅 값 범위 확인
		var ambient = lighting["ambient_light"]
		assert(0.0 <= ambient <= 1.0, "ambient_light 값이 범위를 벗어남: %.2f" % ambient)
		
		print("    ✓ 라이팅 설정 검증 성공")
		return true
		
	except:
		print("    ✗ 라이팅 설정 검증 실패: %s" % error_text)
		return false

# ============================================================================
# 결과 출력 & 리포트 생성
# ============================================================================

func print_test_results():
	"""테스트 결과 출력"""
	print("\n" + "="*80)
	print("📊 테스트 결과 요약")
	print("="*80)
	
	# 전체 통계
	var pass_rate = float(test_results["passed"]) / test_results["total_tests"] * 100
	var status_icon = "✅" if test_results["failed"] == 0 else "❌"
	
	print("\n%s 전체: %d개 테스트" % [status_icon, test_results["total_tests"]])
	print("  통과: %d개" % test_results["passed"])
	print("  실패: %d개" % test_results["failed"])
	print("  성공률: %.1f%%" % pass_rate)
	
	# 성능 통계
	print("\n⏱️  성능 측정")
	print("  전체 시간: %.2f초" % test_results["performance"]["total_time"])
	print("  평균 (존당): %.2f초" % test_results["performance"]["avg_time_per_zone"])
	
	# 존별 상세 결과
	if DETAILED_REPORT:
		print("\n📍 존별 상세 결과")
		for zone_result in test_results["zones"]:
			var zone_names = ["중원", "천산", "황무지", "동해", "흑룡굴"]
			var zone_name = zone_names[zone_result["zone_id"]]
			var status = "✅" if zone_result["tests_failed"] == 0 else "❌"
			print("  %s Zone %d (%s): %.2f초 (통과: %d, 실패: %d)" % [
				status,
				zone_result["zone_id"],
				zone_name,
				zone_result["elapsed_time"],
				zone_result["tests_passed"],
				zone_result["tests_failed"]
			])
	
	# 리포트 문자열 작성
	report_text += "\n📊 테스트 결과 요약\n"
	report_text += "="*80 + "\n\n"
	report_text += "전체: %d개 테스트\n" % test_results["total_tests"]
	report_text += "  통과: %d개\n" % test_results["passed"]
	report_text += "  실패: %d개\n" % test_results["failed"]
	report_text += "  성공률: %.1f%%\n\n" % pass_rate
	
	report_text += "성능 측정\n"
	report_text += "  전체 시간: %.2f초\n" % test_results["performance"]["total_time"]
	report_text += "  평균 (존당): %.2f초\n" % test_results["performance"]["avg_time_per_zone"]

func save_report():
	"""테스트 리포트 파일로 저장"""
	var report_path = "user://MapGenerator_Test_Report.txt"
	var file = FileAccess.open(report_path, FileAccess.WRITE)
	
	if file != null:
		file.store_string(report_text)
		print("\n💾 리포트 저장: %s" % report_path)
	else:
		print("\n⚠️  리포트 저장 실패")

# ============================================================================
# 유틸리티
# ============================================================================

func assert(condition: bool, message: String):
	"""간단한 assert 함수"""
	if not condition:
		push_error("Assertion failed: %s" % message)
		var error_text = message
		throw(Error())

func throw(error: Error):
	"""에러 발생"""
	print(error)
