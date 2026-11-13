//Catwalks and lattices of Baystation 12 (code/game/objects/structures/catwalk.dm and lattice.dm in the source)

/**
 * A Bay catwalk
 *
 * Drawn by corners, joining the catwalks around it in all eight directions, as the source draws it; a plated one has
 * a floor tile on top. Opening it with a crowbar (CM's covered var, the hatch of the source) leaves only the plating
 * under it showing.
 */
/obj/structure/catwalk/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/catwalks.dmi'
	icon_state = "catwalk"
	base_state = "blank"
	/// Colour of the floor tile on top of a plated catwalk, null if it has none
	var/plated_color

/obj/structure/catwalk/bay/Initialize()
	. = ..()
	update_nearby_catwalks()

/obj/structure/catwalk/bay/Destroy()
	var/turf/old_loc = loc
	. = ..()
	for(var/obj/structure/catwalk/bay/neighbor in orange(1, old_loc))
		neighbor.update_icon()

/obj/structure/catwalk/bay/attackby(obj/item/attacking_item, mob/user)
	var/was_covered = covered
	. = ..()
	if(covered != was_covered)
		update_icon()

/obj/structure/catwalk/bay/update_icon()
	. = ..()
	overlays.Cut()
	if(!covered)
		return
	var/list/joined_dirs = list()
	for(var/direction in GLOB.alldirs)
		if(locate(/obj/structure/catwalk/bay) in get_step(src, direction))
			joined_dirs += direction
	var/list/connections = dirs_to_corner_states(joined_dirs)
	for(var/i in 1 to 4)
		overlays += image(icon, "catwalk[connections[i]]", dir = 1<<(i-1))
	if(plated_color)
		var/image/plating = image(icon, "plated")
		plating.color = plated_color
		overlays += plating

/// Redraws this catwalk and the ones around it, whose corners depend on it
/obj/structure/catwalk/bay/proc/update_nearby_catwalks()
	update_icon()
	for(var/obj/structure/catwalk/bay/neighbor in orange(1, src))
		neighbor.update_icon()

/// /obj/catwalk_plated in the source: a catwalk with a steel floor tile on top
/obj/structure/catwalk/bay/plated
	name = "plated catwalk"
	icon_state = "catwalk_plated"
	plated_color = "#4c535b"

/obj/structure/catwalk/bay/plated/dark
	icon_state = "catwalk_plateddark"
	plated_color = "#404040"

/obj/structure/catwalk/bay/plated/white
	icon_state = "catwalk_platedwhite"
	plated_color = "#eeeeee"

/**
 * A Bay lattice
 *
 * Joins the lattices and catwalks around it, and anything that is not space, by one of the sixteen states of the
 * source; the sprites are greyscale and take the colour of steel.
 */
/obj/structure/lattice/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/lattice.dmi'
	icon_state = "lattice0"
	color = COLOR_STEEL

/obj/structure/lattice/bay/updateOverlays()
	var/dir_sum = 0
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(src, direction)
		if((locate(/obj/structure/lattice) in neighbor) || (locate(/obj/structure/catwalk) in neighbor))
			dir_sum += direction
		else if(!istype(neighbor, /turf/open/space) && !istype(neighbor, /turf/open_space))
			dir_sum += direction
	overlays.Cut()
	icon_state = "lattice[dir_sum]"
