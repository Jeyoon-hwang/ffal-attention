# dialogue_system.gd - 대화 시스템, NPC와 상호작용
# 작성: 천재 ⚡
# 2026-05-07 Day 4

extends Node

# ============================================================
# 대화 시스템: NPC와의 상호작용, 분기 대사, 친밀도 시스템
# ============================================================

class DialogueNode:
	var id: String
	var text: String
	var speaker: String
	var emotion: String  # happy, sad, neutral, angry, surprised
	var choices: Array = []
	var action: String = ""  # quest, trade, fight, leave
	
	func _init(node_id: String, node_text: String, speaker_name: String,
			   speaker_emotion: String) -> void:
		self.id = node_id
		self.text = node_text
		self.speaker = speaker_name
		self.emotion = speaker_emotion

class DialogueChoice:
	var id: String
	var text: String
	var next_node: String
	var affinity_change: int
	var reward: Dictionary = {}
	
	func _init(choice_id: String, choice_text: String, next_id: String,
			   aff_change: int) -> void:
		self.id = choice_id
		self.text = choice_text
		self.next_node = next_id
		self.affinity_change = aff_change

# 현재 대화
var current_dialogue_id: String = ""
var current_npc_id: String = ""
var dialogue_history: Array = []
var dialogue_trees: Dictionary = {}  # npc_id -> dialogue_tree

# 감정 이모지
var emotion_emojis = {
	"happy": "😊",
	"sad": "😢",
	"neutral": "😐",
	"angry": "😠",
	"surprised": "😲"
}

# 대화 액션 설명
var action_texts = {
	"quest": "📋 �へスト를 받았습니다!",
	"trade": "🛍️ 물품을 구매했습니다!",
	"fight": "⚔️ 결투를 시작합니다!",
	"leave": "👋 대화를 끝냈습니다."
}

# 초기화
func _init() -> void:
	generate_dialogue_trees()

# ============================================================
# 대화 트리 생성
# ============================================================

func generate_dialogue_trees() -> void:
	var tree_counter = 0
	
	# 각 NPC 타입별 대화 트리
	var npc_types = [
		{"name": "상인", "greeting": "좋은 물건이 있으면 사가실래?", "action": "trade"},
		{"name": "스승", "greeting": "무술을 배우고 싶은가?", "action": "quest"},
		{"name": "마법사", "greeting": "마법의 신비로움을 느껴보시겠는가?", "action": "quest"},
		{"name": "전사", "greeting": "한판 떠볼래?", "action": "fight"},
		{"name": "여관주인", "greeting": "어서 오세요, 피곤하신 것 같은데?", "action": "none"},
		{"name": "주민", "greeting": "뭐하는 사람이세요?", "action": "none"}
	]
	
	for npc_type in npc_types:
		var tree = generate_npc_dialogue_tree(npc_type)
		dialogue_trees[npc_type["name"]] = tree
		tree_counter += 1
	
	print("[Dialogue System] 총 " + str(tree_counter) + "개의 대화 트리 생성 완료")

# NPC 타입별 대화 트리 생성
func generate_npc_dialogue_tree(npc_type: Dictionary) -> Dictionary:
	var tree = {}
	var npc_name = npc_type["name"]
	
	# 인사말 노드
	var greeting_node = DialogueNode.new(
		"%s_greeting" % npc_name,
		npc_type["greeting"],
		npc_name,
		"happy"
	)
	
	# 선택지 1: 긍정
	var choice_yes = DialogueChoice.new(
		"%s_choice_yes" % npc_name,
		"네, 좋습니다.",
		"%s_yes_response" % npc_name,
		10
	)
	
	# 선택지 2: 부정
	var choice_no = DialogueChoice.new(
		"%s_choice_no" % npc_name,
		"아니요, 괜찮습니다.",
		"%s_no_response" % npc_name,
		-5
	)
	
	greeting_node.choices.append(choice_yes)
	greeting_node.choices.append(choice_no)
	greeting_node.action = npc_type["action"]
	
	tree["greeting"] = greeting_node
	
	# 긍정 응답 노드
	var yes_response = DialogueNode.new(
		"%s_yes_response" % npc_name,
		get_positive_response(npc_type["action"]),
		npc_name,
		"happy"
	)
	
	# 종료 선택지
	var choice_end = DialogueChoice.new(
		"%s_choice_end_yes" % npc_name,
		"감사합니다!",
		"end",
		5
	)
	yes_response.choices.append(choice_end)
	yes_response.action = npc_type["action"]
	
	tree["yes_response"] = yes_response
	
	# 부정 응답 노드
	var no_response = DialogueNode.new(
		"%s_no_response" % npc_name,
		get_negative_response(npc_type["action"]),
		npc_name,
		"sad"
	)
	
	var choice_end_no = DialogueChoice.new(
		"%s_choice_end_no" % npc_name,
		"네, 안녕히 계세요.",
		"end",
		0
	)
	no_response.choices.append(choice_end_no)
	
	tree["no_response"] = no_response
	
	return tree

