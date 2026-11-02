/**
 * Moves the parent by pixels inside its tile until it leaves the tile, see [/datum/component/pixel_shifting]
 *
 * Whatever of the parent is drawn over a wall south of its tile is hidden, as with wall leaning, so it stands behind the wall instead of over it.
 * Removing the component puts the parent back.
 *
 * Moves can glide. A new animation would start from where the last one ends rather than where the parent is seen,
 * so every glide starts by putting the parent where it is seen at that moment, worked out from the last glide.
 * The wall masks are not animated: an animation of a filter belongs to its atom, and clients lose track of it
 * once masks are removed and added again, leaving the mask at the end of the glide. They follow the parent every tick instead.
 */
/datum/component/pixel_shifted
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Names of the filters hiding the parent behind walls, by the x offset of the wall tile from its tile plus 2
	var/static/list/wall_cut_filters = list("pixel_shift_cut_west", "pixel_shift_cut_south", "pixel_shift_cut_east")
	/// Opaque tile that the wall cut filters hide the parent with
	var/static/icon/wall_cut_mask = icon('icons/effects/alphacolors.dmi', "")
	/// pixel_x the parent glides from in its last glide. It glides to its pixel_x
	var/glide_from_x = 0
	/// pixel_y the parent glides from in its last glide. It glides to its pixel_y
	var/glide_from_y = 0
	/// world.time when the last glide started
	var/glide_start_time = 0
	/// How long the last glide takes
	var/glide_time = 0
	/// Timer moving the wall masks along with the parent while it glides
	var/mask_timer

/datum/component/pixel_shifted/Initialize()
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shifted/RegisterWithParent()
	..()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(unshift))
	if(isliving(parent))
		// Lying down, buckling and attack animations set the offsets themselves
		RegisterSignal(parent, list(COMSIG_LIVING_SET_BODY_POSITION, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOB_ANIMATING), PROC_REF(unshift))

/datum/component/pixel_shifted/UnregisterFromParent()
	..()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOB_ANIMATING))
	if(QDELETED(parent))
		return
	deltimer(mask_timer)
	mask_timer = null
	var/atom/movable/shifted = parent
	shifted.remove_filter(wall_cut_filters)
	if(is_gliding())
		// The glide would carry on to the shifted place, so it is finished at once
		animate(shifted, pixel_x = shifted.base_pixel_x, pixel_y = shifted.base_pixel_y, time = 0, flags = ANIMATION_END_NOW)
	else
		shifted.pixel_x = shifted.base_pixel_x
		shifted.pixel_y = shifted.base_pixel_y

/// Puts the parent back where it normally stands
/datum/component/pixel_shifted/proc/unshift()
	SIGNAL_HANDLER
	qdel(src)

/// Whether the parent is still gliding to its pixel offsets
/datum/component/pixel_shifted/proc/is_gliding()
	return world.time < glide_start_time + glide_time

/**
 * Returns the pixel offsets the parent is seen at right now, partway through its glide, as list(pixel_x, pixel_y)
 *
 * Arguments:
 * * whole - whether to round them to whole pixels, as pixel offsets to set. Masks follow the glide better unrounded
 */
/datum/component/pixel_shifted/proc/get_seen_pixel(whole = TRUE)
	var/atom/movable/shifted = parent
	if(!is_gliding())
		return list(shifted.pixel_x, shifted.pixel_y)
	var/progress = (world.time - glide_start_time) / glide_time
	var/seen_x = glide_from_x + (shifted.pixel_x - glide_from_x) * progress
	var/seen_y = glide_from_y + (shifted.pixel_y - glide_from_y) * progress
	if(whole)
		return list(round(seen_x, 1), round(seen_y, 1))
	return list(seen_x, seen_y)

/**
 * Moves the parent to the given pixel offsets, as close as PIXEL_SHIFT_RADIUS allows from its base offsets
 *
 * Arguments:
 * * new_x - pixel_x to move to
 * * new_y - pixel_y to move to
 * * time - how long the parent glides there from where it is seen, at an even speed
 */
/datum/component/pixel_shifted/proc/shift_to(new_x, new_y, time = 0)
	var/atom/movable/shifted = parent
	var/list/new_pixel = shifted.clamp_pixel_shift(new_x, new_y)
	var/list/seen_pixel = get_seen_pixel()
	if(new_pixel[1] == seen_pixel[1] && new_pixel[2] == seen_pixel[2] && !is_gliding())
		return
	glide_from_x = seen_pixel[1]
	glide_from_y = seen_pixel[2]
	glide_start_time = world.time
	glide_time = time
	if(time)
		// The animation starts from the appearance it is called on
		shifted.pixel_x = seen_pixel[1]
		shifted.pixel_y = seen_pixel[2]
		animate(shifted, pixel_x = new_pixel[1], pixel_y = new_pixel[2], time = time)
	else
		shifted.pixel_x = new_pixel[1]
		shifted.pixel_y = new_pixel[2]
	var/from_x = time ? seen_pixel[1] : new_pixel[1]
	var/from_y = time ? seen_pixel[2] : new_pixel[2]
	if(update_wall_cut(new_pixel[1], new_pixel[2], from_x, from_y) && time && !mask_timer)
		mask_timer = addtimer(CALLBACK(src, PROC_REF(follow_masks)), world.tick_lag, TIMER_STOPPABLE|TIMER_LOOP)

/**
 * Glides the parent from where it is seen in the direction, at the speed, up to the edge of PIXEL_SHIFT_RADIUS
 *
 * From the edge it slides along the edge instead, towards where the direction points from the base offsets.
 *
 * Arguments:
 * * direction - the direction to glide in, diagonals included
 * * speed - pixels a decisecond
 */
