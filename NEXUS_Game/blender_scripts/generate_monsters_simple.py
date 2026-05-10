#!/usr/bin/env python3
"""
NEXUS 무술 창조 게임 - 간단한 몬스터 생성 (Day 17-18)
"""

import bpy
import os

class MonsterGenerator:
    def __init__(self, output_dir="assets/Models/Monsters"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
    
    def clear_scene(self):
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
    
    def create_simple_monster(self, name, color=(0.5, 0.5, 0.5)):
        """간단한 몬스터 생성"""
        # 구체 하나로 몬스터 만들기
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.3, location=(0, 0, 0))
        monster = bpy.context.active_object
        monster.name = name
        
        # 머터리얼
        mat = bpy.data.materials.new(name=f"{name}_Mat")
        if mat.use_nodes:
            mat.node_tree.nodes["Principled BSDF"].inputs[0].default_value = (
                color[0], color[1], color[2], 1.0
            )
        monster.data.materials.append(mat)
        
        return monster
    
    def export_monster(self, monster, name):
        """내보내기"""
        filepath = os.path.join(self.output_dir, f"{name}.fbx")
        monster.select_set(True)
        bpy.context.view_layer.objects.active = monster
        bpy.ops.export_scene.fbx(filepath=filepath, use_selection=True)
        print(f"[NEXUS] ✅ {name}: {filepath}")
        return filepath
    
    def generate_all(self):
        """모든 몬스터 생성"""
        monsters = {
            "Wolf": (0.6, 0.5, 0.4),
            "Bat": (0.3, 0.3, 0.4),
            "Skeleton": (0.7, 0.7, 0.7),
            "Bear": (0.4, 0.3, 0.2),
            "Giant": (0.5, 0.4, 0.3),
            "Spider": (0.2, 0.2, 0.2),
            "Demon": (0.8, 0.2, 0.2),
            "Golem": (0.4, 0.4, 0.4),
            "Zombie": (0.3, 0.5, 0.3),
            "Dragon": (0.8, 0.6, 0.2),
        }
        
        for name, color in monsters.items():
            self.clear_scene()
            monster = self.create_simple_monster(name, color)
            self.export_monster(monster, name)
        
        return list(monsters.keys())

def main():
    print("[NEXUS] 🔥 간단한 몬스터 생성 시작")
    generator = MonsterGenerator()
    monsters = generator.generate_all()
    print(f"\n[NEXUS] ✅ {len(monsters)}개 몬스터 생성 완료!")

if __name__ == "__main__":
    main()
