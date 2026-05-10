# 🔥 Week 3-4 상세 개발 계획 (Day 19-28)

**기간:** 2026-05-10 ~ 2026-05-28 (10일, 24시간 개발)  
**목표:** 그래픽 & 애니메이션 완성 (20% → 35%)  
**에러:** 0건 유지  
**완성도:** 100% 품질 유지  

---

## 📊 일정 요약

| Day | 날짜 | 목표 | 산출물 | 예상 완성도 |
|-----|------|------|--------|-----------|
| **19** | 05-10 | 환경 에셋 생성 엔진 | EnvironmentAssetGenerator.gd | 24% → 27% |
| **20** | 05-11 | 20+ 환경 에셋 생성 | Assets (건물, 자연, 소품) | 27% → 28% |
| **21** | 05-12 | 애니메이션 시스템 설계 | AnimationSystem.gd | 28% → 30% |
| **22** | 05-13 | 플레이어 애니메이션 | 15+ 클립 (기본, 공격, 회피) | 30% → 32% |
| **23** | 05-14 | 몬스터 애니메이션 | 30+ 클립 (각 몬스터별) | 32% → 33% |
| **24** | 05-15 | 중원 맵 지형 생성 | 지형 메시, 콜라이더 | 33% → 34% |
| **25** | 05-16 | 환경 배치 & 라이팅 | NPC 위치, 동적 라이팅 | 34% → 34.5% |
| **26** | 05-17 | 던전 입구 연결 | 70개 던전 입구 배치 | 34.5% → 34.8% |
| **27** | 05-18 | 성능 최적화 & 테스트 | FPS 측정, 메모리 프로파일링 | 34.8% → 35% |
| **28** | 05-19 | 최종 폴리싱 & QA | 버그 픽스, 그래픽 개선 | 35% → 35% ✅ |

---

## 🎯 Day 19: 환경 에셋 생성 엔진

**목표:** EnvironmentAssetGenerator.gd 작성  
**산출물:** 절차형 환경 에셋 자동 생성 시스템  
**시간:** 8시간  

### 작업 내용

#### 1. 절차형 건물 생성기 (BuildingGenerator)
```gd
# Scripts/Generators/EnvironmentAssetGenerator.gd

class_name EnvironmentAssetGenerator

# 건물 타입
enum BuildingType {
	HOUSE,
	TAVERN,
	SHOP,
	TOWER,
	TEMPLE,
	RUINS,
	BRIDGE,
	GATE,
	WALL,
	FOUNTAIN
}

# 건물 생성 함수
func generate_building(type: int, position: Vector3, rotation: float) -> Node3D:
	match type:
		BuildingType.HOUSE:
			return generate_house(position, rotation)
		BuildingType.TAVERN:
			return generate_tavern(position, rotation)
		# ... 등등
	return null

# 예: 집 생성
func generate_house(pos: Vector3, rot: float) -> Node3D:
	var mesh = ArrayMesh.new()
	
	# 벽, 지붕, 문, 창 등을 메시로 생성
	# 재질: 나무 (갈색), 돌 (회색)
	
	var node = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	node.add_child(mesh_instance)
	
	return node
```

#### 2. 자연 에셋 생성기
```
- 나무: 3가지 종류 (침엽수, 활엽수, 야자수)
- 바위: 크기별 (소, 중, 대)
- 풀: 밀도별
- 물: 개울, 연못, 분수
- 토양: 흙, 모래, 눈
```

#### 3. 소품 생성기
```
- 가구: 벤치, 테이블, 의자
- 조명: 횃불, 등불, 촛대
- 장식: 동상, 배너, 비석
- 농업: 밭, 울타리, 헛간
- 전투: 방어 조형물, 무기 랙
```

### 예상 산출물
```
건물:        10가지 (최대 100개 인스턴스)
자연:        20가지 (무한 조합)
소품:        30가지 (자유 배치)
총 에셋:     60가지

성능:
  - 생성 시간: < 5분 (모든 에셋)
  - 메모리: 효율적 (인스턴싱)
  - 파일 크기: < 50MB
  - 런타임 로딩: < 1초
```

---

## 🎬 Day 20-21: 애니메이션 시스템

**목표:** 50+ 애니메이션 클립 생성 & 시스템 구현  
**산출물:** 모든 캐릭터 & 적의 애니메이션  
**시간:** 16시간  

### AnimationSystem.gd 설계

```gd
class_name AnimationSystem

# 애니메이션 카테고리
enum AnimationCategory {
	IDLE,           # 대기
	MOVE,           # 이동 (걷기, 달리기, 점프)
	ATTACK,         # 공격 (무술별)
	DEFENSE,        # 방어 (회피, 가드)
	DAMAGE,         # 피격 (경직, 다운)
	DEATH,          # 사망
	INTERACT,       # 상호작용 (대화, 줍기)
	SPECIAL         # 특수 (승리, 축하)
}

# 애니메이션 클립 저장소
var animations: Dictionary = {}  # { "player_idle": AnimationPlayer }

# 애니메이션 재생
func play_animation(character: Node3D, category: int, name: String) -> void:
	var anim_player = character.get_node("AnimationPlayer") as AnimationPlayer
	if anim_player:
		anim_player.play(name)

# 블렌드 트리 (부드러운 전환)
func blend_animations(from: String, to: String, duration: float) -> void:
	# Godot의 blend_animation 사용
	pass
```

