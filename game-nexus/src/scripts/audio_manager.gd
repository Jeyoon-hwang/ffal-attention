extends Node

# 🎵 Audio Manager - 음악, 효과음, 음량 관리
# 지역별 BGM, 전투음, 효과음 담당

class_name AudioManager

# 음악 타입
enum MUSIC_TYPE {
	REGION,
	BATTLE,
	BOSS,
	MENU,
	VICTORY,
	DEFEAT
}

# 현재 음악
var current_music: String = ""
var current_music_type: int = MUSIC_TYPE.REGION
var is_transitioning: bool = false

# 음악 데이터
var music_library: Dictionary = {
	# 지역별 BGM
	"central_plains": {
		"type": MUSIC_TYPE.REGION,
		"name": "중원의 바람",
		"duration": 180.0,
		"tempo": "moderate"
	},
	"frozen_lands": {
		"type": MUSIC_TYPE.REGION,
		"name": "동토의 설원",
		"duration": 180.0,
		"tempo": "slow"
	},
	"south_sea": {
		"type": MUSIC_TYPE.REGION,
		"name": "남해의 파도",
		"duration": 180.0,
		"tempo": "bright"
	},
	"western_desert": {
		"type": MUSIC_TYPE.REGION,
		"name": "서역의 신비",
		"duration": 180.0,
		"tempo": "exotic"
	},
	"northern_peaks": {
		"type": MUSIC_TYPE.REGION,
		"name": "북방의 영혼",
		"duration": 180.0,
		"tempo": "epic"
	},
	
	# 전투 BGM
	"battle_normal": {
		"type": MUSIC_TYPE.BATTLE,
		"name": "일반 전투",
		"duration": 120.0,
		"tempo": "fast"
	},
	"battle_intense": {
		"type": MUSIC_TYPE.BATTLE,
		"name": "격렬한 전투",
		"duration": 120.0,
		"tempo": "very_fast"
	},
	
	# 보스 BGM
	"boss_normal": {
		"type": MUSIC_TYPE.BOSS,
		"name": "보스 전투",
		"duration": 240.0,
		"tempo": "epic"
	},
	"boss_final": {
		"type": MUSIC_TYPE.BOSS,
		"name": "최종 보스",
		"duration": 300.0,
		"tempo": "very_epic"
	},
	
	# 승/패
	"victory": {
		"type": MUSIC_TYPE.VICTORY,
		"name": "승리",
		"duration": 30.0,
		"tempo": "triumphant"
	},
	"defeat": {
		"type": MUSIC_TYPE.DEFEAT,
		"name": "패배",
		"duration": 30.0,
		"tempo": "sad"
	}
}

# 효과음 데이터
var sfx_library: Dictionary = {
	# 공격음
	"attack_sword": {
		"category": "combat",
		"pitch": 1.0,
		"volume": 0.7
	},
	"attack_magic": {
		"category": "combat",
		"pitch": 1.0,
		"volume": 0.8
	},
	"attack_fist": {
		"category": "combat",
		"pitch": 0.9,
		"volume": 0.6
	},
	"attack_kick": {
		"category": "combat",
		"pitch": 1.1,
		"volume": 0.7
	},
	"attack_combo": {
		"category": "combat",
		"pitch": 1.0,
		"volume": 0.8
	},
	
	# 방어음
	"defend_block": {
		"category": "combat",
		"pitch": 1.0,
		"volume": 0.6
	},
	"dodge_success": {
		"category": "combat",
		"pitch": 1.2,
		"volume": 0.5
	},
	
	# 보스음
	"boss_roar": {
		"category": "boss",
		"pitch": 0.8,
		"volume": 0.9
	},
	"boss_attack": {
		"category": "boss",
		"pitch": 0.9,
		"volume": 0.8
	},
	
	# UI 효과음
	"ui_click": {
		"category": "ui",
		"pitch": 1.0,
		"volume": 0.4
	},
	"ui_confirm": {
		"category": "ui",
		"pitch": 1.2,
		"volume": 0.5
	},
	"ui_cancel": {
		"category": "ui",
		"pitch": 0.8,
		"volume": 0.4
	},
	
	# 환경음
	"wind_blow": {
		"category": "environment",
		"pitch": 1.0,
		"volume": 0.3
	},
	"water_splash": {
		"category": "environment",
		"pitch": 1.0,
		"volume": 0.5
	},
	"snow_crunch": {
		"category": "environment",
		"pitch": 0.95,
		"volume": 0.4
	}
}

# 음량 설정
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ambient_volume: float = 0.5

# 음악 플레이어 (AudioStreamPlayer)
var music_player: AudioStreamPlayer = null
var fade_time: float = 1.5  # 페이드 인/아웃 시간

# 효과음 플레이어 (풀링)
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_pool_size: int = 10

# 지역별 음악 매핑
var region_music_map: Dictionary = {
	"중원": "central_plains",
	"동토": "frozen_lands",
	"남해": "south_sea",
	"서역": "western_desert",
	"북방": "northern_peaks"
}

