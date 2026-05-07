# quest_system.gd - 퀘스트 시스템
# 200+ 퀘스트 생성, 관리, 추적

extends Node

# 퀘스트 클래스
class Quest:
	var id: String
	var title: String
	var description: String
	var giver: String  # NPC 이름
	var giver_region: String
	var level_required: int
	var type: String  # "main", "side", "daily", "event", "hidden"
	
	var objectives: Array = []  # 목표 목록
	var rewards: Dictionary = {}  # exp, gold, items
	var prerequisites: Array = []  # 선행 퀘스트들
	var next_quests: Array = []  # 다음 퀘스트들
	
	var completion_count: int = 0  # 완료 횟수
	var is_repeatable: bool = false
	var dialog_choices: Array = []  # 대사 선택지
	
	func _init(p_id: String, p_title: String, p_giver: String, p_type: String, p_level: int):
		id = p_id
		title = p_title
		giver = p_giver
		type = p_type
		level_required = p_level
		rewards = {
			"exp": 100 * p_level,
			"gold": 50 * p_level,
			"items": p_level
		}

class QuestObjective:
	var id: String
	var description: String
	var type: String  # "kill", "collect", "talk", "explore", "deliver"
	var target: String
	var target_count: int
	var progress: int = 0
	
	func _init(p_id: String, p_desc: String, p_type: String, p_target: String, p_count: int):
		id = p_id
		description = p_desc
		type = p_type
		target = p_target
		target_count = p_count

class QuestChain:
	"""퀘스트 체인 (여러 퀘스트가 연결됨)"""
	var id: String
	var name: String
	var quests: Array = []
	var total_reward: Dictionary = {}
	
	func _init(p_id: String, p_name: String):
		id = p_id
		name = p_name

# 모든 퀘스트 저장소
var quests: Dictionary = {}
var quest_chains: Dictionary = {}

# 퀘스트 유형별 개수
var quest_count_targets = {
	"main": 10,
	"side": 100,
	"daily": 50,
	"event": 20,
	"hidden": 20
}

func _ready():
	generate_all_quests()
	create_quest_chains()
	print_quest_summary()

# === 퀘스트 생성 함수들 ===

func generate_all_quests():
	"""모든 퀘스트 생성 (200+)"""
	
	# 메인 퀘스트 (10개)
	generate_main_quests()
	
	# 사이드 퀘스트 (100개)
	generate_side_quests()
	
	# 데일리 퀘스트 (50개)
	generate_daily_quests()
	
	# 이벤트 퀘스트 (20개)
	generate_event_quests()
	
	# 숨겨진 퀘스트 (20개)
	generate_hidden_quests()
	
	print("[Quest System] %d개 퀘스트 생성 완료" % quests.size())

func generate_main_quests():
	"""메인 퀘스트 10개 생성"""
	
	var main_quests = [
		{"id": "main_1", "title": "새로운 시작", "giver": "은사 청운", "level": 1},
		{"id": "main_2", "title": "5대파의 비밀", "giver": "도사 무", "level": 3},
		{"id": "main_3", "title": "동토의 수수께끼", "giver": "얼음 도사 한", "level": 2},
		{"id": "main_4", "title": "남해의 보물", "giver": "해적 두목", "level": 3},
		{"id": "main_5", "title": "사막의 진실", "giver": "황금 도사", "level": 2},
		{"id": "main_6", "title": "봉인된 힘", "giver": "노 도사", "level": 4},
		{"id": "main_7", "title": "음모의 실마리", "giver": "수행자 진", "level": 3},
		{"id": "main_8", "title": "최강의 도장", "giver": "은사 청운", "level": 4},
		{"id": "main_9", "title": "우주의 비밀", "giver": "노 도사", "level": 4},
		{"id": "main_10", "title": "진정한 영웅", "giver": "은사 청운", "level": 5}
	]
	
	for q_data in main_quests:
		var quest = Quest.new(q_data["id"], q_data["title"], q_data["giver"], "main", q_data["level"])
		quest.description = "[메인] %s를 완료하세요." % q_data["title"]
		
		# 목표 설정
		var objective = QuestObjective.new(
			q_data["id"] + "_obj",
			"목표 완료",
			"kill",
			"보스",
			1
		)
		quest.objectives.append(objective)
		
		quests[q_data["id"]] = quest

