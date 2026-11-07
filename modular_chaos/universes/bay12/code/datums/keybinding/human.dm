/datum/keybinding/human/rig_select_module
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "rig_select_module"
	full_name = "Hardsuit: select module"
	description = "Shows the modules of your hardsuit in a radial menu, to pick the one the use key uses."
	keybind_signal = COMSIG_KB_HUMAN_RIG_SELECT_MODULE_DOWN

/datum/keybinding/human/rig_select_module/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	INVOKE_ASYNC(human_mob, TYPE_PROC_REF(/mob/living/carbon/human, rig_select_module))
	return TRUE

/datum/keybinding/human/rig_use_module
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "rig_use_module"
	full_name = "Hardsuit: use module"
	description = "Uses the selected module of your hardsuit: turns it on or off, or readies it for a click on a target."
	keybind_signal = COMSIG_KB_HUMAN_RIG_USE_MODULE_DOWN

/datum/keybinding/human/rig_use_module/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	INVOKE_ASYNC(human_mob, TYPE_PROC_REF(/mob/living/carbon/human, rig_use_module))
	return TRUE
