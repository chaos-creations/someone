/**
 * Whether the game master closed observing to this mob's player with GLOB.admin_only_observe, telling them if so
 *
 * Staff can always observe. Goes by the mob's own client, since usr is not always this mob (nesting ghosts the host).
 */
/mob/proc/is_observing_blocked()
	if(!GLOB.admin_only_observe || CLIENT_IS_STAFF(client))
		return FALSE
	to_chat(src, FONT_SIZE_LARGE(SPAN_DEADSAY("<b>Observation has been disabled by the Game Master.</b>")))
	return TRUE

/mob/living/do_ghost()
	CAN_BE_REDEFINED(TRUE)
	if(is_observing_blocked())
		return
	return ..()
