// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/// Most smartgun drums the M802 rig holds
#define MAXIMUM_MAGAZINE_COUNT 2

/obj/item/storage/belt/gun/smartgunner/garrow
	name = "\improper M802 pattern smartgunner sidearm rig"
	desc = "The M802 is a limited-issue mark of USCM load-bearing equipment, designed to carry a limited quantity of smartgun and pistol ammunition, along with a sidearm."
	icon_state = "sgbelt"

	//Keep a track of how many magazines are inside the belt.
	var/magazines = 0

/obj/item/storage/belt/gun/smartgunner/garrow/can_be_inserted(obj/item/item, mob/user, stop_messages = FALSE)
	. = ..()
	if(magazines >= MAXIMUM_MAGAZINE_COUNT && istype(item, /obj/item/ammo_magazine/smartgun))
		if(!stop_messages)
			to_chat(usr, SPAN_WARNING("[src] can't hold any more drums."))
		return FALSE

/obj/item/storage/belt/gun/smartgunner/garrow/handle_item_insertion(obj/item/item, prevent_warning = FALSE, mob/user)
	. = ..()
	if(istype(item, /obj/item/ammo_magazine/smartgun))
		magazines++

/obj/item/storage/belt/gun/smartgunner/garrow/remove_from_storage(obj/item/item as obj, atom/new_location)
	. = ..()
	if(istype(item, /obj/item/ammo_magazine/smartgun))
		magazines--

/obj/item/storage/belt/gun/smartgunner/garrow/on_stored_atom_del(atom/movable/item)
	if(istype(item, /obj/item/ammo_magazine/smartgun))
		magazines--

#undef MAXIMUM_MAGAZINE_COUNT

// Marine gear that keeps its jungle look on every map, as the FORECON platoon vendors stock it (from cmss13-pve)

/obj/item/storage/belt/marine/standard
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN

/obj/item/storage/belt/gun/m4a3/standard
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN

/obj/item/storage/belt/medical/lifesaver/standard
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN

/obj/item/storage/belt/medical/lifesaver/standard/full/fill_preset_inventory()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexalinp(src)
	new /obj/item/reagent_container/hypospray/autoinjector/oxycodone(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/antitox(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/peridaxon(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_container/hypospray/autoinjector/iron(src)

/// Medical belt holding just the Health Diagnostic Equipment
/obj/item/storage/belt/medical/only_scanner/fill_preset_inventory()
	new /obj/item/device/healthanalyzer/soul(src)
