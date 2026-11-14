//Posters of Baystation 12 (code/game/objects/effects/decals/posters/ and maps/torch/structures/posters.dm in the source)

/// A design random Bay posters pick from
#define POSTER_FLAG_RANDOM_PICK (1<<0)
/// A design only contraband posters show
#define POSTER_FLAG_CONTRABAND (1<<1)
/// A design of the Torch, which its own posters pick from
#define POSTER_FLAG_TORCH (1<<2)

/datum/poster
	/// The file of its sprite
	var/icon = 'icons/obj/structures/props/wall_decorations/posters.dmi'
	/// What Bay posters make of the design, POSTER_FLAG_*; none for those that are not Bay's
	var/bay_poster_flags = NONE

// Each poster shows the sprite of its design from the file of the design
/obj/structure/sign/poster/Initialize(mapload, serial)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	var/datum/poster/design = GLOB.poster_designs[serial_number]
	icon = initial(design.icon)

/**
 * A Bay poster: a CM poster, ripped, taken down and put back up as those are, that shows a design of Bay
 *
 * Unless mapped with one, it picks a design at random from those it may show (/singleton/poster and
 * get_random_poster_type() of the source): random picks without contraband, or of its kind.
 */
/obj/structure/sign/poster/bay
	desc = "A large piece of space-resistant printed paper."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "random_poster"
	/// The type of its design, for one mapped with a design
	var/poster_type
	/// POSTER_FLAG_* a design picked at random must have
	var/required_flags = POSTER_FLAG_RANDOM_PICK
	/// POSTER_FLAG_* a design picked at random must not have
	var/excluded_flags = POSTER_FLAG_CONTRABAND

/obj/structure/sign/poster/bay/Initialize(mapload, serial)
	if(!serial && !isnum(serial_number))
		serial_number = poster_type ? GLOB.poster_designs.Find(poster_type) : random_bay_poster_serial(required_flags, excluded_flags)
	return ..()

/**
 * The number of a design of Bay at random
 *
 * * required_flags - POSTER_FLAG_* it must have
 * * excluded_flags - POSTER_FLAG_* it must not have
 */
/proc/random_bay_poster_serial(required_flags = POSTER_FLAG_RANDOM_PICK, excluded_flags = NONE)
	var/list/serials = list()
	for(var/serial in 1 to length(GLOB.poster_designs))
		var/datum/poster/design = GLOB.poster_designs[serial]
		var/flags = initial(design.bay_poster_flags)
		if((flags & required_flags) == required_flags && !(flags & excluded_flags))
			serials += serial
	return pick(serials)

/// A Bay poster with one of the designs of the Torch
/obj/structure/sign/poster/bay/torch
	required_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_TORCH

/obj/structure/sign/poster/bay/torch/counselor
	poster_type = /datum/poster/bay_counselor

/obj/structure/sign/poster/bay/bay_9
	poster_type = /datum/poster/bay_9

/obj/structure/sign/poster/bay/bay_50
	poster_type = /datum/poster/bay_50

// The designs (/singleton/poster in the source), flat, as CM takes every type of /datum/poster for a design

