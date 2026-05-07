# 🥋 NEXUS Week 3 Day 5 - 그래픽 & 환경 확장 계획

**목표**: 87% → 92% (그래픽 기초 완성)  
**시간**: 2026-05-07 (수요일) - 3월 5일  
**이전 진행도**: Week 2 Day 4 완료 (87%, 5,225줄)  

---

## 🎯 Day 5 4가지 미션

### Mission 1: 지역별 3D 환경 확장 (중요도: 최고)
**목표**: 5개 지역의 기본 3D 씬 완성  
**파일**: `src/scenes/region_*.tscn` (5개)  
**라인**: ~400줄

#### 각 지역별 씬:
1. **중원** (central_plains.tscn) - 이미 있음
   - ✅ 평원, 건물, 훈련장, 보스 아레나
   
2. **동토** (frozen_lands.tscn) - NEW
   - 눈덮인 평원 (MeshInstance3D + StandardMaterial)
   - 얼음 탑 (4개)
   - 북풍 마을 (건물 3개)
   - 동토 던전 입구
   - 동토 보스 아레나 (크리스탈 구조물)
   
3. **남해** (south_sea.tscn) - NEW
   - 모래 해변
   - 파도 (물 평면)
   - 항구 건물 (5개)
   - 해양 생물 구조물
   - 남해 던전 입구 (동굴)
   
4. **서역** (western_desert.tscn) - NEW
   - 사막 지형 (모래 텍스처)
   - 오아시스 (물 + 야자수)
   - 카라반 마을 (천막 + 상점)
   - 고대 유적 (돌 기둥)
   - 서역 던전 입구 (사찰)
   
5. **북방** (northern_peaks.tscn) - NEW
   - 산봉우리 (높은 지형)
   - 설산 (눈 입자)
   - 수도사 사찰 (건물)
   - 용암 분화구 (내부)
   - 북방 던전 입구 (영묘)

#### 기술 구현:
```
각 지역마다:
- 기본 노드 구조 (Node3D)
  - 지형 (MeshInstance3D + StandardMaterial)
  - 건물들 (여러 박스 메쉬)
  - 스포닝 포인트들 (Marker3D)
  - 던전 입구들 (BoxShape3D + Area3D)
  - 환경 오브젝트 (야자수, 바위 등)
  - 카메라 및 라이팅

- 텍스처는 단색 StandardMaterial 사용 (나중에 확장)
- 간단한 메쉬 모양으로 시각화
```

**체크리스트**:
- [ ] frozen_lands.tscn 생성 (눈 지형, 타워, 마을)
- [ ] south_sea.tscn 생성 (해변, 항구, 물)
- [ ] western_desert.tscn 생성 (사막, 오아시스, 유적)
- [ ] northern_peaks.tscn 생성 (산, 사찰, 분화구)
- [ ] 각 씬에 스포닝 포인트 30개씩 배치
- [ ] 각 씬에 보스 아레나 추가
- [ ] 모든 씬에서 플레이어 이동 가능 확인

---

### Mission 2: 환경 상호작용 시스템 (Environment Manager)
**목표**: 지역별 환경 이펙트 자동 적용  
**파일**: `src/scripts/environment_system.gd` (NEW)  
**라인**: ~250줄

#### 기능:
```
✅ 지역별 환경 설정:
  - 중원: 맑음, 자연색
  - 동토: 눈 입자, 추위 효과 (화면 흐려짐)
  - 남해: 물 파도, 해풍 입자
  - 서역: 모래바람, 열기 효과
  - 북방: 강한 바람, 저온 효과

✅ 동적 환경:
  - 날씨 시스템 (맑음, 흐림, 비, 눈)
  - 시간 시스템 (낮, 밤) - 라이팅 변경
  - 주기적 환경 변화
  - 지역 이동 시 자동 적용

✅ 플레이어에게 영향:
  - 동토: 체력 5% 지속 감소
  - 남해: 이동 속도 감소 (모래)
  - 서역: 마나 회복 10% 감소 (건조함)
  - 북방: 크리티컬 확률 증가 (집중력)

✅ 함수들:
  - set_environment(region_name)
  - set_weather(weather_type)
  - set_time(time_of_day)
  - get_environment_effect(region)
  - apply_effect_to_player()
  - get_player_effect_value(effect_name)
```

**구현 전략**:
- 환경 데이터를 Dictionary로 저장
- region_manager와 통합
- 게임 루프에서 1초마다 업데이트

---

### Mission 3: NPC 3D 모델 & 배치 시스템
**목표**: 모든 지역의 100+명 NPC를 3D로 표현  
**파일**: `src/scripts/npc_spawner.gd` (UPDATE)  
**라인**: ~200줄 (신규 또는 확장)

