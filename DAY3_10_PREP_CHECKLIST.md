# 🔧 Day 3-10 준비 체크리스트 (2026-05-09 ~ 2026-05-10)
## Week 3 시작을 위한 개발 환경 최종 준비

**작성일:** 2026-05-08  
**체크 날짜:** 2026-05-09 ~ 2026-05-10  
**상태:** 준비 시작  

---

## 📋 Day-by-Day 준비 항목

### **Day 3-4 (2026-05-09, 목요일 & 금요일) - 도구 & 환경 준비**

#### 개발 도구 준비
- [ ] **Blender 확인** (모델링)
  ```bash
  which blender
  blender --version
  ```
  - 설치 필요 시: https://www.blender.org/download/
  - 권장: 4.0 이상

- [ ] **Python 모듈 확인** (프로시저럴 생성)
  ```bash
  pip list | grep -i "trimesh\|numpy\|pillow"
  ```
  - 필요 시 설치:
    ```bash
    pip install trimesh numpy pillow
    ```

- [ ] **Godot 프로젝트 확인**
  ```bash
  cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev
  ls -la project.godot
  godot --version
  ```
  - Godot 4.2 이상 확인

#### Git 준비
- [ ] **저장소 상태 확인**
  ```bash
  cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev
  git status
  git log --oneline | head -5
  ```

- [ ] **Git 설정**
  ```bash
  git config user.name "천재"
  git config user.email "cheonjae@nexus.dev"
  ```

#### 디렉토리 구조 최종 확인
- [ ] **Assets 폴더 구조**
  ```
  Assets/
  ├── Models/
  │   ├── Characters/      (플레이어, NPC)
  │   ├── Enemies/         (몬스터)
  │   ├── Bosses/          (보스)
  │   └── Environment/     (환경 요소)
  ├── Animations/
  │   ├── Character/
  │   ├── Combat/
  │   └── Creatures/
  ├── Textures/
  ├── Audio/
  └── UI/
  ```

- [ ] 없는 폴더 생성
  ```bash
  mkdir -p Assets/Models/{Characters,Enemies,Bosses,Environment}
  mkdir -p Assets/Animations/{Character,Combat,Creatures}
  ```

---

### **Day 5-6 (2026-05-10, 토요일 & 일요일) - 리소스 및 스크립트 준비**

#### 모델 리소스 수집
- [ ] **Sketchfab에서 무료 모델 다운로드**
  - 검색: "human character game ready", "monster game ready"
  - 포맷: GLB/GLTF 우선
  - 라이센스: Creative Commons OK

  ```bash
  # fetch_sketchfab.py 실행 (필요 시)
  cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev
  python3 fetch_sketchfab.py
  ```

- [ ] **프로시저럴 생성 스크립트 준비**
  ```bash
  # 기존 스크립트 확인
  ls -la /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev/*.py
  ```

  주요 스크립트:
  - `generate_models.py` - 기본 모델 생성
  - `create_3d_models.py` - 고급 모델 생성
  - `gen_martial_arts.py` - 무술 애니메이션

#### 애니메이션 생성 도구 준비
- [ ] **Blender 애니메이션 스크립트 준비**
  ```bash
  # 기존 스크립트 확인 또는 새로 작성
  ls -la /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev/*animation*.py
  ls -la /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev/*anim*.sh
  ```

- [ ] **Godot 애니메이션 생성 스크립트 준비**
  ```bash
  cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev/Scripts/Animation
  ls -la generate_animations.py
  ```

---

### **Day 7-8 (준비 완료 점검 일) - Godot 프로젝트 최적화**

#### 스크립트 시스템 확인
- [ ] **CharacterModelBuilder.gd 확인**
  ```bash
  cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev
  grep -n "class_name\|func " Scripts/Graphics/CharacterModelBuilder.gd | head -20
  ```

- [ ] **AnimationController.gd 확인**
  ```bash
  grep -n "class_name\|func " Scripts/Graphics/AnimationController.gd | head -20
  ```

- [ ] **BossAnimationController.gd 확인** (있는지 확인, 없으면 Day 11에 생성)
  ```bash
  ls -la Scripts/Graphics/BossAnimationController.gd 2>/dev/null || echo "생성 필요"
  ```

#### 테스트 씬 준비
- [ ] **모델 테스트 씬 생성**
  ```
  Scenes/Test/
  ├── CharacterModelTest.tscn     (새로 생성)
  ├── AnimationTest.tscn          (새로 생성)
  └── BossAnimationTest.tscn      (새로 생성)
  ```

#### 데이터 구조 확인
- [ ] **애니메이션 메타데이터 구조**
  ```
  Data/
  ├── animations.json             (생성 또는 확인)
  └── animation_config.json       (생성 또는 확인)
  ```

  샘플 구조:
  ```json
  {
    "character": {
      "idle": {
        "frames": 30,
        "fps": 30,
        "loop": true,
        "duration": 1.0
      }
    },
    "monsters": {
      "wolf": {
        "walk": {...}
      }
    }
  }
  ```

---

### **Day 9-10 (최종 점검) - 워크플로우 및 문서**

