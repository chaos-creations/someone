/// Every origin players can pick exists and can have its default accent, every accent has a name, and the chat glyph is colored by the accent
/datum/unit_test/origins

/datum/unit_test/origins/Run()
	TEST_ASSERT(length(GLOB.chaos_player_origins), "No origins players can pick")
	for(var/origin_name in GLOB.chaos_player_origins)
		var/datum/origin/origin = GLOB.origins[origin_name]
		TEST_ASSERT(origin, "Player origin [origin_name] has no /datum/origin")
		TEST_ASSERT(origin.can_have_accent(origin.default_accent), "Origin [origin_name] can't have its default accent [origin.default_accent]")

	for(var/datum/accent/accent_type as anything in subtypesof(/datum/accent))
		TEST_ASSERT(accent_type::name, "[accent_type] has no name")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.origin = ORIGIN_CHAOS_TEMPLATE
	human.accent = ACCENT_TEMPLATE
	human.accent_glyph = "<"
	var/datum/accent/template_accent = GLOB.accents[ACCENT_TEMPLATE]
	TEST_ASSERT_EQUAL(human.get_accent_glyph(), "<b style='color:[template_accent.glyph_color]'>&lt;</b> ", "Chat glyph of a human")
	human.accent_glyph = ""
	human.get_accent_glyph()
	TEST_ASSERT(human.accent_glyph in GLOB.accent_glyphs, "A human without a glyph didn't get a random one")
