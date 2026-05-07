extends Node3D

# 👥 NPC Spawner - NPC를 3D 환경에 배치 & 관리
# 지역별 NPC 배치, 애니메이션, 상호작용

class_name NPCSpawner

# NPC 직업별 색상
var job_colors: Dictionary = {
	"merchant": Color(1.0, 0.8, 0.0),        # 황금색 = 상인
	"teacher": Color(0.5, 0.8, 1.0),        # 파란색 = 스승
	"warrior": Color(1.0, 0.2, 0.2),        # 빨간색 = 전사
	"mage": Color(0.8, 0.2, 1.0),           # 보라색 = 마법사
	"innkeeper": Color(0.8, 0.4, 0.2),      # 주황색 = 여관주인
	"priest": Color(1.0, 1.0, 0.8),         # 연한 노랑 = 종교인
	"scholar": Color(0.6, 0.6, 0.6),        # 회색 = 학자
	"blacksmith": Color(0.4, 0.4, 0.5),     # 진회색 = 대장장이
	"guard": Color(0.5, 0.5, 0.7),          # 청회색 = 경비
	"farmer": Color(0.6, 0.8, 0.2),         # 연두색 = 농부
	"dancer": Color(1.0, 0.5, 0.8),         # 분홍색 = 춤꾼
	"hunter": Color(0.4, 0.8, 0.4),         # 초록색 = 사냥꾼
	"artisan": Color(0.9, 0.7, 0.5),        # 주황 갈색 = 장인
	"sage": Color(0.7, 0.9, 1.0),           # 하늘색 = 현인
	"musician": Color(1.0, 0.7, 0.5),       # 황등 주황색 = 악사
	"healer": Color(0.2, 0.8, 0.4)          # 녹색 = 치유자
}

# 스포닝된 NPC들
var spawned_npcs: Dictionary = {}  # npc_id -> NPC Node

# 참조
var npc_system: NPCSystem = null
var spawn_points: Array = []
var player_ref: Node = null

# 설정
var npc_height: float = 1.8
var npc_scale: float = 0.5
var interaction_distance: float = 5.0
var animation_speed: float = 1.0

func _ready():
	set_process(true)
	
	# 게임 매니저에서 NPC 시스템 참조 받기
	# (게임 매니저에서 호출될 예정)
	
	print("🧑 NPC Spawner 준비 완료")

func _process(delta):
	# 스포닝된 모든 NPC 애니메이션 업데이트
	for npc_id in spawned_npcs.keys():
		var npc_node = spawned_npcs[npc_id]
		if is_instance_valid(npc_node):
			update_npc_animation(npc_node, delta)
		else:
			spawned_npcs.erase(npc_id)

# 📍 지역별 NPC 배치
func spawn_npcs_in_region(region_name: String) -> void:
	# 기존 NPC 제거
	clear_npcs()
	
	if not npc_system:
		print("❌ NPC System이 설정되지 않음")
		return
	
	# 지역의 스포닝 포인트 가져오기
	var spawn_points_nodes = get_tree().get_nodes_in_group("SpawnPoints")
	if spawn_points_nodes.is_empty():
		spawn_points_nodes = get_children()
	
	# 해당 지역의 NPC 가져오기
	var region_npcs = npc_system.get_region_npcs(region_name)
	
	print("🧑 지역 ", region_name, "에 ", region_npcs.size(), "명의 NPC 배치")
	
	var spawn_index = 0
	for npc_id in region_npcs.keys():
		if spawn_index >= spawn_points_nodes.size():
			print("⚠️ 스포닝 포인트 부족 (필요: ", region_npcs.size(), ", 있음: ", spawn_points_nodes.size(), ")")
			break
		
		var npc_data = region_npcs[npc_id]
		var spawn_point = spawn_points_nodes[spawn_index]
		
		# 약간 랜덤 오프셋으로 충돌 방지
		var random_offset = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
		var spawn_position = spawn_point.global_position + random_offset
		
		# NPC 3D 모델 생성
		var npc_node = create_npc_3d_model(npc_id, npc_data, spawn_position)
		spawned_npcs[npc_id] = npc_node
		
		spawn_index += 1

# 🎨 NPC 3D 모델 생성
func create_npc_3d_model(npc_id: String, npc_data: Dictionary, position: Vector3) -> Node3D:
	var npc_root = Node3D.new()
	npc_root.name = "NPC_" + npc_id
	npc_root.position = position
	
	# 신체 (캡슐 모양)
	var body = CSGCylinder3D.new()
	body.height = npc_height * 0.6
	body.radius = npc_scale * 0.3
	body.position.y = npc_height * 0.3
	body.material = StandardMaterial3D.new()
	
	var job = npc_data.get("job", "merchant")
	body.material.albedo_color = job_colors.get(job, Color.GRAY)
	
	# 머리 (박스 모양)
	var head = CSGBox3D.new()
	head.size = Vector3(npc_scale * 0.4, npc_scale * 0.4, npc_scale * 0.4)
	head.position.y = npc_height * 0.85
	head.material = StandardMaterial3D.new()
	head.material.albedo_color = Color(0.9, 0.7, 0.5)
	
	# 이름 라벨 (Label3D)
	var label = Label3D.new()
	label.text = npc_data.get("name", "Unknown")
	label.font_size = 24
	label.position.y = npc_height + 0.3
	
	# 데이터 저장
	var npc_info = Node.new()
	npc_info.name = "NPCInfo"
	npc_info.set_meta("npc_id", npc_id)
	npc_info.set_meta("npc_name", npc_data.get("name", "Unknown"))
	npc_info.set_meta("job", job)
	npc_info.set_meta("personality", npc_data.get("personality", "neutral"))
	npc_info.set_meta("idle_timer", 0.0)
	npc_info.set_meta("animation_state", "idle")  # idle, talk, walk
	npc_info.set_meta("animation_progress", 0.0)
	
	# 조합
	npc_root.add_child(body)
	npc_root.add_child(head)
	npc_root.add_child(label)
	npc_root.add_child(npc_info)
	
	# 월드에 추가
	add_child(npc_root)
	
	return npc_root

