# 🚀 DAY 11 (2026-05-11) 최종 킥오프 체크리스트

**목표:** Week 3-4 시작 — 모델링 & 애니메이션 본격화 (40% → 70%)  
**현재 상황:** Week 1-2 완료 (40%), 모든 도구 준비 완료 ✅  
**시간:** 2026-05-11 09:00 AM 시작

---

## ✅ 환경 확인 (사전)

### 도구 설치 상태 (2026-05-09 04:57 확인)
- [x] **Godot 4.6.2** ✅
- [x] **Blender 5.1.1** ✅
- [x] **Python 3.9.6** ✅
- [x] **Git** ✅

### 프로젝트 구조 (2026-05-09 04:57 확인)
```
NEXUS_Game/
├── Assets/                     [새로 생성됨]
│   ├── Models/
│   │   ├── Characters/         (Day 11부터 사용)
│   │   ├── Monsters/           (Day 12부터 사용)
│   │   └── Environments/       (Day 15-16부터 사용)
│   ├── Animations/             (Day 11부터 사용)
│   ├── Textures/               (Day 11부터 사용)
│   └── Audio/                  (Day 17부터 사용)
├── Scripts/                    (기존 완료됨)
├── Scenes/                     (기존 완료됨)
├── Data/                       (기존 완료됨)
└── tools/                      (자동화 스크립트 추가됨)
    ├── blender_export.py       [새로 생성됨]
    ├── model_import.py         [새로 생성됨]
    └── resource_manager.py     [새로 생성됨]
```

---

## 🎯 DAY 11 실행 계획

### 09:00 - 프로젝트 준비 (30분)
```bash
cd ~/.openclaw/workspace/NEXUS_Game

# 1. Git 상태 확인
git status
git log --oneline -5

# 2. 리소스 카탈로그 생성
python3 tools/resource_manager.py .

# 3. Assets 폴더 최종 확인
ls -la Assets/
```

**체크포인트:** ✅ 프로젝트 구조 완벽

---

### 09:30 - Sketchfab에서 모델 다운로드 (30분)

**필요한 것:**
- 기본 인간형 캐릭터 1개 (로우폴리 또는 미드폴리)
- 무술 게임 스타일 (데빌메이크라이, 바퀴벨 같은)
- **라이센스:** CC0 또는 CC-BY (상용 사용 가능)

**추천 사이트:**
1. **Sketchfab** (무료): https://sketchfab.com
   - 검색: "humanoid character" + "gameready"
   - 필터: CC0, CC-BY
   
2. **OpenGameArt** (무료): https://opengameart.org
   - 더 게임 친화적
   
3. **CGTrader** (유료): https://www.cgtrader.com
   - 고품질 모델 (필요시)

**다운로드 형식:**
- `.fbx` (권장) — Godot 최적화됨
- `.blend` (OK) — 직접 수정 가능
- `.gltf` (OK) — 웹 표준

**다운로드 위치:**
```
Assets/Models/Characters/
└── Player_v1.fbx  (또는 .blend)
```

**체크포인트:** ✅ 모델 1개 다운로드 완료

---

### 10:00 - Blender 준비 (30분)

```bash
# 1. Blender 열기
blender

# 2. 다운로드한 모델 열기
#    File > Open > Assets/Models/Characters/Player_v1.fbx

# 3. Rigify 애드온 설치 (스켈톤 자동 생성)
#    Edit > Preferences > Add-ons > Search "Rigify" > Enable

# 4. 모델 검토
#    - 스케일 확인 (2m 키 기준)
#    - 재질 확인
#    - 본(bones) 확인 (있으면 좋음)
```

**체크포인트:** ✅ Blender 셋업 완료

---

### 10:30 - 기본 애니메이션 생성 (1시간)

#### 애니메이션 5가지 만들기:

**1. Idle (대기, 3-5초)**
- 캐릭터가 서있는 상태
- 약간의 호흡 움직임 정도

**2. Walk (보행, 1.2초 루프)**
- 정상 속도로 앞으로 걷기
- 팔과 다리 자연스럽게

**3. Run (달리기, 0.6초 루프)**
- Walk보다 빠르고 역동적
- 몸이 약간 굽어짐

**4. Attack (기본 공격, 0.8초)**
- 펀치 또는 킥
- 명확한 시작 → 중간 → 종료

**5. Damaged (피격, 0.5초)**
- 뒤로 살짝 밀려남
- 짧은 경직 표현

