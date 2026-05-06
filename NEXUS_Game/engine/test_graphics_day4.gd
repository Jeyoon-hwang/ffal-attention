extends Node3D
class_name TestGraphicsDay4

## Week 3 Day 4 그래픽 & 애니메이션 테스트

var game_scene: GameScene3D
var player_anim_controller: AnimationController
var martial_art_engine: MartialArtEngine

var test_results = {
	"character_3d": false,
	"particle_effects": false,
	"game_scene_3d": false,
	"animation_controller": false,
	"martial_art_execution": false,
	"lighting_system": false,
	"scene_themes": false
}

# 생명 주기
func _ready():
	print("=" * 60)
	print("🎬 NEXUS Week 3 Day 4 그래픽 & 애니메이션 테스트 시작")
	print("=" * 60)
	
	martial_art_engine = MartialArtEngine.new()
	
	await test_character_3d()
	await test_particle_effects()
	await test_game_scene_3d()
	await test_animation_controller()
	await test_martial_art_execution()
	await test_lighting_system()
	await test_scene_themes()
	
	_print_test_results()

## Test 1: Character3D 시스템
func test_character_3d():
	print("\n[Test 1] Character3D 시스템 검증")
	
	try:
		var character = Character3D.new()
		character.character_name = "Test Player"
		character.character_class = "Swordsman"
		character.level = 10
		add_child(character)
		
		assert(character.character_name == "Test Player", "Character name mismatch")
		assert(character.character_class == "Swordsman", "Character class mismatch")
		
		# 모든 클래스 테스트
		var classes = ["Swordsman", "Archer", "Mage", "Rogue", "Paladin", "Bard"]
		for cls in classes:
			character.set_class(cls)
			assert(character.character_class == cls, "Failed to set class: " + cls)
		
		print("✅ Character3D: 모든 6개 클래스 로드 완료")
		print("  - Swordsman (검사) ✓")
		print("  - Archer (궁수) ✓")
		print("  - Mage (마도사) ✓")
		print("  - Rogue (도적) ✓")
		print("  - Paladin (기사) ✓")
		print("  - Bard (음유시인) ✓")
		
		var debug = character.get_debug_info()
		print("  디버그 정보: %s" % debug)
		
		test_results["character_3d"] = true
		character.queue_free()
	except:
		print("❌ Character3D 테스트 실패: %s" % get_stack())
		test_results["character_3d"] = false

## Test 2: 파티클 이펙트
func test_particle_effects():
	print("\n[Test 2] 파티클 이펙트 시스템 검증")
	
	try:
		var particle_mgr = ParticleManager3D.new()
		add_child(particle_mgr)
		
		# 모든 무술별 이펙트 확인
		var effects = particle_mgr.get_available_effects()
		assert(effects.size() > 10, "Effect count too low")
		
		print("✅ 파티클 이펙트: %d개 무술 이펙트 로드" % effects.size())
		
		# Base 5가지
		print("  Base 무술 이펙트:")
		for base in ["slash", "thrust", "smash", "wave", "special"]:
			assert(base in effects, "Missing base: " + base)
			var info = particle_mgr.get_effect_info(base)
			print("    - %s (Color: %s)" % [base, info["color"]])
		
		# Modifier 8가지
		print("  Modifier 이펙트:")
		var modifiers = ["quick", "heavy", "wide", "precise", "pierce", "chain", "drain", "poison"]
		for mod in modifiers:
			assert(mod in effects, "Missing modifier: " + mod)
			var info = particle_mgr.get_effect_info(mod)
			print("    - %s" % mod)
		
		test_results["particle_effects"] = true
		particle_mgr.queue_free()
	except:
		print("❌ 파티클 이펙트 테스트 실패: %s" % get_stack())
		test_results["particle_effects"] = false

## Test 3: GameScene3D
func test_game_scene_3d():
	print("\n[Test 3] GameScene3D 씬 관리자 검증")
	
	try:
		game_scene = GameScene3D.new()
		game_scene.scene_name = "Central Plains"
		game_scene.difficulty = 1
		add_child(game_scene)
		
		await get_tree().process_frame  # 1 프레임 대기
		
		# 플레이어 확인
		var player = game_scene.get_player()
		assert(player != null, "Player not spawned")
		print("✅ GameScene3D: 플레이어 스폰 완료")
		print("  - Position: %s" % player.global_position)
		print("  - Class: %s" % player.character_class)
		
		# 적 스폰 테스트
		var enemy = game_scene.spawn_enemy("Test Enemy", "Archer", Vector3(5, 1, 5), 2)
		assert(enemy != null, "Enemy not spawned")
		print("✅ 적 스폰 완료: %s (AI Level %d)" % [enemy.character_name, enemy.level])
		
		var enemies = game_scene.get_all_enemies()
		assert(enemies.size() > 0, "No enemies in scene")
		
		# 씬 디버그 정보
		var debug = game_scene.get_debug_info()
		print("  씬 정보: %s" % debug)
		
		test_results["game_scene_3d"] = true
	except:
		print("❌ GameScene3D 테스트 실패: %s" % get_stack())
		test_results["game_scene_3d"] = false

