# 🚀 Week 3 준비 마스터 플랜 (Day 4-10, 2026-05-10~17)

**목표:** Day 11에 완벽한 상태로 본격 모델링 시작  
**기간:** 8일 (Day 4-10)  
**원칙:** 에러 0, 완벽한 준비  

---

## 📅 Day 4-10 타임라인

| Day | 날짜 | 요일 | 목표 | 소요 | 체크 |
|-----|------|------|------|------|------|
| 4 | 2026-05-10 | 토 | Sketchfab 모델 DL | 2시간 | ⬜ |
| 5 | 2026-05-11 | 일 | Blender 환경 | 3시간 | ⬜ |
| 6 | 2026-05-12 | 월 | Godot Import 테스트 | 2시간 | ⬜ |
| 7 | 2026-05-13 | 화 | Blender 애니메이션 | 3시간 | ⬜ |
| 8 | 2026-05-14 | 수 | Mixamo 통합 | 3시간 | ⬜ |
| 9 | 2026-05-15 | 목 | 검증 & 최적화 | 2시간 | ⬜ |
| 10 | 2026-05-16 | 금 | 최종 준비 | 1시간 | ⬜ |
| 11 | 2026-05-17 | 토 | 🚀 본격 개발 | 9시간 | 🎉 |

**총 소요:** 16-18시간 (8일)  
**일일 평균:** 2시간 (충분히 여유 있음)

---

## 🎯 Day 4: Sketchfab 모델 다운로드

### 📋 할 일
1. **Sketchfab.com 접속**
   - 검색: "Rigged Human Male"
   - 필터: CC0/CC-BY, 10k-30k polygons, Rigged: Yes

2. **모델 선택 (5-15분)**
   - 3개 후보 찾기
   - 라이센스 확인
   - 포맷 확인 (FBX/Blend)

3. **다운로드 (5분)**
   - 저장: `Assets/Models/Characters/Base/PlayerMale_v1.blend`
   - 확인: 파일 크기 정상? (10-50 MB)

4. **Blender에서 검증 (30분)**
   ```bash
   blender Assets/Models/Characters/Base/PlayerMale_v1.blend
   ```
   - ✅ 파일 열림?
   - ✅ 메시 정상?
   - ✅ Armature(뼈) 있음?
   - ✅ T-포즈?

### 📊 성공 기준
```
✅ 모델 1개 다운로드
✅ 저장 위치 확인
✅ Blender에서 열림
✅ 메시 & 리깅 정상
✅ Git 기록
✅ 에러 = 0
```

### 📚 참고
- **가이드:** DAY4_SKETCHFAB_GUIDE.md
- **시간:** 1-2시간
- **난이도:** ⭐ (매우 쉬움)

---

## 🔧 Day 5: Blender 환경 설정

### 📋 할 일
1. **Blender 기본 설정**
   - Edit → Preferences → Add-ons
   - 검색: "Rigify"
   - ✅ 활성화

2. **FBX 내보내기 설정 확인**
   - File → Export → FBX
   - 확인 사항:
     ```
     ✅ Animation: ON
     ✅ NLA Strips: ON
     ✅ All Actions: ON
     ✅ Deformed Mesh: ON
     ```

3. **Mixamo 계정 준비**
   - https://www.mixamo.com
   - Adobe ID로 무료 가입
   - 로그인 테스트

4. **테스트 리깅 (Day 4 모델)**
   - Blender에서 모델 열기
   - Mixamo에 업로드
   - 자동 리깅 확인 (5분)
   - FBX 다운로드

### 📊 성공 기준
```
✅ Rigify 활성화
✅ FBX 설정 확인
✅ Mixamo 계정 생성
✅ 테스트 리깅 성공
✅ 자동 리깅 작동 확인
✅ 에러 = 0
```

### 📚 참고
- **시간:** 2-3시간
- **난이도:** ⭐⭐ (쉬움)

---

## ✅ Day 6: Godot FBX 임포트 테스트

### 📋 할 일
1. **Godot 프로젝트 열기**
   ```bash
   cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Game
   godot --editor
   ```

2. **Import 설정 확인**
   - Project → Project Settings → Import → Scene → FBX
   - ✅ Meshes → Ensure Tangents: ON
   - ✅ Animation → Imports: ON
   - ✅ Animation → Bake All: ON

3. **Test Scene 생성**
   - Ctrl+N (새 씬)
   - Node → 3D Scene
   - Day 5에서 내보낸 FBX 드래그 & 드롭
   - Save As: `Scenes/Test/ModelImportTest.tscn`

4. **애니메이션 테스트**
   - 모델 선택
   - Inspector → Animation 섹션
   - ✅ 애니메이션 목록 보임?
   - ✅ 재생 가능?

### 📊 성공 기준
```
✅ FBX 임포트 설정 확인
✅ Test Scene 생성
✅ 모델 임포트 성공
✅ 애니메이션 재생 확인
✅ 에러 = 0
```

