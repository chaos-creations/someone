//Tables and racks of Baystation 12 (code/modules/tables/ in the source)

// The corners a table is drawn from, as dirs_to_corner_states() of the source sets them
#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

/**
 * A Bay table
 *
 * A CM table, flipped into cover and slid over as those are, made of a Bay material and reinforced with another, as
 * in the source: it takes their colour, sprites and strength, and joins only the tables of the same material next to
 * it, drawn corner by corner, not across windows. A reinforced one does not flip. Building and taking apart Bay tables
 * comes with Bay material sheets.
 */
/obj/structure/surface/table/bay
	name = "table frame"
	desc = "It's a table, for putting things on. Or standing on, if you really want to."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/tables.dmi'
	icon_state = "frame"
	/// The material of its top, a material name until Initialize(), then the /material; null for a bare frame
	var/material/material
	/// The material it is reinforced with, a material name until Initialize(), then the /material; null for none
	var/material/reinforcement
	/// Whether it is padded with carpet, as gambling tables are
	var/carpeted = FALSE
	/// The four corner states it is drawn with: north-west, south-east, north-east and south-west
	var/list/connections = list("0", "0", "0", "0")

/obj/structure/surface/table/bay/Initialize()
	resolve_materials()
	// The colour and alpha of the map editor previews
	color = null
	alpha = 255
	update_material()
	update_desc()
	return ..()

/**
 * Turns the material names the table is mapped with into the materials
 *
 * Tables next to it draw it before it initializes, so they call this too.
 */
/obj/structure/surface/table/bay/proc/resolve_materials()
	if(istext(material))
		material = get_bay_material(material)
	if(istext(reinforcement))
		reinforcement = get_bay_material(reinforcement)
	reinforced = !!reinforcement

/// Sets the health of the table from its materials, as the source does
/obj/structure/surface/table/bay/proc/update_material()
	if(!material)
		health = 10
		return
	health = material.integrity * 0.5
	if(reinforcement)
		health += reinforcement.integrity * 0.5

/// Names the table after its materials
/obj/structure/surface/table/bay/proc/update_desc()
	name = material ? "[material.display_name] table" : "table frame"
	desc = initial(desc)
	if(reinforcement)
		name = "reinforced [name]"
		desc = "[initial(desc)] This one seems to be reinforced with [reinforcement.display_name]."

/obj/structure/surface/table/bay/update_icon()
	resolve_materials()
	overlays.Cut()
	if(flipped)
		update_flipped_icon()
		return
	icon_state = "blank"
	update_connections()
	// The frame, which shows through glass tops
	for(var/i in 1 to 4)
		overlays += image(icon, connections[i], dir = 1 << (i - 1))
	if(!material)
		return
	for(var/i in 1 to 4)
		var/image/top = image(icon, "[material.table_icon_base]_[connections[i]]", dir = 1 << (i - 1))
		top.color = material.icon_colour
		top.alpha = 255 * material.opacity
		overlays += top
	if(reinforcement)
		for(var/i in 1 to 4)
			var/image/reinforcing = image(icon, "[material.table_icon_reinf]_[connections[i]]", dir = 1 << (i - 1))
			reinforcing.color = reinforcement.icon_colour
			reinforcing.alpha = 255 * reinforcement.opacity
			overlays += reinforcing
	if(carpeted)
		for(var/i in 1 to 4)
			overlays += image(icon, "carpet_[connections[i]]", dir = 1 << (i - 1))

/// Draws the table on its side, joined with the flipped tables of the same material along it
/obj/structure/surface/table/bay/proc/update_flipped_icon()
	var/count = 0
	var/table_dirs = 0
	for(var/direction in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/surface/table/bay/table = locate() in get_step(src, direction)
		if(table?.flipped && table.dir == dir && same_material(table))
			count++
			table_dirs |= direction
	var/flip_type = "[count]"
	if(count == 1)
		if(table_dirs & turn(dir, 90))
			flip_type += "-"
		if(table_dirs & turn(dir, -90))
			flip_type += "+"
	icon_state = "flip[flip_type]"
	if(!material)
		return
	var/image/top = image(icon, "[material.table_icon_base]_flip[flip_type]")
	top.color = material.icon_colour
	top.alpha = 255 * material.opacity
	overlays += top
	if(reinforcement)
		var/image/reinforcing = image(icon, "[material.table_icon_reinf]_flip[flip_type]")
		reinforcing.color = reinforcement.icon_colour
		reinforcing.alpha = 255 * reinforcement.opacity
		overlays += reinforcing
	if(carpeted)
		overlays += image(icon, "carpet_flip[flip_type]")

/**
 * Whether another table is of the same material, which tables join only with
 *
 * * table - the other table
 */
/obj/structure/surface/table/bay/proc/same_material(obj/structure/surface/table/bay/table)
	resolve_materials()
	table.resolve_materials()
	return material && table.material && material.name == table.material.name

/// Works out the corners the table is drawn with from the tables it joins, which windows between them keep apart
/obj/structure/surface/table/bay/proc/update_connections()
	if(!material)
		connections = list("0", "0", "0", "0")
		return
	var/list/blocked_dirs = list()
	for(var/obj/structure/window/window in loc)
		if(window.is_full_window())
			connections = list("0", "0", "0", "0")
			return
		blocked_dirs |= window.dir
	for(var/direction in GLOB.cardinals - blocked_dirs)
		for(var/obj/structure/window/window in get_step(src, direction))
			if(window.is_full_window() || window.dir == REVERSE_DIR(direction))
				blocked_dirs |= direction
				break
			if(window.dir != direction)
				// Off to the side, it blocks the diagonal
				blocked_dirs |= window.dir | direction
	for(var/direction in GLOB.diagonals - blocked_dirs)
		for(var/obj/structure/window/window in get_step(src, direction))
			if(window.is_full_window() || (window.dir & REVERSE_DIR(direction)))
				blocked_dirs |= direction
				break
	// A blocked cardinal blocks the diagonals next to it too
	for(var/north_south in list(NORTH, SOUTH))
		for(var/east_west in list(EAST, WEST))
			if((north_south in blocked_dirs) || (east_west in blocked_dirs))
				blocked_dirs |= north_south | east_west
	var/list/connection_dirs = list()
	for(var/obj/structure/surface/table/bay/table in orange(src, 1))
		var/table_dir = get_dir(src, table)
		if(!(table_dir in blocked_dirs) && same_material(table) && flipped == table.flipped)
			connection_dirs |= table_dir
	connections = list()
	for(var/corner in list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST))
		var/corner_state = CORNER_NONE
		if(corner in connection_dirs)
			corner_state |= CORNER_DIAGONAL
		if(turn(corner, 45) in connection_dirs)
			corner_state |= CORNER_COUNTERCLOCKWISE
		if(turn(corner, -45) in connection_dirs)
			corner_state |= CORNER_CLOCKWISE
		connections += "[corner_state]"

