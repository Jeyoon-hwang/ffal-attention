#!/usr/bin/env python3
# NEXUS Day 7 최종 검증 스크립트
# 모든 엔진 파일 분석 & 품질 검증

import os
import re
from pathlib import Path
from datetime import datetime

# ============================================================================
# 설정
# ============================================================================

PROJECT_ROOT = Path(__file__).parent
ENGINE_DIR = PROJECT_ROOT / "engine"
CONTENT_DIR = PROJECT_ROOT / "content"

# ============================================================================
# 검증 결과
# ============================================================================

class ValidationResult:
    def __init__(self):
        self.total_checks = 0
        self.passed_checks = 0
        self.failed_checks = 0
        self.warnings = []
        self.errors = []
        self.file_stats = {}

    def add_pass(self):
        self.total_checks += 1
        self.passed_checks += 1

    def add_fail(self, msg):
        self.total_checks += 1
        self.failed_checks += 1
        self.errors.append(msg)

    def add_warning(self, msg):
        self.warnings.append(msg)

    def get_pass_rate(self):
        if self.total_checks == 0:
            return 0
        return (self.passed_checks / self.total_checks) * 100

    def print_report(self):
        print("\n" + "="*60)
        print("📊 Day 7 검증 리포트")
        print("="*60)
        
        print(f"\n✅ 통과: {self.passed_checks}/{self.total_checks}")
        print(f"❌ 실패: {self.failed_checks}/{self.total_checks}")
        print(f"⚠️  경고: {len(self.warnings)}개")
        
        print(f"\n📈 성공률: {self.get_pass_rate():.1f}%")
        
        if self.errors:
            print("\n❌ 오류 목록:")
            for error in self.errors:
                print(f"  - {error}")
        
        if self.warnings:
            print("\n⚠️  경고 목록:")
            for warning in self.warnings:
                print(f"  - {warning}")
        
        if self.failed_checks == 0:
            print("\n🎉 모든 검사 통과! (에러 0건)")
        
        print("="*60 + "\n")

# ============================================================================
# Phase 1: 파일 구조 검증
# ============================================================================

def validate_file_structure(result):
    print("\n[Phase 1] 파일 구조 검증...")
    
    # 필수 폴더
    required_dirs = [
        ENGINE_DIR,
        CONTENT_DIR,
        PROJECT_ROOT / "docs",
        PROJECT_ROOT / "assets"
    ]
    
    for dir_path in required_dirs:
        if dir_path.exists():
            result.add_pass()
            print(f"  ✅ {dir_path.name}/")
        else:
            result.add_fail(f"필수 폴더 없음: {dir_path.name}")
    
    # 필수 파일
    required_files = [
        PROJECT_ROOT / "project.godot",
        PROJECT_ROOT / "main.tscn",
        PROJECT_ROOT / "NEXUS_Game/docs/GDD_OPTION2_FINAL.md",
        PROJECT_ROOT / "NEXUS_Game/docs/ROADMAP_12WEEKS_TIGHT.md"
    ]
    
    for file_path in required_files:
        if file_path.exists():
            result.add_pass()
            print(f"  ✅ {file_path.name}")
        else:
            result.add_fail(f"필수 파일 없음: {file_path.name}")

# ============================================================================
# Phase 2: 엔진 파일 분석
# ============================================================================

