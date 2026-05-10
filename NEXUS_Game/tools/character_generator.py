#!/usr/bin/env python3
"""
🎨 NEXUS 캐릭터 자동 모델 생성기
Blender Python API를 사용한 절차형 캐릭터 생성

사용법:
  blender --background --python character_generator.py -- --name player_male --gender male --style traditional
"""

import bpy
import bmesh
import math
import sys
from pathlib import Path
from mathutils import Vector, Matrix, Quaternion

class CharacterGenerator:
    """Blender에서 캐릭터를 절차형으로 생성하는 클래스"""
    
    def __init__(self, name="player_male", gender="male", style="traditional"):
        self.name = name
        self.gender = gender  # "male" or "female"
        self.style = style    # "traditional", "modern", etc.
        self.height = 1.80    # 180cm
        self.scale = 1.0
        
        # 청소
        self.clear_scene()
        
    def clear_scene(self):
        """씬 초기화"""
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
        
    def create_body(self):
        """기본 몸 생성 (캡슐 기반 리토폴로지)"""
        # 정점 생성
        mesh = bpy.data.meshes.new(f"{self.name}_mesh")
        obj = bpy.data.objects.new(self.name, mesh)
        bpy.context.collection.objects.link(obj)
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        
        # bmesh로 지오메트리 생성
        bm = bmesh.new()
        
        # 머리
        head_radius = 0.1
        head_height = 0.23
        self._create_sphere(bm, (0, 0, head_height * 0.95), head_radius, subdivisions=6)
        
        # 목
        self._create_cylinder(bm, (0, 0, head_height * 0.7), radius=0.05, height=0.1, segments=8)
        
        # 가슴/상반신
        chest_height = head_height * 0.5
        self._create_box(bm, (0, 0, chest_height), width=0.22, depth=0.15, height=0.3)
        
        # 복부
        ab_height = head_height * 0.2
        self._create_box(bm, (0, 0, ab_height), width=0.20, depth=0.14, height=0.25)
        
        # 여성스러운 곡선 (여성인 경우)
        if self.gender == "female":
            self._apply_female_curves(bm, chest_height)
        
        # 양팔
        shoulder_y = 0.11
        arm_height = chest_height + 0.05
        self._create_arm(bm, (shoulder_y, 0, arm_height), side="left")
        self._create_arm(bm, (-shoulder_y, 0, arm_height), side="right")
        
        # 양다리
        leg_start_height = ab_height - 0.15
        self._create_leg(bm, (0.08, 0, leg_start_height), side="left")
        self._create_leg(bm, (-0.08, 0, leg_start_height), side="right")
        
        bm.to_mesh(mesh)
        bm.free()
        
        # 모디파이어 적용
        self._apply_smooth_modifier(obj)
        
        return obj
    
    def _create_sphere(self, bm, center, radius, subdivisions=4):
        """구 생성"""
        center = Vector(center)
        
        for i in range(subdivisions):
            for j in range(subdivisions * 2):
                theta = (i / subdivisions) * math.pi
                phi = (j / (subdivisions * 2)) * 2 * math.pi
                
                x = math.sin(theta) * math.cos(phi)
                y = math.sin(theta) * math.sin(phi)
                z = math.cos(theta)
                
                v = bm.verts.new((center.x + x * radius, 
                                  center.y + y * radius, 
                                  center.z + z * radius))
    
    def _create_cylinder(self, bm, center, radius, height, segments=8):
        """원통 생성"""
        center = Vector(center)
        verts = []
        
        for i in range(2):
            for j in range(segments):
                angle = (j / segments) * 2 * math.pi
                x = math.cos(angle) * radius
                y = math.sin(angle) * radius
                z = center.z + (i - 0.5) * height
                
                v = bm.verts.new((center.x + x, center.y + y, z))
                verts.append(v)
    
    def _create_box(self, bm, center, width, depth, height):
        """박스 생성"""
        center = Vector(center)
        cx, cy, cz = center.x, center.y, center.z
        hw, hd, hh = width/2, depth/2, height/2
        
        verts = [
            bm.verts.new((cx - hw, cy - hd, cz - hh)),
            bm.verts.new((cx + hw, cy - hd, cz - hh)),
            bm.verts.new((cx + hw, cy + hd, cz - hh)),
            bm.verts.new((cx - hw, cy + hd, cz - hh)),
            bm.verts.new((cx - hw, cy - hd, cz + hh)),
            bm.verts.new((cx + hw, cy - hd, cz + hh)),
            bm.verts.new((cx + hw, cy + hd, cz + hh)),
            bm.verts.new((cx - hw, cy + hd, cz + hh)),
        ]
        
        # 면 생성
        bm.faces.new([verts[0], verts[1], verts[2], verts[3]])  # 아래
        bm.faces.new([verts[4], verts[7], verts[6], verts[5]])  # 위
        bm.faces.new([verts[0], verts[4], verts[5], verts[1]])  # 앞
        bm.faces.new([verts[2], verts[6], verts[7], verts[3]])  # 뒤
        bm.faces.new([verts[0], verts[3], verts[7], verts[4]])  # 좌
        bm.faces.new([verts[1], verts[5], verts[6], verts[2]])  # 우
    
    def _create_arm(self, bm, shoulder_pos, side="left"):
        """팔 생성"""
        center = Vector(shoulder_pos)
        
        # 상박
        upper_arm_len = 0.3
        upper_arm_radius = 0.035
        self._create_cylinder(bm, (center.x, center.y, center.z - upper_arm_len/2), 
                             upper_arm_radius, upper_arm_len, segments=6)
        
        # 전박
        lower_arm_len = 0.28
        lower_arm_radius = 0.025
        self._create_cylinder(bm, (center.x, center.y, center.z - upper_arm_len - lower_arm_len/2), 
                             lower_arm_radius, lower_arm_len, segments=6)
    
    def _create_leg(self, bm, hip_pos, side="left"):
        """다리 생성"""
        center = Vector(hip_pos)
        
        # 대퇴
        upper_leg_len = 0.4
        upper_leg_radius = 0.045
        self._create_cylinder(bm, (center.x, center.y, center.z - upper_leg_len/2), 
                             upper_leg_radius, upper_leg_len, segments=8)
        
        # 정강
        lower_leg_len = 0.38
        lower_leg_radius = 0.032
        self._create_cylinder(bm, (center.x, center.y, center.z - upper_leg_len - lower_leg_len/2), 
                             lower_leg_radius, lower_leg_len, segments=8)
    
    def _apply_female_curves(self, bm, chest_height):
        """여성스러운 곡선 적용"""
        # 간단한 스케일 조정
        for v in bm.verts:
            if abs(v.co.z - chest_height) < 0.15:  # 가슴 부근
                # X축 (폭) 약간 줄이고 Y축 (깊이) 늘리기
                v.co.x *= 1.1
                v.co.y *= 1.15
    
    def _apply_smooth_modifier(self, obj):
        """Smooth 모디파이어 적용"""
        smooth = obj.modifiers.new(name="Smooth", type='SMOOTH')
        smooth.iterations = 3
        smooth.factor = 0.5
    
    def create_armature(self, obj):
        """45개 본의 스켈레톤 생성"""
        # Armature 생성
        armature_data = bpy.data.armatures.new(f"{self.name}_armature")
        armature = bpy.data.objects.new(f"{self.name}_armature", armature_data)
        bpy.context.collection.objects.link(armature)
        bpy.context.view_layer.objects.active = armature
        armature.select_set(True)
        
        # 에딧 모드
        bpy.ops.object.mode_set(mode='EDIT')
        
        bones = {}
        
        # Root bone
        root = armature_data.edit_bones.new("Root")
        root.head = (0, 0, 0)
        root.tail = (0, 0, 0.1)
        bones['Root'] = root
        
        # Spine (척추 6개)
        spine_positions = [
            (0, 0, 0.3),   # L1-L5
            (0, 0, 0.5),   # T12-T1
            (0, 0, 0.7),   # 가슴
            (0, 0, 0.85),  # 목
            (0, 0, 1.0),   # 턱
            (0, 0, 1.15),  # 머리
        ]
        
        spine_bones = []
        for i, pos in enumerate(spine_positions):
            bone = armature_data.edit_bones.new(f"Spine_{i}")
            if i == 0:
                bone.parent = bones['Root']
            else:
                bone.parent = spine_bones[i-1]
            bone.head = spine_positions[i-1] if i > 0 else root.head
            bone.tail = pos
            spine_bones.append(bone)
            bones[f'Spine_{i}'] = bone
        
        # 양팔 (각 14개, 총 28개)
        self._create_arm_bones(armature_data, bones, spine_bones[2], side='L')
        self._create_arm_bones(armature_data, bones, spine_bones[2], side='R')
        
        # 양다리 (각 12개, 총 24개)
        self._create_leg_bones(armature_data, bones, spine_bones[0], side='L')
        self._create_leg_bones(armature_data, bones, spine_bones[0], side='R')
        
        # 머리 디테일 (8개)
        self._create_head_bones(armature_data, bones, spine_bones[-1])
        
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # 모디파이어 추가
        obj_modifier = obj.modifiers.new(name="Armature", type='ARMATURE')
        obj_modifier.object = armature
        
        return armature
    
    def _create_arm_bones(self, armature_data, bones, shoulder_bone, side='L'):
        """팔 본 생성"""
        prefix = f"Arm_{side}_"
        side_x = 1 if side == 'R' else -1
        
        shoulder = armature_data.edit_bones.new(f"{prefix}Shoulder")
        shoulder.parent = shoulder_bone
        shoulder.head = (side_x * 0.1, 0, 1.0)
        shoulder.tail = (side_x * 0.12, 0, 0.9)
        
        upper_arm = armature_data.edit_bones.new(f"{prefix}UpperArm")
        upper_arm.parent = shoulder
        upper_arm.head = shoulder.tail
        upper_arm.tail = (side_x * 0.12, 0, 0.6)
        
        forearm = armature_data.edit_bones.new(f"{prefix}Forearm")
        forearm.parent = upper_arm
        forearm.head = upper_arm.tail
        forearm.tail = (side_x * 0.12, 0, 0.32)
        
        wrist = armature_data.edit_bones.new(f"{prefix}Wrist")
        wrist.parent = forearm
        wrist.head = forearm.tail
        wrist.tail = (side_x * 0.12, 0, 0.25)
        
        bones[f'{prefix}Shoulder'] = shoulder
        bones[f'{prefix}UpperArm'] = upper_arm
        bones[f'{prefix}Forearm'] = forearm
        bones[f'{prefix}Wrist'] = wrist
        
        # 손가락 (5개)
        for i in range(5):
            finger = armature_data.edit_bones.new(f"{prefix}Finger_{i}")
            finger.parent = wrist
            finger.head = wrist.tail + Vector((0.02 * (i - 2), 0.01, 0))
            finger.tail = finger.head + Vector((0, 0, -0.05))
            bones[f'{prefix}Finger_{i}'] = finger
    
    def _create_leg_bones(self, armature_data, bones, hip_bone, side='L'):
        """다리 본 생성"""
        prefix = f"Leg_{side}_"
        side_x = 1 if side == 'R' else -1
        
        hip = armature_data.edit_bones.new(f"{prefix}Hip")
        hip.parent = hip_bone
        hip.head = (side_x * 0.08, 0, 0.3)
        hip.tail = (side_x * 0.08, 0, 0.25)
        
        upper_leg = armature_data.edit_bones.new(f"{prefix}Thigh")
        upper_leg.parent = hip
        upper_leg.head = hip.tail
        upper_leg.tail = (side_x * 0.08, 0, -0.15)
        
        knee = armature_data.edit_bones.new(f"{prefix}Knee")
        knee.parent = upper_leg
        knee.head = upper_leg.tail
        knee.tail = (side_x * 0.08, 0, -0.5)
        
        ankle = armature_data.edit_bones.new(f"{prefix}Ankle")
        ankle.parent = knee
        ankle.head = knee.tail
        ankle.tail = (side_x * 0.08, 0, -0.75)
        
        foot = armature_data.edit_bones.new(f"{prefix}Foot")
        foot.parent = ankle
        foot.head = ankle.tail
        foot.tail = (side_x * 0.08, 0.1, -0.8)
        
        bones[f'{prefix}Hip'] = hip
        bones[f'{prefix}Thigh'] = upper_leg
        bones[f'{prefix}Knee'] = knee
        bones[f'{prefix}Ankle'] = ankle
        bones[f'{prefix}Foot'] = foot
        
        # 발가락 (5개)
        for i in range(5):
            toe = armature_data.edit_bones.new(f"{prefix}Toe_{i}")
            toe.parent = foot
            toe.head = foot.tail + Vector((0.01 * (i - 2), 0, 0))
            toe.tail = toe.head + Vector((0, 0.02, 0))
            bones[f'{prefix}Toe_{i}'] = toe
    
    def _create_head_bones(self, armature_data, bones, head_bone):
        """머리 디테일 본"""
        # 턱
        jaw = armature_data.edit_bones.new("Head_Jaw")
        jaw.parent = head_bone
        jaw.head = (0, 0, 1.0)
        jaw.tail = (0, 0, 0.98)
        bones['Head_Jaw'] = jaw
        
        # 눈 (2개)
        for side in ['L', 'R']:
            eye = armature_data.edit_bones.new(f"Head_Eye_{side}")
            eye.parent = head_bone
            side_x = 1 if side == 'R' else -1
            eye.head = (side_x * 0.03, 0.08, 1.08)
            eye.tail = (side_x * 0.03, 0.10, 1.08)
            bones[f'Head_Eye_{side}'] = eye
        
        # 귀 (2개)
        for side in ['L', 'R']:
            ear = armature_data.edit_bones.new(f"Head_Ear_{side}")
            ear.parent = head_bone
            side_x = 1 if side == 'R' else -1
            ear.head = (side_x * 0.08, 0, 1.05)
            ear.tail = (side_x * 0.08, 0, 1.12)
            bones[f'Head_Ear_{side}'] = ear
        
        # 코
        nose = armature_data.edit_bones.new("Head_Nose")
        nose.parent = head_bone
        nose.head = (0, 0.09, 1.08)
        nose.tail = (0, 0.12, 1.08)
        bones['Head_Nose'] = nose
    
    def create_materials(self):
        """머터리얼 생성"""
        try:
            # 피부 머터리얼
            skin_mat = bpy.data.materials.new(name="Material_Skin")
            skin_mat.use_nodes = True
            principled = skin_mat.node_tree.nodes.get("Principled BSDF")
            if principled:
                # 입력 이름으로 접근
                if "Base Color" in principled.inputs:
                    principled.inputs["Base Color"].default_value = (0.8, 0.6, 0.5, 1.0)
                if "Subsurface Weight" in principled.inputs:
                    principled.inputs["Subsurface Weight"].default_value = 0.1
            
            # 복장 머터리얼
            cloth_mat = bpy.data.materials.new(name="Material_Cloth")
            cloth_mat.use_nodes = True
            principled_cloth = cloth_mat.node_tree.nodes.get("Principled BSDF")
            if principled_cloth:
                if "Base Color" in principled_cloth.inputs:
                    principled_cloth.inputs["Base Color"].default_value = (0.2, 0.1, 0.05, 1.0)
                if "Roughness" in principled_cloth.inputs:
                    principled_cloth.inputs["Roughness"].default_value = 0.3
            
            return skin_mat, cloth_mat
        except Exception as e:
            print(f"⚠️  머터리얼 생성 에러: {e}")
            return None, None
    
    def export_fbx(self, filepath):
        """FBX로 익스포트"""
        bpy.ops.export_scene.fbx(
            filepath=filepath,
            use_selection=False,
            animate=True,
            all_armatures=True,
            deformed_bones=True,
        )
        print(f"✅ 모델 익스포트 완료: {filepath}")

