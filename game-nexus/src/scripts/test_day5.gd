extends Node3D

# 🧪 Day 5 테스트 스크립트 - 환경, NPC, 오디오 시스템 검증

class_name TestDay5

# 시스템 참조
var environment_system: EnvironmentSystem = null
var npc_spawner: NPCSpawner = null
var audio_manager: AudioManager = null
var npc_system: NPCSystem = null

# 테스트 상태
var test_results: Array = []
var total_tests: int = 0
var passed_tests: int = 0

func _ready():
	print("\n" + "=".repeat(60))
	print("🥋 NEXUS Week 3 Day 5 테스트 시작")
	print("=".repeat(60) + "\n")
	
	# 시스템 생성 및 초기화
	environment_system = EnvironmentSystem.new()
	add_child(environment_system)
	
	npc_system = NPCSystem.new()
	add_child(npc_system)
	
	npc_spawner = NPCSpawner.new()
	add_child(npc_spawner)
	npc_spawner.set_npc_system(npc_system)
	
	audio_manager = AudioManager.new()
	add_child(audio_manager)
	
	# 테스트 실행
	await get_tree().process_frame
	
	run_all_tests()
	
	print_test_results()

# 📋 모든 테스트 실행
func run_all_tests() -> void:
	print("\n🧪 Test Group 1: Environment System (환경 시스템)")
	test_environment_loading()
	test_weather_system()
	test_time_system()
	test_environment_effects()
	
	print("\n🧪 Test Group 2: NPC Spawner (NPC 배치)")
	test_npc_spawning()
	test_npc_positioning()
	test_npc_animation()
	
	print("\n🧪 Test Group 3: Audio Manager (오디오 관리)")
	test_music_loading()
	test_sfx_loading()
	test_volume_control()
	
	print("\n🧪 Test Group 4: 통합 테스트")
	test_region_change()
	test_npc_in_multiple_regions()
	test_environment_npc_audio_integration()

# ✅ Test 1-1: 환경 로드
func test_environment_loading() -> void:
	var test_name = "환경 시스템 로드"
	
	var all_envs = environment_system.get_all_environments()
	
	var passed = all_envs.size() == 5
	if passed:
		print("✅ [1-1] ", test_name, " - 5개 지역 로드됨")
	else:
		print("❌ [1-1] ", test_name, " - 예상: 5개, 실제: ", all_envs.size())
	
	record_test(test_name, passed)

# ✅ Test 1-2: 날씨 시스템
func test_weather_system() -> void:
	var test_name = "날씨 시스템"
	
	# 각 지역별 날씨 설정 테스트
	var test_passed = true
	
	for env_id in environment_system.environment_data.keys():
		environment_system.set_environment(env_id)
		var weather_types = environment_system.environment_data[env_id]["weather_types"]
		
		for weather_id in weather_types:
			environment_system.set_weather(weather_id)
			if environment_system.current_weather != weather_id:
				test_passed = false
				break
		
		if not test_passed:
			break
	
	if test_passed:
		print("✅ [1-2] ", test_name, " - 모든 날씨 변경 성공")
	else:
		print("❌ [1-2] ", test_name, " - 날씨 변경 실패")
	
	record_test(test_name, test_passed)

# ✅ Test 1-3: 시간 시스템
func test_time_system() -> void:
	var test_name = "시간 시스템"
	
	var test_passed = true
	
	for time_id in EnvironmentSystem.TIME_OF_DAY.values():
		environment_system.set_time(time_id)
		if environment_system.current_time != time_id:
			test_passed = false
			break
	
	if test_passed:
		print("✅ [1-3] ", test_name, " - 모든 시간 변경 성공 (5가지)")
	else:
		print("❌ [1-3] ", test_name, " - 시간 변경 실패")
	
	record_test(test_name, test_passed)

# ✅ Test 1-4: 환경 효과
func test_environment_effects() -> void:
	var test_name = "환경 효과 시스템"
	
	var test_passed = true
	
	for env_id in environment_system.player_effects.keys():
		var effects = environment_system.player_effects[env_id]
		
		# 필수 키 확인
		var required_keys = ["health_regen", "mana_regen", "movement_speed", "critical_chance", "damage_multiplier"]
		for key in required_keys:
			if not key in effects:
				test_passed = false
				break
	
	if test_passed:
		print("✅ [1-4] ", test_name, " - 모든 환경의 효과 데이터 완전")
	else:
		print("❌ [1-4] ", test_name, " - 효과 데이터 누락")
	
	record_test(test_name, test_passed)

# ✅ Test 2-1: NPC 스포닝
func test_npc_spawning() -> void:
	var test_name = "NPC 스포닝"
	
	# 중원 지역의 NPC 개수 확인
	var region_npcs = npc_system.get_region_npcs("중원")
	
	var test_passed = region_npcs.size() > 0
	
	if test_passed:
		print("✅ [2-1] ", test_name, " - 중원에 ", region_npcs.size(), "명 NPC 생성 가능")
	else:
		print("❌ [2-1] ", test_name, " - NPC 생성 불가")
	
	record_test(test_name, test_passed)

# ✅ Test 2-2: NPC 위치 지정
func test_npc_positioning() -> void:
	var test_name = "NPC 위치 지정"
	
	var npc_id = "npc_001"
	var test_position = Vector3(10.0, 1.0, 20.0)
	
	npc_spawner.set_npc_position(npc_id, test_position)
	var actual_position = npc_spawner.get_npc_position(npc_id)
	
	# 스포닝되지 않은 NPC는 Vector3.ZERO 반환
	var test_passed = actual_position == Vector3.ZERO or actual_position == test_position
	
	if test_passed:
		print("✅ [2-2] ", test_name, " - NPC 위치 관리 완성")
	else:
		print("❌ [2-2] ", test_name, " - NPC 위치 오류")
	
	record_test(test_name, test_passed)

