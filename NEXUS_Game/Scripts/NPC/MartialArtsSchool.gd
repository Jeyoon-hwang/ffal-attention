## MartialArtsSchool.gd - 무술관 (중원 지역)
##
## 무술을 배우고 강화할 수 있는 시설
## 마스터와 제자들이 운영

extends Node3D

class_name MartialArtsSchool

# 무술관 정보
var school_name: String = "천산 무술관"
var school_description: String = "천산의 전설적인 무술관"
var location: Vector3 = Vector3(100, 0, 100)
var master_name: String = "천산 장인"

# 제공 무술 목록
var available_martial_arts: Array[Dictionary] = []

# 강화 시스템
var upgrade_system: Dictionary = {}

# 수련생들 (내부 NPC)
var disciples: Array[Dictionary] = []

# 통계
var total_students: int = 0
var total_taught: int = 0

func _init() -> void:
	"""초기화"""
	initialize_school()

## 무술관 초기화
func initialize_school() -> void:
	"""무술관 초기화"""
	
	# 무술 목록 설정
	setup_martial_arts()
	
	# 강화 시스템 설정
	setup_upgrade_system()
	
	# 수련생 설정
	setup_disciples()
	
	print("[%s] 무술관 초기화 완료!" % school_name)
	print("  • 마스터: %s" % master_name)
	print("  • 제공 무술: %d개" % available_martial_arts.size())
	print("  • 강화 항목: %d개" % upgrade_system.size())

## 무술 목록 설정
func setup_martial_arts() -> void:
	"""무술 목록 설정"""
	
	available_martial_arts = [
		# 기초 무술
		{
			"id": "basic_punch",
			"name": "천권",
			"description": "기초 권법. 일직선으로 빠르게 날린다.",
			"level": 1,
			"cost": 0,  # 무료
			"damage": 1.0,
			"speed": 1.0,
			"reach": 1.0,
			"attributes": {"strength": 10}
		},
		{
			"id": "tiger_strike",
			"name": "호발",
			"description": "호랑이처럼 강력한 발차기.",
			"level": 1,
			"cost": 50,  # 50원
			"damage": 1.2,
			"speed": 0.8,
			"reach": 1.1,
			"attributes": {"strength": 15}
		},
		{
			"id": "triple_chain",
			"name": "삼단연격",
			"description": "3단 콤보 공격. 연결력이 좋다.",
			"level": 1,
			"cost": 100,  # 100원
			"damage": 0.8,
			"speed": 1.3,
			"reach": 0.9,
			"attributes": {"dexterity": 15}
		},
		{
			"id": "evade",
			"name": "회피술",
			"description": "적의 공격을 피하는 기술.",
			"level": 1,
			"cost": 75,  # 75원
			"damage": 0.0,
			"speed": 1.5,
			"reach": 0.0,
			"attributes": {"dexterity": 20}
		},
		# 고급 무술 (레벨업 후 학습)
		{
			"id": "mountain_storm",
			"name": "천산폭풍",
			"description": "천산의 폭풍을 부르는 강력한 기술. (Lv.5+)",
			"level": 5,
			"cost": 200,
			"damage": 2.0,
			"speed": 1.2,
			"reach": 1.5,
			"attributes": {"strength": 30, "wisdom": 10}
		},
		{
			"id": "shadow_clone",
			"name": "분신술",
			"description": "분신을 만들어 적을 혼란시킨다. (Lv.10+)",
			"level": 10,
			"cost": 300,
			"damage": 1.0,
			"speed": 1.0,
			"reach": 1.0,
			"attributes": {"dexterity": 30, "wisdom": 20}
		}
	]

## 강화 시스템 설정
func setup_upgrade_system() -> void:
	"""강화 시스템 설정"""
	
	upgrade_system = {
		"damage": {
			"name": "데미지 강화",
			"description": "공격력을 1.5배로 증가",
			"cost": 10,  # 스킬 포인트
			"multiplier": 1.5
		},
		"speed": {
			"name": "속도 강화",
			"description": "공격 속도를 1.25배로 증가",
			"cost": 12,
			"multiplier": 1.25
		},
		"reach": {
			"name": "리치 강화",
			"description": "공격 범위를 1.2배로 증가",
			"cost": 8,
			"multiplier": 1.2
		},
		"combo": {
			"name": "콤보 강화",
			"description": "콤보 연결성을 1.3배로 증가",
			"cost": 15,
			"multiplier": 1.3
		}
	}

## 수련생 설정
func setup_disciples() -> void:
	"""무술관의 수련생들 설정"""
	
	disciples = [
		{
			"name": "무술 수련생",
			"level": 1,
			"count": 3,
			"is_trainee": true
		},
		{
			"name": "무술 감독",
			"level": 2,
			"count": 1,
			"is_trainee": false
		}
	]

