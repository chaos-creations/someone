//Signs of Baystation 12 (code/game/objects/structures/signs.dm and barsign.dm, maps/torch/structures/signs.dm and packs/factions/scgec/misc.dm in the source)

/**
 * A Bay sign
 *
 * A CM sign, which a screwdriver takes down and puts back up as in the source, with the sprites of the source.
 */
/obj/structure/sign/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/signs.dmi'

/// A Bay sign two tiles wide, each half a sign of its own, which cannot be taken down
/obj/structure/sign/double/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/signs.dmi'

/obj/structure/sign/double/bay/map
	name = "map"
	desc = "A framed map."

/obj/structure/sign/double/bay/map/left
	icon_state = "map-left"

/obj/structure/sign/double/bay/map/right
	icon_state = "map-right"

/obj/structure/sign/bay/monkey_painting
	name = "\improper Mr. Deempisi portrait"
	desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
	icon_state = "monkey_painting"

/obj/structure/sign/bay/warning
	name = "\improper WARNING"
	icon_state = "securearea"

/obj/structure/sign/bay/warning/detailed
	icon_state = "securearea2"

/obj/structure/sign/bay/thera
	icon_state = "thera"
	name = "\improper THERA SAFE ROOM"
	desc = "A detailed sign that reads 'Temporary Housing for Emergency, Radioactive, Atmospheric. This location is unsuitable for extended Habitation. Do not shelter here beyond immediate need.'"

/obj/structure/sign/bay/warning/airlock
	name = "\improper EXTERNAL AIRLOCK"
	icon_state = "doors"

/obj/structure/sign/bay/warning/biohazard
	name = "\improper BIOHAZARD"
	icon_state = "bio"

/obj/structure/sign/bay/warning/bomb_range
	name = "\improper BOMB RANGE"
	icon_state = "blast"

/obj/structure/sign/bay/warning/caution
	name = "\improper CAUTION"

/obj/structure/sign/bay/warning/toxic_material
	name = "\improper TOXIC MATERIAL"
	icon_state = "toxic_material"

/obj/structure/sign/bay/warning/compressed_gas
	name = "\improper COMPRESSED GAS"
	icon_state = "hikpa"

/obj/structure/sign/bay/warning/deathsposal
	name = "\improper DISPOSAL LEADS TO SPACE"
	icon_state = "deathsposal"

/obj/structure/sign/bay/warning/docking_area
	name = "\improper KEEP CLEAR: DOCKING AREA"

/obj/structure/sign/bay/warning/engineering_access
	name = "\improper ENGINEERING ACCESS"

/obj/structure/sign/bay/warning/fall
	name = "\improper FALL HAZARD"
	icon_state = "falling"

/obj/structure/sign/bay/warning/fire
	name = "\improper DANGER: FIRE"
	icon_state = "fire"

/obj/structure/sign/bay/warning/high_voltage
	name = "\improper HIGH VOLTAGE"
	icon_state = "shock"

/obj/structure/sign/bay/warning/hot_exhaust
	name = "\improper HOT EXHAUST"
	icon_state = "fire"

/obj/structure/sign/bay/warning/internals_required
	name = "\improper INTERNALS REQUIRED"

/obj/structure/sign/bay/warning/lethal_turrets
	name = "\improper LETHAL TURRETS"
	icon_state = "turrets"

/obj/structure/sign/bay/warning/mail_delivery
	name = "\improper MAIL DELIVERY"
	icon_state = "mail"

/obj/structure/sign/bay/warning/moving_parts
	name = "\improper MOVING PARTS"
	icon_state = "movingparts"

/obj/structure/sign/bay/warning/nosmoking_1
	name = "\improper NO SMOKING"
	icon_state = "nosmoking"

/obj/structure/sign/bay/warning/nosmoking_2
	name = "\improper NO SMOKING"
	icon_state = "nosmoking2"

/obj/structure/sign/bay/warning/nosmoking_burned
	name = "\improper NO SMOKING"
	icon_state = "nosmoking2_b"

/obj/structure/sign/bay/warning/smoking
	name = "\improper SMOKING"
	icon_state = "smoking"

