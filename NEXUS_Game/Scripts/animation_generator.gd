@tool
extends Node
class_name AnimationGenerator
## 애니메이션 자동 생성 엔진
## 무술과 캐릭터 종류에 따라 애니메이션 클립을 자동 생성

const Animation = preload("res://addons/godot_animations/animation.gd")

## 애니메이션 종류
enum AnimType {
	IDLE,              # 대기
	WALK_F, WALK_B, WALK_L, WALK_R,  # 이동
	RUN_F, RUN_B, RUN_L, RUN_R,      # 달리기
	JUMP, FALL, LAND,                 # 점프/낙하
	
	ATTACK_PUNCH,      # 펀치
	ATTACK_KICK,       # 킥
	ATTACK_PALM,       # 장파
	ATTACK_SPIN,       # 회전 공격
	ATTACK_THRUST,     # 찌르기
	ATTACK_SWEEP,      # 휘두르기
	
	DEFENSE_BLOCK,     # 방어
	DEFENSE_DODGE,     # 회피
	DEFENSE_PARRY,     # 막기
	
	HIT_LIGHT,         # 가벼운 피격
	HIT_HEAVY,         # 무거운 피격
	HIT_KNOCKBACK,     # 넉백
	HIT_LAUNCH,        # 띄워지기
	
	STUN, FROZEN, BURN,  # 상태이상
	
	DEATH,             # 사망
	REVIVE,            # 부활
	
	EMOTE_CELEBRATE,   # 승리
	EMOTE_BOW,         # 인사
	EMOTE_LAUGH,       # 웃음
}

## 캐릭터 유형별 애니메이션 정의
class AnimConfig:
	var type: String  # "human", "wolf", "bat", "skeleton", etc.
	var bones: Array[String]  # 본 이름 목록
	var hand_bones: Array[String]
	var foot_bones: Array[String]
	var spine_bones: Array[String]
	var head_bone: String
	
	func _init(p_type: String):
		type = p_type
		match p_type:
			"human":
				bones = ["Armature", "Hips", "Spine", "Chest", "Neck", "Head",
						"LeftShoulder", "LeftArm", "LeftForeArm", "LeftHand",
						"RightShoulder", "RightArm", "RightForeArm", "RightHand",
						"LeftUpLeg", "LeftLeg", "LeftFoot",
						"RightUpLeg", "RightLeg", "RightFoot"]
				hand_bones = ["LeftHand", "RightHand"]
				foot_bones = ["LeftFoot", "RightFoot"]
				spine_bones = ["Spine", "Chest", "Neck"]
				head_bone = "Head"
			"wolf":
				bones = ["Armature", "Hips", "Spine", "Chest", "Neck", "Head",
						"Jaw", "LeftFrontLeg", "LeftFrontPaw", "RightFrontLeg", "RightFrontPaw",
						"LeftBackLeg", "LeftBackPaw", "RightBackLeg", "RightBackPaw", "Tail"]
				hand_bones = ["Jaw"]
				foot_bones = ["LeftFrontPaw", "RightFrontPaw", "LeftBackPaw", "RightBackPaw"]
				spine_bones = ["Spine", "Chest", "Neck"]
				head_bone = "Head"
			"bat":
				bones = ["Armature", "Hips", "Spine", "Chest", "Neck", "Head",
						"LeftWing", "RightWing", "LeftWingTip", "RightWingTip", "Tail"]
				hand_bones = ["LeftWing", "RightWing"]
				foot_bones = ["LeftWingTip", "RightWingTip"]
				spine_bones = ["Spine", "Chest"]
				head_bone = "Head"
			_:
				# 기본값
				bones = ["Armature", "Root", "Spine", "Head"]
				hand_bones = []
				foot_bones = []
				spine_bones = ["Spine"]
				head_bone = "Head"

## 개별 프레임 정의
class KeyFrame:
	var time: float
	var bone: String
	var position: Vector3
	var rotation: Quaternion
	var scale: Vector3 = Vector3.ONE
	
	func _init(p_time: float, p_bone: String, p_pos: Vector3, p_rot: Quaternion):
		time = p_time
		bone = p_bone
		position = p_pos
		rotation = p_rot

