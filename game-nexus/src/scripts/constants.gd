# ⚡ NEXUS 무협 게임 - 글로벌 상수
# 모든 매직 넘버를 여기서 정의하고 관리

extends Node

# ============================================================
# 🥋 플레이어 설정
# ============================================================
const PLAYER_SPEED = 12.0
const PLAYER_JUMP_FORCE = 18.0
const PLAYER_GRAVITY = 30.0
const PLAYER_MOUSE_SENSITIVITY = 0.3
const PLAYER_MAX_HEALTH = 120
const PLAYER_MAX_ENERGY = 100

# 플레이어 공격
const PLAYER_BASIC_ATTACK_DAMAGE = 20
const PLAYER_BASIC_ATTACK_COMBO_BONUS = 0.3  # 콤보당 30% 증가
const PLAYER_MAX_COMBO = 3
const PLAYER_COMBO_WINDOW = 0.8  # 콤보 인정 시간 (초) [개선: 0.6 → 0.8]
const PLAYER_ATTACK_COOLDOWN = 0.8

# 플레이어 회전 공격 (새 기능)
const PLAYER_SPIN_ATTACK_DAMAGE = 35
const PLAYER_SPIN_ATTACK_COOLDOWN = 2.0
const PLAYER_SPIN_ATTACK_ENERGY_COST = 20
const PLAYER_SPIN_ATTACK_RANGE = 8.0  # 회전 범위 (모든 방향)

# 플레이어 대시 공격 (Shift)
const PLAYER_DASH_ATTACK_DAMAGE = 28
const PLAYER_DASH_ATTACK_COOLDOWN = 1.5
const PLAYER_DASH_ATTACK_ENERGY_COST = 15
const PLAYER_DASH_SPEED = 40.0  # 대시 속도
const PLAYER_DASH_DURATION = 0.3  # 대시 지속 시간

# 플레이어 무술 스킬
const PLAYER_SKILL_DAMAGE = 45
const PLAYER_SKILL_COOLDOWN = 1.2
const PLAYER_SKILL_ENERGY_COST = 30
const PLAYER_ENERGY_RECOVERY_RATE = 2.5  # 초당 에너지 [개선: 5 → 2.5]

# 플레이어 내공 (정기)
const PLAYER_SPIRIT_MAX = 100
const PLAYER_SPIRIT_DAMAGE_MULTIPLIER = 1.5
const PLAYER_SPIRIT_COST_PER_SECOND = 5  # 내공 소비

# ============================================================
# 👹 적 설정
# ============================================================
const ENEMY_SPEED = 7.0
const ENEMY_GRAVITY = 30.0
const ENEMY_DETECTION_RANGE = 25.0
const ENEMY_ATTACK_RANGE = 4.0
const ENEMY_BASE_HEALTH = 50
const ENEMY_BASE_ATTACK_DAMAGE = 12

# 적 난이도별 스케일링 [개선: 체력 상향]
const ENEMY_HEALTH_MULTIPLIERS = {
	1: 1.2,    # 초급 (60 HP)
	2: 1.8,    # 중급 (90 HP)
	3: 3.0,    # 상급 (150 HP)
	4: 5.0     # 신급 (250 HP) - 마스터급
}

const ENEMY_DAMAGE_MULTIPLIERS = {
	1: 1.1,    # 초급 (13.2 dmg)
	2: 1.5,    # 중급 (18 dmg)
	3: 2.0,    # 상급 (24 dmg)
	4: 3.0     # 신급 (36 dmg) - 강력함
}

# 적 스킬
const ENEMY_SKILL_COOLDOWN = 2.0
const ENEMY_SKILL_DAMAGE_MULTIPLIER = 2.0  # 기본 공격의 2배
const ENEMY_SKILL_CHANCE_BASE = 0.3

# 적 스킬 확률 (무술 레벨별) [개선: 레벨에 따라 조정 + Level 4 추가]
const ENEMY_SKILL_CHANCES = {
	1: 0.2,    # 초급: 20%
	2: 0.4,    # 중급: 40%
	3: 0.6,    # 상급: 60%
	4: 0.85    # 신급: 85% - 거의 항상 스킬 사용
}

# 적 회피 확률 (무술 레벨별) - 신급 AI 전용
const ENEMY_DODGE_CHANCES = {
	1: 0.1,    # 초급: 10%
	2: 0.25,   # 중급: 25%
	3: 0.4,    # 상급: 40%
	4: 0.7     # 신급: 70% - 매우 높음
}

# 적 반응 시간 (초) - 낮을수록 빠름
const ENEMY_REACTION_TIMES = {
	1: 0.8,    # 초급: 느림
	2: 0.5,    # 중급: 중간
	3: 0.3,    # 상급: 빠름
	4: 0.1     # 신급: 매우 빠름 (0.1초)
}