/obj/structure/sign/bay/warning/pods
	name = "\improper ESCAPE PODS"
	icon_state = "podsnorth"

/obj/structure/sign/bay/warning/pods/south
	name = "\improper ESCAPE PODS"
	icon_state = "podssouth"

/obj/structure/sign/bay/warning/pods/east
	name = "\improper ESCAPE PODS"
	icon_state = "podseast"

/obj/structure/sign/bay/warning/pods/west
	name = "\improper ESCAPE PODS"
	icon_state = "podswest"

/obj/structure/sign/bay/warning/radioactive
	name = "\improper RADIOACTIVE AREA"
	icon_state = "radiation"

/obj/structure/sign/bay/warning/secure_area
	name = "\improper SECURE AREA"

/obj/structure/sign/bay/warning/secure_area/armory
	name = "\improper ARMORY"
	icon_state = "armory"

/obj/structure/sign/bay/warning/server_room
	name = "\improper SERVER ROOM"
	icon_state = "server"

/obj/structure/sign/bay/warning/siphon_valve
	name = "\improper SIPHON VALVE"

/obj/structure/sign/bay/warning/vacuum
	name = "\improper HARD VACUUM AHEAD"
	icon_state = "space"

/obj/structure/sign/bay/warning/vent_port
	name = "\improper EJECTION/VENTING PORT"

/obj/structure/sign/bay/redcross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "redcross"

/obj/structure/sign/bay/greencross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "greencross"

/obj/structure/sign/bay/bluecross_1
	name = "infirmary"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "bluecross"

/obj/structure/sign/bay/bluecross_2
	name = "infirmary"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "bluecross2"

/obj/structure/sign/bay/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/bay/goldenplaque/security
	name = "motivational plaque"
	desc = "A plaque engraved with a generic motivational quote and picture. ' Greater love hath no man than this, that a man lay down his life for his friends. John 15:13 "

/obj/structure/sign/bay/goldenplaque/medical
	name = "medical certificate"
	desc = "A picture next to a long winded description of medical certifications and degrees."

/obj/structure/sign/bay/kiddieplaque
	name = "\improper AI developers plaque"
	desc = "An extremely long list of names and job titles and a picture of the design team responsible for building this AI Core."
	icon_state = "kiddieplaque"

/obj/structure/sign/bay/atmosplaque
	name = "\improper engineering memorial plaque"
	desc = "This plaque memorializes those engineers and technicians who made the ultimate sacrifice to save their vessel and its crew."
	icon_state = "atmosplaque"

/obj/structure/sign/bay/emergonly
	name = "\improper EMERGENCY ONLY"
	desc = "A warning sign which reads 'EMERGENCY ONLY!'."
	icon_state = "emerg"

/obj/structure/sign/bay/noidle
	name = "\improper NO IDLING"
	desc = "A warning sign which reads 'NO IDLING!'."
	icon_state = "noidle"

/obj/structure/sign/double/bay/maltesefalcon
	name = "The Maltese Falcon"
	desc = "The Maltese Falcon, Space Bar and Grill."

/obj/structure/sign/double/bay/maltesefalcon/left
	icon_state = "maltesefalcon-left"

/obj/structure/sign/double/bay/maltesefalcon/right
	icon_state = "maltesefalcon-right"

/obj/structure/sign/bay/warning/science
	name = "\improper SCIENCE!"
	icon_state = "science"

/obj/structure/sign/bay/warning/science/anomalous_materials
	name = "\improper ANOMALOUS MATERIALS"

/obj/structure/sign/bay/warning/science/mass_spectrometry
	name = "\improper MASS SPECTROMETRY"

/obj/structure/sign/bay/science_1
	name = "\improper RESEARCH WING"
	desc = "A sign labelling the research wing."
	icon_state = "science"

/obj/structure/sign/bay/science_2
	name = "\improper RESEARCH"
	desc = "A sign labelling an area where research is performed."
	icon_state = "science2"

/obj/structure/sign/bay/xenobio_1
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entites are researched."
	icon_state = "xenobio"

/obj/structure/sign/bay/xenobio_2
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entites are researched."
	icon_state = "xenobio2"