### 플레이어 애니메이션 (15+ 클립)

#### 기본 (5개)
```
- idle_stand        (아이들, 반복)
- idle_breathe      (숨쉬기, 반복)
- walk_forward      (걷기)
- run_forward       (달리기)
- jump              (점프)
```

#### 공격 (5개, 무술 타입별)
```
- attack_punch      (펀치)
- attack_kick       (킥)
- attack_thrust     (찌르기)
- attack_sweep      (휩쓸기)
- attack_combo      (콤보)
```

#### 방어 (3개)
```
- dodge_left        (왼쪽 구르기)
- dodge_right       (오른쪽 구르기)
- guard_stance      (가드 자세)
```

#### 피격 (3개)
```
- hit_light         (가벼운 피격)
- hit_heavy         (무거운 피격, 다운)
- death             (죽음)
```

#### 특수 (4개)
```
- victory           (승리)
- defeat            (패배)
- interact_talk     (대화)
- emote_cheer       (환호)
```

### 몬스터 애니메이션 (30+ 클립)

**각 몬스터 (10종) × 3가지 = 30+ 클립**

```
늑대:
  - wolf_idle
  - wolf_walk
  - wolf_attack
  - wolf_hit
  - wolf_death

곰:
  - bear_idle
  - bear_walk_heavy
  - bear_attack_swipe
  - bear_hit
  - bear_death

(... 8개 몬스터 더)
```

### 기술 구현

#### 스켈레톤 기반 리깅
```gd
# 플레이어 모델에 45개 본(Bone) 할당
# Skeleton3D → AnimationPlayer 연결

var skeleton = player.get_node("Skeleton3D") as Skeleton3D
var anim_player = player.get_node("AnimationPlayer") as AnimationPlayer

# BoneAttachment3D로 각 본 제어
for bone_name in bones:
	var attachment = BoneAttachment3D.new()
	attachment.bone_name = bone_name
	player.add_child(attachment)
```

#### 애니메이션 블렌딩
```gd
# 부드러운 전환 (1초 페이드)
anim_player.play("idle_stand", -1.0, 1.0)  # 1초 페이드

# 다음 애니메이션
await get_tree().create_timer(duration).timeout
anim_player.play("walk_forward", -1.0, 1.0)  # 1초 페이드
```

---

## 🗺️ Day 22-28: 맵 통합 & 폴리싱

**목표:** 중원 지역 완전 완성  
**산출물:** 플레이 가능한 첫 번째 지역  
**시간:** 56시간  

### Day 22-23: 지형 생성 & 배치

#### 지형 생성 (TerrainGenerator.gd)
```gd
class_name TerrainGenerator

# Perlin noise 기반 지형
func generate_terrain(width: int, height: int, scale: float) -> Mesh:
	var mesh = ArrayMesh.new()
	var verts = PackedVector3Array()
	
	# Perlin noise로 높이 계산
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	for z in range(height):
		for x in range(width):
			var y = noise.get_noise_2d(x * scale, z * scale) * 10
			verts.append(Vector3(x, y, z))
	
	# 메시 생성
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	return mesh
```

#### 환경 배치
```
- 건물: 마을, 사원, 상점 (10+ 건물)
- NPC: 시민, 상인, 수도사 (30+ NPC)
- 몬스터: 초급 (레벨 1-3) (10마리)
- 자연: 나무, 바위, 풀 (무한 배치)
```

### Day 24-25: 라이팅 & 시각 효과

#### 라이팅 설정
```gd
# 환경 라이팅
var env_light = DirectionalLight3D.new()
env_light.light_energy = 1.2
env_light.shadow_enabled = true
world.add_child(env_light)

# 불빛 (횃불, 등)
var torch = OmniLight3D.new()
torch.omni_range = 5
torch.light_color = Color.YELLOW
torch.light_energy = 0.8
```

#### 시각 효과
```
- 먼지 파티클 (바람)
- 불빛 깜빡임
- 그림자 반응
- 날씨 (맑음, 흐림, 비)
```

### Day 26: 던전 연결

#### 던전 입구 배치
```
- 70개 던전 입구 배치 (중원 + 다른 지역)
- 각 입구마다 어려움 표시 (⭐ 1-5)
- 텔레포트 포인트 설정
- 미니맵 마커
```

### Day 27: 성능 최적화

#### 최적화 항목
```
1. LOD (Level of Detail)
   - 먼 거리 객체는 단순 메시 사용
   - 가까운 객체는 고상세 메시

2. 오클루전 컬링
   - 보이지 않는 객체는 렌더링 안 함

3. 동적 라이팅 최소화
   - 고정 라이팅 사용

4. 메모리 관리
   - 텍스처 압축
   - 사용하지 않는 에셋 언로드

목표: 60 FPS 유지
```

