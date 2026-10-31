/// Cyrillic text survives the text helpers and speech filters, and say prefixes typed with the Russian keyboard layout work
/datum/unit_test/cyrillic_text

/datum/unit_test/cyrillic_text/Run()
	// What a byte cut inside a multi-byte character turns it into
	var/broken_char = ascii2text(0xFFFD)

	TEST_ASSERT_EQUAL(capitalize("привет, мир"), "Привет, мир", "capitalize() with a Cyrillic first letter")
	TEST_ASSERT_EQUAL(capitalize("hello"), "Hello", "capitalize() with a Latin first letter")
	TEST_ASSERT_EQUAL(capitalize(""), "", "capitalize() of an empty string")
	TEST_ASSERT_EQUAL(stars("привет мир", 0), "****** ***", "stars() hides each Cyrillic letter with one star")
	TEST_ASSERT_EQUAL(stars("привет мир", 100), "привет мир", "stars() keeps clear Cyrillic letters")
	TEST_ASSERT_EQUAL(strip_html("привет мир", 5), "прив", "strip_html() limits by characters")
	TEST_ASSERT_EQUAL(findtext(DazedText("привет"), "п-р"), 1, "DazedText() repeats the second Cyrillic letter")

	for(var/garbled in list(slur("привет мир"), Gibberish("привет мир", 50), NewStutter("привет мир", TRUE), adminscrub("привет", 4)))
		TEST_ASSERT(!findtext(garbled, broken_char), "Speech filter broke a Cyrillic letter: [garbled]")

	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix(":рпривет", CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys), ":hпривет", "Radio prefix in the Russian layout")
	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix(":Рпривет", CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys), ":hпривет", "Uppercase radio prefix in the Russian layout")
	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix("№фпривет", CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys), "#aпривет", "№ radio prefix in the Russian layout")
	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix("№hпривет", CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys), "#hпривет", "№ radio prefix with a Latin key")
	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix(":ъпривет", CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys), ":ъпривет", "Unknown radio prefix stays as typed")
	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix("привет", CYRILLIC_RADIO_PREFIX_SYMBOLS, GLOB.department_radio_keys), "привет", "Message without a prefix stays as typed")
	TEST_ASSERT_EQUAL(convert_cyrillic_say_prefix("!япривет", CYRILLIC_LANGUAGE_PREFIX_SYMBOLS, GLOB.language_keys), "!zпривет", "Language prefix in the Russian layout")
	TEST_ASSERT_EQUAL(convert_cyrillic_multibroadcast(",рм привет"), ",hv привет", "Multi-broadcast keys in the Russian layout")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/list/say_modes = human.parse_say_modes(":р привет")
	TEST_ASSERT_EQUAL(say_modes["message_and_language"], "привет", "Human radio message with a Russian layout prefix")
	TEST_ASSERT((RADIO_CHANNEL_DEPARTMENT in say_modes["modes"]), "Human radio channel with a Russian layout prefix")
