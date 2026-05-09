#!/usr/bin/env python3
"""
Day 5: Export FBX for Godot
"""
import bpy
import os

print("\n🎬 [Blender FBX Export] 시작\n")

# 저장 경로
base_path = "/Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game/Assets/Models/Characters/Base"
fbx_path = os.path.join(base_path, "PlayerMale_v1_final.fbx")

print(f"📍 FBX 내보내기: {fbx_path}")

# FBX 내보내기 (Godot용)
try:
    bpy.ops.export_scene.fbx(
        filepath=fbx_path,
        use_mesh_modifiers=True,
        bake_anim=True,
        bake_anim_use_all_actions=True,
    )
    
    print(f"✅ FBX 내보내기 완료: {fbx_path}")
    
    # 파일 크기 확인
    if os.path.exists(fbx_path):
        file_size_kb = os.path.getsize(fbx_path) / 1024
        print(f"   파일 크기: {file_size_kb:.1f} KB")
    
except Exception as e:
    print(f"❌ FBX 내보내기 실패: {e}")
    exit(1)

print("\n✅ 완료!\n")
