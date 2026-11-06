/datum/emote/living/carbon/human/New()
	CAN_BE_REDEFINED(TRUE)
	// The Vox use every emote humans use; species_type_allowed_typecache is turned into a typecache by upstream's New()
	if(/datum/species/human in species_type_allowed_typecache)
		species_type_allowed_typecache += /datum/species/vox
	return ..()

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	CAN_BE_REDEFINED(TRUE)
	if(isvox(user))
		return 'modular_chaos/universes/bay12/sound/voice/shriek1.ogg'
	return ..()

/// The shriek of a Vox
/datum/emote/living/carbon/human/vox_shriek
	key = "shriek"
	key_third_person = "shrieks"
	message = "SHRIEKS!"
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE
	sound = 'modular_chaos/universes/bay12/sound/voice/shriek1.ogg'
	audio_cooldown = 10 SECONDS
	species_type_allowed_typecache = list(/datum/species/vox)
	species_type_blacklist_typecache = list()
