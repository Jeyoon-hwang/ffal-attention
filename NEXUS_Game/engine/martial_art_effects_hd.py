"""
NEXUS 무술 창조 게임 - HD 무술 이펙트 시스템
============================================

작성자: 천재 ⚡
작성일: 2026-05-09 (Week 3 Day 2)
목표: 50+ 무술별 고유 이펙트 정의

주요 기능:
  - 5가지 베이스 파티클 조합
  - 무술별 커스텀 이펙트
  - 라이팅 & 블룸 설정
  - 음향 효과 매핑
  - 성능 프로필 (가벼움/중간/무거움)
"""

from dataclasses import dataclass, asdict, field
from typing import Dict, List, Optional, Tuple
from enum import Enum


# ============================================================================
# 1. 열거형 정의
# ============================================================================

class ParticleBase(Enum):
    """파티클 베이스 타입"""
    FIRE = "fire"
    ICE = "ice"
    LIGHTNING = "lightning"
    WIND = "wind"
    HOLY = "holy"


class EffectIntensity(Enum):
    """이펙트 강도"""
    LIGHT = 0.5
    MEDIUM = 1.0
    HEAVY = 1.5
    EXTREME = 2.0


class AudioEffect(Enum):
    """음향 효과"""
    SLASH = "slash"
    IMPACT = "impact"
    MAGIC = "magic"
    EXPLOSION = "explosion"
    WIND = "wind"
    HOLY = "holy"


# ============================================================================
# 2. 무술 이펙트 정의
# ============================================================================

@dataclass
class MartialArtEffect:
    """무술 이펙트 정의"""
    martial_art_id: str
    name: str
    description: str
    
    # 파티클 조합
    particle_bases: List[str]  # ["fire", "ice", ...] 형태
    intensity: float = 1.0     # 0.5 ~ 2.0
    
    # 라이팅
    has_bloom: bool = False
    bloom_color: Optional[str] = None
    bloom_intensity: float = 1.0
    
    # 라이팅 (광)
    has_light: bool = False
    light_color: Optional[str] = None
    light_range: float = 5.0
    light_energy: float = 1.0
    
    # 음향
    sound_effect: str = "slash"
    sound_volume: float = 1.0
    
    # 성능 프로필
    performance_weight: int = 1  # 1=light, 2=medium, 3=heavy
    
    def to_dict(self):
        return asdict(self)


# ============================================================================
# 3. 무술 이펙트 데이터베이스
# ============================================================================

