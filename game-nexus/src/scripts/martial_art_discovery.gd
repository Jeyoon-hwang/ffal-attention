# 무술 발견 시스템 (Martial Arts Discovery System)
# 고서, NPC, 던전에서 무술 요소 발견

extends Node

class AncientScroll:
	var name: String
	var location: Vector3
	var martial_elements: Array  # [기초, 스타일, 패턴, 효과] 중 하나
	var discovered: bool = false
	var rarity: String  # 일반, 희귀, 전설
	
	func _init(p_name: String, p_location: Vector3):
		name = p_name
		location = p_location
		rarity = ["일반", "희귀", "전설"][randi() % 3]

# 고서 데이터베이스 (500개+)
var ancient_scrolls: Array[AncientScroll] = []

# 무술 요소 희귀도
var rarity_rates = {
	"일반": {"bases": 5, "styles": 3, "patterns": 3, "effects": 1},
	"희귀": {"bases": 1, "styles": 1, "patterns": 1, "effects": 1},
	"전설": {"bases": 0, "styles": 0, "patterns": 0, "effects": 1},
}

# 플레이어의 발견한 요소
var discovered_elements = {
	"bases": [],
	"styles": [],
	"patterns": [],
	"effects": []
}

func _ready():
	generate_ancient_scrolls()

# 고서 생성 (500개+)
func generate_ancient_scrolls():
	var scroll_count = 500
	
	for i in range(scroll_count):
		var x = randf_range(-50000, 50000)
		var z = randf_range(-50000, 50000)
		var position = Vector3(x, 0, z)
		
		var scroll = AncientScroll.new(
			"고서-%d" % i,
			position
		)
		
		ancient_scrolls.append(scroll)
	
	print("✅ 고서 %d개 생성 완료" % scroll_count)

# 고서 발견
func discover_scroll(scroll: AncientScroll) -> Array:
	if scroll.discovered:
		return []  # 이미 발견함
	
	scroll.discovered = true
	var gained_elements = []
	
	# 희귀도에 따라 요소 습득
	var elements_data = rarity_rates[scroll.rarity]
	
	# 기초 요소
	for i in range(elements_data["bases"]):
		var element = get_random_element("bases")
		if element not in discovered_elements["bases"]:
			discovered_elements["bases"].append(element)
			gained_elements.append({"type": "기초", "name": element, "rarity": scroll.rarity})
	
	# 스타일 요소
	for i in range(elements_data["styles"]):
		var element = get_random_element("styles")
		if element not in discovered_elements["styles"]:
			discovered_elements["styles"].append(element)
			gained_elements.append({"type": "스타일", "name": element, "rarity": scroll.rarity})
	
	# 패턴 요소
	for i in range(elements_data["patterns"]):
		var element = get_random_element("patterns")
		if element not in discovered_elements["patterns"]:
			discovered_elements["patterns"].append(element)
			gained_elements.append({"type": "패턴", "name": element, "rarity": scroll.rarity})
	
	# 효과 요소
	for i in range(elements_data["effects"]):
		var element = get_random_element("effects")
		if element not in discovered_elements["effects"]:
			discovered_elements["effects"].append(element)
			gained_elements.append({"type": "효과", "name": element, "rarity": scroll.rarity})
	
	print("📜 고서 발견: %s (%s)" % [scroll.name, scroll.rarity])
	for elem in gained_elements:
		print("  → %s: %s" % [elem["type"], elem["name"]])
	
	return gained_elements

# 무작위 요소 선택
func get_random_element(element_type: String) -> String:
	var element_lists = {
		"bases": ["주먹", "발", "검", "채", "손가락", "팔", "다리", "머리", "내력", "기운"],
		"styles": ["강경", "부드러움", "빠름", "느림", "날카로움", "둔함", "우아함", "야만", "섬세함", "폭발", "조용함", "우렁참", "회전", "직선", "곡선", "연계", "단순", "복잡", "침착", "광기"],
		"patterns": ["일직선", "원형", "대각선", "지그재그", "나선형", "파동", "폭발", "집중", "산포", "다단", "관통", "광선", "충격", "진동", "뒤틀림", "얼음", "불", "바람", "땅", "어둠", "빛", "독", "생명", "정신", "시간", "공간", "중력", "음파", "기운", "영혼"],
		"effects": ["타격", "내력", "회전", "파동", "연쇄", "폭발", "절단", "관통", "부수기", "마비", "감속", "중독", "화상", "결빙", "혼란", "공포", "흡수", "강화", "약화", "반사", "방어", "회피", "이동", "비행", "치유", "부활", "현혹", "분신", "차원", "운명", "무한"]
	}
	
	var elements = element_lists.get(element_type, [])
	if elements.is_empty():
		return ""
	
	return elements[randi() % elements.size()]

# NPC에게 무술 배우기
func learn_martial_art_from_npc(npc_name: String, martial_art_name: String) -> bool:
	print("📖 %s에게서 '%s' 무술 배움!" % [npc_name, martial_art_name])
	return true

