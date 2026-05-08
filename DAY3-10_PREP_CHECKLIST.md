# 📋 NEXUS Day 3-10 준비 체크리스트
**기간:** 2026-05-08 ~ 2026-05-10 (3일)  
**목표:** Week 3 (Day 11) 풀속도 시작 준비  
**상태:** 진행 중 🔥

---

## ✅ 환경 확인 (Day 3)

### 1. 개발 도구 확인
- ✅ **Blender 5.1.1** - 설치됨
- ✅ **Godot 4.6.2** - 설치됨
- ✅ **Python 3.9.6** - 설치됨
- ✅ **trimesh, numpy** - 설치됨
- ⏳ **Git** - 확인 필요

### 2. Git 설정
```bash
# NEXUS_Dev 폴더 Git 상태 확인
cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev
git status
git log --oneline -5
```

**목표:** Git 히스토리 정리, Day 3-10 브랜치 생성

---

## 📦 리소스 수집 (Day 3-4)

### 1. Sketchfab 모델 수집
**목표:** 기본 모델 30개 수집

#### 플레이어 캐릭터
- [ ] 남성 캐릭터 기본 모델 (리깅 있는)
- [ ] 여성 캐릭터 기본 모델 (리깅 있는)
- [ ] NPC 모델 3-4개

#### 몬스터 (기본 5종)
- [ ] 늑대 모델
- [ ] 박쥐 모델
- [ ] 스켈레톤 모델
- [ ] 곰 모델
- [ ] 거인 모델

#### 보스
- [ ] 첫 보스 모델 (중원 던전)
- [ ] 2-3개 추가 보스 모델

#### 환경 (저폴리)
- [ ] 나무 모델 (5종 배리에이션)
- [ ] 바위/대지 모델 (3종)
- [ ] 건물/구조물 (3종)
- [ ] 부수 물체 (상자, 기둥, 문 등 10종)

**리소스:** Sketchfab, Turbosquid (Free), CGTrader

### 2. 참조 이미지 수집
- [ ] 무술 포즈 이미지 100+ (Pinterest, ArtStation)
- [ ] 캐릭터 디자인 참조 (5-10개 게임)
- [ ] 환경 컨셉 아트 (각 지역별 5-10개)
- [ ] 색상 팔레트 (지역별)

### 3. 애니메이션 프리셋 준비
- [ ] Mixamo 계정 확인 (또는 CMU 모션 캡처)
- [ ] 기본 애니메이션 50+ 다운로드
  - 대기 (Idle)
  - 이동 (Walk, Run)
  - 회피 (Dodge)
  - 공격 (Punch, Kick, Combo)

---

## 🛠️ 모델링 워크플로우 준비 (Day 4-5)

### 1. Blender 프로젝트 구성
```
NEXUS_Blender/
├── Characters/
│   ├── Player_Base.blend
│   ├── NPC_Models.blend
│   └── Monsters.blend
├── Animations/
│   ├── Combat_Anims.blend
│   ├── Movement_Anims.blend
│   └── NPC_Anims.blend
├── Environments/
│   ├── Region_Zhongyuan.blend
│   ├── Region_Tianshan.blend
│   ├── Region_Wasteland.blend
│   ├── Region_East_Sea.blend
│   └── Region_Dragon_Cave.blend
├── Props/
│   └── Props_Collection.blend
└── Textures/
    ├── Characters/
    ├── Environments/
    └── Props/
```

### 2. Blender 스크립트 준비
- [ ] FBX 익스포트 자동화 스크립트
- [ ] Rigify 리깅 자동화
- [ ] 애니메이션 베이킹 스크립트
- [ ] 텍스처 압축 스크립트

**참고:** `create_models_blender.blend.py` 확인

### 3. 텍스처 설정
- [ ] PBR 텍스처 워크플로우 (Albedo, Normal, Roughness, Metallic)
- [ ] 텍스처 라이브러리 구성 (Wood, Stone, Metal, Fabric 등)
- [ ] Substance Painter 또는 Marmoset 설정 (선택)

---

## 🎮 Godot 프로젝트 최적화 (Day 5-6)

### 1. Scripts 폴더 정리
```
Scripts/
├── Core/
│   ├── GameManager.gd
│   ├── Player.gd
│   ├── Enemy.gd
│   └── CombatSystem.gd
├── Graphics/
│   ├── Animator.gd
│   ├── ParticleManager.gd
│   └── LODManager.gd
├── AI/
│   ├── AIController.gd
│   ├── BehaviorTree.gd
│   └── PatternDetector.gd
├── Martial/
│   ├── MartialArtEngine.gd
│   ├── MartialArtUI.gd
│   └── SkillSystem.gd
└── Utils/
    ├── DataLoader.gd
    └── Logger.gd
```

- [ ] 기존 37개 스크립트 분류
- [ ] 병렬 로딩 최적화 (비동기)
- [ ] 메모리 풀 설정 (Enemy, Projectile 등)

### 2. Assets 폴더 최적화
```
Assets/
├── Models/          (FBX 모델들)
├── Animations/      (애니메이션 클립)
├── Textures/        (2K 최대)
├── Scenes/          (테스트 씬들)
└── Materials/       (Godot 머티리얼)
```

- [ ] 모델 임포트 설정 확인 (FBX 옵션)
- [ ] 텍스처 압축 설정 (VRAM 최적화)
- [ ] 대역폭 제한 설정 (로딩 속도)

### 3. 성능 기준선 측정
- [ ] 빈 씬 FPS 측정 (기준선)
- [ ] 플레이어 + 5 몬스터 FPS
- [ ] 플레이어 + 20 몬스터 FPS
- [ ] 메모리 사용량 측정

