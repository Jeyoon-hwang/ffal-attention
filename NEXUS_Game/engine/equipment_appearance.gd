"""
NEXUS 무술 창조 게임 - 장비 외형 시스템
======================================

작성자: 천재 ⚡
작성일: 2026-05-09 (Week 3 Day 1)
목표: 착용 장비에 따라 캐릭터 외형 동적 변경

주요 기능:
  - 장비 슬롯별 메시 교체
  - 색상 오버라이드 시스템
  - 파티클/광 효과 추가
  - 성능 최적화 (머티리얼 재사용)
"""

extends Node3D

class_name EquipmentAppearance


# ============================================================================
# 1. 상수 정의
# ============================================================================

const EQUIPMENT_SLOTS = [
    "head", "chest", "legs", "feet", "hands",
    "neck", "ring_left", "ring_right"
]

const BODY_PARTS = {
    "head": "Head",
    "chest": "Torso",
    "legs": "Legs",
    "feet": "Feet",
    "hands": "Hands",
    "neck": "Neck"
}

const MATERIAL_TYPES = {
    "metal": {"roughness": 0.4, "metallic": 1.0},
    "leather": {"roughness": 0.8, "metallic": 0.0},
    "cloth": {"roughness": 0.9, "metallic": 0.0},
    "silk": {"roughness": 0.6, "metallic": 0.2}
}


# ============================================================================
# 2. 데이터 클래스
# ============================================================================

class EquipmentItem:
    var item_id: String
    var item_name: String
    var equipment_slot: String
    var mesh_name: String
    var material_name: String
    var color_override: String
    var has_aura: bool
    var aura_color: String
    var particle_effect: String
    
    func _init(data: Dictionary):
        item_id = data.get("item_id", "")
        item_name = data.get("item_name", "")
        equipment_slot = data.get("equipment_slot", "")
        mesh_name = data.get("mesh_name", "")
        material_name = data.get("material_name", "")
        color_override = data.get("color_override", "")
        has_aura = data.get("has_aura", false)
        aura_color = data.get("aura_color", "")
        particle_effect = data.get("particle_effect", "")


class CharacterAppearance:
    var profession_id: String
    var gender: String
    var skin_tone: Color
    var hair_style: String
    var hair_color: Color
    var eye_color: Color
    var equipped_items: Dictionary  # slot -> EquipmentItem
    
    func _init(profession_id: String, gender: String):
        self.profession_id = profession_id
        self.gender = gender
        self.equipped_items = {}
        # 기본값
        skin_tone = Color.from_string("#D4A574", Color.WHITE)
        hair_style = "default"
        hair_color = Color.from_string("#8B4513", Color.WHITE)
        eye_color = Color.from_string("#8B4513", Color.WHITE)


# ============================================================================
# 3. 주요 클래스
# ============================================================================

class_name EquipmentAppearanceManager
extends Node3D


# 멤버 변수
var character_node: Node3D
var appearance: CharacterAppearance
var mesh_instances: Dictionary  # body_part -> MeshInstance3D
var material_cache: Dictionary  # material_name -> Material
var particle_effects: Dictionary  # slot -> GPUParticles3D


func _ready():
    """초기화"""
    mesh_instances = {}
    material_cache = {}
    particle_effects = {}
    
    print("[EquipmentAppearance] 초기화 완료")


# ============================================================================
# 4. 외형 설정 함수
# ============================================================================

func set_character_appearance(profession_id: String, gender: String):
    """캐릭터 기본 외형 설정"""
    appearance = CharacterAppearance.new(profession_id, gender)
    print("[EquipmentAppearance] 캐릭터 외형 설정: %s (%s)" % [profession_id, gender])


func set_skin_tone(tone: Color):
    """피부색 변경"""
    if appearance:
        appearance.skin_tone = tone
        _update_skin_materials()


func set_hair_style(style: String, color: Color):
    """머리 스타일 및 색상 변경"""
    if appearance:
        appearance.hair_style = style
        appearance.hair_color = color
        _update_hair_mesh()


func equip_item(equipment_data: Dictionary):
    """장비 장착 및 외형 적용"""
    var item = EquipmentItem.new(equipment_data)
    var slot = item.equipment_slot
    
    if slot not in EQUIPMENT_SLOTS:
        print("[ERROR] 알 수 없는 장비 슬롯: %s" % slot)
        return
    
    # 기존 장비 제거
    unequip_item(slot)
    
    # 새 장비 장착
    appearance.equipped_items[slot] = item
    
    # 외형 업데이트
    _apply_equipment_appearance(item)
    
    print("[EquipmentAppearance] 장비 장착: %s -> %s" % [slot, item.item_name])


func unequip_item(slot: String):
    """장비 해제 및 기본 모습 복원"""
    if slot in appearance.equipped_items:
        appearance.equipped_items.erase(slot)
        _restore_default_appearance(slot)
        print("[EquipmentAppearance] 장비 해제: %s" % slot)


# ============================================================================
# 5. 내부 업데이트 함수
# ============================================================================

func _apply_equipment_appearance(item: EquipmentItem):
    """장비 외형 적용"""
    
    # 1. 메시 교체
    _swap_mesh(item.equipment_slot, item.mesh_name)
    
    # 2. 색상 오버라이드
    if item.color_override:
        _apply_color_override(item.equipment_slot, item.color_override)
    
    # 3. 머티리얼 적용
    _apply_material(item.equipment_slot, item.material_name)
    
    # 4. 파티클 효과
    if item.has_aura:
        _add_aura_effect(item.equipment_slot, item.aura_color)
    
    if item.particle_effect:
        _add_particle_effect(item.equipment_slot, item.particle_effect)


