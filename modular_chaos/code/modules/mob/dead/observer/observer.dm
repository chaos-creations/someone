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

/mob/dead/observer/get_status_tab_items()
	CAN_BE_REDEFINED(TRUE)
	var/list/status_items = ..()
	if(!larva_pool_cached_message || !SSticker.mode || SSticker.mode.xeno_join_allowed)
		return status_items
	// Without xeno join the larva pool position is meaningless, so drop it with the blank line upstream adds after it
	var/message_index = status_items.Find(larva_pool_cached_message)
	if(message_index)
		status_items.Cut(message_index, message_index + 2)
	return status_items
