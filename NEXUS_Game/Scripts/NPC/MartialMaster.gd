## MartialMaster.gd - 무술관 마스터 (NPC)
##
## 천산 장인: 무술관의 주인이자 마스터
## 무술을 가르치고 강화를 돕는다

extends NPC

class_name MartialMaster

# 마스터 특성
var title: String = "천산 장인"
var rank: String = "대사범"
var years_of_experience: int = 50
var specialty: String = "천산파 무술"

# 소속 무술관
var associated_school: MartialArtsSchool

# 마스터의 기술
var master_techniques: Array[String] = [
	"천권",
	"호발",
	"삼단연격",
	"천산폭풍",
	"분신술"
]

func _init(school: MartialArtsSchool = null) -> void:
	"""마스터 NPC 초기화"""
	super._init(title, "martial_master")
	
	npc_id = "martial_master_chuongyeon"
	description = "천산 무술관의 마스터. 무술을 전수해준다."
	world_position = Vector3(100, 0, 100)
	affinity = 50  # 중립적
	
	dialogue = [
		"환영한다, 젊은이.",
		"내가 너에게 무술을 전수하겠노라.",
		"천산의 정신을 배워가거라.",
		"그 정도면 충분하다. 수고했다!"
	]
	
	interaction_options = [
		"무술 배우기",
		"무술 강화하기",
		"마스터에게 물어보기",
		"작별 인사"
	]
	
	# 무술관 연결
	if school:
		associated_school = school
	else:
		associated_school = MartialArtsSchool.new()

## 플레이어 상호작용 오버라이드
func interact(player: Node) -> void:
	"""플레이어와 상호작용"""
	print("\n[%s]" % npc_name)
	speak_dialogue()
	
	if interaction_options.size() > 0:
		print("\n  선택지:")
		for i in range(interaction_options.size()):
			print("    %d. %s" % [i + 1, interaction_options[i]])

## 옵션 처리 오버라이드
func handle_option(option_index: int, player: Node) -> void:
	"""옵션 처리"""
	
	match option_index:
		0:  # 무술 배우기
			show_learnable_martial_arts(player)
		
		1:  # 무술 강화하기
			show_upgrade_options(player)
		
		2:  # 마스터에게 물어보기
			answer_question(player)
		
		3:  # 작별
			say_goodbye()

## 배울 수 있는 무술 목록 표시
func show_learnable_martial_arts(player: Node) -> void:
	"""배울 수 있는 무술 목록 표시"""
	
	print("\n[마스터: 자네의 수준에 맞는 무술들이네.]")
	
	var learnable = associated_school.get_learnable_martial_arts(player.level)
	
	if learnable.size() == 0:
		print("마스터: 아직 배울 무술이 없군...")
		return
	
	print("\n[배울 수 있는 무술]")
	for i in range(learnable.size()):
		var martial = learnable[i]
		var status = "✓" if martial["cost"] <= player.gold else "✗"
		print("  %s %d. %s (Lv.%d, %d원)" % [
			status,
			i + 1,
			martial["name"],
			martial["level"],
			martial["cost"]
		])
		print("     - %s" % martial["description"])

## 강화 옵션 표시
func show_upgrade_options(player: Node) -> void:
	"""강화 옵션 표시"""
	
	print("\n[마스터: 기술을 더 정련해야겠군.]")
	print("\n[강화 옵션]")
	
	var upgrade_system = associated_school.upgrade_system
	for upgrade_key in upgrade_system:
		var upgrade = upgrade_system[upgrade_key]
		var status = "✓" if upgrade["cost"] <= player.skill_points else "✗"
		print("  %s • %s (스킬포인트 %d)" % [
			status,
			upgrade["name"],
			upgrade["cost"]
		])
		print("    - %s" % upgrade["description"])

## 질문에 답변
func answer_question(player: Node) -> void:
	"""플레이어의 질문에 답변"""
	
	var answers = [
		"수련이 가장 중요하다. 계속 노력하거라.",
		"천산의 무술은 세상에서 가장 우수한 무술이다.",
		"보스를 찾아 맞서거라. 그것이 실력을 높이는 가장 빠른 길이다.",
		"호감도를 쌓으면 특별한 기술을 전수해주겠노라.",
		"아, 그건 네 스스로 깨달아야 한다.",
		"먼저 기초를 완성해야 한다. 서두르지 마거라."
	]
	
	var answer = answers[randi() % answers.size()]
	print("\n마스터: '%s'" % answer)

## 작별 인사
func say_goodbye() -> void:
	"""작별 인사"""
	print("\n마스터: '수고했다, 젊은이. 곧 다시 보자.'")

## 특별 기술 전수 (호감도 조건)
func teach_special_technique(player: Node) -> bool:
	"""호감도가 높으면 특별 기술 전수"""
	
	if affinity >= 80:
		var special = "천산의 최종 기술"
		print("\n마스터: '자네의 열정이 맘에 든다.'")
		print("마스터: '이 기술은 제자들만 배울 수 있는 것이다. 받아가거라.'")
		print("[%s을(를) 습득했습니다!]" % special)
		return true
	else:
		print("\n마스터: '아직 멀었군... 더 노력해보게.'")
		return false

## 마스터 정보 출력
func print_master_info() -> void:
	"""마스터 정보 출력"""
	
	print("\n" + "="*50)
	print("🥋 %s" % npc_name)
	print("="*50)
	print("직책: %s" % rank)
	print("무술: %s" % specialty)
	print("경력: %d년" % years_of_experience)
	print("호감도: %d/100" % affinity)
	print("감정: %s" % mood)
	
	print("\n[마스터의 기술]")
	for technique in master_techniques:
		print("  • %s" % technique)
	
	print("\n[제공 서비스]")
	for option in interaction_options:
		print("  • %s" % option)

## 마스터 시뮬레이션
func simulate_interaction(player: Node) -> void:
	"""마스터와의 상호작용 시뮬레이션"""
	
	print("\n" + "="*50)
	print("🥋 천산 장인과의 만남 (시뮬레이션)")
	print("="*50 + "\n")
	
	print("[상황] 플레이어가 무술관에 들어간다.")
	print("\n마스터를 발견했습니다.")
	
	# 상호작용
	interact(player)
	
	# 옵션 선택 (시뮬레이션)
	print("\n[플레이어: '무술 배우기']")
	show_learnable_martial_arts(player)
	
	print("\n[플레이어: '무술 강화하기']")
	show_upgrade_options(player)
	
	print("\n[플레이어: '마스터에게 물어보기']")
	answer_question(player)
	
	print("\n[플레이어: '작별 인사']")
	say_goodbye()
	
	print("\n" + "="*50)

## 통계
func get_statistics() -> Dictionary:
	"""마스터 통계"""
	
	return {
		"name": npc_name,
		"rank": rank,
		"specialty": specialty,
		"experience_years": years_of_experience,
		"technique_count": master_techniques.size(),
		"affinity": affinity,
		"mood": mood
	}
