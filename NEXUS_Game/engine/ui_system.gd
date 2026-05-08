"""
NEXUS 무술 창조 게임 - UI & 메뉴 시스템
=========================================

작성자: 천재 ⚡
작성일: 2026-05-08
목표: 완전한 UI 시스템 (HUD, 메뉴, 인벤토리, 캐릭터 시트)

주요 기능:
  - 게임 HUD (HP, MP, 스킬, 목표)
  - 메인 메뉴 (시작, 로드, 설정)
  - 인벤토리 (장비, 아이템, 정렬)
  - 캐릭터 시트 (스탯, 무술, 퀘스트)
  - 다이얼로그 시스템 (NPC 대화)
  - 설정 메뉴 (그래픽, 사운드, 게임플레이)
"""

extends CanvasLayer

class_name UISystem


# ============================================================================
# 1. UI 컴포넌트 클래스
# ============================================================================

class UIPanel:
    var name: String
    var position: Vector2
    var size: Vector2
    var is_visible: bool = false
    var elements: Dictionary = {}
    var background_color: Color = Color.BLACK
    var opacity: float = 0.8
    
    func _init(p_name: String, p_position: Vector2, p_size: Vector2):
        name = p_name
        position = p_position
        size = p_size


class UIButton:
    var name: String
    var label: String
    var position: Vector2
    var size: Vector2
    var callback: Callable
    var is_hovered: bool = false
    var is_pressed: bool = false
    var color_normal: Color = Color.WHITE
    var color_hover: Color = Color.YELLOW
    var color_pressed: Color = Color.ORANGE
    
    func _init(p_name: String, p_label: String, p_callback: Callable):
        name = p_name
        label = p_label
        callback = p_callback


class UIProgressBar:
    var name: String
    var position: Vector2
    var size: Vector2
    var current_value: float = 0.0
    var max_value: float = 100.0
    var color: Color = Color.GREEN
    var background_color: Color = Color.DARK_GRAY
    
    func _init(p_name: String, p_size: Vector2):
        name = p_name
        size = p_size
    
    func set_value(p_value: float):
        current_value = clamp(p_value, 0.0, max_value)


class UIText:
    var name: String
    var text: String = ""
    var position: Vector2
    var size: Vector2
    var color: Color = Color.WHITE
    var alignment: String = "left"  # left, center, right
    
    func _init(p_name: String, p_text: String = ""):
        name = p_name
        text = p_text


# ============================================================================
# 2. 메인 메뉴
# ============================================================================

var main_menu_data: Dictionary = {
    "title": "NEXUS 무술 창조",
    "subtitle": "마스터 각본가를 목표로",
    "background": "medieval_castle",
    
    "buttons": [
        {"label": "NEW GAME", "action": "start_new_game"},
        {"label": "LOAD GAME", "action": "load_game"},
        {"label": "CONTINUE", "action": "continue_game"},
        {"label": "SETTINGS", "action": "open_settings"},
        {"label": "CREDITS", "action": "show_credits"},
        {"label": "EXIT", "action": "quit_game"}
    ],
    
    "version": "1.0.0",
    "credits": "Developed by 천재 ⚡"
}


# ============================================================================
# 3. 게임 HUD (In-Game UI)
# ============================================================================

