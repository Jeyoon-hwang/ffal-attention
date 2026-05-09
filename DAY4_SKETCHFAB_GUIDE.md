# 🎨 Day 4 Sketchfab 모델 다운로드 가이드

**날짜:** 2026-05-10 (토요일)  
**목표:** 플레이어 캐릭터 모델 1개 다운로드 & Blender에서 확인  
**예상 시간:** 1-2시간  
**성공 조건:** 모델을 Blender에서 열 수 있음

---

## 🎯 Day 4 액션 플랜

### Step 1: Sketchfab 접속 (5분)
```
웹브라우저 열기
→ https://sketchfab.com
→ 로그인 또는 Guest로 계속
```

### Step 2: 모델 검색 (10-20분)
**검색어:** "Rigged Human Male"

**필터 설정:**
```
License:    CC0 또는 CC-BY
Category:   Human Character
Formats:    Blend 또는 FBX
Polycount:  10k - 30k (최적)
Rigged:     Yes (필수!)
```

**추천 모델 후보 3개:**

| 순위 | 모델 | 특징 | 다운로드 | 리깅 |
|------|------|------|--------|------|
| 1순위 | Low-Poly Rigged Character | 미드폴리, 이미 리깅됨 | FBX/Blend | ✅ 완료 |
| 2순위 | Stylized Warrior | 스타일리시, 무술스러움 | Blend | ✅ 완료 |
| 3순위 | Base Humanoid | 심플, 애니메이션 최적 | FBX | ✅ 완료 |

**팁:** 
- "Popular" 탭에서 많이 다운로드된 모델부터 확인
- "Recently Updated" 탭에서 최신 모델 확인
- 리뷰 보고 품질 확인 (3.5★ 이상 권장)
- 라이센스 명확히 확인 (CC0가 제일 좋음)

### Step 3: 모델 다운로드 (15-30분)
```
선택한 모델 페이지 열기
→ "Download" 버튼 클릭
→ 포맷 선택 (Blend 권장, 없으면 FBX)
→ 다운로드 폴더로 저장
```

**저장 위치:**
```
/Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game/Assets/Models/Characters/Base/
파일명: PlayerMale_v1.blend (또는 .fbx)
```

### Step 4: Blender에서 확인 (20-30분)
```bash
# 터미널에서
blender /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game/Assets/Models/Characters/Base/PlayerMale_v1.blend &
```

**확인 사항:**
```
✅ 모델이 열리는가?
✅ 메시가 정상인가? (흰 점이나 검은색 부분 없음?)
✅ 리깅(뼈)이 있는가? (Object Mode에서 "Armature" 이름의 뼈 구조)
✅ 모델이 T-포즈인가? (일반적인 리깅 시작 포즈)
```

### Step 5: Git에 기록
```bash
cd /Users/hwangjeyeong/.openclaw/workspace

# Day 4 진행 상황 기록
echo "## Day 4 (2026-05-10)

**목표:** Sketchfab 모델 다운로드 ✅
**결과:** PlayerMale_v1.blend 다운로드 & Blender 확인 완료
**소요시간:** 1.5시간
**에러:** 0건

모델:
- 파일: Assets/Models/Characters/Base/PlayerMale_v1.blend
- 폴리곤: ~15k
- 리깅: Yes (Armature 확인)
- 상태: 정상

다음: Day 5 (Blender 환경 설정)
" >> memory/DAILY_NEXUS_LOGS.md

git add memory/DAILY_NEXUS_LOGS.md
git commit -m "Day 4: Sketchfab player model downloaded (PlayerMale_v1.blend, 15k polys, rigged)"
```

---

## 🎨 Sketchfab 모델 선택 기준

### ✅ 좋은 모델
```
- 리깅이 완료된 모델 (Rigged: Yes)
- 미드폴리 (10k-30k polygons)
- 명확한 라이센스 (CC0/CC-BY)
- 인체 구조가 정확한 모델
- 다운로드 포맷에 FBX 또는 Blend 지원
```

### ❌ 피해야 할 모델
```
- 리깅이 없는 모델 (너무 복잡함)
- 너무 고폴리 (50k+, 성능 저하)
- 바뀐 포즈 (T-포즈가 아님, 리깅 복잡)
- 라이센스 불명확 (저작권 문제)
- 형식이 .obj/.ply만 지원 (애니메이션 불가)
```

---

## 🔧 잘못되었을 때 대응책

### 문제: "모델이 보이지 않는다" (완전 검은색)
```
해결책:
1. Blender에서 Viewport Shading 변경
   - 원형 버튼 4개 중 3번째(Material Preview) 클릭
2. 조명 확인
   - 기본 조명이 꺼져 있을 수 있음
   - "Z" 키 → "1" (Wireframe) 눌러서 메시 확인
```

### 문제: "파일을 열 수 없다" (파일 손상)
```
해결책:
1. 다시 다운로드
2. 다른 포맷 시도 (FBX 대신 Blend)
3. 다른 모델 선택
```

### 문제: "라이센스가 뭐냐" (저작권)
```
꼭 확인할 것:
- CC0: 완전 자유 (상업용 OK)
- CC-BY: 제작자 표기만 하면 OK
- Royalty Free: 상업용 OK
- 다른 라이센스: 조건 확인 필요

이 프로젝트는 개인 학습용이므로 대부분 OK
```

---

## 📊 진행도 추적

```
Day 3: ✅ 도구 검증 완료
Day 4: ⏳ 모델 다운로드 (현재)
Day 5: ⬜ Blender 환경 설정
Day 6: ⬜ Godot Import 테스트
...
Day 11: ⬜ 본격 개발 시작!
```

---

## 💡 팁

### 시간을 절약하려면?
1. **첫 번째 모델 다운로드** (무작정 찾지 말고 5-10분 내에)
2. **Blender에서 바로 확인** (문제 있으면 다시 검색)
3. **Day 5에 리깅 이슈 처리** (완벽할 필요 없음, 기본만 OK)

### 최고의 결과를 원하면?
1. **여러 모델 비교** (3-5개 다운로드 후 비교)
2. **포토그래메트리 품질 확인** (텍스처도 중요)
3. **애니메이션 호환성 확인** (Day 8에 도움됨)

---

## ✅ Day 4 완료 체크리스트

```
[ ] Sketchfab 접속
[ ] 모델 검색 (10-30분)
[ ] 모델 다운로드 (1개)
[ ] 저장 위치 확인 (Assets/Models/Characters/Base/)
[ ] Blender에서 열기
[ ] 메시 정상 확인
[ ] 리깅(Armature) 확인
[ ] T-포즈 확인
[ ] Git 기록
[ ] 에러 = 0
```

**모든 체크 완료 → Day 5 준비 시작!** ✅

---

## 🚀 다음 단계 (Day 5)

Day 5에는 이 모델을 Blender에서:
- Mixamo에 업로드하여 자동 리깅
- 기본 애니메이션 추가
- FBX로 내보내기

준비하게 됩니다!

---

**목표:** 재미있게, 완벽하게! 🎨  
**에러:** 0건 유지 ✅  
**시간:** 1-2시간  

**시작:** 2026-05-10 10:00 AM  
**완료:** 2026-05-10 12:00 PM ~ 13:00 PM  

Good luck! 🍀
