extends Node3D

# 🌍 Environment System - 지역별 환경 효과 관리
# 날씨, 시간, 플레이어 버프/디버프 등을 담당

class_name EnvironmentSystem

# 환경 타입
enum ENVIRONMENT {
	CENTRAL_PLAINS,
	FROZEN_LANDS,
	SOUTH_SEA,
	WESTERN_DESERT,
	NORTHERN_PEAKS
}

enum WEATHER {
	CLEAR,
	CLOUDY,
	RAIN,
	SNOW,
	SANDSTORM,
	WIND
}

enum TIME_OF_DAY {
	DAWN,
	MORNING,
	NOON,
	EVENING,
	NIGHT
}

# 현재 환경 상태
var current_environment: int = ENVIRONMENT.CENTRAL_PLAINS
var current_weather: int = WEATHER.CLEAR
var current_time: int = TIME_OF_DAY.NOON
var game_time: float = 0.0

# 환경별 설정 데이터
var environment_data: Dictionary = {
	ENVIRONMENT.CENTRAL_PLAINS: {
		"name": "중원",
		"base_color": Color(0.8, 0.8, 0.7),
		"light_energy": 1.5,
		"light_color": Color(1.0, 1.0, 0.9),
		"weather_types": [WEATHER.CLEAR, WEATHER.CLOUDY, WEATHER.RAIN],
		"has_particles": false
	},
	ENVIRONMENT.FROZEN_LANDS: {
		"name": "동토",
		"base_color": Color(0.9, 0.95, 1.0),
		"light_energy": 1.3,
		"light_color": Color(0.8, 0.9, 1.0),
		"weather_types": [WEATHER.CLEAR, WEATHER.CLOUDY, WEATHER.SNOW],
		"has_particles": true
	},
	ENVIRONMENT.SOUTH_SEA: {
		"name": "남해",
		"base_color": Color(0.95, 0.9, 0.7),
		"light_energy": 1.6,
		"light_color": Color(1.0, 0.95, 0.85),
		"weather_types": [WEATHER.CLEAR, WEATHER.CLOUDY, WEATHER.RAIN],
		"has_particles": true
	},
	ENVIRONMENT.WESTERN_DESERT: {
		"name": "서역",
		"base_color": Color(0.95, 0.85, 0.6),
		"light_energy": 1.7,
		"light_color": Color(1.0, 0.9, 0.7),
		"weather_types": [WEATHER.CLEAR, WEATHER.SANDSTORM, WEATHER.WIND],
		"has_particles": true
	},
	ENVIRONMENT.NORTHERN_PEAKS: {
		"name": "북방",
		"base_color": Color(0.6, 0.65, 0.7),
		"light_energy": 1.4,
		"light_color": Color(0.85, 0.9, 1.0),
		"weather_types": [WEATHER.CLOUDY, WEATHER.SNOW, WEATHER.WIND],
		"has_particles": true
	}
}

# 플레이어 효과 (지역별)
var player_effects: Dictionary = {
	ENVIRONMENT.CENTRAL_PLAINS: {
		"health_regen": 0.0,
		"mana_regen": 0.0,
		"movement_speed": 1.0,
		"critical_chance": 0.0,
		"damage_multiplier": 1.0,
		"description": "기본 환경"
	},
	ENVIRONMENT.FROZEN_LANDS: {
		"health_regen": -0.05,  # 1초에 5% 체력 감소
		"mana_regen": 0.1,      # 10% 빠른 마나 회복
		"movement_speed": 0.85, # 15% 느림
		"critical_chance": 0.0,
		"damage_multiplier": 1.0,
		"description": "추위로 인한 체력 감소, 마나 회복 증가"
	},
	ENVIRONMENT.SOUTH_SEA: {
		"health_regen": 0.05,   # 1초에 5% 체력 회복
		"mana_regen": 0.0,
		"movement_speed": 0.90, # 10% 느림 (모래)
		"critical_chance": 0.05,
		"damage_multiplier": 0.95,
		"description": "습한 환경, 체력 회복, 크리티컬 증가"
	},
	ENVIRONMENT.WESTERN_DESERT: {
		"health_regen": -0.03,  # 3% 체력 감소
		"mana_regen": -0.1,     # 10% 마나 회복 감소
		"movement_speed": 0.80, # 20% 느림 (모래)
		"critical_chance": 0.0,
		"damage_multiplier": 1.1, # 10% 데미지 증가
		"description": "건조한 환경, 마나 소비 증가, 데미지 증가"
	},
	ENVIRONMENT.NORTHERN_PEAKS: {
		"health_regen": -0.02,  # 2% 체력 감소
		"mana_regen": 0.05,     # 5% 마나 회복 증가
		"movement_speed": 0.95,
		"critical_chance": 0.15, # 15% 크리티컬 증가 (집중력)
		"damage_multiplier": 1.05,
		"description": "신성한 산, 크리티컬 증가"
	}
}

