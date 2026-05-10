## DataLoader.gd - 데이터 로드/저장 시스템
## JSON 파일에서 게임 데이터를 로드하고 저장

class_name DataLoader
extends Node

static var data_path = "res://Data"

# ===== 무술 데이터 로드 =====

static func load_martial_arts(filename: String = "martial_arts.json") -> Array[MartialArt]:
	"""무술 데이터를 로드한다"""
	
	var filepath = "%s/Martial/%s" % [data_path, filename]
	var file = FileAccess.open(filepath, FileAccess.READ)
	
	if not file:
		print("[DataLoader] 경고: 파일 없음 - %s" % filepath)
		# 기본 무술 생성
		return create_default_martial_arts()
	
	var json_string = file.get_as_text()
	var json = JSON.parse_string(json_string)
	
	if not json or not json.has("martial_arts"):
		print("[DataLoader] 경고: 잘못된 JSON 형식")
		return create_default_martial_arts()
	
	var martial_arts = []
	
	for martial_data in json["martial_arts"]:
		var martial = MartialArt.new()
		
		# 기본 정보
		martial.martial_id = martial_data.get("id", "martial_000")
		martial.martial_name = martial_data.get("name", "무술")
		martial.description = martial_data.get("description", "설명 없음")
		
		# 데미지
		martial.base_damage = martial_data.get("base_damage", 5)
		martial.str_scaling = martial_data.get("str_scaling", 0.5)
		martial.dex_scaling = martial_data.get("dex_scaling", 0.2)
		
		# 에너지
		martial.energy_cost = martial_data.get("energy_cost", 10)
		
		# 애니메이션
		martial.animation_name = martial_data.get("animation_name", "attack_basic")
		martial.animation_duration = martial_data.get("animation_duration", 1.0)
		
		# 판정
		martial.hitbox_range = martial_data.get("hitbox_range", 1.5)
		martial.hitbox_radius = martial_data.get("hitbox_radius", 0.3)
		
		martial_arts.append(martial)
	
	print("[DataLoader] 무술 데이터 로드: %d개" % martial_arts.size())
	return martial_arts

# ===== 기본 무술 생성 =====

static func create_default_martial_arts() -> Array[MartialArt]:
	"""기본 무술 세트를 생성한다"""
	
	var martials = []
	
	# 1. 기본권
	var basic_punch = MartialArt.new()
	basic_punch.martial_id = "martial_001"
	basic_punch.martial_name = "기본권"
	basic_punch.description = "가장 기초적인 권법"
	basic_punch.base_damage = 5
	basic_punch.energy_cost = 10
	basic_punch.str_scaling = 0.5
	basic_punch.dex_scaling = 0.2
	basic_punch.animation_duration = 0.8
	martials.append(basic_punch)
	
	# 2. 연속권
	var combo_punch = MartialArt.new()
	combo_punch.martial_id = "martial_002"
	combo_punch.martial_name = "연속권"
	combo_punch.description = "빠른 연속 권법"
	combo_punch.base_damage = 8
	combo_punch.energy_cost = 15
	combo_punch.str_scaling = 0.4
	combo_punch.dex_scaling = 0.3
	combo_punch.animation_duration = 1.2
	combo_punch.combo_requirements = ["martial_001"]
	martials.append(combo_punch)
	
	# 3. 회피
	var dodge = MartialArt.new()
	dodge.martial_id = "martial_003"
	dodge.martial_name = "회피"
	dodge.description = "측면으로 재빠르게 회피"
	dodge.base_damage = 0
	dodge.energy_cost = 20
	dodge.defense_type = MartialArt.DefenseType.DODGE
	dodge.defense_level = 3
	dodge.dex_scaling = 0.5
	dodge.animation_duration = 0.5
	martials.append(dodge)
	
	# 4. 강력한 발차기
	var kick = MartialArt.new()
	kick.martial_id = "martial_004"
	kick.martial_name = "발차기"
	kick.description = "강력한 발차기"
	kick.base_damage = 12
	kick.energy_cost = 25
	kick.str_scaling = 0.6
	kick.dex_scaling = 0.3
	kick.animation_duration = 1.0
	martials.append(kick)
	
	# 5. 방어
	var guard = MartialArt.new()
	guard.martial_id = "martial_005"
	guard.martial_name = "방어"
	guard.description = "단단한 방어 자세"
	guard.base_damage = 0
	guard.energy_cost = 5
	guard.defense_type = MartialArt.DefenseType.GUARD
	guard.defense_level = 2
	guard.animation_duration = 0.3
	martials.append(guard)
	
	print("[DataLoader] 기본 무술 생성: %d개" % martials.size())
	return martials

