/// Asks a human for an important action, see [/mob/living/carbon/human/proc/do_important_action]
/atom/movable/screen/important_action
	name = "important action"
	icon = 'modular_chaos/icons/mob/hud/important_action.dmi'
	icon_state = "midnight"
	layer = HUD_LAYER

/atom/movable/screen/important_action/clicked(mob/user, list/mods)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	INVOKE_ASYNC(human_user, TYPE_PROC_REF(/mob/living/carbon/human, ask_important_action))
	return TRUE
