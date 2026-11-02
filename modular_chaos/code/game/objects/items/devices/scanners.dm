/obj/item/device/healthanalyzer
	flags_human_ai = TOOL_ITEM

// Human AI medics only look the patient over, attack() opens a scan window for the client of the user
/obj/item/device/healthanalyzer/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	user.visible_message(SPAN_NOTICE("[user] analyzes the vitals of [target] with [src]."), SPAN_NOTICE("You analyze the vitals of [target]."))
	playsound(loc, 'sound/items/healthanalyzer.ogg', 50)
	add_fingerprint(user)
