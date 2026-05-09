# 🎯 Day 5 Mixamo 워크플로우

**날짜:** 2026-05-09  
**목표:** PlayerMale_v1.blend → Mixamo 자동 리깅 → 애니메이션 3개 다운로드  
**에러 목표:** 0건  

---

## Phase 1: Mixamo 자동 리깅 (1.5시간)

### Step 1: Blender에서 모델 준비 (15분)
```
✅ PlayerMale_v1.blend 열기
✅ 스케일 확인 (목표: 1.8m 인간형)
✅ 리깅 제거 (기존 Armature 삭제)
✅ FBX로 내보내기 (Mixamo용)
   - 포맷: FBX ASCII
   - 포함: Mesh only (뼈 X)
   - 스케일: 1.0
```

### Step 2: Mixamo 자동 리깅 업로드 (30분)
```
⏳ Mixamo 접속 (https://www.mixamo.com)
⏳ 로그인 (Adobe 계정)
⏳ Upload Model
   - PlayerMale_v1_for_mixamo.fbx 선택
   - 스켈레톤: Human (기본)
   - 리깅: 자동 (Standard Rig)
⏳ 리깅 결과 확인
   - 뼈 개수: 65개 (Mixamo Standard)
   - 애니메이션 호환성: ✅
```

### Step 3: 기본 애니메이션 3개 다운로드 (1시간)
```
애니메이션 1: Idle (대기)
   - 검색: "Idle"
   - 선택: "Idle (Standing, Relaxed)"
   - 포맷: FBX (Generic)
   - 프레임: 모두 포함
   - 다운로드: PlayerMale_Idle.fbx

애니메이션 2: Walk (걷기)
   - 검색: "Walk"
   - 선택: "Walking Forward"
   - 포맷: FBX (Generic)
   - 다운로드: PlayerMale_Walk.fbx

애니메이션 3: Run (달리기)
   - 검색: "Run"
   - 선택: "Running Forward"
   - 포맷: FBX (Generic)
   - 다운로드: PlayerMale_Run.fbx

⏳ 모두 다운로드 (약 1시간)
```

---

## Phase 2: Blender 통합 (1시간)

### Step 1: 베이스 모델 업데이트 (15분)
```
✅ PlayerMale_v1_mixamo.fbx 임포트
✅ Mixamo Armature 확인 (65개 뼈)
✅ 메시 연결 확인
✅ T-포즈 리셋 확인
✅ 저장: PlayerMale_v1_rigged.blend
```

### Step 2: 애니메이션 베이크 (45분)
```
✅ PlayerMale_Idle.fbx 임포트 → Idle 액션 베이크
✅ PlayerMale_Walk.fbx 임포트 → Walk 액션 베이크
✅ PlayerMale_Run.fbx 임포트 → Run 액션 베이크

각 애니메이션:
  - NLA 에디터에서 확인
  - 루프 여부 확인 (Idle: 반복, Walk/Run: 반복)
  - 프레임 범위 기록
```

### Step 3: 통합 FBX 내보내기 (15분)
```
✅ Blender에서 최종 FBX 내보내기
   - 포맷: FBX 2020 (Godot 호환)
   - 포함: Mesh + Armature + All Actions
   - 애니메이션: 모두 포함
   - 파일명: PlayerMale_v1_final.fbx

확인:
   - 파일 크기: 예상 500KB ~ 2MB
   - 메시 정상: ✅
   - 뼈 정상: ✅
   - 애니메이션 정상: ✅
```

---

## Phase 3: Godot 임포트 & 테스트 (1시간)

### Step 1: Godot 임포트 설정 (15분)
```
✅ Godot 프로젝트 열기 (NEXUS_Game)
✅ Assets/Models/Characters/ 확인
✅ PlayerMale_v1_final.fbx 드래그 & 드롭
✅ 임포트 설정 팝업:
   - Root Type: Humanoid (중요!)
   - Root Name: root
   - 애니메이션 임포트: 활성화
   - Anim FPS: 24
✅ Import 클릭
```

### Step 2: 씬 생성 & 테스트 (30분)
```
✅ 테스트 씬: player_test_v1.tscn
   - AnimatedCharacter3D 추가
   - PlayerMale_v1_final.fbx 연결
   - 기본 애니메이션: "Idle"

✅ 스크립트: player_animator.gd
   - idle() → Idle 재생
   - walk() → Walk 재생
   - run() → Run 재생
   - 입력: W=Walk, Shift+W=Run, 기본=Idle

✅ 테스트 플레이:
   - W: Walk 재생 ✅
   - Shift+W: Run 재생 ✅
   - 아무것도 없음: Idle 재생 ✅
```

### Step 3: 최종 검증 (15분)
```
✅ 에러 로그: 0건
✅ 애니메이션 부드러움: 정상
✅ 부족한 부분: 기록
✅ Git 커밋: "Day 5: Add Mixamo rigging and animations"
```

---

## 📊 성공 지표

| 항목 | 예상 | 결과 | 상태 |
|------|------|------|------|
| 자동 리깅 | 65개 뼈 | 🔄 진행 중 | - |
| 애니메이션 3개 | Idle/Walk/Run | 🔄 진행 중 | - |
| Godot 테스트 | 모두 정상 | 🔄 진행 중 | - |
| 에러 | 0건 | 🔄 진행 중 | - |

---

## ⚡ 주의사항

```
1. Mixamo 로그인 필요 (Adobe 계정)
2. 애니메이션 다운로드 대기 시간 예상 (1-2분/개)
3. FBX 포맷 통일 (Godot 호환성)
4. 보간 확인 (Blender → Godot 이동)
```

---

## 🎯 다음 타겟 (Day 6)

```
목표: Godot에서 실제 플레이어 애니메이션 시스템 완성
  - Input 처리 (WASD → Idle/Walk/Run)
  - 카메라 좌우 (마우스)
  - 점프 애니메이션 추가
  - 공격 애니메이션 추가 (3가지)

진행도: 40% → 50%
에러: 0건 유지
```

---

**작성:** 천재 ⚡  
**시간:** 2026-05-09 11:56 AM  
**다음 업데이트:** Day 5 완료 후  
