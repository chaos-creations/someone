/// Time it takes to type out one character of a message over a speaker
#define LANGCHAT_TYPING_CHARACTER_TIME (0.5)
/// Extra pause after a character that ends a phrase
#define LANGCHAT_TYPING_PAUSE (2)
/// With this many players or more seeing a message, it shows up at once, like a crowd's speech should
#define LANGCHAT_TYPING_CROWD_SIZE 5

/// Number of the last message shown over the atom. Typing out an older message stops once a newer one comes
/atom/var/langchat_typing_id = 0
/**
 * Whether the message over the atom is typed out, and so is hidden only by its own timer
 *
 * Upstream's timers that hide messages are keyed on their language, so the timer of an older message
 * in another language (an emote just before) is not replaced and would hide the new message while it is typed out.
 */
/atom/var/langchat_typed_message = FALSE
/// Copies of the langchat images with the whole message, shown instead of them to players with [LANGCHAT_INSTANT_TEXT], as list(original image = copy)
/atom/var/list/image/langchat_instant_images
/// Players shown the copies in langchat_instant_images
/atom/var/list/mob/langchat_instant_viewers

/**
 * Types speech over the speaker out character by character, with a little shake on each one
 *
 * Upstream builds and shows the whole message, then this types it out again from the start.
 * Emotes, long messages split into parts (megaphones) and messages seen by a crowd show up at once, as before,
 * and so does everything for players with [LANGCHAT_INSTANT_TEXT].
 */
/atom/langchat_speech(message, list/listeners, datum/language/language, override_color, skip_language_check = FALSE, animation_style = LANGCHAT_DEFAULT_POP, list/additional_styles = list("langchat"), scramble_message = TRUE, split_long_messages = FALSE)
	CAN_BE_REDEFINED(TRUE)
	// Upstream removes "emote" from the styles, and only sets the scrambled text when there is one
	var/is_emote = additional_styles && additional_styles.Find("emote")
	var/old_scrambled_text = langchat_scrambled_image?.maptext
	// Lets upstream hide the old message before showing this one
	langchat_typed_message = FALSE
	. = ..()
	langchat_typing_id++
	if(is_emote || split_long_messages || !langchat_image?.maptext)
		return

	var/viewer_count = 0
	for(var/mob/player in langchat_listeners)
		if(langchat_client_enabled(player))
			viewer_count++
	if(viewer_count >= LANGCHAT_TYPING_CROWD_SIZE)
		return

	var/type_scrambled = langchat_scrambled_image && langchat_scrambled_image.maptext != old_scrambled_text
	langchat_typed_message = TRUE
	langchat_show_instant_copies(type_scrambled)
	INVOKE_ASYNC(src, PROC_REF(langchat_type_out), langchat_typing_id, type_scrambled)

/atom/langchat_drop_image()
	CAN_BE_REDEFINED(TRUE)
	// Only the message's own timer, [/atom/proc/langchat_drop_typed_message], hides a typed out message
	if(langchat_typed_message)
		return
	langchat_hide_instant_copies()
	return ..()

/// Hides the typed out message over the atom, unless a newer message has come since
/atom/proc/langchat_drop_typed_message(typing_id)
	if(langchat_typing_id != typing_id)
		return
	langchat_typed_message = FALSE
	langchat_drop_image()

/**
 * Shows players with [LANGCHAT_INSTANT_TEXT] copies of the langchat images with the whole message, in place of the ones being typed out
 *
 * * with_scrambled - Whether the scrambled image belongs to this message and is typed out too
 */
/atom/proc/langchat_show_instant_copies(with_scrambled)
	var/list/image/typed_images = list(langchat_image)
	if(with_scrambled)
		typed_images += langchat_scrambled_image
	for(var/mob/player in langchat_listeners)
		if(!(player.client?.prefs?.toggles_langchat & LANGCHAT_INSTANT_TEXT))
			continue
		for(var/image/typed_image as anything in typed_images)
			if(!(typed_image in player.client.images))
				continue
			LAZYINITLIST(langchat_instant_images)
			var/image/instant_image = langchat_instant_images[typed_image]
			if(!instant_image)
				instant_image = image(loc = typed_image.loc)
				// The final look of the image, since animate() sets the variables to where the animation ends
				instant_image.appearance = typed_image.appearance
				instant_image.loc = typed_image.loc
				langchat_instant_images[typed_image] = instant_image
			player.client.images -= typed_image
			player.client.images += instant_image
			LAZYOR(langchat_instant_viewers, player)

/// Gives the players with [LANGCHAT_INSTANT_TEXT] the langchat images back in place of the copies, once those show the whole message too
/atom/proc/langchat_hide_instant_copies()
	for(var/mob/player as anything in langchat_instant_viewers)
		if(!player.client)
			continue
		for(var/image/typed_image as anything in langchat_instant_images)
			var/image/instant_image = langchat_instant_images[typed_image]
			if(instant_image in player.client.images)
				player.client.images -= instant_image
				player.client.images += typed_image
	langchat_instant_viewers = null
	langchat_instant_images = null

/**
 * Splits the text into what is typed out one at a time: characters, but HTML entities and tags whole
 *
 * Returns a list of texts.
 */