func generate_side_quests():
	"""사이드 퀘스트 100개 생성"""
	
	var quest_types = ["kill", "collect", "talk", "explore", "deliver"]
	var regions = ["zhongyuan", "dongtu", "nanhai", "xiyou", "beifang"]
	var npc_list = [
		"은사 청운", "상인 왕자", "수행자 진", "이발소 주인", "도사 무",
		"얼음 도사 한", "설인 사냥꾼", "빙설 수사", "보급 상인",
		"해적 두목", "상인 돌핀", "나침반 제작자", "어부 칼",
		"황금 도사", "카라반 주인", "사막 가이드", "보물 사냥꾼",
		"노 도사", "산 정령 보호자", "약초 채집꾼", "비밀 수행자"
	]
	
	for i in range(100):
		var quest_id = "side_%d" % (i + 1)
		var giver = npc_list[i % npc_list.size()]
		var giver_region = regions[i % regions.size()]
		var quest_type = quest_types[i % quest_types.size()]
		var level = (i % 4) + 1
		
		var titles = {
			"kill": ["처치", "격퇴", "제거"],
			"collect": ["수집", "모으기", "찾기"],
			"talk": ["대화", "대면", "확인"],
			"explore": ["탐험", "발견", "조사"],
			"deliver": ["배달", "운반", "전달"]
		}
		
		var title_base = titles[quest_type][i % 3]
		var title = "%s %d" % [title_base, i + 1]
		
		var quest = Quest.new(quest_id, title, giver, "side", level)
		quest.description = "%s 님의 부탁: %s" % [giver, title]
		quest.giver_region = giver_region
		quest.is_repeatable = true
		
		# 목표 설정
		var objective = QuestObjective.new(
			quest_id + "_obj",
			"목표 진행",
			quest_type,
			"대상_%d" % i,
			randi_range(1, 10)
		)
		quest.objectives.append(objective)
		
		quests[quest_id] = quest

func generate_daily_quests():
	"""데일리 퀘스트 50개 생성"""
	
	var daily_titles = [
		"전투 훈련 (%d)", "몬스터 사냥 (%d)", "아이템 수집 (%d)",
		"지역 탐험 (%d)", "경험치 쌓기 (%d)"
	]
	
	for i in range(50):
		var quest_id = "daily_%d" % (i + 1)
		var level = (i % 4) + 1
		var title_template = daily_titles[i % daily_titles.size()]
		var title = title_template % (i + 1)
		var giver = "일일 훈련소" if i < 25 else "일일 사냥터"
		
		var quest = Quest.new(quest_id, title, giver, "daily", level)
		quest.description = "매일 도전할 수 있는 퀘스트입니다."
		quest.is_repeatable = true
		
		# 목표 설정
		var objective = QuestObjective.new(
			quest_id + "_obj",
			"목표 달성",
			"kill",
			"무작위 몬스터",
			randi_range(5, 15)
		)
		quest.objectives.append(objective)
		
		quests[quest_id] = quest

func generate_event_quests():
	"""이벤트 퀘스트 20개 생성"""
	
	var event_themes = [
		"봄 축제", "여름 대회", "가을 수확", "겨울 축제",
		"보름달 이벤트", "특별 전투", "공동 토벌"
	]
	
	for i in range(20):
		var quest_id = "event_%d" % (i + 1)
		var level = (i % 4) + 1
		var theme = event_themes[i % event_themes.size()]
		var title = "%s - 이벤트 %d" % [theme, i + 1]
		var giver = "이벤트 관리자"
		
		var quest = Quest.new(quest_id, title, giver, "event", level)
		quest.description = "[특별 이벤트] %s 참여" % theme
		
		# 목표 설정
		var objective = QuestObjective.new(
			quest_id + "_obj",
			"이벤트 완료",
			"explore",
			theme,
			1
		)
		quest.objectives.append(objective)
		
		quests[quest_id] = quest