**Blender에서 애니메이션 만드는 방법:**
1. Shapekeys 또는 Armature 본 조작
2. 타임라인에서 키프레임 삽입
3. 각 애니메이션 Action으로 저장

**단순화 팁:**
- 복잡한 애니메이션 X
- 기본 동작만 먼저 O
- Mixamo 추천: https://www.mixamo.com
  - 무료 애니메이션 자동 생성
  - Blender에서 직접 임포트 가능

**체크포인트:** ✅ 애니메이션 5개 완성

---

### 11:30 - FBX 내보내기 & 자동화 (30분)

```bash
# 1. Blender에서 FBX로 내보내기
#    File > Export > Filmbox (.fbx)
#    설정:
#    - Animation: ON
#    - Deformed Mesh: ON
#    - NLA Strips: ON (여러 애니메이션 사용시)

# 2. 다음 경로에 저장
#    Assets/Models/Characters/Player_v1.fbx

# 3. Python 스크립트로 확인
python3 tools/model_import.py Assets/Models/Characters/Player_v1.fbx character
```

**체크포인트:** ✅ FBX 내보내기 완료

---

### 12:00 - Godot 임포트 & 테스트 (30분)

```bash
# 1. Godot 에디터 열기
godot

# 2. NEXUS_Game 프로젝트 열기
#    File > Open Project

# 3. Assets/Models/Characters/Player_v1.fbx를 Scenes/로 드래그
#    (자동 임포트 대기, 1-2분)

# 4. 새 씬 생성
#    File > New Scene > Node3D (이름: TestCharacter)

# 5. Player_v1 인스턴스 추가
#    인스턴스 생성 > Assets/Models/.../Player_v1.fbx

# 6. AnimationPlayer 노드 찾기
#    Player_v1 > AnimationPlayer 확인

# 7. 애니메이션 재생 테스트 (Console)
#    $AnimationPlayer.play("Idle")
#    $AnimationPlayer.play("Walk")
```

**체크포인트:** ✅ Godot 임포트 & 재생 확인

---

### 12:30 - 첫 번째 Git 커밋 (15분)

```bash
cd ~/.openclaw/workspace/NEXUS_Game

# 1. 변경사항 확인
git status

# 2. Assets 추가 (LFS 권장 — 용량 큼)
git add Assets/
git add tools/

# 3. 커밋
git commit -m "Day 11: Week 3 시작 - 플레이어 모델 + 기본 애니메이션 5개"

# 4. 로그 확인
git log --oneline -1
```

**체크포인트:** ✅ Git 커밋 완료

---

### 13:00 - 일일 로그 & 진행도 업데이트

**작성:** `/Users/hwangjeyeong/.openclaw/workspace/DAY11_COMPLETION_LOG.md`

내용:
```markdown
# Day 11 (2026-05-11) 완료 로그

## 성과 ✅
- [x] 플레이어 모델 1개 다운로드 완료
- [x] Blender 애니메이션 5개 생성 완료
- [x] FBX 내보내기 완료
- [x] Godot 임포트 & 재생 테스트 완료
- [x] Git 커밋 완료

## 통계 📊
- 모델: 1개
- 애니메이션: 5개
- FBX 용량: XX MB
- 버그: 0건 ✅
- 시간: 약 4시간

## 진행도 🎯
**40% → 45%** (Week 1-2 완료 + 모델링 시작)

## 다음 Day 12 계획 📅
- [ ] 전투 애니메이션 7개 추가
- [ ] 몬스터 모델 1개 다운로드
- [ ] Blender 애니메이션 생성

## 메모 📝
- Mixamo 정말 좋음! 고민하지 말고 사용할 것
- Blender Rigify 스켈레톤 자동 생성 매우 유용
- FBX 임포트시 메시 자동 인식 완벽
```

---

## 🛠️ 자동화 도구 가이드

### 1️⃣ blender_export.py
```bash
# Blender 파일을 FBX로 자동 변환
blender model.blend -P tools/blender_export.py
```

### 2️⃣ model_import.py
```bash
# FBX 임포트 설정 생성 & GDScript 템플릿 생성
python3 tools/model_import.py Assets/Models/Characters/Player_v1.fbx character
```

### 3️⃣ resource_manager.py
```bash
# 전체 리소스 카탈로그 생성 & 상태 확인
python3 tools/resource_manager.py .
```

---

## 📝 주의사항 ⚠️

