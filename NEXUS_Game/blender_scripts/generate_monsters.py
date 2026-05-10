#!/usr/bin/env python3
"""
NEXUS 무술 창조 게임 - Blender 몬스터 자동 생성 스크립트
Day 17-18 목표: 10종 몬스터 모델 자동 생성 (절차적)

사용 방법:
  blender --background --python blender_scripts/generate_monsters.py
"""

import bpy
import os
from mathutils import Vector
import random

class MonsterGenerator:
    """절차적 몬스터 생성 시스템"""
    
    def __init__(self, output_dir="assets/Models/Monsters"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        self.clear_default_scene()
        
        self.monsters_spec = {
            "Wolf": {"color": (0.6, 0.5, 0.4), "scale": 1.2, "legs": 4},
            "Bat": {"color": (0.3, 0.3, 0.4), "scale": 0.8, "wings": True},
            "Skeleton": {"color": (0.7, 0.7, 0.7), "scale": 1.8, "bones": True},
            "Bear": {"color": (0.4, 0.3, 0.2), "scale": 1.5, "legs": 4},
            "Giant": {"color": (0.5, 0.4, 0.3), "scale": 2.5, "legs": 2},
            "Spider": {"color": (0.2, 0.2, 0.2), "scale": 0.9, "legs": 8},
            "Demon": {"color": (0.8, 0.2, 0.2), "scale": 1.6, "wings": True},
            "Golem": {"color": (0.4, 0.4, 0.4), "scale": 2.0, "legs": 2},
            "Zombie": {"color": (0.3, 0.5, 0.3), "scale": 1.3, "legs": 2},
            "Dragon": {"color": (0.8, 0.6, 0.2), "scale": 3.0, "wings": True},
        }
    
    def clear_default_scene(self):
        """씬 정리"""
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
    
    def create_body(self, scale=1.0, shape="sphere"):
        """몸통 생성"""
        if shape == "sphere":
            bpy.ops.mesh.primitive_uv_sphere_add(
                radius=0.2 * scale, location=(0, 0, 0)
            )
        elif shape == "cube":
            bpy.ops.mesh.primitive_cube_add(
                size=0.4 * scale, location=(0, 0, 0)
            )
        elif shape == "cylinder":
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.15 * scale, depth=0.4 * scale, location=(0, 0, 0)
            )
        
        body = bpy.context.active_object
        body.name = "Body"
        bpy.ops.object.shade_smooth()
        return body
    
    def create_head(self, scale=1.0):
        """머리 생성"""
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=0.12 * scale, location=(0, 0, 0.25 * scale)
        )
        head = bpy.context.active_object
        head.name = "Head"
        bpy.ops.object.shade_smooth()
        return head
    
    def create_legs(self, count=4, scale=1.0):
        """다리 생성"""
        legs = []
        
        for i in range(count):
            angle = (i / count) * 6.28  # 2π
            x = (0.1 * scale) * __import__('math').cos(angle)
            y = (0.1 * scale) * __import__('math').sin(angle)
            
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.04 * scale, depth=0.25 * scale,
                location=(x, y, -0.2 * scale)
            )
            leg = bpy.context.active_object
            leg.name = f"Leg_{i}"
            leg.rotation_euler = (1.57, 0, angle)
            bpy.ops.object.shade_smooth()
            legs.append(leg)
        
        return legs
    
    def create_wings(self, scale=1.0):
        """날개 생성"""
        wings = []
        
        for side in [-1, 1]:
            # 날개 메시 (평면을 변형)
            bpy.ops.mesh.primitive_plane_add(
                size=0.3 * scale, location=(side * 0.15 * scale, 0, 0.1 * scale)
            )
            wing = bpy.context.active_object
            wing.name = f"Wing_{['L', 'R'][side > 0]}"
            wing.scale = (0.5, 1.5, 1.0)
            bpy.ops.object.shade_smooth()
            wings.append(wing)
        
        return wings
    
    def create_wolf(self, scale=1.0):
        """늑대 생성"""
        print("[NEXUS] 생성 중: Wolf")
        
        body = self.create_body(scale, shape="cylinder")
        head = self.create_head(scale)
        legs = self.create_legs(4, scale)
        
        # 꼬리
        bpy.ops.mesh.primitive_cone_add(
            radius=0.05 * scale, depth=0.3 * scale,
            location=(0.15 * scale, 0, -0.1 * scale)
        )
        tail = bpy.context.active_object
        tail.name = "Tail"
        bpy.ops.object.shade_smooth()
        legs.append(tail)
        
        # 모든 파트 합치기
        all_parts = [body, head] + legs
        for obj in all_parts:
            obj.select_set(True)
        
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.join()
        
        monster = bpy.context.active_object
        monster.name = "Wolf"
        return monster
    
    def create_bat(self, scale=1.0):
        """박쥐 생성"""
        print("[NEXUS] 생성 중: Bat")
        
        body = self.create_body(scale * 0.6, shape="sphere")
        head = self.create_head(scale * 0.6)
        wings = self.create_wings(scale * 0.8)
        
        all_parts = [body, head] + wings
        for obj in all_parts:
            obj.select_set(True)
        
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.join()
        
        monster = bpy.context.active_object
        monster.name = "Bat"
        return monster
    
    def create_skeleton(self, scale=1.0):
        """스켈레톤 생성"""
        print("[NEXUS] 생성 중: Skeleton")
        
        body = self.create_body(scale * 1.1, shape="cube")
        head = self.create_head(scale * 1.1)
        legs = self.create_legs(2, scale * 1.1)
        
        # 팔
        for side in [-1, 1]:
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.04 * scale, depth=0.3 * scale,
                location=(side * 0.15 * scale, 0, 0.1 * scale)
            )
            arm = bpy.context.active_object
            arm.name = f"Arm_{['L', 'R'][side > 0]}"
            bpy.ops.object.shade_smooth()
            legs.append(arm)
        
        all_parts = [body, head] + legs
        for obj in all_parts:
            obj.select_set(True)
        
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.join()
        
        monster = bpy.context.active_object
        monster.name = "Skeleton"
        return monster
    
    def create_generic_monster(self, name, spec):
        """일반 몬스터 생성 (템플릿)"""
        print(f"[NEXUS] 생성 중: {name}")
        
        scale = spec.get("scale", 1.0)
        body = self.create_body(scale, shape="sphere")
        head = self.create_head(scale)
        
        parts = [body, head]
        
        # 다리
        if "legs" in spec:
            legs = self.create_legs(spec["legs"], scale)
            parts.extend(legs)
        
        # 날개
        if spec.get("wings", False):
            wings = self.create_wings(scale)
            parts.extend(wings)
        
        # 모든 파트 합치기
        for obj in parts:
            obj.select_set(True)
        
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.join()
        
        monster = bpy.context.active_object
        monster.name = name
        
        # 머터리얼 추가
        mat = bpy.data.materials.new(name=f"{name}_Material")
        if mat.use_nodes:
            mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            spec["color"][0], spec["color"][1], spec["color"][2], 1.0
        )
        monster.data.materials.append(mat)
        
        return monster
    
    def export_monster(self, monster, name):
        """몬스터를 FBX로 내보내기"""
        filepath = os.path.join(self.output_dir, f"{name}.fbx")
        
        monster.select_set(True)
        bpy.context.view_layer.objects.active = monster
        bpy.ops.export_scene.fbx(
            filepath=filepath,
            use_selection=True
        )
        
        print(f"[NEXUS] ✅ 내보내기: {filepath}")
        return filepath
    
    def generate_all(self):
        """모든 몬스터 생성"""
        monsters_data = []
        
        # 특수 몬스터들
        special_generators = {
            "Wolf": self.create_wolf,
            "Bat": self.create_bat,
            "Skeleton": self.create_skeleton,
        }
        
        for name, spec in self.monsters_spec.items():
            # 씬 정리
            bpy.ops.object.select_all(action='SELECT')
            bpy.ops.object.delete(use_global=False)
            
            # 몬스터 생성
            if name in special_generators:
                monster = special_generators[name](spec.get("scale", 1.0))
            else:
                monster = self.create_generic_monster(name, spec)
            
            # 내보내기
            filepath = self.export_monster(monster, name)
            monsters_data.append({
                "name": name,
                "filepath": filepath
            })
        
        return monsters_data


def main():
    """메인 함수"""
    print("[NEXUS] 🔥 Blender 몬스터 생성 시작")
    print(f"[NEXUS] Blender 버전: {bpy.app.version_string}")
    
    generator = MonsterGenerator()
    monsters = generator.generate_all()
    
    print("\n[NEXUS] ✅ 모든 몬스터 생성 완료!")
    print(f"[NEXUS] 총 {len(monsters)}개 몬스터 생성됨\n")
    
    for monster in monsters:
        print(f"  - {monster['name']}: {monster['filepath']}")
    
    print("\n[NEXUS] 다음 단계: Godot에서 자동 임포트 및 애니메이션 추가")


if __name__ == "__main__":
    main()