func generate_hidden_quests():
	"""숨겨진 퀘스트 20개 생성"""
	
	var hidden_titles = [
		"비밀의 방", "숨겨진 보물", "저주 풀기",
		"잊혀진 영혼", "어둠의 비밀", "시간 역행",
		"평행 세계", "신비한 존재", "무한 던전"
	]
	
	for i in range(20):
		var quest_id = "hidden_%d" % (i + 1)
		var level = (i % 4) + 2  # 레벨 2이상
		var title = hidden_titles[i % hidden_titles.size()]
		var giver = "미스터리한 존재"
		
		var quest = Quest.new(quest_id, title, giver, "hidden", level)
		quest.description = "[숨겨진] 특별한 조건에서만 나타납니다..."
		
		# 선행 조건 (다른 퀘스트)
		if i > 0:
			quest.prerequisites.append("hidden_%d" % i)
		
		# 목표 설정
		var objective = QuestObjective.new(
			quest_id + "_obj",
			"미스터리 풀기",
			"collect",
			"신비한 물건",
			randi_range(1, 5)
		)
		quest.objectives.append(objective)
		
		quests[quest_id] = quest

func create_quest_chains():
	"""퀨스트 체인 생성 (연결된 퀘스트)"""
	
	# 메인 퀨스트 체인
	var main_chain = QuestChain.new("chain_main", "메인 스토리")
	for i in range(1, 11):
		main_chain.quests.append("main_%d" % i)
	quest_chains["chain_main"] = main_chain
	
	# 각 지역별 퀨스트 체인
	var regions = ["zhongyuan", "dongtu", "nanhai", "xiyou", "beifang"]
	for region_id in regions:
		var region_chain = QuestChain.new("chain_%s" % region_id, "%s 지역 퀘스트" % region_id)
		
		# 해당 지역의 사이드 퀘스트 일부
		var count = 0
		for i in range(1, 101):
			if count >= 20:
				break
			var quest = quests.get("side_%d" % i)
			if quest and quest.giver_region == region_id:
				region_chain.quests.append("side_%d" % i)
				count += 1
		
		quest_chains["chain_%s" % region_id] = region_chain

# === 퀨스트 조회 함수들 ===

func get_quest(quest_id: String) -> Quest:
	"""퀘스트 ID로 조회"""
	return quests.get(quest_id)

func get_all_quests() -> Array:
	"""모든 퀘스트 반환"""
	return quests.values()

func get_quests_by_type(quest_type: String) -> Array:
	"""타입별 퀨스트 반환"""
	var result = []
	for quest in quests.values():
		if quest.type == quest_type:
			result.append(quest)
	return result

func get_quests_by_giver(giver_name: String) -> Array:
	"""NPC별 퀨스트 반환"""
	var result = []
	for quest in quests.values():
		if quest.giver == giver_name:
			result.append(quest)
	return result

func get_quests_by_level(level: int) -> Array:
	"""난이도별 퀨스트 반환"""
	var result = []
	for quest in quests.values():
		if quest.level_required == level:
			result.append(quest)
	return result

func get_quests_by_region(region_id: String) -> Array:
	"""지역별 퀨스트 반환"""
	var result = []
	for quest in quests.values():
		if quest.giver_region == region_id:
			result.append(quest)
	return result

# === 퀨스트 체인 조회 ===

func get_quest_chain(chain_id: String) -> QuestChain:
	"""퀨스트 체인 조회"""
	return quest_chains.get(chain_id)

func get_all_quest_chains() -> Array:
	"""모든 퀨스트 체인"""
	return quest_chains.values()

# === 통계 함수들 ===

func get_total_quest_count() -> int:
	"""전체 퀘스트 수"""
	return quests.size()

func get_quest_count_by_type(quest_type: String) -> int:
	"""타입별 퀴스트 수"""
	return get_quests_by_type(quest_type).size()

func print_quest_summary():
	"""전체 퀨스트 요약"""
	print("\n=== 퀨스트 시스템 요약 ===")
	
	print("\n[타입별 퀨스트]")
	for quest_type in quest_count_targets.keys():
		var count = get_quest_count_by_type(quest_type)
		print("  %s: %d개" % [quest_type, count])
	
	print("\n=== 전체 통계 ===")
	print("총 퀨스트: %d개" % [get_total_quest_count()])
	print("총 체인: %d개" % [quest_chains.size()])
