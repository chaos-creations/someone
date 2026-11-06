/datum/playable_race/vox
	id = RACE_VOX
	name = "Vox"
	tagline = "Shrieking scavengers of the arkships"
	desc = "Beaked, quilled and tailed reptilian aliens from the moon-sized arkships of the Vox Empire. Oxygen is poison to them: they live on nitrogen from a tank, and they wear only clothing made for their talons and beaks."
	icon = "crow"
	color = "#5fb8a8"
	species = SPECIES_VOX
	pros = list(
		"Talons and beak hit twice as hard as human fists",
		"Shrugs off the cold far below what a human survives",
		"Speaks Vox-pidgin, which nobody else understands",
	)
	cons = list(
		"Suffocates and is poisoned by air without a nitrogen tank and a Vox mask",
		"Can't wear human gloves, footwear or masks",
	)
	allowed_origins = VOX_ORIGINS
	default_origin = ORIGIN_VOX_STARLIGHT_HERALD
