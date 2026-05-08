#!/usr/bin/env python3
"""
NEXUS Game 리소스 관리자
모델, 애니메이션, 텍스처 자동 조직 & 캐탈로그
"""

import json
import os
from pathlib import Path
from datetime import datetime

class ResourceManager:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.assets_dir = self.project_root / "Assets"
        self.catalog_file = self.assets_dir / "RESOURCE_CATALOG.json"
        self.catalog = self._load_catalog()
    
    def _load_catalog(self) -> dict:
        """기존 카탈로그 로드 또는 새로 생성"""
        if self.catalog_file.exists():
            with open(self.catalog_file, 'r') as f:
                return json.load(f)
        return {"models": {}, "animations": {}, "textures": {}, "metadata": {}}
    
    def scan_assets(self) -> None:
        """Assets 폴더 스캔 & 카탈로그 생성"""
        
        print("🔍 Assets 폴더 스캔 중...")
        
        # Models 스캔
        models_dir = self.assets_dir / "Models"
        if models_dir.exists():
            self._scan_models(models_dir)
        
        # Animations 스캔
        animations_dir = self.assets_dir / "Animations"
        if animations_dir.exists():
            self._scan_animations(animations_dir)
        
        # Textures 스캔
        textures_dir = self.assets_dir / "Textures"
        if textures_dir.exists():
            self._scan_textures(textures_dir)
        
        # 메타데이터 업데이트
        self.catalog["metadata"]["last_scan"] = datetime.now().isoformat()
        self.catalog["metadata"]["project_root"] = str(self.project_root)
        
        # 카탈로그 저장
        self._save_catalog()
        print(f"✅ 카탈로그 저장: {self.catalog_file}")
    
    def _scan_models(self, models_dir: Path) -> None:
        """모델 파일 스캔"""
        
        model_count = 0
        for category_dir in models_dir.iterdir():
            if not category_dir.is_dir():
                continue
            
            category = category_dir.name
            self.catalog["models"][category] = []
            
            for file_path in category_dir.glob("*"):
                if file_path.suffix.lower() in ['.fbx', '.blend', '.gltf', '.glb']:
                    model_info = {
                        "name": file_path.stem,
                        "path": str(file_path.relative_to(self.project_root)),
                        "size_mb": round(file_path.stat().st_size / 1024 / 1024, 2),
                        "modified": datetime.fromtimestamp(file_path.stat().st_mtime).isoformat(),
                        "status": "pending"  # ready, imported, error
                    }
                    self.catalog["models"][category].append(model_info)
                    model_count += 1
        
        print(f"  📦 Models: {model_count}개 발견")
    
    def _scan_animations(self, animations_dir: Path) -> None:
        """애니메이션 파일 스캔"""
        
        anim_count = 0
        self.catalog["animations"]["clips"] = []
        
        for file_path in animations_dir.rglob("*"):
            if file_path.suffix.lower() in ['.anim', '.json']:
                anim_info = {
                    "name": file_path.stem,
                    "path": str(file_path.relative_to(self.project_root)),
                    "type": "godot_anim" if file_path.suffix == ".anim" else "json_config"
                }
                self.catalog["animations"]["clips"].append(anim_info)
                anim_count += 1
        
        print(f"  🎬 Animations: {anim_count}개 발견")
    
    def _scan_textures(self, textures_dir: Path) -> None:
        """텍스처 파일 스캔"""
        
        texture_count = 0
        self.catalog["textures"]["images"] = []
        
        for file_path in textures_dir.rglob("*"):
            if file_path.suffix.lower() in ['.png', '.jpg', '.jpeg', '.hdr', '.exr']:
                texture_info = {
                    "name": file_path.stem,
                    "path": str(file_path.relative_to(self.project_root)),
                    "format": file_path.suffix.lower(),
                    "size_mb": round(file_path.stat().st_size / 1024 / 1024, 2)
                }
                self.catalog["textures"]["images"].append(texture_info)
                texture_count += 1
        
        print(f"  🎨 Textures: {texture_count}개 발견")
    
    def _save_catalog(self) -> None:
        """카탈로그를 JSON으로 저장"""
        self.assets_dir.mkdir(parents=True, exist_ok=True)
        with open(self.catalog_file, 'w') as f:
            json.dump(self.catalog, f, indent=2)
    
    def get_status_report(self) -> str:
        """현재 리소스 상태 리포트 생성"""
        
        report = []
        report.append("\n" + "="*60)
        report.append("📊 NEXUS Game 리소스 카탈로그")
        report.append("="*60)
        
        # 모델 통계
        model_total = sum(len(v) for v in self.catalog.get("models", {}).values() if isinstance(v, list))
        report.append(f"📦 Models: {model_total}개")
        for category, items in self.catalog.get("models", {}).items():
            if isinstance(items, list):
                report.append(f"  - {category}: {len(items)}")
        
        # 애니메이션 통계
        anim_count = len(self.catalog.get("animations", {}).get("clips", []))
        report.append(f"🎬 Animations: {anim_count}개")
        
        # 텍스처 통계
        texture_count = len(self.catalog.get("textures", {}).get("images", []))
        total_texture_mb = sum(t.get("size_mb", 0) for t in self.catalog.get("textures", {}).get("images", []))
        report.append(f"🎨 Textures: {texture_count}개 ({total_texture_mb:.1f} MB)")
        
        # 마지막 스캔
        last_scan = self.catalog.get("metadata", {}).get("last_scan", "Never")
        report.append(f"⏱️  마지막 스캔: {last_scan}")
        
        report.append("="*60 + "\n")
        
        return "\n".join(report)
    
    def print_status(self) -> None:
        """상태 출력"""
        print(self.get_status_report())
    
    def generate_import_checklist(self) -> None:
        """임포트 체크리스트 생성"""
        
        checklist = []
        checklist.append("\n📋 Week 3-4 임포트 체크리스트\n")
        
        # Day 11 준비
        checklist.append("✅ Day 11 (2026-05-11)")
        checklist.append("  - [ ] 플레이어 모델 1개 (Sketchfab 또는 자체 제작)")
        checklist.append("  - [ ] Blender에서 기본 애니메이션 5개 생성 (Idle, Walk, Run, Attack, Die)")
        checklist.append("  - [ ] FBX로 내보내기 및 Godot 임포트")
        
        # Day 12
        checklist.append("\n✅ Day 12 (2026-05-12)")
        checklist.append("  - [ ] 전투 애니메이션 7개 추가 (Attack1-5, Block, Counter)")
        checklist.append("  - [ ] 몬스터 모델 1개 시작")
        
        # Week 3 마무리
        checklist.append("\n✅ Week 3 (Day 13-18)")
        checklist.append("  - [ ] 플레이어 모델 완성 + 애니메이션 12개")
        checklist.append("  - [ ] 몬스터 3개 + 애니메이션 24개")
        checklist.append("  - [ ] 환경 에셋 10개 (나무, 바위, 건물)")
        checklist.append("  - [ ] 중원 지역 비주얼 완성")
        
        # 출력
        print("\n".join(checklist))

if __name__ == "__main__":
    import sys
    
    project_root = sys.argv[1] if len(sys.argv) > 1 else Path.cwd()
    
    manager = ResourceManager(project_root)
    
    # 스캔 & 리포트
    manager.scan_assets()
    manager.print_status()
    manager.generate_import_checklist()
