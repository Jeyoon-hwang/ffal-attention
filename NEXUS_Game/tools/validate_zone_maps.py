#!/usr/bin/env python3
"""
validate_zone_maps.py - zone_maps.json 검증 스크립트

기능:
  - JSON 파일 로드 및 파싱
  - 데이터 스키마 검증
  - 존(Zone) 데이터 무결성 확인
  - 성능 분석
  - 상세 리포트 생성

사용법:
  python3 validate_zone_maps.py

작성자: 천재 ⚡
버전: 1.0
"""

import json
import sys
import time
from pathlib import Path
from typing import Dict, List, Any, Tuple

# ============================================================================
# 상수 정의
# ============================================================================

ZONE_NAMES = ["중원", "천산", "황무지", "동해", "흑룡굴"]
EXPECTED_ZONES = 5
EXPECTED_ZONE_SIZE = 500

REQUIRED_ZONE_FIELDS = [
    "id", "name", "description", "size", "difficulty", "theme",
    "heightmap_config", "assets", "dungeons", "npcs", "merchants", "lighting"
]

REQUIRED_HEIGHTMAP_FIELDS = [
    "scale", "persistency", "lacunarity", "octaves", "max_height"
]

REQUIRED_LIGHTING_FIELDS = [
    "sun_angle", "sun_color", "ambient_light", "ambient_color"
]

# ============================================================================
# 검증 함수
# ============================================================================

def validate_json_file(file_path: str) -> Tuple[bool, str, Dict]:
    """JSON 파일 로드 및 파싱"""
    print(f"📂 JSON 파일 로드: {file_path}")
    
    if not Path(file_path).exists():
        return False, f"❌ 파일 없음: {file_path}", {}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print("✓ JSON 파싱 성공")
        return True, "✓ JSON 파일 로드 완료", data
    except json.JSONDecodeError as e:
        return False, f"❌ JSON 파싱 실패: {e}", {}
    except Exception as e:
        return False, f"❌ 파일 읽기 실패: {e}", {}

def validate_zone_count(data: Dict) -> Tuple[bool, str]:
    """존 개수 검증"""
    print("\n📊 존 개수 검증")
    
    if "zones" not in data:
        return False, "❌ zones 필드 없음"
    
    zones = data["zones"]
    if not isinstance(zones, list):
        return False, "❌ zones가 리스트가 아님"
    
    zone_count = len(zones)
    if zone_count != EXPECTED_ZONES:
        return False, f"❌ 존 개수 불일치 (예상: {EXPECTED_ZONES}, 실제: {zone_count})"
    
    print(f"✓ 존 개수 검증 완료 (총 {zone_count}개)")
    return True, f"✓ 존 개수 정확 ({zone_count}개)"

def validate_zone_fields(data: Dict) -> Tuple[bool, List[str]]:
    """각 존의 필드 검증"""
    print("\n🔍 존 필드 검증")
    
    errors = []
    zones = data.get("zones", [])
    
    for zone_id, zone in enumerate(zones):
        # 필수 필드 확인
        for field in REQUIRED_ZONE_FIELDS:
            if field not in zone:
                errors.append(f"Zone {zone_id} ({ZONE_NAMES[zone_id]}): {field} 필드 누락")
        
        # 필드 값 검증
        if zone.get("id") != zone_id:
            errors.append(f"Zone {zone_id}: id 값 불일치 (예상: {zone_id}, 실제: {zone.get('id')})")
        
        if zone.get("name") != ZONE_NAMES[zone_id]:
            errors.append(f"Zone {zone_id}: name 값 불일치 (예상: {ZONE_NAMES[zone_id]}, 실제: {zone.get('name')})")
        
        if zone.get("size") != EXPECTED_ZONE_SIZE:
            errors.append(f"Zone {zone_id}: size 값 불일치 (예상: {EXPECTED_ZONE_SIZE}, 실제: {zone.get('size')})")
        
        # 난이도 범위 검증
        if "difficulty" in zone:
            difficulty = zone["difficulty"]
            if not isinstance(difficulty, list) or len(difficulty) != 2:
                errors.append(f"Zone {zone_id}: difficulty 형식 오류")
            elif difficulty[0] >= difficulty[1]:
                errors.append(f"Zone {zone_id}: difficulty 범위 오류 (최소 >= 최대)")
        
        print(f"  Zone {zone_id} ({zone.get('name', '?')}): ", end="")
        zone_errors = [e for e in errors if e.startswith(f"Zone {zone_id}")]
        if zone_errors:
            print(f"❌ {len(zone_errors)}개 오류")
        else:
            print("✓")
    
    if not errors:
        print("✓ 모든 필드 검증 완료")
    else:
        print(f"❌ 총 {len(errors)}개 오류 발견")
    
    return len(errors) == 0, errors

