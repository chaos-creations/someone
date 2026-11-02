/datum/hud/human/New(mob/living/carbon/human/owner, datum/custom_hud/hud_type, ui_color = "#ffffff", ui_alpha = 255)
	CAN_BE_REDEFINED(TRUE)
	..()
	// Zombies have no inventory to pop up
	if(!iszombie(owner))
		draw_important_action(ui_datum, ui_alpha, ui_color)
