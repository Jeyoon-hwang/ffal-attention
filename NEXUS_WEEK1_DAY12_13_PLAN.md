# Day 12-13 계획: 무술관 & NPC 완성

**날짜:** 2026-05-10 ~ 2026-05-11  
**목표:** 85% → 95% (+10%)  
**주제:** NPC 상세 구현 & 무술관 시스템  

---

## 🎯 Day 12-13 마일스톤

### Day 12: NPC 상세 시스템 & 무술관 구현

**목표:** Merchant, QuestGiver, Trainer NPC 완성

#### 12-1. MartialArtsSchool.gd (무술관 시스템)
```gdscript
class_name MartialArtsSchool

# 무술관 정보
- name: 중원 무술관
- master: 은사 NPC
- disciples: 제자 목록
- martial_arts_library: 배울 수 있는 무술 목록 (20+)

# 핵심 메서드
- teach_martial_art(player, martial_art_key)  # 무술 교육
- list_available_arts()                       # 배울 수 있는 무술 목록
- upgrade_martial_art(player, martial_art)    # 무술 강화
- calculate_training_time(martial_art)        # 훈련 시간 계산
```

**구현 내용:**
- 무술관 건물 표현
- 무술 목록 (20+개)
- 훈련 진행도 시스템
- 무술 완성도 (0-100%)

---

#### 12-2. MerchantNPC.gd (상인 상세 구현)
```gdscript
class_name MerchantNPC extends NPCBase

# 상인 속성
- inventory: 판매 아이템 목록
- buy_prices: 구매 가격표
- sell_prices: 판매 가격표
- reputation: 거래 평판

# 핵심 메서드
- list_items_for_sale()           # 판매 아이템 목록
- buy_item(player, item_key)      # 플레이어에게서 구매
- sell_item(player, item_key)     # 플레이어에게 판매
- get_item_price(item_key)        # 아이템 가격 조회
- apply_discount(player_level)    # 레벨별 할인 적용
```

**구현 내용:**
- 30개+ 아이템 데이터베이스
- 동적 가격 조정 (수요-공급)
- 플레이어 레벨별 할인
- 아이템 부족 시 재입고

---

#### 12-3. QuestGiverNPC.gd (�에스트 관리자 상세 구현)
```gdscript
class_name QuestGiverNPC extends NPCBase

# 퀘스트 속성
- quest_list: 제공하는 퀘스트 목록 (10+)
- active_quests: 플레이어가 진행 중인 퀘스트
- completed_quests: 완료한 퀘스트

# 핵심 메서드
- list_available_quests(player)    # 플레이어가 할 수 있는 퀘스트
- offer_quest(player, quest_id)    # 퀘스트 제시
- check_quest_progress(player)     # 진행도 확인
- complete_quest(player, quest_id) # 퀘스트 완료 보상
```

**구현 내용:**
- 10+개 퀘스트 데이터베이스
- 퀘스트 진행도 추적
- 보상 시스템 (경험치, 골드, 아이템)
- 퀘스트 연계 시스템

---

### Day 13: NPC AI 스케줄링 & 최종 통합

**목표:** NPC가 동적으로 이동하고 활동하는 시스템 완성

#### 13-1. NPCScheduler.gd (NPC 스케줄링 시스템)
```gdscript
class_name NPCScheduler

# 스케줄 속성
- npc_schedules: {npc_key: [시간별 활동]}
- current_time: 게임 시간
- day_cycle: 24시간 사이클

# 핵심 메서드
- create_schedule(npc_key, activities)  # NPC 일정 생성
- update_npc_position(npc_key, delta)   # 시간 진행에 따라 NPC 위치 이동
- get_npc_current_activity(npc_key)     # 현재 NPC가 뭐하고 있나
- advance_game_time(delta)              # 게임 시간 진행
```

**구현 내용:**
- 각 NPC별 24시간 활동 스케줄
- 시간에 따른 위치 변경
- 활동 로그 (예: 은사는 오전 9시-12시 무술관에서 가르침)
- 플레이어와의 만남 시스템

예시 스케줄:
```
은사:
  00:00-08:00: 숙소에서 수련
  08:00-12:00: 무술관 (제자 교육)
  12:00-13:00: 음식점에서 점심
  13:00-18:00: 무술관 (개인 수련)
  18:00-23:59: 숙소에서 휴식

상인 종이:
  00:00-09:00: 숙소에서 휴식
  09:00-17:00: 상점 (영업)
  17:00-19:00: 음식점에서 저녁
  19:00-23:59: 숙소에서 휴식
```

---

#### 13-2. NPCInteractionManager.gd (상호작용 확장)
```gdscript
class_name NPCInteractionManager

# 상호작용 시스템
- npc_interactions: NPC별 상호작용 저장
- player_reputation: 플레이어와 NPC의 호감도

# 핵심 메서드
- increase_reputation(npc_key, amount)  # 호감도 증가
- get_reputation(npc_key)               # 호감도 조회
- unlock_npc_dialogue(npc_key, level)   # 호감도 레벨별 대사 해금
- get_personal_quest(npc_key)           # NPC 개인 퀘스트 제시
```

**구현 내용:**
- 6명 NPC별 호감도 시스템 (0-100)
- 호감도에 따른 대사 변화
- 호감도 특정 레벨에서 개인 퀘스트 해금
- 최고 호감도 달성 시 특수 이벤트

---

#### 13-3. 통합 테스트 (Day12_13_NPCSystem.gd)

**테스트 항목:**
1. 무술관 시스템 (무술 교육, 강화)
2. Merchant 시스템 (거래, 가격)
3. QuestGiver 시스템 (퀘스트, 보상)
4. NPC 스케줄링 (시간에 따른 이동)
5. 호감도 시스템 (대사 변화)
6. 전체 게임플레이 (완전한 NPC 상호작용)

---

## 📊 구현 통계 (예상)

**코드:**
- 신규 파일: 6개
- 신규 줄 수: ~25,000줄
- 누적 줄 수: ~102,000줄 (Day 1-13)

**시스템:**
- 무술관: 1개
- NPC 타입: 3개 상세 구현
- 무술: 20+개
- 퀘스트: 10+개
- 아이템: 30+개

---

## 🎯 성공 기준

**Day 12 완료 조건:**
- ✅ MartialArtsSchool.gd 구현 & 테스트
- ✅ MerchantNPC.gd 구현 & 테스트
- ✅ QuestGiverNPC.gd 구현 & 테스트
- ✅ 에러 0건

**Day 13 완료 조건:**
- ✅ NPCScheduler.gd 구현 & 테스트
- ✅ NPCInteractionManager.gd 구현 & 테스트
- ✅ 통합 테스트 (모든 NPC 상호작용)
- ✅ 진행도 85% → 95%
- ✅ 에러 0건

---

## 🚀 최종 목표

**Day 14 준비:**
- 모든 NPC 시스템 완성
- 게임 완전 플레이스루 가능
- 모든 주요 시스템 작동
- 버그 0건 (또는 최소)

**다음 단계:**
- Day 14: 최종 통합 테스트 & 폴리시 (95% → 100%)

---

**시작하자! 풀속도로!** ⚡