def validate_heightmap_config(data: Dict) -> Tuple[bool, List[str]]:
    """높이맵 설정 검증"""
    print("\n🗻 높이맵 설정 검증")
    
    errors = []
    zones = data.get("zones", [])
    
    for zone_id, zone in enumerate(zones):
        heightmap = zone.get("heightmap_config", {})
        
        # 필수 필드 확인
        for field in REQUIRED_HEIGHTMAP_FIELDS:
            if field not in heightmap:
                errors.append(f"Zone {zone_id}: heightmap_config.{field} 필드 누락")
        
        # 값 범위 검증
        if "scale" in heightmap:
            scale = heightmap["scale"]
            if not (10 <= scale <= 100):
                errors.append(f"Zone {zone_id}: scale 범위 오류 (값: {scale})")
        
        if "persistency" in heightmap:
            persistency = heightmap["persistency"]
            if not (0.0 <= persistency <= 1.0):
                errors.append(f"Zone {zone_id}: persistency 범위 오류 (값: {persistency})")
        
        if "octaves" in heightmap:
            octaves = heightmap["octaves"]
            if not (1 <= octaves <= 10):
                errors.append(f"Zone {zone_id}: octaves 범위 오류 (값: {octaves})")
        
        zone_errors = [e for e in errors if e.startswith(f"Zone {zone_id}")]
        if zone_errors:
            print(f"  Zone {zone_id}: ❌ {len(zone_errors)}개 오류")
        else:
            print(f"  Zone {zone_id}: ✓")
    
    if not errors:
        print("✓ 높이맵 설정 검증 완료")
    
    return len(errors) == 0, errors

def validate_assets_config(data: Dict) -> Tuple[bool, List[str]]:
    """에셋 설정 검증"""
    print("\n🎨 에셋 설정 검증")
    
    errors = []
    zones = data.get("zones", [])
    
    for zone_id, zone in enumerate(zones):
        assets = zone.get("assets", {})
        
        if not isinstance(assets, dict):
            errors.append(f"Zone {zone_id}: assets가 dict가 아님")
            continue
        
        # 에셋 타입별 검증
        asset_types = ["building", "nature", "props"]
        for asset_type in asset_types:
            if asset_type not in assets:
                errors.append(f"Zone {zone_id}: assets.{asset_type} 필드 누락")
                continue
            
            asset_config = assets[asset_type]
            
            # 필수 필드 확인
            required_fields = ["count", "distribution", "types"]
            for field in required_fields:
                if field not in asset_config:
                    errors.append(f"Zone {zone_id}: assets.{asset_type}.{field} 필드 누락")
            
            # count 값 범위 검증
            if "count" in asset_config:
                count = asset_config["count"]
                if not (1 <= count <= 100):
                    errors.append(f"Zone {zone_id}: assets.{asset_type}.count 범위 오류 (값: {count})")
        
        zone_errors = [e for e in errors if e.startswith(f"Zone {zone_id}")]
        if zone_errors:
            print(f"  Zone {zone_id}: ❌ {len(zone_errors)}개 오류")
        else:
            print(f"  Zone {zone_id}: ✓")
    
    if not errors:
        print("✓ 에셋 설정 검증 완료")
    
    return len(errors) == 0, errors

def validate_lighting_config(data: Dict) -> Tuple[bool, List[str]]:
    """라이팅 설정 검증"""
    print("\n💡 라이팅 설정 검증")
    
    errors = []
    zones = data.get("zones", [])
    
    for zone_id, zone in enumerate(zones):
        lighting = zone.get("lighting", {})
        
        # 필수 필드 확인
        for field in REQUIRED_LIGHTING_FIELDS:
            if field not in lighting:
                errors.append(f"Zone {zone_id}: lighting.{field} 필드 누락")
        
        # ambient_light 범위 검증
        if "ambient_light" in lighting:
            ambient = lighting["ambient_light"]
            if not (0.0 <= ambient <= 1.0):
                errors.append(f"Zone {zone_id}: ambient_light 범위 오류 (값: {ambient})")
        
        zone_errors = [e for e in errors if e.startswith(f"Zone {zone_id}")]
        if zone_errors:
            print(f"  Zone {zone_id}: ❌ {len(zone_errors)}개 오류")
        else:
            print(f"  Zone {zone_id}: ✓")
    
    if not errors:
        print("✓ 라이팅 설정 검증 완료")
    
    return len(errors) == 0, errors

