# 🔥 Day 18-20: 보스 애니메이션 & 카메라 & 이펙트

**기간:** 2026-05-13 (수) ~ 2026-05-15 (금)  
**목표:** 35% → 50% (그래픽/애니메이션 진행)  
**진행형:** 병렬 작업 (기존 로직 유지, 그래픽만 추가)

---

## 📅 세부 일정

### Day 18 (05-13 수요일)

#### Morning (8시간)

**Task 1: 보스 애니메이션 10개 추가**

```gdscript
# AlphaWolf 특수 애니메이션

# 1. animate_boss_roar - 분노의 울음
#    - 입 벌림 (메시 스케일)
#    - 몸통 팽창
#    - 효과: 화면 진동 신호
func animate_boss_roar(progress: float) -> void:
    mesh_instance.scale = Vector3(1.0, 1.2 + sin(progress * PI * 3) * 0.2, 1.0)
    mesh_instance.position.y = sin(progress * PI * 4) * 0.1  # 진동

# 2. animate_boss_shadow_jump - 그림자 도약
#    - 빠른 점프 (0.3초)
#    - 후진 + 옆으로 (ランダム 방향)
#    - 착지 충격
func animate_boss_shadow_jump(progress: float) -> void:
    var height = (1.0 - abs(progress * 2.0 - 1.0)) * 2.0
    mesh_instance.position.y = height
    mesh_instance.position.x = cos(progress * PI) * 3.0

# 3. animate_boss_fury_slash - 분노의 연격 (5연격)
#    - 5번의 빠른 슬래시
#    - 각각 0.2초
func animate_boss_fury_slash(progress: float) -> void:
    var combo_progress = fmod(progress * 5.0, 1.0)
    animate_martial_28(combo_progress)  # 우측 베기 사용

# 4-7. Phase 전환 애니메이션
#    - Phase 2 진입: 몸 색상 변경 (로직에서 처리), 회전
#    - Phase 3 진입: 빠른 회전 + 포효
#    - Phase 회복: 무릎 꿇기 → 일어서기
#    - 패배 애니메이션: 쓰러짐 + 사라지기

# 8-10. 추가 보스 애니메이션
#    - 광역 공격 (양팔 회전)
#    - 버프 시전 (빛 에너지)
#    - 약점 노출 (무방비 포즈)
```

#### Afternoon (4시간)

**Task 2: 카메라 시스템 개선**

```gdscript
# Main3D.gd에 카메라 모드 추가

# 기본 카메라: Over-the-shoulder
# 보스 전투 카메라: Wide shot (35도 시야각, 거리 10m)
# 특수 공격: 줌인 (특수 기술 발동 시)

func set_camera_mode(mode: String) -> void:
    match mode:
        "normal":
            camera.fov = 70
            camera_distance = 5
        "boss":
            camera.fov = 35
            camera_distance = 10
        "zoom":
            camera.fov = 50
            camera_distance = 3

# 동적 카메라 추적
func update_camera_position(delta: float) -> void:
    var target_pos = player.position + Vector3(0, 1.5, camera_distance)
    camera.position = camera.position.lerp(target_pos, delta * 5.0)
    camera.look_at(player.position + Vector3(0, 1.0, 0), Vector3.UP)
```

---

### Day 19 (05-14 목요일)

#### Full Day (8시간)

**Task 3: 파티클 & 이펙트 시스템**

```gdscript
# ParticleEffectManager.gd

# 타격 이펙트: 작은 먼지 입자
# 무술 이펙트: 무술별 색상 (화염=빨강, 빙결=파랑)
# 보스 이펙트: 큰 폭발 (포효, 에너지 버스트)
# 상태 이펙트: 버프/디버프 아이콘 (생명력 회복, 중독)

func create_hit_effect(position: Vector3) -> void:
    var particles = GPUParticles3D.new()
    particles.position = position
    particles.lifetime = 1.0
    particles.emitting = true
    add_child(particles)
    await get_tree().create_timer(1.5).timeout
    particles.queue_free()

func create_martial_effect(martial_type: String, position: Vector3) -> void:
    # martial_type별 색상
    var color = {"fire": Color.RED, "ice": Color.CYAN, "lightning": Color.YELLOW}.get(martial_type, Color.WHITE)
    # 파티클 생성...
```

#### Testing
- 모든 이펙트 시각적 검증
- 성능 측정 (파티클 수 최적화)

---

### Day 20 (05-15 금요일)

#### Morning (4시간)

**Task 4: 라이팅 & 그래픽 개선**

```gdscript
# WorldEnvironment & 지역별 색감

# 중원 (Jungwon): 황금색 태양빛, 따뜻한 톤
light.energy_multiplier = 1.8
light.light_energy = Color(1.0, 0.9, 0.7)  # 황금색

# 천산 (Tianshan): 차가운 파란 톤, 높은 고도
light.energy_multiplier = 1.5
light.light_energy = Color(0.8, 0.9, 1.0)  # 파란색

# 황무지 (Wasteland): 어두운 황토색
light.energy_multiplier = 0.9
light.light_energy = Color(0.7, 0.6, 0.4)  # 황토색
```

#### Afternoon (4시간)

**Task 5: 통합 테스트 & 성능 최적화**

