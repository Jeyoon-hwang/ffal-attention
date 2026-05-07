## MartialArtEngine.gd - 무술 생성 & 관리 엔진
## 핵심: 수백만 무술 조합 가능

class_name MartialArtEngine
extends RefCounted

# ╔═════════════════════════════════════════════════════════╗
# ║          기본 데이터 (Base Data)                        ║
# ╚═════════════════════════════════════════════════════════╝

# 기본 100가지 동작
var base_motions: Array[String] = [
	# 손 기술 (20가지)
	"punch_straight", "punch_hook", "punch_uppercut", "palm_strike",
	"open_hand_slap", "finger_thrust", "knife_hand", "hammer_fist",
	"backfist", "ridge_hand", "claw_strike", "grab_throw",
	"arm_bar", "shoulder_strike", "elbow_strike", "wrist_lock",
	"pressure_point", "nerve_strike", "tiger_claw", "eagle_claw",
	
	# 발 기술 (20가지)
	"kick_front", "kick_side", "kick_round", "kick_spinning",
	"kick_reverse", "kick_crescent", "kick_axe", "kick_double",
	"thrust_kick", "back_kick", "hook_kick", "knee_strike",
	"shin_kick", "stomp", "sweep", "spin_sweep",
	"flying_kick", "jump_kick", "tornado_kick", "scissor_kick",
	
	# 몸통 기술 (20가지)
	"headbutt", "shoulder_ram", "body_slam", "throw_over_hip",
	"seoi_nage", "o_goshi", "drop_seoi", "flying_mare",
	"leg_sweep", "foot_sweep", "takedown", "tackle",
	"suplex", "german_suplex", "belly_to_belly", "spinebuster",
	"power_bomb", "clothesline", "lariat", "uranage",
	
	# 특수 기술 (20가지)
	"backheel", "fake_attack", "feint", "counter",
	"parry_strike", "redirect", "flow_technique", "pressure_palm",
	"internal_strike", "chi_blast", "energy_wave", "spirit_bomb",
	"meditation_strike", "pressure_point_strike", "vortex_palm", "void_punch",
	"time_stop", "reality_warp", "dimension_slash", "spirit_cut",
	
	# 방어 기술 (20가지)
	"block_high", "block_middle", "block_low", "cross_block",
	"butterfly_guard", "iron_guard", "rolling_guard", "diagonal_block",
	"deflect", "absorb", "stance_shift", "dodge_roll",
	"matrix_dodge", "blink_step", "shadow_clone", "barrier",
	"hardening", "intangible", "riposte", "counter_guard"
]

# 리듬 (3가지)
var tempos: Array[String] = ["fast", "mid", "slow"]

# 방어 타입 & 레벨 (5레벨 × 4타입 = 20가지)
var defense_types: Array[String] = ["evade", "guard", "parry", "counter"]

# 효과 (20가지)
var effects_list: Array[String] = [
	"none",          # 없음
	"stun",          # 기절 (1-3초)
	"knockdown",     # 다운 (2초)
	"knockback",     # 밀려남
	"bleed",         # 출혈 (지속 데미지)
	"burn",          # 화염 (지속 데미지)
	"freeze",        # 빙결 (이동 속도 감소)
	"poison",        # 독 (스탯 감소)
	"blind",         # 실명 (명중률 감소)
	"silence",       # 침묵 (무술 사용 불가)
	"slow",          # 둔화 (공격 속도 감소)
	"weaken",        # 약화 (데미지 감소)
	"vulnerability", # 취약 (받는 데미지 증가)
	"heal",          # 회복 (HP 회복)
	"shield",        # 보호막
	"berserk",       # 광전사 (공격력 증가, 방어력 감소)
	"invisible",     # 투명 (회피율 증가)
	"regen",         # 재생 (자동 회복)
	"buff_atk",      # 공격력 증가
	"buff_def"       # 방어력 증가
]

# ╔═════════════════════════════════════════════════════════╗
# ║          생성된 무술 캐시 (Created Arts Cache)         ║
# ╚═════════════════════════════════════════════════════════╝

var created_arts: Dictionary = {}       # id → MartialArt


# ═══════════════════════════════════════════════════════════════════════════════

