//Materials of Baystation 12 (code/modules/materials/definitions/materials_other.dm in the source), written by tools/port_materials.py,
//which this should be written by again rather than edited

/material/waste
	name = MATERIAL_WASTE
	icon_colour = "#2e3a07"
	sheet_icon_base = "puck"
	ore_name = "slag"
	ore_desc = "Someone messed up..."
	ore_icon_overlay = "lump"
	hidden_from_codex = TRUE

/material/cult
	name = MATERIAL_CULT
	display_name = "disturbing stone"
	wall_icon_base = "cult"
	wall_flags = 0
	wall_blend_icons = list(
		"solid" = TRUE,
		"wood" = TRUE,
		"metal" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#402821"
	wall_icon_reinf = "reinf_cult"
	shard_type = SHARD_STONE_PIECE
	sheet_icon_base = "brick"
	sheet_singular_name = "brick"
	sheet_plural_name = "bricks"
	conductive = 0
	construction_difficulty = MATERIAL_NORMAL_DIY
	hidden_from_codex = TRUE

/material/cult/reinf
	name = MATERIAL_REINFORCED_CULT
	display_name = "runic inscriptions"
