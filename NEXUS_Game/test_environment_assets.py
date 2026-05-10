#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_environment_assets.py
Day 19 - 환경 에셋 생성 테스트
"""

import json
import time
from datetime import datetime
from typing import Dict, List, Any
import random

class EnvironmentAssetGenerator:
    def __init__(self):
        self.asset_templates = {}
        self.generated_assets = []
        self.start_time = time.time()
    
    def initialize_asset_templates(self):
        """에셋 템플릿 정의"""
        
        # 건물 (5가지)
        self.asset_templates["house"] = {
            "name": "House",
            "category": "Building",
            "variations": 3,
            "scale_range": (1.0, 1.5, 1.0),
            "color_variations": ["wood_brown", "stone_gray", "white"],
            "complexity": "medium"
        }
        
        self.asset_templates["tower"] = {
            "name": "Tower",
            "category": "Building",
            "variations": 2,
            "scale_range": (0.8, 2.5, 0.8),
            "color_variations": ["stone_gray", "dark_stone"],
            "complexity": "high"
        }
        
        self.asset_templates["temple"] = {
            "name": "Temple",
            "category": "Building",
            "variations": 2,
            "scale_range": (1.5, 2.0, 1.5),
            "color_variations": ["red_wood", "gold_trim"],
            "complexity": "high"
        }
        
        self.asset_templates["wall"] = {
            "name": "Wall",
            "category": "Building",
            "variations": 1,
            "scale_range": (3.0, 1.5, 0.3),
            "color_variations": ["stone_gray", "dark_wood"],
            "complexity": "low"
        }
        
        self.asset_templates["gate"] = {
            "name": "Gate",
            "category": "Building",
            "variations": 2,
            "scale_range": (1.5, 2.0, 0.3),
            "color_variations": ["dark_wood", "iron_black"],
            "complexity": "medium"
        }
        
        # 자연 (5가지)
        self.asset_templates["tree"] = {
            "name": "Tree",
            "category": "Nature",
            "variations": 4,
            "scale_range": (0.6, 1.8, 0.6),
            "color_variations": ["green_dark", "green_bright", "autumn_red"],
            "complexity": "medium"
        }
        
        self.asset_templates["rock"] = {
            "name": "Rock",
            "category": "Nature",
            "variations": 5,
            "scale_range": (0.5, 1.0, 0.5),
            "color_variations": ["gray", "brown", "dark_gray"],
            "complexity": "low"
        }
        
        self.asset_templates["grass"] = {
            "name": "GrassPatch",
            "category": "Nature",
            "variations": 1,
            "scale_range": (2.0, 0.1, 2.0),
            "color_variations": ["green"],
            "complexity": "low"
        }
        
        self.asset_templates["bush"] = {
            "name": "Bush",
            "category": "Nature",
            "variations": 3,
            "scale_range": (0.7, 1.0, 0.7),
            "color_variations": ["green_dark", "green_medium"],
            "complexity": "low"
        }
        
        self.asset_templates["mushroom_group"] = {
            "name": "MushroomGroup",
            "category": "Nature",
            "variations": 2,
            "scale_range": (0.4, 0.5, 0.4),
            "color_variations": ["red_white", "brown"],
            "complexity": "low"
        }
        
        # 소품 (5가지)
        self.asset_templates["bench"] = {
            "name": "Bench",
            "category": "Props",
            "variations": 2,
            "scale_range": (1.0, 0.8, 0.4),
            "color_variations": ["brown_wood", "stone_gray"],
            "complexity": "low"
        }
        
        self.asset_templates["lamp"] = {
            "name": "Lamp",
            "category": "Props",
            "variations": 2,
            "scale_range": (0.3, 1.5, 0.3),
            "color_variations": ["iron_black", "bronze"],
            "complexity": "medium"
        }
        
        self.asset_templates["fence"] = {
            "name": "Fence",
            "category": "Props",
            "variations": 2,
            "scale_range": (2.0, 1.0, 0.2),
            "color_variations": ["brown_wood", "light_wood"],
            "complexity": "low"
        }
        
        self.asset_templates["well"] = {
            "name": "Well",
            "category": "Props",
            "variations": 1,
            "scale_range": (0.8, 1.2, 0.8),
            "color_variations": ["stone_gray", "brown_wood"],
            "complexity": "medium"
        }
        
        self.asset_templates["statue"] = {
            "name": "Statue",
            "category": "Props",
            "variations": 2,
            "scale_range": (0.6, 1.5, 0.6),
            "color_variations": ["stone_white", "bronze"],
            "complexity": "medium"
        }
        
        print(f"[Template] {len(self.asset_templates)}가지 에셋 템플릿 로드됨")
    
    def generate_all_assets(self):
        """모든 템플릿에서 에셋 생성"""
        total = 0
        
        for asset_type, template in self.asset_templates.items():
            variations = template.get("variations", 1)
            
            for i in range(variations):
                asset = self.generate_single_asset(asset_type, i)
                self.generated_assets.append(asset)
                total += 1
        
        print(f"[Generated] 총 {total}개 에셋 생성됨")
    
    def generate_single_asset(self, asset_type: str, variation_index: int) -> Dict:
        """단일 에셋 생성"""
        template = self.asset_templates[asset_type]
        color_variations = template.get("color_variations", ["default"])
        
        asset = {
            "id": f"{asset_type}_{variation_index}",
            "type": asset_type,
            "category": template.get("category", "Unknown"),
            "name": f"{template.get('name', 'Asset')} Variation {variation_index + 1}",
            "variation": variation_index,
            "scale": self.generate_random_scale(template.get("scale_range", (1, 1, 1))),
            "color": color_variations[variation_index % len(color_variations)],
            "vertices": self.generate_procedural_mesh_stats(asset_type, variation_index),
            "polygons": self.generate_polygon_count(asset_type),
            "material": self.generate_material_spec(asset_type),
            "collision": self.generate_collision_shape(asset_type),
            "performance": {
                "lod0": 100,  # 기본 품질
                "lod1": 50,   # 중간 거리
                "lod2": 25,   # 먼 거리
                "is_optimized": True
            },
            "metadata": {
                "created_at": int(time.time() * 1000),
                "generator_version": "1.0",
                "complexity": template.get("complexity", "medium"),
                "batch_compatible": True
            }
        }
        
        return asset
    
    def generate_random_scale(self, scale_range):
        """스케일 범위 내에서 랜덤 스케일 생성"""
        return [
            round(random.uniform(scale_range[0] * 0.8, scale_range[0] * 1.2), 2),
            round(random.uniform(scale_range[1] * 0.8, scale_range[1] * 1.2), 2),
            round(random.uniform(scale_range[2] * 0.8, scale_range[2] * 1.2), 2)
        ]
    
    def generate_procedural_mesh_stats(self, asset_type: str, variation_index: int) -> int:
        """절차형 메시 정점 수 계산"""
        base_vertices = {
            "house": 120,
            "tower": 180,
            "temple": 250,
            "wall": 80,
            "gate": 140,
            "tree": 200,
            "rock": 60,
            "grass": 30,
            "bush": 90,
            "mushroom_group": 50,
            "bench": 70,
            "lamp": 100,
            "fence": 60,
            "well": 110,
            "statue": 150
        }
        
        base = base_vertices.get(asset_type, 80)
        variance = random.randint(-15, 15)
        return max(20, base + variance)
    
    def generate_polygon_count(self, asset_type: str) -> int:
        """폴리곤 수 계산"""
        base_polygons = {
            "house": 40,
            "tower": 60,
            "temple": 85,
            "wall": 25,
            "gate": 45,
            "tree": 65,
            "rock": 20,
            "grass": 10,
            "bush": 30,
            "mushroom_group": 15,
            "bench": 23,
            "lamp": 33,
            "fence": 20,
            "well": 35,
            "statue": 50
        }
        
        return base_polygons.get(asset_type, 25)
    
    def generate_material_spec(self, asset_type: str) -> Dict:
        """머티리얼 사양"""
        category_to_material = {
            "Building": "masonry",
            "Nature": "vegetation",
            "Props": "crafted"
        }
        
        category = ""
        if asset_type in self.asset_templates:
            category = self.asset_templates[asset_type].get("category", "Unknown")
        
        return {
            "type": category_to_material.get(category, "default"),
            "roughness": 0.7,
            "metallic": 0.0,
            "normal_map": True,
            "has_alpha": False
        }
    
    def generate_collision_shape(self, asset_type: str) -> Dict:
        """충돌 형태"""
        shapes = {
            "house": "box",
            "tower": "cylinder",
            "temple": "box",
            "wall": "box",
            "gate": "box",
            "tree": "cylinder",
            "rock": "sphere",
            "grass": "plane",
            "bush": "sphere",
            "mushroom_group": "capsule",
            "bench": "box",
            "lamp": "cylinder",
            "fence": "box",
            "well": "cylinder",
            "statue": "capsule"
        }
        
        return {
            "shape": shapes.get(asset_type, "box"),
            "enabled": asset_type not in ["grass", "mushroom_group"],
            "is_static": True
        }
    
    def get_category_stats(self) -> Dict:
        """카테고리별 통계"""
        stats = {}
        for asset in self.generated_assets:
            cat = asset.get("category", "Unknown")
            if cat not in stats:
                stats[cat] = 0
            stats[cat] += 1
        return stats
    
    def calculate_total_vertices(self) -> int:
        """총 정점 수"""
        return sum(asset.get("vertices", 0) for asset in self.generated_assets)
    
    def calculate_total_polygons(self) -> int:
        """총 폴리곤 수"""
        return sum(asset.get("polygons", 0) for asset in self.generated_assets)
    
    def export_assets_to_json(self):
        """JSON으로 내보내기"""
        export_data = {
            "metadata": {
                "generated_at": int(time.time() * 1000),
                "generator": "EnvironmentAssetGenerator v1.0",
                "total_assets": len(self.generated_assets),
                "categories": self.get_category_stats(),
                "total_vertices": self.calculate_total_vertices(),
                "total_polygons": self.calculate_total_polygons()
            },
            "assets": self.generated_assets
        }
        
        file_path = "environment_assets.json"
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(export_data, f, indent=2, ensure_ascii=False)
            print(f"[Export] 환경 에셋 JSON 저장됨: {file_path}")
        except Exception as e:
            print(f"[Error] 파일 저장 실패: {e}")
    
    def print_generation_summary(self):
        """생성 요약"""
        elapsed = time.time() - self.start_time
        print("\n" + "="*70)
        print("[EnvironmentAssetGenerator] 생성 완료!")
        print("="*70)
        print(f"총 에셋: {len(self.generated_assets)}개")
        print(f"총 정점: {self.calculate_total_vertices()}개")
        print(f"총 폴리곤: {self.calculate_total_polygons()}개")
        print(f"소요 시간: {elapsed:.3f}초")
        print("\n카테고리별 분포:")
        stats = self.get_category_stats()
        for category in sorted(stats.keys()):
            print(f"  - {category}: {stats[category]}개")
        print("="*70 + "\n")
    
    def run(self):
        """실행"""
        print("[EnvironmentAssetGenerator] 초기화 시작...")
        self.initialize_asset_templates()
        self.generate_all_assets()
        self.export_assets_to_json()
        self.print_generation_summary()
        
        # 상세 정보 출력
        print("\n[상세 에셋 목록]")
        for asset in self.generated_assets[:5]:  # 처음 5개만 샘플
            print(f"  - {asset['id']}: {asset['name']}")
            print(f"    • 스케일: {asset['scale']}")
            print(f"    • 정점: {asset['vertices']}개, 폴리곤: {asset['polygons']}개")
        print(f"\n... 그 외 {len(self.generated_assets) - 5}개")


def main():
    print("🎨 Day 19 - 환경 에셋 자동 생성 테스트\n")
    
    generator = EnvironmentAssetGenerator()
    generator.run()
    
    print("✅ 테스트 완료!")


if __name__ == "__main__":
    main()