## 기본 무술들 로드 (시작 시)
func load_base_martial_arts() -> void:
	# 기본 무술 5가지 생성
	var basic_arts = [
		{"id": "punch_001", "name": "기본 펀치", "motion": "punch_straight", "power": 10, "energy": 5},
		{"id": "kick_001", "name": "기본 차기", "motion": "kick_front", "power": 12, "energy": 6},
		{"id": "palm_001", "name": "손날 타격", "motion": "palm_strike", "power": 14, "energy": 7},
		{"id": "throw_001", "name": "손 던지기", "motion": "grab_throw", "power": 20, "energy": 10},
		{"id": "block_001", "name": "기본 방어", "motion": "block_middle", "power": 0, "energy": 3},
	]
	
	for art_data in basic_arts:
		var art = _create_from_data(art_data)
		created_arts[art.id] = art


## 내부: 데이터에서 무술 생성
func _create_from_data(data: Dictionary) -> MartialArt:
	var art = MartialArt.new()
	art.id = data.get("id", "unknown")
	art.name = data.get("name", "Unknown")
	art.base_power = float(data.get("power", 10))
	art.energy_cost = int(data.get("energy", 5))
	art.animation_name = data.get("motion", "punch_straight")
	art.is_combo = data.get("is_combo", true)
	art.max_combo_count = data.get("max_combo", 3)
	return art


## 📌 동적 무술 생성 (핵심 기능!)
## 난이도별 무술 생성 (조합 시스템)
func generate_martial_art(rarity: int = 0) -> MartialArt:
	var art = MartialArt.new()
	
	# ID 생성 (timestamp 기반)
	art.id = "generated_%d_%d" % [Time.get_ticks_msec(), randi()]
	
	# 기본 동작 선택
	var motion = base_motions[randi() % base_motions.size()]
	art.animation_name = motion
	
	# 이름 생성
	var tempo = tempos[randi() % tempos.size()]
	var adjective = ["민첩한", "강력한", "신비로운", "위험한"][randi() % 4]
	art.name = "%s %s" % [adjective, motion.replace("_", " ")]
	
	# 난이도별 설정
	match rarity:
		0:  # 일반 (Common)
			art.base_power = randf_range(8.0, 15.0)
			art.energy_cost = randi_range(3, 7)
			art.is_combo = true
			art.effects = [effects_list[randi() % 5]]  # 기본 효과만
		
		1:  # 레어 (Rare)
			art.base_power = randf_range(15.0, 25.0)
			art.energy_cost = randi_range(7, 12)
			art.is_combo = randi() % 2 == 0
			art.is_guard_breaking = randi() % 3 == 0
			# 2-3개 효과
			var effect_count = randi_range(2, 3)
			for i in range(effect_count):
				art.effects.append(effects_list[randi_range(5, 15)])
		
		2:  # 에픽 (Epic)
			art.base_power = randf_range(25.0, 40.0)
			art.energy_cost = randi_range(12, 18)
			art.is_combo = true
			art.is_guard_breaking = true
			art.is_knockdown = randi() % 2 == 0
			# 3-4개 효과
			var effect_count = randi_range(3, 4)
			for i in range(effect_count):
				art.effects.append(effects_list[randi_range(5, 20)])
		
		3:  # 레전더리 (Legendary)
			art.base_power = randf_range(40.0, 100.0)
			art.energy_cost = randi_range(15, 25)
			art.is_combo = true
			art.is_guard_breaking = true
			art.is_knockdown = true
			# 4-5개 효과 + 특수 효과
			var effect_count = randi_range(4, 5)
			for i in range(effect_count):
				art.effects.append(effects_list[randi_range(5, 20)])
			art.effects.append(effects_list[randi_range(15, 20)])
	
	# 스케일링 설정 (난이도 올수록 다양함)
	art.str_scaling = randf_range(0.5, 1.0)
	art.dex_scaling = randf_range(0.0, 0.5)
	art.int_scaling = randf_range(0.0, 0.3)
	
	# 쿨타임 설정
	if art.is_knockdown:
		art.cooldown = randf_range(2.0, 5.0)
	elif art.is_guard_breaking:
		art.cooldown = randf_range(1.0, 3.0)
	else:
		art.cooldown = randf_range(0.0, 1.0)
	
	created_arts[art.id] = art
	return art


