#!/usr/bin/env python3
"""
Blender glTF 자동 내보내기 스크립트 (Blender 5.1 호환)
목표: PlayerMale_v1.blend → PlayerMale_v1.glb (Godot 호환)

사용법:
  blender -b PlayerMale_v1.blend -P blender_export_gltf.py
"""

import bpy
import os
import sys

def export_gltf():
    """자동 glTF 내보내기 (간소화된 버전)"""
    
    # 현재 Blend 파일 경로
    blend_file = bpy.data.filepath
    blend_dir = os.path.dirname(blend_file)
    
    # 출력 경로 (glb 형식)
    output_file = os.path.join(blend_dir, "PlayerMale_v1.glb")
    
    print(f"🎬 Blender glTF Export 시작")
    print(f"  입력: {blend_file}")
    print(f"  출력: {output_file}")
    
    try:
        # 최소한의 설정으로 glTF 내보내기 (Blender 5.1 호환)
        bpy.ops.export_scene.gltf(
            filepath=output_file,
            export_format='GLB'  # 바이너리 glTF만 지정
        )
        
        # 파일 크기 확인
        if os.path.exists(output_file):
            file_size = os.path.getsize(output_file) / (1024 * 1024)  # MB
            print(f"✅ glTF 내보내기 완료!")
            print(f"  파일크기: {file_size:.2f} MB")
            print(f"  경로: {output_file}")
            sys.exit(0)
        else:
            print(f"❌ 내보내기 실패: 파일이 생성되지 않음")
            sys.exit(1)
            
    except Exception as e:
        print(f"❌ 에러: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    # Blender가 자동으로 이 스크립트를 실행함
    export_gltf()
