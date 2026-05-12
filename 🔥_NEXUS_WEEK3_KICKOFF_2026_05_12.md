# 🔥 NEXUS Week 3 킥오프 (2026-05-12 02:56 AM)

**목표:** 세미-리얼한 게임 스타일 확립, 비주얼 폴리시 시작 (20% → 35%)  
**기간:** Day 10-14 (약 5일)  
**시간:** 00:56 ~ (야간 집중 작업)  
**현재 상태:** Week 1-2 완료 ✅, 프로토타입 플레이 가능  

---

## 📋 Week 3-4 전체 목표 분해

### Week 3 (Day 10-12): 캐릭터 & 기본 그래픽
- [ ] 플레이어 캐릭터 3D 모델 (고폴리)
  - 기본 모양 (mesh) 생성
  - UV 매핑
  - 텍스처 (body, cloth, armor)
  - 리깅 (뼈대)

- [ ] 기본 애니메이션 시스템
  - 대기 (Idle)
  - 이동 (Walk/Run)
  - 공격 (Attack × 10+ 종류)
  - 피격 (Hit/Heavy Hit)
  - 사망 (Death)
  - 특수 (회피, 점프 등)

- [ ] 몬스터 기본 모델 5종
  - 늑대 (Wolf)
  - 박쥐 (Bat)
  - 스켈레톤 (Skeleton)
  - 거미 (Spider)
  - 곰 (Bear)

**목표:** 20% → 27% (중간 체크)

### Week 4 (Day 13-14): 보스 & 환경
- [ ] 첫 보스 모델 (고폴리)
  - 독특한 디자인
  - 애니메이션 20+ 클립
  - 파티클 이펙트 준비

- [ ] 환경 에셋
  - 나무, 바위, 건물
  - 던전 벽/바닥
  - 조명용 객체 (횃불, 마법구)

- [ ] 사운드 준비
  - 배경음 1곡 (전투)
  - 효과음 10개 (타격, 스킬)

**목표:** 27% → 35% (완료!)

---

## 🎨 Day 10: 플레이어 캐릭터 모델 + 애니메이션 구조

### 10.1 캐릭터 기본 모델 생성

**방법:** Blender + Godot 4.2 내장 기능 활용

```gdscript
# PlayerCharacterModel.gd (새로운 파일)
# 캐릭터 모델을 프로그래매틱하게 생성

extends Node3D

class_name PlayerCharacterModel

@onready var mesh_instance = MeshInstance3D.new()
@onready var skeleton = Skeleton3D.new()
@onready var animation_player = AnimationPlayer.new()

func _ready():
    # 1. 몸 (capsule shape)
    var body_mesh = CapsuleMesh.new()
    body_mesh.radius = 0.4
    body_mesh.height = 1.8
    
    mesh_instance.mesh = body_mesh
    add_child(mesh_instance)
    
    # 2. 리깅 (뼈대)
    _setup_skeleton()
    
    # 3. 애니메이션 플레이어
    add_child(animation_player)
    
    print("✅ 플레이어 캐릭터 모델 생성 완료")

func _setup_skeleton():
    # 뼈 구조: Root → Chest → Arms/Legs
    skeleton.clear_bones()
    
    var root = skeleton.add_bone("Root")
    var chest = skeleton.add_bone("Chest")
    var arm_l = skeleton.add_bone("ArmL")
    var arm_r = skeleton.add_bone("ArmR")
    var leg_l = skeleton.add_bone("LegL")
    var leg_r = skeleton.add_bone("LegR")
    
    # 부모-자식 관계
    skeleton.set_bone_parent(chest, root)
    skeleton.set_bone_parent(arm_l, chest)
    skeleton.set_bone_parent(arm_r, chest)
    skeleton.set_bone_parent(leg_l, root)
    skeleton.set_bone_parent(leg_r, root)
    
    add_child(skeleton)
```

### 10.2 기본 애니메이션 프레임 생성