# ============================================================
# 🎮 게임 매니저 설정
# ============================================================
const GAME_ENEMIES_PER_STAGE = 5
const GAME_STAGE_DURATION = 120.0  # 2분
const GAME_STAGE_DIFFICULTY_INCREMENT = 0.10  # 스테이지당 난이도 +10% [개선: 15% → 10%]
const GAME_BOSS_SPAWN_TIMING = 0.5  # 스테이지의 50% 진행 후

# 적 스포닝
const GAME_SPAWN_CHECK_INTERVAL = 1.0

# ============================================================
# 👹 보스 설정 [개선: 체력 상향]
# ============================================================
const BOSS_LEVEL = 3
const BOSS_BASE_HEALTH = 280  # [개선: 200 → 280]
const BOSS_BASE_DAMAGE = 30
const BOSS_SKILL_CHANCE = 0.6
const BOSS_ATTACK_PATTERNS = 3  # 보스는 3가지 패턴

# 보스 파당별 특성
const BOSS_FACTION_MULTIPLIERS = {
	"정파": 1.0,      # 균형
	"사파": 0.9,      # 빠르지만 약함
	"독립": 1.2,      # 강함
	"보스": 1.0       # 기본
}

# ============================================================
# 🏮 파당 시스템
# ============================================================
const FACTIONS = {
	"정파": {"difficulty": 1.0, "speed": 1.0, "power": 1.0},
	"사파": {"difficulty": 0.8, "speed": 1.3, "power": 0.8},
	"독립": {"difficulty": 1.2, "speed": 0.8, "power": 1.3}
}

# ============================================================
# 📊 점수 시스템
# ============================================================
const SCORE_ENEMY_BASE = 100
const SCORE_COMBO_MULTIPLIER = 1.25  # 콤보당 25% 증가
const SCORE_SKILL_BONUS = 50
const SCORE_BOSS_MULTIPLIER = 5.0

# ============================================================
# 🎵 카메라 설정
# ============================================================
const CAMERA_FOV = 75.0
const CAMERA_NEAR = 0.1
const CAMERA_FAR = 1000.0

# ============================================================
# 🎨 UI 설정
# ============================================================
const UI_HEALTH_BAR_WIDTH = 200
const UI_ENERGY_BAR_WIDTH = 150
const UI_FONT_SIZE_SMALL = 14
const UI_FONT_SIZE_NORMAL = 18
const UI_FONT_SIZE_LARGE = 24

# ============================================================
# ⏱️ 타이밍
# ============================================================
const ANIMATION_ATTACK_DURATION = 0.5
const ANIMATION_DAMAGE_DURATION = 0.3
const ANIMATION_DEATH_DURATION = 1.0

# ============================================================
# 🎯 게임 밸런싱 (난이도)
# ============================================================
class DifficultyScaling:
	static var HEALTH_SCALE = 1.15  # 스테이지당 체력 15% 증가
	static var DAMAGE_SCALE = 1.12  # 스테이지당 대미지 12% 증가
	static var SPAWN_SCALE = 1.08   # 스테이지당 스폰 8% 증가

# ============================================================
# 🛠️ 디버그 모드
# ============================================================
const DEBUG_MODE = false
const DEBUG_SHOW_RANGES = false
const DEBUG_SHOW_AI_STATE = false
const DEBUG_INFINITE_ENERGY = false
const DEBUG_ONE_HIT_KILL = false

# ============================================================
# 함수: 디버그 출력
# ============================================================
static func debug(message: String) -> void:
	if DEBUG_MODE:
		print("[⚡DEBUG] " + message)

# 함수: 난이도에 따른 에너미 체력 계산
static func get_enemy_health(base_health: int, martial_level: int, stage: int) -> int:
	var level_multiplier = ENEMY_HEALTH_MULTIPLIERS.get(martial_level, 1.0)
	var stage_multiplier = pow(DifficultyScaling.HEALTH_SCALE, stage - 1)
	return int(base_health * level_multiplier * stage_multiplier)

# 함수: 난이도에 따른 에너미 대미지 계산
static func get_enemy_damage(base_damage: int, martial_level: int, stage: int) -> int:
	var level_multiplier = ENEMY_DAMAGE_MULTIPLIERS.get(martial_level, 1.0)
	var stage_multiplier = pow(DifficultyScaling.DAMAGE_SCALE, stage - 1)
	return int(base_damage * level_multiplier * stage_multiplier)

# 함수: 에너미 스킬 확률
static func get_skill_chance(martial_level: int) -> float:
	return ENEMY_SKILL_CHANCES.get(martial_level, 0.85)

# 함수: 에너미 회피 확률
static func get_dodge_chance(martial_level: int) -> float:
	return ENEMY_DODGE_CHANCES.get(martial_level, 0.7)

# 함수: 에너미 반응 시간
static func get_reaction_time(martial_level: int) -> float:
	return ENEMY_REACTION_TIMES.get(martial_level, 0.1)