var hud_components: Dictionary = {
    # 플레이어 상태
    "player_hp": {
        "type": "health_bar",
        "position": Vector2(20, 20),
        "size": Vector2(250, 30),
        "label": "HP",
        "color": Color.RED,
        "background": Color.DARK_RED
    },
    "player_mp": {
        "type": "mana_bar",
        "position": Vector2(20, 55),
        "size": Vector2(250, 25),
        "label": "MP",
        "color": Color.BLUE,
        "background": Color.DARK_BLUE
    },
    "player_stamina": {
        "type": "stamina_bar",
        "position": Vector2(20, 85),
        "size": Vector2(250, 20),
        "label": "체력",
        "color": Color.YELLOW,
        "background": Color.DARK_GRAY
    },
    
    # 스킬 바
    "skill_bar": {
        "type": "skill_grid",
        "position": Vector2(20, screen_size.y - 120),
        "columns": 8,
        "rows": 1,
        "skill_slots": 8,
        "slot_size": Vector2(50, 50),
        "spacing": 10
    },
    
    # 미니맵
    "mini_map": {
        "type": "minimap",
        "position": Vector2(screen_size.x - 220, 20),
        "size": Vector2(200, 200),
        "zoom": 0.1,
        "show_enemies": True,
        "show_npcs": False
    },
    
    # 목표 추적
    "objective_tracker": {
        "type": "text_list",
        "position": Vector2(20, 150),
        "size": Vector2(250, 200),
        "max_items": 3,
        "title": "목표",
        "color": Color.WHITE
    },
    
    # 플레이어 정보
    "player_info": {
        "type": "info_display",
        "position": Vector2(20, 360),
        "content": {
            "level": "1",
            "experience": "0 / 1000",
            "profession": "검사",
            "location": "중원"
        }
    },
    
    # 진행 상황 (우상단)
    "quest_progress": {
        "type": "text_display",
        "position": Vector2(screen_size.x - 220, 220),
        "width": 200,
        "title": "진행 중인 퀘스트"
    },
    
    # 상태 이상 표시
    "buff_debuff_display": {
        "type": "icon_grid",
        "position": Vector2(screen_size.x - 500, 20),
        "icon_size": Vector2(40, 40),
        "spacing": 10,
        "max_icons": 8
    }
}


var screen_size: Vector2 = Vector2(1920, 1080)


# ============================================================================
# 4. 인벤토리 UI
# ============================================================================

var inventory_ui: Dictionary = {
    "panel_size": Vector2(800, 600),
    "panel_position": Vector2(560, 240),
    
    "tabs": [
        {
            "name": "equipment",
            "label": "장비",
            "slots": 16,
            "grid_size": Vector2(4, 4),
            "slot_size": Vector2(100, 100)
        },
        {
            "name": "items",
            "label": "아이템",
            "slots": 32,
            "grid_size": Vector2(8, 4),
            "slot_size": Vector2(70, 70)
        },
        {
            "name": "martial_arts",
            "label": "무술서",
            "slots": 24,
            "grid_size": Vector2(6, 4),
            "slot_size": Vector2(80, 80)
        },
        {
            "name": "quest_items",
            "label": "퀘스트",
            "slots": 12,
            "grid_size": Vector2(4, 3),
            "slot_size": Vector2(90, 90)
        }
    ],
    
    "filter": {
        "enabled": True,
        "categories": ["all", "weapon", "armor", "accessory", "consumable", "material"]
    },
    
    "sort_options": ["name", "rarity", "level_required", "date_acquired"]
}


# ============================================================================
# 5. 캐릭터 시트
# ============================================================================

var character_sheet: Dictionary = {
    "panel_size": Vector2(600, 800),
    "panel_position": Vector2(660, 140),
    
    "sections": [
        {
            "name": "stats",
            "title": "능력치",
            "stats": [
                {"name": "STR", "value": 0, "label": "근력"},
                {"name": "DEX", "value": 0, "label": "민첩"},
                {"name": "INT", "value": 0, "label": "지능"},
                {"name": "VIT", "value": 0, "label": "체력"},
                {"name": "WIS", "value": 0, "label": "지혜"},
                {"name": "CHA", "value": 0, "label": "매력"},
                {"name": "LCK", "value": 0, "label": "행운"},
                {"name": "RES", "value": 0, "label": "저항"}
            ]
        },
        {
            "name": "resistances",
            "title": "저항",
            "resistances": [
                {"element": "fire", "value": 0},
                {"element": "ice", "value": 0},
                {"element": "lightning", "value": 0},
                {"element": "poison", "value": 0},
                {"element": "dark", "value": 0},
                {"element": "holy", "value": 0}
            ]
        },
        {
            "name": "martial_arts",
            "title": "무술",
            "display_count": 5,
            "sort": "proficiency"
        },
        {
            "name": "quests",
            "title": "퀘스트",
            "filter": "active",
            "display_count": 3
        }
    ]
}


# ============================================================================
# 6. 다이얼로그 시스템
# ============================================================================

var dialogue_system: Dictionary = {
    "panel_size": Vector2(1000, 300),
    "panel_position": Vector2(460, 700),
    
    "speaker": {
        "portrait_size": Vector2(150, 150),
        "name_color": Color.YELLOW,
        "name_size": 24
    },
    
    "text": {
        "max_width": 800,
        "font_size": 20,
        "text_color": Color.WHITE,
        "speed": "fast"  # slow, normal, fast
    },
    
    "choices": {
        "max_displayed": 4,
        "button_width": 900,
        "button_height": 50,
        "spacing": 10,
        "hover_color": Color.YELLOW,
        "normal_color": Color.WHITE
    }
}


