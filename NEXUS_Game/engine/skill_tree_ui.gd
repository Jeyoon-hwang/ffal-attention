extends Control

# ============================================================================
# Skill Tree UI - 5개 능력치 브랜치별 스킬 트리
# ============================================================================
# Week 3 Day 6: 스킬 트리 UI
# 담당: 천재 ⚡
# ============================================================================

# 스킬 트리 데이터
var skill_points = 0
var skill_tree = {}
var selected_skill = null

# 화면 컴포넌트
var branch_buttons = {}
var skill_display = {}
var point_label: Label
var skill_detail_label: Label

# 각 브랜치의 스킬들 (3단계)
var skills = {
	"STR": [
		{
			"name": "강화된 검술",
			"level": 1,
			"cost": 1,
			"bonus": "공격력 +5%",
			"description": "검의 위력을 강화합니다."
		},
		{
			"name": "맹렬한 참격",
			"level": 2,
			"cost": 2,
			"bonus": "공격력 +15%, 쿨타임 -10%",
			"description": "강력한 칼질로 적을 베어냅니다."
		},
		{
			"name": "괴력의 경지",
			"level": 3,
			"cost": 3,
			"bonus": "공격력 +30%, 치명타율 +10%",
			"description": "극도의 힘을 발휘합니다."
		}
	],
	"DEX": [
		{
			"name": "민첩한 동작",
			"level": 1,
			"cost": 1,
			"bonus": "회피율 +5%",
			"description": "빠른 움직임으로 위험을 피합니다."
		},
		{
			"name": "그림자 선수",
			"level": 2,
			"cost": 2,
			"bonus": "회피율 +15%, 이동속도 +10%",
			"description": "그림자처럼 빠르게 이동합니다."
		},
		{
			"name": "분신의 술",
			"level": 3,
			"cost": 3,
			"bonus": "회피율 +30%, 민첩성 +20%",
			"description": "순간이동으로 적의 공격을 피합니다."
		}
	],
	"INT": [
		{
			"name": "기본 마법",
			"level": 1,
			"cost": 1,
			"bonus": "마력 +5%",
			"description": "마법의 기초를 배웁니다."
		},
		{
			"name": "원소의 힘",
			"level": 2,
			"cost": 2,
			"bonus": "마력 +15%, 마법 쿨타임 -15%",
			"description": "여러 원소의 힘을 조종합니다."
		},
		{
			"name": "마법의 대가",
			"level": 3,
			"cost": 3,
			"bonus": "마력 +30%, 마법 효과 +25%",
			"description": "마법의 최고 경지에 도달합니다."
		}
	],
	"VIT": [
		{
			"name": "체력 단련",
			"level": 1,
			"cost": 1,
			"bonus": "체력 +5%",
			"description": "체질을 강화합니다."
		},
		{
			"name": "강인한 체질",
			"level": 2,
			"cost": 2,
			"bonus": "체력 +15%, 회복속도 +10%",
			"description": "튼튼한 몸을 만듭니다."
		},
		{
			"name": "불멸의 신체",
			"level": 3,
			"cost": 3,
			"bonus": "체력 +30%, 방어력 +20%",
			"description": "거의 죽지 않는 몸이 됩니다."
		}
	],
	"WIS": [
		{
			"name": "통찰력",
			"level": 1,
			"cost": 1,
			"bonus": "지혜 +5%",
			"description": "상황을 더 잘 파악합니다."
		},
		{
			"name": "영혼 감지",
			"level": 2,
			"cost": 2,
			"bonus": "지혜 +15%, 적 정보 표시",
			"description": "적의 약점을 감지합니다."
		},
		{
			"name": "천의 눈",
			"level": 3,
			"cost": 3,
			"bonus": "지혜 +30%, 모든 적 정보 공개",
			"description": "세상의 모든 것이 보입니다."
		}
	]
}

# ============================================================================
# 초기화
# ============================================================================

func _ready():
	# 윈도우 설정
	anchor_left = 0.0
	anchor_top = 0.1
	anchor_right = 0.3
	anchor_bottom = 0.9
	
	# 배경
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.2, 0.9)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	add_child(bg)
	
	# === 제목 ===
	var title = Label.new()
	title.text = "스킬 트리"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)
	
	# === 스킬 포인트 ===
	point_label = Label.new()
	point_label.text = "스킬 포인트: 0"
	point_label.position = Vector2(10, 40)
	point_label.add_theme_font_size_override("font_size", 16)
	add_child(point_label)
	
	# === 브랜치 버튼 (5개) ===
	var branches = ["STR", "DEX", "INT", "VIT", "WIS"]
	var colors = [Color.RED, Color.CYAN, Color.MAGENTA, Color.GREEN, Color.YELLOW]
	
	for i in range(branches.size()):
		var btn = Button.new()
		btn.text = branches[i]
		btn.position = Vector2(10, 70 + i * 50)
		btn.custom_minimum_size = Vector2(260, 40)
		btn.add_theme_color_override("font_color", colors[i])
		add_child(btn)
		branch_buttons[branches[i]] = btn
		btn.pressed.connect(Callable(self, "_on_branch_selected").bind(branches[i]))
	
	# === 스킬 상세 정보 ===
	skill_detail_label = Label.new()
	skill_detail_label.position = Vector2(10, 330)
	skill_detail_label.custom_minimum_size = Vector2(260, 200)
	skill_detail_label.text = "스킬을 선택하세요."
	skill_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(skill_detail_label)
	
	# === 닫기 버튼 ===
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.position = Vector2(240, 10)
	close_btn.custom_minimum_size = Vector2(30, 30)
	add_child(close_btn)
	close_btn.pressed.connect(Callable(self, "hide"))
	
	# 초기화
	skill_points = 0

# ============================================================================
# 브랜치 선택
# ============================================================================

func _on_branch_selected(branch: String):
	"""브랜치 선택"""
	_show_branch_skills(branch)

func _show_branch_skills(branch: String):
	"""브랜치의 스킬들 표시"""
	skill_detail_label.text = branch + " 스킬:\n\n"
	
	var branch_skills = skills.get(branch, [])
	for i in range(branch_skills.size()):
		var skill = branch_skills[i]
		skill_detail_label.text += "[%d] %s\n" % [i + 1, skill["name"]]
		skill_detail_label.text += "비용: %d점 | %s\n" % [skill["cost"], skill["bonus"]]
		skill_detail_label.text += skill["description"] + "\n\n"

# ============================================================================
# 스킬 습득
# ============================================================================

func add_skill_points(amount: int):
	"""스킬 포인트 추가"""
	skill_points += amount
	point_label.text = "스킬 포인트: %d" % skill_points

func learn_skill(branch: String, skill_level: int) -> bool:
	"""스킬 습득"""
	if skill_level < 1 or skill_level > 3:
		return false
	
	var branch_skills = skills.get(branch, [])
	if skill_level > branch_skills.size():
		return false
	
	var skill = branch_skills[skill_level - 1]
	
	# 포인트 확인
	if skill_points >= skill["cost"]:
		skill_points -= skill["cost"]
		point_label.text = "스킬 포인트: %d" % skill_points
		print("[SkillTree] " + skill["name"] + "을(를) 습득했습니다!")
		return true
	else:
		print("[SkillTree] 포인트가 부족합니다!")
		return false

# ============================================================================
# 디버그 / 테스트
# ============================================================================

func _add_test_data():
	"""테스트: 스킬 포인트 추가"""
	add_skill_points(10)

# ============================================================================
# 로깅
# ============================================================================

func _print_debug(msg: String):
	print("[SkillTree] " + msg)
