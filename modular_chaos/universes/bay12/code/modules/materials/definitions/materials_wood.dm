//Materials of Baystation 12 (code/modules/materials/definitions/materials_wood.dm in the source), written by tools/port_materials.py,
//which this should be written by again rather than edited

/material/wood
	name = BAY_MATERIAL_WOOD
	lore_text = "A fibrous structural material harvested from an indeterminable plant. Don't get a splinter."
	adjective_name = "wooden"
	icon_colour = "#d5a66e"
	integrity = 75
	sheet_icon_base = "sheet-wood"
	wall_icon_base = "wood"
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE|MATERIAL_WALL_HAS_EDGES
	wall_blend_icons = list(
		"solid" = TRUE,
		"stone" = TRUE,
		"metal" = TRUE
	)
	table_icon_base = "wood"
	explosion_resistance = 2
	shard_type = SHARD_SPLINTER
	shard_can_repair = 0
	hardness = MATERIAL_FLEXIBLE + 10
	brute_armor = 1
	weight = 18
	melting_point = T0C+300
	ignition_point = T0C+288
	dooropen_noise = 'modular_chaos/universes/bay12/sound/effects/doorcreaky.ogg'
	door_icon_base = "wood"
	destruction_desc = "splinters"
	sheet_singular_name = "plank"
	sheet_plural_name = "planks"
	hitsound = 'modular_chaos/universes/bay12/sound/effects/woodhit.ogg'
	conductive = 0
	construction_difficulty = MATERIAL_NORMAL_DIY
	sale_price = 1
	value = 3

/material/wood/holographic
	name = "holo" + BAY_MATERIAL_WOOD
	icon_colour = "#543c30"
	display_name = "wood"
	shard_type = SHARD_NONE
	sale_price = 0
	value = 0
	hidden_from_codex = TRUE

/material/wood/mahogany
	name = MATERIAL_MAHOGANY
	lore_text = "Mahogany is prized for its beautiful grain and rich colour, and as such is typically used for fine furniture and cabinetry."
	adjective_name = MATERIAL_MAHOGANY
	icon_colour = "#792f27"
	construction_difficulty = MATERIAL_HARD_DIY
	sale_price = 3
	value = 45

/material/wood/maple
	name = MATERIAL_MAPLE
	lore_text = "Owing to its fast growth and ease of working, silver maple is a popular wood for flooring and furniture."
	adjective_name = MATERIAL_MAPLE
	icon_colour = "#d2bc9d"

/material/wood/ebony
	name = MATERIAL_EBONY
	lore_text = "Ebony is the name for a group of dark coloured, extremely dense, and fine grained hardwoods. \
				Despite gene modification to produce larger source trees and ample land to plant them on, \
				genuine ebony remains a luxury for the very wealthy thanks to the price fixing efforts of intergalactic luxuries cartels. \
				Most people will only ever touch ebony in small items, such as chess pieces, or the accent pieces of a fine musical instrument."
	adjective_name = MATERIAL_EBONY
	icon_colour = "#332521"
	weight = 22
	integrity = 100
	construction_difficulty = MATERIAL_VERY_HARD_DIY
	sale_price = 6
	value = 85

/material/wood/walnut
	name = MATERIAL_WALNUT
	lore_text = "Walnut is a dense hardwood that polishes to a very fine finish. \
				Walnut is especially favoured for construction of figurines (where it contrasts with lighter coloured woods) and tables. \
				The ultimate aspiration of many professionals is an office with a vintage walnut desk, the bigger and heavier the better."
	adjective_name = MATERIAL_WALNUT
	icon_colour = "#543c30"
	weight = 20
	construction_difficulty = MATERIAL_HARD_DIY
	sale_price = 2
	value = 21

/material/wood/bamboo
	name = MATERIAL_BAMBOO
	lore_text = "Bamboo is a fast-growing grass which can be used similar to wood after processing. Due to its swift growth \
				and high strength, various species of bamboo area common building materials in developing societies."
	adjective_name = MATERIAL_BAMBOO
	icon_colour = "#e6d2ba"
	weight = 16
	hardness = MATERIAL_RIGID

/material/wood/yew
	name = MATERIAL_YEW
	lore_text = "Although favoured in days past for the construction of bows, yew has a multitude of uses, including medicine. The yew \
				tree can live for nearly a thousand years thanks to its natural disease resistance."
	adjective_name = MATERIAL_YEW
	icon_colour = "#e3994e"

/material/wood/vox
	name = MATERIAL_VOXRES
	ignition_point = T0C+300
	melting_point = T0C+300
	conductive = 0
	icon_colour = "#3a4e1b"
	hidden_from_codex = TRUE
	sheet_icon_base = "vox"
	sheet_singular_name = "slab"
	sheet_plural_name = "slabs"
	construction_difficulty = MATERIAL_NORMAL_DIY
	integrity = 60
	hardness = MATERIAL_FLEXIBLE
	weight = 12
	brute_armor = 1