# 액션별 긍정 응답
func get_positive_response(action: String) -> String:
	var responses = {
		"trade": "그럼 좋은 물건들을 보여드릴게. 어떤 걸 찾으신가?",
		"quest": "좋아, 당신의 도움이 필요해. 이 퀘스트를 들어주겠나?",
		"fight": "좋은 기백이야. 그럼 진검승부를 펼쳐보자!",
		"none": "그렇군. 얘기라도 나누고 싶지 않으신가?"
	}
	return responses.get(action, "좋아, 그럼...")

# 액션별 부정 응답
func get_negative_response(action: String) -> String:
	var responses = {
		"trade": "아, 그렇군. 필요하실 땐 언제든 찾아오세요.",
		"quest": "아쉽네. 하지만 언젠가는 필요할 때가 있을 거야.",
		"fight": "흠, 무술이 부족한가 봐. 다음에 다시 오게.",
		"none": "그렇군. 혹시 모르니 조심해서 다녀요."
	}
	return responses.get(action, "그렇군...")

# ============================================================
# 대화 진행
# ============================================================

# 대화 시작
func start_dialogue(npc_id: String, npc_name: String) -> DialogueNode:
	current_npc_id = npc_id
	current_dialogue_id = "%s_greeting" % npc_name
	
	var tree = dialogue_trees.get(npc_name, {})
	if tree.has("greeting"):
		var node = tree["greeting"]
		dialogue_history.append(node.id)
		return node
	
	return null

# 선택지 선택
func choose_option(choice_id: String) -> DialogueNode:
	var tree = dialogue_trees.get_current_npc_tree()
	
	if tree.is_empty():
		return null
	
	# 현재 노드 찾기
	var current_node = null
	for node in tree.values():
		if node.id == current_dialogue_id:
			current_node = node
			break
	
	if current_node == null:
		return null
	
	# 선택지 찾기
	var choice = null
	for c in current_node.choices:
		if c.id == choice_id:
			choice = c
			break
	
	if choice == null:
		return null
	
	# 친밀도 변경
	if current_npc_id in get_tree().root.get_node("/root"):
		# NPC 친밀도 업데이트
		pass
	
	# 다음 노드로 이동
	current_dialogue_id = choice.next_node
	dialogue_history.append(choice.next_node)
	
	if choice.next_node == "end":
		return null
	
	var next_node = tree.get(choice.next_node)
	return next_node

# 대화 종료
func end_dialogue() -> void:
	current_npc_id = ""
	current_dialogue_id = ""

# 현재 NPC 대화 트리 가져오기
func get_current_npc_tree() -> Dictionary:
	# NPC ID에서 타입 추출
	var parts = current_npc_id.split("_")
	if parts.size() > 0:
		var npc_type = parts[0]
		return dialogue_trees.get(npc_type, {})
	return {}

# ============================================================
# 대화 유틸리티
# ============================================================

# 현재 대화 노드 가져오기
func get_current_node() -> DialogueNode:
	var tree = get_current_npc_tree()
	
	for node in tree.values():
		if node.id == current_dialogue_id:
			return node
	
	return null

# 대화 히스토리
func get_dialogue_history() -> Array:
	return dialogue_history.duplicate()

# 대화 초기화
func clear_dialogue_history() -> void:
	dialogue_history.clear()

# 대화 노드의 선택지 표시
func print_dialogue_options() -> void:
	var node = get_current_node()
	if node == null:
		return
	
	print("\n" + node.speaker + " (" + node.emotion + ") " + emotion_emojis[node.emotion])
	print(node.text)
	print("\n선택지:")
	
	for i in range(node.choices.size()):
		var choice = node.choices[i]
		var affinity_str = "+" + str(choice.affinity_change) if choice.affinity_change >= 0 else str(choice.affinity_change)
		print("  [" + str(i + 1) + "] " + choice.text + " (친밀도: " + affinity_str + ")")

# 게임 통계
func print_game_status() -> void:
	print("\n" + "="*50)
	print("💬 대화 시스템 통계")
	print("="*50)
	
	var total_nodes = 0
	var total_choices = 0
	
	for npc_type in dialogue_trees.keys():
		var tree = dialogue_trees[npc_type]
		total_nodes += tree.size()
		
		for node in tree.values():
			total_choices += node.choices.size()
	
	print("\n📊 통계:")
	print("  NPC 타입: " + str(dialogue_trees.keys().size()) + "개")
	print("  총 대화 노드: " + str(total_nodes) + "개")
	print("  총 선택지: " + str(total_choices) + "개")
	
	print("\n대화 히스토리: " + str(dialogue_history.size()) + "개 노드")
	print("="*50 + "\n")

# ============================================================