/datum/poster/bay_1
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter1"
	name = "Unlucky Space Explorer"
	desc = "This particular one depicts a skeletal form within a space suit."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_2
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter2"
	name = "Positronic Logic Conflicts"
	desc = "This particular one depicts the cold, unmoving stare of a particular advanced AI."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_3
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter3"
	name = "Paranoia"
	desc = "This particular one warns of the dangers of trusting your co-workers too much."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_4
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter4"
	name = "Keep Calm"
	desc = "This particular one is of a famous New Earth design, although a bit modified. Someone has scribbled an O over the A on the poster."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_5
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter5"
	name = "Martian Warlord"
	desc = "This particular one depicts the cartoony mug of a certain Martial Warmonger."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_6
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter6"
	name = "Technological Singularity"
	desc = "This particular one is of the blood-curdling symbol of a long-since defeated enemy of humanity."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_8
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter8"
	name = "Pinup Girl Cindy"
	desc = "This particular one is of a historical corporate PR girl, Cindy, in a particularly feminine pose."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_9
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter9"
	name = "Pinup Girl Amy"
	desc = "This particular one is of Amy, the nymphomaniac urban legend of deep space. How this photograph came to be is not known."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_10
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter10"
	name = "Don't Panic"
	desc = "This particular one depicts some sort of star in a grimace. The \"Don't Panic\" is written in big, friendly letters."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_11
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter11"
	name = "Underwater Laboratory"
	desc = "This particular one is of the fabled last crew of a previous Company project."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_12
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter12"
	name = "Rogue AI"
	desc = "This particular one depicts the shell of the infamous AI that catastropically comandeered one of humanity's earliest space stations. Back then, the Company was just known as TriOptimum."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_13
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter13"
	name = "User of the Arcane Arts"
	desc = "This particular one depicts a wizard, casting a spell. You can't really make out if it's an actual photograph or a computer-generated image."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_14
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter14"
	name = "Levitating Skull"
	desc = "This particular one is the portrait of a flying enchanted skull. Its adventures along with its fabled companion are now fading through history..."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_15
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter15"
	name = "Augmented Legend"
	desc = "This particular one is of an obviously augmented individual, gazing towards the sky. The cyber-city in the backround is rather punkish."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_16
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter16"
	name = "Dangerous Static"
	desc = "This particular one depicts nothing remarkable other than a rather mesmerising pattern of monitor static. There's a tag on the sides of the poster, but it's ripped off."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_17
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter17"
	name = "Pinup Girl Val"
	desc = "Luscious Val McNeil, the vertically challenged Legal Extraordinaire, winner of Miss Space two years running and favoured pinup girl of Lawyers Weekly."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_18
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter18"
	name = "Derpman, Enforcer of the State"
	desc = "Here to protect and serve... your donuts! A generously proportioned man, he teaches you the value of hiding your snacks."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_19
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter19"
	name = "Respect an Unathi"
	desc = "This poster depicts a well dressed looking Unathi receiving a prestigious award. It appears to espouse greater co-operation and harmony between the two races."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_20
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter20"
	name = "Skrell Twilight"
	desc = "This poster depicts a mysteriously inscrutable, alien scene. Numerous Skrell can be seen conversing amidst great, crystalline towers rising above crashing waves"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_21
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter21"
	name = "Join the Fuzz!"
	desc = "It's a nice recruitment poster of a white haired Chinese woman that says; \"Big Guns, Hot Women, Good Times. Security. We get it done.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_22
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter22"
	name = "Looking for a career with excitement?"
	desc = "A recruitment poster starring a dark haired woman with glasses and a purple shirt that has \"Got Brains? Got Talent? Not afraid of electric flying monsters that want to suck the soul out of you? Then Xenobiology could use someone like you!\" written on the bottom."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_23
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter23"
	name = "Safety first: because electricity doesn't wait!"
	desc = "A safety poster starring a clueless looking redhead with frazzled hair. \"Every year, hundreds of employees expose themselves to electric shock. Play it safe. Avoid suspicious doors after electrical storms, and always wear protection when doing electric maintenance.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_24
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter24"
	name = "Responsible medbay habits, No #259"
	desc = "A poster with a nervous looking geneticist on it states; \"Friends Tell Friends They're Clones. It can cause severe and irreparable emotional trauma if a person is not properly informed of their recent demise. Always follow your contractual obligation and inform them of their recent rejuvenation.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_25
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter25"
	name = "Irresponsible medbay habits, No #2"
	desc = "This is a safety poster starring a perverted looking naked doctor. \"Sexual harassment is never okay. REPORT any acts of sexual deviance or harassment that disrupt a healthy working environment.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_26
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter26"
	name = "The Men We Knew"
	desc = "This movie poster depicts a group of soldiers fighting a large exosuit, the movie seems to be a patriotic war movie."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_27
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter27"
	name = "Plastic Sheep Can't Scream"
	desc = "This is a movie poster for an upcoming horror movie, it features an AI in the front of it."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_28
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter28"
	name = "The Stars Know Love"
	desc = "This is a movie poster. A bleeding woman is shown drawing a heart in her blood on the window of space ship, it seems to be a romantic Drama."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_29
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter29"
	name = "Winter Is Coming"
	desc = "On the poster is a frighteningly large wolf, he warns: \"Only YOU can keep humanity from freezing during planetary occultation!\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_30
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter30"
	name = "Ambrosia Vulgaris"
	desc = "Just looking at this poster makes you feel a little bit dizzy."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_31
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter31"
	name = "Donut Corp"
	desc = "This is an advertisement for Donut Corp, the new innovation in donut technology!"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_32
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter32"
	name = "Eat!"
	desc = "A poster depicting a hamburger. The poster orders you to consume the hamburger."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_33
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter33"
	name = "Tools, tools, tools"
	desc = "You can never have enough tools, thats for sure!"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_34
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter34"
	name = "Power Up!"
	desc = "High reward, higher risk!"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_35
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter35"
	name = "Lamarr"
	desc = "This is a poster depicting the pet and mascot of the science department."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_36
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter36"
	name = "Fancy Borg"
	desc = "A poster depicting a cyborg using the service module. 'Fancy Borg' is written on it."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_37
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter37"
	name = "Fancier Borg"
	desc = "A poster depicting a cyborg using the service module. 'Fancy Borg' is written on it. This is even fancier than the first poster."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_38
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter38"
	name = "Toaster Love"
	desc = "This is a poster of a toaster containing two slices of bread. The word LOVE is written in big pink letters underneath."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_39
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter39"
	name = "Responsible medbay habits, No #91"
	desc = "A safety poster with a chemist holding a vial. \"Always wear safety gear while handling dangerous chemicals, even if it concerns only small amounts.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_40
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter40"
	name = "Agreeable work environment"
	desc = "This poster depicts a young woman in a stylish dress. \"Try to aim for a pleasant atmosphere in the workspace. A friendly word can do more than forms in triplicate.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_41
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter41"
	name = "Professional work environment"
	desc = "A safety poster featuring a green haired woman in a shimmering blue dress. \"As an Internal Affairs Agent, your job is to create a fair and agreeable work environment for the crewmembers, as discreetly and professionally as possible.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_42
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter42"
	name = "Engineering pinup"
	desc = "This is pin-up poster. A half-naked girl with white hair, toned muscles and stunning blue eyes looks back at you from the poster. Her welding helmet, tattoos and grey jumpsuit hanging around her waist gives a bit of a rugged feel."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_43
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter43"
	name = "Responsible medbay habits, No #3"
	desc = "A safety poster with a purple-haired surgeon. She looks a bit cross. \"Let the surgeons do their work. NEVER replace or remove a surgery tool from where the surgeon put it.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_45
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter45"
	name = "Responsible engineering habits, No #1"
	desc = "A safety poster featuring a blue haired engineer. \"When repairing a machine or construction, always aim for long-term solutions.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_46
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter46"
	name = "Inspirational lawyer"
	desc = "An inspirational poster depicting a Skrellian lawyer. He seems to be shouting something, while pointing fiercely to the right."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_47
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter47"
	name = "Security pinup"
	desc = "This is a pin-up poster. A dark skinned white haired girl poses in the sunlight wearing a tank top with her stomach exposed. The text on the poster states \"M, Succubus of Security.\" and a lipstick mark stains the top right corner, as if kissed by the model herself."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_48
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter48"
	name = "Borg pinup?"
	desc = "This is a.. pin-up poster? It is a diagram on an old model of cyborg with a note scribbled in marker on the bottom, on the top there is a large XO written in red marker."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_49
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter49"
	name = "Engineering recruitment"
	desc = "This is a poster showing an engineer relaxing by a computer, the text states \"Living the life! Join Engineering today!\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_50
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter50"
	name = "Pinup Girl Cindy Kate"
	desc = "This particular one is of Cindy Kate, a seductive performer well known among less savoury circles."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_51
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter51"
	name = "space appreciation poster"
	desc = "This is a poster produced by the Generic Space Company, as a part of a series of commemorative posters on the wonders of space. One of three."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_52
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter52"
	name = "fire safety poster"
	desc = "This is a poster reminding you of what you should do if you are on fire, or if you are at a dance party."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_53
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter53"
	name = "fire extinguisher poster"
	desc = "This is a poster reminding you of what you should use to put out a fire."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_54
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter54"
	name = "firefighter poster"
	desc = "This is a poster of a particularly stern looking firefighter. The caption reads, \"Only you can prevent space fires.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_55
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter55"
	name = "Earth appreciation poster"
	desc = "This is a poster produced by the Generic Space Company, as a part of a series of commemorative posters on the wonders of space. Two of three."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_56
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter56"
	name = "Mars appreciation poster"
	desc = "This is a poster produced by the Generic Space Company, as a part of a series of commemorative posters on the wonders of space. Three of three."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_57
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter57"
	name = "space carp warning poster"
	desc = "This poster tells of the dangers of space carp infestations."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_58
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter58"
	name = "space carp information poster"
	desc = "This poster showcases an old spacer saying on the dangers of migrant space carp."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_59
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter59"
	name = "poster - Miss Science 2299"
	desc = "A large piece of space-resistant printed paper. This pin-up poster depicts a woman wearing a corporate labcoat, a bikini, and a sheepish grin. She's shyly posing atop some highly specialized research equipment."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_nabber
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "poster_nabber"
	name = "serpentid information poster"
	desc = "This worn poster produced by Xynergy tells the dangers of close encounters with serpentids, and warns to not go near them."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_fleet
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "poster_fleet"
	name = "SCGF recruitment poster"
	desc = "A poster produced by the SCGF. It depicts a tactical-looking Fourth Fleet petty officer, standing in front of the SCG flag proudly."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_annoyed_gas
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "annoyed_gas"
	name = "Annoyed GAS"
	desc = "The poster shows a chittering Giant Armored Serpentid with its scythe arms raised \
	and ready to attack. \"Run!\" is written in big red letters, and at the very bottom there \
	is a small text: \"If during the communication process the GAS began to actively chitter, \
	buzz, raised sickles or strikes in the air with them - you must turn around and leave him \
	alone.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_healthy_hugs
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "healthy_hugs"
	name = "Healthy hugs"
	desc = "The poster shows a Giant Armored Serpentid holding a girl with a yellow flower in \
	her hair with sickles. On the left - a large inscription \"HUGS\" in green letters, under \
	which it is written in small letters: \"Hugs are useful both morally and physically: for \
	example, the human race lowers blood pressure and produces oxytocin. Almost any crew will \
	increase confidence and feel good. The main thing is - be sure to ask permission.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_no_alcohol
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "no_alcohol"
	name = "Clean Living"
	desc = {"At the top of the poster is a word in Cyrillic script missing its middle letter: \
	"СП*РТ". Below are two letters to fill in, "O" and "И", along with a word association for \
	each: "СПOРТ - СИЛА" (SPORT - STRENGTH), and "СПИРТ - МОГИЛА" (SPIRIT - GRAVE). Public health \
	messaging at its finest!"}
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_pizza_for_captain
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "pizza_for_captain"
	name = "Pizza for Captain"
	desc = "On fairly cheap thick paper, the red inscription reads: \"Pizza for Captain\". The \
	slice of pizza itself is also drawn... with pineapples? Wouldn't eat this for anything! \
	Someone apparently doesn't like the captain very much..."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_would_you_plant
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "would_you_plant"
	name = "Would you seed?"
	desc = "A large green poster shows a brand new hydroponic tray. On top is a large text with \
	the evocative question, \"Would you seed?\", with small text explaining, \"Hydroponic trays \
	allow you to grow absolutely any crop quickly and efficiently, and the indicators tell you \
	when the plant needs care! And how can you not seed one of these?\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_cabbage_tray
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "cabbage_tray"
	name = "Cabbage tray"
	desc = "The poster shows a Giant Armored Serpentid with a hydroponic tray of ripe cabbage \
	in front of it, indicated by a green indicator on it. On the left side of the poster it \
	says: \"Most GAS don't know how to cut existing plantings. Please don't plant all the trays \
	and leave a few free ones. In order for the serpentid to eat, it only needs literally a \
	couple of empty trays.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_earth
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_earth"
	name = "Visit Earth!"
	desc = "A large piece of space-resistant printed paper. This poster depicts the metropolis of New Benin, \
	the background showing the high rises around the space elevator. In the foreground is lush jungle foliage. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the birthplace of ingenuity.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_mars
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_mars"
	name = "Visit Mars!"
	desc = "A large piece of space-resistant printed paper. This poster depicts the SGC capital atop Olympus Mons, \
	the sun's rays artfully shaded across the mountain. The city appears somehow both small against the peak, \
	but towering above it. The small print urges the reader to contact \
	Zeng-hu Travel Solutions to visit \"the beating heart of Sol.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_luna
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_luna"
	name = "Visit Luna!"
	desc = "A large piece of space-resistant printed paper. This poster depicts the lights of New Vegas across a dark sky, \
	the artificial shine greater than the stars above. Tiny vehicles show the scale of the skyscrapers. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the one true city of night.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_ceti
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_ceti"
	name = "Visit Ceti!"
	desc = "A large piece of space-resistant printed paper. This poster depicts the high-rises of Icon, \
	portrayed as though they formed part of a massive circuit board. The image is colour-shifted to give it a chrome-like sheen. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"tomorrow from today.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_venus
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_venus"
	name = "Visit Venus!"
	desc = "A large piece of space-resistant printed paper. This poster depicts the Caelestis Resort, \
	Zeng-hu Travel Solution's premier holiday destination in the Zone, known for delivering every luxury its patrons can afford. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the closest thing to heaven.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_pirx
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_pirx"
	name = "Visit Pirx!"
	desc = "A large piece of space-resistant printed paper. \
	This poster depicts soaring Basking Trees on a thick bed of Pirx Grass that complements the deep sunset. \
	There is not a single sign of development in view. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the last of the untouched paradises.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_gaia
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_gaia"
	name = "Visit Gaia!"
	desc = "A large piece of space-resistant printed paper. This poster depicts small settlements and farmhouses set among rolling, \
	grassy plains, with a distant lake beneath a peaceful blue sky. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"a land of pastoral peace, away from it all.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_foster
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_foster"
	name = "Visit Foster's World!"
	desc = "A large piece of space-resistant printed paper. This poster depicts a figure in silhouette, \
	fishing on an icy lake as a star rises between vast mountains beyond. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the true wilderness - untainted, unforgiving, unforgettable.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_tadmor
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_tadmor"
	name = "Visit Tadmor!"
	desc = "A large piece of space-resistant printed paper. \
	This poster depicts the view looking down from the top of Tadmor's tectonic canyons, at the valley below. \
	There are hints of settlements built into the canyons visible. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the premier destination for those who go against the grain.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_tadmor_1
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_tadmor_1"
	name = "Visit Tadmor!"
	desc = "A large piece of space-resistant printed paper. \
	This poster depicts the view looking up from one of Tadmor's tectonic canyons at the twin stars of Gamma Cephei. \
	There are hints of settlements built into the canyons visible. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"the premier destination for those who go against the grain.\""
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_visit_brahe
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_brahe"
	name = "(DON'T) Visit Brahe!"
	desc = "A large piece of space-resistant printed paper. This poster depicts a glittering city that sits, coral-like, \
	atop a vast ocean, shimmering in the sun. The sand in the foreground is impeccable and the sky has only wispy clouds. \
	<span class='danger'>A Level 4 Travel Advisory issued by the Office of Interstellar Intelligence has been stuck on top of this poster, \
	which indicates all unauthorised travel to Brahe to be in breach of an ongoing blockade.</span>"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK

