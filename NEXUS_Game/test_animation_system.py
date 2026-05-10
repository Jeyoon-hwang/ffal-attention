#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_animation_system.py
Day 20-21 - 애니메이션 시스템 생성 테스트
"""

import json
import time
from typing import Dict, List, Any

class AnimationSystemGenerator:
    def __init__(self):
        self.animation_clips = {}
        self.animation_library = {}
        self.start_time = time.time()
    
    def initialize_animation_specs(self):
        """애니메이션 스펙 정의"""
        
        # 플레이어 애니메이션 (20개)
        self.animation_clips["player"] = {
            "idle": {"name": "Player Idle", "duration": 1.5, "fps": 30, "loop": True, "frames": 45},
            "walk": {"name": "Player Walk", "duration": 1.0, "fps": 30, "loop": True, "frames": 30},
            "run": {"name": "Player Run", "duration": 0.8, "fps": 30, "loop": True, "frames": 24},
            "jump": {"name": "Player Jump", "duration": 0.6, "fps": 30, "loop": False, "frames": 18},
            "jump_land": {"name": "Player Jump Land", "duration": 0.5, "fps": 30, "loop": False, "frames": 15},
            "attack_punch": {"name": "Player Attack Punch", "duration": 0.4, "fps": 30, "loop": False, "frames": 12, "attack_frame": 6},
            "attack_kick": {"name": "Player Attack Kick", "duration": 0.5, "fps": 30, "loop": False, "frames": 15, "attack_frame": 8},
            "attack_spin": {"name": "Player Attack Spin", "duration": 0.6, "fps": 30, "loop": False, "frames": 18, "attack_frame": 10},
            "attack_heavy": {"name": "Player Attack Heavy", "duration": 0.7, "fps": 30, "loop": False, "frames": 21, "attack_frame": 12},
            "attack_combo": {"name": "Player Attack Combo", "duration": 1.2, "fps": 30, "loop": False, "frames": 36, "combo_hits": [6, 18, 30]},
            "defend": {"name": "Player Defend", "duration": 0.3, "fps": 30, "loop": True, "frames": 9},
            "dodge_roll": {"name": "Player Dodge Roll", "duration": 0.5, "fps": 30, "loop": False, "frames": 15, "i_frames": [5, 10]},
            "dodge_jump": {"name": "Player Dodge Jump", "duration": 0.6, "fps": 30, "loop": False, "frames": 18, "i_frames": [6, 12]},
            "hit_light": {"name": "Player Hit Light", "duration": 0.3, "fps": 30, "loop": False, "frames": 9},
            "hit_heavy": {"name": "Player Hit Heavy", "duration": 0.5, "fps": 30, "loop": False, "frames": 15},
            "knockdown": {"name": "Player Knockdown", "duration": 0.8, "fps": 30, "loop": False, "frames": 24},
            "stand_up": {"name": "Player Stand Up", "duration": 0.6, "fps": 30, "loop": False, "frames": 18},
            "victory": {"name": "Player Victory", "duration": 1.0, "fps": 30, "loop": False, "frames": 30},
            "defeat": {"name": "Player Defeat", "duration": 1.5, "fps": 30, "loop": False, "frames": 45},
            "interact": {"name": "Player Interact", "duration": 0.8, "fps": 30, "loop": False, "frames": 24},
        }
        
        # 적 애니메이션 (10개)
        self.animation_clips["enemy"] = {
            "idle": {"name": "Enemy Idle", "duration": 1.5, "fps": 30, "loop": True, "frames": 45},
            "walk": {"name": "Enemy Walk", "duration": 1.0, "fps": 30, "loop": True, "frames": 30},
            "run": {"name": "Enemy Run", "duration": 0.8, "fps": 30, "loop": True, "frames": 24},
            "attack": {"name": "Enemy Attack", "duration": 0.5, "fps": 30, "loop": False, "frames": 15, "attack_frame": 8},
            "attack_heavy": {"name": "Enemy Attack Heavy", "duration": 0.7, "fps": 30, "loop": False, "frames": 21, "attack_frame": 12},
            "hit_light": {"name": "Enemy Hit Light", "duration": 0.3, "fps": 30, "loop": False, "frames": 9},
            "hit_heavy": {"name": "Enemy Hit Heavy", "duration": 0.5, "fps": 30, "loop": False, "frames": 15},
            "defend": {"name": "Enemy Defend", "duration": 0.4, "fps": 30, "loop": True, "frames": 12},
            "death": {"name": "Enemy Death", "duration": 1.0, "fps": 30, "loop": False, "frames": 30},
            "roar": {"name": "Enemy Roar", "duration": 0.8, "fps": 30, "loop": False, "frames": 24},
        }
        
        # 몬스터 특화 애니메이션 (10개)
        self.animation_clips["monsters"] = {
            "wolf_growl": {"name": "Wolf Growl", "duration": 0.6, "fps": 30, "loop": False, "frames": 18},
            "wolf_pounce": {"name": "Wolf Pounce", "duration": 0.7, "fps": 30, "loop": False, "frames": 21},
            "bear_swipe": {"name": "Bear Swipe", "duration": 0.8, "fps": 30, "loop": False, "frames": 24},
            "bear_roar": {"name": "Bear Roar", "duration": 1.0, "fps": 30, "loop": False, "frames": 30},
            "skeleton_slash": {"name": "Skeleton Slash", "duration": 0.5, "fps": 30, "loop": False, "frames": 15},
            "skeleton_rattle": {"name": "Skeleton Rattle", "duration": 0.4, "fps": 30, "loop": True, "frames": 12},
            "ghost_float": {"name": "Ghost Float", "duration": 2.0, "fps": 30, "loop": True, "frames": 60},
            "ghost_disappear": {"name": "Ghost Disappear", "duration": 0.5, "fps": 30, "loop": False, "frames": 15},
            "spider_crawl": {"name": "Spider Crawl", "duration": 0.6, "fps": 30, "loop": True, "frames": 18},
            "spider_bite": {"name": "Spider Bite", "duration": 0.4, "fps": 30, "loop": False, "frames": 12},
        }
        
        # 보스 애니메이션 (10개)
        self.animation_clips["boss"] = {
            "boss1_phase1": {"name": "Boss 1 Phase 1", "duration": 1.5, "fps": 30, "loop": False, "frames": 45},
            "boss1_ultimate": {"name": "Boss 1 Ultimate", "duration": 2.0, "fps": 30, "loop": False, "frames": 60},
            "boss2_spin": {"name": "Boss 2 Spin", "duration": 1.2, "fps": 30, "loop": False, "frames": 36},
            "boss2_laser": {"name": "Boss 2 Laser", "duration": 1.5, "fps": 30, "loop": False, "frames": 45},
            "boss3_charge": {"name": "Boss 3 Charge", "duration": 1.0, "fps": 30, "loop": False, "frames": 30},
            "boss3_slam": {"name": "Boss 3 Slam", "duration": 0.8, "fps": 30, "loop": False, "frames": 24},
            "boss4_flight": {"name": "Boss 4 Flight", "duration": 2.0, "fps": 30, "loop": True, "frames": 60},
            "boss4_lightning": {"name": "Boss 4 Lightning", "duration": 1.5, "fps": 30, "loop": False, "frames": 45},
            "boss5_appear": {"name": "Boss 5 Appear", "duration": 2.0, "fps": 30, "loop": False, "frames": 60},
            "boss5_final": {"name": "Boss 5 Final Attack", "duration": 3.0, "fps": 30, "loop": False, "frames": 90},
        }
        
        print(f"[Template] {len(self.animation_clips)}가지 애니메이션 카테고리 로드됨")
    
    def generate_all_animations(self):
        """모든 애니메이션 생성"""
        total_clips = 0
        
        for category, clips in self.animation_clips.items():
            self.animation_library[category] = {}
            for clip_name, clip_data in clips.items():
                processed_clip = self.process_animation_clip(category, clip_name, clip_data)
                self.animation_library[category][clip_name] = processed_clip
                total_clips += 1
        
        print(f"[Generated] 총 {total_clips}개 애니메이션 클립 생성됨")
    
    def process_animation_clip(self, category: str, name: str, spec: Dict) -> Dict:
        """애니메이션 클립 처리"""
        clip = {
            "id": f"{category}_{name}",
            "category": category,
            "name": spec.get("name", name),
            "duration": spec.get("duration", 1.0),
            "fps": spec.get("fps", 30),
            "frames": spec.get("frames", 30),
            "loop": spec.get("loop", False),
            "blend_in": spec.get("blend_in", 0.1),
            "blend_out": spec.get("blend_out", 0.1),
            "performance": {
                "memory_kb": self.calculate_memory_usage(spec.get("frames", 30)),
                "playback_speed": self.calculate_playback_speed(
                    spec.get("duration", 1.0), 
                    spec.get("frames", 30)
                ),
                "is_optimized": True
            },
            "metadata": {
                "created_at": int(time.time() * 1000),
                "version": "1.0",
                "compatible_with": self.determine_compatible_entities(category)
            }
        }
        
        # 추가 속성 병합
        for key, value in spec.items():
            if key not in clip:
                clip[key] = value
        
        return clip
    
    def calculate_memory_usage(self, frame_count: int) -> float:
        """메모리 사용량 (KB)"""
        kb_per_frame = 2.5
        return frame_count * kb_per_frame
    
    def calculate_playback_speed(self, duration: float, frame_count: int) -> float:
        """재생 속도 계산"""
        if duration == 0:
            return 1.0
        return float(frame_count) / duration / 30.0
    
    def determine_compatible_entities(self, category: str) -> List:
        """호환 엔티티"""
        compatibility = {
            "player": ["player_character"],
            "enemy": ["all_enemies"],
            "monsters": ["wolf", "bear", "skeleton", "ghost", "spider"],
            "boss": ["boss_1", "boss_2", "boss_3", "boss_4", "boss_5"]
        }
        return compatibility.get(category, [])
    
    def get_total_clip_count(self) -> int:
        """총 클립 개수"""
        total = 0
        for category in self.animation_library.values():
            total += len(category)
        return total
    
    def get_category_stats(self) -> Dict:
        """카테고리별 통계"""
        stats = {}
        for category, clips in self.animation_library.items():
            stats[category] = len(clips)
        return stats
    
    def calculate_total_duration(self) -> float:
        """총 재생 시간"""
        total = 0.0
        for category in self.animation_library.values():
            for clip in category.values():
                total += clip.get("duration", 0.0)
        return total
    
    def calculate_total_frames(self) -> int:
        """총 프레임 수"""
        total = 0
        for category in self.animation_library.values():
            for clip in category.values():
                total += clip.get("frames", 0)
        return total
    
    def export_animations_to_json(self):
        """JSON 내보내기"""
        export_data = {
            "metadata": {
                "generated_at": int(time.time() * 1000),
                "generator": "AnimationSystemGenerator v1.0",
                "total_clips": self.get_total_clip_count(),
                "categories": self.get_category_stats(),
                "total_duration": self.calculate_total_duration(),
                "total_frames": self.calculate_total_frames()
            },
            "animation_library": self.animation_library
        }
        
        file_path = "animations.json"
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(export_data, f, indent=2, ensure_ascii=False)
            print(f"[Export] 애니메이션 JSON 저장됨: {file_path}")
        except Exception as e:
            print(f"[Error] 파일 저장 실패: {e}")
    
    def print_generation_summary(self):
        """생성 요약"""
        elapsed = time.time() - self.start_time
        print("\n" + "="*70)
        print("[AnimationSystemGenerator] 생성 완료!")
        print("="*70)
        print(f"총 애니메이션: {self.get_total_clip_count()}개")
        print(f"총 프레임: {self.calculate_total_frames()}개")
        print(f"총 재생 시간: {self.calculate_total_duration():.1f}초")
        print(f"소요 시간: {elapsed:.3f}초")
        print("\n카테고리별 분포:")
        stats = self.get_category_stats()
        for category in sorted(stats.keys()):
            print(f"  - {category}: {stats[category]}개")
        print("="*70 + "\n")
    
    def run(self):
        """실행"""
        print("[AnimationSystemGenerator] 초기화 시작...")
        self.initialize_animation_specs()
        self.generate_all_animations()
        self.export_animations_to_json()
        self.print_generation_summary()
        
        # 상세 정보 (샘플)
        print("[상세 애니메이션 목록 - 샘플]")
        player_anims = self.animation_library.get("player", {})
        for i, (name, clip) in enumerate(list(player_anims.items())[:3]):
            print(f"  - {clip['name']}")
            print(f"    • 프레임: {clip['frames']}개, 재생시간: {clip['duration']:.1f}초")
            print(f"    • 메모리: {clip['performance']['memory_kb']:.1f}KB")
        print(f"\n... 플레이어 애니메이션 그 외 {len(player_anims) - 3}개")


def main():
    print("🎬 Day 20-21 - 애니메이션 시스템 생성 테스트\n")
    
    generator = AnimationSystemGenerator()
    generator.run()
    
    print("✅ 애니메이션 생성 완료!")


if __name__ == "__main__":
    main()