/proc/langchat_typing_tokens(text)
	var/list/tokens = list()
	var/text_length = length_char(text)
	var/position = 1
	while(position <= text_length)
		var/character = copytext_char(text, position, position + 1)
		var/token_end = position
		if(character == "&")
			var/entity_end = findtext_char(text, ";", position, min(text_length, position + 10) + 1)
			if(entity_end)
				token_end = entity_end
		else if(character == "<")
			var/tag_end = findtext_char(text, ">", position)
			if(tag_end)
				token_end = tag_end
		tokens += copytext_char(text, position, token_end + 1)
		position = token_end + 1
	return tokens

/**
 * Types the message shown over the atom out again from the start, then restarts the timer that hides it
 *
 * Sleeps at most once a server tick, typing out as many characters per tick as fit in it.
 *
 * * typing_id - Number of the message, see [/atom/var/langchat_typing_id]
 * * type_scrambled - Whether the scrambled text for listeners who don't know the language belongs to this message
 */
/atom/proc/langchat_type_out(typing_id, type_scrambled)
	// Characters followed by LANGCHAT_TYPING_PAUSE
	var/static/list/pause_characters = list("." = TRUE, "," = TRUE, "!" = TRUE, "?" = TRUE, ";" = TRUE, ":" = TRUE)
	var/list/text_parts = langchat_split_maptext(langchat_image.maptext)
	var/list/tokens = langchat_typing_tokens(text_parts[2])
	var/list/scrambled_parts
	var/list/scrambled_tokens
	if(type_scrambled)
		scrambled_parts = langchat_split_maptext(langchat_scrambled_image.maptext)
		scrambled_tokens = langchat_typing_tokens(scrambled_parts[2])

	var/token_count = length(tokens)
	var/typed_text = ""
	var/scrambled_typed_count = 0
	var/scrambled_typed_text = ""
	// Time the typing may still spend before the next sleep
	var/time_budget = 0
	for(var/index in 1 to token_count)
		var/token = tokens[index]
		var/token_time = LANGCHAT_TYPING_CHARACTER_TIME + (pause_characters[token] ? LANGCHAT_TYPING_PAUSE : 0)
		while(time_budget < token_time)
			// Shows what is typed so far, then waits for the next tick
			langchat_image.maptext = text_parts[1] + typed_text + text_parts[3]
			if(type_scrambled)
				langchat_scrambled_image.maptext = scrambled_parts[1] + scrambled_typed_text + scrambled_parts[3]
			animate(langchat_image, pixel_x = rand(-1, 1), time = world.tick_lag, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)
			sleep(world.tick_lag)
			if(langchat_typing_id != typing_id || QDELETED(src))
				return
			time_budget += world.tick_lag
		time_budget -= token_time
		typed_text += token
		if(type_scrambled)
			// The scrambled text can be longer or shorter, so it keeps up proportionally
			var/scrambled_target = round(length(scrambled_tokens) * index / token_count)
			while(scrambled_typed_count < scrambled_target)
				scrambled_typed_count++
				scrambled_typed_text += scrambled_tokens[scrambled_typed_count]

	langchat_image.maptext = text_parts[1] + typed_text + text_parts[3]
	if(type_scrambled)
		langchat_scrambled_image.maptext = scrambled_parts[1] + scrambled_parts[2] + scrambled_parts[3]
	animate(langchat_image, pixel_x = 0, time = world.tick_lag, flags = ANIMATION_PARALLEL)
	langchat_hide_instant_copies()
	// As long as upstream's timer, counted from now that the message can be read in full
	var/display_time = (min(token_count, LANGCHAT_LONGEST_TEXT) / LANGCHAT_LONGEST_TEXT) * 4 SECONDS + 2 SECONDS
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, langchat_drop_typed_message), typing_id), display_time)

/// Splits langchat maptext into list(the opening span tag, the text inside, the closing tag)
/proc/langchat_split_maptext(maptext)
	var/opening_end = findtext(maptext, ">")
	var/closing_start = findlasttext(maptext, "</span>")
	if(!opening_end || closing_start <= opening_end)
		return list("", maptext, "")
	return list(copytext(maptext, 1, opening_end + 1), copytext(maptext, opening_end + 1, closing_start), copytext(maptext, closing_start))

/// Returns the line of the preferences menu that toggles [LANGCHAT_INSTANT_TEXT]
/datum/preferences/proc/get_langchat_typing_entry()
	return "<b>Abovehead Chat Typing:</b> <a href='byond://?_src_=prefs;preference=langchat_instant'><b>[(toggles_langchat & LANGCHAT_INSTANT_TEXT) ? "Instant" : "Typed Out"]</b></a><br>"

/// Toggles [LANGCHAT_INSTANT_TEXT]. The caller saves the preferences
/datum/preferences/proc/toggle_langchat_typing()
	toggles_langchat ^= LANGCHAT_INSTANT_TEXT

CLIENT_VERB(toggle_langchat_instant)
	set name = "Toggle Abovehead Chat Typing"
	set category = "Preferences.Chat"
	set desc = "Toggles whether speech above heads is typed out or shows up at once."

	prefs.toggle_langchat_typing()
	prefs.save_preferences()
	to_chat(src, SPAN_BOLDNOTICE("Speech above heads will now [(prefs.toggles_langchat & LANGCHAT_INSTANT_TEXT) ? "show up at once" : "be typed out"]."))

#undef LANGCHAT_TYPING_CHARACTER_TIME
#undef LANGCHAT_TYPING_PAUSE
#undef LANGCHAT_TYPING_CROWD_SIZE
