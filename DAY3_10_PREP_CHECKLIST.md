# 📋 Day 3-10 준비 체크리스트
## Week 3-4 모델링/애니메이션 본격 개발 전 준비

**목표:** Day 11에 즉시 모델링 시작 가능한 환경 구축  
**기간:** 2026-05-09 ~ 2026-05-17 (8일)  
**현재:** Day 3 (2026-05-09 6:56 AM)  

---

## 🛠️ 도구 & 환경 확인

### ✅ 설치 완료
- [x] Godot 4.6.2 (godot command 확인)
- [x] Blender (blender command 확인)
- [x] Python 3.9 (python3 --version)
- [x] Git (프로젝트 초기화 완료)

### ⚙️ 추가 설정 필요

#### Day 3 (오늘) - 기본 환경 설정
```bash
# 1. Python 모듈 설치 (모델링 자동화 용)
pip3 install trimesh numpy pillow

# 2. Blender Python API 테스트
blender --version

# 3. Godot FBX 임포트 설정 확인
cd NEXUS_Game
godot --editor &
# → Assets 폴더 구조 확인
# → Import 설정 기본값 확인
# → 종료
```

**체크:** 에러 없음? ✅ → Day 4로

---

## 📚 리소스 수집 (Day 3-4)

### 1️⃣ 모델 다운로드 웹사이트 (무료 CC0/CC-BY)