def validate_poi_count(data: Dict) -> Tuple[bool, List[str]]:
    """POI 개수 검증"""
    print("\n📍 POI 개수 검증")
    
    errors = []
    zones = data.get("zones", [])
    
    # 지역별 예상 POI 수
    expected_pois = [10, 16, 13, 21, 27]
    
    for zone_id, zone in enumerate(zones):
        dungeons = zone.get("dungeons", 0)
        npcs = zone.get("npcs", 0)
        merchants = zone.get("merchants", 0)
        
        total_pois = dungeons + npcs + merchants
        expected = expected_pois[zone_id]
        
        if total_pois != expected:
            errors.append(f"Zone {zone_id}: POI 개수 불일치 (예상: {expected}, 실제: {total_pois})")
        
        print(f"  Zone {zone_id}: 던전 {dungeons}, NPC {npcs}, 상인 {merchants} = {total_pois}개", end="")
        zone_errors = [e for e in errors if e.startswith(f"Zone {zone_id}")]
        if zone_errors:
            print(" ❌")
        else:
            print(" ✓")
    
    if not errors:
        print("✓ POI 개수 검증 완료")
    
    return len(errors) == 0, errors

def calculate_statistics(data: Dict) -> Dict:
    """데이터 통계 계산"""
    print("\n📈 데이터 통계")
    
    stats = {
        "total_zones": 0,
        "total_assets": 0,
        "total_pois": 0,
        "total_asset_types": 0,
        "avg_assets_per_zone": 0,
        "avg_pois_per_zone": 0,
        "file_size_kb": 0
    }
    
    zones = data.get("zones", [])
    stats["total_zones"] = len(zones)
    
    for zone in zones:
        assets = zone.get("assets", {})
        asset_count = sum(config.get("count", 0) for config in assets.values() if isinstance(config, dict))
        stats["total_assets"] += asset_count
        
        poi_count = zone.get("dungeons", 0) + zone.get("npcs", 0) + zone.get("merchants", 0)
        stats["total_pois"] += poi_count
    
    if stats["total_zones"] > 0:
        stats["avg_assets_per_zone"] = stats["total_assets"] / stats["total_zones"]
        stats["avg_pois_per_zone"] = stats["total_pois"] / stats["total_zones"]
    
    print(f"  총 존: {stats['total_zones']}개")
    print(f"  총 에셋: {stats['total_assets']}개 (평균: {stats['avg_assets_per_zone']:.1f}개/존)")
    print(f"  총 POI: {stats['total_pois']}개 (평균: {stats['avg_pois_per_zone']:.1f}개/존)")
    
    return stats

# ============================================================================
# 메인 실행
# ============================================================================

def main():
    """메인 검증 함수"""
    print("\n" + "="*80)
    print("🧪 zone_maps.json 검증 스크립트 (Day 22)")
    print("="*80 + "\n")
    
    start_time = time.time()
    
    # 파일 경로
    file_path = Path(__file__).parent.parent / "data" / "zone_maps.json"
    
    # 1단계: JSON 파일 로드
    success, message, data = validate_json_file(str(file_path))
    print(message)
    if not success:
        print("\n❌ 검증 실패!")
        return False
    
    # 2단계: 존 개수 검증
    success, message = validate_zone_count(data)
    print(message)
    if not success:
        return False
    
    # 3단계: 존 필드 검증
    success, errors = validate_zone_fields(data)
    if errors:
        for error in errors:
            print(f"  {error}")
    
    # 4단계: 높이맵 설정 검증
    success, errors = validate_heightmap_config(data)
    if errors:
        for error in errors:
            print(f"  {error}")
    
    # 5단계: 에셋 설정 검증
    success, errors = validate_assets_config(data)
    if errors:
        for error in errors:
            print(f"  {error}")
    
    # 6단계: 라이팅 설정 검증
    success, errors = validate_lighting_config(data)
    if errors:
        for error in errors:
            print(f"  {error}")
    
    # 7단계: POI 개수 검증
    success, errors = validate_poi_count(data)
    if errors:
        for error in errors:
            print(f"  {error}")
    
    # 8단계: 통계 계산
    stats = calculate_statistics(data)
    
    # 완료
    elapsed = time.time() - start_time
    
    print("\n" + "="*80)
    print("✅ 검증 완료!")
    print(f"⏱️  소요시간: {elapsed:.2f}초")
    print("="*80 + "\n")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