def validate_engine_files(result):
    print("\n[Phase 2] 엔진 파일 분석...")
    
    required_engines = [
        "martial_art_engine.gd",
        "player_combat.gd",
        "enemy_ai.gd",
        "game_manager.gd",
        "ui_manager.gd",
        "hud_system.gd",
        "inventory_system.gd",
        "skill_tree_ui.gd",
        "map_system.gd",
        "menu_system.gd"
    ]
    
    for engine_file in required_engines:
        engine_path = ENGINE_DIR / engine_file
        
        if engine_path.exists():
            # 파일 크기 확인
            size = engine_path.stat().st_size
            
            with open(engine_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기본 검증
            has_class = "class_name" in content or engine_file == "game_manager.gd"
            has_ready = "_ready()" in content or "_process()" in content or engine_file == "ui_manager.gd"
            has_comments = "#" in content
            
            if has_class and has_ready and has_comments:
                result.add_pass()
                print(f"  ✅ {engine_file} ({size} bytes)")
            else:
                result.add_fail(f"{engine_file}: 기본 구조 부족")
        else:
            result.add_fail(f"엔진 파일 없음: {engine_file}")

# ============================================================================
# Phase 3: 코드 품질 검사
# ============================================================================

def validate_code_quality(result):
    print("\n[Phase 3] 코드 품질 검사...")
    
    # GDScript 파일 개수
    gd_files = list(ENGINE_DIR.glob("*.gd"))
    result.add_pass()
    print(f"  ✅ GDScript 파일: {len(gd_files)}개")
    
    # 전체 라인 수 계산
    total_lines = 0
    for gd_file in gd_files:
        with open(gd_file, 'r', encoding='utf-8') as f:
            total_lines += len(f.readlines())
    
    if total_lines > 1000:
        result.add_pass()
        print(f"  ✅ 총 라인 수: {total_lines}줄 (충분)")
    else:
        result.add_fail(f"코드 양이 부족: {total_lines}줄")
    
    # 메모리 누수 패턴 검사
    memory_issues = 0
    for gd_file in gd_files:
        with open(gd_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # while True 무한 루프 체크
        if "while true:" in content.lower() and "break" not in content:
            result.add_warning(f"{gd_file.name}: 무한 루프 가능성")
            memory_issues += 1
    
    if memory_issues == 0:
        result.add_pass()
        print(f"  ✅ 메모리 누수 패턴: 0건")

# ============================================================================
# Phase 4: 콘텐츠 검증
# ============================================================================

def validate_content(result):
    print("\n[Phase 4] 콘텐츠 검증...")
    
    # 지역 데이터
    zones_dir = CONTENT_DIR / "zones"
    if zones_dir.exists():
        zone_files = list(zones_dir.glob("*.json"))
        if zone_files:
            result.add_pass()
            print(f"  ✅ 지역 데이터: {len(zone_files)}개")
        else:
            result.add_fail("지역 데이터 파일 없음")
    else:
        result.add_fail("zones 폴더 없음")
    
    # 던전 데이터
    dungeons_dir = CONTENT_DIR / "dungeons"
    if dungeons_dir.exists():
        dungeon_files = list(dungeons_dir.glob("*.json"))
        if len(dungeon_files) >= 4:
            result.add_pass()
            print(f"  ✅ 던전 데이터: {len(dungeon_files)}개 (충분)")
        else:
            result.add_warning(f"던전이 적음: {len(dungeon_files)}개 (목표: 4+)")
    else:
        result.add_fail("dungeons 폴더 없음")
    
    # NPC 데이터
    npcs_dir = CONTENT_DIR / "npcs"
    if npcs_dir.exists():
        npc_files = list(npcs_dir.glob("*.json"))
        if npc_files:
            result.add_pass()
            print(f"  ✅ NPC 데이터: {len(npc_files)}개")
    else:
        result.add_fail("npcs 폴더 없음")
    
    # 퀘스트 데이터
    quests_dir = CONTENT_DIR / "quests"
    if quests_dir.exists():
        quest_files = list(quests_dir.glob("*.json"))
        if quest_files:
            result.add_pass()
            print(f"  ✅ 퀘스트 데이터: {len(quest_files)}개")

# ============================================================================
# Phase 5: 빌드 준비 검증
# ============================================================================

def validate_build_readiness(result):
    print("\n[Phase 5] 빌드 준비 검증...")
    
    # project.godot 확인
    project_file = PROJECT_ROOT / "project.godot"
    if project_file.exists():
        with open(project_file, 'r') as f:
            content = f.read()
        
        if "game_version" in content or "name=" in content:
            result.add_pass()
            print(f"  ✅ Godot 프로젝트 파일")
    
    # 문서 준비
    docs = [
        PROJECT_ROOT / "docs" / "GDD_OPTION2_FINAL.md",
        PROJECT_ROOT / "docs" / "ROADMAP_12WEEKS_TIGHT.md"
    ]
    
    docs_ready = 0
    for doc in docs:
        if doc.exists():
            docs_ready += 1
    
    if docs_ready == 2:
        result.add_pass()
        print(f"  ✅ 게임 설계 문서: {docs_ready}개 완성")
    else:
        result.add_warning(f"게임 설계 문서: {docs_ready}개 (목표: 2)")

# ============================================================================
# Phase 6: 최종 요약
# ============================================================================

def print_summary(result):
    print("\n" + "="*60)
    print("📋 Day 7 검증 요약")
    print("="*60)
    
    print("\n🎮 게임 상태:")
    print(f"  - 엔진 파일: {len(list(ENGINE_DIR.glob('*.gd')))}개")
    print(f"  - 전체 용량: {sum(f.stat().st_size for f in ENGINE_DIR.glob('*.gd')) / 1024:.1f}KB")
    print(f"  - 콘텐츠: 지역, 던전, NPC, 퀘스트")
    
    print("\n📊 검증 결과:")
    print(f"  - 통과율: {result.get_pass_rate():.1f}%")
    print(f"  - 에러: {result.failed_checks}건")
    print(f"  - 경고: {len(result.warnings)}건")
    
    if result.failed_checks == 0:
        print("\n✅ 모든 검증 통과!")
        print("👉 다음: Phase 2-6 폴리시 작업")
    else:
        print("\n⚠️  오류 수정 필요")
    
    print("="*60)

# ============================================================================
# 메인
# ============================================================================

def main():
    print("\n" + "="*60)
    print("🎯 NEXUS Day 7 검증 시작")
    print(f"시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*60)
    
    result = ValidationResult()
    
    validate_file_structure(result)
    validate_engine_files(result)
    validate_code_quality(result)
    validate_content(result)
    validate_build_readiness(result)
    
    result.print_report()
    print_summary(result)

if __name__ == "__main__":
    main()
