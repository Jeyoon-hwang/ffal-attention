extends Node3D
"""
Animation Test Script
- PlayerModel의 애니메이션을 테스트
- 키 입력으로 Idle/Walk/Run 전환
"""

@onready var player_model = $PlayerModel
@onready var animation_player = $PlayerModel/AnimationPlayer
@onready var camera = $Camera3D

var current_animation = "Idle"
var animations_available = []

func _ready():
	print("🎬 AnimationTest 씬 시작")
	
	# AnimationPlayer가 있는지 확인
	if animation_player == null:
		print("❌ AnimationPlayer를 찾을 수 없음")
		return
	
	# 사용 가능한 애니메이션 리스트
	animations_available = animation_player.get_animation_list()
	print(f"✅ 사용 가능한 애니메이션: {animations_available.size()}개")
	for anim in animations_available:
		print(f"  - {anim}")
	
	# 기본 애니메이션 재생
	if animations_available.size() > 0:
		play_animation(animations_available[0])
	else:
		print("⚠️ 애니메이션이 없음")

func _process(delta):
	# 입력 처리
	if Input.is_action_just_pressed("ui_accept"):  # Space
		print("🔄 다음 애니메이션으로")
		cycle_animation()
	
	# WASD로 카메라 회전
	if Input.is_key_pressed(KEY_A):
		camera.position.x -= 3 * delta
	if Input.is_key_pressed(KEY_D):
		camera.position.x += 3 * delta
	if Input.is_key_pressed(KEY_W):
		camera.position.z -= 3 * delta
	if Input.is_key_pressed(KEY_S):
		camera.position.z += 3 * delta

func play_animation(anim_name: String):
	if anim_name in animations_available:
		print(f"▶️  재생: {anim_name}")
		animation_player.play(anim_name)
		current_animation = anim_name
	else:
		print(f"❌ 애니메이션 '{anim_name}'을 찾을 수 없음")

func cycle_animation():
	if animations_available.size() == 0:
		return
	
	var current_index = animations_available.find(current_animation)
	var next_index = (current_index + 1) % animations_available.size()
	var next_animation = animations_available[next_index]
	
	play_animation(next_animation)
