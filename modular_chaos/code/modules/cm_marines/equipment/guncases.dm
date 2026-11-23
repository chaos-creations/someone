// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/storage/box/guncase/heavy
	name = "heavy gun case"
	desc = "You shouldn't be seeing this."
	icon_state = null
	use_sound = "toolbox"
	var/move_delay_mult = 2

/obj/item/storage/box/guncase/heavy/pickup(mob/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY, PROC_REF(handle_movedelay))

/obj/item/storage/box/guncase/heavy/proc/handle_movedelay(mob/user, list/movedata)
	SIGNAL_HANDLER
	if(locate(/obj/item/storage/box/guncase/heavy) in user.contents)
		movedata["move_delay"] += move_delay_mult

/obj/item/storage/box/guncase/heavy/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY)

/obj/item/storage/box/guncase/heavy/m4ra_pve
	icon = 'modular_chaos/icons/obj/items/storage/kits.dmi'
	name = "\improper M4RA-A6 battle rifle case"
	desc = "A large case for storing an M4RA-A6, a modified USCM battle rifle capable of firing the brutal A19 depleted uranium bullets."
	icon_state = "r2case"
	storage_slots = 8
	can_hold = list(/obj/item/weapon/gun/rifle/m4ra/pve, /obj/item/ammo_magazine/rifle/m4ra/custom, /obj/item/ammo_magazine/rifle/m4ra/custom/impact, /obj/item/ammo_magazine/rifle/m4ra/custom/incendiary, /obj/item/ammo_magazine/rifle/m4ra/custom/pve)

/obj/item/storage/box/guncase/heavy/m4ra_pve/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/m4ra/pve(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom/pve(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom/pve(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom/impact(src)
	new /obj/item/ammo_magazine/rifle/m4ra/custom/incendiary(src)

/obj/item/storage/box/guncase/heavy/m4ra_pve/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(src.icon, "bigcase_lid_open")
	else
		overlays += image(src.icon, "r2case_lid")
		return
	if(locate(/obj/item/weapon/gun/rifle/m4ra/pve) in src.contents)
		overlays += image(src.icon, "+r2")

/obj/item/storage/box/guncase/heavy/hpr
	icon = 'modular_chaos/icons/obj/items/storage/kits.dmi'
	name = "\improper M41AE2 heavy pulse rifle case"
	desc = "A case storing an M41AE2 heavy pulse rifle, a heavier variant of the M41A designed for sustained automatic fire."
	icon_state = "hprcase"
	storage_slots = 3
	can_hold = list(/obj/item/weapon/gun/rifle/lmg, /obj/item/ammo_magazine/rifle/lmg)
	/// Overlay icon_state of the rifle lying in the open case
	var/gun_overlay_state = "+m41ae2"

/obj/item/storage/box/guncase/heavy/hpr/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/lmg(src)
	new /obj/item/ammo_magazine/rifle/lmg(src)
	new /obj/item/ammo_magazine/rifle/lmg(src)

/obj/item/storage/box/guncase/heavy/hpr/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(src.icon, "bigcase_lid_open")
	else
		overlays += image(src.icon, "hprcase_lid")
		return
	if(locate(/obj/item/weapon/gun/rifle/lmg) in contents)
		overlays += image(src.icon, gun_overlay_state)

/obj/item/storage/box/guncase/heavy/hpr/recon
	gun_overlay_state = "+m41ae2_recon"
	storage_slots = 4
	can_hold = list(/obj/item/weapon/gun/rifle/lmg, /obj/item/ammo_magazine/rifle/lmg, /obj/item/attachable/bipod/m41ae2/recon)

/obj/item/storage/box/guncase/heavy/hpr/recon/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/lmg/recon(src)
	new /obj/item/ammo_magazine/rifle/lmg/recon(src)
	new /obj/item/ammo_magazine/rifle/lmg/recon(src)
	new /obj/item/attachable/bipod/m41ae2/recon(src) // swaps with the vertical grip, both take the under rail

/obj/item/storage/box/guncase/heavy/motiondetectors
	icon = 'modular_chaos/icons/obj/items/storage/kits.dmi'
	name = "\improper motion detectors case"
	desc = "A case containing four individual handheld motion detectors."
	icon_state = "mdcase"
	storage_slots = 4
	can_hold = list(/obj/item/device/motiondetector)

/obj/item/storage/box/guncase/heavy/motiondetectors/fill_preset_inventory()
	new /obj/item/device/motiondetector(src)
	new /obj/item/device/motiondetector(src)
	new /obj/item/device/motiondetector(src)
	new /obj/item/device/motiondetector(src)

/obj/item/storage/box/guncase/heavy/motiondetectors/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(icon, "case_lid_open")
	else
		overlays += image(icon, "mdcase_lid")
		return

	if(length(contents) >= storage_slots)
		var/image/source_image = image(icon, "+md")
		source_image.pixel_x = 0
		overlays += source_image
	if(length(contents) >= storage_slots * 0.75)
		var/image/source_image = image(icon, "+md")
		source_image.pixel_x = 6
		overlays += source_image
	if(length(contents) >= storage_slots * 0.5)
		var/image/source_image = image(icon, "+md")
		source_image.pixel_x = 12
		overlays += source_image
	if(length(contents) >= storage_slots * 0.25)
		var/image/source_image = image(src.icon, "+md")
		source_image.pixel_x = 18
		overlays += source_image

/obj/item/storage/box/guncase/heavy/fuel
	icon = 'modular_chaos/icons/obj/items/storage/kits.dmi'
	name = "\improper M240A1 fuel canister case"
	desc = "A heavy case containing six fuel canisters for the M240A1 incinerator unit."
	icon_state = "fuelcase"
	storage_slots = 6
	can_hold = list(/obj/item/ammo_magazine/flamer_tank)

/obj/item/storage/box/guncase/heavy/fuel/fill_preset_inventory()
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)

/obj/item/storage/box/guncase/heavy/fuel/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(icon, "bigcase_lid_open")
	else
		overlays += image(icon, "fuelcase_lid")
		return
	var/tank_tally = 0
	for(var/obj/item/ammo_magazine/flamer_tank/tank in contents)
		tank_tally++
		if(tank_tally > initial(storage_slots))
			return
		if(istype(tank, /obj/item/ammo_magazine/flamer_tank))
			if(tank_tally <= 3)
				var/image/source_image = image(icon, "+fuel_bottom")
				source_image.pixel_x = tank_tally*8-8
				overlays += source_image
			else
				var/image/source_image = image(icon, "+fuel")
				source_image.pixel_x = tank_tally*8-8-(24)
				overlays += source_image
