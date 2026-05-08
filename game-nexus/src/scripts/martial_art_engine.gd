# 무술 생성 엔진 (Martial Arts Generator Engine)
# 수백만 가지 무술을 동적으로 생성

extends Node

# 무술 요소 데이터베이스
var base_elements = {
	"주먹": {"damage": 10, "speed": 1.0, "range": 2},
	"발": {"damage": 15, "speed": 0.8, "range": 3},
	"검": {"damage": 25, "speed": 1.2, "range": 5},
	"채": {"damage": 20, "speed": 0.7, "range": 4},
	"손가락": {"damage": 5, "speed": 2.0, "range": 1},
	"팔": {"damage": 12, "speed": 1.1, "range": 2.5},
	"다리": {"damage": 18, "speed": 0.9, "range": 3.5},
	"머리": {"damage": 8, "speed": 0.6, "range": 2},
	"내력": {"damage": 30, "speed": 0.5, "range": 10},
	"기운": {"damage": 20, "speed": 1.5, "range": 6},
}

var style_elements = {
	"강경": {"multiplier": 1.5, "defense": 1.0},
	"부드러움": {"multiplier": 0.8, "defense": 1.5},
	"빠름": {"multiplier": 0.9, "defense": 0.7, "speed_bonus": 1.5},
	"느림": {"multiplier": 1.3, "defense": 1.2, "speed_bonus": 0.7},
	"날카로움": {"multiplier": 1.2, "crit": 1.5},
	"둔함": {"multiplier": 1.1, "defense": 1.3},
	"우아함": {"multiplier": 1.0, "defense": 0.9, "accuracy": 1.2},
	"야만": {"multiplier": 1.4, "defense": 0.8},
	"섬세함": {"multiplier": 0.7, "accuracy": 2.0, "crit": 0.5},
	"폭발": {"multiplier": 1.6, "aoe": 1.5},
	"조용함": {"multiplier": 1.0, "stealth": 1.5},
	"우렁참": {"multiplier": 1.3, "aoe": 2.0},
	"회전": {"multiplier": 1.0, "spin": 1.0},
	"직선": {"multiplier": 1.2, "accuracy": 1.0},
	"곡선": {"multiplier": 1.1, "dodge": 1.3},
	"연계": {"multiplier": 0.8, "combo": 2.0},
	"단순": {"multiplier": 1.1, "speed_bonus": 1.4},
	"복잡": {"multiplier": 1.3, "skill_req": 2.0},
	"침착": {"multiplier": 1.0, "stability": 1.5},
	"광기": {"multiplier": 1.5, "stability": 0.5},
}

var pattern_elements = {
	"일직선": {"range": 1.0, "width": 0.5},
	"원형": {"range": 1.2, "width": 1.5},
	"대각선": {"range": 1.1, "width": 0.8},
	"지그재그": {"range": 0.9, "width": 0.7},
	"나선형": {"range": 1.3, "width": 1.2},
	"파동": {"range": 1.4, "width": 2.0},
	"폭발": {"range": 1.5, "width": 2.5},
	"집중": {"range": 0.5, "width": 0.3},
	"산포": {"range": 2.0, "width": 3.0},
	"다단": {"range": 1.0, "hits": 5},
	"관통": {"range": 3.0, "width": 0.2},
	"광선": {"range": 5.0, "width": 0.1},
	"충격": {"range": 1.0, "impact": 2.0},
	"진동": {"range": 2.0, "wave": 1.5},
	"뒤틀림": {"range": 1.5, "distortion": 1.0},
	"얼음": {"range": 1.2, "freeze": 1.0},
	"불": {"range": 1.3, "burn": 1.0},
	"바람": {"range": 1.4, "knockback": 1.5},
	"땅": {"range": 1.0, "stun": 1.0},
	"어둠": {"range": 1.5, "blind": 1.0},
	"빛": {"range": 1.2, "light": 1.0},
	"독": {"range": 1.1, "poison": 1.0},
	"생명": {"range": 1.0, "heal": 1.0},
	"정신": {"range": 1.3, "confusion": 1.0},
	"시간": {"range": 1.5, "slow": 1.0},
	"공간": {"range": 2.0, "teleport": 1.0},
	"중력": {"range": 1.4, "pull": 1.0},
	"음파": {"range": 1.5, "stun_range": 2.0},
	"기운": {"range": 1.6, "aura": 1.0},
	"영혼": {"range": 1.7, "spirit": 1.0},
}

