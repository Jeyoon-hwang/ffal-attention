#!/usr/bin/env python3
"""NEXUS 무술 창조 게임 - 간단한 환경 에셋 생성"""

import bpy
import os

class EnvironmentGenerator:
    def __init__(self, output_dir="assets/Models/Environments"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
    
    def clear_scene(self):
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
    
    def create_simple_asset(self, name, color=(0.5, 0.5, 0.5)):
        """간단한 에셋 생성"""
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.5, location=(0, 0, 0))
        obj = bpy.context.active_object
        obj.name = name
        
        mat = bpy.data.materials.new(name=f"{name}_Mat")
        if mat.use_nodes:
            mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
                color[0], color[1], color[2], 1.0
            )
        obj.data.materials.append(mat)
        return obj
    
    def export_asset(self, obj, name):
        filepath = os.path.join(self.output_dir, f"{name}.fbx")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.export_scene.fbx(filepath=filepath, use_selection=True)
        print(f"[NEXUS] ✅ {name}")
        return filepath
    
    def generate_all(self):
        assets = {
            "Tree_1": (0.2, 0.6, 0.2),
            "Tree_2": (0.2, 0.5, 0.2),
            "Rock_1": (0.5, 0.5, 0.5),
            "Rock_2": (0.6, 0.6, 0.6),
            "Rock_3": (0.4, 0.4, 0.4),
            "House_1": (0.7, 0.4, 0.2),
            "House_2": (0.8, 0.5, 0.3),
            "Bush_1": (0.3, 0.5, 0.2),
            "Bush_2": (0.4, 0.6, 0.3),
            "Water": (0.1, 0.3, 0.8),
        }
        
        for name, color in assets.items():
            self.clear_scene()
            obj = self.create_simple_asset(name, color)
            self.export_asset(obj, name)
        
        return list(assets.keys())

def main():
    print("[NEXUS] 🔥 환경 에셋 생성 시작")
    generator = EnvironmentGenerator()
    assets = generator.generate_all()
    print(f"\n[NEXUS] ✅ {len(assets)}개 에셋 생성 완료!")

if __name__ == "__main__":
    main()