**목표:** 60 FPS 유지, 메모리 500MB 이하

### 4. 테스트 씬 생성
- [ ] Model_Test.tscn (모델 임포트 테스트)
- [ ] Animation_Test.tscn (애니메이션 재생 테스트)
- [ ] Performance_Test.tscn (성능 테스트)
- [ ] Lighting_Test.tscn (조명 테스트)

---

## 📚 문서 & 워크플로우 (Day 6-7)

### 1. 개발 프로세스 정의
- [ ] **일일 워크플로우**
  1. 모델링 (08:00-12:00)
  2. 점심시간
  3. 애니메이션 & 통합 (13:00-18:00)
  4. 테스트 & 버그 픽스 (18:00-20:00)

- [ ] **일주일 일정**
  - 월-금: 개발
  - 토: 플레이 테스트 + 밸런싱
  - 일: 문서 & 계획

### 2. 일일 로그 템플릿
```markdown
# 2026-05-11 (Day 11) - 개발 로그

## 오늘의 목표
- [ ] 플레이어 모델 리깅

## 완료한 것
- ✅ 모델 임포트

## 진행도
- 모델링: 50%

## 다음
- 애니메이션 추가

## 블로커/이슈
- 없음
```

- [ ] `memory/YYYY-MM-DD.md` 매일 작성
- [ ] 주간 리뷰 (매주 금요일)

### 3. 버그 트래킹
- [ ] GitHub Issues 또는 로컬 JSON 파일
- [ ] 버그 심각도 분류 (Critical, Major, Minor)
- [ ] 버그 픽스 우선순위 결정

### 4. 문서 준비
- [ ] **MODELING_GUIDE.md** - 모델 제작 가이드
- [ ] **ANIMATION_GUIDE.md** - 애니메이션 가이드
- [ ] **IMPORT_WORKFLOW.md** - Blender → Godot 워크플로우
- [ ] **OPTIMIZATION_NOTES.md** - 최적화 메모

---

## 🔍 리뷰 & 검증 (Day 8-10)

### 1. 기존 코드 리뷰
- [ ] Scripts/ 코드 품질 검토
- [ ] 메모리 누수 체크
- [ ] 성능 병목 지점 식별
- [ ] 리팩토링 필요 부분 마크

### 2. Godot 프로젝트 상태 확인
```bash
cd NEXUS_Dev
godot --version
# Scenes 확인
# Assets 임포트 상태
# 에러/경고 메시지 확인
```

- [ ] 컴파일 에러: 0
- [ ] 경고 메시지: 최소화
- [ ] 프로젝트 로드 시간 < 5초

### 3. 기획 문서 최종 확인
- [ ] GDD_OPTION2_FINAL.md 재검토
- [ ] ROADMAP_12WEEKS_TIGHT.md 업데이트
- [ ] Week 3 상세 계획 확인

### 4. 리소스 정리
- [ ] 수집한 모델 폴더 정리
- [ ] 참조 이미지 폴더 구성
- [ ] 애니메이션 프리셋 분류

---

## 🚀 Day 11 최종 점검 (Day 10 오후)

### 모든 것이 준비되었는가?
- [ ] 개발 환경: ✅
- [ ] 리소스: ✅
- [ ] Godot 프로젝트: ✅
- [ ] Blender 워크플로우: ✅
- [ ] 문서 & 계획: ✅

### Day 11 아침 체크리스트
```
☐ Godot 시작
☐ 첫 모델 임포트 테스트
☐ Blender 열기
☐ 커피/차 준비 ☕
☐ 집중 모드 ON
☐ "푸시하자!" 🚀
```

---

## 📊 진행도 추적

| 항목 | 예상 완료 | 상태 |
|------|---------|------|
| 환경 확인 | Day 3 | ⏳ |
| 리소스 수집 | Day 4-5 | ⏳ |
| 모델링 워크플로우 | Day 5-6 | ⏳ |
| Godot 최적화 | Day 6-7 | ⏳ |
| 문서 & 프로세스 | Day 7-8 | ⏳ |
| 리뷰 & 검증 | Day 8-10 | ⏳ |
| **Day 11 준비** | **Day 10 오후** | ⏳ |

---

## 🎯 Week 3 목표 (Day 11 시작)

```
Week 3 (Day 11-18)
40% → 60%

┌─────────────────────────────┐
│ 플레이어 모델 + 5개 애니메이션 │
│ 몬스터 3개 + 24개 애니메이션  │
│ 환경 10개 에셋               │
│ 보스 1개 + 20개 애니메이션    │
│ 총 56개 애니메이션 ✅        │
│                             │
│ 진행도: 40% → 60% 달성      │
└─────────────────────────────┘
```

---

## 📝 노트

**성공 전략:**
1. **병렬 작업** - 모델링 + 코딩 동시 진행
2. **점진적 확장** - 1개 모델 → 2개 → 3개
3. **매일 테스트** - 임포트한 즉시 Godot에서 확인
4. **에러 0 유지** - 버그는 즉시 수정

**주의사항:**
- 고폴리 모델은 피하기 (5k-10k 삼각형)
- 텍스처는 2K 이상 피하기 (VRAM 제약)
- FBX 익스포트 시 Armature/Rigging 확인
- LOD 설정은 나중에

---

**최종 목표:** Day 11 아침 9시, Godot과 Blender 동시에 열고 첫 모델을 로드한다! 🚀

**작성자:** 천재 ⚡  
**업데이트:** 2026-05-08 22:00  
**상태:** 준비 중