# 파티클 이펙트 (날씨별)
var weather_particles: Dictionary = {
	WEATHER.SNOW: {
		"particle_name": "snow",
		"speed": 0.5,
		"density": 100
	},
	WEATHER.RAIN: {
		"particle_name": "rain",
		"speed": 2.0,
		"density": 150
	},
	WEATHER.SANDSTORM: {
		"particle_name": "sand",
		"speed": 1.5,
		"density": 200
	},
	WEATHER.WIND: {
		"particle_name": "wind",
		"speed": 1.0,
		"density": 50
	}
}

# 활성 파티클 (참조)
var active_particles: Array = []

# 참조
var player_ref: Node = null
var directional_light: DirectionalLight3D = null
var camera_ref: Camera3D = null

# 시간 변화 설정
var day_duration: float = 300.0  # 5분 = 1일
var update_interval: float = 0.1

func _ready():
	set_process(true)
	
	# 게임 시작 시 중원으로 설정
	set_environment(ENVIRONMENT.CENTRAL_PLAINS)
	set_weather(WEATHER.CLEAR)

func _process(delta):
	# 시간 업데이트
	game_time += delta
	update_time_of_day()
	
	# 플레이어 효과 업데이트 (0.1초마다)
	if fmod(game_time, update_interval) < delta:
		apply_environment_effects_to_player()

# 🌍 지역 설정
func set_environment(env_id: int) -> void:
	if env_id not in environment_data:
		print("❌ Unknown environment: ", env_id)
		return
	
	current_environment = env_id
	var env = environment_data[env_id]
	
	print("🌍 설정된 지역: ", env["name"])
	
	# 라이팅 업데이트
	update_lighting(env)
	
	# 날씨 재설정 (지역에 맞는 날씨)
	var default_weather = env["weather_types"][0]
	set_weather(default_weather)

# 🌪️ 날씨 설정
func set_weather(weather_id: int) -> void:
	if weather_id not in WEATHER.values():
		print("❌ Unknown weather: ", weather_id)
		return
	
	current_weather = weather_id
	
	# 이전 파티클 제거
	clear_weather_particles()
	
	# 새 파티클 생성 (선택적)
	if weather_id in weather_particles:
		spawn_weather_particles(weather_id)
	
	print("🌪️ 날씨 변경: ", WEATHER.keys()[weather_id])

# ⏰ 시간 설정
func set_time(time_id: int) -> void:
	if time_id not in TIME_OF_DAY.values():
		print("❌ Unknown time: ", time_id)
		return
	
	current_time = time_id
	update_lighting_for_time()
	print("⏰ 시간 변경: ", TIME_OF_DAY.keys()[time_id])

# 🔄 시간 자동 업데이트
func update_time_of_day() -> void:
	var cycle_position = fmod(game_time, day_duration) / day_duration
	
	if cycle_position < 0.15:
		current_time = TIME_OF_DAY.DAWN
	elif cycle_position < 0.35:
		current_time = TIME_OF_DAY.MORNING
	elif cycle_position < 0.65:
		current_time = TIME_OF_DAY.NOON
	elif cycle_position < 0.85:
		current_time = TIME_OF_DAY.EVENING
	else:
		current_time = TIME_OF_DAY.NIGHT
	
	update_lighting_for_time()