### 📚 참고
- **시간:** 1-2시간
- **난이도:** ⭐⭐ (쉬움)

---

## 🎬 Day 7: Blender 애니메이션 파이프라인

### 📋 할 일
1. **Blender Dope Sheet 연습**
   - Window → Toggle Dope Sheet
   - 간단한 애니메이션 생성 (예: Idle)
     ```
     Frame 0: T-Pose
     Frame 15: 약간 움직임
     Frame 30: 원래 포즈
     ```

2. **FBX 내보내기**
   - File → Export → FBX
   - 설정: Animation ON, All Actions ON
   - 저장: `Assets/Animations/Blender/Idle.fbx`

3. **Godot 임포트 & 테스트**
   - Godot에서 FBX 임포트
   - Test Scene에서 애니메이션 재생
   - ✅ 정상 작동?

### 📊 성공 기준
```
✅ Blender에서 애니메이션 생성
✅ FBX 내보내기 성공
✅ Godot 임포트 성공
✅ 애니메이션 재생 확인
✅ 에러 = 0
```

### 📚 참고
- **시간:** 2-3시간
- **난이도:** ⭐⭐⭐ (중간)

---

## 🌟 Day 8: Mixamo 애니메이션 통합

### 📋 할 일
1. **Mixamo에서 애니메이션 다운로드**
   - https://www.mixamo.com
   - 기본 캐릭터 또는 Day 5 모델 사용
   - 3개 애니메이션 다운로드 (FBX):
     ```
     1. Idle (대기, 30프레임)
     2. Walk (걷기, 60프레임)
     3. Run (달리기, 45프레임)
     ```
   - 저장: `Assets/Animations/Mixamo/`

2. **Blender에서 통합**
   - 플레이어 모델 열기
   - 각 FBX 애니메이션 임포트
   - NLA Editor에서 스택 구성
   - 최종 FBX 내보내기

3. **Godot 테스트**
   - 통합 FBX 임포트
   - Test Scene에서 3개 애니메이션 모두 재생
   - ✅ 모두 정상?

### 📊 성공 기준
```
✅ Mixamo 3개 애니메이션 DL
✅ Blender 통합 성공
✅ Godot 임포트 성공
✅ 3개 애니메이션 모두 재생
✅ 에러 = 0
```

### 📚 참고
- **시간:** 2-3시간
- **난이도:** ⭐⭐⭐ (중간)

---

## 🔍 Day 9: 검증 & 최적화

### 📋 할 일
1. **모든 도구 최종 확인**
   ```bash
   godot --version        # 4.6.2?
   blender --version      # 5.1.1?
   python3 --version      # 3.9.6?
   ```
   - ✅ 모두 정상?

2. **FBX 임포트/내보내기 워크플로우 검증**
   - Blender → FBX 내보내기 (정상?)
   - Godot에서 FBX 임포트 (정상?)
   - 애니메이션 재생 (정상?)

3. **Git 상태 확인**
   ```bash
   git status             # clean?
   git log --oneline      # 커밋 히스토리?
   ```

4. **Day 11-24 리소스 목록 준비**
   - 몬스터 5종 (Wolf, Bat, Skeleton, Goblin, Dragon)
   - 환경 10종 (Tree, Rock, Building, etc)
   - 보스 2종

### 📊 성공 기준
```
✅ 모든 도구 정상
✅ 워크플로우 검증 완료
✅ Git 준비 완료
✅ 리소스 목록 정리
✅ 에러 = 0
```

### 📚 참고
- **시간:** 1-2시간
- **난이도:** ⭐⭐ (쉬움)

---

## 🎯 Day 10: 최종 준비 & 킥오프 준비

### 📋 할 일
1. **모든 파일 최종 점검**
   - Assets/ 폴더 정리
   - Scripts/ 파일 정리
   - Scenes/ 폴더 정리
   - Docs/ 문서 정리

2. **Git Branch 생성**
   ```bash
   git checkout -b week3_4_graphics
   git push -u origin week3_4_graphics
   ```

3. **Daily Log 템플릿 최종화**
   - memory/DAILY_NEXUS_LOGS.md 생성
   - Day 11 포맷 확인

4. **Day 11 준비 확인**
   - [ ] Godot 4.6.2 실행 가능?
   - [ ] Blender 리깅 가능?
   - [ ] Python 모듈 설치?
   - [ ] Assets 폴더 완성?
   - [ ] Git branch 생성?
   - [ ] 에러 = 0?

### 📊 성공 기준
```
✅ 모든 파일 정리
✅ Git branch 생성
✅ Daily Log 준비
✅ Day 11 조건 확인
✅ 에러 = 0
✅ 모든 준비 완료!
```

### 📚 참고
- **시간:** 1시간
- **난이도:** ⭐ (매우 쉬움)

---

