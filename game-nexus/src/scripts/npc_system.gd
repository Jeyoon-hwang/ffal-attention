# npc_system.gd - 100+ NPC 시스템, 대화, 거래, 친밀도
# 작성: 천재 ⚡
# 2026-05-07 Day 4

extends Node

# ============================================================
# NPC 시스템: 100+ NPC 자동 생성, 대화, 거래, 친밀도 관리
# ============================================================

class NPCPerson:
	var id: String
	var name: String
	var region: String
	var job: String
	var level: int
	var personality: String
	var dialogue_count: int = 0
	var affinity: int = 0  # -100 ~ 100
	var quest_given: bool = false
	var goods: Array = []  # 거래 물품
	
	func _init(npc_id: String, npc_name: String, npc_region: String, 
			   npc_job: String, npc_level: int, npc_personality: String) -> void:
		self.id = npc_id
		self.name = npc_name
		self.region = npc_region
		self.job = npc_job
		self.level = npc_level
		self.personality = npc_personality

class NPCDialogue:
	var id: String
	var npc_id: String
	var text: String
	var type: String  # greeting, quest, trade, story
	var affinity_min: int
	var affinity_max: int
	
	func _init(dialogue_id: String, npc_id: String, dialogue_text: String, 
			   dialogue_type: String, min_aff: int, max_aff: int) -> void:
		self.id = dialogue_id
		self.npc_id = npc_id
		self.text = dialogue_text
		self.type = dialogue_type
		self.affinity_min = min_aff
		self.affinity_max = max_aff

class NPCTrade:
	var id: String
	var npc_id: String
	var item_id: String
	var item_name: String
	var item_price: int
	var stock: int
	
	func _init(trade_id: String, npc_id: String, item_id: String, 
			   item_name: String, item_price: int, stock: int) -> void:
		self.id = trade_id
		self.npc_id = npc_id
		self.item_id = item_id
		self.item_name = item_name
		self.item_price = item_price
		self.stock = stock

# NPC 리스트
var npcs: Dictionary = {}  # npc_id -> NPCPerson
var dialogues: Dictionary = {}  # npc_id -> Array[NPCDialogue]
var trades: Dictionary = {}  # npc_id -> Array[NPCTrade]

# 지역별 NPC 리스트
var region_npcs: Dictionary = {
	"중원": [],
	"동토": [],
	"남해": [],
	"서역": [],
	"북방": []
}

# 직업 목록
var jobs: Array = [
	"상인", "마법사", "전사", "도둑", "사제", "낚시꾼", "대장간",
	"연금술사", "사냥꾼", "가드", "귀족", "가난한사람", "모험가", 
	"스승", "악당", "은둔자"
]

# 성격 목록
var personalities: Array = [
	"친절", "무뚝뚝", "장난", "진지", "겁쟁이", "용감", "탐욕", "관대",
	"신비", "부패", "순진", "지혜"
]

# 기본 대사 템플릿
var dialogue_templates: Dictionary = {
	"greeting": [
		"어서 왔네. 뭔가 도와줄 일이 있나?",
		"오, 처음 뵙는군.",
		"반갑네, 친구.",
		"뭐하는 거야?",
		"혹시 내가 도와줄 수 있는 게 있나?",
		"어디서 온 사람이야?",
		"오늘 날씨 참 좋지 않나?",
		"이 근처 처음이신가?",
		"뭔가 궁금한 게 있으면 말해줘.",
		"나한테는 나름의 신념이 있어."
	],
	"quest": [
		"사실 좀 도와줄 게 있는데...",
		"혹시 용감한 모험가인가?",
		"내가 부탁할 게 있다.",
		"이 일을 처리해주면 좋겠는데...",
		"혹시 시간이 있으면...",
		"실은 이런 일들이 쌓여있거든.",
		"혹시 나한테 빌려줄 수 있는 도움이 있을까?"
	],
	"trade": [
		"좋은 물품들이 있거든.",
		"뭔가 필요한 게 있나?",
		"이것들을 판매하고 있어.",
		"관심 있는 물품이 있나?",
		"좋은 거래라고 생각해."
	],
	"story": [
		"내 얘기를 좀 들어볼래?",
		"이 지역에는 많은 전설들이 있어.",
		"옛날 이야기를 들어본 적 있나?",
		"이 일이 벌어진 지 오래됐네.",
		"그게 뭐냐고 물어본다면... 길기도 하지."
	]
}

# 초기화
func _init() -> void:
	generate_npcs()
	generate_dialogues()
	generate_trades()

# ============================================================
# 100+ NPC 자동 생성
# ============================================================