// A reinforced Bay table does not flip; nor does one that joins tables of another material along the flip
/obj/structure/surface/table/bay/flip(direction, skip_straight_check = FALSE)
	if(reinforcement)
		to_chat(usr, SPAN_NOTICE("It won't budge."))
		return FALSE
	return ..()

/obj/structure/surface/table/bay/update_adjacent(location)
	if(!location)
		location = src
	for(var/obj/structure/surface/table/bay/table in orange(location, 1))
		if(!HAS_TRAIT(table, TRAIT_TABLE_FLIPPING))
			table.update_icon()

// Presets (code/modules/tables/presets.dm in the source); the colours are their map editor previews

/obj/structure/surface/table/bay/standard
	icon_state = "plain_preview"
	color = COLOR_OFF_WHITE
	material = DEFAULT_FURNITURE_MATERIAL

/obj/structure/surface/table/bay/steel
	icon_state = "plain_preview"
	color = COLOR_GRAY40
	material = MATERIAL_STEEL

/obj/structure/surface/table/bay/marble
	icon_state = "stone_preview"
	color = COLOR_GRAY80
	material = MATERIAL_MARBLE

/obj/structure/surface/table/bay/reinforced
	icon_state = "reinf_preview"
	color = COLOR_OFF_WHITE
	material = DEFAULT_FURNITURE_MATERIAL
	reinforcement = MATERIAL_STEEL

/obj/structure/surface/table/bay/steel_reinforced
	icon_state = "reinf_preview"
	color = COLOR_GRAY40
	material = MATERIAL_STEEL
	reinforcement = MATERIAL_STEEL

/obj/structure/surface/table/bay/gamblingtable
	icon_state = "gamble_preview"
	carpeted = TRUE
	material = MATERIAL_WALNUT

/obj/structure/surface/table/bay/glass
	icon_state = "plain_preview"
	color = COLOR_DEEP_SKY_BLUE
	alpha = 77
	material = MATERIAL_GLASS

/obj/structure/surface/table/bay/glass/boron
	color = GLASS_COLOR_BORON
	material = MATERIAL_BORON_GLASS

/obj/structure/surface/table/bay/woodentable
	icon_state = "solid_preview"
	color = WOOD_COLOR_GENERIC
	material = BAY_MATERIAL_WOOD

/obj/structure/surface/table/bay/woodentable/mahogany
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY

/obj/structure/surface/table/bay/woodentable/maple
	color = WOOD_COLOR_PALE
	material = MATERIAL_MAPLE

/obj/structure/surface/table/bay/woodentable/ebony
	color = WOOD_COLOR_BLACK
	material = MATERIAL_EBONY

/obj/structure/surface/table/bay/woodentable/walnut
	color = WOOD_COLOR_CHOCOLATE
	material = MATERIAL_WALNUT

/obj/structure/surface/table/bay/woodentable_reinforced
	icon_state = "reinf_preview"
	color = WOOD_COLOR_GENERIC
	material = BAY_MATERIAL_WOOD
	reinforcement = BAY_MATERIAL_WOOD

/obj/structure/surface/table/bay/woodentable_reinforced/walnut
	color = WOOD_COLOR_CHOCOLATE
	material = MATERIAL_WALNUT
	reinforcement = MATERIAL_WALNUT

/obj/structure/surface/table/bay/woodentable_reinforced/walnut/maple
	reinforcement = MATERIAL_MAPLE

/obj/structure/surface/table/bay/woodentable_reinforced/mahogany
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY
	reinforcement = MATERIAL_MAHOGANY

/obj/structure/surface/table/bay/woodentable_reinforced/mahogany/walnut
	reinforcement = MATERIAL_WALNUT

/obj/structure/surface/table/bay/woodentable_reinforced/ebony
	color = WOOD_COLOR_BLACK
	material = MATERIAL_EBONY
	reinforcement = MATERIAL_WALNUT

/obj/structure/surface/table/bay/woodentable_reinforced/ebony/walnut
	reinforcement = MATERIAL_WALNUT

/**
 * A Bay rack
 *
 * A CM rack with the sprite of the source.
 */
/obj/structure/surface/rack/bay
	desc = "Different from the Middle Ages version."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/furniture.dmi'
	icon_state = "rack"

/obj/structure/surface/rack/bay/dark
	color = COLOR_GRAY40

#undef CORNER_NONE
#undef CORNER_COUNTERCLOCKWISE
#undef CORNER_DIAGONAL
#undef CORNER_CLOCKWISE