/datum/component/pixel_shifted/proc/glide_toward(direction, speed)
	var/atom/movable/shifted = parent
	var/list/seen_pixel = get_seen_pixel()
	var/step_x = ((direction & EAST) ? 1 : 0) - ((direction & WEST) ? 1 : 0)
	var/step_y = ((direction & NORTH) ? 1 : 0) - ((direction & SOUTH) ? 1 : 0)
	var/step_length = sqrt(step_x ** 2 + step_y ** 2)
	if(!step_length)
		return
	step_x /= step_length
	step_y /= step_length
	// How far along the direction the edge of the radius is, from where the parent is seen
	var/offset_x = seen_pixel[1] - shifted.base_pixel_x
	var/offset_y = seen_pixel[2] - shifted.base_pixel_y
	var/along = offset_x * step_x + offset_y * step_y
	var/discriminant = along ** 2 - (offset_x ** 2 + offset_y ** 2 - PIXEL_SHIFT_RADIUS ** 2)
	var/distance = discriminant > 0 ? sqrt(discriminant) - along : 0
	if(distance >= 1)
		shift_to(seen_pixel[1] + step_x * distance, seen_pixel[2] + step_y * distance, distance / speed)
		return
	var/list/edge_pixel = shifted.clamp_pixel_shift(seen_pixel[1] + step_x * PIXEL_SHIFT_RADIUS, seen_pixel[2] + step_y * PIXEL_SHIFT_RADIUS)
	distance = sqrt((edge_pixel[1] - seen_pixel[1]) ** 2 + (edge_pixel[2] - seen_pixel[2]) ** 2)
	if(distance < 1)
		stop_glide()
		return
	shift_to(edge_pixel[1], edge_pixel[2], distance / speed)

/// Stops the parent where it is seen right now
/datum/component/pixel_shifted/proc/stop_glide()
	if(!is_gliding())
		return
	var/list/seen_pixel = get_seen_pixel()
	shift_to(seen_pixel[1], seen_pixel[2], world.tick_lag)

/**
 * Sets up the masks hiding whatever of the parent is drawn over walls south of its tile, for a move, and puts them where the parent is seen
 *
 * Each mask covers one wall tile, so it has to move the other way when the parent moves.
 * A mask stays through a glide even when the parent leaves its wall, as it then hides nothing.
 *
 * Arguments:
 * * new_x - pixel_x the parent moves to
 * * new_y - pixel_y the parent moves to
 * * from_x - pixel_x the parent glides from, the same as new_x for an instant move
 * * from_y - pixel_y the parent glides from, the same as new_y for an instant move
 *
 * Returns whether the parent has any mask.
 */
/datum/component/pixel_shifted/proc/update_wall_cut(new_x, new_y, from_x, from_y)
	var/atom/movable/shifted = parent
	var/turf/shifted_turf = get_turf(shifted)
	var/has_masks = FALSE
	for(var/x_offset in -1 to 1)
		var/filter_name = wall_cut_filters[x_offset + 2]
		var/turf/south_turf = shifted_turf && locate(shifted_turf.x + x_offset, shifted_turf.y - 1, shifted_turf.z)
		if(!istype(south_turf, /turf/closed) || !(reaches_wall(new_x, new_y, x_offset) || reaches_wall(from_x, from_y, x_offset)))
			LAZYREMOVE(shifted.filter_data, filter_name)
			continue
		has_masks = TRUE
		if(!LAZYACCESS(shifted.filter_data, filter_name))
			var/list/mask = alpha_mask_filter(x = 0, y = 0, icon = wall_cut_mask, flags = MASK_INVERSE)
			mask["priority"] = 1
			LAZYSET(shifted.filter_data, filter_name, mask)
	follow_masks()
	return has_masks

/// Puts the wall masks where the parent is seen right now, and stops following the parent once it ends its glide
/datum/component/pixel_shifted/proc/follow_masks()
	var/atom/movable/shifted = parent
	if(!is_gliding() && mask_timer)
		deltimer(mask_timer)
		mask_timer = null
	var/list/seen_pixel = get_seen_pixel(whole = FALSE)
	for(var/x_offset in -1 to 1)
		var/list/mask = LAZYACCESS(shifted.filter_data, wall_cut_filters[x_offset + 2])
		if(!mask)
			continue
		// The mask covers the wall tile, in pixels from the bottom left of the parent's icon
		mask["x"] = x_offset * world.icon_size - seen_pixel[1]
		mask["y"] = -world.icon_size - seen_pixel[2]
	shifted.update_filters()

/// Whether an icon at the pixel offsets reaches over the tile south of its own one, x_offset tiles east of it
/datum/component/pixel_shifted/proc/reaches_wall(pixel_x, pixel_y, x_offset)
	return pixel_y < 0 && pixel_x + world.icon_size > x_offset * world.icon_size && pixel_x < (x_offset + 1) * world.icon_size

/**
 * Returns the pixel offsets pixel shifting moves this to when asked for new_x, new_y, as list(pixel_x, pixel_y)
 *
 * They are as close as PIXEL_SHIFT_RADIUS allows from the base offsets.
 */
/atom/movable/proc/clamp_pixel_shift(new_x, new_y)
	var/offset_x = new_x - base_pixel_x
	var/offset_y = new_y - base_pixel_y
	var/distance = sqrt(offset_x ** 2 + offset_y ** 2)
	if(distance > PIXEL_SHIFT_RADIUS)
		offset_x *= PIXEL_SHIFT_RADIUS / distance
		offset_y *= PIXEL_SHIFT_RADIUS / distance
	return list(base_pixel_x + round(offset_x, 1), base_pixel_y + round(offset_y, 1))