/datum/poster/bay_unusual_gas
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "unusual_gas"
	name = "Unusual GAS"
	desc = "The poster shows a Giant Armored Serpentid. On his tail is what appears to be a \
	large black gaiter with purple stripes. GAS sickles are dressed in cute little mitts of \
	the same color. The entire lower right corner of the poster is occupied by a large \
	inscription \"uwu\", and in the lower left it says: \"More on our site - WetSkrell.nt\"."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_CONTRABAND

/datum/poster/bay_visit_brahe_1
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "visit_brahe_1"
	name = "Visit Brahe!"
	desc = "A large piece of space-resistant printed paper. This poster depicts a glittering city that sits, coral-like, \
	atop a vast ocean, shimmering in the sun. The sand in the foreground is impeccable and the sky has only wispy clouds. \
	The small print urges the reader to contact Zeng-hu Travel Solutions to visit \"a true jewel of the ocean.\". \
	<span class='notice'>A small marker-born etching on the side seems to say, \"Strike the iron while it's hot - For the Frontier Alliance!\"</span>"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_CONTRABAND

/datum/poster/bay_counselor
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "live_laugh_love"
	name = "Wholesome Poster"
	desc = "A wholesome, mass-fabricated poster that states \"Live Laugh Love\". There's tons of small hearts plastered around the text. The dot above the \"i\" has been drawn in the shape of a heart. Supposed to lift your mood... somehow?"
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_TORCH

