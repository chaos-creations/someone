/**
 * Returns TRUE if this mob is controlled by an AI rather than a client.
 *
 * /mob/proc/do_click() calls it (as a marked edit) to let human AI click without a client.
 */
/mob/proc/is_ai_controlled()
	return mob_flags & AI_CONTROLLED
