/**
 * Climbs `user` to the `destination` ladder, like climb_ladder() does for players.
 *
 * climb_ladder() opens a direction menu at the end if the destination leads both ways, which a human AI can't answer.
 * Keep the checks in sync with climb_ladder(). Sleeps. Returns TRUE if the user got there.
 */
/obj/structure/ladder/proc/ai_climb(mob/living/carbon/human/user, obj/structure/ladder/destination)
	if(busy || user.action_busy || ((destination != up) && (destination != down)))
		return FALSE
	if(user.stat || get_dist(user, src) > 1 || user.body_position == LYING_DOWN || user.buckled || user.anchored)
		return FALSE

	var/ladder_dir_name = (destination == up) ? "up" : "down"
	user.visible_message(SPAN_NOTICE("[user] starts climbing [ladder_dir_name] [src]."))
	busy = TRUE
	. = FALSE
	if(do_after(user, 20, INTERRUPT_INCAPACITATED|INTERRUPT_OUT_OF_RANGE|INTERRUPT_RESIST, BUSY_ICON_GENERIC, src, INTERRUPT_NONE))
		if(!QDELETED(destination) && !user.is_mob_incapacitated() && get_dist(user, src) <= 1 && user.body_position != LYING_DOWN && !user.buckled && !user.anchored)
			visible_message(SPAN_NOTICE("[user] climbs [ladder_dir_name] [src]."))
			destination.add_fingerprint(user)
			user.trainteleport(destination.loc)
			. = TRUE
	busy = FALSE
	add_fingerprint(user)