/obj/structure/sign/bay/xenobio_3
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entites are researched."
	icon_state = "xenobio3"

/obj/structure/sign/bay/xenobio_4
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entites are researched."
	icon_state = "xenobio4"

/obj/structure/sign/bay/xenoarch
	name = "\improper XENOARCHAEOLOGY"
	desc = "A sign labelling an area as a place where xenoarchaeological finds are researched."
	icon_state = "xenobio4"

/obj/structure/sign/bay/chemistry
	name = "\improper CHEMISTRY"
	desc = "A sign labelling an area containing chemical equipment."
	icon_state = "chemistry"

/obj/structure/sign/bay/xenoflora
	name = "\improper XENOFLORA"
	desc = "A sign labelling an area as a place where xenobiological plants are researched."
	icon_state = "hydro4"

/obj/structure/sign/bay/botany
	name = "\improper BOTANY"
	desc = "A warning sign which reads 'BOTANY!'."
	icon_state = "hydro3"

/obj/structure/sign/bay/hydro
	name = "\improper HYDROPONICS"
	desc = "A sign labelling an area as a place where plants are grown."
	icon_state = "hydro"

/obj/structure/sign/bay/hydrostorage
	name = "\improper HYDROPONICS STORAGE"
	desc = "A sign labelling an area as a place where plant growing supplies are kept."
	icon_state = "hydro3"

/obj/structure/sign/bay/directions
	name = "direction sign"
	desc = "A direction sign, claiming to know the way."
	icon_state = "direction"

/obj/structure/sign/bay/directions/science
	name = "\improper Research Division"
	icon_state = "direction_sci"

/obj/structure/sign/bay/directions/janitor
	name = "\improper Custodial Closet"
	icon_state = "direction_jan"

/obj/structure/sign/bay/directions/engineering
	name = "\improper Engineering Bay"
	icon_state = "direction_eng"

/obj/structure/sign/bay/directions/security
	name = "\improper Security Wing"
	icon_state = "direction_sec"

/obj/structure/sign/bay/directions/medical
	name = "\improper Medical Bay"
	icon_state = "direction_med"

/obj/structure/sign/bay/directions/evac
	name = "\improper Evacuation Wing"
	icon_state = "direction_evac"

/obj/structure/sign/bay/directions/bridge
	name = "\improper Bridge"
	icon_state = "direction_bridge"

/obj/structure/sign/bay/directions/supply
	name = "\improper Supply Office"
	icon_state = "direction_supply"

/obj/structure/sign/bay/directions/infirmary
	name = "\improper Infirmary"
	icon_state = "direction_infirm"

/obj/structure/sign/bay/directions/examroom
	name = "\improper Exam Room"
	icon_state = "examroom"

/obj/structure/sign/bay/directions/infm
	name = "\improper Infirmary"
	icon_state = "infm"

/obj/structure/sign/bay/directions/med
	name = "\improper Medbay"
	icon_state = "med"

/obj/structure/sign/bay/deck/bridge
	name = "\improper Bridge Deck"
	icon_state = "deck-b"

/obj/structure/sign/bay/deck/first
	name = "\improper First Deck"
	icon_state = "deck-1"

/obj/structure/sign/bay/deck/second
	name = "\improper Second Deck"
	icon_state = "deck-2"

/obj/structure/sign/bay/deck/third
	name = "\improper Third Deck"
	icon_state = "deck-3"

/obj/structure/sign/bay/deck/fourth
	name = "\improper Fourth Deck"
	icon_state = "deck-4"

/obj/structure/sign/bay/deck/fifth
	name = "\improper Fifth Deck"
	icon_state = "deck-5"

/obj/structure/sign/bay/dedicationplaque
	name = "\improper SEV Torch dedication plaque"
	icon_state = "lightplaque"

/obj/structure/sign/bay/solgov
	name = "\improper SolGov Seal"
	desc = "A sign which signifies who this vessel belongs to."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/solgov.dmi'
	icon_state = "solgovseal"

/obj/structure/sign/double/bay/solgovflag
	name = "\improper Sol Central Government Flag"
	desc = "The flag of the Sol Central Government, a symbol of many things to many people."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/solgov.dmi'

