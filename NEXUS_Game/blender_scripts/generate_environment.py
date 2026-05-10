#!/usr/bin/env python3
"""
NEXUS 무술 창조 게임 - Blender 환경 에셋 자동 생성
Day 19 목표: 환경 에셋 20+개 생성 (절차적)

사용 방법:
  blender --background --python blender_scripts/generate_environment.py
"""

import bpy
import os
import random
from mathutils import Vector

class EnvironmentGenerator:
    """절차적 환경 생성 시스템"""
    
    def __init__(self, output_dir="assets/Models/Environments"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        self.clear_default_scene()
    
    def clear_default_scene(self):
        """씬 정리"""
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
    
    def create_tree(self, name="Tree", scale=1.0):
        """나무 생성"""
        print(f"[NEXUS] 생성 중: {name}")
        
        # 트렁크
        bpy.ops.mesh.primitive_cylinder_add(
            radius=0.1 * scale, depth=2.0 * scale, location=(0, 0, 1.0 * scale)
        )
        trunk = bpy.context.active_object
        trunk.name = "Trunk"
        
        # 잎 (원뿔 모양)
        bpy.ops.mesh.primitive_cone_add(
            radius=0.8 * scale, depth=1.5 * scale, location=(0, 0, 2.5 * scale)
        )
        foliage = bpy.context.active_object
        foliage.name = "Foliage"
        
        # 머터리얼
        trunk_mat = bpy.data.materials.new(name="Wood")
        trunk_mat.use_nodes = True
        trunk_mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            0.4, 0.3, 0.2, 1.0
        )
        trunk.data.materials.append(trunk_mat)
        
        foliage_mat = bpy.data.materials.new(name="Leaves")
        foliage_mat.use_nodes = True
        foliage_mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            0.2, 0.6, 0.2, 1.0
        )
        foliage.data.materials.append(foliage_mat)
        
        # 합치기
        trunk.select_set(True)
        foliage.select_set(True)
        bpy.context.view_layer.objects.active = trunk
        bpy.ops.object.join()
        
        tree = bpy.context.active_object
        tree.name = name
        return tree
    
    def create_rock(self, name="Rock", scale=1.0):
        """바위 생성"""
        print(f"[NEXUS] 생성 중: {name}")
        
        # 바위는 스케일이 랜덤한 큐브
        bpy.ops.mesh.primitive_cube_add(size=1.0 * scale)
        rock = bpy.context.active_object
        rock.name = name
        
        # 불규칙한 형태
        rock.scale = (
            random.uniform(0.7, 1.3) * scale,
            random.uniform(0.7, 1.3) * scale,
            random.uniform(0.5, 1.2) * scale
        )
        bpy.ops.object.transform_apply(scale=True)
        
        # 머터리얼
        mat = bpy.data.materials.new(name="Stone")
        mat.use_nodes = True
        mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            0.5, 0.5, 0.5, 1.0
        )
        rock.data.materials.append(mat)
        
        return rock
    
    def create_building(self, name="House", scale=1.0):
        """건물 생성"""
        print(f"[NEXUS] 생성 중: {name}")
        
        # 벽
        bpy.ops.mesh.primitive_cube_add(
            size=1.0,
            location=(0, 0, 1.0 * scale)
        )
        wall = bpy.context.active_object
        wall.name = "Wall"
        wall.scale = (1.0 * scale, 1.0 * scale, 2.0 * scale)
        bpy.ops.object.transform_apply(scale=True)
        
        # 지붕
        bpy.ops.mesh.primitive_cone_add(
            radius=0.6 * scale, depth=0.8 * scale,
            location=(0, 0, 2.5 * scale)
        )
        roof = bpy.context.active_object
        roof.name = "Roof"
        
        # 문 (상자)
        bpy.ops.mesh.primitive_cube_add(
            size=0.4 * scale, location=(0, 0.5 * scale, 0.5 * scale)
        )
        door = bpy.context.active_object
        door.name = "Door"
        door.scale = (0.3 * scale, 0.1 * scale, 1.0 * scale)
        bpy.ops.object.transform_apply(scale=True)
        
        # 합치기
        wall.select_set(True)
        roof.select_set(True)
        door.select_set(True)
        bpy.context.view_layer.objects.active = wall
        bpy.ops.object.join()
        
        building = bpy.context.active_object
        building.name = name
        
        # 머터리얼
        mat = bpy.data.materials.new(name="Brick")
        mat.use_nodes = True
        mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            0.7, 0.4, 0.2, 1.0
        )
        building.data.materials.append(mat)
        
        return building
    
    def create_bush(self, name="Bush", scale=1.0):
        """덤불 생성"""
        print(f"[NEXUS] 생성 중: {name}")
        
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=0.5 * scale, location=(0, 0, 0.5 * scale)
        )
        bush = bpy.context.active_object
        bush.name = name
        
        # 머터리얼
        mat = bpy.data.materials.new(name="Foliage")
        mat.use_nodes = True
        mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            0.3, 0.5, 0.2, 1.0
        )
        bush.data.materials.append(mat)
        
        return bush
    
    def create_water(self, name="Water"):
        """물 생성"""
        print(f"[NEXUS] 생성 중: {name}")
        
        bpy.ops.mesh.primitive_plane_add(
            size=10.0, location=(0, 0, 0)
        )
        water = bpy.context.active_object
        water.name = name
        
        # 머터리얼 (파란색)
        mat = bpy.data.materials.new(name="Water")
        mat.use_nodes = True
        mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
            0.1, 0.3, 0.8, 0.8
        )
        water.data.materials.append(mat)
        
        return water
    
    def export_object(self, obj, name):
        """객체를 FBX로 내보내기"""
        filepath = os.path.join(self.output_dir, f"{name}.fbx")
        
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.export_scene.fbx(
            filepath=filepath,
            use_selection=True
        )
        
        print(f"[NEXUS] ✅ 내보내기: {filepath}")
        return filepath
    
    def generate_all(self):
        """모든 환경 에셋 생성"""
        assets_data = []
        
        # 에셋 목록
        assets = [
            ("Tree_1", self.create_tree, {"name": "Tree_1", "scale": 1.0}),
            ("Tree_2", self.create_tree, {"name": "Tree_2", "scale": 1.2}),
            ("Rock_1", self.create_rock, {"name": "Rock_1", "scale": 0.8}),
            ("Rock_2", self.create_rock, {"name": "Rock_2", "scale": 1.0}),
            ("Rock_3", self.create_rock, {"name": "Rock_3", "scale": 1.5}),
            ("House_1", self.create_building, {"name": "House_1", "scale": 1.0}),
            ("House_2", self.create_building, {"name": "House_2", "scale": 1.0}),
            ("Bush_1", self.create_bush, {"name": "Bush_1", "scale": 0.8}),
            ("Bush_2", self.create_bush, {"name": "Bush_2", "scale": 1.0}),
            ("Water", self.create_water, {}),
        ]
        
        for asset_name, generator, kwargs in assets:
            # 씬 정리
            bpy.ops.object.select_all(action='SELECT')
            bpy.ops.object.delete(use_global=False)
            
            # 생성
            obj = generator(**kwargs)
            
            # 내보내기
            filepath = self.export_object(obj, asset_name)
            assets_data.append({
                "name": asset_name,
                "filepath": filepath
            })
        
        return assets_data


def main():
    """메인 함수"""
    print("[NEXUS] 🔥 Blender 환경 에셋 생성 시작")
    print(f"[NEXUS] Blender 버전: {bpy.app.version_string}")
    
    generator = EnvironmentGenerator()
    assets = generator.generate_all()
    
    print("\n[NEXUS] ✅ 모든 환경 에셋 생성 완료!")
    print(f"[NEXUS] 총 {len(assets)}개 에셋 생성됨\n")
    
    for asset in assets:
        print(f"  - {asset['name']}: {asset['filepath']}")
    
    print("\n[NEXUS] 다음 단계: Godot에서 자동 임포트")


if __name__ == "__main__":
    main()
