//Props of Cadaab (maps/away/cadaab/ in Proxi-BoS-Bay12) and of the maps it borrows from: Castelnau, Torch and the city of Inax.
//They only look like the originals for now; the mechanics of the source (mining, ore, fence doors that lock) are not ported.

/// A rock sticking out of the ground of Shahtinsk, of a random look (/obj/structure/cadaab in the source)
/obj/structure/cadaab_stone
	name = "stone"
	desc = "You will surely burn your hand if you touch it."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "stone0"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	/// Prefix of the numbered icon states one is picked from at random on Initialize(), "[variant_prefix]0" to "[variant_prefix][variants - 1]"
	var/variant_prefix = "stone"
	/// How many numbered icon states variant_prefix has
	var/variants = 7

/obj/structure/cadaab_stone/Initialize(mapload, ...)
	. = ..()
	icon_state = "[variant_prefix][rand(0, variants - 1)]"

/// An ore deposit of a random ore (/obj/random/cadaab_minerals in the source)
/obj/structure/cadaab_stone/mineral
	name = "ore deposit"
	desc = "It certainly shouldn't stick out of the stone."
	icon_state = "stoneiron0"

/obj/structure/cadaab_stone/mineral/Initialize(mapload, ...)
	var/static/list/deposits = list(
		"ore deposit" = list("stoneiron", 8),
		"silver deposit" = list("stonesilver", 8),
		"gold deposit" = list("stonegold", 8),
		"uranium deposit" = list("stoneuran", 7),
		"phoron deposit" = list("stonephoron", 7),
	)
	name = pick(deposits)
	var/list/deposit = deposits[name]
	variant_prefix = deposit[1]
	variants = deposit[2]
	return ..()

/// A steel fence of Cadaab, climbable (/obj/structure/steelfence in the source)
/obj/structure/cadaab_fence
	name = "steel fence"
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "steelfence"
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	throwpass = TRUE
	layer = ABOVE_MOB_LAYER

/// A door in a steel fence: a hand opens and closes it
/obj/structure/cadaab_fence/door
	name = "steel fence door"
	icon_state = "fencedoor"
	climbable = FALSE

/obj/structure/cadaab_fence/door/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	density = !density
	icon_state = density ? "fencedoor" : "fencedooropen"
	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	return TRUE

/// An advertising panel of Cadaab (/obj/structure/ads in the source)
/obj/structure/cadaab_ad
	name = "IPCRUNNER 2320"
	desc = "They try to make you watch stupid movies even on the forgotten moon."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "ipcrunner"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/cadaab_ad/propaganda
	name = "Terran propaganda"
	desc = "'A TI ZAPISALSYA V DOBROVOLCI?'."
	icon_state = "tovarisch"

/obj/structure/cadaab_ad/retro
	name = "CYBER KILLER RETRO advertising panel"
	icon_state = "retro"

/// A TV set waiting for a transmission (/obj/machinery/noisetv in the source, which plays the noise of Cadaab when on)
/obj/structure/cadaab_tv
	name = "transmission center"
	desc = "A device assembled from parts found on Cadaab, waiting to receive a transmission."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "tvnoise"
	anchored = TRUE
	density = TRUE

/obj/structure/cadaab_tv/bigger
	icon_state = "tvnoise2"

/obj/structure/cadaab_tv/old
	name = "old TV"
	desc = "An old TV. You doubt that it still works."
	icon_state = "tvnoise3"

/// The vending machine of the Syndi-Pass owners (/obj/machinery/vending/syndipass in the source), without its goods for now
/obj/structure/cadaab_syndi_vendor
	name = "\improper Exclusive for Syndi-Pass Owners"
	desc = "Vending machine with products exclusively for syndi-pass owners."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "syndi-off"
	anchored = TRUE
	density = TRUE

/// A gas station of Cadaab (/obj/structure/reagent_dispensers/fueltank/cadaab in the source)
/obj/structure/cadaab_gas_station
	name = "gas station"
	desc = "There's probably still fuel left in it."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "fuel"
	anchored = TRUE
	density = TRUE

/obj/structure/cadaab_gravestone
	name = "grave stone"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "gravestone"
	anchored = TRUE
	density = TRUE

/obj/structure/cadaab_gravestone/alt
	icon_state = "gravestone2"

/// A filled grave (/obj/structure/pit/closed/cadaab in the source)
/obj/structure/cadaab_grave
	name = "grave"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "grave"
	anchored = TRUE

/obj/structure/closet/cadaab_tent
	name = "tent"
	desc = "A pretty big green tent."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props_48x48.dmi'
	icon_state = "tent"
	icon_closed = "tent"
	icon_opened = "tent_open"