func generate_npcs() -> void:
	var npc_counter = 0
	var regions = ["중원", "동토", "남해", "서역", "북방"]
	
	# 각 지역별 15-25명 NPC 생성
	for region in regions:
		var npc_count_per_region = 15 + randi() % 11  # 15-25명
		for i in range(npc_count_per_region):
			var npc_id = "%s_NPC_%03d" % [region, i + 1]
			var name = generate_npc_name(region)
			var job = jobs[randi() % jobs.size()]
			var level = (randi() % 4) + 1  # Level 1-4
			var personality = personalities[randi() % personalities.size()]
			
			var npc = NPCPerson.new(npc_id, name, region, job, level, personality)
			npc.goods = generate_npc_goods(job)
			
			npcs[npc_id] = npc
			region_npcs[region].append(npc_id)
			npc_counter += 1
	
	print("[NPC System] 총 " + str(npc_counter) + "명의 NPC 생성 완료")

# 지역별 이름 생성
func generate_npc_name(region: String) -> String:
	var names = {
		"중원": ["이순신", "류관순", "한성범", "박창", "정은희", "김철수", "이영희", 
				 "박민준", "최인호", "정미영", "강준호", "유미라", "이호진", "박수진"],
		"동토": ["알렉산더", "보리스", "이반", "유리", "밍크", "프로스트", "스노우", 
				 "얼음늑대", "블리자드", "겨울노인"],
		"남해": ["가우", "크루즈", "아리아", "마리나", "산타나", "파도", "조개", 
				 "산호", "해마", "해적왕"],
		"서역": ["아흐마드", "카심", "알라딘", "자스민", "신밧드", "사막귀신", "라이온",
				 "모래폭풍", "오아시스", "유목민"],
		"북방": ["아르스", "프로스트", "드래곤킬러", "얼음전사", "산의왕", "곰사냥꾼", 
				 "용감한심장", "산상의신", "절벽의수호자"]
	}
	return names[region][randi() % names[region].size()]

# NPC 직업별 물품 생성
func generate_npc_goods(job: String) -> Array:
	var goods_map = {
		"상인": ["여행자 통행증", "지도", "나침반", "여행자 식량"],
		"마법사": ["마나 물약", "주문서", "마법 부적", "수정구슬"],
		"전사": ["검", "방패", "갑옷", "투구"],
		"도둑": ["숨을 물건", "열쇠", "밧줄", "손가락장갑"],
		"사제": ["성수", "축복 부적", "신성한 경전"],
		"낚시꾼": ["물고기", "미끼", "낚싯대", "바구니"],
		"대장간": ["강철 막대", "도끼", "쇠망치", "철광석"],
		"연금술사": ["약초", "약물", "추출액", "연금석"],
		"사냥꾼": ["화살", "화살집", "사냥총", "짐승 가죽"],
		"가드": ["횃불", "방패", "검", "경찰봉"],
		"귀족": ["보석", "비단", "금화", "와인"],
		"가난한사람": ["빵", "물", "헝겊", "나무"],
		"모험가": ["생존 키트", "모험일지", "지팡이", "배낭"],
		"스승": ["비법서", "수련서", "무술 지팡이"],
		"악당": ["독약", "다크 부적", "검은 칼"],
		"은둔자": ["산삼", "약 백년초", "비방서"]
	}
	
	var goods = goods_map.get(job, ["일반 물건"])
	var result = []
	var num_goods = 1 + (randi() % 3)  # 1-3개
	
	for i in range(num_goods):
		result.append(goods[randi() % goods.size()])
	
	return result

# ============================================================
# NPC 대화 시스템
# ============================================================

func generate_dialogues() -> void:
	var total_dialogues = 0
	
	for npc_id in npcs.keys():
		var npc = npcs[npc_id]
		var npc_dialogues = []
		
		# 각 NPC당 6-10개 대사 생성
		var dialogue_count = 6 + (randi() % 5)
		
		for i in range(dialogue_count):
			var dialogue_type = ["greeting", "quest", "trade", "story"].pick_random()
			var text = get_random_dialogue(dialogue_type, npc)
			var affinity_min = randi() % 50 - 25  # -25 ~ 25
			var affinity_max = affinity_min + 50 + (randi() % 50)  # 적어도 50 범위
			
			var dialogue = NPCDialogue.new(
				"%s_DLG_%d" % [npc_id, i],
				npc_id,
				text,
				dialogue_type,
				affinity_min,
				affinity_max
			)
			
			npc_dialogues.append(dialogue)
			total_dialogues += 1
		
		dialogues[npc_id] = npc_dialogues

