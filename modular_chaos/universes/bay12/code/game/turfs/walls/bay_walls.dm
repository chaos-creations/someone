//Walls of Baystation 12 (/turf/simulated/wall in the source): bulkheads of steel and other materials, painted

/**
 * A Bay wall
 *
 * Drawn the way /turf/simulated/wall/on_update_icon() draws it in the source: four corners of greyscale masks from
 * walls.dmi, coloured at runtime. The base mask takes paint_color, or material_color if the wall is not painted; over it
 * go the paint and stripe masks, the reinforcement, and an edge in the stripe colour on the side of a door or of a wall
 * that is painted otherwise. Mappers can paint a placed wall with paint_color and stripe_color.
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
	/// Prefix of the masks of the wall itself: "solid" or "metal"; the paint, stripe and edge masks add "_paint", "_stripe" and "_other"
	var/wall_icon_base = "solid"
	/// Icon state of the reinforcement over the wall, null if it has none; one with directional states "[wall_icon_reinf][corner state]" is drawn by corners
	var/wall_icon_reinf
	/// Colour of the material of the wall, which it shows if it is not painted
	var/material_color = COLOR_STEEL
	/// Colour of the material of the reinforcement, which it shows if the wall is not painted
	var/reinf_material_color = COLOR_PLASTEEL
	/// Colour the wall is painted, null if it is not
	var/paint_color
	/// Colour of the stripe along the wall, and of its edges; null if it has none
	var/stripe_color
	/// Whether an edge is drawn where the wall meets a door or a wall of another paint, as Bay does for steel and plasteel
	var/has_edges = TRUE
	/// Corner states of the edge, in the order of wall_connections; "0" is no edge on that corner
	var/list/edge_connections = list("0", "0", "0", "0")

/turf/closed/wall/bay/Initialize(mapload, ...)
	if(color && color != initial(color)) // Painted in the map editor
		paint_color = color
	color = null
	return ..()

/turf/closed/wall/bay/update_connections(propagate = FALSE)
	. = ..()
	if(!has_edges)
		return
	var/list/edge_dirs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor)
			continue
		if(istype(neighbor, /turf/closed/wall))
			var/turf/closed/wall/bay/neighbor_wall = neighbor
			if(!can_join_with(neighbor_wall))
				continue
			if(!istype(neighbor_wall) || neighbor_wall.wall_icon_base != wall_icon_base || neighbor_wall.paint_color != paint_color)
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

	var/base_color = paint_color || material_color
	for(var/i in 1 to 4)
		var/corner_dir = 1<<(i-1)
		overlays += wall_layer("[wall_icon_base][wall_connections[i]]", corner_dir, base_color)
		if(paint_color)
			overlays += wall_layer("[wall_icon_base]_paint[wall_connections[i]]", corner_dir, paint_color)
		if(stripe_color)
			overlays += wall_layer("[wall_icon_base]_stripe[wall_connections[i]]", corner_dir, stripe_color)
	if(wall_icon_reinf)
		var/reinf_color = paint_color || reinf_material_color
		if(icon_exists(icon, "[wall_icon_reinf]0"))
			for(var/i in 1 to 4)
				overlays += wall_layer("[wall_icon_reinf][wall_connections[i]]", 1<<(i-1), reinf_color)
		else
			overlays += wall_layer(wall_icon_reinf, SOUTH, reinf_color)
	if(has_edges)
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

/// Called by windows and doors next to the wall when they change. The parent sets icon_state to "[walltype][junction]", which this wall does not use, so it redraws the corners instead.
/turf/closed/wall/bay/handle_icon_junction(junction)
	junctiontype = junction
	update_connections()
	update_icon()

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

/// /turf/simulated/wall/r_wall in the source: plasteel over the plating, three times the health
/turf/closed/wall/bay/reinforced
	name = "reinforced steel bulkhead"
	desc = "It seems to be a section of hull reinforced with plasteel and plated with steel."
	icon_state = "r_generic"
	wall_icon_reinf = "reinf_over"
	damage_cap = HEALTH_WALL_REINFORCED

/turf/closed/wall/bay/reinforced/prepainted
	color = COLOR_WALL_GUNMETAL
	paint_color = COLOR_WALL_GUNMETAL
	stripe_color = COLOR_GUNMETAL

/turf/closed/wall/bay/reinforced/prepainted/fleet
	color = COLOR_DARK_BLUE_GRAY
	paint_color = COLOR_DARK_BLUE_GRAY
	stripe_color = COLOR_WALL_GUNMETAL

/// /turf/simulated/wall/r_wall/hull in the source: a reinforced wall painted all over in the blue of the Sol Central Government
/turf/closed/wall/bay/reinforced/hull
	name = "hull"
	color = COLOR_SOL
	paint_color = COLOR_SOL
	stripe_color = COLOR_SOL

/// A hull wall that cannot be damaged, for the outside of a ship, like /turf/closed/wall/almayer/outer
/turf/closed/wall/bay/reinforced/hull/outer
	name = "outer hull"
	turf_flags = TURF_HULL

/// /turf/simulated/wall/titanium in the source: pale titanium plates, with no stripe or edges
/turf/closed/wall/bay/titanium
	name = "titanium wall"
	desc = "It seems to be a section of hull plated with titanium."
	icon_state = "titanium"
	wall_icon_base = "metal"
	material_color = COLOR_TITANIUM
	has_edges = FALSE

/// /turf/simulated/wall/r_titanium in the source
/turf/closed/wall/bay/titanium/reinforced
	name = "reinforced titanium wall"
	desc = "It seems to be a section of hull reinforced with titanium and plated with titanium."
	icon_state = "r_titanium"
	wall_icon_reinf = "reinf_metal"
	reinf_material_color = COLOR_TITANIUM
	damage_cap = HEALTH_WALL_REINFORCED

/// /turf/simulated/wall/ocp_wall in the source: osmium-carbide plasteel, light blue
/turf/closed/wall/bay/ocp
	name = "reinforced osmium-carbide plasteel bulkhead"
	desc = "It seems to be a section of hull reinforced with osmium-carbide plasteel and plated with osmium-carbide plasteel."
	icon_state = "r_generic"
	material_color = COLOR_OSMIUM_CARBIDE_PLASTEEL
	wall_icon_reinf = "reinf_over"
	reinf_material_color = COLOR_OSMIUM_CARBIDE_PLASTEEL
	damage_cap = HEALTH_WALL_REINFORCED