/datum/poster/bay_event1
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter_event1"
	name = "Justice for Joe"
	desc = "A hand-written poster demanding the release of one SCPO Joseph Tornakov from Fleet Intelligence custody. It's somewhat faded, and someone's drawn an impressive moustache on Tornakov in permanent marker. Someone has also written general anti-government statements written around the poster's fringes."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_CONTRABAND

/datum/poster/bay_event2
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter_event2"
	name = "Captain for Senate"
	desc = "A poster loudly advertising the SEV Torch's captain's upcoming bid for SCG Senate. The fine print lightly suggests that failing to vote in their favor will result in an NJP."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_CONTRABAND

/datum/poster/bay_event3
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter_event3"
	name = "Visit E-14b Outpost"
	desc = "This poster invites personnel to visit the the E-14b research outpost, built through joint Terran and Expeditionary Corps efforts. According to the poster, it's still under construction."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_TORCH

/datum/poster/bay_event4
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/bay_posters.dmi'
	icon_state = "bsposter_event4"
	name = "Scientific Cooperation"
	desc = "This poster depicts a Sol Expeditionary Corps captain shaking hands with a Terran Pioneer Corps officer. It appears to espouse greater scientific cooperation between the two organisations."
	bay_poster_flags = POSTER_FLAG_RANDOM_PICK | POSTER_FLAG_TORCH

#undef POSTER_FLAG_RANDOM_PICK
#undef POSTER_FLAG_CONTRABAND
#undef POSTER_FLAG_TORCH