## 생성된 애니메이션
class AnimationClip:
	var name: String
	var length: float
	var fps: float = 30.0
	var loop: bool = false
	var frames: Array[KeyFrame] = []
	
	func _init(p_name: String, p_length: float, p_fps: float = 30.0):
		name = p_name
		length = p_length
		fps = p_fps
	
	func add_frame(frame: KeyFrame):
		frames.append(frame)
	
	func to_godot_animation() -> Animation:
		var anim = Animation.new()
		anim.name = name
		anim.length = length
		
		# 현재는 더미 반환 (실제로는 Godot Animation으로 변환)
		return anim

# ============== 애니메이션 생성 함수 ==============

static func generate_animations(character_type: String) -> Dictionary:
	"""모든 애니메이션 생성 및 반환"""
	var config = AnimConfig.new(character_type)
	var anims = {}
	
	# 기본 애니메이션
	anims["idle"] = _gen_idle(config)
	anims["walk_f"] = _gen_walk(config, Vector3.FORWARD)
	anims["walk_b"] = _gen_walk(config, Vector3.BACK)
	anims["walk_l"] = _gen_walk(config, Vector3.LEFT)
	anims["walk_r"] = _gen_walk(config, Vector3.RIGHT)
	anims["run_f"] = _gen_run(config, Vector3.FORWARD)
	anims["jump"] = _gen_jump(config)
	anims["fall"] = _gen_fall(config)
	anims["land"] = _gen_land(config)
	
	# 공격 애니메이션
	anims["attack_punch"] = _gen_punch(config)
	anims["attack_kick"] = _gen_kick(config)
	anims["attack_palm"] = _gen_palm(config)
	anims["attack_spin"] = _gen_spin(config)
	
	# 방어 애니메이션
	anims["defense_block"] = _gen_block(config)
	anims["defense_dodge"] = _gen_dodge(config)
	
	# 피격 애니메이션
	anims["hit_light"] = _gen_hit_light(config)
	anims["hit_heavy"] = _gen_hit_heavy(config)
	anims["knockback"] = _gen_knockback(config)
	
	# 상태이상
	anims["stun"] = _gen_stun(config)
	anims["frozen"] = _gen_frozen(config)
	
	# 사망/승리
	anims["death"] = _gen_death(config)
	anims["revive"] = _gen_revive(config)
	anims["celebrate"] = _gen_celebrate(config)
	
	return anims

## == 기본 애니메이션 ==

