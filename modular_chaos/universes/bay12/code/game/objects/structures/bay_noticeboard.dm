//Notice boards of Baystation 12 (code/modules/persistence/noticeboards.dm in the source)

/// The most notices the sprites of a Bay notice board show
#define BAY_NOTICEBOARD_SHOWN_NOTICES 5

/**
 * A Bay notice board
 *
 * A CM notice board (pinning, reading and taking down notices as there) with the sprites of the source, which draw
 * up to five of them. The notices are not kept from round to round as there.
 */
/obj/structure/noticeboard/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/furniture/noticeboard.dmi'
	icon_state = "nboard00"

/obj/structure/noticeboard/bay/update_overlays()
	icon_state = "nboard0[min(notices, BAY_NOTICEBOARD_SHOWN_NOTICES)]"

#undef BAY_NOTICEBOARD_SHOWN_NOTICES