MARTIAL_ARTS_EFFECTS = {
    # ==================== 검사 (Swordsman) ====================
    "basic_slash": MartialArtEffect(
        martial_art_id="basic_slash",
        name="기본 베기",
        description="단순한 칼날 공격",
        particle_bases=[],  # 기본 물리 공격
        intensity=0.5,
        has_bloom=False,
        sound_effect="slash",
        performance_weight=1
    ),
    
    "power_strike": MartialArtEffect(
        martial_art_id="power_strike",
        name="강력한 일격",
        description="힘을 모아 내려치는 공격",
        particle_bases=["fire"],
        intensity=1.5,
        has_bloom=True,
        bloom_color="#FF6600",
        bloom_intensity=1.5,
        has_light=True,
        light_color="#FF8844",
        light_range=5.0,
        light_energy=1.5,
        sound_effect="impact",
        performance_weight=2
    ),
    
    "spinning_slash": MartialArtEffect(
        martial_art_id="spinning_slash",
        name="회전 베기",
        description="360도 회전하며 베는 공격",
        particle_bases=["wind"],
        intensity=1.0,
        has_bloom=True,
        bloom_color="#66CCFF",
        bloom_intensity=1.0,
        has_light=True,
        light_color="#88DDFF",
        light_range=4.0,
        light_energy=1.2,
        sound_effect="wind",
        performance_weight=2
    ),
    
    "flame_slash": MartialArtEffect(
        martial_art_id="flame_slash",
        name="화염 베기",
        description="불에 휩싸인 칼로 베는 공격",
        particle_bases=["fire"],
        intensity=2.0,
        has_bloom=True,
        bloom_color="#FF4400",
        bloom_intensity=2.0,
        has_light=True,
        light_color="#FF5500",
        light_range=6.0,
        light_energy=2.0,
        sound_effect="magic",
        performance_weight=3
    ),
    
    # ==================== 궁수 (Archer) ====================
    "basic_shot": MartialArtEffect(
        martial_art_id="basic_shot",
        name="기본 사격",
        description="일반 화살 한 발 발사",
        particle_bases=[],
        intensity=0.5,
        has_bloom=False,
        sound_effect="slash",
        performance_weight=1
    ),
    
    "rapid_fire": MartialArtEffect(
        martial_art_id="rapid_fire",
        name="연속 사격",
        description="빠르게 여러 화살을 발사",
        particle_bases=["wind"],
        intensity=1.2,
        has_bloom=True,
        bloom_color="#FFFF00",
        bloom_intensity=1.2,
        has_light=True,
        light_color="#FFCC00",
        light_range=3.0,
        light_energy=1.0,
        sound_effect="wind",
        performance_weight=2
    ),
    
    "fire_arrow": MartialArtEffect(
        martial_art_id="fire_arrow",
        name="불화살",
        description="불이 붙은 화살을 발사",
        particle_bases=["fire"],
        intensity=1.5,
        has_bloom=True,
        bloom_color="#FF6600",
        bloom_intensity=1.5,
        has_light=True,
        light_color="#FF8844",
        light_range=5.0,
        light_energy=1.5,
        sound_effect="magic",
        performance_weight=2
    ),
    
    "ice_arrow": MartialArtEffect(
        martial_art_id="ice_arrow",
        name="얼음화살",
        description="얼음으로 된 화살을 발사",
        particle_bases=["ice"],
        intensity=1.3,
        has_bloom=True,
        bloom_color="#00CCFF",
        bloom_intensity=1.3,
        has_light=True,
        light_color="#44DDFF",
        light_range=4.0,
        light_energy=1.2,
        sound_effect="magic",
        performance_weight=2
    ),
    
    # ==================== 마도사 (Mage) ====================
    "fireball": MartialArtEffect(
        martial_art_id="fireball",
        name="파이어볼",
        description="불의 구체를 발사하는 주문",
        particle_bases=["fire"],
        intensity=2.0,
        has_bloom=True,
        bloom_color="#FF4400",
        bloom_intensity=2.0,
        has_light=True,
        light_color="#FF6600",
        light_range=7.0,
        light_energy=2.0,
        sound_effect="magic",
        performance_weight=3
    ),
    
    "ice_spike": MartialArtEffect(
        martial_art_id="ice_spike",
        name="얼음 가시",
        description="얼음 가시를 소환하는 주문",
        particle_bases=["ice"],
        intensity=1.8,
        has_bloom=True,
        bloom_color="#00DDFF",
        bloom_intensity=1.8,
        has_light=True,
        light_color="#00FFFF",
        light_range=6.0,
        light_energy=1.8,
        sound_effect="magic",
        performance_weight=3
    ),
    
    "lightning_bolt": MartialArtEffect(
        martial_art_id="lightning_bolt",
        name="라이트닝 볼트",
        description="번개를 낙하시키는 주문",
        particle_bases=["lightning"],
        intensity=2.2,
        has_bloom=True,
        bloom_color="#FFFF00",
        bloom_intensity=2.2,
        has_light=True,
        light_color="#FFFF00",
        light_range=8.0,
        light_energy=2.5,
        sound_effect="explosion",
        performance_weight=3
    ),
    
    "meteor": MartialArtEffect(
        martial_art_id="meteor",
        name="메테오",
        description="운석을 소환하는 주문",
        particle_bases=["fire"],
        intensity=2.5,
        has_bloom=True,
        bloom_color="#FF3300",
        bloom_intensity=2.5,
        has_light=True,
        light_color="#FF4400",
        light_range=10.0,
        light_energy=3.0,
        sound_effect="explosion",
        performance_weight=3
    ),
    
    # ==================== 도적 (Rogue) ====================
    "backstab": MartialArtEffect(
        martial_art_id="backstab",
        name="백스탭",
        description="등 뒤에서 찌르는 암살 기술",
        particle_bases=[],
        intensity=0.8,
        has_bloom=False,
        sound_effect="slash",
        performance_weight=1
    ),
    
    "evasion": MartialArtEffect(
        martial_art_id="evasion",
        name="회피",
        description="민첩하게 회피하는 기술",
        particle_bases=["wind"],
        intensity=0.6,
        has_bloom=False,
        sound_effect="wind",
        performance_weight=1
    ),
    
    "shadow_clone": MartialArtEffect(
        martial_art_id="shadow_clone",
        name="그림자 복제",
        description="그림자를 이용한 복제 기술",
        particle_bases=["wind"],
        intensity=1.2,
        has_bloom=True,
        bloom_color="#333333",
        bloom_intensity=0.8,
        has_light=False,
        sound_effect="magic",
        performance_weight=2
    ),
    
    "poison_strike": MartialArtEffect(
        martial_art_id="poison_strike",
        name="독 타격",
        description="독이 묻은 무기로 공격",
        particle_bases=["ice"],
        intensity=1.0,
        has_bloom=True,
        bloom_color="#00FF00",
        bloom_intensity=1.0,
        has_light=True,
        light_color="#00DD00",
        light_range=3.0,
        light_energy=0.8,
        sound_effect="impact",
        performance_weight=1
    ),
    
    # ==================== 기사 (Paladin) ====================
    "shield_bash": MartialArtEffect(
        martial_art_id="shield_bash",
        name="쉴드 배시",
        description="방패로 때리는 공격",
        particle_bases=["holy"],
        intensity=1.2,
        has_bloom=True,
        bloom_color="#FFFF99",
        bloom_intensity=1.2,
        has_light=True,
        light_color="#FFFF88",
        light_range=4.0,
        light_energy=1.2,
        sound_effect="impact",
        performance_weight=2
    ),
    
    "holy_strike": MartialArtEffect(
        martial_art_id="holy_strike",
        name="신성한 일격",
        description="신성한 에너지로 공격",
        particle_bases=["holy"],
        intensity=1.8,
        has_bloom=True,
        bloom_color="#FFFF44",
        bloom_intensity=1.8,
        has_light=True,
        light_color="#FFFF66",
        light_range=6.0,
        light_energy=1.8,
        sound_effect="magic",
        performance_weight=2
    ),
    
    "divine_protection": MartialArtEffect(
        martial_art_id="divine_protection",
        name="신성한 보호",
        description="신성한 방어막을 생성",
        particle_bases=["holy"],
        intensity=1.5,
        has_bloom=True,
        bloom_color="#FFFFAA",
        bloom_intensity=1.5,
        has_light=True,
        light_color="#FFFFCC",
        light_range=5.0,
        light_energy=1.5,
        sound_effect="magic",
        performance_weight=2
    ),
    
    # ==================== 음유시인 (Bard) ====================
    "resonant_note": MartialArtEffect(
        martial_art_id="resonant_note",
        name="공명하는 음표",
        description="음악의 진동으로 공격",
        particle_bases=["wind"],
        intensity=1.0,
        has_bloom=True,
        bloom_color="#FF66FF",
        bloom_intensity=1.0,
        has_light=True,
        light_color="#FF88FF",
        light_range=4.0,
        light_energy=1.0,
        sound_effect="magic",
        performance_weight=2
    ),
    
    "charm_spell": MartialArtEffect(
        martial_art_id="charm_spell",
        name="매혹의 주문",
        description="상대를 매혹시키는 음악",
        particle_bases=["holy"],
        intensity=1.2,
        has_bloom=True,
        bloom_color="#FF99FF",
        bloom_intensity=1.2,
        has_light=True,
        light_color="#FFAAFF",
        light_range=5.0,
        light_energy=1.2,
        sound_effect="magic",
        performance_weight=2
    ),
}


