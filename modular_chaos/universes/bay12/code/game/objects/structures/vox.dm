// Holy places of the Vox, built to the glory of Auralis, their creators

/obj/structure/vox_monolith
	name = "monolith of Kritiki"
	desc = "A structure built in honor and glory of Auralis, proclaiming the prophecy '𒄃𒄉𒃼𒃴𒃮𒂀'."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/vox/vox_monolith.dmi'
	icon_state = "monolith_kritika"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	anchored = TRUE

/obj/structure/vox_monolith/codex
	name = "monolith of Chakala"
	icon_state = "monolith_chakala"

/obj/structure/vox_monolith/guard
	name = "monolith of Kihikihi"
	icon_state = "monolith_kihikihi"

/// The Vox altar (/obj/structure/table/vox in Baystation 12): things can be put on it, but it can't be flipped or taken apart
/obj/structure/surface/vox_altar
	name = "the Altar of Eternity"
	desc = "A structure built in honor and glory of Auralis, proclaiming the prophecy '𒄃𒄉𒃼𒃴𒃮𒂀'."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/vox/vox_altar.dmi'
	icon_state = "altar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	throwpass = TRUE
	breakable = FALSE
	climbable = FALSE
	wrenchable = FALSE
	explo_proof = TRUE

/obj/structure/surface/vox_altar/deconstruct(disassembled = TRUE)
	return FALSE

/// The Vox lectern (/obj/structure/cult/altar/bookcasevox in Baystation 12)
/obj/structure/vox_lectern
	name = "the Lectern of Eternity"
	desc = "A structure built in honor and glory of Auralis, proclaiming the prophecy '𒄃𒄉𒃼𒃴𒃮𒂀'."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/vox/vox_altar.dmi'
	icon_state = "bookcase"
	density = TRUE
	anchored = TRUE