func _swap_mesh(slot: String, mesh_name: String):
    """메시 교체"""
    if not mesh_name:
        return
    
    var body_part = _get_body_part_for_slot(slot)
    if body_part not in mesh_instances:
        print("[WARNING] 메시 인스턴스를 찾을 수 없음: %s" % body_part)
        return
    
    # 새 메시 로드 및 적용
    var new_mesh = load("res://assets/meshes/%s.tres" % mesh_name)
    if new_mesh:
        var mesh_instance = mesh_instances[body_part]
        mesh_instance.mesh = new_mesh
        print("[OK] 메시 교체: %s" % mesh_name)
    else:
        print("[WARNING] 메시를 로드할 수 없음: %s" % mesh_name)


func _apply_color_override(slot: String, color_hex: String):
    """색상 오버라이드 적용"""
    var color = Color.from_string(color_hex, Color.WHITE)
    var body_part = _get_body_part_for_slot(slot)
    
    if body_part in mesh_instances:
        var mesh_instance = mesh_instances[body_part]
        var material = mesh_instance.get_active_material(0)
        if material:
            material = material.duplicate()
            material.albedo_color = color
            mesh_instance.set_surface_override_material(0, material)


func _apply_material(slot: String, material_name: String):
    """머티리얼 적용"""
    var body_part = _get_body_part_for_slot(slot)
    if body_part not in mesh_instances:
        return
    
    var mesh_instance = mesh_instances[body_part]
    var material: StandardMaterial3D
    
    # 캐시에서 찾기
    if material_name in material_cache:
        material = material_cache[material_name].duplicate()
    else:
        # 새로 생성
        material = StandardMaterial3D.new()
        
        # 머티리얼 타입에 따라 설정
        if material_name in MATERIAL_TYPES:
            var props = MATERIAL_TYPES[material_name]
            material.roughness = props["roughness"]
            material.metallic = props["metallic"]
        
        material_cache[material_name] = material
    
    mesh_instance.set_surface_override_material(0, material)


func _add_aura_effect(slot: String, aura_color: String):
    """광 효과 추가"""
    var body_part = _get_body_part_for_slot(slot)
    if body_part not in mesh_instances:
        return
    
    var mesh_instance = mesh_instances[body_part]
    
    # OmniLight3D 생성
    var light = OmniLight3D.new()
    light.light_color = Color.from_string(aura_color, Color.WHITE)
    light.omni_range = 2.0
    light.omni_attenuation = 2.0
    light.light_energy = 0.8
    
    mesh_instance.add_child(light)
    print("[OK] 광 효과 추가: %s (색상: %s)" % [body_part, aura_color])


func _add_particle_effect(slot: String, effect_name: String):
    """파티클 효과 추가"""
    var body_part = _get_body_part_for_slot(slot)
    if body_part not in mesh_instances:
        return
    
    var mesh_instance = mesh_instances[body_part]
    
    # 파티클 이펙트 로드 및 추가
    var particles = load("res://assets/particles/%s.tscn" % effect_name)
    if particles:
        var particle_node = particles.instantiate()
        mesh_instance.add_child(particle_node)
        particle_effects[slot] = particle_node
        print("[OK] 파티클 효과 추가: %s" % effect_name)


func _restore_default_appearance(slot: String):
    """기본 외형 복원"""
    var body_part = _get_body_part_for_slot(slot)
    
    if body_part in mesh_instances:
        # 기본 메시로 복원
        var default_mesh = load("res://assets/meshes/default_%s.tres" % body_part)
        if default_mesh:
            mesh_instances[body_part].mesh = default_mesh
        
        # 광 효과 제거
        if slot in particle_effects:
            particle_effects[slot].queue_free()
            particle_effects.erase(slot)


func _update_skin_materials():
    """피부색 변경 반영"""
    if "Torso" in mesh_instances:
        _apply_color_override("chest", appearance.skin_tone.to_html())


func _update_hair_mesh():
    """머리 메시 업데이트"""
    if "Head" in mesh_instances:
        # 스타일에 따라 메시 변경
        var mesh_name = "hair_%s" % appearance.hair_style
        _swap_mesh("head", mesh_name)
        _apply_color_override("head", appearance.hair_color.to_html())


func _get_body_part_for_slot(slot: String) -> String:
    """슬롯에 해당하는 신체 부위 반환"""
    return BODY_PARTS.get(slot, "")


# ============================================================================
# 6. 디버그 함수
# ============================================================================

func debug_print_equipped_items():
    """장착된 장비 목록 출력"""
    print("\n=== 장착된 장비 ===")
    for slot in appearance.equipped_items.keys():
        var item = appearance.equipped_items[slot]
        print("  [%s] %s (%s)" % [slot, item.item_name, item.mesh_name])
    print("==================\n")


func debug_print_appearance():
    """외형 정보 출력"""
    print("\n=== 캐릭터 외형 ===")
    print("  직업: %s" % appearance.profession_id)
    print("  성별: %s" % appearance.gender)
    print("  피부색: %s" % appearance.skin_tone.to_html())
    print("  머리: %s (%s)" % [appearance.hair_style, appearance.hair_color.to_html()])
    print("==================\n")


# ============================================================================
# 7. 싱글톤 패턴
# ============================================================================

static var _instance: EquipmentAppearanceManager

static func get_instance() -> EquipmentAppearanceManager:
    if not _instance:
        _instance = EquipmentAppearanceManager.new()
    return _instance