## ID로 무술 검색
func get_martial_art(id: String) -> MartialArt:
	if id in created_arts:
		return created_arts[id]
	return null


## 모든 무술 조회
func get_all_martial_arts() -> Array:
	return created_arts.values()


## 레벨별 무술 조회
func get_martial_arts_by_level(min_level: int, max_level: int) -> Array:
	var result = []
	for art in created_arts.values():
		if art.level >= min_level and art.level <= max_level:
			result.append(art)
	return result


# ╔═════════════════════════════════════════════════════════╗
# ║        JSON 로드/저장 (Save/Load from JSON)           ║
# ╚═════════════════════════════════════════════════════════╝

## JSON에서 무술 로드
func load_martial_arts_from_json(path: String) -> bool:
	if not ResourceLoader.exists(path):
		print("무술 파일 없음: %s" % path)
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("파일 읽기 실패: %s" % path)
		return false
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error != OK:
		print("JSON 파싱 실패")
		return false
	
	var data = json.data
	if data == null or not data.has("martial_arts"):
		print("유효한 JSON 구조 아님")
		return false
	
	# 무술들 로드
	for art_data in data["martial_arts"]:
		var art = MartialArt.from_dict(art_data)
		created_arts[art.id] = art
	
	print("무술 %d개 로드 완료" % created_arts.size())
	return true


## 현재 무술들을 JSON으로 저장
func save_martial_arts_to_json(path: String) -> bool:
	var data = {
		"version": "1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"martial_arts": []
	}
	
	for art in created_arts.values():
		data["martial_arts"].append(art.to_dict())
	
	# 파일 경로의 폴더 생성
	var dir = DirAccess.open(path.get_base_dir())
	if dir == null:
		DirAccess.make_absolute_path(path.get_base_dir())
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("파일 쓰기 실패: %s" % path)
		return false
	
	file.store_line(JSON.stringify(data))
	print("무술 %d개 저장 완료: %s" % [created_arts.size(), path])
	return true


# ╔═════════════════════════════════════════════════════════╗
# ║          사용자 정의 무술 (Custom Arts)               ║
# ╚═════════════════════════════════════════════════════════╝

## 사용자가 무술을 커스텀 생성
## 예: create_custom_art("punch_straight", ["stun", "burn"])
func create_custom_art(base_motion: String, effects: Array = []) -> MartialArt:
	var art = MartialArt.new()
	
	art.id = "custom_%d" % Time.get_ticks_msec()
	art.name = "커스텀 무술"
	art.animation_name = base_motion
	art.base_power = 15.0
	art.energy_cost = 8
	art.effects = effects
	
	created_arts[art.id] = art
	return art


## 무술 강화 (레벨 업)
func upgrade_martial_art(art_id: String) -> bool:
	if art_id not in created_arts:
		return false
	
	var art = created_arts[art_id]
	return art.upgrade()


## 무술 삭제
func remove_martial_art(art_id: String) -> bool:
	if art_id not in created_arts:
		return false
	
	created_arts.erase(art_id)
	return true


# ╔═════════════════════════════════════════════════════════╗
# ║              통계 (Statistics)                           ║
# ╚═════════════════════════════════════════════════════════╝

## 생성된 무술 개수
func get_total_martial_count() -> int:
	return created_arts.size()


## 평균 데미지
func get_average_power() -> float:
	if created_arts.size() == 0:
		return 0.0
	
	var total = 0.0
	for art in created_arts.values():
		total += art.base_power
	
	return total / created_arts.size()


## 무술 목록 출력 (디버그)
func print_all_martial_arts() -> void:
	print("\n=== 무술 목록 ===")
	for art in created_arts.values():
		print("  [%s] %s - Power: %.1f, Energy: %d, Effects: %s" % [
			art.id, art.name, art.base_power, art.energy_cost, ", ".join(art.effects)
		])
	print("총 %d개\n" % created_arts.size())


# ═══════════════════════════════════════════════════════════════════════════════
# 조합 계산 공식:
# 기본동작(100) × 리듬(3) × 방어타입(4×5) × 효과(20) × ...
# = 최소 1,200가지
# 프래그먼트 시스템으로 확장 시 → 수백만 가지 가능
# ═══════════════════════════════════════════════════════════════════════════════