```bash
# Day20_CombinedTest.gd
# 플레이어 생성 → 보스 소환 → 전투 시뮬레이션
# FPS 측정: 목표 60 FPS
# 메모리 사용: 최소화
```

#### Final
- Git 커밋: `Day 18-20: Boss animations + camera + effects`
- 진행 보고: 35% → 50% 달성

---

## 🛠️ 구현 상세 (코드 템플릿)

### 보스 애니메이션 추가 (AnimationController.gd)

```gdscript
# 35번부터 44번까지 보스 애니메이션 추가

# 35. animate_boss_roar (보스 포효)
# 36. animate_boss_shadow_jump (보스 그림자 도약)
# 37. animate_boss_fury_slash (보스 분노의 연격)
# 38. animate_boss_phase2_enter (Phase 2 진입)
# 39. animate_boss_phase3_enter (Phase 3 진입)
# 40. animate_boss_wide_attack (광역 공격)
# 41. animate_boss_buff (버프 시전)
# 42. animate_boss_vulnerable (약점 노출)
# 43. animate_boss_defeat (패배 애니메이션)
# 44. animate_boss_recover (회복 애니메이션)

func animate_boss_roar(progress: float) -> void:
    mesh_instance.scale = Vector3(1.0, 1.2 + sin(progress * PI * 3) * 0.2, 1.0)
    mesh_instance.position.y = sin(progress * PI * 4) * 0.1

# ... (나머지 9개 함수)
```

### update_animation 함수 추가

```gdscript
"boss_roar":
    animate_boss_roar(progress)
"boss_shadow_jump":
    animate_boss_shadow_jump(progress)
# ... (나머지)
```

### 카메라 모드 (Main3D.gd)

```gdscript
var camera_mode: String = "normal"
var camera_distance: float = 5.0

func _ready() -> void:
    # ... 기존 코드 ...
    set_camera_mode("normal")

func set_camera_mode(mode: String) -> void:
    match mode:
        "normal":
            camera_fov = 70
            camera_distance = 5
        "boss":
            camera_fov = 35
            camera_distance = 10
        "zoom":
            camera_fov = 50
            camera_distance = 3

func _process(delta: float) -> void:
    # 카메라 업데이트
    update_camera_position(delta)
    
    # 보스 근처면 자동으로 보스 모드로 전환
    if player.distance_to(boss.position) < 15:
        set_camera_mode("boss")
    else:
        set_camera_mode("normal")
```

---

## 📊 진행률 추적

| Day | 작업 | 예상 | 목표 | 상태 |
|-----|------|------|------|------|
| 17 | 무술 30개 | 2h | ✅ | ✅ 완료 |
| 18 | 보스 10개 + 카메라 | 4h | ✅ | ⏳ 진행 |
| 19 | 파티클 & 이펙트 | 4h | ✅ | ⏳ 진행 |
| 20 | 라이팅 & 최적화 | 4h | ✅ | ⏳ 진행 |

**총:** 14시간 (2일)

---

## 🎯 성공 기준

### Day 18 완료
- [ ] 10개 보스 애니메이션 완성
- [ ] 카메라 모드 전환 동작
- [ ] 에러 0건

### Day 19 완료
- [ ] 파티클 이펙트 추가
- [ ] 모든 타격 이펙트 시각적 확인
- [ ] 60 FPS 유지

### Day 20 완료
- [ ] 지역별 라이팅 완성
- [ ] 성능 최적화 (메모리 <500MB)
- [ ] 통합 테스트 통과

---

## 🔥 핵심 원칙

✅ **기존 로직 유지** - 게임 시스템 변경 X, 그래픽만 추가  
✅ **증분 개발** - 매일 커밋, 매일 테스트  
✅ **에러 0** - 완벽한 완성을 목표  
✅ **성능 우선** - 60 FPS 유지  

---

## 💾 파일 구조 (예상)

```
Scripts/Combat/
├── AnimationController.gd (수정: +10개 함수)
├── ParticleEffectManager.gd (새 파일)
└── CameraManager.gd (새 파일)

Scripts/UI/
└── Main3D.gd (수정: 카메라 모드 추가)

Scripts/Test/
├── Day17_MartialAnimation.gd (완료)
├── Day18_BossAnimation.gd (새 파일)
├── Day19_ParticleTest.gd (새 파일)
└── Day20_IntegrationTest.gd (새 파일)
```

---

## ⚡ 빠른 실행

```bash
# Day 18 시작
cd /Users/hwangjeyeong/.openclaw/workspace/NEXUS

# 1. 보스 애니메이션 추가
nano Scripts/Combat/AnimationController.gd
# -> animate_boss_roar() ~ animate_boss_recover() 추가

# 2. update_animation에 라우팅 추가
# -> "boss_roar": animate_boss_roar(progress)
# -> ... (나머지)

# 3. 카메라 개선 (Main3D.gd)
nano Scripts/UI/Main3D.gd
# -> set_camera_mode() 함수 추가
# -> update_camera_position() 수정

# 4. 테스트 실행
godot --script Scripts/Test/Day18_BossAnimation.gd

# 5. 커밋
git add -A && git commit -m "Day 18: Add boss animations + camera system"
```

---

**상태: 📋 Day 18-20 계획 완성**  
**예상 시간: 12-14시간**  
**목표: 35% → 50%**  
**시작: 2026-05-13 09:00**

