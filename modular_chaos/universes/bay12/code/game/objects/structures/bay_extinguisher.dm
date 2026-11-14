//Extinguisher cabinets of Baystation 12 (code/game/objects/structures/extinguisher.dm in the source)

/**
 * A Bay extinguisher cabinet
 *
 * A CM extinguisher cabinet (opened, emptied and filled as there) with the sprites of the source. It holds a CM
 * extinguisher until the extinguishers of the source are ported.
 */
/obj/structure/extinguisher_cabinet/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/extinguisher.dmi'
	icon_state = "extinguisher_closed"

// Mapped closed, under the state of a closed cabinet, which CM cabinets name after their base
/obj/structure/extinguisher_cabinet/bay/Initialize()
	. = ..()
	base_icon = "extinguisher"