var effect_elements = {
	"타격": {"type": "impact", "power": 1.0},
	"내력": {"type": "internal", "power": 1.2},
	"회전": {"type": "spin", "power": 0.9},
	"파동": {"type": "wave", "power": 1.1},
	"연쇄": {"type": "chain", "power": 0.8, "multi": 5},
	"폭발": {"type": "explosion", "power": 1.3},
	"절단": {"type": "cut", "power": 1.0},
	"관통": {"type": "pierce", "power": 1.1},
	"부수기": {"type": "crush", "power": 1.4},
	"마비": {"type": "stun", "power": 0.5, "duration": 3},
	"감속": {"type": "slow", "power": 0.6, "duration": 5},
	"중독": {"type": "poison", "power": 0.7, "duration": 10},
	"화상": {"type": "burn", "power": 0.8, "duration": 8},
	"결빙": {"type": "freeze", "power": 0.9, "duration": 4},
	"혼란": {"type": "confusion", "power": 0.5, "duration": 6},
	"공포": {"type": "fear", "power": 0.4, "duration": 5},
	"흡수": {"type": "absorb", "power": 1.0, "heal": 0.5},
	"강화": {"type": "buff", "power": 0.5, "boost": 1.5},
	"약화": {"type": "debuff", "power": 0.6, "reduce": 0.5},
	"반사": {"type": "reflect", "power": 0.8, "reflect_ratio": 0.5},
	"방어": {"type": "shield", "power": 0.5, "defense": 2.0},
	"회피": {"type": "dodge", "power": 0.3, "dodge_rate": 0.8},
	"이동": {"type": "teleport", "power": 0.2, "distance": 10},
	"비행": {"type": "flight", "power": 0.1, "height": 20},
	"치유": {"type": "heal", "power": 1.0, "heal_amount": 50},
	"부활": {"type": "revive", "power": 2.0, "heal_amount": 100},
	"현혹": {"type": "illusion", "power": 0.7},
	"분신": {"type": "clone", "power": 0.9, "count": 3},
	"차원": {"type": "dimension", "power": 1.2},
	"운명": {"type": "fate", "power": 1.5},
	"무한": {"type": "infinite", "power": 2.0},
}

# 무술 클래스
class MartialArt:
	var id: String  # 고유 ID
	var name: String
	var bases: Array  # 기초 요소들
	var styles: Array  # 스타일 요소들
	var patterns: Array  # 패턴 요소들
	var effects: Array  # 효과 요소들
	
	var level: int = 1
	var damage: float
	var speed: float
	var accuracy: float
	var cooldown: float
	var description: String
	var color: Color
	var discovered_at: String
	
	func _init():
		id = str(hash(self))
		damage = 10.0
		speed = 1.0
		accuracy = 1.0
		cooldown = 1.0
		color = Color.WHITE
		discovered_at = Time.get_datetime_string_from_system()

# 생성된 무술 저장소
var all_martial_arts = {}  # ID → MartialArt
var discovered_martial_arts = []  # 발견한 무술
var player_martial_arts = []  # 플레이어가 만든 무술

func _ready():
	generate_base_martial_arts()

# 기초 무술 생성 (모든 1가지 요소)
func generate_base_martial_arts():
	for base_name in base_elements.keys():
		var ma = MartialArt.new()
		ma.name = base_name
		ma.bases = [base_name]
		ma.damage = base_elements[base_name]["damage"]
		ma.speed = base_elements[base_name]["speed"]
		ma.description = "%s를(을) 사용하는 기초 무술" % base_name
		
		all_martial_arts[ma.id] = ma
		discovered_martial_arts.append(ma.id)

