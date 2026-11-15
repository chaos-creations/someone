//Crematoria of Baystation 12 (code/game/objects/structures/morgue.dm in the source)
// Bay morgues are CM's, which have the same sprites.

/**
 * A Bay crematorium
 *
 * A CM crematorium (opened, loaded and set off by its igniter as there) with the sprites of the source.
 */
/obj/structure/morgue/crematorium/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/crematorium.dmi'
	tray_path = /obj/structure/morgue_tray/crematorium/bay

/// The tray of a Bay crematorium, which the sprites of the source draw clean however bloody it is
/obj/structure/morgue_tray/crematorium/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/crematorium.dmi'

/obj/structure/morgue_tray/crematorium/bay/update_icon()
	icon_state = icon_tray

/**
 * The igniter of a Bay crematorium, a CM one on a button of the source
 *
 * Bay access is not ported yet, so it is open to everyone.
 */
/obj/structure/machinery/crema_switch/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/buttons.dmi'
	icon_state = "blastctrl"
	req_access = null
