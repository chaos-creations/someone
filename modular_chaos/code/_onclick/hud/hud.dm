/datum/hud
	/// Button of the pop-up inventory that asks for an important action, see [/mob/living/carbon/human/proc/do_important_action]
	var/atom/movable/screen/important_action/important_action_icon

/datum/hud/Destroy()
	CAN_BE_REDEFINED(TRUE)
	important_action_icon = null
	return ..()

/// Adds the important action button to the pop-up inventory, in the look of ui_datum
/datum/hud/proc/draw_important_action(datum/custom_hud/ui_datum, ui_alpha, ui_color)
	important_action_icon = new /atom/movable/screen/important_action()
	important_action_icon.icon_state = ui_datum.ui_important_action_state
	important_action_icon.screen_loc = ui_datum.ui_important_action
	if(ui_alpha)
		important_action_icon.alpha = ui_alpha
	if(ui_color)
		important_action_icon.color = ui_color
	toggleable_inventory += important_action_icon
