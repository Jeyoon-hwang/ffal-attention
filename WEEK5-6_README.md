# 📚 Week 5-6 계획 문서 가이드

**프로젝트:** NEXUS 무술 창조 게임  
**페이즈:** Week 5-6 (Day 29-42)  
**목표:** 35% → 60% 달성  
**상태:** ✅ 모든 계획 문서 준비 완료

---

## 📖 문서 구조 (4개 파일)

### 1️⃣ WEEK5-6_EXECUTIVE_SUMMARY.md ⭐ **START HERE**
**파일 크기:** 13KB  
**읽는 시간:** 10분

#### 내용
```
✅ 현재 상태 평가 (Day 1-28 완료)
✅ Week 5-6 목표 & 타임라인
✅ 주요 산출물 요약
✅ 기술적 하이라이트 4가지
✅ 진행도 추적표
✅ 품질 메트릭
✅ 성공 기준
```

#### 언제 읽을까?
- **Week 5 시작 전** 전체 개요 파악
- **진행 중** 주간 목표 확인
- **사람들과 대화할 때** 진행도 설명

---

### 2️⃣ WEEK5-6_DETAILED_PLAN.md 📋 **CORE REFERENCE**
**파일 크기:** 39KB  
**읽는 시간:** 1시간 (전체) / 10분 (Day별)

#### 내용
```
Day 29-30: 지역 5개 완성 (Zone 2-5)
  └─ MountainTerrainGenerator, DesertTerrainGenerator 등
  
Day 31-32: 던전 생성 엔진 (BSP 알고리즘)
  └─ DungeonGenerator, DungeonSpawner 등
  
Day 33-34: NPC & 대화 시스템
  └─ 20명 NPC, 고급 대화 시스템
  
Day 35-36: 퀘스트 시스템 (200개)
  └─ QuestManager, 퀘스트 DB
  
Day 37-40: 무술, 장비, 경제 시스템
  └─ 150+ 무술, 50개 장비, 드롭 시스템
  
Day 41-42: 게임 밸런싱 & 완성
  └─ 전체 테스트, QA, 버그 픽스

+ JSON 파일 생성 계획 (20+명, 200+퀘, 50장비)
+ 매일 체크리스트 & 테스트 항목
```

#### 언제 읽을까?
- **매 Day 시작 전** 해당 Day 섹션 정독
- **구현 시작** 코드 구조 참고
- **테스트 시** 테스트 항목 확인

#### 사용법
```
# Day 29 시작할 때:
WEEK5-6_DETAILED_PLAN.md의 "Day 29-30" 섹션 읽기
  → "오전: Zone 2 지형 & 디자인" 부터 시작
  → MountainTerrainGenerator.gd 코드 참조
  → 테스트 체크리스트 확인

# Day 31 오후:
WEEK5-6_DETAILED_PLAN.md의 "Day 31" 오후 섹션
  → DungeonSpawner.gd 코드 복사해서 시작
  → 테스트 케이스 실행
```

---

### 3️⃣ WEEK5-6_TASK_BREAKDOWN.json ⏱️ **TIME TRACKING**
**파일 크기:** 19KB  
**읽는 시간:** 15분 (전체)

#### 내용 (JSON 포맷)
```json
{
  "day_29": {
    "theme": "Zone 2-5 지형 생성",
    "current_progress": "35%",
    "target_progress": "36%",
    "estimated_hours": 8,
    "tasks": [
      {
        "id": "task_29_1",
        "name": "천산 지형 생성",
        "lines_of_code": 110,
        "hours": 2,
        "outputs": ["Scripts/World/Zones/MountainTerrainGenerator.gd"]
      },
      ...
    ]
  },
  ...
}
```

#### 언제 읽을까?
- **주간 계획 수립** 시간 추정 확인
- **Day 중간 중간** 남은 시간 계산
- **느려지는 Day** 어디서 시간이 부족한지 확인
- **주말** 일주일 진행도 자동 추적

#### 기능
```
✅ Day별 시간 추정 (구체적)
✅ Task별 코드라인 수
✅ 의존성 표시
✅ 누적 진행도 계산
✅ Git 커밋 메시지 제시
```

---

### 4️⃣ WEEK5-6_IMPLEMENTATION_GUIDE.md 💻 **CODE REFERENCE**
**파일 크기:** 27KB  
**읽는 시간:** 30분 (관련 섹션만)

#### 내용
```
Day 29-30: 지역 완성
  → Procedural Terrain Generation (Perlin Noise)
  → 완전한 코드 예제
  
Day 31-32: 던전 시스템
  → BSP 알고리즘 상세 설명
  → 단계별 구현 코드
  
Day 33-34: NPC & 대화
  → NPC 데이터 구조 (JSON)
  → DialogueSystem 구현
  
Day 35-36: 퀘스트
  → 퀘스트 데이터베이스 구조
  → QuestManager 전체 코드
  
Day 37-40: 시스템들
  → 무술 조합 알고리즘
  → 장비 시스템
  → 드롭 & 경제 시스템
  
Day 41-42: 밸런싱
  → GameBalancer 클래스
  → 테스트 함수들
  → Assert 유틸리티
```

