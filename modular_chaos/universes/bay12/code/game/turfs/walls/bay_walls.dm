//Walls of Baystation 12 (/turf/simulated/wall in the source): bulkheads of steel and other materials, painted

/// Health of a Bay wall of steel in the source, which a CM wall's HEALTH_WALL stands for
#define BAY_STEEL_WALL_HEALTH 225

/// Whether the area is outside the ship, AREA_FLAG_EXTERNAL in the source, which hull walls next to it fade from
/area/var/bay_external = FALSE

/area/space
	bay_external = TRUE

/**
 * A Bay wall
 *
 * Made of a Bay material and reinforced with another, as in the source: they give it its name, the masks it is drawn
 * with, its colour, whether it has edges and a stripe that takes paint, whether it can be seen through, and how much
 * it takes, in CM's units (a steel wall has CM's HEALTH_WALL). It joins walls of the same mask, and of the masks its
 * material blends with, with an edge between those and between walls of other paints.
 *
 * Drawn the way /turf/simulated/wall/on_update_icon() draws it in the source: four corners of greyscale masks from
 * walls.dmi, coloured at runtime. The base mask takes paint_color, or the colour of the material if the wall is not
 * painted; over it go the paint and stripe masks, the reinforcement, and the edges in the stripe colour. Mappers can
 * paint a placed wall with paint_color and stripe_color.
 *
 * The parent's smoothing is turned off with special_icon, which here only means that this type draws its corners itself.
 * The color var shows the paint in the map editor: painted types set it to their paint_color, and a color set on a
 * placed wall becomes its paint_color on Initialize(). It is cleared then, as it would tint everything on the wall.
 */
/turf/closed/wall/bay
	name = "steel bulkhead"
	desc = "It seems to be a section of hull plated with steel."
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/walls.dmi'
	icon_state = "generic"
	walltype = "solid"
	special_icon = TRUE
	/// The material it is plated with, a material name until resolve_materials(), then the /material
	var/material/material = MATERIAL_STEEL
	/// The material it is reinforced with, a material name until resolve_materials(), then the /material; null for none
	var/material/reinf_material
	/// Colour the wall is painted, null if it is not
	var/paint_color
	/// Colour of the stripe along the wall, and of its edges; null if it has none
	var/stripe_color
	/// Corner states of the edge, in the order of wall_connections; "0" is no edge on that corner
	var/list/edge_connections = list("0", "0", "0", "0")

/turf/closed/wall/bay/Initialize(mapload, ...)
	if(color && color != initial(color)) // Painted in the map editor
		paint_color = color
	color = null
	resolve_materials()
	update_material()
	return ..()

/**
 * Turns the material names the wall is mapped with into the materials
 *
 * Walls next to it draw it before it initializes, so they call this too.
 */
/turf/closed/wall/bay/proc/resolve_materials()
	if(istext(material))
		material = get_bay_material(material)
	if(istext(reinf_material))
		reinf_material = get_bay_material(reinf_material)

/// Names the wall after its materials and sets what they make of it, /turf/simulated/wall/proc/update_material() of the source
/turf/closed/wall/bay/proc/update_material()
	if(reinf_material)
		name = "reinforced [material.display_name] [material.wall_name]"
		desc = "It seems to be a section of hull reinforced with [reinf_material.display_name] and plated with [material.display_name]."
	else
		name = "[material.display_name] [material.wall_name]"
		desc = "It seems to be a section of hull plated with [material.display_name]."
	set_opacity(material.opacity >= 0.5)
	var/bay_health = material.integrity * 1.5
	if(reinf_material)
		bay_health += round(reinf_material.integrity * 0.75)
	damage_cap = round(HEALTH_WALL * bay_health / BAY_STEEL_WALL_HEALTH)

/**
 * How the wall joins another, can_join_with() of the source
 *
 * Returns 0 if it does not, 1 if it does, and 2 if it does with an edge between, as between walls of other paints or
 * of masks the material blends with.
 * * target - the other wall
 */
/turf/closed/wall/bay/can_join_with(turf/closed/wall/target)
	var/turf/closed/wall/bay/target_wall = target
	if(!istype(target_wall))
		return 0
	resolve_materials()
	target_wall.resolve_materials()
	if(!material || !target_wall.material)
		return 0
	if(material.wall_blend_icons[target_wall.material.wall_icon_base])
		return 2
	if(material.wall_icon_base == target_wall.material.wall_icon_base)
		return paint_color == target_wall.paint_color ? 1 : 2
	return 0

/turf/closed/wall/bay/update_connections(propagate = FALSE)
	. = ..()
	resolve_materials()
	if(!(material.wall_flags & MATERIAL_WALL_HAS_EDGES))
		return
	var/list/edge_dirs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor)
			continue
		if(istype(neighbor, /turf/closed/wall))
			if(can_join_with(neighbor) == 2)
				edge_dirs += direction
			continue
		if(!(direction in GLOB.cardinals))
			continue
		for(var/obj/structure/machinery/door/door in neighbor)
			if(can_join_with_object(door))
				edge_dirs += direction
				break
	edge_connections = dirs_to_corner_states(edge_dirs)