# ============================================================================
# 4. 통계 및 내보내기
# ============================================================================

def count_by_intensity():
    """강도별 무술 개수"""
    stats = {"light": 0, "medium": 0, "heavy": 0, "extreme": 0}
    for art in MARTIAL_ARTS_EFFECTS.values():
        if art.intensity < 0.8:
            stats["light"] += 1
        elif art.intensity < 1.3:
            stats["medium"] += 1
        elif art.intensity < 2.0:
            stats["heavy"] += 1
        else:
            stats["extreme"] += 1
    return stats


def count_by_base():
    """베이스 타입별 무술 개수"""
    stats = {}
    for art in MARTIAL_ARTS_EFFECTS.values():
        if not art.particle_bases:
            base = "physical"
        else:
            base = ",".join(art.particle_bases)
        
        if base not in stats:
            stats[base] = 0
        stats[base] += 1
    return stats


def export_to_dict() -> dict:
    """모든 무술 이펙트를 딕셔너리로 내보내기"""
    return {
        art_id: art.to_dict() 
        for art_id, art in MARTIAL_ARTS_EFFECTS.items()
    }


if __name__ == "__main__":
    print("\n" + "=" * 80)
    print("NEXUS 무술 이펙트 HD 시스템 - 테스트")
    print("=" * 80)
    
    print("\n✅ 등록된 무술 이펙트: %d개\n" % len(MARTIAL_ARTS_EFFECTS))
    
    # 직업별 출력
    professions = {
        "swordsman": ["basic_slash", "power_strike", "spinning_slash", "flame_slash"],
        "archer": ["basic_shot", "rapid_fire", "fire_arrow", "ice_arrow"],
        "mage": ["fireball", "ice_spike", "lightning_bolt", "meteor"],
        "rogue": ["backstab", "evasion", "shadow_clone", "poison_strike"],
        "paladin": ["shield_bash", "holy_strike", "divine_protection"],
        "bard": ["resonant_note", "charm_spell"],
    }
    
    for prof, arts in professions.items():
        print(f"👤 {prof.upper()}:")
        for art_id in arts:
            if art_id in MARTIAL_ARTS_EFFECTS:
                art = MARTIAL_ARTS_EFFECTS[art_id]
                print(f"   ✅ {art.name} (강도: {art.intensity})")
        print()
    
    # 통계
    print("📊 통계:")
    print(f"  강도별: {count_by_intensity()}")
    print(f"  베이스별: {count_by_base()}")
    print(f"  총 무술: {len(MARTIAL_ARTS_EFFECTS)}개")
    
    print("\n" + "=" * 80)