# 던전 클리어 보상
func clear_dungeon_reward(dungeon_name: String) -> Array:
	var rewards = []
	
	# 랜덤하게 무술 요소 또는 고서 보상
	var reward_type = ["요소", "고서", "장비"][randi() % 3]
	
	if reward_type == "요소":
		# 무술 요소 3개 보상
		for i in range(3):
			var element_type = ["bases", "styles", "patterns", "effects"][randi() % 4]
			var element = get_random_element(element_type)
			if element not in discovered_elements[element_type]:
				discovered_elements[element_type].append(element)
				rewards.append({
					"type": "요소",
					"category": element_type,
					"name": element
				})
	
	elif reward_type == "고서":
		# 고서 1개 보상
		var scroll = ancient_scrolls.filter(func(s): return not s.discovered)[0]
		if scroll:
			var gained = discover_scroll(scroll)
			rewards.append_array(gained)
	
	print("🏆 던전 클리어 보상: %s" % dungeon_name)
	for reward in rewards:
		print("  → %s" % reward)
	
	return rewards

# 전투 경험 학습
func learn_from_combat(enemy_name: String, enemy_martial_art: String) -> Array:
	var learned = []
	
	# 적의 무술로부터 기초 요소 습득 (확률)
	if randf() < 0.3:  # 30% 확률
		var base = get_random_element("bases")
		if base not in discovered_elements["bases"]:
			discovered_elements["bases"].append(base)
			learned.append(base)
	
	if learned.size() > 0:
		print("⚔️ %s와의 전투에서 기술 습득: %s" % [enemy_name, ", ".join(learned)])
	
	return learned

# 자각 & 창조 (오래된 무술 조합으로 새 무술 발명)
func enlightenment_create(bases: Array, styles: Array, patterns: Array, effects: Array) -> String:
	print("💡 깨달음! 새로운 무술을 창조했습니다!")
	print("  기초: %s" % ", ".join(bases))
	print("  스타일: %s" % ", ".join(styles))
	print("  패턴: %s" % ", ".join(patterns))
	print("  효과: %s" % ", ".join(effects))
	return "새로운 무술"

# 발견 진행률
func get_discovery_progress() -> Dictionary:
	var martial_art_engine = get_node("/root/Main/MartialArtEngine")
	var total_bases = martial_art_engine.base_elements.size()
	var total_styles = martial_art_engine.style_elements.size()
	var total_patterns = martial_art_engine.pattern_elements.size()
	var total_effects = martial_art_engine.effect_elements.size()
	
	return {
		"bases": {"discovered": discovered_elements["bases"].size(), "total": total_bases},
		"styles": {"discovered": discovered_elements["styles"].size(), "total": total_styles},
		"patterns": {"discovered": discovered_elements["patterns"].size(), "total": total_patterns},
		"effects": {"discovered": discovered_elements["effects"].size(), "total": total_effects},
	}

# 진행률 출력
func print_discovery_progress():
	var progress = get_discovery_progress()
	
	print("\n=== 무술 요소 발견 진행률 ===")
	print("기초: %d / %d (%.1f%%)" % [
		progress["bases"]["discovered"],
		progress["bases"]["total"],
		float(progress["bases"]["discovered"]) / progress["bases"]["total"] * 100
	])
	print("스타일: %d / %d (%.1f%%)" % [
		progress["styles"]["discovered"],
		progress["styles"]["total"],
		float(progress["styles"]["discovered"]) / progress["styles"]["total"] * 100
	])
	print("패턴: %d / %d (%.1f%%)" % [
		progress["patterns"]["discovered"],
		progress["patterns"]["total"],
		float(progress["patterns"]["discovered"]) / progress["patterns"]["total"] * 100
	])
	print("효과: %d / %d (%.1f%%)" % [
		progress["effects"]["discovered"],
		progress["effects"]["total"],
		float(progress["effects"]["discovered"]) / progress["effects"]["total"] * 100
	])
	
	var total_discovered = (progress["bases"]["discovered"] + progress["styles"]["discovered"] + 
							progress["patterns"]["discovered"] + progress["effects"]["discovered"])
	var total_all = (progress["bases"]["total"] + progress["styles"]["total"] + 
					 progress["patterns"]["total"] + progress["effects"]["total"])
	
	print("\n전체: %d / %d (%.1f%%)" % [total_discovered, total_all, float(total_discovered) / total_all * 100])
	print("\n발견한 고서: %d / %d" % [
		ancient_scrolls.filter(func(s): return s.discovered).size(),
		ancient_scrolls.size()
	])

# 높은 난이도 무술 생성 가능 확인
func can_create_advanced_martial_arts() -> bool:
	var discovered_count = (discovered_elements["bases"].size() + 
							discovered_elements["styles"].size() + 
							discovered_elements["patterns"].size() + 
							discovered_elements["effects"].size())
	return discovered_count >= 30  # 최소 30개 요소 필요
