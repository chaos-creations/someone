//Materials of Baystation 12 (code/modules/materials/_materials.dm and controllers/subsystems/initialization/materials.dm in the source)

/**
 * A material of Baystation 12, /material of the source
 *
 * What a thing is made of: its name, colour and sprites, and how strong, hard and heavy it is. Tables, chairs and beds
 * here are made of these. The definitions are in definitions/, written by tools/port_materials.py with the vars below;
 * what the source does with materials in its other systems (stacks, recipes, reagents, ores, research) comes with
 * those systems. get_bay_material() finds one by its name.
 */
/material
	/// Unique name, by which it is found
	var/name
	/// Prettier name to show, the name unless set
	var/display_name
	/// The name as an adjective, the display name unless set
	var/adjective_name
	/// The name to use in object names, the display name unless set
	var/use_name
	/// The name of walls of it
	var/wall_name = "wall"
	/// MATERIAL_UNMELTABLE, MATERIAL_BRITTLE and MATERIAL_PADDING
	var/flags = 0
	var/sheet_singular_name = "sheet"
	var/sheet_plural_name = "sheets"
	var/lore_text
	var/mechanics_text
	var/antag_text
	/// Whether it is kept out of the codex of the source
	var/hidden_from_codex
	/// What it breaks into, a SHARD_* name
	var/shard_type = SHARD_SHRAPNEL
	/// The sprite of its shards, the shard type unless set
	var/shard_icon
	/// Whether its shards can be welded back into sheets
	var/shard_can_repair = TRUE
	/// How things of it are said to break apart
	var/destruction_desc = "breaks apart"
	/// The colour things of it take
	var/icon_colour
	/// The sprites of its sheets
	var/sheet_icon_base = "sheet"
	/// The overlay of its reinforced sheets
	var/sheet_icon_reinf = "reinf-overlay"
	/// Whether its sheets have a sprite for a stack
	var/sheet_has_plural_icon = TRUE
	/// The sprites of walls of it
	var/wall_icon_base = "metal"
	/// The sprites of walls reinforced with it
	var/wall_icon_reinf = "reinf_metal"
	/// How walls of it can be painted, MATERIAL_PAINTABLE_* and MATERIAL_WALL_HAS_EDGES
	var/wall_flags = MATERIAL_PAINTABLE_MAIN
	/// The wall_icon_base of the walls of other materials that walls of it join, with an edge between: base to TRUE
	var/list/wall_blend_icons = list()
	/// The sprites of doors of it
	var/door_icon_base = "metal"
	/// The sprites of tables of it
	var/table_icon_base = "metal"
	/// The sprites of tables reinforced with it
	var/table_icon_reinf = "reinf_metal"
	/// How long cutting through a wall of it takes, in ticks
	var/cut_delay = 0
	/// How strongly things of it irradiate what is around them
	var/radioactivity
	/// The temperature it catches fire at, in kelvin
	var/ignition_point
	/// The temperature it melts at, in kelvin
	var/melting_point = 1800
	/// What a wall reinforced with it divides brute damage by
	var/brute_armor = 2
	/// What a wall reinforced with it divides burn damage by, the brute armour unless set
	var/burn_armor
	/// The health of things of it
	var/integrity = 150
	/// How much it blocks sight; below 0.5, walls and doors of it are see-through
	var/opacity = 1
	/// How well walls of it stand explosions
	var/explosion_resistance = 5
	/// Whether things of it conduct electricity
	var/conductive = TRUE
	/// How brightly things of it glow
	var/luminescence
	/// What it is alloyed from: material names to amounts
	var/list/alloy_materials
	/// Whether it is the product of an alloy
	var/alloy_product
	/// How much of it a sheet holds
	var/units_per_sheet = SHEET_MATERIAL_AMOUNT
	/// How hard it is, which edged weapons of it cut with: MATERIAL_SOFT to MATERIAL_VERY_HARD
	var/hardness = MATERIAL_HARD
	/// How heavy it is, which blunt weapons of it hit with
	var/weight = 20
	/// The sound of slamming someone on a table of it
	var/tableslam_noise = 'modular_chaos/universes/bay12/sound/weapons/tablehit1.ogg'
	/// The sound of a door of it opening
	var/dooropen_noise = 'modular_chaos/universes/bay12/sound/effects/stonedoor_openclose.ogg'
	/// The sound of hitting things of it
	var/hitsound = 'modular_chaos/universes/bay12/sound/weapons/genhit.ogg'
	/// How hard building with it is, MATERIAL_*_DIY
	var/construction_difficulty = MATERIAL_EASY_DIY
	var/ore_name
	var/ore_desc
	/// The material its ore smelts into
	var/ore_smelts_to
	/// The material its ore compresses into
	var/ore_compresses_to
	/// How much it an ore gives
	var/ore_result_amount
	/// The chance its ore spreads into the rock around it, in percent
	var/ore_spread_chance
	var/ore_scan_icon
	var/ore_icon_overlay
	/// What a sheet of it sells for
	var/sale_price
	/// What it is worth
	var/value = 1
	/// Whether it fuels fusion
	var/is_fusion_fuel

/material/New()
	..()
	if(!display_name)
		display_name = name
	if(!use_name)
		use_name = display_name
	if(!adjective_name)
		adjective_name = display_name
	if(!shard_icon)
		shard_icon = shard_type
	if(!burn_armor)
		burn_armor = brute_armor

/// Whether things of it break rather than bend
/material/proc/is_brittle()
	return !!(flags & MATERIAL_BRITTLE)

/// Whether the glass is reinforced, which strong glass counts as
/material/glass/proc/is_reinforced()
	return integrity > 75

/material/glass/is_brittle()
	return ..() && !is_reinforced()

/// What skin of this kind is tanned into
/material/skin/var/tans_to = MATERIAL_LEATHER_GENERIC

/**
 * The Bay material of the given name, null if there is none
 *
 * * name - its name, any case
 */
/proc/get_bay_material(name)
	RETURN_TYPE(/material)
	var/static/list/materials_by_name
	if(!materials_by_name)
		materials_by_name = list()
		for(var/material_type in subtypesof(/material))
			var/material/material = new material_type()
			if(material.name)
				materials_by_name[lowertext(material.name)] = material
	if(!name)
		return null
	var/material/material = materials_by_name[lowertext(name)]
	if(!material)
		log_debug("No Bay material named '[name]'")
	return material
