//Materials of Baystation 12 (code/modules/materials/definitions/materials_organic.dm in the source), written by tools/port_materials.py,
//which this should be written by again rather than edited

/material/plastic
	name = MATERIAL_PLASTIC
	lore_text = "A generic polymeric material. Probably the most flexible and useful substance ever created by human science; mostly used to make disposable cutlery."
	flags = MATERIAL_BRITTLE
	wall_icon_base = "solid"
	door_icon_base = "plastic"
	wall_icon_reinf = "reinf_over"
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#ffffff"
	hardness = MATERIAL_FLEXIBLE
	weight = 5
	melting_point = T0C+371
	conductive = 0
	construction_difficulty = MATERIAL_NORMAL_DIY
	sale_price = 1
	dooropen_noise = 'modular_chaos/universes/bay12/sound/effects/doorcreaky.ogg'

/material/plastic/holographic
	name = "holo" + MATERIAL_PLASTIC
	display_name = MATERIAL_PLASTIC
	shard_type = SHARD_NONE
	sale_price = null
	hidden_from_codex = TRUE

/material/cardboard
	name = MATERIAL_CARDBOARD
	lore_text = "What with the difficulties presented by growing plants in orbit, a stock of cardboard in space is probably more valuable than gold."
	flags = MATERIAL_BRITTLE
	integrity = 10
	sheet_icon_base = "sheet-card"
	wall_icon_base = "solid"
	wall_icon_reinf = "reinf_over"
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE|MATERIAL_WALL_HAS_EDGES
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#aaaaaa"
	hardness = MATERIAL_SOFT
	brute_armor = 1
	weight = 1
	ignition_point = T0C+232 //"the temperature at which book-paper catches fire, and burns." close enough
	melting_point = T0C+232
	door_icon_base = "wood"
	destruction_desc = "crumples"
	conductive = 0
	value = 0

/material/cloth/carpet
	name = "carpet"
	display_name = "red"
	use_name = "red upholstery"
	icon_colour = "#9d2300"
	sheet_singular_name = "tile"
	sheet_plural_name = "tiles"

/material/cloth/yellow
	name = "yellow"
	display_name = "yellow"
	use_name = "yellow cloth"
	icon_colour = "#ffbf00"

/material/cloth/teal
	name = "teal"
	display_name = "teal"
	use_name = "teal cloth"
	icon_colour = "#00e1ff"

/material/cloth/black
	name = "black"
	display_name = "black"
	use_name = "black cloth"
	icon_colour = "#505050"

/material/cloth/green
	name = "green"
	display_name = "green"
	use_name = "green cloth"
	icon_colour = "#b7f27d"

/material/cloth/puple
	name = "purple"
	display_name = "purple"
	use_name = "purple cloth"
	icon_colour = "#9933ff"

/material/cloth/blue
	name = "blue"
	display_name = "blue"
	use_name = "blue cloth"
	icon_colour = "#46698c"

/material/cloth/beige
	name = "beige"
	display_name = "beige"
	use_name = "beige cloth"
	icon_colour = "#ceb689"

/material/cloth/lime
	name = "lime"
	display_name = "lime"
	use_name = "lime cloth"
	icon_colour = "#62e36c"

/material/carpet
	name = MATERIAL_CARPET
	display_name = "red"
	use_name = "red upholstery"
	icon_colour = "#9d2300"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300
	sheet_icon_base = "skin"
	sheet_singular_name = "tile"
	sheet_plural_name = "tiles"
	conductive = 0
	construction_difficulty = MATERIAL_NORMAL_DIY

/material/skin
	name = MATERIAL_SKIN_GENERIC
	icon_colour = "#9e8c72"
	sheet_icon_base = "skin"
	flags = MATERIAL_PADDING
	ignition_point = T0C+300
	melting_point = T0C+300
	conductive = 0
	hidden_from_codex = TRUE
	construction_difficulty = MATERIAL_NORMAL_DIY
	value = 1
	integrity = 50
	hardness = MATERIAL_SOFT
	weight = 5
	explosion_resistance = 1
	tans_to = MATERIAL_LEATHER_GENERIC

/material/skin/lizard
	name = MATERIAL_SKIN_LIZARD
	icon_colour = "#626952"
	tans_to = MATERIAL_LEATHER_LIZARD
	hardness = MATERIAL_FLEXIBLE
	weight = 10

/material/skin/insect
	name = MATERIAL_SKIN_CHITIN
	icon_colour = "#7a726d"
	tans_to = MATERIAL_LEATHER_CHITIN
	integrity = 75
	hardness = MATERIAL_RIGID
	weight = 15
	brute_armor = 2