/turf/closed/wall/bay/update_icon()
	. = ..()
	if(QDELETED(src))
		return
	resolve_materials()
	icon_state = "blank"
	flags_atom |= HTML_USE_INITIAL_ICON
	// The parent added the damage and bullet holes last; the wall goes under them
	var/list/damage_images = list()
	if(damage)
		damage_images += damage_overlays[damage_overlay]
		if(current_bulletholes && bullet_overlay)
			damage_images += bullet_overlay
	for(var/damage_image in damage_images)
		overlays -= damage_image

	var/wall_icon_base = material.wall_icon_base
	var/base_color = paint_color || material.icon_colour
	for(var/i in 1 to 4)
		var/corner_dir = 1<<(i-1)
		overlays += wall_layer("[wall_icon_base][wall_connections[i]]", corner_dir, base_color)
		if(paint_color)
			overlays += wall_layer("[wall_icon_base]_paint[wall_connections[i]]", corner_dir, paint_color)
		if(stripe_color)
			overlays += wall_layer("[wall_icon_base]_stripe[wall_connections[i]]", corner_dir, stripe_color)
	if(reinf_material)
		var/reinf_color = paint_color || reinf_material.icon_colour
		var/wall_icon_reinf = material.wall_icon_reinf
		if(icon_exists(icon, "[wall_icon_reinf]0"))
			for(var/i in 1 to 4)
				overlays += wall_layer("[wall_icon_reinf][wall_connections[i]]", 1<<(i-1), reinf_color)
		else
			overlays += wall_layer(wall_icon_reinf, SOUTH, reinf_color)
	if(material.wall_flags & MATERIAL_WALL_HAS_EDGES)
		for(var/i in 1 to 4)
			if(edge_connections[i] != "0")
				overlays += wall_layer("[wall_icon_base]_other[edge_connections[i]]", 1<<(i-1), stripe_color || base_color)

	for(var/damage_image in damage_images)
		overlays += damage_image

/**
 * One mask of a Bay wall, coloured; the images are cached, as every wall of a paint uses the same few
 *
 * * icon_state - the mask
 * * corner_dir - dir of the image, which picks the corner of the mask
 * * color - colour the mask is multiplied by
 */
/turf/closed/wall/bay/proc/wall_layer(icon_state, corner_dir, color)
	var/static/list/layer_cache = list()
	var/key = "[icon_state]-[corner_dir]-[color]"
	var/image/layer = layer_cache[key]
	if(!layer)
		layer = image(icon, icon_state, dir = corner_dir)
		layer.color = color
		layer_cache[key] = layer
	return layer

/**
 * Paints the wall, where its material takes paint: the wall itself and, if it can have one, its stripe
 *
 * * new_color - the paint
 */
/turf/closed/wall/bay/proc/paint(new_color)
	if(material.wall_flags & MATERIAL_PAINTABLE_MAIN)
		paint_color = new_color
	if(material.wall_flags & MATERIAL_PAINTABLE_STRIPE)
		stripe_color = new_color
	for(var/turf/closed/wall/bay/painted_wall in range(1, src))
		painted_wall.update_connections()
		painted_wall.update_icon()

/// Called by windows and doors next to the wall when they change. The parent sets icon_state to "[walltype][junction]", which this wall does not use, so it redraws the corners instead.
/turf/closed/wall/bay/handle_icon_junction(junction)
	junctiontype = junction
	update_connections()
	update_icon()

/**
 * Brightens a colour, adjust_brightness() of the source
 *
 * * color - the colour
 * * value - how much to add to each channel, 0 to 255
 */
/proc/bay_adjust_brightness(color, value)
	if(!color)
		return "#ffffff"
	if(!value)
		return color
	var/list/channels = rgb2num(color)
	return rgb(clamp(channels[1] + value, 0, 255), clamp(channels[2] + value, 0, 255), clamp(channels[3] + value, 0, 255))

/// /turf/simulated/wall/prepainted in the source: the dark gunmetal of the SEV Torch
/turf/closed/wall/bay/prepainted
	color = COLOR_WALL_GUNMETAL
	paint_color = COLOR_WALL_GUNMETAL
	stripe_color = COLOR_GUNMETAL

/// /turf/simulated/wall/prepainted/fleet in the source: the dark blue of the Fleet
/turf/closed/wall/bay/prepainted/fleet
	color = COLOR_DARK_BLUE_GRAY
	paint_color = COLOR_DARK_BLUE_GRAY
	stripe_color = COLOR_WALL_GUNMETAL