#### 언제 읽을까?
- **코드 작성 중** 구현 패턴 참고
- **알고리즘 이해** 흐름도 읽기
- **JSON 구조** 복사해서 사용
- **테스트 함수** 테스트 작성에 활용

#### 코드 복사 방법
```
1. 해당 섹션의 전체 코드 블록 선택
2. GDScript 파일로 복사
3. 클래스명, 함수명 맞춰서 수정
4. 그대로 사용 가능
```

---

## 🎯 빠른 시작 (5분)

### Step 1: 현재 상태 이해
```bash
# Read executive summary (5분)
cat WEEK5-6_EXECUTIVE_SUMMARY.md | head -100
```

### Step 2: 오늘의 일 확인
```bash
# Day 29라고 하면:
grep -A 30 "Day 29" WEEK5-6_DETAILED_PLAN.md
```

### Step 3: 시간 추정 확인
```bash
# JSON에서 해당 Day의 hours 확인
cat WEEK5-6_TASK_BREAKDOWN.json | grep -A 5 "day_29"
```

### Step 4: 코드 참고
```bash
# Implementation guide에서 알고리즘 학습
grep -A 50 "Day 29-30: 지역 완성" WEEK5-6_IMPLEMENTATION_GUIDE.md
```

---

## 📊 문서별 사용 시점

```
주간 시작
  ↓
1. EXECUTIVE_SUMMARY.md 읽기 (10분)
   → 주간 목표 & 진행도 파악
  ↓
매일 아침
  ↓
2. DETAILED_PLAN.md에서 오늘의 섹션 읽기 (10분)
   → 구체적인 Task 확인
  ↓
  ↓
3. TASK_BREAKDOWN.json에서 시간 확인 (2분)
   → 예상 시간 vs 실제 진행 비교
  ↓
코드 작성 중
  ↓
4. IMPLEMENTATION_GUIDE.md에서 코드 참고 (필요할 때)
   → 알고리즘 이해
   → 코드 템플릿 복사
  ↓
저녁
  ↓
5. 일일 로그 작성 (memory/2026-05-XX-*.md)
   → 오늘 무엇을 했는가
   → 내일 예상
```

---

## 🗂️ 파일 요약표

| 파일명 | 크기 | 포맷 | 목적 | 읽는 시간 |
|--------|------|------|------|----------|
| EXECUTIVE_SUMMARY | 13KB | Markdown | 전체 개요 | 10분 |
| DETAILED_PLAN | 39KB | Markdown | 구체적 가이드 | 1시간 |
| TASK_BREAKDOWN | 19KB | JSON | 시간 추정 | 15분 |
| IMPLEMENTATION_GUIDE | 27KB | Markdown | 코드 예제 | 30분 |

**총 98KB의 상세한 계획 문서**

---

## ✅ 사용 체크리스트

### Week 5 시작 전
```
☑️ WEEK5-6_EXECUTIVE_SUMMARY.md 읽기
☑️ WEEK5-6_DETAILED_PLAN.md Day 29-30 섹션 정독
☑️ WEEK5-6_TASK_BREAKDOWN.json에서 14일 일정 확인
☑️ WEEK5-6_IMPLEMENTATION_GUIDE.md 북마크
☑️ 첫 Task부터 시작
```

### 매일
```
☑️ 오전: DETAILED_PLAN.md 오전 섹션 읽기
☑️ 오후: IMPLEMENTATION_GUIDE.md 코드 참고
☑️ 저녁: 일일 로그 작성
☑️ 밤: TASK_BREAKDOWN.json으로 진행도 체크
```

### 막힐 때
```
☑️ IMPLEMENTATION_GUIDE.md 코드 예제 복사
☑️ DETAILED_PLAN.md 테스트 항목 확인
☑️ EXECUTIVE_SUMMARY.md 기술 설명 재읽기
```

---

## 🎯 문서와 파일의 관계

```
프로젝트 구조:
NEXUS_Game/
  ├─ Scripts/
  │  └─ (70 + 20 = 90개 파일 예정)
  │
  ├─ Data/
  │  ├─ NPCs/npc_database.json (20명)
  │  ├─ Quests/quest_database.json (200개)
  │  ├─ Equipment/equipment_database.json (50개)
  │  └─ Items/loot_tables.json
  │
  ├─ Docs/
  │  └─ (기존 GDD, ROADMAP 등)
  │
  └─ ...

계획 문서:
workspace/
  ├─ WEEK5-6_DETAILED_PLAN.md ← 각 파일을 만들라고 지시
  │  "Scripts/World/Zones/MountainTerrainGenerator.gd 생성"
  │  "Data/NPCs/npc_database.json 생성"
  │
  ├─ WEEK5-6_IMPLEMENTATION_GUIDE.md ← 코드를 어떻게 작성할지
  │  코드 예제 포함
  │
  ├─ WEEK5-6_TASK_BREAKDOWN.json ← 각 파일별 시간
  │  "MountainTerrainGenerator.gd: 2시간"
  │
  └─ WEEK5-6_EXECUTIVE_SUMMARY.md ← 큰 그림
     "Week 5-6의 목표는 콘텐츠 폭발"
```

