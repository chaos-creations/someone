/**
 * Gun rack, ported from cmss13-pve: holds up to [/obj/structure/gun_rack/var/max_stored] guns of one type and shows how many are left.
 *
 * Click it with a fitting gun to rack it, click it with an empty hand to take the last racked gun.
 */
/obj/structure/gun_rack
	name = "gun rack"
	desc = "ARMAT-produced gun rack for storage of long guns. While initial model was supposed to be extremely modifiable, USCM comissioned racks with fixed slots which only fit M41A rifles. Some say they were cheaper, and some say the main reason was marine's ability to easily break anything more complex than a tungsten ball."
	icon = 'modular_chaos/icons/obj/structures/gun_racks.dmi'
	icon_state = "m41a"
	density = TRUE
	/// Gun type (and its subtypes) the rack takes. Null for a rack that holds nothing
	var/allowed_type
	/// Gun type the rack starts filled with
	var/populate_type
	/// Whether the starting guns spawn without ammunition
	var/populate_empty = FALSE
	/// Most guns the rack holds; the icon has a state for every count up to it
	var/max_stored = 5
	/// Guns the rack starts with
	var/initial_stored = 5

/obj/structure/gun_rack/Initialize()
	. = ..()
	if(!allowed_type)
		icon_state = "[initial(icon_state)]_0"
		return

	for(var/i in 1 to initial_stored)
		new populate_type(src, populate_empty)
	update_icon()

/obj/structure/gun_rack/attackby(obj/item/item, mob/user)
	if(istype(item, allowed_type) && length(contents) < max_stored)
		user.drop_inv_item_to_loc(item, src)
		update_icon()
		return
	return ..()

/obj/structure/gun_rack/attack_hand(mob/living/user)
	if(!length(contents))
		to_chat(user, SPAN_WARNING("[src] is empty."))
		return

	var/obj/stored_obj = contents[length(contents)]
	user.put_in_hands(stored_obj)
	to_chat(user, SPAN_NOTICE("You grab [stored_obj] from [src]."))
	playsound(src, "gunequip", 25, TRUE)
	update_icon()

/obj/structure/gun_rack/update_icon()
	icon_state = "[initial(icon_state)]_[length(contents)]"

/obj/structure/gun_rack/m41
	allowed_type = /obj/item/weapon/gun/rifle/m41aMK1
	populate_type = /obj/item/weapon/gun/rifle/m41aMK1

/obj/structure/gun_rack/m41/unloaded
	populate_empty = TRUE

/obj/structure/gun_rack/m41/empty
	initial_stored = 0

/obj/structure/gun_rack/m41/recon
	icon_state = "m41arecon"
	populate_type = /obj/item/weapon/gun/rifle/m41aMK1/forecon

/obj/structure/gun_rack/m41/recon/unloaded
	populate_empty = TRUE

/obj/structure/gun_rack/type71
	icon_state = "type71"
	desc = "Some off-branded gun rack. Per SOF and UPPA regulations, weapons should be stored in secure safes and only given out when necessary. Of course, most (but not all!) units overlook this regulation, only storing their firearms in safes when inspection arrives."
	max_stored = 6
	initial_stored = 6
	allowed_type = /obj/item/weapon/gun/rifle/type71
	populate_type = /obj/item/weapon/gun/rifle/type71

/obj/structure/gun_rack/type71/unloaded
	populate_empty = TRUE

/obj/structure/gun_rack/type71/empty
	initial_stored = 0

/obj/structure/gun_rack/flamer
	name = "M240A1 incinerator rack"
	icon_state = "m240"
	desc = "ARMAT-produced gun rack for storage of long guns. While initial model was supposed to be extremely modifiable, USCM comissioned racks with fixed slots which only fit M240A1 incinerators. Some say they were cheaper, and some say the main reason was marine's ability to easily break anything more complex than a tungsten ball."
	max_stored = 2
	initial_stored = 2
	allowed_type = /obj/item/weapon/gun/flamer/m240
	populate_type = /obj/item/weapon/gun/flamer/m240

/obj/structure/gun_rack/flamer/unloaded
	populate_empty = TRUE

/obj/structure/gun_rack/flamer/empty
	initial_stored = 0

/obj/structure/gun_rack/mk221
	name = "M120 shotgun rack"
	icon_state = "mk221"
	desc = "ARMAT-produced gun rack for storage of long guns. While initial model was supposed to be extremely modifiable, USCM comissioned racks with fixed slots which only fit M120 tactical shotguns. Some say they were cheaper, and some say the main reason was marine's ability to easily break anything more complex than a tungsten ball."
	max_stored = 2
	initial_stored = 2
	allowed_type = /obj/item/weapon/gun/shotgun/combat
	populate_type = /obj/item/weapon/gun/shotgun/combat

/obj/structure/gun_rack/mk221/empty
	initial_stored = 0

/obj/structure/gun_rack/m20a
	name = "M20A pulse rifle rack"
	icon_state = "m20a"
	allowed_type = /obj/item/weapon/gun/rifle/m20a
	populate_type = /obj/item/weapon/gun/rifle/m20a

/obj/structure/gun_rack/m20a/unloaded
	populate_empty = TRUE

/obj/structure/gun_rack/m20a/empty
	initial_stored = 0

/obj/structure/gun_rack/nsg
	name = "NSG L23A1 pulse rifle rack"
	icon_state = "nsg"
	desc = "ARMAT-produced gun rack for storage of long guns. This one is configured to hold up to five L23A1 pulse rifles."
	allowed_type = /obj/item/weapon/gun/rifle/nsg23
	populate_type = /obj/item/weapon/gun/rifle/nsg23

/obj/structure/gun_rack/nsg/unloaded
	populate_empty = TRUE

/obj/structure/gun_rack/nsg/empty
	initial_stored = 0
