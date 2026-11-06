/datum/equipment_preset/load_preset(mob/living/carbon/human/new_human, randomise = FALSE, count_participant = FALSE, client/mob_client, show_job_gear = TRUE)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	// The preset sets the languages of the job and dresses the human, then the species adds what it can't do without
	for(var/language in new_human.species.innate_languages)
		new_human.add_language(language)
	new_human.species.equip_survival_gear(new_human)