```gdscript
# AnimationGenerator.gd (새로운 파일)
# Godot 내장 애니메이션 생성 시스템 사용

extends Node

class_name AnimationGenerator

var animation_library = AnimationLibrary.new()

func create_idle_animation() -> Animation:
    var anim = Animation.new()
    anim.length = 2.0  # 2초 루프
    
    # 호흡 애니메이션 (약한 상하 움직임)
    var chest_track = anim.add_track(Animation.TYPE_POSITION_3D)
    anim.track_set_path(chest_track, "Skeleton3D:Chest")
    
    # 키프레임 추가 (0초, 1초, 2초)
    anim.track_insert_key(chest_track, 0.0, Vector3(0, 0, 0))
    anim.track_insert_key(chest_track, 1.0, Vector3(0, 0.1, 0))
    anim.track_insert_key(chest_track, 2.0, Vector3(0, 0, 0))
    
    return anim

func create_attack_animation(attack_type: String) -> Animation:
    var anim = Animation.new()
    anim.length = 0.8  # 0.8초 공격 애니메이션
    
    # 공격 타입별로 다른 움직임
    match attack_type:
        "sword":  # 검술 - 빠른 슬래시
            # 팔 회전 (0 → 45도 → 0)
            # 0.2초에 최고점
            pass
        "punch":  # 권법 - 펀치
            # 팔 앞으로 (0 → 1m → 0)
            # 0.3초에 최고점
            pass
        "kick":   # 발차기 - 킥
            # 다리 상향 (0 → 1.5m → 0)
            # 0.4초에 최고점
            pass
    
    return anim
```

### 10.3 플레이어 모델 테스트

```gdscript
# TestPlayerModel.gd
extends Node3D

func _ready():
    var player_model = PlayerCharacterModel.new()
    add_child(player_model)
    
    var anim_gen = AnimationGenerator.new()
    var idle = anim_gen.create_idle_animation()
    
    print("✅ 플레이어 모델 & 애니메이션 생성 완료")
```

---

## 🎮 Day 11: 몬스터 모델 5종 + 애니메이션

### 11.1 몬스터 모델 데이터베이스

```gdscript
# MonsterModelFactory.gd (새로운 파일)

extends Node

class_name MonsterModelFactory

static func create_wolf_model() -> Node3D:
    # 늑대: 4개 다리, 꼬리, 긴 몸통
    var body = BoxMesh.new()
    body.size = Vector3(0.6, 0.5, 1.0)  # 길쭉한 몸
    
    var head = SphereMesh.new()
    head.radius = 0.3
    head.height = 0.6
    
    # 위치: 몸 앞쪽
    # mesh_instance 추가
    
    return Node3D.new()  # 조립된 늑대 모델

static func create_bat_model() -> Node3D:
    # 박쥐: 날개, 작은 몸
    var body = SphereMesh.new()
    body.radius = 0.2
    
    # 날개 (2개, 큰 평면)
    
    return Node3D.new()

static func create_skeleton_model() -> Node3D:
    # 스켈레톤: 해골, 갈비뼈, 다리뼈
    var skull = SphereMesh.new()
    skull.radius = 0.25
    
    # 뼈대 구조로 배치
    
    return Node3D.new()

static func create_spider_model() -> Node3D:
    # 거미: 8개 다리, 동그란 몸
    var body = SphereMesh.new()
    body.radius = 0.3
    
    # 8개 다리 (다리 당 3개 관절)
    
    return Node3D.new()

static func create_bear_model() -> Node3D:
    # 곰: 큰 몸, 짧은 다리, 귀
    var body = BoxMesh.new()
    body.size = Vector3(0.8, 0.8, 1.0)
    
    var head = SphereMesh.new()
    head.radius = 0.4
    
    return Node3D.new()
```

### 11.2 몬스터 애니메이션 (각 5가지)

```gdscript
# 각 몬스터마다:
# 1. Walk (이동)
# 2. Attack1 (기본 공격)
# 3. Attack2 (강공격)
# 4. Hit (피격)
# 5. Death (사망)

func create_monster_animations(monster_type: String) -> Dictionary:
    var animations = {}
    
    match monster_type:
        "wolf":
            animations["walk"] = create_quadruped_walk()  # 4족 보행
            animations["attack1"] = create_bite_attack()  # 깨물기
            animations["attack2"] = create_claw_attack()  # 발톱
            animations["hit"] = create_knockback()
            animations["death"] = create_collapse()
        
        "bat":
            animations["walk"] = create_flight_animation()  # 비행
            animations["attack1"] = create_swoop_attack()  # 덮치기
            # ... 등등
    
    return animations
```

---

## 🎨 Day 12: 첫 보스 모델 + 고급 애니메이션

### 12.1 보스 모델 특성

