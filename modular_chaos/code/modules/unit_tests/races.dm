/// Every race players can pick exists, allows its default origin and turns a human into a species for each choice of its options, whose defaults are valid, and the option kinds sanitize their values
/datum/unit_test/races

/datum/unit_test/races/Run()
	TEST_ASSERT(CHAOS_DEFAULT_RACE in GLOB.chaos_player_races, "The default race [CHAOS_DEFAULT_RACE] isn't one players can pick")
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	for(var/race_id in GLOB.chaos_player_races)
		var/datum/playable_race/playable_race = GLOB.playable_races[race_id]
		TEST_ASSERT(playable_race, "Player race [race_id] has no /datum/playable_race")
		TEST_ASSERT(playable_race.name, "Race [race_id] has no name")
		TEST_ASSERT(playable_race.can_have_origin(playable_race.default_origin), "Race [race_id] can't have its default origin [playable_race.default_origin]")
		TEST_ASSERT_EQUAL(length(playable_race.options), length(playable_race.option_types), "Race [race_id] has options with the same key")

		var/list/default_values = playable_race.sanitize_values(null)
		TEST_ASSERT(!("unknown" in playable_race.sanitize_values(list("unknown" = TRUE))), "Race [race_id] kept the value of an unknown option")
		for(var/key in playable_race.options)
			var/datum/race_option/option = playable_race.options[key]
			TEST_ASSERT(option.name && option.kind, "Option [key] of race [race_id] has no name or kind")
			TEST_ASSERT_EQUAL(option.sanitize(option.default), option.default, "Option [key] of race [race_id] doesn't take its default")
			if(!istype(option, /datum/race_option/choice))
				continue
			// An option can pick the species, so every choice must give one
			var/datum/race_option/choice/choice_option = option
			for(var/value in choice_option.choices)
				var/list/values = default_values.Copy()
				values[key] = value
				var/species_name = playable_race.get_species(values)
				TEST_ASSERT(GLOB.all_species[species_name], "Race [race_id] with [key] [value] has an unknown species [species_name]")
				playable_race.apply_to(human, values)
				TEST_ASSERT_EQUAL(human.species.name, species_name, "A human didn't become the species of race [race_id] with [key] [value]")

		var/species_name = playable_race.get_species(default_values)
		TEST_ASSERT(GLOB.all_species[species_name], "Race [race_id] has an unknown species [species_name]")
		playable_race.apply_to(human, default_values)
		TEST_ASSERT_EQUAL(human.species.name, species_name, "A human didn't become the species of race [race_id]")

	var/datum/race_option/choice/choice_option = allocate(/datum/race_option/choice)
	choice_option.choices = list("first" = "First", "second" = "Second")
	choice_option.default = "first"
	TEST_ASSERT_EQUAL(choice_option.sanitize("second"), "second", "A choice option didn't take one of its choices")
	TEST_ASSERT_EQUAL(choice_option.sanitize("third"), "first", "A choice option took a value it doesn't offer")

	var/datum/race_option/toggle/toggle_option = allocate(/datum/race_option/toggle)
	TEST_ASSERT_EQUAL(toggle_option.sanitize(null), FALSE, "A toggle option without a value isn't its default")
	TEST_ASSERT_EQUAL(toggle_option.sanitize(5), TRUE, "A toggle option didn't turn a true value into TRUE")

	var/datum/race_option/color/color_option = allocate(/datum/race_option/color)
	TEST_ASSERT_EQUAL(color_option.sanitize("#A0B1C2"), "#a0b1c2", "A color option didn't take a color")
	TEST_ASSERT_EQUAL(color_option.sanitize("#abc"), color_option.default, "A color option took a short color")
	TEST_ASSERT_EQUAL(color_option.sanitize("red"), color_option.default, "A color option took a color name")

	var/datum/race_option/text/text_option = allocate(/datum/race_option/text)
	var/text = text_option.sanitize(" <b>Tom & Jerry</b>\nЖ ")
	TEST_ASSERT_EQUAL(text, "bTom & Jerry/b Ж", "A text option didn't strip the HTML characters and line breaks")
	TEST_ASSERT_EQUAL(text_option.sanitize(text), text, "A text option changed a value it sanitized, as on every load")
	var/long_text = ""
	for(var/i in 1 to text_option.max_length + 5)
		long_text += "Ж"
	TEST_ASSERT_EQUAL(length_char(text_option.sanitize(long_text)), text_option.max_length, "A text option kept a text longer than it takes")