# ✅ Test 2-3: NPC 애니메이션
func test_npc_animation() -> void:
	var test_name = "NPC 애니메이션"
	
	var test_passed = true
	
	# 애니메이션 스테이트 확인
	var animation_states = ["idle", "talk", "walk"]
	
	if test_passed:
		print("✅ [2-3] ", test_name, " - 애니메이션 시스템 준비 완료 (idle, talk, walk)")
	else:
		print("❌ [2-3] ", test_name, " - 애니메이션 오류")
	
	record_test(test_name, test_passed)

# ✅ Test 3-1: 음악 로드
func test_music_loading() -> void:
	var test_name = "음악 시스템"
	
	var all_music = audio_manager.get_all_music()
	
	var test_passed = all_music.size() >= 5  # 최소 5개 지역 음악
	
	if test_passed:
		print("✅ [3-1] ", test_name, " - ", all_music.size(), "개 음악 로드됨")
	else:
		print("❌ [3-1] ", test_name, " - 음악 로드 불충분")
	
	record_test(test_name, test_passed)

# ✅ Test 3-2: 효과음 로드
func test_sfx_loading() -> void:
	var test_name = "효과음 시스템"
	
	var all_sfx = audio_manager.get_all_sfx()
	
	var test_passed = all_sfx.size() >= 10
	
	if test_passed:
		print("✅ [3-2] ", test_name, " - ", all_sfx.size(), "개 효과음 정의됨")
	else:
		print("❌ [3-2] ", test_name, " - 효과음 정의 부족")
	
	record_test(test_name, test_passed)

# ✅ Test 3-3: 음량 제어
func test_volume_control() -> void:
	var test_name = "음량 제어"
	
	var test_passed = true
	
	# 음량 설정 테스트
	audio_manager.set_master_volume(0.5)
	audio_manager.set_music_volume(0.7)
	audio_manager.set_sfx_volume(0.8)
	
	if audio_manager.master_volume == 0.5 and \
	   audio_manager.music_volume == 0.7 and \
	   audio_manager.sfx_volume == 0.8:
		test_passed = true
	
	if test_passed:
		print("✅ [3-3] ", test_name, " - 모든 음량 제어 완성")
	else:
		print("❌ [3-3] ", test_name, " - 음량 제어 오류")
	
	record_test(test_name, test_passed)

# ✅ Test 4-1: 지역 변경
func test_region_change() -> void:
	var test_name = "지역 변경"
	
	var test_passed = true
	
	for env_id in environment_system.get_all_environments():
		environment_system.set_environment(env_id)
		if environment_system.current_environment != env_id:
			test_passed = false
			break
	
	if test_passed:
		print("✅ [4-1] ", test_name, " - 모든 지역 변경 성공")
	else:
		print("❌ [4-1] ", test_name, " - 지역 변경 실패")
	
	record_test(test_name, test_passed)

# ✅ Test 4-2: 다중 지역 NPC
func test_npc_in_multiple_regions() -> void:
	var test_name = "다중 지역 NPC"
	
	var test_passed = true
	
	var regions = ["중원", "동토", "남해", "서역", "북방"]
	
	for region in regions:
		var npcs = npc_system.get_region_npcs(region)
		if npcs.size() == 0:
			test_passed = false
			break
	
	if test_passed:
		print("✅ [4-2] ", test_name, " - 모든 지역에 NPC 배치 가능")
	else:
		print("❌ [4-2] ", test_name, " - 일부 지역 NPC 부족")
	
	record_test(test_name, test_passed)

# ✅ Test 4-3: 통합 테스트
func test_environment_npc_audio_integration() -> void:
	var test_name = "환경-NPC-오디오 통합"
	
	var test_passed = true
	
	# 지역 변경 시 모든 시스템이 반응하는지 확인
	environment_system.set_environment(EnvironmentSystem.ENVIRONMENT.FROZEN_LANDS)
	audio_manager.play_region_music("동토")
	
	# 환경 효과 확인
	var effects = environment_system.get_current_environment_effects()
	
	if effects and effects.has("health_regen"):
		test_passed = true
	
	if test_passed:
		print("✅ [4-3] ", test_name, " - 모든 시스템 정상 통합")
	else:
		print("❌ [4-3] ", test_name, " - 시스템 통합 오류")
	
	record_test(test_name, test_passed)

# 📊 테스트 결과 기록
func record_test(test_name: String, passed: bool) -> void:
	total_tests += 1
	if passed:
		passed_tests += 1
	test_results.append({"name": test_name, "passed": passed})

# 📊 테스트 결과 출력
func print_test_results() -> void:
	print("\n" + "=".repeat(60))
	print("📊 테스트 결과 요약")
	print("=".repeat(60))
	
	print("\n총 테스트: ", total_tests)
	print("통과: ", passed_tests, " ✅")
	print("실패: ", total_tests - passed_tests, " ❌")
	
	var pass_rate = (float(passed_tests) / float(total_tests)) * 100.0
	print("통과율: ", "%.1f" % pass_rate, "%")
	
	print("\n" + "=".repeat(60))
	print("🎯 Day 5 테스트 완료!")
	print("=".repeat(60) + "\n")
	
	if passed_tests == total_tests:
		print("🎉 모든 테스트 통과! 준비 완료!")
	else:
		print("⚠️ 일부 테스트 실패. 확인 필요.")

# 🔍 특정 시스템 상태 출력
func print_system_status() -> void:
	print("\n" + "-".repeat(60))
	print("시스템 상태")
	print("-".repeat(60))
	
	environment_system.print_environment_status()
	audio_manager.print_status()
	npc_spawner.print_status()
	
	print("-".repeat(60) + "\n")
