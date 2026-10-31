/mob/living/carbon/human/whisper(message as text)
	CAN_BE_REDEFINED(TRUE)
	return ..(convert_cyrillic_say_prefix(message, CYRILLIC_LANGUAGE_PREFIX_SYMBOLS, GLOB.language_keys))
