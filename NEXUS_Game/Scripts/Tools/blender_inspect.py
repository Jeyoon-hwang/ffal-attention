#!/usr/bin/env python3
import bpy

print("\n📊 Blend 파일 내용:")
print("=" * 50)

print("\n🔧 Object 목록:")
for obj in bpy.data.objects:
    print(f"  - {obj.name} ({obj.type})")

print("\n🎨 Mesh 목록:")
for mesh in bpy.data.meshes:
    print(f"  - {mesh.name}")

print("\n🦴 Armature 목록:")
for arm in bpy.data.armatures:
    print(f"  - {arm.name}")

print("\n✅ 검사 완료\n")
