#!/usr/bin/env python3
"""
FBX → Godot 자동 임포트 도구
Godot 4.2+ 프로젝트에 FBX 모델과 애니메이션 자동 임포트
"""

import json
import os
from pathlib import Path

def create_import_config(fbx_file: str, asset_type: str = "character") -> dict:
    """Godot 임포트 설정 생성"""
    
    config = {
        "importer": "scene",
        "type": "PackedScene",
        "uid": "uid://generated",
        "path": fbx_file,
        "import_metadata": {
            "asset_type": asset_type,
            "auto_import": True,
            "created_at": "2026-05-09"
        },
        "options": {
            "meshes/ensure_tangents": True,
            "meshes/generate_lods": True,
            "meshes/create_shadow_meshes": False,
            "reimport_skeletal_meshes": True,
            "animation/fps": 30,
            "animation/trimming": False,
            "animation/remove_immoral_data": False
        }
    }
    
    return config

def generate_godot_script(model_name: str, asset_type: str = "character") -> str:
    """Godot GDScript 기본 템플릿 생성"""
    
    if asset_type == "character":
        script = f'''# Auto-generated character loader for {model_name}
extends Node3D

@onready var model = $Model
@onready var animation_player = $Model/AnimationPlayer
@onready var skeleton = $Model/Skeleton3D

# 사용 가능한 애니메이션
var animations: Dictionary = {{}}

func _ready() -> void:
    if not animation_player:
        push_error("AnimationPlayer를 찾을 수 없습니다")
        return
    
    # 모든 애니메이션 자동 수집
    for anim_name in animation_player.get_animation_list():
        animations[anim_name] = animation_player.get_animation(anim_name)
    
    print("✅ {{name}} 로드 완료: %d개 애니메이션" % [animations.size()])

func play_animation(name: String, from_pos: float = 0.0) -> void:
    """애니메이션 재생"""
    if name in animations:
        animation_player.play(name, CustomAnimation.BLEND, 0.1)
    else:
        push_warning("애니메이션 '%s'을 찾을 수 없습니다" % [name])

func get_animation_duration(name: String) -> float:
    """애니메이션 길이 반환"""
    if name in animations:
        return animations[name].length
    return 0.0

func set_animation_speed(speed: float) -> void:
    """애니메이션 재생 속도 설정"""
    animation_player.speed_scale = speed
'''.format(name=model_name)
    
    elif asset_type == "monster":
        script = f'''# Auto-generated monster loader for {model_name}
extends Node3D

@onready var model = $Model
@onready var animation_player = $AnimationPlayer
@onready var skeletal_mesh = $Model/SkeletalMesh

func _ready() -> void:
    print("✅ {{name}} 몬스터 로드 완료")

func play_attack_animation() -> void:
    var attack_anims = [anim for anim in animation_player.get_animation_list() if "attack" in anim.to_lower()]
    if attack_anims.size() > 0:
        animation_player.play(attack_anims[0])

func play_idle_animation() -> void:
    if "Idle" in animation_player.get_animation_list():
        animation_player.play("Idle")
'''.format(name=model_name)
    
    return script

def create_import_package(fbx_path: str, asset_type: str = "character") -> dict:
    """전체 임포트 패키지 생성"""
    
    fbx_path = Path(fbx_path)
    model_name = fbx_path.stem
    
    package = {
        "metadata": {
            "model_name": model_name,
            "asset_type": asset_type,
            "fbx_path": str(fbx_path),
            "status": "ready_for_import"
        },
        "godot_import_config": create_import_config(str(fbx_path), asset_type),
        "gdscript_template": generate_godot_script(model_name, asset_type),
        "instructions": [
            "1. FBX 파일을 Godot Assets 폴더에 복사",
            "2. Godot 에디터가 자동 임포트 수행",
            "3. 생성된 씬을 프로젝트에 추가",
            "4. 제공된 GDScript를 로더로 사용"
        ]
    }
    
    return package

def print_import_summary(fbx_path: str) -> None:
    """임포트 준비 요약 출력"""
    
    fbx_path = Path(fbx_path)
    model_name = fbx_path.stem
    
    print(f"\n{'='*60}")
    print(f"🎯 Godot 임포트 준비: {model_name}")
    print(f"{'='*60}")
    print(f"📁 FBX: {fbx_path}")
    print(f"📊 크기: {fbx_path.stat().st_size / 1024 / 1024:.2f} MB")
    print(f"\n🔧 다음 단계:")
    print(f"1. FBX를 Assets/Models/에 복사")
    print(f"2. Godot 에디터 재시작 (자동 임포트)")
    print(f"3. Scenes/에 씬 파일 생성")
    print(f"4. 임포트 설정 확인")
    print(f"{'='*60}\n")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        fbx_file = sys.argv[1]
        asset_type = sys.argv[2] if len(sys.argv) > 2 else "character"
        
        if os.path.exists(fbx_file):
            package = create_import_package(fbx_file, asset_type)
            print_import_summary(fbx_file)
            
            # 설정 파일 저장
            config_path = Path(fbx_file).with_suffix('.import.json')
            with open(config_path, 'w') as f:
                json.dump(package, f, indent=2)
            print(f"✅ 설정 저장: {config_path}")
        else:
            print(f"❌ 파일 없음: {fbx_file}")
            sys.exit(1)
    else:
        print("사용법: python3 model_import.py <fbx_file> [character|monster|environment]")
        sys.exit(1)