/// /turf/simulated/wall/r_wall in the source: steel reinforced with plasteel
/turf/closed/wall/bay/reinforced
	icon_state = "r_generic"
	reinf_material = MATERIAL_PLASTEEL

/turf/closed/wall/bay/reinforced/prepainted
	color = COLOR_WALL_GUNMETAL
	paint_color = COLOR_WALL_GUNMETAL
	stripe_color = COLOR_GUNMETAL

/turf/closed/wall/bay/reinforced/prepainted/fleet
	color = COLOR_DARK_BLUE_GRAY
	paint_color = COLOR_DARK_BLUE_GRAY
	stripe_color = COLOR_WALL_GUNMETAL

/**
 * /turf/simulated/wall/r_wall/hull in the source: a reinforced wall painted all over in the blue of the Sol Central
 * Government, its paint faded on two in five of those that face the outside
 */
/turf/closed/wall/bay/reinforced/hull
	name = "hull"
	color = COLOR_SOL
	paint_color = COLOR_SOL
	stripe_color = COLOR_SOL

/turf/closed/wall/bay/reinforced/hull/Initialize(mapload, ...)
	. = ..()
	if(!prob(40))
		return
	for(var/direction in GLOB.cardinals)
		var/area/outside = get_area(get_step(src, direction))
		if(outside?.bay_external)
			var/bleach_factor = rand(10, 50)
			paint_color = bay_adjust_brightness(paint_color, bleach_factor)
			stripe_color = bay_adjust_brightness(stripe_color, bleach_factor)
			update_icon()
			return

/// A hull wall that cannot be damaged, for the outside of a ship, like /turf/closed/wall/almayer/outer
/turf/closed/wall/bay/reinforced/hull/outer
	name = "outer hull"
	turf_flags = TURF_HULL

// The walls of other materials (code/game/turfs/simulated/wall_types.dm in the source)

/turf/closed/wall/bay/titanium
	icon_state = "titanium"
	material = MATERIAL_TITANIUM

/// /turf/simulated/wall/r_titanium in the source
/turf/closed/wall/bay/titanium/reinforced
	icon_state = "r_titanium"
	reinf_material = MATERIAL_TITANIUM

/// /turf/simulated/wall/ocp_wall in the source: osmium-carbide plasteel
/turf/closed/wall/bay/ocp
	icon_state = "r_ocp"
	material = MATERIAL_OSMIUM_CARBIDE_PLASTEEL
	reinf_material = MATERIAL_OSMIUM_CARBIDE_PLASTEEL

/// /turf/simulated/wall/r_wall/rglass_wall in the source: glass reinforced with steel, which can be seen through
/turf/closed/wall/bay/reinforced/rglass
	material = MATERIAL_GLASS
	reinf_material = MATERIAL_STEEL

/turf/closed/wall/bay/iron
	material = MATERIAL_IRON

/turf/closed/wall/bay/uranium
	material = MATERIAL_URANIUM

/turf/closed/wall/bay/diamond
	material = MATERIAL_DIAMOND

/turf/closed/wall/bay/gold
	material = MATERIAL_GOLD

/turf/closed/wall/bay/silver
	material = MATERIAL_SILVER

/turf/closed/wall/bay/phoron
	material = MATERIAL_PHORON

/turf/closed/wall/bay/sandstone
	material = MATERIAL_SANDSTONE

/turf/closed/wall/bay/rutile
	material = MATERIAL_RUTILE

/turf/closed/wall/bay/wood
	icon_state = "woodneric"
	color = WOOD_COLOR_GENERIC
	material = BAY_MATERIAL_WOOD

/turf/closed/wall/bay/mahogany
	icon_state = "woodneric"
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY

/turf/closed/wall/bay/maple
	icon_state = "woodneric"
	color = WOOD_COLOR_PALE
	material = MATERIAL_MAPLE

/turf/closed/wall/bay/ebony
	icon_state = "woodneric"
	color = WOOD_COLOR_BLACK
	material = MATERIAL_EBONY

/turf/closed/wall/bay/walnut
	icon_state = "woodneric"
	color = WOOD_COLOR_CHOCOLATE
	material = MATERIAL_WALNUT

/turf/closed/wall/bay/ironphoron
	material = MATERIAL_IRON
	reinf_material = MATERIAL_PHORON

/turf/closed/wall/bay/golddiamond
	material = MATERIAL_GOLD
	reinf_material = MATERIAL_DIAMOND

/turf/closed/wall/bay/silvergold
	material = MATERIAL_SILVER
	reinf_material = MATERIAL_GOLD

/turf/closed/wall/bay/sandstone/diamond
	reinf_material = MATERIAL_DIAMOND

/turf/closed/wall/bay/crystal
	material = MATERIAL_CRYSTAL

/turf/closed/wall/bay/concrete
	material = MATERIAL_CONCRETE

#undef BAY_STEEL_WALL_HEALTH