---

## 💡 Best Practices

### 1. 일일 루틴
```
09:00 - DETAILED_PLAN.md 오전 섹션 읽기 (10분)
09:10 - 첫 Task 시작
12:00 - 점심, TASK_BREAKDOWN.json 확인 (5분)
13:00 - 오후 Task 시작
17:00 - 코딩 중단
17:00-18:00 - 테스트 & 디버깅
18:00-19:00 - IMPLEMENTATION_GUIDE.md로 검증
19:00-20:00 - 일일 로그 & Git 커밋
```

### 2. 막히는 경우
```
만약 Day 29 오전이 예상보다 길어진다면:

1. TASK_BREAKDOWN.json 확인
   → "estimated_hours": 2 (예상 2시간)
   → 실제: 3시간 경과
   
2. 선택:
   a) 계속 진행 (시간 초과)
   b) MVP만 구현 (기본 기능만)
   c) 폴리싱은 Day 42에 (품질은 나중)

3. DETAILED_PLAN.md의 "dependencies" 확인
   → Day 30이 Day 29에 의존하는가?
   → 의존하면 서둘러야 함
   → 독립적이면 품질 우선
```

### 3. 진행도 추적
```
# 자동 계산 방법:
# TASK_BREAKDOWN.json의 "target_progress" 사용

Day 29: 35% → 36%  (+1%)
Day 30: 36% → 38%  (+2%)
...
Day 42: 59% → 60%  (+1%)

리마크:
  • Week 5 마쳐지면: 50% (절반!)
  • Week 6 마쳐지면: 60% (목표 달성!)
```

---

## 🚀 Week 5 시작하기

### Day 29 첫 5분
```bash
# 1. 이 README 읽기
cat WEEK5-6_README.md

# 2. Executive Summary로 개요 파악
head -150 WEEK5-6_EXECUTIVE_SUMMARY.md

# 3. Day 29 상세 계획 읽기
grep -A 100 "Day 29-30" WEEK5-6_DETAILED_PLAN.md | head -80

# 4. Task 1 코드 보기
grep -A 50 "Task 1: 천산 지형 생성" WEEK5-6_IMPLEMENTATION_GUIDE.md
```

### Day 29 시작하기
```
1. MountainTerrainGenerator.gd 파일 생성
2. IMPLEMENTATION_GUIDE.md의 코드 복사
3. DETAILED_PLAN.md의 테스트 항목 확인
4. 09:00-11:00: 구현
5. 11:00-12:00: 기본 테스트
6. 14:00-16:00: 다음 Task (DesertTerrainGenerator)
7. 16:30-17:00: 환경 디테일
8. 18:00-20:00: 테스트, 커밋, 로그
```

---

## 🎓 FAQ

### Q: 어느 문서부터 읽어야 하나?
**A:** WEEK5-6_EXECUTIVE_SUMMARY.md부터 시작하세요.

### Q: 코드는 어디에?
**A:** WEEK5-6_IMPLEMENTATION_GUIDE.md에 완전한 코드 예제가 있습니다.

### Q: 시간 추정이 맞나?
**A:** TASK_BREAKDOWN.json의 estimated_hours를 참고하세요. 보수적 추정입니다.

### Q: 뒤처지면?
**A:** 
1. MVP만 구현 (기본 기능)
2. 폴리싱은 Day 41-42에
3. DETAILED_PLAN.md의 "dependencies" 확인

### Q: 일일 로그는?
**A:** memory/2026-05-13-NEXUS-WEEK5-DAY29.md 형식으로 작성하세요.

---

## 📈 진행도 대시보드

```
주차 시작: Day 29 (2026-05-13)
현재: ???
일주일 경과: Day 29-35

███░░░░░░░░░░░░░░░░░░░░░░░░░░░░  14%
├─ Week 5: Day 29-35 (50% 목표)
└─ Week 6: Day 36-42 (60% 목표)

목표 달성:
  Day 29: 35% → 36% ☐
  ...
  Day 42: 59% → 60% ☐
```

---

## ✨ 최종 정리

```
📄 4개의 계획 문서
💻 20개의 새로운 GDScript 파일
📊 5개의 JSON 데이터베이스
🎯 14일간의 상세한 일정
✅ 0개의 에러로 완성할 예정

준비 완료! 🚀
```

---

**생성일:** 2026-05-10  
**상태:** ✅ 모든 계획 완료, 실행 준비 완료  
**다음:** Day 29 시작!

**여기서부터 시작하세요. 문서가 모든 것을 안내합니다.** 📚⚡