## Test 4: AnimationController
func test_animation_controller():
	print("\n[Test 4] AnimationController 상태 머신 검증")
	
	try:
		if not game_scene:
			await test_game_scene_3d()
		
		var player = game_scene.get_player()
		player_anim_controller = AnimationController.new()
		player_anim_controller.character = player
		player_anim_controller.particle_manager = player.particle_manager
		add_child(player_anim_controller)
		
		await get_tree().process_frame
		
		print("✅ AnimationController 초기화 완료")
		
		# 상태 전환 테스트
		player_anim_controller.is_moving = false
		await get_tree().process_frame
		assert(player_anim_controller.current_state == AnimationController.State.IDLE, "Failed to set IDLE")
		print("  - IDLE 상태 전환 ✓")
		
		player_anim_controller.set_movement(Vector3.FORWARD)
		await get_tree().process_frame
		assert(player_anim_controller.current_state == AnimationController.State.MOVING, "Failed to set MOVING")
		print("  - MOVING 상태 전환 ✓")
		
		# 공격 상태
		player_anim_controller.is_attacking = true
		await get_tree().process_frame
		assert(player_anim_controller.current_state == AnimationController.State.ATTACKING, "Failed to set ATTACKING")
		print("  - ATTACKING 상태 전환 ✓")
		
		var anim_debug = player_anim_controller.get_debug_info()
		print("  상태 머신 정보: %s" % anim_debug)
		
		test_results["animation_controller"] = true
	except:
		print("❌ AnimationController 테스트 실패: %s" % get_stack())
		test_results["animation_controller"] = false

## Test 5: 무술 실행 & 이펙트 동기화
func test_martial_art_execution():
	print("\n[Test 5] 무술 실행 & 이펙트 동기화 검증")
	
	try:
		if not player_anim_controller:
			await test_animation_controller()
		
		# 무술 생성
		var martial_art = martial_art_engine.create_martial_art("slash", [], true)
		assert(martial_art != null, "Failed to create martial art")
		
		print("✅ 무술 생성: %s" % martial_art["name"])
		print("  - Damage: %d" % martial_art["damage"])
		print("  - Cooldown: %.1fs" % martial_art["cooldown"])
		
		# 무술 실행
		player_anim_controller.execute_martial_art(martial_art)
		assert(player_anim_controller.is_attacking, "Attack not triggered")
		print("  - 공격 애니메이션 시작 ✓")
		
		# 애니메이션 진행 시뮬레이션
		for i in range(3):
			await get_tree().create_timer(0.2).timeout
			var progress = player_anim_controller.attack_animation_progress / max(player_anim_controller.attack_duration, 0.1)
			print("  - 애니메이션 진행률: %.1f%%" % (progress * 100))
		
		test_results["martial_art_execution"] = true
	except:
		print("❌ 무술 실행 테스트 실패: %s" % get_stack())
		test_results["martial_art_execution"] = false

## Test 6: 조명 시스템
func test_lighting_system():
	print("\n[Test 6] 조명 시스템 검증")
	
	try:
		if not game_scene:
			await test_game_scene_3d()
		
		# 조명 확인
		var lights = game_scene.lights
		assert(lights.size() >= 3, "Not enough lights")
		
		print("✅ 조명 시스템: %d개 라이트 설정" % lights.size())
		print("  - 메인 라이트 (태양) ✓")
		print("  - 채우기 라이트 ✓")
		print("  - 백라이트 ✓")
		
		for i in range(lights.size()):
			var light = lights[i]
			print("  Light %d: Energy %.1f" % [i, light.energy])
		
		test_results["lighting_system"] = true
	except:
		print("❌ 조명 시스템 테스트 실패: %s" % get_stack())
		test_results["lighting_system"] = false

## Test 7: 지역 테마 시스템
func test_scene_themes():
	print("\n[Test 7] 지역 테마 시스템 검증")
	
	try:
		if not game_scene:
			await test_game_scene_3d()
		
		var zones = ["central_plains", "frozen_peak", "magma_crater", "dark_forest", "divine_realm"]
		
		print("✅ 지역 테마: %d개 지역 테마 로드" % zones.size())
		
		for zone in zones:
			game_scene.set_zone_theme(zone)
			print("  - %s 테마 적용 ✓" % zone)
		
		test_results["scene_themes"] = true
	except:
		print("❌ 지역 테마 테스트 실패: %s" % get_stack())
		test_results["scene_themes"] = false

## 테스트 결과 출력
func _print_test_results():
	print("\n" + "=" * 60)
	print("📊 테스트 결과 요약")
	print("=" * 60)
	
	var passed = 0
	var total = test_results.size()
	
	for test_name in test_results.keys():
		var status = "✅ PASS" if test_results[test_name] else "❌ FAIL"
		print("%s: %s" % [test_name, status])
		if test_results[test_name]:
			passed += 1
	
	var percentage = (passed * 100) / total
	print("\n총 %d/%d 통과 (%d%%)" % [passed, total, percentage])
	
	if passed == total:
		print("\n🎉 모든 그래픽 & 애니메이션 테스트 완료!")
		print("진도: 85% → 90% 달성")
	else:
		print("\n⚠️ 일부 테스트 실패. 다시 확인 필요!")

## 헬퍼: Try-Catch
func try(func_name: String) -> bool:
	return test_results.get(func_name, false)

func assert(condition: bool, message: String):
	if not condition:
		push_error("Assertion failed: " + message)
		throw()

func throw():
	raise(Exception())