# 🎬 NPC 애니메이션 업데이트
func update_npc_animation(npc_node: Node3D, delta: float) -> void:
	var npc_info = npc_node.get_node_or_null("NPCInfo")
	if not npc_info:
		return
	
	var idle_timer = npc_info.get_meta("idle_timer", 0.0) + delta
	var animation_state = npc_info.get_meta("animation_state", "idle")
	var animation_progress = npc_info.get_meta("animation_progress", 0.0) + delta
	
	var head = npc_node.get_child(1)
	if head:
		match animation_state:
			"idle":
				# 좌우로 천천히 흔들기
				var sway = sin(animation_progress * 2.0) * 5.0  # 초당 2회전
				head.rotation.y = deg_to_rad(sway)
				
				# 5초마다 상태 변경
				if idle_timer > 5.0:
					animation_state = randi() % 2 == 0 ? "talk" : "idle"
					idle_timer = 0.0
			
			"talk":
				# 위아래 끄덕이기
				var nod = sin(animation_progress * 3.0) * 3.0
				head.position.y = npc_node.get_child(1).position.y + deg_to_rad(nod) * 0.1
				
				# 2초 후 아이들로 돌아가기
				if idle_timer > 2.0:
					animation_state = "idle"
					idle_timer = 0.0
	
	# 메타 데이터 업데이트
	npc_info.set_meta("idle_timer", idle_timer)
	npc_info.set_meta("animation_state", animation_state)
	npc_info.set_meta("animation_progress", animation_progress)

# 🗣️ NPC와 상호작용 가능 여부 확인
func is_npc_in_interaction_range(npc_node: Node3D) -> bool:
	if not player_ref:
		return false
	
	var distance = player_ref.global_position.distance_to(npc_node.global_position)
	return distance < interaction_distance

# 👤 NPC ID로 노드 찾기
func get_npc_node(npc_id: String) -> Node3D:
	return spawned_npcs.get(npc_id, null)

# 🗑️ 모든 NPC 제거
func clear_npcs() -> void:
	for npc_id in spawned_npcs.keys():
		var npc_node = spawned_npcs[npc_id]
		if is_instance_valid(npc_node):
			npc_node.queue_free()
	spawned_npcs.clear()

# 📋 스포닝된 NPC 개수 반환
func get_spawned_npc_count() -> int:
	return spawned_npcs.size()

# 📍 NPC 위치 설정
func set_npc_position(npc_id: String, position: Vector3) -> void:
	var npc_node = spawned_npcs.get(npc_id)
	if npc_node:
		npc_node.position = position

# 📍 NPC 위치 가져오기
func get_npc_position(npc_id: String) -> Vector3:
	var npc_node = spawned_npcs.get(npc_id)
	if npc_node:
		return npc_node.position
	return Vector3.ZERO

# 🔗 NPC 시스템 설정
func set_npc_system(system: NPCSystem) -> void:
	npc_system = system

# 🔗 플레이어 참조 설정
func set_player_ref(player: Node) -> void:
	player_ref = player

# 🎨 NPC 색상 커스터마이징
func set_npc_color(npc_id: String, color: Color) -> void:
	var npc_node = spawned_npcs.get(npc_id)
	if npc_node:
		var body = npc_node.get_child(0)
		if body and body.material:
			body.material.albedo_color = color

# 📊 현재 상태 출력
func print_status() -> void:
	print("\n🧑 NPC Spawner 상태:")
	print("  스포닝된 NPC: ", spawned_npcs.size())
	
	for npc_id in spawned_npcs.keys():
		var npc_node = spawned_npcs[npc_id]
		if is_instance_valid(npc_node):
			var npc_info = npc_node.get_node_or_null("NPCInfo")
			if npc_info:
				print("    - ", npc_info.get_meta("npc_name"), " (", npc_info.get_meta("job"), ")")

# ⚡ 모든 NPC에게 신호 보내기 (예: 지역 변경)
func notify_all_npcs(signal_type: String, data: Variant = null) -> void:
	for npc_id in spawned_npcs.keys():
		var npc_node = spawned_npcs[npc_id]
		if is_instance_valid(npc_node):
			match signal_type:
				"region_changed":
					# 지역이 변경되었을 때 애니메이션 초기화
					var npc_info = npc_node.get_node_or_null("NPCInfo")
					if npc_info:
						npc_info.set_meta("idle_timer", 0.0)
				"time_changed":
					# 시간이 변경되었을 때 처리
					pass
				_:
					print("❌ Unknown signal: ", signal_type)