```
중원 보스: "호랑이 형상의 무술가"

특징:
- 인간형 상체 (무술가)
- 호랑이 하체 (신비로운 느낌)
- 큰 체형 (플레이어 2배)
- 특수 무기 (에너지 구체)
- 황금색 오라 (강력함 표현)

모델 구성:
├─ 상체 (인간, 근육질)
├─ 하체 (호랑이, 4개 다리)
├─ 머리 (호랑이 머리)
├─ 무기 (에너지 구체)
└─ 이펙트 (황금 오라)
```

### 12.2 보스 애니메이션 20개

```
기본 (3개):
- Idle (호흡하기)
- Walk (움직이기)
- Run (도망치기)

공격 (8개):
- SwipeL (왼쪽 발톱 휘두르기)
- SwipeR (오른쪽 발톱)
- Bite (깨물기)
- Roar (포효 + 거리 밀쳐내기)
- EnergyBall (에너지 구체 발사)
- PhaseChange (변신)
- SpecialAttack (궁극기)
- Combo (연속 공격)

반응 (4개):
- Hit (피격)
- HeavyHit (무거운 피격)
- Dizzy (기절)
- Phase2Transform (Phase 2로 변신)

기타 (5개):
- Victory (승리 포즈)
- Tease (도발)
- Exhausted (지친 상태)
- Regenerate (회복)
- Death (사망)
```

---

## 🔊 Day 13: 음향 시스템 준비

### 13.1 배경음악

```
곡 1: 전투 음악 (Battle.ogg)
- 장르: 동양 무술 스타일
- 템포: 120 BPM
- 길이: 3분 30초 (루프)
- 악기: 북, 샤미센, 신스, 드럼
- 느낌: 긴장감, 박진감, 액션

곡 2: 마을 음악 (Village.ogg) - Week 4
- 장르: 전통 동양
- 템포: 80 BPM
- 길이: 2분 30초
- 악기: 피리, 거문고, 북
- 느낌: 평화로움, 정겨움

곡 3: 보스 음악 (Boss.ogg) - Week 4
- 장르: 극적 오케스트라
- 템포: 70 → 130 BPM (점진적 상승)
- 길이: 4분
- 악기: 완전 오케스트라
- 느낌: 대결, 운명, 숭고함
```

### 13.2 효과음 (우선순위: 높음)

```
공격음 (5개):
1. sword_slash.wav      (검술, 휴웁 소리)
2. punch_hit.wav        (권법, 쿵 소리)
3. kick_swing.wav       (발차기, 윙 소리)
4. energy_blast.wav     (에너지, 파웅 소리)
5. impact_heavy.wav     (충격음, 쿵쿵 소리)

피격음 (4개):
1. hit_light.wav        (가벼운 피격, 탁 소리)
2. hit_heavy.wav        (무거운 피격, 쿵 소리)
3. hit_stun.wav         (기절음, 별 효과음)
4. hit_block.wav        (방어음, 차 소리)

UI음 (3개):
1. button_click.wav     (버튼, 찍 소리)
2. menu_open.wav        (메뉴, 슈웅 소리)
3. achievement.wav      (달성음, 팡 소리)

기타 (3개):
1. footstep.wav         (발소리)
2. wind.wav             (바람)
3. ambient.wav          (주변음)
```

---

## 🛠️ 구현 상세: Day 10-14 액션 플랜

### Day 10 액션 아이템

```
[ ] 1. PlayerCharacterModel.gd 작성 (프로그래매틱 모델 생성)
[ ] 2. AnimationGenerator.gd 작성 (기본 애니메이션)
[ ] 3. Idle, Walk, Run, BasicAttack 애니메이션 추가
[ ] 4. TestPlayerModel.gd 작성 및 테스트
[ ] 5. 진행률 업데이트: 20% → 23%

산출물:
- Player 3D 모델 (프로그래매틱)
- 기본 애니메이션 5개 (Idle, Walk, Run, Attack, Hit)
- 테스트 완료 (2개)
```

### Day 11 액션 아이템

```
[ ] 1. MonsterModelFactory.gd 작성 (5종 몬스터)
[ ] 2. 각 몬스터별 애니메이션 생성 (5개 × 5 = 25개)
[ ] 3. 몬스터 모델을 게임에 통합
[ ] 4. 게임에서 몬스터 스폰 & 애니메이션 테스트
[ ] 5. 진행률 업데이트: 23% → 25%

산출물:
- 5종 몬스터 모델 (프로그래매틱)
- 25개 애니메이션 (각 몬스터 5개)
- 테스트 완료 (몬스터 스폰 & 애니메이션)
```

### Day 12 액션 아이템