#### 개발 워크플로우 정의
- [ ] **일일 개발 프로세스**
  1. Git pull (최신 코드 가져오기)
  2. 오늘 작업 항목 확인 (WEEK3_4_DETAILED_PLAN.md)
  3. 모델/애니메이션 개발
  4. Godot에서 테스트
  5. 버그 로깅
  6. Git add/commit/push
  7. 다음 날 준비

#### 성능 목표 설정
- [ ] **성능 기준선 측정**
  ```bash
  # Godot에서 FPS 측정 도구 활성화
  # Tools → Monitor (Ctrl+Alt+D)
  ```

  목표:
  - FPS: 60 이상
  - 메모리: 500MB 이하
  - 로딩 시간: 5초 이하

#### 문서 정리
- [ ] **Day 11 시작 가이드 문서 생성**
  - 모델 디자인 문서
  - 애니메이션 타이밍 문서
  - 색상 팔레트 정의

- [ ] **개발 로그 템플릿 생성**
  ```markdown
  # Day N 개발 로그
  
  **날짜:** 2026-05-XX
  **완료 항목:**
  - [ ] ...
  
  **문제 및 해결:**
  - ...
  
  **내일 계획:**
  - ...
  
  **버그 리스트:**
  - ...
  ```

---

## 🎨 모델 & 애니메이션 기초 작업

### 색상 팔레트 정의
```
주요 색상:
- 플레이어: 파란색 톤 (신뢰감)
- 몬스터: 빨강/검정 톤 (위협감)
- 보스: 금색/검정 톤 (강렬함)
- 환경: 녹색/갈색 톤 (자연)
- UI: 흰색/검은색 톤 (가독성)
```

### 모델 폴리곤 목표
```
- 플레이어: 2000-3000개
- 일반 몬스터: 1000-2000개
- 보스: 3000-5000개
- 환경: 500-1000개
- 목표: 총 50K 이하 (성능)
```

### 애니메이션 표준화
```
- 프레임 레이트: 30 FPS
- 루프 애니메이션: 부드럽게 (시작/끝 동일)
- 전환: 0.2초 (부드러운 변화)
- 음향: Day 19+ 추가
```

---

## 📊 리소스 체크리스트

### 필수 준비물
- [x] Godot 4.2+
- [x] Blender 또는 프로시저럴 생성 도구
- [x] Python 3.8+
- [x] Git
- [x] 텍스트 에디터 (VS Code)

### 권장 준비물
- [ ] Sketchfab 계정 (무료 모델 다운로드)
- [ ] Freesound.org 계정 (음향 효과)
- [ ] 모델 참조 이미지 수집
- [ ] 색상 팔레트 도구 (coolors.co)

---

## 🚀 Day 11 시작 체크리스트

### 월요일 (2026-05-11, Day 11) 아침 확인
- [ ] 모든 도구 설치 완료 확인
- [ ] NEXUS_Dev 프로젝트 열 수 있는지 확인
- [ ] Scripts/Graphics 폴더 구조 확인
- [ ] Assets/Models 폴더 준비 완료 확인
- [ ] 오늘 작업 항목 확인 (플레이어 모델 & 애니메이션)

### 시작 전 최종 점검
```bash
# 터미널 확인
cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS_Dev
git status                    # 깔끔한 상태 확인
godot --version              # Godot 4.2+ 확인
python3 -c "import trimesh"  # 필요한 모듈 확인

# Godot 실행
godot                         # 또는 godot . (프로젝트 폴더에서)
```

---

## 📝 추가 작업 항목

### 선택사항 (여유 있으면)
- [ ] 참조 이미지 및 컨셉 아트 수집
- [ ] 음향 효과 미리 수집 (Day 17+에 사용)
- [ ] 보스 디자인 스케치
- [ ] 지역 배경음악 선정

### 장기 계획 (Week 5+)
- [ ] 추가 모델링 기술 습득
- [ ] 애니메이션 최적화 기법 학습
- [ ] Godot 성능 최적화 심화

---

## 🎯 성공 기준

✅ **Day 10 종료 시점:**
- [ ] 모든 도구 설치 완료
- [ ] Godot 프로젝트 완벽하게 로드
- [ ] Assets 폴더 구조 정비 완료
- [ ] 개발 워크플로우 정의 완료
- [ ] Day 11 시작 준비 100% 완료
- [ ] 에러 0건

---

## 📞 도움말

### 문제 발생 시
```
Q: Blender/Godot 설치 문제?
A: 공식 사이트에서 다운로드 (링크는 아래)

Q: Python 모듈 설치 실패?
A: pip install --upgrade pip 후 재시도

Q: Git 설정 문제?
A: git config --global 사용 (사용자 전체)
```

### 리소스 링크
- Blender 다운로드: https://www.blender.org/download/
- Godot 다운로드: https://godotengine.org/download/
- Sketchfab 모델: https://sketchfab.com/
- 색상 도구: https://coolors.co/

---

**Version:** 1.0  
**Last Updated:** 2026-05-08  
**Next Step:** Day 3 시작 (2026-05-09)  
**Status:** 준비 목록 생성 완료 ✅

**모든 준비를 완료하고 Day 11 (2026-05-11)부터 본격 개발을 시작합니다!** 🚀

