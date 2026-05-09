extends Node
class_name MartialArtEngine
"""
무술 생성 엔진 (Martial Art Creation Engine)
- 무술 조합 가능 (수백만 가지)
- 무술 저장/로드
- 무술 데이터베이스 관리

구성:
1. 기본 동작 100가지 (Base Motions)
2. 리듬 3가지 (Fast/Mid/Slow)
3. 방어 타입 5가지 × 5레벨 (25가지)
4. 에너지 비용 10가지 (1-10)
5. 추가 효과 8가지
->  100 × 3 × 25 × 10 × 8 = 600,000,000 조합 가능!
"""

# 기본 동작 데이터베이스
var base_motions: Array[Dictionary] = []
var martial_arts_db: Dictionary = {}  # martial_id -> MartialArt
var player_martial_arts: Array[MartialArt] = []  # 플레이어가 학습한 무술

# 상수
const MOTION_COUNT = 100
const MAX_MARTIAL_SLOTS = 5

func _ready():
	_initialize_base_motions()
	_load_martial_database()
	print("[MartialArtEngine] 초기화 완료")

## 기본 동작 초기화 (100가지)
func _initialize_base_motions() -> void:
	var motion_names = [
		"Straight Punch", "Jab", "Uppercut", "Roundhouse", "Cross",
		"Hook Kick", "Knee Strike", "Elbow Strike", "Palm Strike", "Spin",
		"Low Kick", "High Kick", "Front Kick", "Axe Kick", "Sweep",
		"Combination Strike", "Rapid Punch", "Spinning Strike", "Jump Attack", "Power Slam",
		# ... 80개 더 추가 가능
	]
	
	for i in range(min(MOTION_COUNT, motion_names.size())):
		base_motions.append({
			"id": i,
			"name": motion_names[i] if i < motion_names.size() else f"Motion_{i}",
			"category": "strike" if i < 10 else ("kick" if i < 15 else "special")
		})

## 기본 무술 생성 (교육용)
func _load_martial_database() -> void:
	# 기본 무술 10가지 사전 정의
	var basic_martial_configs = [
		{
			"id": "basic_punch",
			"name": "기본 펀치",
			"base_motion": 0,
			"base_damage": 10.0,
			"energy_cost": 3,
			"defense_type": MartialArt.DefenseType.NONE,
			"animation": "Punch"
		},
		{
			"id": "kick",
			"name": "발차기",
			"base_motion": 12,
			"base_damage": 15.0,
			"energy_cost": 5,
			"defense_type": MartialArt.DefenseType.NONE,
			"animation": "Kick"
		},
		{
			"id": "guard",
			"name": "방어",
			"base_motion": 50,
			"base_damage": 0.0,
			"energy_cost": 2,
			"defense_type": MartialArt.DefenseType.GUARD,
			"defense_level": 2,
			"animation": "Guard"
		},
		{
			"id": "evade",
			"name": "회피",
			"base_motion": 51,
			"base_damage": 0.0,
			"energy_cost": 4,
			"defense_type": MartialArt.DefenseType.EVADE,
			"defense_level": 2,
			"animation": "Dodge"
		},
	]
	
	for config in basic_martial_configs:
		var martial = MartialArt.new()
		martial.martial_id = config["id"]
		martial.martial_name = config["name"]
		martial.base_motion = config["base_motion"]
		martial.base_damage = config.get("base_damage", 10.0)
		martial.energy_cost = config.get("energy_cost", 5)
		martial.defense_type = config.get("defense_type", MartialArt.DefenseType.NONE)
		if config.has("defense_level"):
			martial.defense_level = config["defense_level"]
		martial.animation_name = config.get("animation", "Default")
		
		martial_arts_db[martial.martial_id] = martial

## 무술 생성 (랜덤 조합)
func generate_random_martial() -> MartialArt:
	"""
	무술을 무작위로 생성
	반복 가능한 파라미터:
	- Base Motion: 100가지
	- Tempo: 3가지
	- Defense: 5×5=25가지
	- Energy: 10가지
	- Effect: 8가지
	-> 600,000,000가지 조합!
	"""
	var martial = MartialArt.new()
	
	# 무술 ID 자동 생성
	martial.martial_id = "custom_%s" % str(randi())
	martial.martial_name = _generate_martial_name()
	
	# 기본 동작 선택
	martial.base_motion = randi() % MOTION_COUNT
	martial.motion_name = base_motions[martial.base_motion]["name"]
	
	# 리듬 선택 (Fast/Mid/Slow)
	martial.tempo = randi() % 3
	
	# 데미지 & 에너지 밸런싱
	martial.base_damage = randf_range(5.0, 50.0)
	martial.energy_cost = randi_range(1, 10)
	
	# 방어 타입 선택 (확률: 80% 공격, 20% 방어)
	if randf() < 0.2:
		martial.defense_type = randi_range(1, 4)  # EVADE, GUARD, DEFLECT
		martial.defense_level = randi_range(1, 5)
	
	# 추가 효과 (확률: 30% 추가 효과 있음)
	if randf() < 0.3:
		martial.effects.append(randi_range(1, MartialArt.EffectType.CONFUSE))
		martial.effect_durations.append(randf_range(0.5, 3.0))
	
	# 애니메이션
	martial.animation_name = martial.motion_name.to_lower().replace(" ", "_")
	martial.animation_duration = randf_range(0.5, 2.0)
	martial.animation_hit_frame = martial.animation_duration * 0.5
	
	# 치명타 & 스케일
	martial.crit_chance = randf_range(0.05, 0.25)
	martial.damage_scaling = randf_range(0.8, 1.5)
	
	return martial

