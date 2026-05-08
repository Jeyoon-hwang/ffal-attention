"""
NEXUS 무술 창조 게임 - 캐릭터 모델 시스템
=============================================

작성자: 천재 ⚡
작성일: 2026-05-08
목표: 캐릭터 기본 모델 + 6개 직업 비주얼 변형 시스템

주요 기능:
  - 기본 캐릭터 골격 정의 (head, torso, arms, legs)
  - 6개 직업별 의상 변형 생성
  - 8K 텍스처 매핑 준비
  - 애니메이션 리깅 자동화
  - 색상 팔레트 시스템 (캐릭터 커스터마이징)
"""

import json
from enum import Enum
from dataclasses import dataclass, asdict
from typing import Dict, List, Tuple, Optional
import math


# ============================================================================
# 1. 열거형 정의 (Enums)
# ============================================================================

class Profession(Enum):
    """6개 직업"""
    SWORDSMAN = "swordsman"      # 검사
    ARCHER = "archer"            # 궁수
    MAGE = "mage"                # 마도사
    ROGUE = "rogue"              # 도적
    PALADIN = "paladin"          # 기사
    BARD = "bard"                # 음유시인


class BodyPart(Enum):
    """신체 부위"""
    HEAD = "head"
    TORSO = "torso"
    ARMS = "arms"
    LEGS = "legs"
    HANDS = "hands"
    FEET = "feet"


class GenderType(Enum):
    """성별"""
    MALE = "male"
    FEMALE = "female"


# ============================================================================
# 2. 데이터 클래스 (Data Classes)
# ============================================================================

@dataclass
class Vector3D:
    """3D 벡터"""
    x: float
    y: float
    z: float

    def to_dict(self):
        return {"x": self.x, "y": self.y, "z": self.z}

    @staticmethod
    def from_dict(data):
        return Vector3D(**data)


@dataclass
class BoneData:
    """뼈(본) 데이터"""
    name: str
    position: Vector3D
    rotation: Vector3D
    scale: Vector3D
    parent: Optional[str] = None
    polygon_count: int = 0  # 폴리곤 수

    def to_dict(self):
        return {
            "name": self.name,
            "position": self.position.to_dict(),
            "rotation": self.rotation.to_dict(),
            "scale": self.scale.to_dict(),
            "parent": self.parent,
            "polygon_count": self.polygon_count
        }


@dataclass
class TextureData:
    """텍스처 정보"""
    name: str
    resolution: Tuple[int, int]  # (width, height)
    color_palette: Dict[str, str]  # {color_name: hex_value}
    normal_map: bool = True
    roughness_map: bool = True
    metallic_map: bool = False

    def to_dict(self):
        return {
            "name": self.name,
            "resolution": self.resolution,
            "color_palette": self.color_palette,
            "normal_map": self.normal_map,
            "roughness_map": self.roughness_map,
            "metallic_map": self.metallic_map
        }


@dataclass
class BodyPartDefinition:
    """신체 부위 정의"""
    part_name: str
    bones: List[BoneData]
    texture: TextureData
    polygon_count: int
    rigging_joints: List[str]  # 애니메이션용 조인트

    def to_dict(self):
        return {
            "part_name": self.part_name,
            "bones": [b.to_dict() for b in self.bones],
            "texture": self.texture.to_dict(),
            "polygon_count": self.polygon_count,
            "rigging_joints": self.rigging_joints
        }


@dataclass
class ProfessionCostume:
    """직업별 의상 정의"""
    profession: str
    outfit_name: str
    body_part_modifications: Dict[str, Dict]  # body_part -> {color, texture_variant, ...}
    armor_type: str
    accessories: List[str]
    total_polygon_count: int

    def to_dict(self):
        return {
            "profession": self.profession,
            "outfit_name": self.outfit_name,
            "body_part_modifications": self.body_part_modifications,
            "armor_type": self.armor_type,
            "accessories": self.accessories,
            "total_polygon_count": self.total_polygon_count
        }


