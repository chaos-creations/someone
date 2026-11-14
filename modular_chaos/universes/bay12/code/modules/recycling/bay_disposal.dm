//Disposals of Baystation 12 (code/modules/recycling/disposal.dm, disposalpipe.dm and sortingmachinery.dm in the source)

/**
 * A Bay disposal unit
 *
 * A CM unit with the sprites of the source; it charges with the pressure CM disposals keep, as atmos is not ported.
 */
/obj/structure/machinery/disposal/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay delivery chute, which takes in whatever runs into its open side
/obj/structure/machinery/disposal/deliveryChute/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay disposal outlet
/obj/structure/disposaloutlet/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay straight disposal pipe
/obj/structure/disposalpipe/segment/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay bent disposal pipe
/obj/structure/disposalpipe/segment/bay/bent
	icon_state = "pipe-c"

/// A Bay trunk, joining a pipe to the unit, chute or outlet on its tile
/obj/structure/disposalpipe/trunk/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay junction of three pipes, its dir the main one
/obj/structure/disposalpipe/junction/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay junction with its side pipe on the other side
/obj/structure/disposalpipe/junction/bay/mirrored
	icon_state = "pipe-j2"

/// A Bay junction whose two side pipes join into its main one
/obj/structure/disposalpipe/junction/bay/yjunction
	icon_state = "pipe-y"

/// A Bay sorting junction, which turns aside what is tagged for its sort type
/obj/structure/disposalpipe/sortjunction/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay sorting junction that turns aside the other way
/obj/structure/disposalpipe/sortjunction/flipped/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay sorting junction that turns aside everything untagged
/obj/structure/disposalpipe/sortjunction/untagged/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/obj/structure/disposalpipe/sortjunction/untagged/flipped/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/// A Bay sorting junction that turns aside everything tagged
/obj/structure/disposalpipe/sortjunction/wildcard/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/obj/structure/disposalpipe/sortjunction/wildcard/flipped/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/**
 * A Bay pipe up a deck
 *
 * What comes in goes into the pipe down on the turf above, as in the source; CM ones of this kind leave it where it is.
 */
/obj/structure/disposalpipe/up/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/obj/structure/disposalpipe/up/bay/transfer(obj/structure/disposalholder/holder)
	var/next_dir = nextdir(holder.dir)
	holder.setDir(next_dir)
	var/turf/next_turf
	var/obj/structure/disposalpipe/next_pipe
	if(next_dir == 12)
		next_turf = SSmapping.get_turf_above(get_turf(src))
		if(!next_turf)
			holder.forceMove(loc)
			return
		next_pipe = locate(/obj/structure/disposalpipe/down) in next_turf
	else
		next_turf = get_step(loc, holder.dir)
		next_pipe = holder.findpipe(next_turf)
	return bay_pass_on(holder, next_pipe, next_turf)

/**
 * A Bay pipe down a deck
 *
 * What comes in goes into the pipe up on the turf below, as in the source; CM ones of this kind leave it where it is.
 */
/obj/structure/disposalpipe/down/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/pipes/disposal.dmi'

/obj/structure/disposalpipe/down/bay/transfer(obj/structure/disposalholder/holder)
	var/next_dir = nextdir(holder.dir)
	holder.setDir(next_dir)
	var/turf/next_turf
	var/obj/structure/disposalpipe/next_pipe
	if(next_dir == 11)
		next_turf = SSmapping.get_turf_below(get_turf(src))
		if(!next_turf)
			holder.forceMove(loc)
			return
		next_pipe = locate(/obj/structure/disposalpipe/up) in next_turf
	else
		next_turf = get_step(loc, holder.dir)
		next_pipe = holder.findpipe(next_turf)
	return bay_pass_on(holder, next_pipe, next_turf)

/**
 * Moves a holder into the next pipe, merging it with an idle holder there, or out onto the turf if there is no pipe
 *
 * Returns the pipe, null if it went out.
 * * holder - the holder
 * * next_pipe - the pipe, null if there is none
 * * next_turf - the turf it goes out onto without one
 */
/obj/structure/disposalpipe/proc/bay_pass_on(obj/structure/disposalholder/holder, obj/structure/disposalpipe/next_pipe, turf/next_turf)
	if(!next_pipe)
		holder.forceMove(next_turf)
		return null
	var/obj/structure/disposalholder/idle_holder = locate() in next_pipe
	if(idle_holder && !idle_holder.active)
		holder.merge(idle_holder)
	holder.forceMove(next_pipe)
	return next_pipe