/obj/structure/flora/tree/cadaab
	name = "tree"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props_48x48.dmi'
	icon_state = "tree"
	pixel_x = 0

/obj/structure/flora/tree/cadaab/cacti
	name = "cactus"
	icon_state = "cacti"

/// The flora of the jungle of Inax (/obj/structure/flora/jungle in the source): not dense, but rocks and stumps are
/obj/structure/flora/inax
	name = "bush"
	desc = "It's a living bush making you feel home. Nothing remarkable."
	icon = 'modular_chaos/universes/bay12/icons/obj/flora/jungleflora.dmi'
	icon_state = "busha"
	density = FALSE
	/// Icon states one is picked from at random on Initialize(); empty keeps icon_state
	var/list/random_states

/obj/structure/flora/inax/Initialize()
	. = ..()
	if(length(random_states))
		icon_state = pick(random_states)

/obj/structure/flora/inax/bush_a
	random_states = list("busha", "busha1", "busha2", "busha3")

/obj/structure/flora/inax/bush_b
	icon_state = "bushb"
	random_states = list("bushb", "bushb1", "bushb2", "bushb3")

/obj/structure/flora/inax/bush_c
	icon_state = "bushc"
	random_states = list("bushc", "bushc1", "bushc2", "bushc3")

/obj/structure/flora/inax/rock
	name = "rock"
	desc = "These are some nicely looking decorative rocks with some grass growing around."
	icon_state = "rock"
	random_states = list("rock", "rock1", "rock2", "rock3", "rock4", "rock5")

/obj/structure/flora/inax/large_bush
	name = "large bush"
	desc = "It's a large living bush. It makes you feel in a tropical forest rather than in orbit."
	icon = 'modular_chaos/universes/bay12/icons/obj/flora/largejungleflora.dmi'
	icon_state = "bush"
	layer = ABOVE_MOB_LAYER
	random_states = list("bush", "bush1", "bush2", "bush3")

/obj/structure/flora/inax/large_rock
	name = "large rocks"
	desc = "These are some large decorative rocks with some grass gworing around. It makes you feel cozy."
	icon = 'modular_chaos/universes/bay12/icons/obj/flora/largejungleflora.dmi'
	icon_state = "rocks"
	density = TRUE
	random_states = list("rocks", "rocks1", "rocks2", "rocks3")

/obj/structure/flora/inax/stump
	name = "tree stump"
	desc = "There used to be a tree here apparently. It's a shame someone has cut it."
	icon = 'modular_chaos/universes/bay12/icons/obj/flora/jungletree.dmi'
	icon_state = "tree_stump"
	density = TRUE
	pixel_x = -16

/obj/structure/flora/inax/stump/small
	icon = 'modular_chaos/universes/bay12/icons/obj/flora/jungletreesmall.dmi'

/// Street furniture of the city of Inax (/obj/structure/inaks_decor in the source)
/obj/structure/inaks_decor
	name = "crosswalk sign"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props_48x64.dmi'
	icon_state = "crosswalk_sign"
	anchored = TRUE
	layer = ABOVE_FLY_LAYER

/obj/structure/inaks_decor/turn_sign
	name = "road turn sign"
	icon_state = "turn_sign"

/obj/structure/inaks_decor/lamppost
	name = "lamppost"
	icon_state = "lamppost"

/// A stretch of stairs that goes nowhere (/obj/structure/fake_stairs in the source)
/obj/structure/castelnau_stairs
	name = "stairs"
	desc = "It's short section of stairs."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "strairs_single"
	anchored = TRUE
	layer = TURF_LAYER

/obj/structure/castelnau_stairs/concrete
	icon_state = "beton_stairs"

/obj/structure/castelnau_navlight
	name = "navigation light"
	desc = "It's a large and extremely bright navigation light. Its red color is indicating the port side of the vessel."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "navlight_red"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/// The starboard navigation light of a Castelnau vessel (/obj/structure/navlight_shuttle in the source)
/obj/structure/castelnau_navlight/green
	desc = "It's a large and extremely bright navigation light. Its green color is indicating the starboard side of the vessel."
	icon_state = "navlight_green"

/// A noose tied to the ceiling, without anyone in it
/obj/structure/noose
	name = "noose"
	desc = "A noose tied to the ceiling."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "noose"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/// A memorial statue of the Lordanian Sovereign Systems (/obj/structure/memstatue in the source)
