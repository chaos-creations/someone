//Mop buckets of Baystation 12 (code/game/objects/structures/mop_bucket.dm in the source)

/**
 * A Bay mop bucket
 *
 * A bucket on wheels, which CM has none like: it is filled from containers poured into it and wets the mops dipped in
 * it.
 */
/obj/structure/bay_mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/mop_bucket.dmi'
	icon_state = "mopbucket"
	density = TRUE
	anchored = FALSE
	drag_delay = 1
	flags_atom = OPENCONTAINER
	/// What syringes and the like take from it at a time
	var/amount_per_transfer_from_this = 5

/obj/structure/bay_mopbucket/Initialize(mapload, ...)
	. = ..()
	create_reagents(180)

/obj/structure/bay_mopbucket/get_examine_text(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		. += "[src] contains [reagents.total_volume] unit\s of water!"

/obj/structure/bay_mopbucket/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/reagent_container))
		return
	if(!istype(attacking_item, /obj/item/tool/mop))
		return ..()
	var/obj/item/tool/mop/mop = attacking_item
	if(reagents.total_volume < 1)
		to_chat(user, SPAN_WARNING("[src] is out of water."))
		return
	reagents.trans_to(mop, 5)
	mop.update_icon()
	playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] wets \a [mop] in [src]."), SPAN_NOTICE("You wet [mop] in [src]."))
