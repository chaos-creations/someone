/**
 * M40 HEDP grenade box, ported from cmss13-pve. Deploys onto the floor like a magazine box and hands out one grenade at a time.
 *
 * Fire makes the grenades inside cook off after a delay instead of burning the box away. Upstream ammo boxes only know
 * magazines, so the grenade handling lives on this type and on /obj/structure/magazine_box/nade_box.
 */
/obj/item/ammo_box/magazine/nade_box
	name = "\improper M40 HEDP grenade box"
	desc = "A secure box holding 25 M40 High-Explosive Dual-Purpose grenades. Highly explosive, don't store near the flamer fuel."
	icon = 'modular_chaos/icons/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	icon_state = "base_uscm_nade"
	w_class = SIZE_LARGE
	num_of_magazines = 25 //Scuffed, but it saves making new examination procs
	magazine_type = /obj/item/explosive/grenade/high_explosive
	overlay_ammo_type = null
	overlay_gun_type = null
	overlay_content = null
	icon_state_deployed = null
	empty = FALSE
	can_explode = TRUE
	burning = FALSE
	limit_per_tile = 1 //how many you can deploy per tile
	flames_icon = 'modular_chaos/icons/obj/items/weapons/guns/ammo_boxes/misc.dmi'
	/// Grenade types besides magazine_type that can be put in
	var/list/allowed_magazines = list(/obj/item/explosive/grenade/high_explosive)
	/// State of the model text printed on the box, in grenade_text_markings_icon
	var/overlay_model_type = "model_m40"
	/// State of the colour stripe of the grenade type, in grenade_text_markings_icon
	var/overlay_icon_type = "hedp"
	/// State of the grenades seen in the open box, in /obj/structure/magazine_box/nade_box/var/grenades_icon
	var/overlay_grenade_type = "hedp"
	/// Icon with the model texts and colour stripes
	var/grenade_text_markings_icon = 'icons/obj/items/storage/packets.dmi'

/obj/item/ammo_box/magazine/nade_box/update_icon()
	if(overlays)
		overlays.Cut()
	if(!icon_state_deployed) // The lid is on the sprite already.
		overlays += image(icon, icon_state = "[icon_state]_lid") //adding lid
	if(overlay_model_type)
		overlays += image(grenade_text_markings_icon, icon_state = "[overlay_model_type]") //adding text
	if(overlay_icon_type)
		overlays += image(grenade_text_markings_icon, icon_state = "[overlay_icon_type]") //adding color stripes

/obj/item/ammo_box/magazine/nade_box/get_examine_text(mob/living/user)
	. = ..()
	if(burning)
		. += SPAN_DANGER("It's on fire and the grenades inside might explode at any time!")

/obj/item/ammo_box/magazine/nade_box/deploy_ammo_box(mob/living/user, turf/T)
	if(burning)
		to_chat(user, SPAN_DANGER("It's on fire and the grenades inside might explode at any time!"))
		return

	var/obj/structure/magazine_box/nade_box/deployed_box = new(T)
	deployed_box.icon_state = icon_state_deployed ? icon_state_deployed : icon_state
	deployed_box.name = name
	deployed_box.desc = desc
	deployed_box.boom_box = src
	deployed_box.update_icon()
	user.drop_inv_item_on_ground(src)
	Move(deployed_box)

/obj/item/ammo_box/magazine/nade_box/afterattack(atom/target, mob/living/user, proximity)
	if(burning)
		to_chat(user, SPAN_DANGER("It's on fire and the grenades inside might explode at any time!"))
		return
	if(!proximity)
		return
	if(isturf(target))
		var/turf/target_turf = target
		if(!target_turf.density)
			deploy_ammo_box(user, target_turf)

/obj/item/ammo_box/magazine/nade_box/flamer_fire_act(damage, datum/cause_data/flame_cause_data)
	if(burning)
		return
	burning = TRUE
	process_burning(flame_cause_data)

/// Returns how hard the grenades inside go off when they cook off: just a few cause a detonation, lots nuke it all in one go
/obj/item/ammo_box/magazine/nade_box/proc/get_nade_severity()
	var/severity = 0
	for(var/obj/item/explosive/grenade/nade in contents)
		severity += length(contents)
	return floor(severity / 280)

/obj/item/ammo_box/magazine/nade_box/process_burning(datum/cause_data/flame_cause_data)
	var/obj/structure/magazine_box/host_box
	if(istype(loc, /obj/structure/magazine_box))
		host_box = loc
	var/severity = get_nade_severity()
	if(severity > 0)
		handle_side_effects(host_box, TRUE)
		addtimer(CALLBACK(src, PROC_REF(explode), severity, flame_cause_data), 8 SECONDS) // Gives everyone around a chance to run
		return
	handle_side_effects(host_box)
	//need to make sure we delete the structure box if it exists, it will handle the deletion of ammo box inside
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), (host_box ? host_box : src)), 5 SECONDS)

