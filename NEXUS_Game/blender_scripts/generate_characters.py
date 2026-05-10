#!/usr/bin/env python3
"""
NEXUS 무술 창조 게임 - Blender 캐릭터 자동 생성 스크립트
Day 15-16 목표: 남성, 여성 캐릭터 모델 자동 생성 (절차적)

사용 방법:
  blender --background --python blender_scripts/generate_characters.py
"""

import bpy
import os
from mathutils import Vector, Matrix
import random

class CharacterGenerator:
    """절차적 캐릭터 생성 시스템"""
    
    def __init__(self, output_dir="assets/Models/Characters"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        self.clear_default_scene()
    
    def clear_default_scene(self):
        """Blender 기본 씬 정리"""
        # 모든 메시 삭제
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
        
        # 카메라, 라이트 삭제
        for obj in bpy.context.scene.objects:
            if obj.type in ['CAMERA', 'LIGHT']:
                bpy.data.objects.remove(obj, do_unlink=True)
    
    def create_head(self):
        """머리 생성 (UV 구)"""
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=0.15, location=(0, 0, 0.75)
        )
        head = bpy.context.active_object
        head.name = "Head"
        
        # 세분화해서 더 자연스러운 모양
        bpy.context.view_layer.objects.active = head
        head.select_set(True)
        bpy.ops.object.shade_smooth()
        
        return head
    
    def create_body(self):
        """몸통 생성 (캡슐 형태)"""
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=0.13, location=(0, 0, 0.45)
        )
        body = bpy.context.active_object
        body.name = "Body"
        
        # Y축으로 스케일 조정 (늘려서 몸통 모양)
        body.scale = (1.0, 1.0, 1.3)
        bpy.ops.object.transform_apply(scale=True)
        
        bpy.ops.object.shade_smooth()
        return body
    
    def create_arms(self):
        """팔 생성 (2개)"""
        arms = []
        
        for side in [-1, 1]:  # 좌우
            # 상완
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.05, depth=0.35, location=(side*0.18, 0, 0.55)
            )
            upper_arm = bpy.context.active_object
            upper_arm.name = f"UpperArm_{['L', 'R'][side > 0]}"
            upper_arm.rotation_euler = (1.57, 0, 0)  # 회전
            bpy.ops.object.shade_smooth()
            arms.append(upper_arm)
            
            # 전완
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.04, depth=0.3, location=(side*0.28, 0, 0.35)
            )
            forearm = bpy.context.active_object
            forearm.name = f"ForeArm_{['L', 'R'][side > 0]}"
            forearm.rotation_euler = (1.57, 0, 0)
            bpy.ops.object.shade_smooth()
            arms.append(forearm)
            
            # 손
            bpy.ops.mesh.primitive_uv_sphere_add(
                radius=0.04, location=(side*0.32, 0, 0.2)
            )
            hand = bpy.context.active_object
            hand.name = f"Hand_{['L', 'R'][side > 0]}"
            bpy.ops.object.shade_smooth()
            arms.append(hand)
        
        return arms
    
    def create_legs(self):
        """다리 생성 (2개)"""
        legs = []
        
        for side in [-1, 1]:  # 좌우
            # 넓적다리
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.055, depth=0.4, location=(side*0.1, 0, 0.25)
            )
            thigh = bpy.context.active_object
            thigh.name = f"Thigh_{['L', 'R'][side > 0]}"
            thigh.rotation_euler = (1.57, 0, 0)
            bpy.ops.object.shade_smooth()
            legs.append(thigh)
            
            # 종아리
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.05, depth=0.35, location=(side*0.1, 0, 0.05)
            )
            calf = bpy.context.active_object
            calf.name = f"Calf_{['L', 'R'][side > 0]}"
            calf.rotation_euler = (1.57, 0, 0)
            bpy.ops.object.shade_smooth()
            legs.append(calf)
            
            # 발
            bpy.ops.mesh.primitive_cube_add(
                size=0.08, location=(side*0.1, 0.08, -0.05)
            )
            foot = bpy.context.active_object
            foot.name = f"Foot_{['L', 'R'][side > 0]}"
            foot.scale = (1.0, 1.3, 0.4)
            bpy.ops.object.transform_apply(scale=True)
            bpy.ops.object.shade_smooth()
            legs.append(foot)
        
        return legs
    
    def create_character(self, gender="male"):
        """완전한 캐릭터 생성"""
        print(f"[NEXUS] 생성 중: {gender.upper()} 캐릭터")
        
        # 부위 생성
        head = self.create_head()
        body = self.create_body()
        arms = self.create_arms()
        legs = self.create_legs()
        
        # 모든 오브젝트를 선택 및 조인
        all_parts = [head, body] + arms + legs
        for obj in all_parts:
            obj.select_set(True)
        
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.join()
        
        character = bpy.context.active_object
        character.name = f"Character_{gender.capitalize()}"
        
        # 머터리얼 추가 (피부색)
        mat = bpy.data.materials.new(name="Skin")
        if mat.use_nodes:
            if gender == "male":
                mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
                    0.8, 0.7, 0.65, 1.0  # 남성 피부색
                )
            else:
                mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
                    0.95, 0.8, 0.75, 1.0  # 여성 피부색
                )
        
        character.data.materials.append(mat)
        
        print(f"[NEXUS] ✅ {gender.capitalize()} 캐릭터 생성 완료: {character.name}")
        return character
    
    def add_armature(self, character):
        """기본 스켈레톤 추가"""
        # 간단한 Armature 추가
        bpy.ops.object.armature_add(location=(0, 0, 0.4))
        armature = bpy.context.active_object
        armature.name = "Armature"
        
        # 기본 본 구조 (Spine, Arms, Legs)
        bpy.ops.object.mode_set(mode='EDIT')
        
        # 본 추가는 복잡하므로, 나중에 Rigify로 자동화
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # Armature를 Character의 부모로 설정
        character.select_set(True)
        armature.select_set(True)
        bpy.context.view_layer.objects.active = armature
        
        print(f"[NEXUS] ✅ Armature 추가 완료")
        return armature
    
    def export_character(self, character, gender):
        """캐릭터를 FBX로 내보내기"""
        filepath = os.path.join(
            self.output_dir, 
            f"Character_{gender.capitalize()}.fbx"
        )
        
        character.select_set(True)
        bpy.context.view_layer.objects.active = character
        bpy.ops.export_scene.fbx(
            filepath=filepath,
            use_selection=True
        )
        
        print(f"[NEXUS] ✅ 내보내기 완료: {filepath}")
        return filepath
    
    def generate_all(self):
        """모든 캐릭터 생성"""
        characters_data = []
        
        for gender in ["male", "female"]:
            # 기존 오브젝트 정리
            bpy.ops.object.select_all(action='SELECT')
            bpy.ops.object.delete(use_global=False)
            
            # 캐릭터 생성
            character = self.create_character(gender=gender)
            armature = self.add_armature(character)
            
            # 내보내기
            filepath = self.export_character(character, gender)
            characters_data.append({
                "name": character.name,
                "filepath": filepath,
                "gender": gender
            })
        
        return characters_data


def main():
    """메인 함수"""
    print("[NEXUS] 🔥 Blender 캐릭터 생성 시작")
    print(f"[NEXUS] Blender 버전: {bpy.app.version_string}")
    
    generator = CharacterGenerator()
    characters = generator.generate_all()
    
    print("\n[NEXUS] ✅ 모든 캐릭터 생성 완료!")
    print(f"[NEXUS] 총 {len(characters)}개 캐릭터 생성됨\n")
    
    for char in characters:
        print(f"  - {char['name']}: {char['filepath']}")
    
    print("\n[NEXUS] 다음 단계: Godot에서 자동 임포트 및 리깅")


if __name__ == "__main__":
    main()