/obj/structure/lordania_statue
	name = "statue stand"
	desc = "You will get here one day. Or it's just a statue honouring some piece of tile."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "placeholder"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/lordania_statue/roger
	name = "Roger Blackmore statue"
	desc = "A native of Tersten, a war hero who was head of the Tersten cell of the League of Struggle. Led the takeover of Tersten City, marched in the forefront of the rebels, blew himself up next to one of the army's military installations, posthumously a hero of the Sovereign Lordania."
	icon_state = "shahid"

/obj/structure/lordania_statue/boris
	name = "Boris Booker statue"
	desc = "Your leader and founder of the Sovereign Lordania. 'I see no point in Lordania's existence if it is not united into one strong state capable of dealing with any aggressor in the galactic arena.'"
	icon_state = "booker"

/obj/structure/lordania_statue/vasiliy
	name = "Vasiliy Petrenko statue"
	desc = "Effectively used the subjugation implants to sacrifice himself and his personnel to destroy the SCG patrol fleet in the name of sovereign Lordania. The Systems will not forget their heroes!"
	icon_state = "urod"

/obj/structure/lordania_statue/grisha
	name = "Bolshoy Grigoriy statue"
	desc = "The Hero cat. He bit the wire of an enemy artillery mount and saved the squad."
	icon_state = "grisha"

/obj/structure/lordania_statue/shmesser
	name = "Unknown warrior statue"
	desc = "This naked unknown warrior appeared out of nowhere and attacked Lordania's enemies with only a toolbox. He showed the most important trait of the Lordanian people - courage and commitment to the homeland"
	icon_state = "shmesser"

/obj/structure/lordania_statue/ambrosia
	name = "Stas Bolgarka statue"
	desc = "The most famous GCC officer of the GrigoriWald concentration camp. Killed hundreds of enemies of Lordania and ate SCG children. Retired from service due to old age, today is a member of the party 'Love your xenos'"
	icon_state = "ambrosia"

/obj/structure/lordania_banner
	name = "\improper Sovereign Lordania banner"
	desc = "A steel pole bearing a banner of Lordanian Sovereign Systems. Ave."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/lordania_banner.dmi'
	icon_state = "lordbanner"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER

/// The portrait of Boris Booker (/obj/structure/sign/booker in the source)
/obj/structure/sign/booker
	name = "\improper Lord-Protector Boris Booker portrait"
	desc = "Portrait of our bravest and smartest leader, Lord-Protector Boris Booker"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/paintings.dmi'
	icon_state = "booker"

/obj/structure/sign/lordania_seal
	name = "\improper Sovereign Lordania Seal"
	desc = "A sign which signifies who this vessel was designed in line with. Primarily used to scare away pirates, the likes of which run at the first sign of an LSS presence."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/lordania_flags.dmi'
	icon_state = "lordseal"

/obj/structure/sign/lordania_flag
	name = "Lordanian Sovereign Systems Flag"
	desc = "The flag of the Lordanian Sovereign Systems, a symbol of many things to many people."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/lordania_flags.dmi'
	icon_state = "lordflag-left"

/obj/structure/sign/lordania_flag/right
	icon_state = "lordflag-right"

/obj/structure/sign/castelnau
	name = "first aid"
	desc = "The sign indicates the location of a first aid kit."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/props.dmi'
	icon_state = "firstaid_sign"

/obj/structure/sign/castelnau/height_scale
	name = "height scale"
	desc = "Say 'cheese'!"
	icon_state = "height_scale"

/// A poster of the BoS layer of Proxi-BoS-Bay12 (/obj/structure/sign/poster/antar in the source)
/obj/structure/sign/bos_poster
	name = "Safety"
	desc = "A large piece of cheap printed paper."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/wall_decorations/posters.dmi'
	icon_state = "safety"

/obj/structure/sign/bos_poster/vo_slavu
	name = "Red poster"
	icon_state = "vo_slavu"

/obj/structure/sign/bos_poster/ciga
	name = "Cigarette"
	icon_state = "ciga"

/obj/structure/sign/bos_poster/gloves
	name = "Wear gloves"
	icon_state = "gloves"

/obj/structure/sign/bos_poster/anatomy
	name = "Human anatomy"
	icon_state = "anatomy_s_erisa"

/obj/structure/sign/bos_poster/corparmy_teared
	name = "Corporate Army"
	icon_state = "corparmy_teared"

/obj/structure/sign/bos_poster/kadaab
	name = "Kadaab"
	icon_state = "kadaab"

/obj/structure/sign/bos_poster/gkkarmy
	name = "Militaristic poster"
	icon_state = "armii_gkk_slava"

/obj/structure/sign/bos_poster/smertpss
	name = "Death to Sol"
	icon_state = "smert_pss"

/obj/structure/sign/bos_poster/mine
	name = "Opasno"
	icon_state = "opasno"
