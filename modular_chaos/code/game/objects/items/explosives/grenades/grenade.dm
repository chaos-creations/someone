/obj/item/explosive/grenade
	flags_human_ai = GRENADE_ITEM

/obj/item/explosive/grenade/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	return TRUE

/obj/item/explosive/grenade/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, turf/target_turf)
	if(!ai_brain.ai_sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult))
		return
	attack_self(user)
	user.toggle_throw_mode(THROW_MODE_NORMAL)
	ai_brain.ensure_primary_hand(src)
	if(!ai_brain.ai_sleep(det_time * 0.4) || QDELETED(src) || (loc != user))
		return

	ai_brain.say_grenade_thrown_line()
	if(!ai_brain.ai_sleep(det_time * 0.4) || QDELETED(src) || (loc != user))
		return

	user.face_atom(target_turf)
	user.throw_item(target_turf)
