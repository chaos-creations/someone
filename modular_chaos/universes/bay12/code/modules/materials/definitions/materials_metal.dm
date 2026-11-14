//Materials of Baystation 12 (code/modules/materials/definitions/materials_metal.dm in the source), written by tools/port_materials.py,
//which this should be written by again rather than edited

/material/uranium
	name = MATERIAL_URANIUM
	lore_text = "A highly radioactive metal. Commonly used as fuel in fission reactors."
	mechanics_text = "Uranium ingots are used as fuel in some forms of portable generator."
	wall_name = "bulkhead"
	radioactivity = 12
	sheet_icon_base = "puck"
	wall_icon_base = "stone"
	wall_flags = 0
	wall_blend_icons = list(
		"solid" = TRUE,
		"wood" = TRUE,
		"metal" = TRUE
	)
	door_icon_base = "stone"
	table_icon_base = "stone"
	wall_icon_reinf = "reinf_stone"
	icon_colour = "#007a00"
	weight = 22
	construction_difficulty = MATERIAL_HARD_DIY
	sale_price = 2
	value = 100

/material/gold
	name = MATERIAL_GOLD
	lore_text = "A heavy, soft, ductile metal. Once considered valuable enough to back entire currencies, now predominantly used in corrosion-resistant electronics."
	wall_name = "bulkhead"
	icon_colour = "#ffcc33"
	weight = 25
	hardness = MATERIAL_FLEXIBLE + 5
	integrity = 100
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = MATERIAL_GOLD
	ore_result_amount = 5
	ore_name = "native gold"
	ore_spread_chance = 10
	ore_scan_icon = "mineral_uncommon"
	ore_icon_overlay = "nugget"
	sale_price = 3
	value = 40

/material/gold/bronze
	name = MATERIAL_BRONZE
	lore_text = "An alloy of copper, now typically used for decoration."
	icon_colour = "#edd12f"
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = null
	ore_compresses_to = null
	sale_price = null

/material/copper
	name = MATERIAL_COPPER
	wall_name = "bulkhead"
	icon_colour = "#b87333"
	weight = 15
	hardness = MATERIAL_FLEXIBLE + 10
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = MATERIAL_COPPER
	ore_result_amount = 5
	ore_spread_chance = 10
	ore_name = "tetrahedrite"
	ore_scan_icon = "mineral_common"
	ore_icon_overlay = "shiny"
	sale_price = 1

/material/silver
	name = MATERIAL_SILVER
	lore_text = "A soft, white, lustrous transition metal. Has many and varied industrial uses in electronics, solar panels and mirrors."
	wall_name = "bulkhead"
	icon_colour = "#d1e6e3"
	weight = 22
	hardness = MATERIAL_FLEXIBLE + 10
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = MATERIAL_SILVER
	ore_result_amount = 5
	ore_spread_chance = 10
	ore_name = "native silver"
	ore_scan_icon = "mineral_uncommon"
	ore_icon_overlay = "shiny"
	sale_price = 2
	value = 35

/material/steel
	name = MATERIAL_STEEL
	lore_text = "A strong, flexible alloy of iron and carbon. Probably the single most fundamentally useful and ubiquitous substance in human space."
	wall_name = "bulkhead"
	brute_armor = 7
	wall_icon_base = "solid"
	wall_icon_reinf = "reinf_over"
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE|MATERIAL_WALL_HAS_EDGES
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#a8b0b2"
	hitsound = 'modular_chaos/universes/bay12/sound/weapons/smash.ogg'
	alloy_materials = list(MATERIAL_HEMATITE = 1875, MATERIAL_GRAPHITE = 1875)
	alloy_product = TRUE
	sale_price = 1
	ore_smelts_to = MATERIAL_STEEL
	construction_difficulty = MATERIAL_NORMAL_DIY
	value = 4

/material/steel/holographic
	name = "holo" + MATERIAL_STEEL
	display_name = MATERIAL_STEEL
	shard_type = SHARD_NONE
	conductive = 0
	alloy_materials = null
	alloy_product = FALSE
	sale_price = null
	hidden_from_codex = TRUE
	value = 0

/material/aluminium
	name = MATERIAL_ALUMINIUM
	lore_text = "A low-density ductile metal with a silvery-white sheen."
	wall_name = "bulkhead"
	integrity = 125
	weight = 18
	sheet_icon_base = "sheet-sheen"
	wall_icon_base = "solid"
	wall_icon_reinf = "reinf_over"
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE|MATERIAL_WALL_HAS_EDGES
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#cccdcc"
	hitsound = 'modular_chaos/universes/bay12/sound/weapons/smash.ogg'
	sale_price = 1

