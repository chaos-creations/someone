/datum/keybinding/human/pixel_shift
	hotkey_keys = list("J")
	classic_keys = list("Unbound")
	name = "pixel_shift"
	full_name = "Pixel shift"
	description = "Turns pixel shifting on or off: the movement keys shift you instead of walking, the left mouse button drags items next to you."
	keybind_signal = COMSIG_KB_HUMAN_PIXEL_SHIFT_DOWN

/datum/keybinding/human/pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	human_mob.toggle_pixel_shift()
	return TRUE