# ============================================================================
# 7. 설정 메뉴
# ============================================================================

var settings_menu: Dictionary = {
    "panel_size": Vector2(800, 700),
    "panel_position": Vector2(560, 190),
    
    "tabs": [
        {
            "name": "graphics",
            "label": "그래픽",
            "settings": [
                {
                    "key": "resolution",
                    "label": "해상도",
                    "type": "dropdown",
                    "options": ["1920x1080", "1680x1050", "1440x900", "1280x720"],
                    "current": "1920x1080"
                },
                {
                    "key": "quality",
                    "label": "그래픽 품질",
                    "type": "slider",
                    "min": 0,
                    "max": 3,
                    "options": ["Low", "Medium", "High", "Ultra"],
                    "current": 2
                },
                {
                    "key": "vsync",
                    "label": "수직동기",
                    "type": "toggle",
                    "current": True
                },
                {
                    "key": "bloom",
                    "label": "블룸 효과",
                    "type": "toggle",
                    "current": True
                },
                {
                    "key": "motion_blur",
                    "label": "모션 블러",
                    "type": "toggle",
                    "current": False
                }
            ]
        },
        {
            "name": "audio",
            "label": "사운드",
            "settings": [
                {
                    "key": "master_volume",
                    "label": "마스터 볼륨",
                    "type": "slider",
                    "min": 0,
                    "max": 100,
                    "current": 80
                },
                {
                    "key": "music_volume",
                    "label": "음악 볼륨",
                    "type": "slider",
                    "min": 0,
                    "max": 100,
                    "current": 70
                },
                {
                    "key": "sfx_volume",
                    "label": "효과음 볼륨",
                    "type": "slider",
                    "min": 0,
                    "max": 100,
                    "current": 80
                },
                {
                    "key": "voice_volume",
                    "label": "음성 볼륨",
                    "type": "slider",
                    "min": 0,
                    "max": 100,
                    "current": 75
                }
            ]
        },
        {
            "name": "gameplay",
            "label": "게임플레이",
            "settings": [
                {
                    "key": "difficulty",
                    "label": "난이도",
                    "type": "dropdown",
                    "options": ["Easy", "Normal", "Hard", "Nightmare"],
                    "current": "Normal"
                },
                {
                    "key": "camera_sensitivity",
                    "label": "카메라 민감도",
                    "type": "slider",
                    "min": 0,
                    "max": 100,
                    "current": 50
                },
                {
                    "key": "hud_opacity",
                    "label": "HUD 불투명도",
                    "type": "slider",
                    "min": 0,
                    "max": 100,
                    "current": 80
                },
                {
                    "key": "show_enemy_health",
                    "label": "적 체력 표시",
                    "type": "toggle",
                    "current": True
                }
            ]
        },
        {
            "name": "controls",
            "label": "조작",
            "settings": [
                {"key": "forward", "label": "전진", "type": "keybind", "key": "W"},
                {"key": "backward", "label": "후진", "type": "keybind", "key": "S"},
                {"key": "left", "label": "좌회전", "type": "keybind", "key": "A"},
                {"key": "right", "label": "우회전", "type": "keybind", "key": "D"},
                {"key": "jump", "label": "점프", "type": "keybind", "key": "SPACE"},
                {"key": "attack", "label": "공격", "type": "keybind", "key": "LEFT_MOUSE"},
                {"key": "defend", "label": "방어", "type": "keybind", "key": "RIGHT_MOUSE"},
                {"key": "skill1", "label": "스킬 1", "type": "keybind", "key": "Q"},
                {"key": "skill2", "label": "스킬 2", "type": "keybind", "key": "E"},
                {"key": "inventory", "label": "인벤토리", "type": "keybind", "key": "I"},
                {"key": "character_sheet", "label": "캐릭터 시트", "type": "keybind", "key": "C"},
                {"key": "quests", "label": "퀘스트", "type": "keybind", "key": "J"}
            ]
        }
    ]
}


# ============================================================================
# 8. 초기화 및 관리
# ============================================================================

var active_panels: Array = []
var current_main_menu: String = "main"


