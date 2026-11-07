/**
 * Storage module, a compartment that makes its rig a backpack
 *
 * A click on the worn rig opens it, items used on the worn rig go into it, and dragging the rig onto oneself opens it
 * too. A rig holds one at most. Out of a rig, it is a box of its own: a click on it in a hand opens it.
 *
 * Every rig comes with the smallest one; the bigger ones replace it.
 */
/obj/item/rig_module/storage
	name = "hardsuit storage pouches"
	desc = "A few small pouches built into a hardsuit control module. Enough for the essentials."
	interface_name = "storage pouches"
	interface_desc = "A small storage compartment built into the control module, accessed by a click on the worn suit."
	usable = TRUE
	w_class = SIZE_LARGE

	/// The storage it holds things in
	var/obj/item/storage/internal/container
	/// Types of items it holds, or empty for any; see /obj/item/storage/var/can_hold
	var/list/can_hold = list()
	/// Types of items it doesn't hold; see /obj/item/storage/var/cant_hold
	var/list/cant_hold = list(/obj/item/rig, /obj/item/rig_module/storage)
	/// Biggest weight class of the items it holds
	var/max_w_class = SIZE_SMALL
	/// Total storage space of its items, see /obj/item/storage/var/max_storage_space
	var/max_storage_space = 6

/obj/item/rig_module/storage/Initialize(mapload, ...)
	. = ..()
	container = new(src)
	container.can_hold = can_hold.Copy()
	container.cant_hold = cant_hold.Copy()
	container.max_w_class = max_w_class
	container.max_storage_space = max_storage_space
	container.storage_slots = null

/obj/item/rig_module/storage/Destroy()
	QDEL_NULL(container)
	return ..()

/// Closes the storage for everyone looking into it
/obj/item/rig_module/storage/proc/close_container()
	for(var/mob/watcher as anything in LAZYCOPY(container.content_watchers))
		container.storage_close(watcher)

/obj/item/rig_module/storage/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("It holds items up to [max_w_class >= SIZE_MEDIUM ? "medium" : "small"] size, [max_storage_space] storage space in all.")

/obj/item/rig_module/storage/get_install_problem(obj/item/rig/rig)
	if(rig.storage)
		return "[rig] already has [rig.storage]; take it out first."
	return null

/obj/item/rig_module/storage/installed(obj/item/rig/new_holder)
	. = ..()
	holder.storage = src
	container.master_object = holder
	container.name = holder.name

/obj/item/rig_module/storage/removed()
	close_container()
	if(holder?.storage == src)
		holder.storage = null
	container.master_object = src
	container.name = name
	return ..()

/obj/item/rig_module/storage/on_wearer_cleared()
	close_container()

// Opening a pocket needs no power
/obj/item/rig_module/storage/use_module()
	if(!holder?.wearer)
		return RIG_MODULE_USE_FAILED
	container.open(holder.wearer)
	return RIG_MODULE_USE_DONE

/obj/item/rig_module/storage/attack_hand(mob/user, mods)
	if(loc == user)
		container.open(user)
		return
	close_container()
	return ..()

/obj/item/rig_module/storage/attackby(obj/item/attacking_item, mob/user)
	if(loc == user)
		return container.attackby(attacking_item, user)
	return ..()

/obj/item/rig_module/storage/MouseDrop(obj/over_object)
	if(container.handle_mousedrop(usr, over_object))
		return ..()

/obj/item/rig_module/storage/standard
	name = "hardsuit storage system"
	desc = "A series of straps, pouches and internal modifications for a hardsuit. Has space for quite a few items, though it's a bit bulky and awkward."
	interface_name = "storage compartment"
	interface_desc = "A storage compartment built directly into the control module, about as big as a satchel."
	max_w_class = SIZE_MEDIUM
	max_storage_space = 15

/obj/item/rig_module/storage/large
	name = "hardsuit distributed storage system"
	desc = "A series of straps, pouches and internal modifications for a hardsuit. This model is distributed across the whole body, and holds as much as a backpack."
	interface_name = "distributed storage"
	interface_desc = "A system of storage compartments spread across the whole suit, about as big as a backpack."
	max_w_class = SIZE_MEDIUM
	max_storage_space = 21

/obj/item/rig_module/storage/medical
	name = "hardsuit medical storage system"
	desc = "A series of straps, pouches and internal modifications for a hardsuit. Primarily designed to hold medical supplies."
	interface_name = "medical storage"
	interface_desc = "A storage compartment built into the control module, fitted for medical supplies."
	max_w_class = SIZE_MEDIUM
	max_storage_space = 21
	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/stack/medical,
		/obj/item/stack/nanopaste,
		/obj/item/reagent_container/hypospray,
		/obj/item/reagent_container/syringe,
		/obj/item/reagent_container/pill,
		/obj/item/reagent_container/glass/bottle,
		/obj/item/reagent_container/glass/beaker,
		/obj/item/reagent_container/blood,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/tool/surgery,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/device/flashlight/pen,
		/obj/item/bodybag,
	)

/obj/item/rig_module/storage/combat
	name = "hardsuit tactical storage system"
	desc = "A series of straps, pouches and internal modifications for a hardsuit. Designed to accommodate magazines, grenades and power cells."
	interface_name = "tactical storage"
	interface_desc = "A storage compartment built into the control module, fitted for ammunition, grenades and cells."
	max_w_class = SIZE_MEDIUM
	max_storage_space = 21
	can_hold = list(
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/cell,
		/obj/item/device/flashlight/flare,
	)
