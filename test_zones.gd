#!/usr/bin/env -S godot -s
# Test script for Zone Controllers

extends SceneTree

func _ready() -> void:
	print("\n🧪 Testing Zone Controllers...")
	print("=" * 60)
	
	# Test Mountain Zone
	var mountain = MountainZoneController.new()
	mountain._ready()
	mountain.print_zone_info()
	
	# Test Desert Zone
	var desert = DesertZoneController.new()
	desert._ready()
	desert.print_zone_info()
	
	# Test Sea Zone
	var sea = SeaZoneController.new()
	sea._ready()
	sea.print_zone_info()
	
	# Test Black Dragon Cave
	var black_dragon = BlackDragonCaveController.new()
	black_dragon._ready()
	black_dragon.print_zone_info()
	
	print("\n✅ All zone controllers initialized successfully!")
	print("=" * 60)
	
	quit()