@dataclass
class CharacterModel:
    """완전한 캐릭터 모델"""
    character_name: str
    profession: str
    gender: str
    base_skeleton: Dict[str, BoneData]
    body_parts: Dict[str, BodyPartDefinition]
    costume: ProfessionCostume
    color_scheme: Dict[str, str]  # primary, secondary, accent colors
    total_polygon_count: int
    animation_ready: bool = False

    def to_dict(self):
        return {
            "character_name": self.character_name,
            "profession": self.profession,
            "gender": self.gender,
            "base_skeleton": {k: v.to_dict() for k, v in self.base_skeleton.items()},
            "body_parts": {k: v.to_dict() for k, v in self.body_parts.items()},
            "costume": self.costume.to_dict(),
            "color_scheme": self.color_scheme,
            "total_polygon_count": self.total_polygon_count,
            "animation_ready": self.animation_ready
        }


# ============================================================================
# 3. 캐릭터 모델 빌더 (Builder)
# ============================================================================

class CharacterModelBuilder:
    """캐릭터 모델 생성 시스템"""

    def __init__(self):
        self.profession_specs = self._init_profession_specs()
        self.base_skeleton_template = self._create_base_skeleton()
        self.body_part_templates = self._create_body_part_templates()

    def _init_profession_specs(self) -> Dict:
        """6개 직업의 스펙 정의"""
        return {
            "swordsman": {
                "armor_type": "plate_armor",
                "primary_colors": ["#d4af37", "#2c3e50"],  # Gold, Dark Blue
                "accessories": ["sword_belt", "shoulder_guard"],
                "outfit_name": "검사의 갑옷"
            },
            "archer": {
                "armor_type": "leather_armor",
                "primary_colors": ["#8b7355", "#2ecc71"],  # Brown, Green
                "accessories": ["quiver", "arm_guard"],
                "outfit_name": "궁수의 가죽옷"
            },
            "mage": {
                "armor_type": "cloth_robe",
                "primary_colors": ["#5c0099", "#ff00ff"],  # Purple, Magenta
                "accessories": ["staff_holster", "spell_book"],
                "outfit_name": "마도사의 로브"
            },
            "rogue": {
                "armor_type": "shadow_leather",
                "primary_colors": ["#1a1a1a", "#ff4444"],  # Black, Red
                "accessories": ["hidden_blades", "shadow_cloak"],
                "outfit_name": "도적의 그림자 의상"
            },
            "paladin": {
                "armor_type": "holy_plate",
                "primary_colors": ["#ffff00", "#ffffff"],  # Gold, White
                "accessories": ["shield", "holy_symbol"],
                "outfit_name": "기사의 성스러운 갑옷"
            },
            "bard": {
                "armor_type": "elegant_cloth",
                "primary_colors": ["#ff69b4", "#ffd700"],  # Hot Pink, Gold
                "accessories": ["lute", "colorful_cloak"],
                "outfit_name": "음유시인의 화려한 옷"
            }
        }

    def _create_base_skeleton(self) -> Dict[str, BoneData]:
        """기본 골격 구조 생성 (100K 폴리곤 기준)"""
        skeleton = {
            # Head (20K 폴리곤)
            "head": BoneData(
                name="head",
                position=Vector3D(0, 1.8, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(1, 1, 1),
                parent=None,
                polygon_count=20000
            ),
            "jaw": BoneData(
                name="jaw",
                position=Vector3D(0, 1.6, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.8, 0.6, 1),
                parent="head",
                polygon_count=3000
            ),
            "eyes_left": BoneData(
                name="eyes_left",
                position=Vector3D(-0.3, 1.85, 0.3),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.3, 0.3, 0.3),
                parent="head",
                polygon_count=2000
            ),
            "eyes_right": BoneData(
                name="eyes_right",
                position=Vector3D(0.3, 1.85, 0.3),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.3, 0.3, 0.3),
                parent="head",
                polygon_count=2000
            ),
            
            # Torso (25K 폴리곤)
            "spine_base": BoneData(
                name="spine_base",
                position=Vector3D(0, 1, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(1, 1, 1),
                parent=None,
                polygon_count=8000
            ),
            "spine_mid": BoneData(
                name="spine_mid",
                position=Vector3D(0, 1.4, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(1, 1, 1),
                parent="spine_base",
                polygon_count=8000
            ),
            "chest": BoneData(
                name="chest",
                position=Vector3D(0, 1.6, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(1, 1, 1),
                parent="spine_mid",
                polygon_count=9000
            ),
            
            # Arms (25K 폴리곤)
            "shoulder_left": BoneData(
                name="shoulder_left",
                position=Vector3D(-0.5, 1.55, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.4, 0.4, 0.4),
                parent="chest",
                polygon_count=3000
            ),
            "upper_arm_left": BoneData(
                name="upper_arm_left",
                position=Vector3D(-0.8, 1.3, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.35, 0.35, 0.35),
                parent="shoulder_left",
                polygon_count=5000
            ),
            "forearm_left": BoneData(
                name="forearm_left",
                position=Vector3D(-0.9, 0.9, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.3, 0.3, 0.3),
                parent="upper_arm_left",
                polygon_count=4000
            ),
            "hand_left": BoneData(
                name="hand_left",
                position=Vector3D(-0.85, 0.5, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.25, 0.25, 0.25),
                parent="forearm_left",
                polygon_count=2000
            ),
            
            "shoulder_right": BoneData(
                name="shoulder_right",
                position=Vector3D(0.5, 1.55, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.4, 0.4, 0.4),
                parent="chest",
                polygon_count=3000
            ),
            "upper_arm_right": BoneData(
                name="upper_arm_right",
                position=Vector3D(0.8, 1.3, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.35, 0.35, 0.35),
                parent="shoulder_right",
                polygon_count=5000
            ),
            "forearm_right": BoneData(
                name="forearm_right",
                position=Vector3D(0.9, 0.9, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.3, 0.3, 0.3),
                parent="upper_arm_right",
                polygon_count=4000
            ),
            "hand_right": BoneData(
                name="hand_right",
                position=Vector3D(0.85, 0.5, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.25, 0.25, 0.25),
                parent="forearm_right",
                polygon_count=2000
            ),
            
            # Legs (30K 폴리곤)
            "hip_left": BoneData(
                name="hip_left",
                position=Vector3D(-0.3, 0.95, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.4, 0.4, 0.4),
                parent="spine_base",
                polygon_count=4000
            ),
            "thigh_left": BoneData(
                name="thigh_left",
                position=Vector3D(-0.3, 0.6, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.4, 0.4, 0.4),
                parent="hip_left",
                polygon_count=7000
            ),
            "calf_left": BoneData(
                name="calf_left",
                position=Vector3D(-0.3, 0.2, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.35, 0.35, 0.35),
                parent="thigh_left",
                polygon_count=5000
            ),
            "foot_left": BoneData(
                name="foot_left",
                position=Vector3D(-0.3, -0.15, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.35, 0.2, 0.4),
                parent="calf_left",
                polygon_count=3000
            ),
            
            "hip_right": BoneData(
                name="hip_right",
                position=Vector3D(0.3, 0.95, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.4, 0.4, 0.4),
                parent="spine_base",
                polygon_count=4000
            ),
            "thigh_right": BoneData(
                name="thigh_right",
                position=Vector3D(0.3, 0.6, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.4, 0.4, 0.4),
                parent="hip_right",
                polygon_count=7000
            ),
            "calf_right": BoneData(
                name="calf_right",
                position=Vector3D(0.3, 0.2, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.35, 0.35, 0.35),
                parent="thigh_right",
                polygon_count=5000
            ),
            "foot_right": BoneData(
                name="foot_right",
                position=Vector3D(0.3, -0.15, 0),
                rotation=Vector3D(0, 0, 0),
                scale=Vector3D(0.35, 0.2, 0.4),
                parent="calf_right",
                polygon_count=3000
            ),
        }
        return skeleton

    def _create_body_part_templates(self) -> Dict[str, BodyPartDefinition]:
        """신체 부위 템플릿 생성"""
        
        # 헤드
        head_bones = [
            BoneData("head", Vector3D(0, 1.8, 0), Vector3D(0, 0, 0), Vector3D(1, 1, 1), polygon_count=20000),
            BoneData("jaw", Vector3D(0, 1.6, 0), Vector3D(0, 0, 0), Vector3D(0.8, 0.6, 1), "head", polygon_count=3000),
            BoneData("eyes", Vector3D(0, 1.85, 0.3), Vector3D(0, 0, 0), Vector3D(0.6, 0.6, 0.6), "head", polygon_count=4000),
        ]
        head_texture = TextureData(
            name="head_texture",
            resolution=(8192, 8192),
            color_palette={"skin": "#fdbcb4", "hair": "#3d2817", "eyes": "#6b4423"},
            normal_map=True,
            roughness_map=True
        )
        head_def = BodyPartDefinition(
            part_name="head",
            bones=head_bones,
            texture=head_texture,
            polygon_count=27000,
            rigging_joints=["head", "jaw", "eyes_left", "eyes_right"]
        )
        
        # 토르소
        torso_bones = [
            BoneData("spine_base", Vector3D(0, 1, 0), Vector3D(0, 0, 0), Vector3D(1, 1, 1), polygon_count=8000),
            BoneData("spine_mid", Vector3D(0, 1.4, 0), Vector3D(0, 0, 0), Vector3D(1, 1, 1), "spine_base", polygon_count=8000),
            BoneData("chest", Vector3D(0, 1.6, 0), Vector3D(0, 0, 0), Vector3D(1, 1, 1), "spine_mid", polygon_count=9000),
        ]
        torso_texture = TextureData(
            name="torso_texture",
            resolution=(8192, 8192),
            color_palette={"skin": "#fdbcb4", "fabric": "#2c3e50"},
            normal_map=True,
            roughness_map=True
        )
        torso_def = BodyPartDefinition(
            part_name="torso",
            bones=torso_bones,
            texture=torso_texture,
            polygon_count=25000,
            rigging_joints=["spine_base", "spine_mid", "chest", "shoulder_left", "shoulder_right"]
        )
        
        # 팔 (양쪽)
        arms_bones = [
            BoneData("shoulder_left", Vector3D(-0.5, 1.55, 0), Vector3D(0, 0, 0), Vector3D(0.4, 0.4, 0.4), polygon_count=3000),
            BoneData("upper_arm_left", Vector3D(-0.8, 1.3, 0), Vector3D(0, 0, 0), Vector3D(0.35, 0.35, 0.35), "shoulder_left", polygon_count=5000),
            BoneData("forearm_left", Vector3D(-0.9, 0.9, 0), Vector3D(0, 0, 0), Vector3D(0.3, 0.3, 0.3), "upper_arm_left", polygon_count=4000),
            BoneData("hand_left", Vector3D(-0.85, 0.5, 0), Vector3D(0, 0, 0), Vector3D(0.25, 0.25, 0.25), "forearm_left", polygon_count=2000),
            BoneData("shoulder_right", Vector3D(0.5, 1.55, 0), Vector3D(0, 0, 0), Vector3D(0.4, 0.4, 0.4), polygon_count=3000),
            BoneData("upper_arm_right", Vector3D(0.8, 1.3, 0), Vector3D(0, 0, 0), Vector3D(0.35, 0.35, 0.35), "shoulder_right", polygon_count=5000),
            BoneData("forearm_right", Vector3D(0.9, 0.9, 0), Vector3D(0, 0, 0), Vector3D(0.3, 0.3, 0.3), "upper_arm_right", polygon_count=4000),
            BoneData("hand_right", Vector3D(0.85, 0.5, 0), Vector3D(0, 0, 0), Vector3D(0.25, 0.25, 0.25), "forearm_right", polygon_count=2000),
        ]
        arms_texture = TextureData(
            name="arms_texture",
            resolution=(8192, 8192),
            color_palette={"skin": "#fdbcb4", "fabric": "#2c3e50"},
            normal_map=True,
            roughness_map=True
        )
        arms_def = BodyPartDefinition(
            part_name="arms",
            bones=arms_bones,
            texture=arms_texture,
            polygon_count=28000,
            rigging_joints=["shoulder_left", "upper_arm_left", "forearm_left", "hand_left",
                          "shoulder_right", "upper_arm_right", "forearm_right", "hand_right"]
        )
        
        # 다리 (양쪽)
        legs_bones = [
            BoneData("hip_left", Vector3D(-0.3, 0.95, 0), Vector3D(0, 0, 0), Vector3D(0.4, 0.4, 0.4), polygon_count=4000),
            BoneData("thigh_left", Vector3D(-0.3, 0.6, 0), Vector3D(0, 0, 0), Vector3D(0.4, 0.4, 0.4), "hip_left", polygon_count=7000),
            BoneData("calf_left", Vector3D(-0.3, 0.2, 0), Vector3D(0, 0, 0), Vector3D(0.35, 0.35, 0.35), "thigh_left", polygon_count=5000),
            BoneData("foot_left", Vector3D(-0.3, -0.15, 0), Vector3D(0, 0, 0), Vector3D(0.35, 0.2, 0.4), "calf_left", polygon_count=3000),
            BoneData("hip_right", Vector3D(0.3, 0.95, 0), Vector3D(0, 0, 0), Vector3D(0.4, 0.4, 0.4), polygon_count=4000),
            BoneData("thigh_right", Vector3D(0.3, 0.6, 0), Vector3D(0, 0, 0), Vector3D(0.4, 0.4, 0.4), "hip_right", polygon_count=7000),
            BoneData("calf_right", Vector3D(0.3, 0.2, 0), Vector3D(0, 0, 0), Vector3D(0.35, 0.35, 0.35), "thigh_right", polygon_count=5000),
            BoneData("foot_right", Vector3D(0.3, -0.15, 0), Vector3D(0, 0, 0), Vector3D(0.35, 0.2, 0.4), "calf_right", polygon_count=3000),
        ]
        legs_texture = TextureData(
            name="legs_texture",
            resolution=(8192, 8192),
            color_palette={"skin": "#fdbcb4", "fabric": "#2c3e50", "boots": "#1a1a1a"},
            normal_map=True,
            roughness_map=True
        )
        legs_def = BodyPartDefinition(
            part_name="legs",
            bones=legs_bones,
            texture=legs_texture,
            polygon_count=38000,
            rigging_joints=["hip_left", "thigh_left", "calf_left", "foot_left",
                          "hip_right", "thigh_right", "calf_right", "foot_right"]
        )
        
        return {
            "head": head_def,
            "torso": torso_def,
            "arms": arms_def,
            "legs": legs_def
        }

    def build_character(self, profession: str, gender: str = "male", 
                       name: str = "Player", custom_colors: Optional[Dict[str, str]] = None) -> CharacterModel:
        """완전한 캐릭터 모델 생성"""
        
        if profession not in self.profession_specs:
            raise ValueError(f"Unknown profession: {profession}")
        
        prof_spec = self.profession_specs[profession]
        
        # 색상 스킴 설정
        colors = custom_colors or {
            "primary": prof_spec["primary_colors"][0],
            "secondary": prof_spec["primary_colors"][1],
            "accent": "#ffffff"
        }
        
        # 의상 생성
        costume = ProfessionCostume(
            profession=profession,
            outfit_name=prof_spec["outfit_name"],
            body_part_modifications={
                "head": {"gender": gender},
                "torso": {"color": colors["primary"], "armor": prof_spec["armor_type"]},
                "arms": {"color": colors["primary"]},
                "legs": {"color": colors["secondary"], "boots": "metal_boots"}
            },
            armor_type=prof_spec["armor_type"],
            accessories=prof_spec["accessories"],
            total_polygon_count=100000  # 기본 100K
        )
        
        # 캐릭터 모델 생성
        character = CharacterModel(
            character_name=name,
            profession=profession,
            gender=gender,
            base_skeleton=self.base_skeleton_template,
            body_parts=self.body_part_templates,
            costume=costume,
            color_scheme=colors,
            total_polygon_count=100000,
            animation_ready=False
        )
        
        return character

    def generate_profession_variants(self) -> Dict[str, CharacterModel]:
        """6개 직업별 캐릭터 모델 자동 생성"""
        characters = {}
        for profession in Profession:
            char = self.build_character(profession.value, name=f"{profession.value.upper()}")
            characters[profession.value] = char
        return characters

    def export_to_json(self, character: CharacterModel, filename: str) -> str:
        """캐릭터 모델을 JSON으로 내보내기"""
        data = character.to_dict()
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        return filename


# ============================================================================
# 4. 메인 실행 코드
# ============================================================================

def main():
    """캐릭터 모델 시스템 테스트"""
    
    print("=" * 70)
    print("🎨 NEXUS 캐릭터 모델 시스템 생성")
    print("=" * 70)
    
    builder = CharacterModelBuilder()
    
    # 1. 6개 직업별 캐릭터 생성
    print("\n📋 6개 직업 캐릭터 자동 생성 중...")
    characters = builder.generate_profession_variants()
    
    total_polys = 0
    for profession, char in characters.items():
        print(f"  ✅ {profession.upper()}: {char.total_polygon_count:,} 폴리곤")
        total_polys += char.total_polygon_count
    
    print(f"\n📊 전체 폴리곤: {total_polys:,}")
    print(f"📦 총 캐릭터 수: {len(characters)}")
    
    # 2. 커스텀 캐릭터 생성 (예시)
    print("\n🎨 커스텀 캐릭터 생성...")
    custom_mage = builder.build_character(
        profession="mage",
        gender="female",
        name="Arcane_Sorceress",
        custom_colors={"primary": "#4a0080", "secondary": "#ff33ff", "accent": "#ffff00"}
    )
    print(f"  ✅ {custom_mage.character_name} ({custom_mage.profession}): {custom_mage.total_polygon_count:,} 폴리곤")
    
    # 3. 데이터 구조 확인
    print("\n🔍 캐릭터 모델 구조:")
    print(f"  - 기본 골격: {len(custom_mage.base_skeleton)} 개 본")
    print(f"  - 신체 부위: {len(custom_mage.body_parts)} 개 부위")
    print(f"  - 의상 색상: {len(custom_mage.costume.body_part_modifications)} 개 변형")
    print(f"  - 악세서리: {len(custom_mage.costume.accessories)} 개")
    
    # 4. 리깅 정보
    print("\n🦴 리깅 정보 (애니메이션 조인트):")
    total_joints = sum(len(part.rigging_joints) for part in custom_mage.body_parts.values())
    print(f"  총 조인트: {total_joints} 개")
    for part_name, part in custom_mage.body_parts.items():
        print(f"    - {part_name}: {len(part.rigging_joints)} 개 조인트")
    
    # 5. 텍스처 정보
    print("\n🎨 텍스처 정보:")
    for part_name, part in custom_mage.body_parts.items():
        print(f"  - {part.part_name}: {part.texture.resolution[0]}x{part.texture.resolution[1]}")
    
    print("\n" + "=" * 70)
    print("✅ 캐릭터 모델 시스템 생성 완료!")
    print("=" * 70)
    
    return builder, characters


if __name__ == "__main__":
    builder, characters = main()