# 💡 라이팅 업데이트 (지역별)
func update_lighting(env: Dictionary) -> void:
	directional_light = find_directional_light()
	if directional_light:
		directional_light.light_energy_multiplier = env["light_energy"]
		directional_light.light_color = env["light_color"]

# 💡 라이팅 업데이트 (시간별)
func update_lighting_for_time() -> void:
	if not directional_light:
		directional_light = find_directional_light()
		if not directional_light:
			return
	
	var brightness_map = {
		TIME_OF_DAY.DAWN: 0.6,
		TIME_OF_DAY.MORNING: 1.0,
		TIME_OF_DAY.NOON: 1.3,
		TIME_OF_DAY.EVENING: 0.8,
		TIME_OF_DAY.NIGHT: 0.2
	}
	
	var brightness = brightness_map[current_time]
	directional_light.light_energy_multiplier = brightness

# 👤 플레이어에게 환경 효과 적용
func apply_environment_effects_to_player() -> void:
	if not player_ref:
		return
	
	var effects = get_current_environment_effects()
	
	# 체력 재생/감소 적용
	if effects["health_regen"] != 0.0:
		var health_change = player_ref.max_health * effects["health_regen"] * update_interval
		player_ref.health = clamp(player_ref.health + health_change, 0, player_ref.max_health)

# 🎯 현재 환경의 모든 효과 반환
func get_current_environment_effects() -> Dictionary:
	return player_effects[current_environment].duplicate()

# 🎯 특정 환경의 효과 반환
func get_environment_effect(env_id: int, effect_name: str):
	if env_id in player_effects:
		if effect_name in player_effects[env_id]:
			return player_effects[env_id][effect_name]
	return null

# 🎨 파티클 생성
func spawn_weather_particles(weather_id: int) -> void:
	if weather_id not in weather_particles:
		return
	
	var particle_data = weather_particles[weather_id]
	print("✨ 파티클 생성: ", particle_data["particle_name"])
	
	# 실제 파티클 구현은 나중에
	# 임시로 로그만 출력

# 🗑️ 파티클 제거
func clear_weather_particles() -> void:
	for particle in active_particles:
		if is_instance_valid(particle):
			particle.queue_free()
	active_particles.clear()

# 🔍 DirectionalLight 찾기
func find_directional_light() -> DirectionalLight3D:
	var lights = find_children("*", "DirectionalLight3D")
	if lights.size() > 0:
		return lights[0]
	return null

# 📊 현재 상태 출력
func print_environment_status() -> void:
	var env = environment_data[current_environment]
	var effects = player_effects[current_environment]
	
	print("\n📍 환경 상태:")
	print("  지역: ", env["name"])
	print("  날씨: ", WEATHER.keys()[current_weather])
	print("  시간: ", TIME_OF_DAY.keys()[current_time])
	print("\n⚡ 플레이어 효과:")
	print("  체력: ", effects["health_regen"] * 100, "%/초")
	print("  마나: ", effects["mana_regen"] * 100, "%/초")
	print("  이동속도: ", effects["movement_speed"] * 100, "%")
	print("  크리티컬: ", effects["critical_chance"] * 100, "%")
	print("  데미지: ", effects["damage_multiplier"] * 100, "%\n")

# 🔗 플레이어 참조 설정
func set_player_ref(player: Node) -> void:
	player_ref = player

# 🔗 카메라 참조 설정
func set_camera_ref(camera: Camera3D) -> void:
	camera_ref = camera

# 📋 모든 지역 리스트 반환
func get_all_environments() -> Array:
	return environment_data.keys()

# 📋 모든 날씨 리스트 반환
func get_all_weathers() -> Array:
	return weather_particles.keys()

# 🎯 지역 이름으로 환경 설정
func set_environment_by_name(name: String) -> void:
	for env_id in environment_data.keys():
		if environment_data[env_id]["name"] == name:
			set_environment(env_id)
			return
	print("❌ 지역을 찾을 수 없음: ", name)

# ✅ 지역 변경 감지
func has_environment_changed() -> bool:
	# 나중에 이전 환경과 비교
	return false
