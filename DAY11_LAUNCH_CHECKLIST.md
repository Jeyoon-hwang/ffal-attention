# 🚀 Day 11 (2026-05-11, 일요일) 본격 개발 시작!

**목표:** Week 3-4 모델링 & 애니메이션 본격화 (40% → 70%)

---

## ✅ 최종 체크리스트 (Day 11 시작 전)

### 도구 & 환경 (NOW)

- [x] **Godot 4.3+** 설치 완료
- [x] **Blender 5.1.1** 설치 완료
- [x] **Python 3.10+** 확인
  ```bash
  python3 --version
  ```
- [x] **Git** 확인
  ```bash
  git --version
  ```
- [ ] **OpenGL/Metal** 그래픽 드라이버 최신 상태 확인

### NEXUS_Game 프로젝트 상태

- [x] 프로젝트 폴더 존재: `/Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game`
- [x] GDD & ROADMAP 문서 완성
- [x] Week 1-2 완료 (40%)
- [x] 에러 0건 유지
- [ ] **Day 11을 위한 체크:**
  ```bash
  cd ~/.openclaw/workspace/NEXUS_Game
  godot --version
  ```

### 모델링 & 애니메이션 준비

#### 모델 리소스
- [ ] **Sketchfab 모델 다운로드** (Day 11 아침 30분)
  - 필요: 캐릭터 1개 (기본형)
  - 몬스터: 3-5개 (늑대, 박쥐, 스켈레톤, 곰, 거인)
  - 환경: 나무, 바위, 건물 (기초)
  
  **추천 사이트:**
  - Sketchfab: https://sketchfab.com (무료 모델)
  - OpenGameArt: https://opengameart.org
  - CGTrader: https://www.cgtrader.com (유료, 고품질)

#### Blender 애니메이션 도구
- [ ] **Mixamo 계정 가입** (선택, 무료 애니메이션)
  - https://www.mixamo.com (Adobe)
  - 자동 리그 + 애니메이션
  - Blender로 자동 FBX 다운로드 가능
  
- [ ] **Blender 애드온 설정**
  - Better FBX Importer & Exporter (FBX 호환성)
  - Animation Importer (스켈톤 맞춤)

#### Python 스크립트 (자동화)
- [ ] **애니메이션 생성 스크립트** 준비
  - 모델에서 자동으로 애니메이션 프레임 생성
  - GDScript로 변환
  - Godot 자동 임포트

---

## 📊 Week 3-4 목표 (Day 11-24)

### Week 3 (Day 11-18): 모델 & 기본 애니메이션

| Day | 목표 | 산출물 | 진행도 |
|-----|------|--------|--------|
| 11 | 플레이어 모델 + 기본 애니메이션 5개 | Char 1 + Anim 5 | 40% → 45% |
| 12 | 전투 애니메이션 +7개 | **Anim 12개 도달** | 45% → 50% |
| 13-14 | 몬스터 3개 + 애니메이션 24개 | Monster 3 + Anim 36 | 50% → 55% |
| 15-16 | 환경 + 중원 완성 | Env 10 + 지역 완성 | 55% → 60% |
| 17-18 | 보스 + 애니메이션 20개 | Boss 1 + **Anim 56개 도달** | 60% → 65% |

**진행도: 40% → 65%**

### Week 4 (Day 19-24): 콘텐츠 확장 & 최적화

| Day | 목표 | 산출물 | 진행도 |
|-----|------|--------|--------|
| 19-20 | 천산 지역 + 몬스터 2개 | Env + **Anim 78개** | 65% → 67% |
| 21-22 | 추가 애니메이션 + 최적화 | **Anim 100+개, 최적화** | 67% → 69% |
| 23 | UI 완성 | UI 100% | 69% → 70% |
| 24 | 최종 통합 & 버그 픽스 | **에러 0 유지** | **70% 달성!** |

**진행도: 65% → 70%**

---

## 🎯 Day 11 (내일 아침) 실행 순서

### 09:00 - 프로젝트 셋업 (30분)
```bash
# 1. 프로젝트 폴더 이동
cd ~/.openclaw/workspace/NEXUS_Game

# 2. 상태 확인
git status
git log --oneline -5

# 3. Godot 프로젝트 열기 (또는 확인)
godot --version
ls -la engine/
```

### 09:30 - 모델 리소스 다운로드 (30분)
- Sketchfab에서 모델 찾기
- 기본 인간형 캐릭터 1개 (로우폴리/미드폴리)
- 라이센스 확인 (CC0 또는 CC-BY)

### 10:00 - Blender 셋업 (30분)
- Blender 열기
- 다운로드한 모델 임포트
- 스켈톤 자동 생성 (Rigify)
- 기본 위치 애니메이션 생성

### 10:30 - 첫 번째 애니메이션 만들기 (1시간)
- 기본 애니메이션 (대기, 이동, 회피)
- FBX로 내보내기
- Godot으로 테스트

### 11:30 - Godot 통합 (30분)
- FBX 모델 임포트
- 애니메이션 자동 인식
- 테스트 씬에서 확인

