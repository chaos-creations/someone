// Say prefixes typed with the Russian keyboard layout (":р", "№ф", "!я") work as the same keys on the English one
// (":h", "#a", "!z"). The prefix is rewritten before upstream parses the message, because upstream cuts it off by
// bytes and would cut a Cyrillic letter in half.

/// Returns the English layout character on the same key as a Russian layout letter (either case), or null
/proc/cyrillic_layout_to_latin(char)
	var/static/list/latin_by_cyrillic = list(
		"й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "]",
		"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
		"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = ".", "ё" = "`",
	)
	return latin_by_cyrillic[lowertext(char)]

/**
 * Rewrites a two-character say prefix at the start of message from the Russian keyboard layout to the English one
 *
 * Arguments:
 * * message - The message as typed
 * * symbols - Characters that start the prefix
 * * keys - Known prefixes (GLOB.department_radio_keys, GLOB.language_keys): the message only changes if the rewritten prefix is one of them. With null, any letter is rewritten.
 */
/proc/convert_cyrillic_say_prefix(message, list/symbols, list/keys)
	if(length(message) < 2)
		return message
	var/symbol = message[1]
	if(!(symbol in symbols) || length(symbol) >= length(message))
		return message
	var/key = message[1 + length(symbol)]
	var/latin_symbol = symbol == "№" ? "#" : symbol
	var/latin_key = cyrillic_layout_to_latin(key)
	if(!latin_key)
		if(latin_symbol == symbol)
			return message
		latin_key = lowertext(key)
	var/prefix = "[latin_symbol][latin_key]"
	if(keys && !(prefix in keys))
		return message
	return prefix + copytext(message, 1 + length(symbol) + length(key))

/// Rewrites the channel keys of a multi-broadcast (",рум" to ",hej") from the Russian keyboard layout to the English one, keeping the keys that are not known channels
/proc/convert_cyrillic_multibroadcast(message)
	if(length(message) < 2 || message[1] != ",")
		return message
	var/converted = ","
	var/index = 2
	var/channels = 0
	while(index <= length(message) && channels < MULTIBROADCAST_MAX_CHANNELS)
		var/char = message[index]
		if(char == " " || char == ":" || char == ".")
			break
		var/latin_key = cyrillic_layout_to_latin(char)
		converted += (latin_key && GLOB.department_radio_keys[":[latin_key]"]) ? latin_key : char
		index += length(char)
		channels++
	return converted + copytext(message, index)
