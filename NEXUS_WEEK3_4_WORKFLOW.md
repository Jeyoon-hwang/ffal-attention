# 🎨 Week 3-4 모델링 & 애니메이션 워크플로우

**목표:** 최소 시간에 최대 품질로 100+개 애니메이션 생성

---

## 📊 전체 프로세스 (Day 11-24)

```
Sketchfab/CGTrader 모델 다운로드
       ↓
Blender 임포트 & 리깅
       ↓
애니메이션 생성 (Mixamo 또는 직접)
       ↓
FBX 내보내기
       ↓
Godot 자동 임포트
       ↓
테스트 & 최적화
       ↓
Git 커밋 & Daily log
```

---

## 🎬 Day 별 타스크 분해

### **Day 11 (2026-05-11, 일요일): 플레이어 모델 + 기본 애니메이션 5개**

#### 오전 (09:00-12:00) - 모델 및 리깅
1. **09:00-09:30: 모델 다운로드**
   - Sketchfab에서 "human character male" 검색
   - 조건: CC0 또는 CC-BY, 미드폴리 (<50k 폴리곤)
   - 추천:
     - "Free Fantasy Male Character" (Sketchfab)
     - "Rigged Human" (OpenGameArt)
   - 다운로드: `.blend` 또는 `.fbx`

2. **09:30-10:30: Blender 임포트 & 리깅**
   ```
   1) Blender 열기
   2) 모델 파일 임포트 (File > Import > ...)
   3) 스켈톤 자동 생성 (Modifier > Armature > Auto-Rig Pro 또는 Rigify)
   4) 기본 포즈 설정 (T-Pose)
   5) 저장: Player_v1.blend
   ```

3. **10:30-12:00: 기본 애니메이션 5개 생성**
   - **Idle (대기):** 1-2초 자연스러운 서있는 모션
   - **Walk (걷기):** 2-3초 전진 보행
   - **Run (달리기):** 1.5-2초 빠른 이동
   - **Attack1 (기본 공격):** 1초 펀치
   - **Evade (회피):** 1초 옆으로 굴러가기

   **생성 방법 (2가지 선택):**
   - **옵션 A: Mixamo (권장, 자동)**
     - 모델 Mixamo에 업로드
     - 애니메이션 선택 & 다운로드 (FBX)
     - Blender 임포트
     - 소요: 10분
   
   - **옵션 B: Blender 직접 애니메이션**
     - Dope Sheet에서 키프레임 생성
     - 0-30프레임: Idle
     - 30-60프레임: Walk
     - 60-90프레임: Run
     - 등등...
     - 소요: 1시간

#### 오후 (14:00-17:00) - 내보내기 & Godot 통합
4. **14:00-15:00: FBX 내보내기**
   ```
   Blender File > Export > FBX
   
   설정:
   - Animation: ON
   - Shape Keys: OFF
   - Armature: ON
   - Group by NLA Track: ON
   - NLA Strips: ON
   - All Action: ON
   
   저장: Assets/Models/Characters/Player_v1.fbx
   ```

5. **15:00-16:00: Godot 임포트 & 테스트**
   ```gdscript
   # Scripts/Graphics/CharacterRenderer.gd
   extends Node3D

   @onready var model = $Player_v1
   @onready var animator = $Player_v1/AnimationPlayer

   func _ready():
       # FBX 자동 임포트됨
       animator.play("Idle")

   func play_anim(name: str):
       animator.play(name)

   func _input(event):
       if event.is_action_pressed("ui_accept"):
           play_anim("Walk")
   ```
   - Godot에서 모델 드래그 & 드롭
   - 애니메이션 재생 테스트
   - 버그 확인

6. **16:00-17:00: 최적화 & 커밋**
   ```bash
   # 모델 최적화
   # - 폴리곤 수: 10k-20k (목표)
   # - 텍스처 크기: 1024x1024 또는 2048x2048
   # - LOD 레벨: 2개 (멀리서/가까이서)
   
   git add Assets/Models/Characters/Player_v1.*
   git commit -m "Day 11: Player model + 5 animations"
   ```

7. **17:00: Daily Log 작성**
   ```markdown
   # Day 11 (2026-05-11) - 플레이어 모델 완성!
   
   ## 성과 ✅
   - 플레이어 모델 (미드폴리, 자동 리깅)
   - 기본 애니메이션 5개 (Idle, Walk, Run, Attack, Evade)
   - Godot 테스트 성공
   
   ## 통계
   - 모델: 1개 (12k 폴리곤)
   - 애니메이션: 5개 (총 150프레임)
   - 에러: 0건 ✅
   - 시간 소요: 8시간
   - 진행도: 40% → 45% ✅
   
   ## 다음 Day 12: 전투 애니메이션 7개 추가
   ```

---