### 12:00 - 첫 번째 체크인 ✅
- Git commit
- Daily log 작성
- 진행도 업데이트

---

## 📁 Day 11부터의 파일 구조

```
NEXUS_Game/
├── Assets/
│   ├── Models/
│   │   ├── Characters/
│   │   │   ├── Player_v1.blend        (Day 11 생성)
│   │   │   └── Player_v1.fbx          (Day 11 생성)
│   │   ├── Monsters/
│   │   │   ├── Wolf_v1.blend          (Day 12-13)
│   │   │   └── Wolf_v1.fbx            (Day 12-13)
│   │   └── Environments/
│   │       ├── Tree_01.blend          (Day 15-16)
│   │       └── Tree_01.fbx            (Day 15-16)
│   │
│   ├── Animations/
│   │   ├── Player_Idle.anim           (Day 11)
│   │   ├── Player_Walk.anim           (Day 11)
│   │   ├── Player_Attack1.anim        (Day 12)
│   │   └── ...                        (Day 12-24)
│   │
│   └── Textures/
│       ├── Player_Diffuse.png         (Day 11)
│       └── ...                        (Day 12-24)
│
├── Scripts/
│   ├── Graphics/
│   │   ├── CharacterRenderer.gd       (Day 11)
│   │   ├── AnimationController.gd     (Day 12)
│   │   └── EnvironmentLoader.gd       (Day 15-16)
│   └── ...
│
├── Tools/
│   ├── blender_export.py              (Day 11 생성)
│   ├── model_import.py                (Day 11 생성)
│   └── animation_generator.py         (Day 12 생성)
│
└── Docs/
    ├── WEEK3_4_PROGRESS.md            (Day 11 생성, 매일 갱신)
    ├── DAY11_LOG.md                   (Day 11)
    ├── DAY12_LOG.md                   (Day 12)
    └── ...
```

---

## 🛠️ 자동화 도구 준비

### Python 스크립트: Blender → Godot

```python
# tools/blender_export.py
# (Day 11에 작성할 것)

import bpy
import sys

def export_model(input_blend, output_fbx):
    """Blender 모델을 FBX로 내보내기"""
    bpy.ops.import_scene.blend(filepath=input_blend)
    bpy.ops.export_scene.fbx(filepath=output_fbx, use_anim=True)
    print(f"✅ Exported: {output_fbx}")

def generate_animation_frames(model, anim_name, frames):
    """애니메이션 프레임 생성"""
    # (Day 12에 구현)
    pass
```

### GDScript: Godot 통합

```gdscript
# Scripts/Graphics/CharacterRenderer.gd
# (Day 11에 작성할 것)

extends Node3D

@onready var model = $Model
@onready var animation = $AnimationPlayer

func play_animation(name: String) -> void:
    animation.play(name)

func setup_model(fbx_path: String) -> void:
    # FBX 자동 임포트
    pass
```

---

## ⚡ 성공 조건 (Day 11 끝)

- [x] 플레이어 모델 1개 완성
- [x] 기본 애니메이션 5개 완성
- [x] Godot에서 표시 & 재생 가능
- [x] 에러 0건 유지
- [x] Git commit 완료
- [x] Daily log 작성

**진행도 확인: 40% → 45% 확인**

---

## 📝 Day 11 Daily Log 템플릿

```markdown
# Day 11 (2026-05-11) - 모델링 & 애니메이션 시작!

## 성과
- [x] 플레이어 모델 완성
- [x] 기본 애니메이션 5개 완성
- [x] Godot 테스트 성공

## 통계
- 모델: 1개
- 애니메이션: 5개
- 버그: 0건 ✅
- 진행도: 40% → 45%
- 시간: 4시간 30분

## 다음 Day 12 계획
- 전투 애니메이션 7개 추가
- 몬스터 모델 1개 시작

## 메모
- Blender의 Rigify 매우 효율적
- FBX 임포트 자동으로 Godot 인식 ✅
```

---

## 🔥 Day 11 최종 체크

- [ ] 도구 모두 설치 확인
- [ ] 프로젝트 폴더 정리 완료
- [ ] 모델 리소스 1개 이상 준비
- [ ] Blender 애드온 설치
- [ ] Python 스크립트 템플릿 준비
- [ ] Godot 프로젝트 열기 확인
- [ ] Git 설정 완료
- [ ] 일정표 인쇄/확인

**준비 완료? → Day 11 아침 9시 GO! 🚀**

---

## 🎯 핵심 원칙 (Week 3-4)

1. **매일 커밋** - 진행률 추적
2. **매일 테스트** - Godot에서 직접 보기
3. **애니메이션 자동화** - 스크립트로 시간 절약
4. **병렬 작업** - 모델 + 스크립트 동시 진행
5. **에러 0 유지** - Week 1-2의 전통 계속

---

**Version:** 1.0  
**Updated:** 2026-05-08 23:00  
**Status:** 🚀 **Day 11 준비 완료!**

**지금부터 풀속도! ⚡**