**주요 사이트:**
- **Sketchfab** (https://sketchfab.com)
  - 필터: CC0 License, Human Character, 20k-50k polys
  - 다운로드 형식: Blend, FBX

- **OpenGameArt.org** (https://opengameart.org)
  - Rigged Human Models (자동 리깅 포함)
  - Fantasy characters

- **Mixamo** (https://www.mixamo.com)
  - 애니메이션 라이브러리 (무료)
  - 자동 리깅 (로그인 필요)

### 2️⃣ 다운로드 목록 (Day 3-4)

#### 플레이어 캐릭터
- [ ] 남성 캐릭터 (Rigged, 미드폴리)
  - 저장 위치: `Assets/Models/Characters/Base/PlayerMale_Base.blend`
  - 소요: 20분

#### 몬스터 3종 (Day 13까지 다운로드)
- [ ] Wolf (늑대) - 애니메이션 가능한 모델
- [ ] Bat (박쥐) - Flying 애니메이션 필요
- [ ] Skeleton (해골) - 골격 구조 명확한 모델

#### 보스 모델 (Day 16까지)
- [ ] Boss Character (중급 고폴리, 신체가 복잡한 모델)

#### 환경 에셋 (Day 14까지)
- [ ] 나무 (3종)
- [ ] 바위 (2종)
- [ ] 건물 (1종: 무술관)

**저장 구조:**
```
Assets/
├── Models/
│   ├── Characters/
│   │   └── Base/
│   │       ├── PlayerMale_Base.blend
│   │       ├── Wolf_Base.blend
│   │       └── ...
│   └── Environment/
│       ├── Tree_01.blend
│       ├── Rock_01.blend
│       └── ...
```

---

## 🔧 Blender 워크플로우 설정 (Day 4-5)

### 1️⃣ Blender 프로젝트 템플릿
```bash
mkdir -p NEXUS_BlenderWorkspace
cd NEXUS_BlenderWorkspace
blender --version
```

### 2️⃣ 리깅 & 애니메이션 도구

#### 자동 리깅 방법 (3가지 선택)
1. **Mixamo (가장 간단)**
   - Mixamo 웹사이트 업로드 → 자동 리깅 → 다운로드 (FBX)
   - 소요: 2-3분 per 모델

2. **Rigify (Blender 기본 애드온)**
   - Blender 메뉴: Add-ons → Rigify 활성화
   - 자동 생성, 고급 제어 가능
   - 소요: 5-10분 per 모델

3. **Auto-Rig Pro (커뮤니티 애드온)**
   - 다운로드: https://github.com/ndee85/auto_rig_pro_freeBased on earlier download
   - 설치: Add-ons → Install from file
   - 소요: 2-5분 per 모델

**Day 5 할 일:**
- [ ] Mixamo 계정 생성 (무료)
- [ ] Rigify 활성화 확인
- [ ] 테스트 모델로 자동 리깅 1회 연습

### 3️⃣ Blender FBX 내보내기 설정

**Day 5 오후:**
```
Blender → File → Export → FBX
확인할 설정:
  ✅ Animation: ON
  ✅ NLA Strips: ON (리깅 애니메이션 유지)
  ✅ All Action: ON (모든 애니메이션 포함)
  ✅ Deformed Mesh: ON (리깅된 메쉬)
  ✅ Leaf Bones: OFF (불필요한 뼈 제거)
  
설정 저장: 기본값으로 계속 사용
```

---

## 🎬 애니메이션 생성 도구 (Day 5-6)

### 1️⃣ Mixamo 애니메이션 사용 방법

**Day 6 실습:**
```
1. Mixamo 접속 (https://www.mixamo.com)
2. 캐릭터 업로드 (또는 기본 제공 캐릭터)
3. 검색: "Walk" → 다운로드 (FBX, 60fps)
4. 저장 위치: Assets/Animations/MixamoLib/
5. Blender에서 임포트 & 통합
```

### 2️⃣ Blender 직접 애니메이션 (백업용)

**Dope Sheet로 키프레임 생성 (Day 6-7):**
- Idle (30프레임)
- Walk (60프레임)
- Run (45프레임)
- Attack (30프레임)
- Evade (20프레임)

**참고:** 자동화 스크립트는 Day 12에 작성

---

## 🏗️ Godot 프로젝트 최적화 (Day 6-7)

### 1️⃣ Import 설정 확인

**Day 6 오전:**
```bash
cd NEXUS_Game

# Godot 열기
godot --editor

# 확인할 것:
# 1. Project Settings → Import → Scene → FBX
#    - Animation: Enabled
#    - Meshes: Ensure Tangents ✅
# 2. Assets 폴더 각 부위별 생성 확인
#    - Models/Characters/
#    - Models/Enemies/
#    - Models/Environment/
# 3. 각 폴더에 .import 폴더 자동 생성 확인
```

### 2️⃣ Test Scene 생성

**Day 7 오전:**
```gdscript
# Scenes/Test_ModelImport.tscn 생성
# 내용:
# - 빈 씬 생성
# - 3D Node 추가
# - 더미 FBX 모델 임포트 (테스트)
# - 애니메이션 재생 테스트

# Scripts/Test/ModelImportTest.gd
extends Node3D

@export var model_path: String = "res://Assets/Models/Characters/Base/PlayerMale_Base.fbx"

func _ready():
    var model = load(model_path)
    if model:
        print("✅ Model loaded successfully")
        add_child(model.instantiate())
    else:
        print("❌ Model load failed")
```

---

## 📝 개발 문서 & 워크플로우 (Day 7-8)

### 1️⃣ Daily Log 템플릿 생성

**Day 7:**
```markdown
# memory/DAILY_NEXUS_LOGS.md

## Day 11 (2026-05-11) - 플레이어 모델 + 기본 애니메이션
- 시작 시간: 09:00
- 종료 시간: 17:00
- 목표: 플레이어 모델 + 애니메이션 5개
- 성과: ✅ 완성
- 버그: 0건
- 진행도: 40% → 45%
- 주석: ...
```

### 2️⃣ Git Workflow 확정

**Day 8:**
```bash
# Commit 메시지 형식:
# Day 11: Player model + 5 animations
# - Add PlayerMale_v1 model (12k polygons)
# - Add animations: Idle, Walk, Run, Attack, Evade
# - Godot import successful
# - No errors, 60 FPS stable
# Progress: 40% → 45%

# Branch 전략:
git checkout -b week3_4_graphics
# → Day 24에 main으로 merge
```

---

## ✅ Day 3-10 최종 체크리스트

### 📋 구성 항목 (우선순위순)

#### Day 3 (오늘) ⚡
- [ ] Python 모듈 설치 (`pip3 install trimesh numpy pillow`)
- [ ] Godot 4.6 확인
- [ ] Blender 확인
- [ ] 기본 구조 최종 확인 (Assets, Scripts, Scenes 폴더)

#### Day 4
- [ ] Sketchfab에서 플레이어 모델 1개 다운로드
- [ ] 저장 위치 확인 (Assets/Models/Characters/Base/)
- [ ] Blender에서 열기 (노드 확인)

#### Day 5
- [ ] Mixamo 계정 생성
- [ ] Rigify 활성화
- [ ] FBX 내보내기 설정 확인
- [ ] 테스트: 플레이어 모델 리깅 1회

#### Day 6
- [ ] Godot Import 설정 확인
- [ ] Test Scene 생성 (ModelImportTest.tscn)
- [ ] 더미 FBX 임포트 테스트
- [ ] 에러 확인

#### Day 7
- [ ] Blender Dope Sheet 연습 (간단한 애니메이션 만들기)
- [ ] FBX 내보내기 테스트
- [ ] Godot에서 애니메이션 재생 테스트
- [ ] Daily Log 템플릿 생성

#### Day 8
- [ ] Mixamo에서 애니메이션 3개 다운로드 & 테스트
- [ ] Blender-Godot 워크플로우 확정
- [ ] Git workflow 확정
- [ ] Day 11 최종 준비 확인

#### Day 9-10
- [ ] 모든 도구 최종 확인
- [ ] 리소스 다운로드 목록 정리
- [ ] Day 11 오전 9:00 시작 준비
- [ ] 마지막 에러 확인

---

## 🎯 Day 11 시작 조건 (체크리스트)

```
✅ Godot 4.6 정상 작동
✅ Blender 리깅 가능 확인
✅ Mixamo 애니메이션 다운로드 경로 준비
✅ Assets 폴더 구조 최종 확인
✅ Git 준비 완료 (branch week3_4_graphics)
✅ Daily Log 시스템 준비
✅ 에러 = 0

→ **Day 11 09:00 풀속도 시작!** ⚡
```

---

## 📊 진행도 추적

```
Day 3 (현재): 준비 0% → 20%
Day 4-5:      준비 20% → 40%
Day 6-7:      준비 40% → 60%
Day 8-9:      준비 60% → 80%
Day 10:       준비 80% → 100% ✅

Day 11:       개발 시작! (40% → 45% 목표)
```

---

## 🚀 최종 목표

**Day 11 09:00에 바로 시작 가능한 상태 만들기**

- ✅ 모든 도구 설치 & 확인
- ✅ 워크플로우 확정
- ✅ 리소스 다운로드 준비
- ✅ Godot 설정 완료
- ✅ 에러 0
- ✅ 문서 모두 준비

**준비 완료 시점: 2026-05-10 18:00**

**시작 시점: 2026-05-11 09:00** 🔥

---

**Status:** 🟡 Day 3 시작 (현재)  
**Target:** 🟢 Day 11 09:00 완벽 준비  
**Motto:** "에러 0, 완벽한 게임을 만든다!" ⚡
