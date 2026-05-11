# 🥋 NEXUS 프로젝트 로그 - 2026-05-11

## 📍 현재 상태

**프로젝트 시작:** 2026-05-07 (수)  
**현재 날짜:** 2026-05-11 (월) 11:56 AM Seoul  
**경과 시간:** 4일 2시간  
**목표 기한:** 2026-07-29 (12주)

## 📊 진행률

- 예상 Week 1 진행률: ~40% (Day 5/7)
- 실제 완성도: TBD (아직 초기화 안 함)
- 상태: **프로젝트 초기화 대기 중**

## 🎯 Week 1-2 핵심 목표

### Week 1 (Day 1-7)
- ❌ Day 1-2: 프로젝트 초기화
- ❌ Day 3-4: 무술 생성 엔진 (MartialArt 클래스)
- ⚠️ Day 5-6: 플레이어 전투 시스템 (Player 클래스)
- ⚠️ Day 7: 테스트 & 통합

### Week 2 (Day 8-14)
- ⬜ Day 8-9: 적 AI Level 1-2 (Enemy 클래스)
- ⬜ Day 10-11: 첫 보스 & 중원 프로토타입
- ⬜ Day 12-13: 무술관 & 강화 시스템
- ⬜ Day 14: 통합 테스트 & 플레이 검증

## 🔧 현재 작업

**Immediate Actions (Today, 2026-05-11):**
1. 프로젝트 디렉토리 구조 생성
2. Godot 프로젝트 초기화 또는 Three.js 프로젝트 시작
3. 엔진 선택 결정 (Godot vs Three.js)
4. Day 1-4 미완 항목 회수

## 💡 설계 문서 요약

### 기술 스택
- **엔진 후보:** Godot 4.2 (권장) 또는 Three.js
- **언어:** GDScript (Godot) 또는 JavaScript (Three.js)
- **타겟 플랫폼:** PC (Windows/Mac)
- **FPS 목표:** 60 FPS

### 무술 생성 엔진 (핵심)
```
MartialArt {
  baseMotion: 100가지 기본 동작 ID
  tempo: Fast/Mid/Slow
  defenseType: 회피/가드/상쇄/카운터 (각 5레벨)
  energyCost: 1-10
  hitbox: {range, damage}
  effects: [기절, 경직, 다운, 화염, 빙결 등]
}
```

### 전투 시스템
- 무술 슬롯: 5개 (기본 1 + 고급 4)
- 에너지: 최대 100 (CON 영향)
- 데미지: (STR × 파워 + DEX × 크리티컬) × 상성
- AI 4단계: 동물형 → 기초무술사 → 고급무술사 → 마스터

### 월드
- 5개 지역 (500m × 500m)
- 50-70개 던전
- 100+ NPC, 200+ 퀘스트
- 30-50시간 플레이타임

## 📝 다음 스텝 (우선순위)

1. **엔진 선택 & 초기화** (Today)
   - Godot vs Three.js 결정
   - 프로젝트 생성 & Git 초기화

2. **무술 엔진 설계** (Day 5-6)
   - MartialArt 데이터 구조 정의
   - 무술 생성 함수 구현

3. **플레이어 전투 시스템** (Day 5-7)
   - Player 클래스
   - 기본 공격 & 에너지 시스템

4. **적 AI 기초** (Week 2, Day 8-9)
   - Enemy 클래스
   - Level 1-2 AI

---

## 🚀 상태: 준비 완료, 개발 GO!
