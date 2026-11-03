/**
 * Accent of a human, picked in the character setup separately from the origin
 *
 * Colors the glyph shown before the speaker's name in chat, see [/mob/living/carbon/human/proc/get_accent_glyph].
 * An origin can limit the accents its characters pick with [/datum/origin/var/allowed_accents].
 */
/datum/accent
	/// Shown in the character setup, and the key of GLOB.accents
	var/name
	/// Shown in the character setup
	var/desc
	/// HTML color of the chat glyph
	var/glyph_color = "#8c8c8c"

/datum/accent/template
	name = ACCENT_TEMPLATE
	desc = "A placeholder accent. Nobody can quite place where it comes from."