func _ready():
	# 음악 플레이어 생성
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	# 효과음 플레이어 풀 생성
	for i in range(sfx_pool_size):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "Master"
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	print("🎵 Audio Manager 준비 완료")
	print("  음악: ", music_volume * 100, "%")
	print("  효과음: ", sfx_volume * 100, "%")

# 🎵 지역별 음악 재생
func play_region_music(region_name: String) -> void:
	var music_key = region_music_map.get(region_name, "central_plains")
	play_music(music_key)

# 🎵 음악 재생
func play_music(music_key: String) -> void:
	if not music_key in music_library:
		print("❌ 음악을 찾을 수 없음: ", music_key)
		return
	
	if current_music == music_key:
		return  # 이미 재생 중
	
	var music_data = music_library[music_key]
	
	print("🎵 음악 재생: ", music_data["name"])
	
	# 나중에 실제 오디오 파일 로드
	# 임시로 로그만 출력
	current_music = music_key
	current_music_type = music_data["type"]

# 🎵 전투 음악 재생
func play_battle_music(intensity: int = 0) -> void:
	match intensity:
		0:
			play_music("battle_normal")
		1:
			play_music("battle_intense")
		_:
			play_music("battle_normal")

# 🎵 보스 음악 재생
func play_boss_music(is_final: bool = false) -> void:
	if is_final:
		play_music("boss_final")
	else:
		play_music("boss_normal")

# 🎵 승리/패배 음악 재생
func play_result_music(victory: bool) -> void:
	if victory:
		play_music("victory")
	else:
		play_music("defeat")

# 🔊 효과음 재생
func play_sfx(sfx_key: String) -> void:
	if not sfx_key in sfx_library:
		print("❌ 효과음을 찾을 수 없음: ", sfx_key)
		return
	
	var sfx_data = sfx_library[sfx_key]
	
	# 사용 가능한 플레이어 찾기
	var player = null
	for sfx_player in sfx_players:
		if not sfx_player.playing:
			player = sfx_player
			break
	
	if not player:
		print("⚠️ 효과음 플레이어 부족: ", sfx_key)
		return
	
	# 음량 및 피치 설정
	player.volume_db = linear2db(sfx_data["volume"] * sfx_volume * master_volume)
	if player.has_method("set_pitch_scale"):
		player.pitch_scale = sfx_data["pitch"]
	
	print("🔊 효과음: ", sfx_key)
	# player.play()  # 실제 오디오 파일이 있을 때

# 🎵 음악 정지
func stop_music() -> void:
	if music_player.playing:
		music_player.stop()
	current_music = ""
	print("⏹️ 음악 정지")

# 🔇 음악 일시 중지
func pause_music() -> void:
	music_player.stream_paused = true
	print("⏸️ 음악 일시 중지")

# ▶️ 음악 재개
func resume_music() -> void:
	music_player.stream_paused = false
	print("▶️ 음악 재개")

# 🔊 마스터 음량 설정 (0.0 ~ 1.0)
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear2db(music_volume * master_volume)
	print("🔊 마스터 음량: ", volume * 100, "%")

# 🎵 음악 음량 설정 (0.0 ~ 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear2db(music_volume * master_volume)
	print("🎵 음악 음량: ", volume * 100, "%")

# 🔊 효과음 음량 설정 (0.0 ~ 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	print("🔊 효과음 음량: ", volume * 100, "%")

# 🎵 주변음 음량 설정 (0.0 ~ 1.0)
func set_ambient_volume(volume: float) -> void:
	ambient_volume = clamp(volume, 0.0, 1.0)
	print("🎵 주변음 음량: ", volume * 100, "%")

# 📊 현재 음악 정보 반환
func get_current_music_info() -> Dictionary:
	if current_music in music_library:
		return music_library[current_music].duplicate()
	return {}

# ✅ 음악 재생 여부
func is_music_playing() -> bool:
	return music_player.playing

# 📋 모든 음악 리스트
func get_all_music() -> Array:
	return music_library.keys()

# 📋 모든 효과음 리스트
func get_all_sfx() -> Array:
	return sfx_library.keys()

# 📊 현재 상태 출력
func print_status() -> void:
	print("\n🎵 Audio Manager 상태:")
	print("  현재 음악: ", current_music)
	print("  마스터 음량: ", master_volume * 100, "%")
	print("  음악 음량: ", music_volume * 100, "%")
	print("  효과음 음량: ", sfx_volume * 100, "%")
	print("  주변음 음량: ", ambient_volume * 100, "%\n")

# 🔄 오디오 스트림 로드 (나중에 구현)
func load_audio_file(path: String) -> AudioStream:
	# 나중에 실제 오디오 파일 로드
	return null

# 🔄 효과음 풀 리셋
func reset_sfx_pool() -> void:
	for sfx_player in sfx_players:
		sfx_player.stop()
	print("✅ 효과음 풀 리셋")
