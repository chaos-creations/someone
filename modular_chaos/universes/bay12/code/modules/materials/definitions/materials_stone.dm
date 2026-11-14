//Materials of Baystation 12 (code/modules/materials/definitions/materials_stone.dm in the source), written by tools/port_materials.py,
//which this should be written by again rather than edited

/material/diamond
	name = MATERIAL_DIAMOND
	lore_text = "An extremely hard allotrope of carbon. Valued for its use in industrial tools."
	flags = MATERIAL_UNMELTABLE
	cut_delay = 60
	icon_colour = "#d8d4ea"
	opacity = 0.4
	shard_type = SHARD_SHARD
	tableslam_noise = 'modular_chaos/universes/bay12/sound/effects/Glasshit.ogg'
	hardness = MATERIAL_VERY_HARD + 20
	brute_armor = 10
	burn_armor = 50
	conductive = 0
	construction_difficulty = MATERIAL_VERY_HARD_DIY
	ore_name = "rough diamonds"
	ore_compresses_to = MATERIAL_DIAMOND
	ore_result_amount = 5
	ore_spread_chance = 10
	ore_scan_icon = "mineral_rare"
	ore_icon_overlay = "gems"
	sale_price = 5
	sheet_icon_base = "diamond"
	sheet_singular_name = "gem"
	sheet_plural_name = "gems"
	value = 70

/material/diamond/crystal
	name = MATERIAL_CRYSTAL
	hardness = MATERIAL_VERY_HARD
	ore_compresses_to = null
	sale_price = null
	hidden_from_codex = TRUE

/material/stone
	name = MATERIAL_SANDSTONE
	lore_text = "A clastic sedimentary rock. The cost of boosting it to orbit is almost universally much higher than the actual value of the material."
	wall_icon_base = "stone"
	wall_flags = 0
	wall_blend_icons = list(
		"solid" = TRUE,
		"wood" = TRUE,
		"metal" = TRUE
	)
	table_icon_base = "stone"
	wall_icon_reinf = "reinf_stone"
	icon_colour = "#d9c179"
	shard_type = SHARD_STONE_PIECE
	weight = 22
	hardness = MATERIAL_HARD - 5
	brute_armor = 3
	door_icon_base = "stone"
	sheet_icon_base = "brick"
	sheet_singular_name = "brick"
	sheet_plural_name = "bricks"
	conductive = 0
	construction_difficulty = MATERIAL_NORMAL_DIY
	sale_price = 1
	value = 4

/material/stone/marble
	name = MATERIAL_MARBLE
	lore_text = "A metamorphic rock largely sourced from Earth. Prized for use in extremely expensive decorative surfaces."
	icon_colour = "#aaaaaa"
	weight = 26
	hardness = MATERIAL_HARD
	brute_armor = 3
	integrity = 201
	construction_difficulty = MATERIAL_HARD_DIY
	sale_price = 4
	value = 20

/material/stone/concrete
	name = MATERIAL_CONCRETE
	lore_text = "The most ubiquitous building material of old Earth, now in space. Consists of mineral aggregate bound with some sort of cementing solution."
	icon_colour = "#808080"
	value = 1