static func _gen_idle(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Idle", 1.0)
	anim.loop = true
	
	# 신체는 거의 움직이지 않음
	anim.add_frame(KeyFrame.new(0.0, config.head_bone, Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.5, config.head_bone, Vector3(0, 0.05, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(1.0, config.head_bone, Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_walk(config: AnimConfig, direction: Vector3) -> AnimationClip:
	var anim = AnimationClip.new("Walk_%s" % direction.to_string(), 0.8)
	anim.loop = true
	
	# 다리 움직임 (한 발씩 교대로)
	for i in range(4):  # 4 스텝
		var time = i * 0.2
		var left_idx = 0 if i % 2 == 0 else 1
		var right_idx = 1 if i % 2 == 0 else 0
		
		if config.foot_bones.size() >= 2:
			# 왼발
			anim.add_frame(KeyFrame.new(time, config.foot_bones[0], 
				Vector3(0, float(left_idx) * 0.2, -0.3 * float(i % 2)), Quaternion.IDENTITY))
			# 오른발
			anim.add_frame(KeyFrame.new(time, config.foot_bones[1],
				Vector3(0, float(right_idx) * 0.2, 0.3 * float((i+1) % 2)), Quaternion.IDENTITY))
	
	# 상체 약간 흔들림
	for i in range(4):
		var time = i * 0.2
		var angle = PI / 4 * sin(float(i) * PI / 2)
		anim.add_frame(KeyFrame.new(time, config.spine_bones[0],
			Vector3.ZERO, Quaternion.from_euler(Vector3(0, angle, 0))))
	
	return anim

static func _gen_run(config: AnimConfig, direction: Vector3) -> AnimationClip:
	var anim = AnimationClip.new("Run_%s" % direction.to_string(), 0.5)
	anim.loop = true
	
	# Walk보다 더 큰 움직임, 더 빠른 템포
	for i in range(6):
		var time = i * 0.083
		if config.foot_bones.size() >= 2:
			anim.add_frame(KeyFrame.new(time, config.foot_bones[i % 2],
				Vector3(0, 0.1, sin(float(i) * PI / 3) * 0.4), Quaternion.IDENTITY))
	
	return anim

static func _gen_jump(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Jump", 0.6)
	
	# 웅크렸다 → 펴짐 → 착지
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3(0, -0.2, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.2, config.spine_bones[0], Vector3(0, 0.5, 0), Quaternion.IDENTITY))  # 높이 올라갔을 때
	anim.add_frame(KeyFrame.new(0.4, config.spine_bones[0], Vector3(0, 0.3, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.6, config.spine_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	# 팔
	if config.hand_bones.size() >= 2:
		anim.add_frame(KeyFrame.new(0.0, config.hand_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.2, config.hand_bones[0], Vector3(0.3, 0.3, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.6, config.hand_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	return anim

static func _gen_fall(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Fall", 0.8)
	
	# 자유낙하 포즈
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.8, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_land(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Land", 0.4)
	
	# 착지 쇼크 흡수
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3(0, -0.1, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.2, config.spine_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.4, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

## == 공격 애니메이션 ==

static func _gen_punch(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("AttackPunch", 0.4)
	
	# 준비 → 펀치 → 복귀
	if config.hand_bones.size() >= 1:
		anim.add_frame(KeyFrame.new(0.0, config.hand_bones[0], Vector3(-0.2, 0, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.15, config.hand_bones[0], Vector3(0.4, 0, 0), Quaternion.IDENTITY))  # 최대 뻗음
		anim.add_frame(KeyFrame.new(0.4, config.hand_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	# 상체 회전
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.3, 0))))
	anim.add_frame(KeyFrame.new(0.15, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, 0.2, 0))))
	anim.add_frame(KeyFrame.new(0.4, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_kick(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("AttackKick", 0.5)
	
	# 킥 모션
	if config.foot_bones.size() >= 2:
		# 한 발을 들어올림
		anim.add_frame(KeyFrame.new(0.0, config.foot_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.2, config.foot_bones[0], Vector3(0.3, 0.3, 0.4), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.5, config.foot_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	# 상체 회전
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.2, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0.2, 0.3, 0))))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_palm(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("AttackPalm", 0.45)
	
	# 두 손 모으기 → 밀기
	if config.hand_bones.size() >= 2:
		anim.add_frame(KeyFrame.new(0.0, config.hand_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.1, config.hand_bones[0], Vector3(0, 0.1, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.2, config.hand_bones[0], Vector3(0.5, 0, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.45, config.hand_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	# 전신 뒤로 밀려남
	anim.add_frame(KeyFrame.new(0.2, config.spine_bones[0], Vector3(0, 0, -0.2), Quaternion.IDENTITY))
	
	return anim

static func _gen_spin(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("AttackSpin", 0.6)
	
	# 360도 회전
	for i in range(7):
		var time = float(i) * 0.086
		var angle = float(i) * PI / 3
		anim.add_frame(KeyFrame.new(time, config.spine_bones[0], Vector3.ZERO, 
			Quaternion.from_euler(Vector3(0, angle, 0))))
	
	return anim

## == 방어 애니메이션 ==

static func _gen_block(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("DefenseBlock", 0.5)
	anim.loop = true
	
	# 방어 자세
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.2, 0))))
	anim.add_frame(KeyFrame.new(0.25, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.15, 0))))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.2, 0))))
	
	return anim

static func _gen_dodge(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("DefenseDodge", 0.4)
	
	# 옆으로 구르기
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.2, config.spine_bones[0], Vector3(0.3, 0, 0), Quaternion.from_euler(Vector3(PI/2, 0, 0))))
	anim.add_frame(KeyFrame.new(0.4, config.spine_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	return anim

## == 피격 애니메이션 ==

static func _gen_hit_light(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("HitLight", 0.3)
	
	# 약간 흔들림
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.1, config.spine_bones[0], Vector3(-0.1, 0, 0), Quaternion.from_euler(Vector3(0, -0.1, 0))))
	anim.add_frame(KeyFrame.new(0.3, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_hit_heavy(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("HitHeavy", 0.5)
	
	# 크게 튕겨남
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.2, config.spine_bones[0], Vector3(-0.3, 0, 0), Quaternion.from_euler(Vector3(0, -0.3, 0.1))))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_knockback(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Knockback", 0.6)
	
	# 뒤로 밀려나기
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.3, config.spine_bones[0], Vector3(0, 0.2, -0.5), Quaternion.from_euler(Vector3(0.2, 0, 0))))
	anim.add_frame(KeyFrame.new(0.6, config.spine_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	
	return anim

## == 상태이상 ==

static func _gen_stun(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Stun", 1.0)
	anim.loop = true
	
	# 흔들리며 비틀거림
	for i in range(6):
		var time = float(i) * 0.167
		var angle = sin(float(i) * PI / 3) * 0.2
		anim.add_frame(KeyFrame.new(time, config.head_bone, Vector3.ZERO, 
			Quaternion.from_euler(Vector3(0, angle, 0))))
	
	return anim

static func _gen_frozen(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Frozen", 0.5)
	anim.loop = true
	
	# 얼음처럼 경직된 포즈, 약간 떨림
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3(0, 0, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.25, config.spine_bones[0], Vector3(0.05, 0, 0), Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

## == 사망/부활 ==

static func _gen_death(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Death", 1.0)
	
	# 넘어지기
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3(-0.3, -0.5, 0), 
		Quaternion.from_euler(Vector3(PI / 2, 0, 0))))
	anim.add_frame(KeyFrame.new(1.0, config.spine_bones[0], Vector3(-0.3, -0.5, 0),
		Quaternion.from_euler(Vector3(PI / 2, 0, 0))))
	
	return anim

static func _gen_revive(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Revive", 1.0)
	
	# 부활 (Death의 역순)
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3(-0.3, -0.5, 0), 
		Quaternion.from_euler(Vector3(PI / 2, 0, 0))))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	anim.add_frame(KeyFrame.new(1.0, config.spine_bones[0], Vector3.ZERO, Quaternion.IDENTITY))
	
	return anim

static func _gen_celebrate(config: AnimConfig) -> AnimationClip:
	var anim = AnimationClip.new("Celebrate", 1.0)
	anim.loop = true
	
	# 양팔 들고 환호
	if config.hand_bones.size() >= 2:
		anim.add_frame(KeyFrame.new(0.0, config.hand_bones[0], Vector3(0, 0.3, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.5, config.hand_bones[0], Vector3(0, 0.5, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(1.0, config.hand_bones[0], Vector3(0, 0.3, 0), Quaternion.IDENTITY))
		
		anim.add_frame(KeyFrame.new(0.0, config.hand_bones[1], Vector3(0, 0.3, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(0.5, config.hand_bones[1], Vector3(0, 0.5, 0), Quaternion.IDENTITY))
		anim.add_frame(KeyFrame.new(1.0, config.hand_bones[1], Vector3(0, 0.3, 0), Quaternion.IDENTITY))
	
	# 상체 흔들림
	anim.add_frame(KeyFrame.new(0.0, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.1, 0))))
	anim.add_frame(KeyFrame.new(0.25, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, 0.1, 0))))
	anim.add_frame(KeyFrame.new(0.5, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.1, 0))))
	anim.add_frame(KeyFrame.new(0.75, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, 0.1, 0))))
	anim.add_frame(KeyFrame.new(1.0, config.spine_bones[0], Vector3.ZERO, Quaternion.from_euler(Vector3(0, -0.1, 0))))
	
	return anim
