/mob/living/carbon/xenomorph/say(message)
	CAN_BE_REDEFINED(TRUE)
	// Any key after a hivemind symbol means hivemind, so it is rewritten whatever it is; a language key only if it is one
	message = convert_cyrillic_say_prefix(message, list(":", ".", "#", ",", "№"), null)
	message = convert_cyrillic_say_prefix(message, CYRILLIC_LANGUAGE_PREFIX_SYMBOLS, GLOB.language_keys)
	return ..(message)
