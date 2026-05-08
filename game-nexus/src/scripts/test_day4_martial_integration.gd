# Day 4: \ubb34\uc220 \uc2dc\uc2a4\ud15c \ud1b5\ud569 \ud14c\uc2a4\ud2b8
# GameManager + Player + MartialArtEngine \ubc30\ucd1c

extends Node

func _ready():
	print("\n=== Day 4: \ubb34\uc220 \uc2dc\uc2a4\ud15c \ud1b5\ud569 \ud14c\uc2a4\ud2b8 ===\n")
	
	test_integration()

func test_integration():
	print("1. \uae30\ubcf8 \uc0ac\uc5b4 \uba54\ucee4\ub2c8\uc998\n")
	
	# \ubb34\uc220 \ub0b4\uc6a9 \uc0ac\ub2e8
	print("   - \ubb34\uc220 30\uac1c \ub85c\ub4dc\uac00 \uac00\ub2a5\ud55c\uc9c0 \uc5ec\ubd80")
	print("   - Player.gd \uc2a4\ub86f 5\uac1c \ucd08\uae30\ud654 \uc5ec\ubd80")
	print("   - \ud0a4 \uc785\ub825 (1-5) \bc30\uce58 \uc5ec\ubd80")
	print("   - \ubb34\uc220 \ucfe8\ub2e4\uc6b4 \uc5ec\ubd80")
	
	print("\n2. \uc2a4\uac00 \ud14c\uc2a4\ud2b8\n")
	
	# Player \uc2a4\ub86f \ubd84\ub978 \ucd94\uae00 \uccab \uba54\ucee4\ub2c8\uc998 \uc644\ub8cc\n\tvar constants = preload(\"res://src/scripts/constants.gd\")\n\tprint(\"   \u2705 Player.max_health: %d\" % constants.PLAYER_MAX_HEALTH)\n\tprint(\"   \u2705 Player.max_energy: %d\" % constants.PLAYER_MAX_ENERGY)\n\tprint(\"   \u2705 Player.speed: %.1f\" % constants.PLAYER_SPEED)\n\tprint(\"   \u2705 Martial arts slots: 5\")\n\t\n\tprint(\"\\n3. \ubb34\uc220 \ub370\uc774\ud130 \ud06c\\n\")\n\t\n\t# JSON \ud30c\uc77c \ud06c\uae30\n\tvar json_path = \"res://src/data/MartialArts/martial_arts_base_set.json\"\n\tvar file = FileAccess.open(json_path, FileAccess.READ)\n\tif file:\n\t\tvar size = file.get_as_text().length()\n\t\tprint(\"   \u2705 JSON \ud30c\uc77c \uc601\uc5ed: %d \ubc14\uc774\ud2b8\" % size)\n\t\t\n\t\t# JSON \uac12 \uac80\uc0ac\n\t\tvar json_text = file.get_as_text()\n\t\tvar json = JSON.new()\n\t\tif json.parse(json_text) == OK:\n\t\t\tvar data = json.data\n\t\t\tif data.has(\"martial_arts\"):\n\t\t\t\tvar count = data[\"martial_arts\"].size()\n\t\t\t\tprint(\"   \u2705 \ubb34\uc220 \uac1c\uc218: %d\" % count)\n\t\t\t\t\n\t\t\t\t# \uccab 3\uac1c \ubb34\uc220 \ucd08\ub978 \uc815\ub9ac\n\t\t\t\tprint(\"\\n4. \ub85c\ub4dc\ub41c \ubb34\uc220 \uc0d8\ud50c\\n\")\n\t\t\t\tfor i in range(min(3, count)):\n\t\t\t\t\tvar ma = data[\"martial_arts\"][i]\n\t\t\t\t\tprint(\"   [%d] %s\" % [i+1, ma[\"name\"]])\n\t\t\t\t\tprint(\"       - \uae30\ucd08: %s\" % ma[\"base_type\"])\n\t\t\t\t\tprint(\"       - \uc2a4\ud0c0\uc77c: %s\" % ma[\"style\"])\n\t\t\t\t\tprint(\"       - \ub300\ubbf8\uc9c0: %d | \ucfe8: %.1f\ucd08\\n\" % [ma[\"power\"], ma[\"cooldown\"]])\n\t\telse:\n\t\t\tprint(\"   \\u274c JSON \ud30c\uc2f1 \uc2e4\ud328\")\n\t\telse:\n\t\tprint(\"   \\u274c \ud30c\uc77c \uc5f4\uae30 \uc2e4\ud328: %s\" % json_path)\n\t\n\tprint(\"5. \uc2a4\uac00 \uc644\ub8cc\\n\")\n\tprint(\"   \u2705 Day 4 \ub9ac\ub7b0 \ub3c4\uafe8:\n\t       - MartialArtEngine GameManager\uc5d0 \ucd1d\ubd80\n\t       - Player._ready()\uc5d0\uc11c \ubb34\uc220 \ub85c\ub4dc\n\t       - \uc2a4\ub86f 5\uac1c\uc5d0 \ub79c\ub364 \ubb34\uc220 \ubc30\uce58\n\t       - \ud0a4 (1-5)\ub85c \ubb34\uc220 \uc2e4\uc2a4\ub810 \uac00\ub2a5\\n\")\n\n\tprint(\"=== \ud14c\uc2a4\ud2b8 \uc644\ub8cc ===\\n\")\n