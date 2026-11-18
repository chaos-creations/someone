/**
 * Returns a screen_loc for a point given in pixels from the bottom left corner of the middle tile of the screen
 *
 * While a cutscene's camera points at a mob, that mob stands on the middle tile, so this places things around it.
 */
/proc/cutscene_screen_loc(offset_x, offset_y)
	var/tiles_x = round(offset_x / world.icon_size)
	var/tiles_y = round(offset_y / world.icon_size)
	return "CENTER[tiles_x >= 0 ? "+" : ""][tiles_x]:[offset_x - tiles_x * world.icon_size],CENTER[tiles_y >= 0 ? "+" : ""][tiles_y]:[offset_y - tiles_y * world.icon_size]"

/// Screen objects a [/datum/cutscene] shows its participants. Shared by all of them, since they sit at the same place on every screen
/atom/movable/screen/cutscene
	// Unlike the screen objects this comes from, so the texts draw no icon under them
	icon = null
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/**
 * Black bars sliding in at the top and bottom of the screen while a cutscene plays, two tiles high each
 *
 * The animated chapter title card of cmss13-pve-halo: "title_card" slides the bars in, "title_card_r" out.
 */
/atom/movable/screen/cutscene/letterbox
	icon = 'modular_chaos/icons/mob/hud/cutscene_letterbox.dmi'
	icon_state = "title_card"
	screen_loc = "CENTER-7,CENTER-7"
	// Over the whole HUD, whose inventory items and action buttons are drawn on ABOVE_HUD_PLANE too
	plane = CINEMATIC_PLANE

/atom/movable/screen/cutscene/letterbox/proc/slide_in()
	icon_state = "title_card"

/atom/movable/screen/cutscene/letterbox/proc/slide_out()
	icon_state = "title_card_r"

/// Subtitles in the bottom bar for narration and voices that aren't on the map, as wide as the narrowest view
/atom/movable/screen/cutscene/subtitle
	screen_loc = "CENTER-7,SOUTH:2"
	// Over the bars
	plane = CINEMATIC_PLANE
	layer = ABOVE_HUD_LAYER + 0.1
	maptext_width = 480
	maptext_height = 40

/// Shows the text in the subtitles. null clears them
/atom/movable/screen/cutscene/subtitle/proc/set_text(text)
	maptext = text ? MAPTEXT("<center>[text]</center>") : null

/// Returns a transparent icon of the size, cached, so a maptext-only screen object can be clicked anywhere in its area
/proc/get_cutscene_hitbox_icon(width, height)
	var/static/list/hitbox_icons = list()
	var/key = "[width]x[height]"
	if(!hitbox_icons[key])
		var/icon/hitbox = icon('icons/effects/alphacolors.dmi', "transparent")
		hitbox.Scale(width, height)
		hitbox_icons[key] = hitbox
	return hitbox_icons[key]

/**
 * Answer floating around the leader like a thought. Only the leader can click it, and it lights up under their mouse
 *
 * Plain text with an outline over a transparent icon of the text's size, which makes the whole text clickable.
 */
/atom/movable/screen/cutscene/thought
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	/// The cutscene asking
	var/datum/cutscene/cutscene
	/// ID of the answer
	var/option_id

/**
 * Sizes the thought to its text. It still has to be placed with [/atom/movable/screen/cutscene/thought/proc/place]
 *
 * * cutscene - The cutscene asking
 * * option_id - ID of the answer
 * * text - Text of the answer
 */
/atom/movable/screen/cutscene/thought/Initialize(mapload, datum/cutscene/cutscene, option_id, text)
	. = ..()
	src.cutscene = cutscene
	src.option_id = option_id
	var/text_width = length_char(text) * CUTSCENE_CHAR_WIDTH
	maptext_width = clamp(text_width + 8, 48, CUTSCENE_THOUGHT_MAX_WIDTH)
	var/line_count = max(1, CEILING(text_width / (maptext_width - 8), 1))
	maptext_height = line_count * CUTSCENE_LINE_HEIGHT + 4
	icon = get_cutscene_hitbox_icon(maptext_width, maptext_height)
	maptext = MAPTEXT("<center><span style='-dm-text-outline: 1px #000000'>[text]</span></center>")

/atom/movable/screen/cutscene/thought/Destroy()
	cutscene = null
	return ..()

/**
 * Puts the thought with its center at the point and makes it fade in and float
 *
 * * center_x - Where its center goes, see [/proc/cutscene_screen_loc]
 * * center_y - Where its center goes, see [/proc/cutscene_screen_loc]
 */
/atom/movable/screen/cutscene/thought/proc/place(center_x, center_y)
	screen_loc = cutscene_screen_loc(center_x - round(maptext_width * 0.5), center_y - round(maptext_height * 0.5))
	alpha = 0
	animate(src, alpha = 255, time = 0.5 SECONDS)
	// Each thought floats at its own pace, so they don't move in step
	var/float_time = rand(12, 20) * 0.1 SECONDS
	animate(src, pixel_y = 3, time = float_time, easing = SINE_EASING, loop = -1, flags = ANIMATION_PARALLEL)
	animate(pixel_y = -3, time = float_time, easing = SINE_EASING)

/atom/movable/screen/cutscene/thought/clicked(mob/user, list/mods)
	cutscene?.pick_option(user, option_id)
	return TRUE

/atom/movable/screen/cutscene/thought/MouseEntered(location, control, params)
	. = ..()
	if(usr == cutscene?.leader)
		add_filter("cutscene_hover", 1, outline_filter(1, CUTSCENE_COLOR_HOVER))

/atom/movable/screen/cutscene/thought/MouseExited(location, control, params)
	. = ..()
	remove_filter("cutscene_hover")

/**
 * Bubble over an NPC (or a trigger) that a player clicks to start the cutscene of its [/obj/effect/landmark/cutscene_trigger]
 *
 * The trigger shows it once enough players are near and removes it when they leave.
 */
/obj/effect/cutscene_start_prompt
	name = "start conversation"
	icon = 'icons/mob/effects/talk.dmi'
	icon_state = "default0"
	layer = ABOVE_FLY_LAYER
	anchored = TRUE
	// Only the bubble itself, so clicks on the head of the NPC under it reach the NPC
	mouse_opacity = MOUSE_OPACITY_ICON
	pixel_y = 10
	maptext_width = 128
	maptext_height = 16
	maptext_x = -48
	maptext_y = 22
	/// Trigger whose cutscene the click starts
	var/obj/effect/landmark/cutscene_trigger/trigger

/obj/effect/cutscene_start_prompt/Initialize(mapload, obj/effect/landmark/cutscene_trigger/trigger)
	. = ..()
	src.trigger = trigger
	maptext = MAPTEXT("<center>Click to talk</center>")
	animate(src, pixel_y = 13, time = 1 SECONDS, easing = SINE_EASING, loop = -1)
	animate(pixel_y = 10, time = 1 SECONDS, easing = SINE_EASING)

/obj/effect/cutscene_start_prompt/Destroy()
	trigger = null
	return ..()

/obj/effect/cutscene_start_prompt/clicked(mob/user, list/mods)
	// A shift click examines the NPC under the bubble and so on, only a plain click talks
	if(mods[SHIFT_CLICK] || mods[CTRL_CLICK] || mods[ALT_CLICK] || mods[MIDDLE_CLICK])
		var/atom/anchor = trigger?.prompt_anchor
		if(anchor && anchor != trigger)
			return anchor.clicked(user, mods)
		return ..()
	trigger?.on_prompt_clicked(user)
	return TRUE

/obj/effect/cutscene_start_prompt/ex_act(severity)
	return