/material/aluminium/holographic
	name = "holo" + MATERIAL_ALUMINIUM
	display_name = MATERIAL_ALUMINIUM
	shard_type = SHARD_NONE
	conductive = 0
	alloy_materials = null
	alloy_product = FALSE
	sale_price = null
	hidden_from_codex = TRUE

/material/plasteel
	name = MATERIAL_PLASTEEL
	lore_text = "An alloy of steel and platinum. When regular high-tensile steel isn't tough enough to get the job done, the smart consumer turns to frankly absurd alloys of steel and platinum."
	wall_name = "bulkhead"
	integrity = 400
	melting_point = 6000
	sheet_icon_base = "sheet-reinf"
	wall_icon_base = "solid"
	wall_icon_reinf = "reinf_over"
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE|MATERIAL_WALL_HAS_EDGES
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#a8a9b2"
	explosion_resistance = 7.5
	brute_armor = 8
	burn_armor = 10
	hardness = MATERIAL_VERY_HARD
	weight = 23
	hitsound = 'modular_chaos/universes/bay12/sound/weapons/smash.ogg'
	construction_difficulty = MATERIAL_HARD_DIY
	alloy_materials = list(MATERIAL_STEEL = 2500, MATERIAL_PLATINUM = 1250)
	alloy_product = TRUE
	sale_price = 2
	ore_smelts_to = MATERIAL_PLASTEEL
	value = 12

/material/plasteel/titanium
	name = MATERIAL_TITANIUM
	lore_text = "A light, strong, corrosion-resistant metal. Perfect for cladding high-velocity ballistic supply pods."
	brute_armor = 10
	burn_armor = 8
	integrity = 200
	melting_point = 3000
	weight = 18
	wall_icon_base = "metal"
	wall_flags = MATERIAL_PAINTABLE_MAIN
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	door_icon_base = "metal"
	icon_colour = "#d1e6e3"
	wall_icon_reinf = "reinf_metal"
	construction_difficulty = MATERIAL_VERY_HARD_DIY
	alloy_materials = null
	alloy_product = FALSE
	value = 30

/material/plasteel/ocp
	name = MATERIAL_OSMIUM_CARBIDE_PLASTEEL
	integrity = 200
	melting_point = 12000
	sheet_icon_base = "sheet-reinf"
	wall_icon_base = "solid"
	wall_icon_reinf = "reinf_over"
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE|MATERIAL_WALL_HAS_EDGES
	wall_blend_icons = list(
		"wood" = TRUE,
		"stone" = TRUE
	)
	icon_colour = "#9bc6f2"
	brute_armor = 4
	burn_armor = 20
	weight = 27
	alloy_materials = list(MATERIAL_PLASTEEL = 7500, MATERIAL_OSMIUM = 3750)
	construction_difficulty = MATERIAL_VERY_HARD_DIY
	alloy_product = TRUE
	sale_price = 3

/material/osmium
	name = MATERIAL_OSMIUM
	lore_text = "An extremely hard form of platinum."
	wall_name = "bulkhead"
	icon_colour = "#9999ff"
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	construction_difficulty = MATERIAL_VERY_HARD_DIY
	sale_price = 3
	ore_smelts_to = MATERIAL_OSMIUM
	value = 30
	weight = 29

/material/tritium
	name = MATERIAL_TRITIUM
	lore_text = "A radioactive isotope of hydrogen. Useful as a fusion reactor fuel material."
	mechanics_text = "Tritium is useable as a fuel in some forms of portable generator. It can also be converted into a fuel rod suitable for a R-UST fusion plant injector by clicking a stack on a fuel compressor. It fuses hotter than deuterium but is correspondingly more unstable."
	wall_name = "bulkhead"
	icon_colour = "#777777"
	sheet_icon_base = "puck"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	is_fusion_fuel = 1
	construction_difficulty = MATERIAL_HARD_DIY
	value = 300

/material/deuterium
	name = MATERIAL_DEUTERIUM
	lore_text = "One of the two stable isotopes of hydrogen; also known as heavy hydrogen. Useful as a chemically synthesised fusion reactor fuel material."
	mechanics_text = "Deuterium can be converted into a fuel rod suitable for a R-UST fusion plant injector by clicking a stack on a fuel compressor. It is the most 'basic' fusion fuel."
	wall_name = "bulkhead"
	icon_colour = "#999999"
	sheet_icon_base = "puck"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	is_fusion_fuel = 1
	construction_difficulty = MATERIAL_HARD_DIY

