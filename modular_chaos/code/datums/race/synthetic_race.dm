/// Key of the synthetic generation option, whose values are the species of the generations
#define SYNTHETIC_OPTION_GENERATION "generation"

/datum/playable_race/synthetic
	id = RACE_SYNTHETIC
	name = "Synthetic"
	tagline = "An artificial person"
	desc = "A machine built to look and act human, made to work where people can't or won't. A synthetic outlasts any human, feels no pain and needs no air, but no medicine works on them: they are repaired like any other machine."
	icon = "robot"
	color = "#7fd1ff"
	species = SYNTH_GEN_THREE
	pros = list(
		"Takes half the brute damage and a bit less burn damage than a human",
		"Feels no pain, shrugs off stuns and knockdowns faster",
		"Doesn't breathe, can't be poisoned or infected by an embryo",
		"Sees in the dark and is immune to electric shocks and the cold",
	)
	cons = list(
		"Medicine does nothing: dents are fixed with a welder, burns with cable",
		"Bleeds white synthetic fluid, which gives away what they are",
	)
	option_types = list(/datum/race_option/choice/synthetic_generation)

/datum/playable_race/synthetic/get_species(list/values)
	return values?[SYNTHETIC_OPTION_GENERATION] || species

/// Generation of a synthetic race character, which is their species
/datum/race_option/choice/synthetic_generation
	key = SYNTHETIC_OPTION_GENERATION
	name = "Generation"
	desc = "Older generations are sturdier and slower, and look less human."
	default = SYNTH_GEN_THREE
	choices = list(
		SYNTH_GEN_THREE = "Third",
		SYNTH_GEN_TWO = "Second",
		SYNTH_GEN_ONE = "First",
	)
	choice_descs = list(
		SYNTH_GEN_THREE = "Can't be told apart from a human at a glance. 150 health.",
		SYNTH_GEN_TWO = "Heavier frame: 200 health, less burn damage and can't be pounced, but a bit slower.",
		SYNTH_GEN_ONE = "The frame of the second generation in an obviously artificial body, whose eyes glow in the color of the intent.",
	)

#undef SYNTHETIC_OPTION_GENERATION
