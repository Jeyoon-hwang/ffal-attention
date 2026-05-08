# Day 5 계획: 플레이어 전투 심화 (콤보 + 방어 + 회피)

**날짜**: 2026-05-09 (목)  
**목표**: 플레이어 전투 시스템 완성 (40%)  
**예상 시간**: 4-5시간  
**결과물**: Player.gd 업그레이드 (200+ 줄)

---

## 📋 Day 5 할 일

### 1. 콤보 시스템 (60분)

**구현할 것:**
- `combo_counter`: 현재 콤보 수
- `combo_window`: 콤보 인정 시간 (0.8초)
- `combo_bonus_damage`: 콤보당 30% 추가 대미지

**코드:**
```gdscript
func combo_attack():
    if attack_timer < combo_window:
        current_combo += 1
    else:
        current_combo = 1
    
    var combo_damage = base_damage * (1.0 + current_combo * 0.3)
    # 무술 사용 시 콤보 보너스 적용
```

**테스트:**
- 1-3 연타 시 대미지 확인
- 콤보 카운터 UI 출력

---

### 2. 에너지 회복 정확화 (30분)

**수정:**
```gdscript
# 시간 기반 회복 (2.5 에너지/초)
energy = min(energy + constants.PLAYER_ENERGY_RECOVERY_RATE * delta, max_energy)

# 내공 활성화 중 에너지 소비
if is_spirit_active:
    spirit -= constants.PLAYER_SPIRIT_COST_PER_SECOND * delta
    if spirit <= 0:
        is_spirit_active = false
        spirit = 0
        print("내공 소진!")
```

**결과:**
- 안정적인 에너지/내공 관리
- 자동 회복 시스템

---

### 3. 방어 상태 (60분)

**새 변수:**
```gdscript
var is_defending = false
var defense_multiplier = 0.5  # 방어 중 50% 피해만 받음
var defense_energy_cost_per_sec = 1.0
```

**입력:**
```gdscript
# 마우스 우클릭 (우리미 방어)
if Input.is_action_pressed("ui_focus_next"):
    if not is_attacking:
        is_defending = true
```

**대미지 계산:**
```gdscript
func take_damage(damage: int) -> void:
    var final_damage = damage
    
    if is_defending:
        final_damage = int(damage * defense_multiplier)
        energy -= defense_energy_cost_per_sec * delta
        print("🛡️ 방어! (%.0f → %.0f)" % [damage, final_damage])
    
    health -= final_damage
```

---

### 4. 회피 매커닉 (90분)

**새 변수:**
```gdscript
var is_dodging = false
var dodge_cooldown = 0.5
var dodge_timer = 0
var dodge_speed_multiplier = 2.5
var i_frame_duration = 0.3  # 무적 시간
var current_i_frames = 0.0
```

**실행:**
```gdscript
# Space: 회피
if Input.is_action_just_pressed("ui_accept") and is_on_floor():
    if dodge_timer <= 0:
        dodge()

func dodge():
    is_dodging = true
    dodge_timer = dodge_cooldown
    current_i_frames = i_frame_duration
    energy -= 10
    
    # 캐릭터 방향으로 빠르게 이동
    var direction = -transform.basis.z
    velocity = direction * constants.PLAYER_SPEED * dodge_speed_multiplier
```

**피해 무시:**
```gdscript
# take_damage() 시작에서
if current_i_frames > 0:
    print("🌀 회피 중! 피해 무시")
    return
```

---

### 5. 통합 & 테스트 (60분)

**체크리스트:**
- [ ] 콤보 카운터 작동 확인
- [ ] 에너지 자동 회복 확인
- [ ] 방어 중 피해 50% 감소 확인
- [ ] 회피 무적 시간 확인
- [ ] 무술 + 콤보 보너스 확인
- [ ] 에너지 부족 시 공격 불가 확인

**Git 커밋:**
```bash
git add -A
git commit -m "Day 5: Combo + Defense + Dodge + Energy Recovery system"
```

---

## 📊 예상 코드 변경

| 항목 | 라인 수 |
|------|--------|
| 콤보 시스템 | +30줄 |
| 에너지 회복 | +15줄 |
| 방어 상태 | +40줄 |
| 회피 매커닉 | +50줄 |
| 피해 계산 수정 | +20줄 |
| **총계** | **+155줄** |

---

## ⚠️ 주의사항

1. **i-frame 타이밍**: 회피 시작 시점에 무적 활성화
2. **에너지 관리**: 모든 액션(방어, 회피)이 에너지 소비
3. **콤보 우선순위**: 기본 공격만 콤보 카운트
4. **방어와 회피의 차이**:
   - 방어: 에너지 계속 소비, 느림, 대미지 감소
   - 회피: 에너지 한 번 소비, 빠름, 완전 회피

---

## 🎯 성공 기준

- ✅ 콤보 시스템 작동 (3단 최대)
- ✅ 에너지 초당 2.5 회복
- ✅ 방어 중 피해 50% 감소
- ✅ 회피 중 피해 0% (무적)
- ✅ 모든 기능 에러 없음
- ✅ 플레이 가능한 상태

---

**다음: Day 6 (적 AI 강화)**

_Day 5 완료 후 진행도: 25% → 35%_