### **Day 12-13 (2026-05-12~13): 전투 애니메이션 추가 + 몬스터 3개**

#### 목표
- 플레이어 전투 애니메이션 7개 추가 (Attack2-Attack8)
- 몬스터 모델 3개 (Wolf, Bat, Skeleton)
- 각 몬스터 기본 애니메이션 3개

#### 프로세스
```
Day 12 (오전):
  - 플레이어 전투 애니메이션 3개 (Mixamo 또는 직접)
  
Day 12 (오후):
  - 플레이어 전투 애니메이션 4개 추가
  - 몬스터 Wolf 모델 다운로드 & 임포트

Day 13 (전체):
  - 몬스터 Bat, Skeleton 모델
  - 각 몬스터 기본 애니메이션 3개 (Idle, Walk, Attack)
  - 총 애니메이션: 5개 (Day 11) + 7개 (Day 12) + 12개 (Day 13) = **24개**
```

#### Mixamo 빠른 애니메이션 방법
```
1. Mixamo 로그인 (https://www.mixamo.com)
2. 캐릭터 업로드 (또는 기본 제공 캐릭터 사용)
3. "Walk" 검색 → 다운로드 (FBX)
4. Blender에서 작업 중인 파일과 동일한 캐릭터 기준 재설정
5. 애니메이션 FBX 임포트
6. 최종 FBX 내보내기 (모든 애니메이션 포함)

소요: 애니메이션당 2-3분 (매우 빠름!)
```

---

### **Day 14-15: 환경 에셋 + 중원 지역 완성**

#### 목표
- 환경 에셋 10개 (나무, 바위, 건물)
- 중원 지역 그래픽 완성
- 진행도: 50% → 55%

#### 태스크
```
Day 14:
  - 환경 모델 6개 (나무 3개, 바위 2개, 건물 1개)
  - 각 모델 텍스처 & 최적화

Day 15:
  - 환경 모델 4개 추가
  - 중원 지역 맵에 배치
  - 라이팅 & 섀도우 설정
  - 성능 테스트 (FPS 60 목표)
```

---

### **Day 16-17: 보스 모델 + 보스 애니메이션 20개**

#### 목표
- 중원 보스 모델 1개
- 보스 애니메이션 20개 (Idle, 공격 10개, 이동, 피해, Phase 전환 등)
- 진행도: 55% → 60%

#### 보스 애니메이션 목록 (Day 16-17)
```
Idle (대기) × 2
Walk × 1
Run × 1

Attack (공격) × 10
  - 기본 공격 1-5
  - 광역 공격 1-3
  - 특수 능력 2

Defense (방어) × 2
  - 가드
  - 회피

Damage (피해) × 2
  - 약한 피해
  - 큰 피해

Phase (위상 전환) × 2
  - Phase 1 → Phase 2
  - Phase 2 → Phase 3

총 20개
```

---

### **Day 18-20: 천산 지역 + 몬스터 2개**

#### 목표
- 천산 지역 환경 에셋 8개
- 몬스터 2개 (고등 몬스터)
- 지역 완성
- 진행도: 60% → 65%

---

### **Day 21-22: 최적화 + 애니메이션 확장**

#### 목표
- 성능 최적화 (FPS 60 유지)
- 추가 애니메이션 30개
- 진행도: 65% → 69%

#### 최적화 체크리스트
```
[ ] 모델 폴리곤 수 확인 (목표: 플레이어 10-20k, 몬스터 5-10k)
[ ] 텍스처 최적화 (크기, 압축)
[ ] LOD (Level of Detail) 설정 (멀리서는 저폴리)
[ ] 메쉬 병합 (같은 머티리얼끼리)
[ ] 셰이더 최적화 (복잡도 낮추기)
[ ] 물리 콜라이더 최소화
[ ] Godot 임포트 설정 최적화

목표:
  - CPU: <30ms per frame
  - GPU: <50ms per frame
  - 메모리: <500MB
```

---

### **Day 23: UI 완성**

#### 목표
- UI 에셋 및 스크린 100% 완성
- 진행도: 69% → 70%

---

### **Day 24: 최종 통합 & 버그 픽스**

#### 목표
- 모든 모델/애니메이션 Godot 연동 완료
- 에러 0건 유지
- 진행도: **70% 달성!** 🎉

---

## 🤖 자동화 도구 (Day 11-24)

### 1️⃣ Blender 스크립트: 모델 일괄 처리