## 무술 조합 (플레이어 선택)
func create_martial_from_components(
	base_motion_id: int,
	tempo: int,
	defense_type: int,
	defense_level: int,
	energy_cost: int,
	effects: Array[int] = []
) -> MartialArt:
	"""
	사용자가 선택한 컴포넌트로 무술 생성
	
	파라미터:
	- base_motion_id: 0-99
	- tempo: 0(Fast), 1(Mid), 2(Slow)
	- defense_type: 0(None) ~ 4(Counter)
	- defense_level: 0-5
	- energy_cost: 1-10
	- effects: [EffectType, ...]
	"""
	var martial = MartialArt.new()
	
	martial.martial_id = "custom_%s_%s" % [randi(), Time.get_ticks_msec()]
	martial.base_motion = base_motion_id
	martial.tempo = tempo
	martial.defense_type = defense_type
	martial.defense_level = defense_level
	martial.energy_cost = energy_cost
	
	# 컴포넌트로부터 데미지 계산
	var base_damage = float(energy_cost) * 2.0  # 에너지 비용과 데미지 관계
	martial.base_damage = base_damage
	
	# 효과 추가
	for effect_id in effects:
		if effect_id > 0:
			martial.effects.append(effect_id)
			martial.effect_durations.append(1.5)
	
	martial.martial_name = _generate_martial_name()
	
	return martial

## 무술명 생성 (한국식)
func _generate_martial_name() -> String:
	var prefixes = ["천", "용", "호", "독", "열", "강", "비", "뇌"]
	var suffixes = ["권", "발", "장", "기", "류", "파"]
	
	var prefix = prefixes[randi() % prefixes.size()]
	var suffix = suffixes[randi() % suffixes.size()]
	
	return prefix + suffix

## 플레이어 무술 슬롯에 추가
func add_martial_to_player(martial: MartialArt) -> bool:
	if player_martial_arts.size() >= MAX_MARTIAL_SLOTS:
		print(f"❌ 무술 슬롯 가득 참 (최대 {MAX_MARTIAL_SLOTS})")
		return false
	
	player_martial_arts.append(martial)
	print(f"✅ 무술 추가: {martial.martial_name}")
	return true

## 플레이어 무술 조회
func get_player_martial(slot: int) -> MartialArt:
	if slot >= 0 and slot < player_martial_arts.size():
		return player_martial_arts[slot]
	return null

## 모든 플레이어 무술 조회
func get_all_player_martials() -> Array[MartialArt]:
	return player_martial_arts

## 무술 저장 (JSON)
func save_martial_to_file(martial: MartialArt, filepath: String) -> bool:
	var data = martial.to_dict()
	var json = JSON.stringify(data)
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		print(f"❌ 파일 저장 실패: {filepath}")
		return false
	
	file.store_string(json)
	print(f"✅ 무술 저장: {filepath}")
	return true

## 무술 로드 (JSON)
func load_martial_from_file(filepath: String) -> MartialArt:
	if not ResourceLoader.exists(filepath):
		print(f"❌ 파일 없음: {filepath}")
		return null
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		print(f"❌ 파일 읽기 실패: {filepath}")
		return null
	
	var json_str = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_str)
	
	if error != OK:
		print(f"❌ JSON 파싱 실패: {filepath}")
		return null
	
	var martial = MartialArt.new()
	martial.from_dict(json.data)
	print(f"✅ 무술 로드: {filepath}")
	return martial

## 디버그 출력
func print_player_martials() -> void:
	print("\n🥋 플레이어 무술 슬롯:")
	for i in range(player_martial_arts.size()):
		var martial = player_martial_arts[i]
		print(f"  [{i}] {martial}")
	print()

func print_all_motions() -> void:
	print("\n🎬 기본 동작 (샘플 5개):")
	for i in range(min(5, base_motions.size())):
		var motion = base_motions[i]
		print(f"  [{motion['id']}] {motion['name']}")
	print(f"  ... 총 {base_motions.size()}개")
	print()
