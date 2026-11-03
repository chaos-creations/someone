/mob/living/carbon/human/set_species(new_species, default_color, default_species = "Human")
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(.)
		SEND_SIGNAL(src, COMSIG_HUMAN_SET_SPECIES, new_species)

/mob/living/carbon/human/verb/important_action(message as text)
	set category = "IC"
	set name = "Important Action"

	do_important_action(message)

/// Asks for an important action in a tgui input and does it, for the HUD button
/mob/living/carbon/human/proc/ask_important_action()
	var/message = tgui_input_text(src, "Describe the action like an emote, without your name.", "Important Action", encode = FALSE)
	if(!message)
		return
	do_important_action(message)

/**
 * Emotes an action that game masters should look at, underlined, and sends it to the staff like a prayer
 *
 * Shares the prayer mute and spam prevention.
 *
 * Arguments:
 * * message - the action as typed, in the third person without the name ("tries to pick the lock")
 *
 * Returns TRUE if the action was emoted and sent.
 */
/mob/living/carbon/human/proc/do_important_action(message)
	message = strip_html(message)
	if(!message)
		return FALSE
	if(stat != CONSCIOUS)
		to_chat(src, SPAN_WARNING("You can't do that right now."))
		return FALSE
	if(client)
		if(client.prefs.muted & MUTE_PRAY)
			to_chat(src, SPAN_DANGER("You cannot use important action (muted)."))
			return FALSE
		if(client.handle_spam_prevention(message, MUTE_PRAY))
			return FALSE

	manual_emote("<u>[message]</u>")

	var/admin_message = SPAN_BIGNOTICE("[SPAN_PURPLE("IMPORTANT ACTION: ")][key_name(src, 1)] [ADMIN_PP(src)] [ADMIN_SM(src)] [ADMIN_JMP_USER(src)]: [message]")
	log_admin(admin_message)
	for(var/client/admin in GLOB.admins)
		if(AHOLD_IS_MOD(admin.admin_holder))
			to_chat(admin, SPAN_STAFF_IC(admin_message))
			if(admin.prefs.toggles_sound & SOUND_ARES_MESSAGE)
				admin << 'sound/machines/terminal_alert.ogg'
	return TRUE

/// Turns pixel shift mode on or off, see [/datum/component/pixel_shifting]
/mob/living/carbon/human/verb/toggle_pixel_shift()
	set category = "IC"
	set name = "Pixel Shift"

	var/datum/component/pixel_shifting/pixel_shift_mode = GetComponent(/datum/component/pixel_shifting)
	if(pixel_shift_mode)
		qdel(pixel_shift_mode)
		return
	if(stat != CONSCIOUS)
		to_chat(src, SPAN_WARNING("You can't do that right now."))
		return
	AddComponent(/datum/component/pixel_shifting)

/**
 * Returns the glyph shown before this human's name in chat, as HTML colored by their accent and followed by a space
 *
 * Human AI that no player controls shows HUMAN_AI_ACCENT_GLYPH. A human without a glyph gets a random one here and keeps it.
 * Returns "" if the human has no accent, picked or from the origin.
 */
/mob/living/carbon/human/proc/get_accent_glyph()
	var/datum/accent/speaker_accent = accent ? GLOB.accents[accent] : null
	if(!speaker_accent)
		var/datum/origin/speaker_origin = origin ? GLOB.origins[origin] : null
		if(speaker_origin?.default_accent)
			speaker_accent = GLOB.accents[speaker_origin.default_accent]
	if(!speaker_accent)
		return ""

	var/glyph = accent_glyph
	if(!client && is_ai_controlled())
		glyph = HUMAN_AI_ACCENT_GLYPH
	else if(!glyph)
		accent_glyph = pick(GLOB.accent_glyphs)
		glyph = accent_glyph
	return "<b style='color:[speaker_accent.glyph_color]'>[html_encode(glyph)]</b> "