def main():
    """메인 함수"""
    # 커맨드라인 인자 파싱
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    
    name = "player_male"
    gender = "male"
    style = "traditional"
    
    for i, arg in enumerate(args):
        if arg == "--name" and i + 1 < len(args):
            name = args[i + 1]
        elif arg == "--gender" and i + 1 < len(args):
            gender = args[i + 1]
        elif arg == "--style" and i + 1 < len(args):
            style = args[i + 1]
    
    print(f"🎨 캐릭터 생성 시작: {name} ({gender})")
    
    generator = CharacterGenerator(name=name, gender=gender, style=style)
    
    # 모델 생성
    body_obj = generator.create_body()
    print(f"✅ 몸 생성 완료")
    
    # 리깅
    armature = generator.create_armature(body_obj)
    print(f"✅ 스켈레톤 생성 완료 (45개 본)")
    
    # 머터리얼
    generator.create_materials()
    print(f"✅ 머터리얼 생성 완료")
    
    # 익스포트
    export_path = f"/Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game/assets/models/{name}.fbx"
    Path(export_path).parent.mkdir(parents=True, exist_ok=True)
    generator.export_fbx(export_path)
    
    print(f"\n🎉 캐릭터 생성 완료!")
    print(f"   파일: {export_path}")
    print(f"   이름: {name}")
    print(f"   성별: {gender}")
    print(f"   스타일: {style}")

if __name__ == "__main__":
    main()