/obj/structure/sign/double/bay/solgovflag/left
	icon_state = "solgovflag-left"

/obj/structure/sign/double/bay/solgovflag/right
	icon_state = "solgovflag-right"

// The descriptions the source writes when a sign is made

/obj/structure/sign/double/bay/map/Initialize(mapload, ...)
	. = ..()
	desc = "A framed map of the [SSmapping.configs[SHIP_MAP]?.map_name]."

/obj/structure/sign/bay/warning/Initialize(mapload, ...)
	. = ..()
	desc = "A warning sign which reads '[strip_improper(name)]'."

/obj/structure/sign/bay/warning/lethal_turrets/Initialize(mapload, ...)
	. = ..()
	desc += " Enter at own risk!"

/obj/structure/sign/bay/warning/nosmoking_burned/Initialize(mapload, ...)
	. = ..()
	desc += " It looks charred."

/obj/structure/sign/bay/warning/smoking/Initialize(mapload, ...)
	. = ..()
	desc += " Hell yeah."

/obj/structure/sign/bay/directions/Initialize(mapload, ...)
	. = ..()
	desc = "A direction sign, pointing out which way \the [src] is."

/obj/structure/sign/bay/dedicationplaque/Initialize(mapload, ...)
	. = ..()
	desc = "S.E.V. Torch - Mako Class - Sol Expeditionary Corps Registry 95519 - Shiva Fleet Yards, Mars - First Vessel To Bear The Name - Launched [GLOB.game_year - 5] - Sol Central Government - 'Never was anything great achieved without danger.'"

/**
 * The memorial rock of the Torch, which lists the fallen whose dog tags were added to it
 *
 * Dog tags come with the items of the Torch; until then the list stays as the map leaves it.
 */
/obj/structure/sign/bay/memorial
	name = "memorial rock"
	desc = "A large stone slab, engraved with the names of uniformed personnel who gave their lives for scientific progress. Not a list you'd want to make. Add the dog tags of the fallen to the monument to memorialize them."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/solgov_64x64.dmi'
	icon_state = "memorial"
	density = TRUE
	anchored = TRUE
	pixel_x = -16
	pixel_y = -16
	unacidable = TRUE
	deconstructable = FALSE
	/// The fallen engraved on it, "rank name | branch" each
	var/list/fallen = list()
	/// The branches whose dog tags it takes
	var/list/accepted_branches = list(
		"Expeditionary Corps",
		"Fleet",
	)

/obj/structure/sign/bay/memorial/get_examine_text(mob/user)
	. = ..()
	if(get_dist(user, src) > 2)
		return
	if(length(fallen))
		. += "<b>Among the many names, you read:</b><br> [jointext(fallen, "<br>")]"
	else
		. += "<b>There are many names engraved on \the [src].</b>"

/**
 * The plaque of the Expeditionary Directives, which shows them to whoever examines it, and which faces can be smashed
 * into
 */
/obj/structure/sign/bay/ecplaque
	name = "\improper Expeditionary Directives"
	desc = "A plaque with Expeditionary Corps logo etched in it."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/solgov.dmi'
	icon_state = "ecplaque"
	/// The directives it shows
	var/directives = {"<hr><center>\
		<p>1. <b>Exploring the unknown is your Primary Mission</b>\
			<p>You are to look for land and resources that can be used by Humanity to advance and prosper. Explore. Document. Explain. Knowledge is the most valuable resource.</p>\
		</p>\
		<p>2. <b>Every member of the Expeditionary Corps is an explorer</b>\
			<p>Some are Explorers by rank or position, but everyone has to be one when duty calls. You should always expect being assigned to an expedition if needed. You have already volunteered when you signed up.</p>\
		</p>\
		<p>3. <b>Danger is a part of the mission - avoid, not run away</b>\
			<p>Keep your crew alive and hull intact, but remember - you are not here to sightsee. Dangers are obstacles to be cleared, not the roadblocks. Weigh risks carefully and keep your Primary Mission in mind.</p>\
		</p>\
		</center><hr>\
		"}