## 플레이어에게 무술 교수
func teach_martial_art(player: Node, martial_id: String) -> bool:
	"""플레이어에게 무술 교수"""
	
	for martial in available_martial_arts:
		if martial["id"] == martial_id:
			# 레벨 확인
			if player.level < martial["level"]:
				print("[%s] 아직 이 무술을 배울 수 없습니다. (필요 레벨: %d)" % [school_name, martial["level"]])
				return false
			
			# 골드 확인
			if player.gold >= martial["cost"]:
				player.gold -= martial["cost"]
				
				# 무술 습득 (Player 클래스에 추가 예정)
				# player.add_martial_art(martial)
				
				total_taught += 1
				print("[%s] %s 무술을 습득했습니다! (학습인원: %d)" % [
					school_name,
					martial["name"],
					total_taught
				])
				return true
			else:
				print("[%s] 골드가 부족합니다. (필요: %d, 보유: %d)" % [
					school_name,
					martial["cost"],
					player.gold
				])
				return false
	
	print("[%s] 해당 무술을 찾을 수 없습니다." % school_name)
	return false

## 무술 강화
func upgrade_martial_art(player: Node, martial_id: String, upgrade_type: String) -> bool:
	"""플레이어의 무술 강화"""
	
	# 강화 종류 확인
	if upgrade_type not in upgrade_system:
		print("[%s] 해당 강화를 찾을 수 없습니다." % school_name)
		return false
	
	var upgrade = upgrade_system[upgrade_type]
	
	# 스킬 포인트 확인
	if player.skill_points >= upgrade["cost"]:
		player.skill_points -= upgrade["cost"]
		
		print("[%s] %s을(를) 강화했습니다!" % [school_name, upgrade["name"]])
		print("  • 비용: 스킬 포인트 %d" % upgrade["cost"])
		print("  • 효과: %s" % upgrade["description"])
		
		return true
	else:
		print("[%s] 스킬 포인트가 부족합니다. (필요: %d, 보유: %d)" % [
			school_name,
			upgrade["cost"],
			player.skill_points
		])
		return false

## 무술 정보 조회
func get_martial_art_info(martial_id: String) -> Dictionary:
	"""무술 정보 반환"""
	
	for martial in available_martial_arts:
		if martial["id"] == martial_id:
			return martial
	
	return {}

## 배울 수 있는 무술 목록
func get_learnable_martial_arts(player_level: int) -> Array[Dictionary]:
	"""현재 레벨에서 배울 수 있는 무술 목록"""
	
	var learnable: Array[Dictionary] = []
	
	for martial in available_martial_arts:
		if player_level >= martial["level"]:
			learnable.append(martial)
	
	return learnable

## 강화 정보 조회
func get_upgrade_info(upgrade_type: String) -> Dictionary:
	"""강화 정보 반환"""
	
	if upgrade_type in upgrade_system:
		return upgrade_system[upgrade_type]
	
	return {}

## 무술관 정보 출력
func print_school_info() -> void:
	"""무술관 정보 출력"""
	
	print("\n" + "="*50)
	print("🏛️  %s" % school_name)
	print("="*50)
	print("마스터: %s" % master_name)
	print("설명: %s" % school_description)
	print("위치: (%.1f, %.1f, %.1f)" % [location.x, location.y, location.z])
	print("누적 학생: %d명" % total_students)
	print("누적 교습: %d건" % total_taught)
	
	print("\n[제공 무술]")
	for martial in available_martial_arts:
		print("  • %s (Lv.%d, %d원)" % [martial["name"], martial["level"], martial["cost"]])
		print("    - %s" % martial["description"])
	
	print("\n[강화 시스템]")
	for upgrade_key in upgrade_system:
		var upgrade = upgrade_system[upgrade_key]
		print("  • %s (스킬포인트 %d)" % [upgrade["name"], upgrade["cost"]])
		print("    - %s" % upgrade["description"])

## 무술관 시뮬레이션
func simulate_visit(player: Node) -> void:
	"""무술관 방문 시뮬레이션"""
	
	print("\n" + "="*50)
	print("🏛️  %s 방문 시뮬레이션" % school_name)
	print("="*50 + "\n")
	
	print("[상황] 플레이어가 무술관에 들어간다.")
	print("\n마스터: '환영한다, 젊은이.'")
	print("마스터: '내가 너에게 무술을 전수하겠노라.'")
	
	# 무술 배우기
	print("\n[플레이어가 무술을 배우기로 결정]")
	teach_martial_art(player, "basic_punch")
	teach_martial_art(player, "tiger_strike")
	teach_martial_art(player, "evade")
	
	# 무술 강화
	if player.skill_points > 0:
		print("\n[플레이어가 무술을 강화]")
		upgrade_martial_art(player, "basic_punch", "damage")
	
	print("\n마스터: '수고했다, 젊은이!'")
	print("="*50)

## 통계
func get_statistics() -> Dictionary:
	"""무술관 통계"""
	
	return {
		"school_name": school_name,
		"master_name": master_name,
		"martial_art_count": available_martial_arts.size(),
		"upgrade_type_count": upgrade_system.size(),
		"total_students": total_students,
		"total_taught": total_taught,
		"disciples": disciples
	}
