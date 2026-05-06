# NEXUS 플레이어 전투 시스템
# 플레이어의 무술 발동, 데미지 계산, 콤보 관리
#
# 주요 기능:
# - 무술 발동 및 데미지 적용
# - 콤보 추적
# - 능력치 기반 피해 계산
# - 쿨타임 관리

extends Node

class_name PlayerCombat

# ============================================================================
# 상수
# ============================================================================

# 능력치 (Stats)
const STATS = {
	"str": 10,  # 근력
	"dex": 10,  # 민첩
	"int": 10,  # 지능
	"vit": 10,  # 체력
	"wis": 10,  # 지혜
	"cha": 10,  # 매력
	"lck": 10,  # 행운
	"res": 10,  # 저항
}

# ============================================================================
# 멤버 변수
# ============================================================================

var martial_engine: MartialArtEngine
var player_stats: Dictionary
var equipped_arts: Array[String] = [] # 장착된 무술 ID
var last_art_used: MartialArtEngine.MartialArt = null
var combo_timer: float = 0.0
var combo_chain: Array[MartialArtEngine.MartialArt] = []

# 각 무술별 쿨타임 타이머
var cooldowns: Dictionary = {}

# 플레이어 상태
var hp: float = 100.0
var max_hp: float = 100.0
var mp: float = 100.0
var max_mp: float = 100.0
var spirit: float = 0.0 # 특수 에너지 (내공)
var max_spirit: float = 100.0

# ============================================================================
# 초기화
# ============================================================================

func _ready() -> void:
	martial_engine = MartialArtEngine.new()
	martial_engine.initialize_base_arts()
	
	# 플레이어 기본 능력치 설정
	player_stats = STATS.duplicate()
	
	# 기본 무술 장착 (게임 시작 시)
	equip_martial_art("slash")
	equip_martial_art("thrust")
	
	print("플레이어 전투 시스템 초기화 완료")
	print("능력치: " + str(player_stats))
	print("장착 무술: " + str(equipped_arts))

# ============================================================================
# 무술 관리
# ============================================================================

## 무술 장착 (최대 2개)
func equip_martial_art(art_id: String) -> bool:
	if equipped_arts.size() >= 2:
		print("이미 2개 무술을 장착했습니다")
		return false
	
	var art = martial_engine.get_martial_art(art_id)
	if art == null:
		print("존재하지 않는 무술: " + art_id)
		return false
	
	equipped_arts.append(art_id)
	cooldowns[art_id] = 0.0
	print("무술 장착: " + art.name)
	return true

## 무술 해제
func unequip_martial_art(art_id: String) -> bool:
	if art_id in equipped_arts:
		equipped_arts.erase(art_id)
		print("무술 해제: " + art_id)
		return true
	return false

# ============================================================================
# 공격 시스템
# ============================================================================

## 무술 발동
## index: 0 또는 1 (장착된 무술 중 선택)
func use_martial_art(index: int) -> MartialArtEngine.MartialArt:
	if index < 0 or index >= equipped_arts.size():
		print("유효하지 않은 무술 인덱스: " + str(index))
		return null
	
	var art_id = equipped_arts[index]
	var art = martial_engine.get_martial_art(art_id)
	
	# 쿨타임 확인
	if cooldowns.get(art_id, 0.0) > 0.0:
		print("쿨타임 중: %s (%.1f초 남음)" % [art.name, cooldowns[art_id]])
		return null
	
	# MP 확인
	if mp < art.mana_cost:
		print("마나 부족: %s (필요: %.0f, 보유: %.0f)" % [art.name, art.mana_cost, mp])
		return null
	
	# 공격 발동
	_execute_attack(art)
	
	# 콤보 추적
	_update_combo(art)
	
	# MP 소비
	mp -= art.mana_cost
	
	# 쿨타임 설정
	cooldowns[art_id] = art.cooldown
	
	return art

## 공격 실행
func _execute_attack(art: MartialArtEngine.MartialArt) -> void:
	var damage = martial_engine.calculate_damage(art, player_stats)
	
	# 크리티컬 확인 (DEX 기반, 최대 30%)
	var crit_chance = min(0.3, player_stats["dex"] * 0.003)
	if randf() < crit_chance:
		damage *= 1.5
		print("[크리티컬] " + art.name + " (%.0f 데미지)" % damage)
	else:
		print("[공격] " + art.name + " (%.0f 데미지)" % damage)
	
	last_art_used = art

## 콤보 업데이트
func _update_combo(art: MartialArtEngine.MartialArt) -> void:
	# 새로운 무술이면 콤보 체인 초기화
	if last_art_used != null and last_art_used.id != art.id:
		combo_chain.clear()
	
	# 콤보에 추가
	combo_chain.append(art)
	combo_timer = 1.5 # 콤보 타이밍 윈도우
	
	# 콤보 보너스 (5개 이상)
	if combo_chain.size() >= 5:
		var bonus = martial_engine.calculate_combo_damage(
			martial_engine.create_combo(combo_chain),
			player_stats
		)
		print("[콤보 보너스!] %d단계 콤보 (+%.0f 데미지)" % [combo_chain.size(), bonus * 0.5])

# ============================================================================
# 능력치 및 상태 관리
# ============================================================================

## 능력치 추가
func add_stat(stat_name: String, value: int) -> void:
	if stat_name in player_stats:
		player_stats[stat_name] += value
		print("능력치 증가: %s +%d" % [stat_name, value])

## 체력 회복
func heal(amount: float) -> void:
	hp = min(hp + amount, max_hp)

## 마나 회복
func recover_mana(amount: float) -> void:
	mp = min(mp + amount, max_mp)

## 정신 에너지 (spirit) 회복
func recover_spirit(amount: float) -> void:
	spirit = min(spirit + amount, max_spirit)

## 지속 효과 (매 프레임 호출)
func _process(delta: float) -> void:
	# 쿨타임 감소
	for art_id in cooldowns.keys():
		cooldowns[art_id] = max(0.0, cooldowns[art_id] - delta)
	
	# 콤보 타이머 감소
	combo_timer = max(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		combo_chain.clear()
	
	# MP 회복 (초당 5%)
	recover_mana(max_mp * 0.05 * delta)
	
	# Spirit 회복 (초당 3%)
	recover_spirit(max_spirit * 0.03 * delta)

# ============================================================================
# 디버그
# ============================================================================

func print_stats() -> void:
	print("\n=== 플레이어 능력치 ===")
	for stat_name in player_stats.keys():
		print("%s: %d" % [stat_name, player_stats[stat_name]])
	print("HP: %.0f/%.0f | MP: %.0f/%.0f | Spirit: %.0f/%.0f" % 
		[hp, max_hp, mp, max_mp, spirit, max_spirit])

func print_equipped_arts() -> void:
	print("\n=== 장착된 무술 ===")
	for i in range(equipped_arts.size()):
		var art = martial_engine.get_martial_art(equipped_arts[i])
		print("[%d] %s (쿨타임: %.1f초)" % [i, art.name, cooldowns[equipped_arts[i]]])

func test_attack_sequence() -> void:
	print("\n>>> 무술 시퀀스 테스트 시작")
	
	# 테스트 시퀀스
	for i in range(3):
		var result = use_martial_art(0) # slash 사용
		if result == null:
			push_error("공격 실패: %d번째 시도" % (i + 1))
			await get_tree().create_timer(1.0).timeout
		else:
			await get_tree().create_timer(result.cooldown + 0.1).timeout
	
	print(">>> 무술 시퀀스 테스트 완료")
