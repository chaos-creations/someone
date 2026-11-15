//Large crates of Baystation 12 (code/game/objects/structures/crates_lockers/largecrate.dm in the source)

/**
 * A Bay large crate
 *
 * A CM large crate (pried open with a crowbar into what it holds and wood, as there) with the sprite of the source,
 * which packs up what is mapped on its tile as the source's does.
 */
/obj/structure/largecrate/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/shipping_crates.dmi'

/obj/structure/largecrate/bay/Initialize(mapload, ...)
	. = ..()
	for(var/obj/thing in loc)
		if(thing == src || thing.density || thing.anchored)
			continue
		thing.forceMove(src)
