/mob/living/carbon/human/parse_say_modes(message)
	CAN_BE_REDEFINED(TRUE)
	message = convert_cyrillic_say_prefix(message, CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys)
	message = convert_cyrillic_multibroadcast(message)
	. = ..(message)
	// parse_say() then cuts the language prefix off by bytes
	.["message_and_language"] = convert_cyrillic_say_prefix(.["message_and_language"], CYRILLIC_LANGUAGE_PREFIX_SYMBOLS, GLOB.language_keys)