/obj/item/ammo_box/magazine/nade_box/handle_side_effects(obj/structure/magazine_box/host_box, will_explode = FALSE)
	var/atom/burning_atom = host_box ? host_box : src
	if(host_box)
		host_box.apply_fire_overlay(will_explode)
	else
		apply_fire_overlay(will_explode)
	burning_atom.set_light(5)
	burning_atom.visible_message(SPAN_HIGHDANGER("\The [src] catches on fire and grenades begin cooking off! Duck and cover!"))

/obj/item/ammo_box/magazine/nade_box/apply_fire_overlay(will_explode = FALSE)
	. = ..()
	overlays += image(flames_icon, icon_state = "on_fire_grenade_overlay")

/// Deployed grenade box: grenades go in and come out one at a time, of the box's own grenade types only
/obj/structure/magazine_box/nade_box
	name = "\improper grenade box"
	desc = "A generic grenade box. If you're seeing this, something went wrong and you should contact a GM about it."
	icon = 'modular_chaos/icons/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	icon_state = "base_uscm_nade"
	limit_per_tile = 1
	flames_icon = 'modular_chaos/icons/obj/items/weapons/guns/ammo_boxes/misc.dmi'
	/// The folded grenade box inside, which holds the grenades
	var/obj/item/ammo_box/magazine/nade_box/boom_box
	/// Icon with the grenades seen in the open box
	var/grenades_icon = 'modular_chaos/icons/obj/items/weapons/guns/ammo_boxes/grenades.dmi'

/obj/structure/magazine_box/nade_box/Destroy()
	QDEL_NULL(boom_box)
	return ..()

/obj/structure/magazine_box/nade_box/update_icon()
	if(overlays)
		overlays.Cut()
	if(!boom_box)
		return
	if(length(boom_box.contents) >= (boom_box.num_of_magazines * 0.5))
		overlays += image(grenades_icon, icon_state = "[boom_box.overlay_grenade_type]")
	else if(length(boom_box.contents) > (boom_box.num_of_magazines * 0.125))
		overlays += image(grenades_icon, icon_state = "[boom_box.overlay_grenade_type]_1")

/obj/structure/magazine_box/nade_box/get_examine_text(mob/user)
	. = list(desc)
	if(boom_box)
		. += SPAN_INFO("It holds [length(boom_box.contents)] grenades out of [boom_box.num_of_magazines].")
	if(burning)
		. += SPAN_DANGER("It's on fire and the grenades inside might explode at any time!")

/obj/structure/magazine_box/nade_box/MouseDrop(over_object, src_location, over_location)
	if(over_object != usr || !Adjacent(usr) || !ishuman(usr))
		return
	if(burning)
		to_chat(usr, SPAN_DANGER("It's on fire and the grenades inside might explode at any time!"))
		return
	visible_message(SPAN_NOTICE("[usr] picks up the [name]."))
	usr.put_in_hands(boom_box)
	boom_box = null
	qdel(src)

/obj/structure/magazine_box/nade_box/attack_hand(mob/living/user)
	if(burning)
		to_chat(user, SPAN_DANGER("It's on fire and the grenades inside might explode at any time!"))
		return
	if(!length(boom_box.contents))
		to_chat(user, SPAN_NOTICE("\The [src] is empty."))
		return
	var/obj/item/explosive/grenade/nade = pick(boom_box.contents)
	user.put_in_hands(nade)
	to_chat(user, SPAN_NOTICE("You retrieve \a [nade] from \the [src]."))
	update_icon()

/obj/structure/magazine_box/nade_box/attackby(obj/item/W, mob/living/user)
	if(burning)
		to_chat(user, SPAN_DANGER("It's on fire and the grenades inside might explode at any time!"))
		return
	if(!istypestrict(W, boom_box.magazine_type) && !is_type_in_list(W, boom_box.allowed_magazines))
		to_chat(user, SPAN_WARNING("You don't want to mix different grenades in one box."))
		return
	var/obj/item/explosive/grenade/nade = W
	if(nade.active)
		to_chat(user, SPAN_WARNING("[W] is armed! Don't be stupid!"))
		return
	if(length(boom_box.contents) >= boom_box.num_of_magazines)
		to_chat(user, SPAN_WARNING("[src] is full."))
		return
	user.drop_inv_item_to_loc(W, boom_box)
	to_chat(user, SPAN_NOTICE("You put \a [W] into [src]"))
	update_icon()

/obj/structure/magazine_box/nade_box/flamer_fire_act(damage, datum/cause_data/flame_cause_data)
	if(burning || !boom_box)
		return
	burning = TRUE
	boom_box.flamer_fire_act(damage, flame_cause_data)