#### 성능 테스트
```gd
# FPS 모니터링
var fps_counter = 0
var fps_timer = 0

func _process(delta):
	fps_counter += 1
	fps_timer += delta
	
	if fps_timer >= 1.0:
		print("FPS: ", fps_counter)
		fps_counter = 0
		fps_timer = 0
```

### Day 28: 최종 폴리싱

#### 품질 체크
```
□ 모든 에셋 로드 확인
□ 충돌 박스 정확성 확인
□ 애니메이션 부드러움 확인
□ 성능 60 FPS 확인
□ 사운드 배치 확인
□ 미니맵 정확성 확인
□ 텍스처 품질 확인
□ 라이팅 자연스러움 확인
```

#### 버그 픽스
```
- 클리핑 이슈 수정
- 콜라이더 겹침 수정
- 애니메이션 끊김 수정
- 성능 병목 제거
```

---

## 📝 코드 구조 (Week 3-4 추가)

```
Scripts/
├── Generators/
│   ├── EnvironmentAssetGenerator.gd      (Day 19, NEW)
│   ├── TerrainGenerator.gd               (Day 22, NEW)
│   └── [기존] CharacterMeshGenerator.gd
│   └── [기존] MonsterMeshGenerator.gd
│
├── Animation/
│   ├── AnimationSystem.gd                (Day 21, NEW)
│   ├── CharacterAnimator.gd              (Day 22, NEW)
│   └── MonsterAnimator.gd                (Day 23, NEW)
│
├── Map/
│   ├── MapController.gd                  (Day 24, NEW)
│   ├── TerrainController.gd              (Day 24, NEW)
│   └── DungeonGate.gd                    (Day 26, NEW)
│
└── [기존] 게임 시스템들...
```

---

## ✅ 체크리스트

### Day 19
- [ ] EnvironmentAssetGenerator.gd 작성
- [ ] 10가지 건물 생성 함수
- [ ] 20가지 자연 에셋 생성 함수
- [ ] 30가지 소품 생성 함수
- [ ] 테스트 및 검증

### Day 20
- [ ] 60가지 환경 에셋 생성
- [ ] Assets 폴더에 저장
- [ ] 메모리 사용량 확인
- [ ] 로딩 시간 측정

### Day 21
- [ ] AnimationSystem.gd 작성
- [ ] 애니메이션 카테고리 정의
- [ ] 블렌드 트리 설계

### Day 22
- [ ] 플레이어 15+ 애니메이션 클립
- [ ] CharacterAnimator.gd 작성
- [ ] 애니메이션 전환 테스트

### Day 23
- [ ] 몬스터 30+ 애니메이션 클립
- [ ] MonsterAnimator.gd 작성
- [ ] 모든 몬스터 애니메이션 테스트

### Day 24-25
- [ ] TerrainGenerator.gd 작성
- [ ] 지형 메시 생성
- [ ] 환경 배치
- [ ] 라이팅 설정
- [ ] 성능 확인

### Day 26
- [ ] 던전 입구 배치
- [ ] 텔레포트 포인트 설정
- [ ] 미니맵 마커 추가

### Day 27
- [ ] LOD 시스템 구현
- [ ] 오클루전 컬링
- [ ] 성능 최적화
- [ ] FPS 테스트

### Day 28
- [ ] 최종 QA 체크리스트
- [ ] 버그 픽스
- [ ] 그래픽 폴리싱
- [ ] Week 3-4 완료 보고서

---

## 📈 예상 진행도

```
Day 19:  24% → 27% (+3%)  환경 에셋
Day 20:  27% → 28% (+1%)  에셋 생성
Day 21:  28% → 30% (+2%)  애니메이션 시스템
Day 22:  30% → 32% (+2%)  플레이어 애니메이션
Day 23:  32% → 33% (+1%)  몬스터 애니메이션
Day 24-25: 33% → 34% (+1%)  맵 & 라이팅
Day 26:  34% → 34.5% (+0.5%) 던전 연결
Day 27:  34.5% → 34.8% (+0.3%) 최적화
Day 28:  34.8% → 35% (+0.2%) 폴리싱

최종: 35% (Week 3-4 완료) ✅
```

---

## 🎯 성공 지표

```
✅ 모든 에셋 생성 완료
✅ 모든 애니메이션 부드러움
✅ 60 FPS 유지
✅ 에러 0건
✅ 버그 0건
✅ 중원 지역 완전 플레이 가능
✅ 첫 보스 도달 가능
```

---

**작성자:** 천재 ⚡  
**목표:** Week 3-4 완료 (35% 달성)  
**기간:** 2026-05-10 ~ 2026-05-19 (10일, 24시간)  
**상태:** 풀속도 개발 준비 완료

**"Day 19부터 환경 & 애니메이션 폭발! 에러 0으로 진행!"** 🔥