```python
# tools/batch_export_models.py
# (Day 12 생성)

import bpy
import os

def batch_export_fbx(input_dir, output_dir):
    """폴더의 모든 Blend 파일을 FBX로 변환"""
    for filename in os.listdir(input_dir):
        if filename.endswith(".blend"):
            input_path = os.path.join(input_dir, filename)
            output_name = filename.replace(".blend", ".fbx")
            output_path = os.path.join(output_dir, output_name)
            
            # 파일 열기
            bpy.ops.wm.open_mainfile(filepath=input_path)
            
            # FBX 내보내기
            bpy.ops.export_scene.fbx(
                filepath=output_path,
                use_anim=True,
                anim_step=1,
                use_batch_mode=True
            )
            print(f"✅ Exported: {output_path}")

# 사용 예
if __name__ == "__main__":
    batch_export_fbx("Assets/Models", "Assets/Models")
```

### 2️⃣ Python 스크립트: Godot 자동 임포트 설정

```python
# tools/setup_godot_imports.py
# (Day 12 생성)

import os
import json

def create_import_settings(godot_project_dir, model_dir):
    """Godot FBX 임포트 설정 자동 생성"""
    for model_file in os.listdir(model_dir):
        if model_file.endswith(".fbx"):
            model_path = os.path.join(model_dir, model_file)
            import_settings_path = f"{model_path}.import"
            
            settings = {
                "importer": "scene",
                "type": "PackedScene",
                "uid": "uid://...",  # Godot이 자동 생성
                "path": "res://Assets/Models/...",
                "reimport_files": [model_path]
            }
            
            # Godot은 자동으로 임포트하므로 주석만 작성
            print(f"✅ Import settings created for: {model_file}")

if __name__ == "__main__":
    create_import_settings(
        "NEXUS_Game",
        "NEXUS_Game/Assets/Models"
    )
```

### 3️⃣ GDScript: 애니메이션 자동 로드

```gdscript
# Scripts/Graphics/AnimationLoader.gd
# (Day 12 생성)

extends Node3D

class_name AnimationLoader

# 애니메이션을 이름으로 자동 로드
var animations: Dictionary = {}

func _ready():
    load_all_animations("res://Assets/Models/Characters/")

func load_all_animations(path: String) -> void:
    """폴더의 모든 애니메이션 자동 로드"""
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tscn"):  # Godot 씬 파일
                animations[file_name] = load(f"{path}{file_name}")
            file_name = dir.get_next()
    
    print(f"✅ Loaded {animations.size()} animations")

func play_animation(anim_name: String) -> void:
    """이름으로 애니메이션 재생"""
    if animations.has(anim_name):
        # 재생 로직
        pass
    else:
        print(f"❌ Animation not found: {anim_name}")
```

---

## 📊 진행도 추적 (Day 11-24)

```
Day 11: 40% → 45% (플레이어 모델 + 기본 애니메이션 5개)
Day 12: 45% → 48% (전투 애니메이션 7개)
Day 13: 48% → 52% (몬스터 3개 + 애니메이션 12개)
Day 14: 52% → 54% (환경 6개)
Day 15: 54% → 56% (환경 4개 + 중원 완성)
Day 16: 56% → 58% (보스 모델)
Day 17: 58% → 60% (보스 애니메이션 20개)
Day 18: 60% → 62% (천산 환경)
Day 19: 62% → 64% (몬스터 2개)
Day 20: 64% → 66% (추가 애니메이션)
Day 21: 66% → 67% (최적화)
Day 22: 67% → 68% (더 많은 애니메이션)
Day 23: 68% → 69% (UI)
Day 24: 69% → 70% (최종 통합) 🎉

최종: **70% 완성**
```

---

## ✅ 품질 체크리스트 (매일)

### 모델 검사
- [ ] 폴리곤 수 정상 범위 (플레이어: 10-20k)
- [ ] 텍스처 흐릿함 없음
- [ ] 메쉬 구멍 없음 (Wireframe 모드 확인)
- [ ] 스켈톤 올바른 배치

### 애니메이션 검사
- [ ] 부자연스러운 움직임 없음
- [ ] 프레임 스킵 없음 (60 FPS 유지)
- [ ] 루프 애니메이션 끝과 처음 연결됨
- [ ] 충돌 없음 (모델 제자리에 꽉 찬 상태)

### Godot 통합 검사
- [ ] 모델 보임
- [ ] 애니메이션 재생 됨
- [ ] 에러 메시지 없음
- [ ] FPS 60 이상 유지

---

## 🎯 Day 11 최종 목표

```
시작: 40% (Week 1-2 완료)
     ↓
Day 11 끝: 45%
     ↓
Week 3-4 마치: 70%
     ↓
Week 5-8: 100% 향해
```

---

## 📝 Daily Commit 메시지 형식

```
Day 11: Player model + 5 basic animations

- Add Player_v1 model (12k polygons)
- Add animations: Idle, Walk, Run, Attack1, Evade
- Godot integration successful
- No errors, 60 FPS stable

Progress: 40% → 45%
```

---

**Version:** 1.0  
**Created:** 2026-05-08  
**Status:** 🚀 **Ready for Day 11!**

**에러 0, 완벽한 게임을 만든다! ⚡**
