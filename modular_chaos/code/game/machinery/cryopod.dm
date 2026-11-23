/**
 * Hypersleep chamber with a glass cover, ported from cmss13-pve. Its occupant is drawn lying inside it.
 */
/obj/structure/machinery/cryopod/big
	icon = 'modular_chaos/icons/obj/structures/machinery/hypersleep.dmi'
	icon_state = "hypersleep_base"
	dir = EAST
	/// Image of the occupant drawn under the cover
	var/image/occupant_image
	/// How far the occupant image is turned, in degrees
	var/occupant_angle = 270
	/// Direction the occupant image faces
	var/occupant_dir = EAST
	/// Horizontal offset of the occupant image, in pixels
	var/occupant_x = 6
	/// Vertical offset of the occupant image, in pixels
	var/occupant_y = 0

/obj/structure/machinery/cryopod/big/Initialize()
	. = ..()
	overlays += image(icon, icon_state = "cover_fog", layer = 3.22)

/obj/structure/machinery/cryopod/big/update_icon()
	return

/obj/structure/machinery/cryopod/big/go_in_cryopod(mob/living/mob, silent = FALSE)
	..()
	overlays.Cut()
	occupant_image = image(mob.appearance, loc, layer = 3.21)
	occupant_image.pixel_x = occupant_x
	occupant_image.pixel_y = occupant_y
	occupant_image.dir = occupant_dir
	if(mob.body_position == STANDING_UP)
		occupant_image.transform = occupant.transform.Turn(occupant_angle)
	overlays += occupant_image
	overlays += image(icon, icon_state = "cover", layer = 3.22)

/obj/structure/machinery/cryopod/big/go_out()
	..()
	overlays.Cut()
	occupant_image = null
	overlays += image(icon, icon_state = "cover_fog", layer = 3.22)

/obj/structure/machinery/cryopod/big/despawn_occupant()
	..()
	overlays.Cut()
	occupant_image = null
	overlays += image(icon, icon_state = "cover_fog", layer = 3.22)

/obj/structure/machinery/cryopod/big/flipped
	dir = WEST
	occupant_angle = 90
	occupant_dir = WEST
	occupant_x = 10
