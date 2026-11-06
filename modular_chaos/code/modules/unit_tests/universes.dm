/// The default universe and the one the server runs in exist, and every universe has a name; the races and origins tests check their races and origins
/datum/unit_test/universes

/datum/unit_test/universes/Run()
	TEST_ASSERT(GLOB.universes[CHAOS_DEFAULT_UNIVERSE], "The default universe [CHAOS_DEFAULT_UNIVERSE] has no /datum/universe")
	TEST_ASSERT(CURRENT_UNIVERSE, "The universe of the UNIVERSE config entry [CONFIG_GET(string/universe)] has no /datum/universe")
	for(var/universe_id in GLOB.universes)
		var/datum/universe/universe = GLOB.universes[universe_id]
		TEST_ASSERT(universe.name, "Universe [universe_id] has no name")