## 🎊 Day 11: 본격 개발 시작!

### 🎯 목표
**플레이어 모델 + 기본 애니메이션 5개 완성**

### ⏰ 스케줄
```
09:00 ~ 09:30 (30분) - 프로젝트 준비
09:30 ~ 10:00 (30분) - 플레이어 모델 최종 점검
10:00 ~ 10:30 (30분) - Blender 준비
10:30 ~ 11:30 (1시간) - 기본 애니메이션 5개
  - Idle (대기)
  - Walk (걷기)
  - Run (달리기)
  - Attack (공격)
  - Evade (회피)
11:30 ~ 12:00 (30분) - FBX 내보내기
12:00 ~ 13:00 (1시간) - Godot 임포트 & 테스트
13:00 ~ 14:00 (1시간) - Git 커밋 & 일일 로그
```

### 📊 예상 결과
```
✅ 플레이어 모델 확정
✅ 애니메이션 5개 완성
✅ Godot 임포트 성공
✅ 진행도: 40% → 45%
✅ 에러: 0건
```

---

## 📊 전체 진행도 추적

```
Day 3: ✅ 도구 검증 완료 (40%)
Day 4: ⏳ Sketchfab 모델 (40%)
Day 5: ⬜ Blender 환경 (40%)
Day 6: ⬜ Godot Import (40%)
Day 7: ⬜ 애니메이션 파이프라인 (40%)
Day 8: ⬜ Mixamo 통합 (40%)
Day 9: ⬜ 검증 & 최적화 (40%)
Day 10: ⬜ 최종 준비 (40%)
Day 11: 🚀 본격 개발 시작! (40% → 45%)

[████████░░░░░░░░░░░░░░░] 40%
```

---

## 🔑 핵심 원칙

### ✅ 반드시 지킬 것
1. **매일 Git 커밋**
   ```bash
   git add -A
   git commit -m "Day X: [작업 내용]"
   ```

2. **에러 = 0 원칙**
   - 버그 발견 시 즉시 수정
   - 완벽한 상태만 다음으로 진행

3. **Daily Log 작성**
   - 매일 밤 작업 내용 기록
   - 진행도, 시간, 이슈 기록

4. **하루 1-3시간만 집중**
   - 번아웃 방지
   - 높은 품질 유지

### 🚫 피해야 할 것
1. ❌ 불완전한 상태로 진행
2. ❌ 도구 설치 실패 무시
3. ❌ Git 커밋 건너뛰기
4. ❌ 문서 작성 안 함

---

## 📋 Day 4-10 최종 체크리스트

### Day 4 (모델 DL)
- [ ] Sketchfab 접속
- [ ] 모델 검색 & 선택
- [ ] FBX/Blend 다운로드
- [ ] Blender에서 확인
- [ ] Git 커밋

### Day 5 (Blender 환경)
- [ ] Rigify 활성화
- [ ] FBX 설정 확인
- [ ] Mixamo 계정 생성
- [ ] 테스트 리깅 완료
- [ ] Git 커밋

### Day 6 (Godot Import)
- [ ] Godot 프로젝트 열기
- [ ] Import 설정 확인
- [ ] Test Scene 생성
- [ ] FBX 임포트 테스트
- [ ] Git 커밋

### Day 7 (애니메이션)
- [ ] Blender Dope Sheet 사용
- [ ] 간단한 애니메이션 생성
- [ ] FBX 내보내기
- [ ] Godot에서 재생 테스트
- [ ] Git 커밋

### Day 8 (Mixamo 통합)
- [ ] Mixamo 3개 애니메이션 DL
- [ ] Blender 통합
- [ ] FBX 내보내기
- [ ] Godot 임포트 & 테스트
- [ ] Git 커밋

### Day 9 (검증)
- [ ] 모든 도구 확인
- [ ] 워크플로우 검증
- [ ] Git 상태 점검
- [ ] 리소스 목록 준비
- [ ] Git 커밋

### Day 10 (최종 준비)
- [ ] 파일 정리
- [ ] Git branch 생성
- [ ] Daily Log 준비
- [ ] Day 11 조건 확인
- [ ] Git 커밋

---

## 🚀 시작하기

```
지금: Day 3 (2026-05-09 준비 완료)
내일: Day 4 (2026-05-10 10:00 AM 시작)
목표: Day 11 (2026-05-17 09:00 AM 본격 개발)

1주일만 더! 완벽한 준비 → 완벽한 개발!
```

---

**상태:** 🟢 준비 완료  
**에러:** 0건  
**버그:** 0건  
**다음:** Day 4 (내일) Sketchfab 모델 다운로드  

**모토:** 에러 0, 완벽한 AAA급 게임 완성! ⚡

---

_작성: 2026-05-09 (Day 3)_  
_시작: 2026-05-10 (Day 4)_  
_킥오프: 2026-05-17 (Day 11)_