func _ready():
    """초기화"""
    print("🎨 UI 시스템 준비 완료")
    _setup_ui_panels()


func _setup_ui_panels():
    """UI 패널 설정"""
    print("\n📊 UI 패널 설정:")
    print(f"  - HUD 컴포넌트: {hud_components.size()}개")
    print(f"  - 인벤토리 탭: {inventory_ui['tabs'].size()}개")
    print(f"  - 캐릭터 시트 섹션: {character_sheet['sections'].size()}개")
    print(f"  - 설정 탭: {settings_menu['tabs'].size()}개")


# ============================================================================
# 9. UI 표시/숨김 함수
# ============================================================================

func show_panel(panel_name: String) -> void:
    """패널 표시"""
    if not active_panels.has(panel_name):
        active_panels.append(panel_name)


func hide_panel(panel_name: String) -> void:
    """패널 숨김"""
    if panel_name in active_panels:
        active_panels.erase(panel_name)


func toggle_panel(panel_name: String) -> void:
    """패널 토글"""
    if panel_name in active_panels:
        hide_panel(panel_name)
    else:
        show_panel(panel_name)


func toggle_inventory() -> void:
    """인벤토리 토글 (I 키)"""
    toggle_panel("inventory")


func toggle_character_sheet() -> void:
    """캐릭터 시트 토글 (C 키)"""
    toggle_panel("character_sheet")


func toggle_quests() -> void:
    """퀘스트 토글 (J 키)"""
    toggle_panel("quests")


func toggle_settings() -> void:
    """설정 메뉴 토글 (ESC 키)"""
    toggle_panel("settings")


# ============================================================================
# 10. HUD 업데이트
# ============================================================================

func update_health_bar(current: float, max_health: float) -> void:
    """체력바 업데이트"""
    if hud_components.has("player_hp"):
        var hp_data = hud_components["player_hp"]
        var percentage = (current / max_health) * 100.0
        # 실제 구현에서는 UI 노드 업데이트


func update_mana_bar(current: float, max_mana: float) -> void:
    """마나바 업데이트"""
    if hud_components.has("player_mp"):
        var mp_data = hud_components["player_mp"]
        var percentage = (current / max_mana) * 100.0


func update_skill_bar(skills: Array) -> void:
    """스킬 바 업데이트"""
    if hud_components.has("skill_bar"):
        var skill_data = hud_components["skill_bar"]
        # 스킬 슬롯 업데이트


func update_objective_tracker(objectives: Array) -> void:
    """목표 추적 업데이트"""
    if hud_components.has("objective_tracker"):
        var tracker_data = hud_components["objective_tracker"]
        # 목표 리스트 업데이트


# ============================================================================
# 11. 통계 및 출력
# ============================================================================

func print_ui_summary() -> void:
    """UI 시스템 요약 출력"""
    print("\n" + "=" * 70)
    print("🎨 NEXUS UI & 메뉴 시스템 요약")
    print("=" * 70)
    print(f"\n📊 HUD 컴포넌트: {hud_components.size()}개")
    print(f"📋 인벤토리 탭: {inventory_ui['tabs'].size()}개")
    print(f"👤 캐릭터 시트 섹션: {character_sheet['sections'].size()}개")
    print(f"⚙️ 설정 탭: {settings_menu['tabs'].size()}개")
    
    # HUD 컴포넌트 상세
    print("\n📊 HUD 컴포넌트:")
    for component_name in hud_components.keys():
        print(f"  - {component_name}")
    
    # 인벤토리 탭
    print("\n📋 인벤토리 탭:")
    for tab in inventory_ui["tabs"]:
        print(f"  - {tab['label']} ({tab['slots']} 슬롯)")
    
    # 캐릭터 시트
    print("\n👤 캐릭터 시트 섹션:")
    for section in character_sheet["sections"]:
        print(f"  - {section['title']}")
    
    # 설정
    print("\n⚙️ 설정 탭:")
    for tab in settings_menu["tabs"]:
        print(f"  - {tab['label']}")
    
    print("\n" + "=" * 70)


func get_all_ui_panels() -> Array:
    """모든 UI 패널 목록"""
    var panels = []
    panels.append_array(hud_components.keys())
    panels.append("inventory")
    panels.append("character_sheet")
    panels.append("quests")
    panels.append("settings")
    return panels