/material/skin/fur
	name = MATERIAL_SKIN_FUR
	icon_colour = "#7a726d"
	tans_to = MATERIAL_LEATHER_FUR

/material/skin/fur/gray
	name = MATERIAL_SKIN_FUR_GRAY

/material/skin/fur/white
	name = MATERIAL_SKIN_FUR_WHITE

/material/skin/fur/orange
	name = MATERIAL_SKIN_FUR_ORANGE
	icon_colour = "#ff9900"

/material/skin/fur/black
	name = MATERIAL_SKIN_FUR_BLACK
	icon_colour = "#333333"

/material/skin/fur/heavy
	name = MATERIAL_SKIN_FUR_HEAVY
	icon_colour = "#545c68"

/material/skin/goat
	name = MATERIAL_SKIN_GOATHIDE
	icon_colour = "#c0c0c0"

/material/skin/cow
	name = MATERIAL_SKIN_COWHIDE
	icon_colour = "#666666"

/material/skin/shark
	name = MATERIAL_SKIN_SHARK
	icon_colour = "#a2819e"

/material/skin/fish
	name = MATERIAL_SKIN_FISH
	icon_colour = "#1f6b4f"

/material/skin/fish/purple
	name = MATERIAL_SKIN_FISH_PURPLE
	icon_colour = "#bda2ba"

/material/skin/feathers
	name = MATERIAL_SKIN_FEATHERS
	icon_colour = "#c0c0c0"

/material/skin/feathers/purple
	name = MATERIAL_SKIN_FEATHERS_PURPLE
	icon_colour = "#bda2ba"

/material/skin/feathers/blue
	name = MATERIAL_SKIN_FEATHERS_BLUE
	icon_colour = "#5ca1cc"

/material/skin/feathers/green
	name = MATERIAL_SKIN_FEATHERS_GREEN
	icon_colour = "#1f6b4f"

/material/skin/feathers/brown
	name = MATERIAL_SKIN_FEATHERS_BROWN
	icon_colour = "#663300"

/material/skin/feathers/red
	name = MATERIAL_SKIN_FEATHERS_RED
	icon_colour = "#ff0000"

/material/skin/feathers/black
	name = MATERIAL_SKIN_FEATHERS_BLACK
	icon_colour = "#151515"

/material/bone
	name = MATERIAL_BONE_GENERIC
	sheet_icon_base = "bone"
	sheet_singular_name = "length"
	sheet_plural_name = "lengths"
	icon_colour = "#f0edc7"
	ignition_point = T0C+1100
	melting_point = T0C+1800
	conductive = 0
	hidden_from_codex = TRUE
	construction_difficulty = MATERIAL_NORMAL_DIY
	hitsound = 'modular_chaos/universes/bay12/sound/weapons/smash.ogg'
	integrity = 75
	hardness = MATERIAL_RIGID
	weight = 18
	value = 1

/material/bone/fish
	name = MATERIAL_BONE_FISH
	hardness = MATERIAL_FLEXIBLE
	weight = 13

/material/bone/cartilage
	name = MATERIAL_BONE_CARTILAGE
	hardness = 0
	weight = 10

/material/leather
	name = MATERIAL_LEATHER_GENERIC
	icon_colour = "#5c4831"
	sheet_icon_base = "sheet-leather"
	sheet_has_plural_icon = FALSE
	flags = MATERIAL_PADDING
	ignition_point = T0C+300
	melting_point = T0C+300
	conductive = 0
	hidden_from_codex = TRUE
	construction_difficulty = MATERIAL_NORMAL_DIY
	value = 3
	integrity = 50
	hardness = MATERIAL_FLEXIBLE
	weight = 10

/material/leather/lizard
	name = MATERIAL_LEATHER_LIZARD
	integrity = 75
	hardness = MATERIAL_RIGID
	weight = 15

/material/leather/fur
	name = MATERIAL_LEATHER_FUR

/material/leather/chitin
	name = MATERIAL_LEATHER_CHITIN
	integrity = 100
	hardness = MATERIAL_HARD
	weight = 18
	brute_armor = 2

/material/growth
	name = MATERIAL_GROWTH
	display_name = "organic material"
	sheet_icon_base = "skin"
	wall_icon_base = "cult"
	wall_flags = 0
	wall_blend_icons = list(
		"solid" = TRUE,
		"wood" = TRUE,
		"metal" = TRUE,
		"stone" = TRUE
	)
	wall_flags = 0
	door_icon_base = "cult"
	table_icon_base = "cult"
	wall_icon_reinf = "reinf_cult"
	icon_colour = "#281744"
	hardness = 80
	brute_armor = 4
	burn_armor = 3
	conductive = 0
	construction_difficulty = 10
	hidden_from_codex = TRUE
