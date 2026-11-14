//Materials of Baystation 12 (code/modules/materials/definitions/materials_glass.dm in the source), written by tools/port_materials.py,
//which this should be written by again rather than edited

/material/glass
	name = MATERIAL_GLASS
	lore_text = "A brittle, transparent material made from molten silicates. It is generally not a liquid."
	flags = MATERIAL_BRITTLE
	icon_colour = "#aaccff"
	opacity = 0.3
	integrity = 50
	shard_type = SHARD_SHARD
	tableslam_noise = 'modular_chaos/universes/bay12/sound/effects/Glasshit.ogg'
	hardness = MATERIAL_RIGID + 10
	melting_point = T0C + 100
	weight = 14
	brute_armor = 1
	burn_armor = 2
	sheet_icon_base = "sheet-clear"
	sheet_icon_reinf = "reinf-clear-overlay"
	table_icon_base = "solid"
	destruction_desc = "shatters"
	hitsound = 'modular_chaos/universes/bay12/sound/effects/Glasshit.ogg'
	dooropen_noise = 'modular_chaos/universes/bay12/sound/machines/windowdoor.ogg'
	conductive = 0
	sale_price = 1
	value = 4

/material/glass/boron
	name = MATERIAL_BORON_GLASS
	lore_text = "An extremely heat-resistant form of glass."
	display_name = "borosilicate glass"
	flags = MATERIAL_BRITTLE
	hardness = MATERIAL_HARD
	integrity = 70
	brute_armor = 2
	burn_armor = 5
	melting_point = T0C + 4000
	icon_colour = "#899ebd"
	construction_difficulty = MATERIAL_HARD_DIY
	alloy_product = TRUE
	alloy_materials = list(MATERIAL_SAND = 2500, MATERIAL_BORAX = 500)
	sale_price = 2
	value = 40