func get_random_dialogue(dialogue_type: String, npc: NPCPerson) -> String:
	var base_text = dialogue_templates[dialogue_type].pick_random()
	
	# NPC 성격에 맞춰 대사 수정
	if npc.personality == "무뚝뚝":
		return base_text.to_lower()
	elif npc.personality == "친절":
		return base_text + " 😊"
	elif npc.personality == "신비":
		return "음... " + base_text
	elif npc.personality == "용감":
		return base_text + " 두려움 따윈 없어!"
	
	return base_text

# ============================================================
# NPC 거래 시스템
# ============================================================

func generate_trades() -> void:
	var total_trades = 0
	
	for npc_id in npcs.keys():
		var npc = npcs[npc_id]
		var npc_trades = []
		
		# 각 NPC 물품당 거래 1개 생성
		for i in range(npc.goods.size()):
			var item_name = npc.goods[i]
			var item_price = 10 * (1 + randi() % 20)  # 10 ~ 210 골드
			var stock = 1 + (randi() % 10)  # 1-10개
			
			var trade = NPCTrade.new(
				"%s_TRADE_%d" % [npc_id, i],
				npc_id,
				"item_%d" % i,
				item_name,
				item_price,
				stock
			)
			
			npc_trades.append(trade)
			total_trades += 1
		
		trades[npc_id] = npc_trades

# ============================================================
# 조회 함수
# ============================================================

# NPC 조회
func get_npc(npc_id: String) -> NPCPerson:
	return npcs.get(npc_id)

# 지역 내 모든 NPC
func get_region_npcs(region: String) -> Array:
	var result = []
	for npc_id in region_npcs[region]:
		result.append(npcs[npc_id])
	return result

# NPC 수
func get_npc_count() -> int:
	return npcs.size()

# 지역별 NPC 수
func get_region_npc_count(region: String) -> int:
	return region_npcs[region].size()

# 특정 직업의 NPC들
func get_npcs_by_job(job: String) -> Array:
	var result = []
	for npc_id in npcs.keys():
		if npcs[npc_id].job == job:
			result.append(npcs[npc_id])
	return result

# NPC 대화 조회 (친밀도 기반)
func get_npc_dialogue(npc_id: String) -> NPCDialogue:
	var npc = npcs[npc_id]
	var available_dialogues = []
	
	for dialogue in dialogues[npc_id]:
		if npc.affinity >= dialogue.affinity_min and npc.affinity <= dialogue.affinity_max:
			available_dialogues.append(dialogue)
	
	if available_dialogues.is_empty():
		return dialogues[npc_id][0]
	
	return available_dialogues.pick_random()

# NPC 거래 조회
func get_npc_trades(npc_id: String) -> Array:
	return trades.get(npc_id, [])

# NPC 친밀도 변경
func change_affinity(npc_id: String, amount: int) -> void:
	if npcs.has(npc_id):
		npcs[npc_id].affinity = clamp(npcs[npc_id].affinity + amount, -100, 100)
		npcs[npc_id].dialogue_count += 1

# NPC 퀘스트 주기
func give_npc_quest(npc_id: String) -> bool:
	if npcs.has(npc_id) and not npcs[npc_id].quest_given:
		npcs[npc_id].quest_given = true
		change_affinity(npc_id, 10)
		return true
	return false

# NPC 구매
func buy_from_npc(npc_id: String, trade_id: String, quantity: int) -> int:
	if not trades.has(npc_id):
		return 0
	
	for trade in trades[npc_id]:
		if trade.id == trade_id and trade.stock >= quantity:
			trade.stock -= quantity
			return trade.item_price * quantity
	
	return 0

# NPC 판매
func sell_to_npc(npc_id: String, item_name: String, quantity: int) -> int:
	if npcs.has(npc_id):
		var npc = npcs[npc_id]
		var price = 5 + (randi() % 15)  # 5 ~ 20 골드/개
		return price * quantity
	return 0

# 게임 통계
func print_game_status() -> void:
	print("\n" + "="*50)
	print("🥋 NPC 시스템 통계")
	print("="*50)
	
	var total_npcs = 0
	var total_trades = 0
	var total_dialogues = 0
	
	for region in region_npcs.keys():
		var count = get_region_npc_count(region)
		total_npcs += count
		print("📍 " + region + ": " + str(count) + "명")
	
	for npc_id in npcs.keys():
		total_trades += trades[npc_id].size()
		total_dialogues += dialogues[npc_id].size()
	
	print("\n📊 통계:")
	print("  총 NPC: " + str(total_npcs) + "명")
	print("  총 거래 항목: " + str(total_trades) + "개")
	print("  총 대사: " + str(total_dialogues) + "개")
	print("="*50 + "\n")

# ============================================================