# ===== 캐릭터 데이터 로드 =====

static func load_character(filename: String) -> Character:
	"""캐릭터 데이터를 로드한다"""
	
	var filepath = "%s/Characters/%s" % [data_path, filename]
	var file = FileAccess.open(filepath, FileAccess.READ)
	
	if not file:
		print("[DataLoader] 경고: 캐릭터 파일 없음 - %s" % filepath)
		return create_default_player()
	
	var json_string = file.get_as_text()
	var json = JSON.parse_string(json_string)
	
	if not json:
		return create_default_player()
	
	var player = Player.new()
	player.character_name = json.get("name", "플레이어")
	player.level = json.get("level", 1)
	player.experience = json.get("experience", 0)
	
	# 스탯
	if json.has("stats"):
		for stat_name in json["stats"]:
			player.stats[stat_name] = json["stats"][stat_name]
	
	return player

# ===== 기본 플레이어 생성 =====

static func create_default_player() -> Player:
	"""기본 플레이어를 생성한다"""
	var player = Player.new()
	player.character_name = "플레이어"
	player.level = 1
	player.experience = 0
	player.max_hp = 100
	player.current_hp = 100
	player.max_energy = 100
	player.current_energy = 100
	
	# 기본 무술 장착
	var martials = create_default_martial_arts()
	if martials.size() > 0:
		player.add_martial_art(martials[0], 0)  # 기본권
		player.add_martial_art(martials[1], 1)  # 연속권
		player.add_martial_art(martials[2], 2)  # 회피
		player.add_martial_art(martials[3], 3)  # 발차기
		player.add_martial_art(martials[4], 4)  # 방어
	
	print("[DataLoader] 기본 플레이어 생성")
	return player

# ===== 적 데이터 로드 =====

static func load_enemy(filename: String) -> Enemy:
	"""적 데이터를 로드한다"""
	
	var filepath = "%s/Enemies/%s" % [data_path, filename]
	var file = FileAccess.open(filepath, FileAccess.READ)
	
	if not file:
		print("[DataLoader] 경고: 적 파일 없음 - %s" % filepath)
		return create_default_enemy()
	
	var json_string = file.get_as_text()
	var json = JSON.parse_string(json_string)
	
	if not json:
		return create_default_enemy()
	
	var enemy = Enemy.new()
	enemy.character_name = json.get("name", "적")
	enemy.level = json.get("level", 1)
	enemy.max_hp = json.get("hp", 50)
	enemy.current_hp = enemy.max_hp
	enemy.drop_experience = json.get("experience", 50)
	
	# AI 레벨
	if enemy.ai_controller:
		enemy.ai_controller.ai_level = json.get("ai_level", 1)
	
	return enemy

# ===== 기본 적 생성 =====

static func create_default_enemy() -> Enemy:
	"""기본 적을 생성한다"""
	var enemy = Enemy.new()
	enemy.character_name = "회색 늑대"
	enemy.level = 1
	enemy.max_hp = 50
	enemy.current_hp = 50
	enemy.max_energy = 50
	enemy.current_energy = 50
	enemy.drop_experience = 50
	
	# 스탯
	enemy.stats = {
		"STR": 8,
		"DEX": 9,
		"CON": 7,
		"INT": 3,
		"WIS": 5,
		"CHA": 2
	}
	
	# 기본 무술
	var martials = create_default_martial_arts()
	if martials.size() > 0:
		enemy.add_martial_art(martials[0], 0)
	
	print("[DataLoader] 기본 적 생성")
	return enemy

# ===== 저장 =====

static func save_character(player: Player, filename: String) -> bool:
	"""캐릭터 데이터를 저장한다"""
	
	var data = {
		"name": player.character_name,
		"level": player.level,
		"experience": player.experience,
		"stats": player.stats,
		"hp": player.current_hp,
		"max_hp": player.max_hp
	}
	
	var json_string = JSON.stringify(data)
	var filepath = "%s/Characters/%s" % [data_path, filename]
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("[DataLoader] 저장: %s" % filepath)
		return true
	else:
		print("[DataLoader] 오류: 저장 실패")
		return false