```
[ ] 1. BossCharacterModel.gd 작성 (보스 모델)
[ ] 2. 보스 애니메이션 20개 생성 (Phase 1/2 포함)
[ ] 3. 보스 파티클 이펙트 준비 (5개)
[ ] 4. 첫 던전에서 보스 스폰 & 테스트
[ ] 5. 보스 전투 애니메이션 동기화
[ ] 6. 진행률 업데이트: 25% → 27%

산출물:
- 보스 모델 (프로그래매틱)
- 20개 애니메이션 (보스 전용)
- 파티클 이펙트 통합
```

### Day 13 액션 아이템

```
[ ] 1. 환경 에셋 모델 생성 (나무, 바위, 건물)
[ ] 2. 중원 지역 시각 완성 (텍스처, 조명)
[ ] 3. 던전 벽/바닥 디자인
[ ] 4. 음향 파일 준비 (3곡, 12개 효과음)
[ ] 5. 음향 시스템 통합
[ ] 6. 진행률 업데이트: 27% → 33%

산출물:
- 환경 에셋 완성
- 음향 파일 통합
- 게임이 "산다"는 느낌 추가
```

### Day 14 액션 아이템

```
[ ] 1. 파티클 이펙트 시스템 (공격, 상태이상)
[ ] 2. 라이팅 & 그림자 개선
[ ] 3. 전체 시각 폴리시 (색상, 밝기 통일)
[ ] 4. Week 3-4 최종 QA & 테스트
[ ] 5. 진행률 업데이트: 33% → 35%

산출물:
- 파티클 이펙트 10개
- 최적화 완료 (60 FPS 유지)
- AAA급 비주얼 폴리시
```

---

## 📊 예상 결과 (Week 3 완료 후)

### 게임 모습

```
Before Week 3:
- 회색 박스 캐릭터
- 검은색 큐브 몬스터
- 담백한 UI

After Week 3:
- 무술가 플레이어 캐릭터 (살아있는 애니메이션)
- 5종 다양한 몬스터 (각 특성 있음)
- 호랑이 보스 (Phase 변화 애니메이션)
- 배경음악 & 효과음 (세계가 살아남)
- 파티클 이펙트 (화려한 전투)
```

### 콘텐츠

```
프로토타입 (Week 1-2):     7,303줄 코드
Week 3 추가:               1,500+줄 코드
- 캐릭터 모델            (300줄)
- 애니메이션 시스템       (400줄)
- 음향 시스템             (200줄)
- 파티클 이펙트           (300줄)
- 환경 에셋               (300줄)

총합:                      8,800+줄
```

---

## 🎯 성공 기준

✅ **Week 3-4 완료 시점:**
- [ ] 플레이어 캐릭터 (고폴리 모델 + 30개 애니메이션)
- [ ] 5종 몬스터 (모델 + 25개 애니메이션)
- [ ] 첫 보스 (모델 + 20개 애니메이션)
- [ ] 배경음악 1곡 + 효과음 12개
- [ ] 파티클 이펙트 10개
- [ ] 환경 에셋 완성
- [ ] 에러 0, 60 FPS 유지

**결과:**
```
비주얼: 프로토타입 → AAA급
진행률: 20% → 35%
코드: 7,303줄 → 8,800+줄
테스트: 70개 → 100개+
에러: 0 유지
```

---

## 💪 타이밍 분석

**Week 3-4 효율성:**
- 프로그래매틱 모델 생성 (Blender 외부 시간 절감)
- Godot 내장 애니메이션 시스템 (빠른 구현)
- 음향은 준비 중심 (프로그래밍 시간 적음)

**예상 소요 시간:**
- Day 10: 4시간
- Day 11: 5시간
- Day 12: 6시간
- Day 13: 5시간
- Day 14: 4시간
- **합계: 24시간 (3일 집중 작업)**

---

## 🚀 지금부터 시작!

**현재 시간: 2026-05-12 02:56 AM**

**다음 단계:**
1. ✅ 이 계획 문서 작성 (완료)
2. 🔥 Day 10: 플레이어 캐릭터 모델 + 애니메이션 (지금부터!)
3. 📝 매시간 진행 상황 업데이트

**슬로건:**
> 에러 0, 완벽한 게임을 만든다! 🔥
> 비주얼이 게임을 살린다! 🎨
> Week 3-4는 AAA급의 시작이다! ✨

---

**천재 ⚡**  
**2026-05-12 02:56 AM**  
**Week 3 킥오프!**