/material/mhydrogen
	name = MATERIAL_HYDROGEN
	lore_text = "When hydrogen is exposed to extremely high pressures and temperatures, such as at the core of gas giants like Jupiter, it can take on metallic properties and - more importantly - acts as a room temperature superconductor. Achieving solid metallic hydrogen at room temperature, though, has proven to be rather tricky."
	display_name = "metallic hydrogen"
	wall_name = "bulkhead"
	sheet_icon_base = "sheet-mythril"
	sheet_has_plural_icon = FALSE
	icon_colour = "#e6c5de"
	is_fusion_fuel = 1
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = MATERIAL_TRITIUM
	ore_compresses_to = MATERIAL_HYDROGEN
	ore_name = "raw hydrogen"
	ore_scan_icon = "mineral_rare"
	ore_icon_overlay = "gems"
	sale_price = 5
	value = 100

/material/platinum
	name = MATERIAL_PLATINUM
	lore_text = "A very dense, unreactive, precious metal. Has many industrial uses, particularly as a catalyst."
	wall_name = "bulkhead"
	icon_colour = "#deddff"
	weight = 27
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = MATERIAL_PLATINUM
	ore_compresses_to = MATERIAL_OSMIUM
	ore_result_amount = 5
	ore_spread_chance = 10
	ore_name = "raw platinum"
	ore_scan_icon = "mineral_rare"
	ore_icon_overlay = "shiny"
	sale_price = 5
	value = 80

/material/iron
	name = MATERIAL_IRON
	lore_text = "A ubiquitous, very common metal. The epitaph of stars and the primary ingredient in Earth's core."
	wall_name = "bulkhead"
	icon_colour = "#5c5454"
	weight = 22
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	hitsound = 'modular_chaos/universes/bay12/sound/weapons/smash.ogg'
	construction_difficulty = MATERIAL_NORMAL_DIY
	sale_price = 1
	value = 5

/material/voxalloy
	name = MATERIAL_VOX
	display_name = "durable alloy"
	wall_name = "bulkhead"
	sheet_icon_base = "vox"
	icon_colour = "#6c7364"
	integrity = 1200
	melting_point = 6000
	explosion_resistance = 200
	hardness = 500
	weight = 500
	construction_difficulty = MATERIAL_HARD_DIY
	hidden_from_codex = TRUE
	value = 100

/material/voxalloy/elevatorium
	name = MATERIAL_ELEVATORIUM
	display_name = "elevator panelling"
	wall_name = "bulkhead"
	icon_colour = "#666666"
	construction_difficulty = MATERIAL_HARD_DIY
	hidden_from_codex = TRUE

/material/aliumium
	name = MATERIAL_ALIENALLOY
	display_name = "alien alloy"
	wall_name = "bulkhead"
	wall_icon_base = "jaggy"
	door_icon_base = "metal"
	wall_icon_reinf = "reinf_metal"
	hitsound = 'modular_chaos/universes/bay12/sound/weapons/smash.ogg'
	sheet_singular_name = "chunk"
	sheet_plural_name = "chunks"
	construction_difficulty = MATERIAL_VERY_HARD_DIY
	hidden_from_codex = TRUE

/material/hematite
	name = MATERIAL_HEMATITE
	wall_name = "bulkhead"
	icon_colour = "#aa6666"
	ore_smelts_to = MATERIAL_IRON
	ore_result_amount = 5
	ore_spread_chance = 25
	ore_scan_icon = "mineral_common"
	ore_name = "hematite"
	ore_icon_overlay = "lump"
	sale_price = 1

/material/rutile
	name = MATERIAL_RUTILE
	wall_name = "bulkhead"
	icon_colour = "#d8ad97"
	ore_smelts_to = MATERIAL_TITANIUM
	ore_result_amount = 5
	ore_spread_chance = 15
	ore_scan_icon = "mineral_uncommon"
	ore_name = "rutile"
	ore_icon_overlay = "lump"
	sale_price = 2

/material/electrum
	name = MATERIAL_ELECTRUM
	lore_text = "A soft natural alloy of gold and silver with a green-gold color, typically used for coinage and decoration."
	wall_name = "bulkhead"
	sheet_icon_base = "ingot"
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	icon_colour = "#e7c697"
	weight = 22
	integrity = 100
	hardness = MATERIAL_FLEXIBLE + 10
	construction_difficulty = MATERIAL_HARD_DIY
	ore_smelts_to = MATERIAL_ELECTRUM
	ore_result_amount = 3
	ore_spread_chance = 10
	ore_name = "electrum"
	ore_scan_icon = "mineral_uncommon"
	ore_icon_overlay = "shiny"
	sale_price = 3
	value = 37
