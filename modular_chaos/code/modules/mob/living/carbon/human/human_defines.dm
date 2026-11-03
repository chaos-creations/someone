/mob/living/carbon/human
	/// Name of the accent in GLOB.accents that colors the chat glyph, or null for the default accent of the origin
	var/accent
	/// Glyph before the name in chat (one of GLOB.accent_glyphs), or "" until get_accent_glyph() picks a random one
	var/accent_glyph = ""
