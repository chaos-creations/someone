//Filing cabinets of Baystation 12 (code/modules/paperwork/filingcabinet.dm in the source)

/**
 * A Bay filing cabinet
 *
 * A CM filing cabinet (what it holds, and how, as there) with the sprites of the source.
 */
/obj/structure/filingcabinet/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/furniture/drawers.dmi'

/obj/structure/filingcabinet/bay/chestdrawer
	name = "chest drawer"
	icon_state = FILING_CABINET_CHEST
	cabinet_type = FILING_CABINET_CHEST

/// A Bay filing cabinet set into a wall
/obj/structure/filingcabinet/bay/wallcabinet
	name = "wall-mounted filing cabinet"
	desc = "A filing cabinet installed into a cavity in the wall to save space. Wow!"
	icon_state = "wallcabinet"
	cabinet_type = "wallcabinet"
	density = FALSE

/obj/structure/filingcabinet/bay/filingcabinet
	icon_state = FILING_CABINET_TALL
	cabinet_type = FILING_CABINET_TALL