# 새로운 무술 생성
func create_martial_art(selected_bases: Array, selected_styles: Array, 
					   selected_patterns: Array, selected_effects: Array,
					   custom_name: String = "") -> MartialArt:
	var ma = MartialArt.new()
	
	# 요소 설정
	ma.bases = selected_bases
	ma.styles = selected_styles
	ma.patterns = selected_patterns
	ma.effects = selected_effects
	
	# 이름 생성 (또는 사용자 입력)
	if custom_name.is_empty():
		ma.name = generate_martial_art_name(selected_bases, selected_styles, selected_patterns)
	else:
		ma.name = custom_name
	
	# 스탯 계산
	calculate_martial_art_stats(ma)
	
	# 설명 생성
	ma.description = generate_martial_art_description(ma)
	
	# 색상 생성 (요소 기반)
	ma.color = generate_martial_art_color(selected_effects)
	
	# 저장
	all_martial_arts[ma.id] = ma
	player_martial_arts.append(ma)
	
	return ma

# 무술 이름 자동 생성
func generate_martial_art_name(bases: Array, styles: Array, patterns: Array) -> String:
	var parts = []
	
	if bases.size() > 0:
		parts.append(bases[0])
	
	if styles.size() > 0:
		parts.append(styles[0])
	
	if patterns.size() > 0:
		var pattern = patterns[0]
		if pattern == "일직선":
			parts.append("직")
		elif pattern == "원형":
			parts.append("환")
		elif pattern == "나선형":
			parts.append("선")
	
	var suffix = ["술", "법", "궤", "도"][randi() % 4]
	
	return "".join(parts) + suffix

# 무술 스탯 계산
func calculate_martial_art_stats(ma: MartialArt):
	ma.damage = 10.0
	ma.speed = 1.0
	ma.accuracy = 1.0
	ma.cooldown = 1.0
	
	# 기초 요소 보너스
	for base in ma.bases:
		if base in base_elements:
			ma.damage += base_elements[base]["damage"]
			if "speed" in base_elements[base]:
				ma.speed += (base_elements[base]["speed"] - 1.0)
	
	# 스타일 요소 보너스
	for style in ma.styles:
		if style in style_elements:
			ma.damage *= style_elements[style].get("multiplier", 1.0)
			if "speed_bonus" in style_elements[style]:
				ma.speed *= style_elements[style]["speed_bonus"]
	
	# 패턴 요소 보너스
	for pattern in ma.patterns:
		if pattern in pattern_elements:
			ma.damage += pattern_elements[pattern].get("range", 0) * 2
	
	# 효과 요소 보너스
	for effect in ma.effects:
		if effect in effect_elements:
			ma.damage += effect_elements[effect].get("power", 0) * 10
	
	# 요소 많을수록 쿨타임 증가 (밸런싱)
	ma.cooldown = 1.0 + (ma.bases.size() + ma.styles.size() + 
						 ma.patterns.size() + ma.effects.size()) * 0.1

# 무술 설명 자동 생성
func generate_martial_art_description(ma: MartialArt) -> String:
	var desc = "%s를(을) 활용한 " % ", ".join(ma.bases)
	
	if ma.styles.size() > 0:
		desc += "%s한 " % ma.styles[0]
	
	if ma.patterns.size() > 0:
		desc += "%s 패턴의 " % ma.patterns[0]
	
	desc += "무술. "
	
	if ma.effects.size() > 0:
		desc += "%s의 효과를 가짐" % ", ".join(ma.effects)
	
	return desc

# 무술 색상 생성
func generate_martial_art_color(effects: Array) -> Color:
	if effects.is_empty():
		return Color.WHITE
	
	var color_map = {
		"얼음": Color.CYAN,
		"불": Color.RED,
		"바람": Color.LIGHT_GRAY,
		"땅": Color.BROWN,
		"어둠": Color.BLACK,
		"빛": Color.YELLOW,
		"독": Color.GREEN,
		"생명": Color.LIME,
		"전기": Color.GOLD,
		"물": Color.BLUE,
	}
	
	for effect in effects:
		if effect in color_map:
			return color_map[effect]
	
	# 랜덤 색상
	return Color(randf(), randf(), randf(), 1.0)

