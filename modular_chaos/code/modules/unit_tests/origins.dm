/// Every origin players can pick exists, can have its default accent and has a planet to draw in a known star system, every accent has a name, and the chat glyph is colored by the accent
/datum/unit_test/origins

/datum/unit_test/origins/Run()
	TEST_ASSERT(BAY12_DEFAULT_ORIGIN in GLOB.bay12_player_origins, "The default origin [BAY12_DEFAULT_ORIGIN] isn't one players can pick")
	for(var/origin_name in GLOB.bay12_player_origins)
		var/datum/origin/origin = GLOB.origins[origin_name]
		TEST_ASSERT(origin, "Player origin [origin_name] has no /datum/origin")
		TEST_ASSERT(origin.can_have_accent(origin.default_accent), "Origin [origin_name] can't have its default accent [origin.default_accent]")
		TEST_ASSERT(origin.planet_type in PLANET_TYPES, "Origin [origin_name] has an unknown planet type [origin.planet_type]")
		TEST_ASSERT(origin.planet_size > 0, "Origin [origin_name] has no planet size")
		TEST_ASSERT(GLOB.star_systems[origin.star_system], "Origin [origin_name] is in an unknown star system [origin.star_system]")
		if(origin.moon_of)
			var/datum/origin/planet = GLOB.origins[origin.moon_of]
			TEST_ASSERT(planet && (origin.moon_of in GLOB.bay12_player_origins), "Origin [origin_name] is a moon of [origin.moon_of], which players can't pick")
			TEST_ASSERT_EQUAL(planet.star_system, origin.star_system, "Moon [origin_name] isn't in the star system of its planet")
			TEST_ASSERT(!planet.moon_of, "Moon [origin_name] orbits [origin.moon_of], which is a moon itself")

	for(var/datum/accent/accent_type as anything in subtypesof(/datum/accent))
		TEST_ASSERT(accent_type::name, "[accent_type] has no name")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.origin = ORIGIN_EARTH
	human.accent = ACCENT_TEMPLATE
	human.accent_glyph = "<"
	var/datum/accent/template_accent = GLOB.accents[ACCENT_TEMPLATE]
	TEST_ASSERT_EQUAL(human.get_accent_glyph(), "<b style='color:[template_accent.glyph_color]'>&lt;</b> ", "Chat glyph of a human")
	human.accent_glyph = ""
	human.get_accent_glyph()
	TEST_ASSERT(human.accent_glyph in GLOB.accent_glyphs, "A human without a glyph didn't get a random one")
