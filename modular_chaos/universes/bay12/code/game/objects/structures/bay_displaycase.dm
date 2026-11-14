//Display cases of Baystation 12 (code/game/objects/structures/displaycase.dm in the source)

/**
 * A Bay display case
 *
 * A CM display case that works as the source's: it holds what is mapped on its tile and shows it through its glass,
 * and drops it once the glass breaks. Kicks, hits, bullets and blasts damage it as a CM one.
 */
/obj/structure/displaycase/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/furniture/display_case.dmi'
	icon_state = "glassbox"
	alpha = 150
	health = 14
	occupied = FALSE

/obj/structure/displaycase/bay/Initialize(mapload, ...)
	. = ..()
	for(var/atom/movable/thing in loc)
		if(thing != src && !thing.anchored && (isobj(thing) || ismob(thing)))
			thing.forceMove(src)
	update_icon()

/obj/structure/displaycase/bay/get_examine_text(mob/user)
	. = ..()
	if(length(contents))
		. += "Inside you see [english_list(contents)]."

/obj/structure/displaycase/bay/update_icon()
	icon_state = destroyed ? "glassboxb" : "glassbox"
	underlays.Cut()
	for(var/atom/movable/thing as anything in contents)
		underlays += thing.appearance

/obj/structure/displaycase/bay/healthcheck()
	if(health > 0)
		playsound(src, 'modular_chaos/universes/bay12/sound/effects/Glasshit.ogg', 25, TRUE)
		return
	if(destroyed)
		return
	destroyed = TRUE
	density = FALSE
	new /obj/item/shard(loc)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(loc)
	playsound(src, "windowshatter", 35, TRUE)
	update_icon()

// Kicked as there, without the hover field of a CM one
/obj/structure/displaycase/bay/attack_hand(mob/user)
	add_fingerprint(user)
	if(destroyed)
		return
	user.visible_message(SPAN_WARNING("[user] kicks [src]."), SPAN_WARNING("You kick [src]."))
	health -= 2
	healthcheck()

/obj/structure/displaycase/bay/deconstruct(disassembled = TRUE)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(loc)
	return ..()