#### 기능:
```
✅ NPC 프리팹 생성:
  - 기본 모양: 캡슐 몸 + 박스 머리
  - 색상: 직업별 다른 색 (빨강=전사, 파랑=마법사 등)
  - 라벨: NPC 이름 표시

✅ 지역별 NPC 배치:
  - 각 지역 스포닝 포인트에 NPC 생성
  - 지역별 배치 데이터 사용
  - 충돌 없이 배치 (약간씩 오프셋)

✅ NPC 애니메이션 (간단):
  - 유휴 상태: 좌우 흔들기
  - 대화 상태: 머리 위아래
  - 이동: 걷기 애니메이션

✅ 상호작용:
  - 플레이어가 가까우면 "말하기" 표시
  - 클릭으로 대화 시작
```

**구현**:
- NPCSpawner 노드가 region_manager로부터 NPC 데이터 받기
- 각 NPC마다 CharacterBody3D 생성
- 간단한 유휴 애니메이션 적용

---

### Mission 4: 배경음악 & 사운드 기초 시스템
**목표**: 지역별 BGM 및 효과음 시스템  
**파일**: `src/scripts/audio_manager.gd` (NEW)  
**라인**: ~200줄

#### 기능:
```
✅ 음악 시스템:
  - 지역별 BGM (5개) - 약 3분 각
    * 중원: 우아한 동양 음악
    * 동토: 차갑고 신비로운 음악
    * 남해: 밝고 상큼한 음악
    * 서역: 신비로운 실크로드 음악
    * 북방: 웅장한 산악 음악
  
  - 전투 BGM (1개)
  - 보스 BGM (1개)
  - 마을 BGM (1개)
  
  - 음악 전환: 서서히 감소 → 교체 → 서서히 증가

✅ 효과음 시스템:
  - 공격음 (5가지)
  - 회피음
  - 보스음 (특수)
  - UI 효과음
  - 지역 환경음 (바람, 파도 등)

✅ 함수들:
  - play_region_music(region_name)
  - play_battle_music()
  - play_boss_music()
  - stop_music()
  - play_sfx(sfx_name)
  - set_master_volume(level)
  - set_music_volume(level)
  - set_sfx_volume(level)
```

**구현 전략**:
- AudioStreamPlayer 노드 활용
- 싱글톤 패턴으로 게임 전체에서 접근 가능
- 나중에 실제 음악 파일 로드 가능하도록 설계

---

## 📋 일정 (8시간)

```
09:00-11:00 (120분)  🎮 Mission 1: 4개 지역 씬 생성
11:00-12:00 (60분)   🌍 지역별 스포닝 포인트 배치
12:00-13:00 (60분)   🍽️  점심

13:00-14:30 (90분)   🌪️  Mission 2: Environment System
14:30-16:00 (90분)   🧑 Mission 3: NPC Spawner
16:00-16:30 (30분)   ☕ 휴식

16:30-18:00 (90분)   🎵 Mission 4: Audio Manager
18:00-19:00 (60분)   🍽️  저녁
19:00-20:00 (60분)   🧪 통합 테스트 & 버그 픽스
```

---

## 🎯 Day 5 체크리스트

```
[ ] frozen_lands.tscn 완성
[ ] south_sea.tscn 완성
[ ] western_desert.tscn 완성
[ ] northern_peaks.tscn 완성
[ ] environment_system.gd 완성
[ ] npc_spawner.gd 업데이트
[ ] audio_manager.gd 완성
[ ] 모든 지역 플레이 가능 확인
[ ] 게임 실행 테스트
[ ] 버그 픽스
```

---

## 📊 코드 증가량 예상

| 파일 | 이전 | 추가 | 합계 | 상태 |
|------|------|------|------|------|
| frozen_lands.tscn | 0 | 120 | 120 | NEW |
| south_sea.tscn | 0 | 120 | 120 | NEW |
| western_desert.tscn | 0 | 120 | 120 | NEW |
| northern_peaks.tscn | 0 | 120 | 120 | NEW |
| environment_system.gd | 0 | 250 | 250 | NEW |
| npc_spawner.gd | 0 | 200 | 200 | NEW |
| audio_manager.gd | 0 | 200 | 200 | NEW |
| game_manager.gd | 335 | 50 | 385 | UPDATE |
| **합계** | 335 | 1,150 | 1,485 | +600줄 예상 |

---

## 🎮 Day 5 후 기대 상태

```
✅ 5개 지역 모두 3D로 완성
✅ 100+명 NPC 배치 완료
✅ 환경 효과 시스템 작동
✅ 음악 & 효과음 준비 (아직 파일 없음)
✅ 모든 지역에서 플레이 가능
✅ 진행도: 87% → 92%
✅ 코드: 5,225줄 → 6,375줄
```

---

## 🚀 다음 단계 (Day 6-7)

### Day 6: 애니메이션 & 폴리시
- NPC 기본 애니메이션
- 플레이어 공격 애니메이션
- 보스 패턴 애니메이션
- UI 애니메이션

### Day 7: 성능 최적화 & 완성
- 렌더링 최적화
- 메모리 최적화
- 통합 테스트
- Week 3 완료 (92% 목표)

---

**작성자**: 천재 ⚡  
**상태**: 지금 시작!  
**목표**: 87% → 92% (이 하루에 5% 진행)

_"Week 3 본격 폴리시 단계! 게임이 눈에 띄게 예뻐진다!" 🎨✨_