/obj/structure/sign/bay/ecplaque/get_examine_text(mob/user)
	. = ..()
	. += "The founding principles of EC are written there: <a href='byond://?src=\ref[src];show_info=1'>Expeditionary Directives</a>"

/obj/structure/sign/bay/ecplaque/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["show_info"])
		to_chat(usr, directives)
		return TRUE

/obj/structure/sign/bay/ecplaque/attackby(obj/item/attacking_item, mob/user)
	var/obj/item/grab/grab = attacking_item
	if(!istype(grab) || !ishuman(grab.grabbed_thing) || user.a_intent != INTENT_HARM)
		return ..()
	var/mob/living/carbon/human/victim = grab.grabbed_thing
	victim.apply_damage(5, BRUTE, "head")
	user.visible_message(SPAN_WARNING("[user] smashes [victim] into \the [src] face-first!"),
		SPAN_DANGER("You smash [victim] into \the [src] face-first!"))
	to_chat(victim, SPAN_DANGER("[user] smashes you into \the [src] face-first!"))
	playsound(src, 'modular_chaos/universes/bay12/sound/weapons/tablehit1.ogg', 50, TRUE)
	user.stop_pulling()
	log_attack("[key_name(user)] educated [key_name(victim)] on [src].")

/**
 * The bar sign of Bay: closed until someone with an ID card turns it to one of its pictures, each with words of its own
 */
/obj/structure/sign/double/barsign/bay
	desc = "A jumbo-sized LED sign. This one seems to be showing its age."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/barsigns.dmi'
	icon_state = "Closed"

/obj/structure/sign/double/barsign/bay/New()
	..()
	// The CM one picks a picture at random
	icon_state = initial(icon_state)

/obj/structure/sign/double/barsign/bay/get_examine_text(mob/user)
	. = ..()
	var/static/list/descriptions = list(
		"Off" = "It appears to be switched off.",
		"narsiebistro" = "It shows a picture of a large black and red being. Spooky!",
		"on" = "The lights are on, but there's no picture.",
		"empty" = "The lights are on, but there's no picture.",
		"Mess Hall - SEV Torch" = "It appears to be a red haired monk wearing a cheese costume, swinging a hoop around their thighs, holding two torches, inviting you into the mess hall.",
		"Information Action Ratio" = "It's the place to go!",
		"Three Starboard" = "It says 'Three Starboard' alongside a crude rendition of the SEV Torch- who makes this stuff?",
		"The Clowns Head" = "A rather catching portrait of what you can only presume to be the idea of a madman... A Clown Queen...",
		"The Cranky Goldfish" = "A crank-powered fish! Why hadn't you thought of that...",
		"The Cat Caller" = "An adorable neon kitty to brighten up your day.",
		"The Diplomatic Resolution" = "Here's hoping they can talk it out over beer...",
		"Dragons Hoard" = "It says 'DRAGONS HOARD'. What cunning adventurer shall swipe the hoard for themselves?",
		"Closed" = "How unfortunate...",
		"Free Drinks!" = "Yippee!",
		"We Are Open!" = "Come on in!",
		"The Meta Game" = "Big Brain Plays.",
		"Bless This Mess" = "It fills you with a snuggly wuggly sense of warmth and comfort.",
		"The Redshirt" = "Mmm... Donuts...",
		"The Singulo" = "You spin me right 'round, baby right 'round.",
	)
	. += descriptions[icon_state] || "It says '[icon_state]'"

/obj/structure/sign/double/barsign/bay/attackby(obj/item/attacking_item, mob/user)
	var/obj/item/card/id/card = attacking_item.GetID()
	if(!istype(card))
		return ..()
	if(!check_access(card))
		to_chat(user, SPAN_WARNING("Access denied."))
		return
	var/choice = tgui_input_list(user, "What would you like to change the barsign to?", "Bar Sign", icon_states(icon) - list("", "empty", "narsiebistro", "on"))
	if(!choice || choice == icon_state || !user.Adjacent(src))
		return
	icon_state = choice
	user.visible_message(SPAN_NOTICE("[user] updates \the [src]'s display with \a [card]."),
		SPAN_NOTICE("You update \the [src]'s display with \the [card]."))
