#!/bin/bash

echo "📊 Zone Controller Verification Report"
echo "======================================"
echo ""

# Mountain Zone
echo "⛰️ MOUNTAIN ZONE CONTROLLER"
echo "NPC Count:"
grep -c '"id":' NEXUS_Dev/Scripts/World/MountainZoneController.gd | head -1 | xargs -I{} sh -c 'echo "  Total entries: {}"'
grep '"role".*"quest_giver"' NEXUS_Dev/Scripts/World/MountainZoneController.gd | wc -l | xargs -I{} sh -c 'echo "  Quest Givers: {}"'
echo "Enemy Types:"
grep '"type":' NEXUS_Dev/Scripts/World/MountainZoneController.gd | sort -u | sed 's/^/    /'
echo "Props:"
grep '"type":' NEXUS_Dev/Scripts/World/MountainZoneController.gd | grep -o '"type": "[^"]*"' | cut -d'"' -f4 | tail -8 | sed 's/^/    /'
echo ""

# Desert Zone
echo "🏜️ DESERT ZONE CONTROLLER"
echo "NPC Count:"
grep -c '"id":' NEXUS_Dev/Scripts/World/DesertZoneController.gd | head -1 | xargs -I{} sh -c 'echo "  Total entries: {}"'
grep '"role".*"quest_giver"' NEXUS_Dev/Scripts/World/DesertZoneController.gd | wc -l | xargs -I{} sh -c 'echo "  Quest Givers: {}"'
echo "Enemy Types:"
grep '"type":' NEXUS_Dev/Scripts/World/DesertZoneController.gd | sort -u | sed 's/^/    /'
echo ""

# Sea Zone
echo "⛵ SEA ZONE CONTROLLER"
echo "NPC Count:"
grep -c '"id":' NEXUS_Dev/Scripts/World/SeaZoneController.gd | head -1 | xargs -I{} sh -c 'echo "  Total entries: {}"'
grep '"role".*"quest_giver"' NEXUS_Dev/Scripts/World/SeaZoneController.gd | wc -l | xargs -I{} sh -c 'echo "  Quest Givers: {}"'
echo "Enemy Types:"
grep '"type":' NEXUS_Dev/Scripts/World/SeaZoneController.gd | sort -u | sed 's/^/    /'
echo ""

# Black Dragon Cave
echo "🐉 BLACK DRAGON CAVE CONTROLLER (FINAL)"
echo "NPC Count:"
grep -c '"id":' NEXUS_Dev/Scripts/World/BlackDragonCaveController.gd | head -1 | xargs -I{} sh -c 'echo "  Total entries: {}"'
grep '"role".*"quest_giver"' NEXUS_Dev/Scripts/World/BlackDragonCaveController.gd | wc -l | xargs -I{} sh -c 'echo "  Quest Givers: {}"'
echo "Enemy Types:"
grep '"type":' NEXUS_Dev/Scripts/World/BlackDragonCaveController.gd | sort -u | sed 's/^/    /'
echo ""

echo "======================================"
echo "✅ Verification Complete"
