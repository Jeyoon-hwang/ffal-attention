## Merchant.gd - 상인 NPC
##
## 중원의 여행 상인
## 포션, 아이템 판매

extends NPC

class_name Merchant

# 상인 정보
var merchant_name: String = "장상인"
var specialty: String = "포션 & 회복제"

# 판매 인벤토리
var inventory: Array[Dictionary] = []
var total_sales: int = 0

func _init() -> void:
	"""상인 NPC 초기화"""
	super._init("장상인", "merchant")
	
	npc_id = "merchant_chuongyeon"
	description = "여행하는 상인. 유용한 물건들을 판매합니다."
	world_position = Vector3(150, 0, 200)
	affinity = 0
	
	dialogue = [
		"반갑습니다!",
		"좋은 물건들을 많이 가지고 있습니다.",
		"뭔가 필요하신 것이 있으시면 말씀해주세요."
	]
	
	interaction_options = [
		"아이템 구매",
		"판매 물품 보기",
		"작별"
	]
	
	setup_inventory()

## 인벤토리 설정
func setup_inventory() -> void:
	"""상인의 판매 물품을 설정합니다."""
	
	inventory = [
		{
			"name": "체력포션",
			"description": "피를 30 회복합니다.",
			"cost": 20,
			"quantity": 10,
			"type": "healing"
		},
		{
			"name": "에너지포션",
			"description": "에너지를 30 회복합니다.",
			"cost": 15,
			"quantity": 15,
			"type": "energy"
		},
		{
			"name": "부스트포션",
			"description": "능력치를 1분간 1.5배 증가시킵니다.",
			"cost": 50,
			"quantity": 5,
			"type": "buff"
		},
		{
			"name": "해독제",
			"description": "독 상태를 해제합니다.",
			"cost": 10,
			"quantity": 20,
			"type": "cure"
		},
		{
			"name": "부활의_주문서",
			"description": "전투 중 사망 시 1회 부활합니다.",
			"cost": 100,
			"quantity": 2,
			"type": "special"
		}
	]

## 상인과 상호작용
func interact(player: Node) -> void:
	"""플레이어와 상호작용합니다."""
	print("\n[%s]" % npc_name)
	speak_dialogue()
	
	if interaction_options.size() > 0:
		print("\n  선택지:")
		for i in range(interaction_options.size()):
			print("    %d. %s" % [i + 1, interaction_options[i]])

## 옵션 처리
func handle_option(option_index: int, player: Node) -> void:
	"""옵션을 처리합니다."""
	
	match option_index:
		0:  # 아이템 구매
			show_inventory_for_purchase(player)
		
		1:  # 판매 물품 보기
			show_inventory()
		
		2:  # 작별
			say_goodbye()

## 인벤토리 표시 (구매용)
func show_inventory_for_purchase(player: Node) -> void:
	"""구매 가능한 아이템을 표시합니다."""
	
	print("\n[상인: 무엇을 사시겠습니까?]")
	print("\n[구매 가능 물품]")
	
	for i in range(inventory.size()):
		var item = inventory[i]
		var status = "✓" if item["cost"] <= player.gold else "✗"
		
		print("\n  %s %d. %s (재고: %d)" % [
			status,
			i + 1,
			item["name"],
			item["quantity"]
		])
		print("     가격: %d원" % item["cost"])
		print("     설명: %s" % item["description"])

## 인벤토리 표시 (일반)
func show_inventory() -> void:
	"""상인의 전체 인벤토리를 표시합니다."""
	
	print("\n[%s의 판매 물품]" % merchant_name)
	print("="*50)
	
	var total_value = 0
	
	for item in inventory:
		print("\n• %s" % item["name"])
		print("  가격: %d원 | 재고: %d개" % [item["cost"], item["quantity"]])
		print("  설명: %s" % item["description"])
		
		total_value += item["cost"] * item["quantity"]
	
	print("\n" + "="*50)
	print("총 재고 가치: %d원" % total_value)

## 아이템 판매
func sell_item(player: Node, item_name: String, quantity: int = 1) -> bool:
	"""플레이어에게 아이템을 판매합니다."""
	
	for item in inventory:
		if item["name"] == item_name:
			var total_cost = item["cost"] * quantity
			
			# 골드 확인
			if player.gold < total_cost:
				print("\n상인: '골드가 부족하신데요? (%d원 필요, %d원 보유)'" % [total_cost, player.gold])
				return false
			
			# 재고 확인
			if item["quantity"] < quantity:
				print("\n상인: '죄송하지만 재고가 부족합니다. (필요: %d개, 재고: %d개)'" % [quantity, item["quantity"]])
				return false
			
			# 판매 실행
			player.gold -= total_cost
			item["quantity"] -= quantity
			total_sales += total_cost
			
			change_affinity(5)  # 거래로 호감도 상승
			
			print("\n✅ [아이템 구매 완료]")
			print("  아이템: %s x %d" % [item_name, quantity])
			print("  비용: %d원 (남은 골드: %d원)" % [total_cost, player.gold])
			
			return true
	
	print("\n상인: '그런 물건은 없는데요...'")
	return false

## 작별 인사
func say_goodbye() -> void:
	"""작별 인사합니다."""
	print("\n상인: '또 봬요, 손님!'")

## 상인 정보 출력
func print_merchant_info() -> void:
	"""상인 정보를 출력합니다."""
	
	print("\n" + "="*50)
	print("🛍️  %s" % npc_name)
	print("="*50)
	print("전문: %s" % specialty)
	print("위치: (%.1f, %.1f, %.1f)" % [world_position.x, world_position.y, world_position.z])
	print("총 판매액: %d원" % total_sales)
	print("호감도: %d/100" % affinity)
	
	print("\n[판매 물품]")
	for item in inventory:
		print("  • %s: %d원 (재고: %d)" % [item["name"], item["cost"], item["quantity"]])

## 통계
func get_statistics() -> Dictionary:
	"""상인 통계를 반환합니다."""
	
	return {
		"name": npc_name,
		"specialty": specialty,
		"inventory_count": inventory.size(),
		"total_inventory_value": inventory.reduce(
			func(sum, item): return sum + (item["cost"] * item["quantity"]),
			0
		),
		"total_sales": total_sales,
		"affinity": affinity
	}
