#!/usr/bin/env python3
"""
Blender → FBX 자동 내보내기 스크립트
사용: blender -b model.blend -P blender_export.py
또는: blender_export.py --input model.blend --output model.fbx
"""

import bpy
import os
import sys
from pathlib import Path

def export_fbx(input_file: str, output_file: str = None) -> bool:
    """Blender 모델을 FBX로 내보내기"""
    
    try:
        # 입력 파일 확인
        if not os.path.exists(input_file):
            print(f"❌ 파일 없음: {input_file}")
            return False
        
        # 출력 경로 설정 (기본: 같은 폴더에 .fbx로)
        if not output_file:
            output_file = str(Path(input_file).with_suffix('.fbx'))
        
        # 파일 열기
        bpy.ops.wm.open_mainfile(filepath=input_file)
        print(f"✅ 열음: {input_file}")
        
        # 전체 메시 선택
        bpy.ops.object.select_all(action='SELECT')
        
        # FBX 내보내기
        bpy.ops.export_scene.fbx(
            filepath=output_file,
            use_selection=False,
            use_anim=True,
            anim_step=1,
            use_default_take=True,
            use_armature_deform_only=False,
            add_leaf_bones=False,
            mesh_smooth_type='OFF',
            use_smoothing=False,
            use_custom_properties=True
        )
        
        print(f"✅ 내보냈음: {output_file}")
        print(f"📊 파일 크기: {os.path.getsize(output_file) / 1024 / 1024:.2f} MB")
        return True
        
    except Exception as e:
        print(f"❌ 오류: {e}")
        return False

def generate_animation_metadata(blend_file: str) -> dict:
    """Blender 애니메이션 메타데이터 생성"""
    
    try:
        metadata = {
            "file": blend_file,
            "animations": [],
            "armatures": []
        }
        
        # 현재 열려있는 Blend 파일 기준
        for obj in bpy.data.objects:
            if obj.type == 'ARMATURE':
                metadata["armatures"].append(obj.name)
        
        # 애니메이션 액션 수집
        for action in bpy.data.actions:
            anim_info = {
                "name": action.name,
                "frame_start": int(action.frame_range[0]),
                "frame_end": int(action.frame_range[1]),
                "frame_count": int(action.frame_range[1] - action.frame_range[0] + 1)
            }
            metadata["animations"].append(anim_info)
        
        print(f"📋 메타데이터:")
        print(f"  - 스켈톤: {len(metadata['armatures'])}")
        print(f"  - 애니메이션: {len(metadata['animations'])}")
        
        return metadata
        
    except Exception as e:
        print(f"⚠️  메타데이터 수집 실패: {e}")
        return {}

if __name__ == "__main__":
    # 커맨드라인 인자 처리
    input_file = None
    output_file = None
    
    if len(sys.argv) > 4:  # blender -P script.py -- --input X --output Y
        for i, arg in enumerate(sys.argv):
            if arg == "--input" and i + 1 < len(sys.argv):
                input_file = sys.argv[i + 1]
            elif arg == "--output" and i + 1 < len(sys.argv):
                output_file = sys.argv[i + 1]
    
    # 기본 사용법 (Blender 셀렉션 기반)
    if not input_file:
        print("🔵 Blender 자동화 도구 시작")
        print("사용법: blender model.blend -P blender_export.py")
        print("또는: python3 blender_export.py --input model.blend --output model.fbx")
        
        # 현재 Blend 파일에서 메타데이터만 수집
        metadata = generate_animation_metadata(bpy.data.filepath)
        if metadata:
            print("✅ 메타데이터 수집 완료")
    else:
        # 입력 파일 지정시 내보내기
        success = export_fbx(input_file, output_file)
        if success:
            metadata = generate_animation_metadata(input_file)
            sys.exit(0)
        else:
            sys.exit(1)