### 라이센스 확인 필수!
- 다운로드 모델의 라이센스 확인
- CC0 또는 CC-BY만 사용 (상용 OK)
- 라이센스 정보 저장 (법적 문제 방지)

### 모델 스케일 확인
- Godot의 기본 단위: 미터 (m)
- 캐릭터 키: 약 1.8-2.0m
- Blender에서 스케일 조정: S키 + Z축

### 파일 크기 주의
- Assets 폴더가 커질 것 → Git LFS 사용 권장
- 각 모델: 5-50 MB
- Week 3-4 종료시: ~500-1000 MB

### Godot 임포트 대기
- FBX 첫 임포트: 1-2분 대기
- 큰 모델은 더 오래 걸림
- Godot이 먹통처럼 보일 수 있음 (정상)

---

## 🚨 문제 발생시

### 문제: Blender에서 모델이 안 보임
- 해결: Numpad 0 또는 카메라 뷰 조정
- 또는: 모델 스케일이 매우 크거나 작음

### 문제: FBX 임포트후 애니메이션 안 보임
- 해결: AnimationPlayer 노드 확인
- 또는: FBX 내보내기시 "Animation" 옵션 ON 확인

### 문제: Godot이 응답 없음 (Frozen)
- 해결: 기다리기 (임포트 진행 중)
- 또는: 작은 모델부터 테스트

### 문제: 애니메이션이 끊김
- 해결: Blender에서 키프레임 확인
- 또는: Mixamo 사용 (안정적)

---

## ✨ 성공 조건

Day 11 끝날 때 다음이 모두 완료되어야 함:

- [ ] 플레이어 모델 1개 Godot에서 표시됨
- [ ] 애니메이션 5개 재생 가능
- [ ] 오류 0건
- [ ] Git 커밋 완료
- [ ] Daily log 작성

**진행도:** 40% → 45% ✅

---

## 🎯 향후 스케줄 (Week 3-4)

| Day | 목표 | 산출물 |
|-----|------|--------|
| **11** | 플레이어 모델 + 애니메이션 5개 | ✅ 완료 |
| **12** | 전투 애니메이션 7개 + 몬스터 1개 | Anim 12 |
| **13-14** | 몬스터 3개 + 애니메이션 24개 | Anim 36 |
| **15-16** | 환경 + 중원 완성 | Env 10 |
| **17-18** | 보스 + 애니메이션 20개 | Anim 56 |
| **19-24** | Week 4 — 콘텐츠 확장 | 65% → 70% |

---

## 💡 팁 & 트릭

### 시간 절약 팁
1. **Mixamo 사용** — 애니메이션 자동 생성 (10분에 30개 생성 가능)
2. **Python 스크립트** — 반복 작업 자동화
3. **Batch 작업** — 여러 모델 동시 처리
4. **Git LFS** — 대용량 파일 효율 관리

### 품질 팁
1. 애니메이션은 짧게 (0.5-2초)
2. 루프 애니메이션은 첫/마지막 프레임 같아야 함
3. 키프레임은 촘촘하게 (30fps 기준 초당 30프레임)

### 협업 팁
1. 모델링팀: Blender 작업 (assets/export)
2. 애니메이션팀: 애니메이션 추가
3. 프로그래머팀: Godot 통합 & 테스트
4. 일일 Git 커밋으로 동기화

---

## 📞 문의 & 지원

**자동화 도구:**
- `python3 tools/resource_manager.py .` — 현재 상태 확인
- `python3 tools/model_import.py --help` — 도움말

**커뮤니티:**
- Blender: https://blender.stackexchange.com
- Godot: https://godotengine.org/community
- 모델: Sketchfab/OpenGameArt 커뮤니티

---

## 🔥 최종 점검 (DAY 11 시작 전)

- [ ] 모든 도구 설치 확인
- [ ] Assets 폴더 구조 생성됨
- [ ] 자동화 스크립트 3개 준비됨
- [ ] Sketchfab/OpenGameArt 계정 준비 (선택)
- [ ] Blender 기본 사용법 숙지
- [ ] 일정표 확인 (09:00 시작)

**준비 완료? → GO! 🚀**

---

**Version:** 1.0 Final  
**Created:** 2026-05-09 04:57  
**Status:** ✅ **DAY 11 준비 완료!**

**황제영, 새벽 4시 56분부터 준비 시작해서 오전 9시 킥오프 준비 완료! ⚡**