# 총 생성 가능한 무술 개수
func calculate_total_possible_martial_arts() -> int:
	var total = 1
	total *= pow(base_elements.size(), 3)  # 기초 3개 선택
	total *= pow(style_elements.size(), 2)  # 스타일 2개 선택
	total *= pow(pattern_elements.size(), 2)  # 패턴 2개 선택
	total *= pow(effect_elements.size(), 3)  # 효과 3개 선택
	return total

# 무술 발견 (고서, NPC 등에서)
func discover_martial_art(bases: Array, styles: Array, patterns: Array, effects: Array) -> MartialArt:
	var ma = create_martial_art(bases, styles, patterns, effects)
	discovered_martial_arts.append(ma.id)
	print("새로운 무술 발견: %s" % ma.name)
	return ma

# 무술 정보 출력
func print_martial_art_info(ma: MartialArt):
	print("\n=== %s ===" % ma.name)
	print("기초: %s" % ", ".join(ma.bases))
	print("스타일: %s" % (", ".join(ma.styles) if ma.styles.size() > 0 else "없음"))
	print("패턴: %s" % (", ".join(ma.patterns) if ma.patterns.size() > 0 else "없음"))
	print("효과: %s" % (", ".join(ma.effects) if ma.effects.size() > 0 else "없음"))
	print("대미지: %.1f | 속도: %.1f | 정확도: %.1f | 쿨: %.1f" % 
		  [ma.damage, ma.speed, ma.accuracy, ma.cooldown])
	print("설명: %s" % ma.description)
	print("발견 시간: %s" % ma.discovered_at)

# JSON에서 무술 로드
func load_martial_arts_from_json(file_path: String) -> Array:
	var loaded_arts = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		print("오류: 파일을 찾을 수 없음 - ", file_path)
		return loaded_arts
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("오류: JSON 파싱 실패")
		return loaded_arts
	
	var data = json.data
	if data == null or !data.has("martial_arts"):
		print("오류: JSON 형식 잘못됨")
		return loaded_arts
	
	for ma_data in data["martial_arts"]:
		var ma = MartialArt.new()
		ma.id = ma_data.get("id", str(hash(ma)))
		ma.name = ma_data.get("name", "무명")
		ma.level = ma_data.get("level", 1)
		ma.damage = float(ma_data.get("power", 50))
		ma.description = ma_data.get("description", "")
		
		# 배열 형식 데이터
		var base_type = ma_data.get("base_type", "")
		if base_type != "":
			ma.bases = [base_type]
		
		var style = ma_data.get("style", "")
		if style != "":
			ma.styles = [style]
		
		var pattern = ma_data.get("pattern", "")
		if pattern != "":
			ma.patterns = [pattern]
		
		var effects = ma_data.get("effects", [])
		ma.effects = effects if effects is Array else []
		
		# 기본 속성
		ma.speed = 1.0
		ma.accuracy = 1.0
		ma.cooldown = float(ma_data.get("cooldown", 1.0))
		ma.color = generate_martial_art_color(ma.effects)
		
		all_martial_arts[ma.id] = ma
		loaded_arts.append(ma)
		discovered_martial_arts.append(ma.id)
	
	print("무술 JSON 로드 완료: %d개 무술 로드됨" % loaded_arts.size())
	return loaded_arts

# 통계
func print_statistics():
	print("\n=== 무술 시스템 통계 ===")
	print("발견한 무술: %d개" % discovered_martial_arts.size())
	print("생성한 무술: %d개" % player_martial_arts.size())
	print("총 저장된 무술: %d개" % all_martial_arts.size())
	print("생성 가능한 무술: %d개" % calculate_total_possible_martial_arts())
	print("기초 요소: %d개" % base_elements.size())
	print("스타일 요소: %d개" % style_elements.size())
	print("패턴 요소: %d개" % pattern_elements.size())
	print("효과 요소: %d개" % effect_elements.size())
