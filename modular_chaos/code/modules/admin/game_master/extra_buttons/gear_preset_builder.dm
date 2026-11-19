/// Gear preset builders of admins, as list(ckey = /datum/gear_preset_builder), kept for the round so closing the window keeps the work
GLOBAL_LIST_EMPTY(gear_preset_builders)

/// Most characters of an item description shown in the picker
#define GEAR_BUILDER_DESC_LENGTH 300
/// Most parts an imported JSON can be sent in
#define GEAR_BUILDER_IMPORT_MAX_PARTS 50
/// Folder the export is written to before it is sent to the client
#define GEAR_BUILDER_EXPORT_FOLDER "data/gear_preset_export/"

/// Opens the gear preset builder of this admin, see [/datum/gear_preset_builder]
/client/proc/open_gear_preset_builder()
	set name = "Gear Preset Builder"
	set category = "Game Master.Extras"
	if(!check_rights(R_ADMIN))
		return

	var/datum/gear_preset_builder/builder = GLOB.gear_preset_builders[ckey]
	if(QDELETED(builder))
		builder = new
		GLOB.gear_preset_builders[ckey] = builder
	builder.tgui_interact(mob)

/**
 * Lets an admin put together a gear preset in the round from any item in the build
 *
 * The gear is worn by a real mannequin mob in nullspace. Clicking a slot, a storage or the accessories of an item opens
 * a picker with the item types that fit there, found from their type vars without creating them, and picking one puts
 * a new item there through the game's own checks. The result is exported as JSON with the `load_gear()` code of an
 * equipment preset, and can be imported back or spawned on a mob.
 *
 * Gear is described by item trees: list("type" = path, "accessories" = list(trees), "contents" = list(list(trees) per container)).
 * A tree without "accessories" or "contents" keeps what the item spawns with there; with them, the item has exactly that.
 * "edited" = TRUE marks an item whose accessories or contents were changed in the builder, which is how the export tells
 * a changed item from an untouched one for types that spawn with random contents (MREs).
 */
/datum/gear_preset_builder
	/// The mannequin wearing the gear
	var/mob/living/carbon/human/dummy/mannequin
	/// Picture of the mannequin for the window, as base64 PNG, redrawn when preview_outdated is set
	var/preview_image
	/// Size of preview_image in pixels, as list(width, height): larger than a tile when an overlay sticks out of it, centered on the mannequin
	var/list/preview_size
	/// Whether the gear or the facing changed since preview_image was drawn
	var/preview_outdated = TRUE
	/// What the item picker is open for, as list("kind" = "slot", "container" or "accessory", "target" = slot or ref), or null while it is closed
	var/list/picker
	/// Indexes into the catalog of the entries that fit where the picker is open, counted from 0 for the window
	var/list/picker_items = list()
	/// Result of the last action, shown in the window
	var/message
	/// Whether message reports a failure
	var/message_is_error = FALSE
	/// Name of the preset in the exported code
	var/preset_name = "Custom Preset"
	/// Type path of the preset in the exported code, below /datum/equipment_preset/
	var/preset_path = "custom/preset"
	/// Exported JSON, shown in the window while it is set
	var/export_json
	/// Exported code, shown in the window while export_json is set
	var/export_code
	/// Whether the export carries the mannequin's appearance, see get_appearance()
	var/custom_appearance = FALSE
	/// Parts of the JSON being imported received so far, see the "import" action
	var/list/import_parts
	/// Refs of the mannequin's items whose accessories or contents were changed in the builder, as list(ref = TRUE)
	var/list/edited_refs = list()

	/// Every item type that can be picked, as a list of list("path", "slots", "w_class", "cost", "nodrop")
	var/static/list/catalog
	/// Window data of the catalog entries, in the same order
	var/static/list/catalog_data
	/// Skin colors of species that do not use the human ones, as list(species name = list of skin colors)
	var/static/list/species_skin_colors = list(
		SPECIES_YAUTJA = PRED_SKIN_COLOR,
	)
	/// Item types that are not gear and cannot be picked or imported
	var/static/list/excluded_types = list(
		// Lives in the clothing it belongs to
		/obj/item/storage/internal,
		// A living xeno that wounds the face it is taken off, and the mannequin bleeds onto a floor nullspace does not have
		/obj/item/clothing/mask/facehugger,
	)
	/// Branches of item types that gear presets are mostly made of, the only ones the picker lists unless searching
	var/static/list/common_types = list(
		/obj/item/ammo_magazine,
		/obj/item/attachable,
		/obj/item/bodybag,
		/obj/item/cell,
		/obj/item/clothing,
		/obj/item/defenses,
		/obj/item/device,
		/obj/item/explosive,
		/obj/item/map,
		/obj/item/reagent_container/hypospray,
		/obj/item/reagent_container/pill,
		/obj/item/restraint,
		/obj/item/roller,
		/obj/item/smartgun_battery,
		/obj/item/stack/cable_coil,
		/obj/item/stack/medical,
		/obj/item/stack/sandbags_empty,
		/obj/item/stack/sheet,
		/obj/item/storage,
		/obj/item/tool,
		/obj/item/weapon,
	)
	/// uniform_restricted of item types, as list(type = list of types or FALSE), see get_uniform_restrictions()
	var/static/list/uniform_restrictions = list()
	/// The only types whose subtypes set uniform_restricted, so the only ones created to read it, since it is a list initial() cannot read
	var/static/list/restrictable_types = list(
		/obj/item/clothing/suit,
		/obj/item/storage/backpack,
		/obj/item/clothing/shoes/yautja,
	)
	/// Slots the builder edits, in the order the gear is equipped (a belt or pockets need the uniform, suit storage the suit), as list(slot = name)
	var/static/list/slot_names = list(
		WEAR_BODY = "Uniform",
		WEAR_FEET = "Shoes",
		WEAR_HANDS = "Gloves",
		WEAR_JACKET = "Suit",
		WEAR_HEAD = "Head",
		WEAR_FACE = "Mask",
		WEAR_EYES = "Eyes",
		WEAR_L_EAR = "Left ear",
		WEAR_R_EAR = "Right ear",
		WEAR_BACK = "Back",
		WEAR_WAIST = "Belt",
		WEAR_J_STORE = "Suit storage",
		WEAR_L_STORE = "Left pocket",
		WEAR_R_STORE = "Right pocket",
		WEAR_L_HAND = "Left hand",
		WEAR_R_HAND = "Right hand",
	)
	/// Names of the slot defines for the exported code, as list(slot = define)
	var/static/list/slot_defines = list(
		WEAR_BODY = "WEAR_BODY",
		WEAR_FEET = "WEAR_FEET",
		WEAR_HANDS = "WEAR_HANDS",
		WEAR_JACKET = "WEAR_JACKET",
		WEAR_HEAD = "WEAR_HEAD",
		WEAR_FACE = "WEAR_FACE",
		WEAR_EYES = "WEAR_EYES",
		WEAR_L_EAR = "WEAR_L_EAR",
		WEAR_R_EAR = "WEAR_R_EAR",
		WEAR_BACK = "WEAR_BACK",
		WEAR_WAIST = "WEAR_WAIST",
		WEAR_J_STORE = "WEAR_J_STORE",
		WEAR_L_STORE = "WEAR_L_STORE",
		WEAR_R_STORE = "WEAR_R_STORE",
		WEAR_L_HAND = "WEAR_L_HAND",
		WEAR_R_HAND = "WEAR_R_HAND",
	)
	/// Variable names of the item in a slot in the exported code, as list(slot = name)
	var/static/list/slot_variables = list(
		WEAR_BODY = "uniform",
		WEAR_FEET = "shoes",
		WEAR_HANDS = "gloves",
		WEAR_JACKET = "suit",
		WEAR_HEAD = "hat",
		WEAR_FACE = "mask",
		WEAR_EYES = "glasses",
		WEAR_L_EAR = "left_ear",
		WEAR_R_EAR = "right_ear",
		WEAR_BACK = "backpack",
		WEAR_WAIST = "belt",
		WEAR_J_STORE = "suit_storage",
		WEAR_L_STORE = "left_pocket",
		WEAR_R_STORE = "right_pocket",
		WEAR_L_HAND = "left_hand",
		WEAR_R_HAND = "right_hand",
	)
	/// Slots that a storage item worn in them can be filled through with WEAR_IN_* in the exported code, as list(slot = define)
	var/static/list/storage_slot_defines = list(
		WEAR_BACK = "WEAR_IN_BACK",
		WEAR_WAIST = "WEAR_IN_BELT",
		WEAR_J_STORE = "WEAR_IN_J_STORE",
		WEAR_L_STORE = "WEAR_IN_L_STORE",
		WEAR_R_STORE = "WEAR_IN_R_STORE",
	)
	/// Names of item sizes, indexed by w_class
	var/static/list/size_names = list("Tiny", "Small", "Medium", "Large", "Huge", "Massive")
	/// What item types spawn with, as list(type = info), see get_default_info()
	var/static/list/default_info = list()

/datum/gear_preset_builder/New()
	. = ..()
	mannequin = new
	if(!catalog)
		build_catalog()

/datum/gear_preset_builder/Destroy(force, ...)
	QDEL_NULL(mannequin)
	return ..()

/datum/gear_preset_builder/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/GearPresetBuilder", "Gear Preset Builder")
		ui.open()

/datum/gear_preset_builder/ui_state(mob/user)
	return GLOB.admin_state

/datum/gear_preset_builder/ui_static_data(mob/user)
	var/list/data = list()
	// Sent once, the picker then only sends which entries fit
	data["catalog"] = catalog_data
	data["species_list"] = get_keys(GLOB.all_species)
	return data

/datum/gear_preset_builder/ui_data(mob/user)
	var/list/data = list()

	// A picture rather than a live map view: a map control created by the window scales the mannequin unreliably
	if(preview_outdated)
		var/icon/flat = getFlatIcon(mannequin, mannequin.dir, no_anim = TRUE)
		center_preview(flat)
		preview_image = icon2base64(flat)
		preview_size = list(flat.Width(), flat.Height())
		preview_outdated = FALSE
	data["preview"] = preview_image
	data["preview_size"] = preview_size
	data["appearance"] = get_appearance()
	data["custom_appearance"] = custom_appearance
	data["species"] = mannequin.species.name
	data["appearance_options"] = get_species_options(mannequin.species.name)
	data["message"] = message
	data["message_is_error"] = message_is_error
	data["preset_name"] = preset_name
	data["preset_path"] = preset_path
	data["export_json"] = export_json
	data["export_code"] = export_code
	data["picker"] = picker ? get_picker_data() : null
	data["picker_items"] = picker_items

	var/list/slots = list()
	for(var/slot in slot_names)
		var/obj/item/item = mannequin.get_item_by_slot(slot)
		slots += list(list(
			"id" = slot,
			"name" = slot_names[slot],
			"item" = item ? get_item_data(item) : null,
		))
	data["slots"] = slots

	return data

/datum/gear_preset_builder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	message = null
	message_is_error = FALSE
	// Nearly every action changes the gear or the facing, so the picture is redrawn after any
	preview_outdated = TRUE

	switch(action)
		if("open_picker")
			var/kind = params["kind"]
			var/target = params["target"]
			switch(kind)
				if("slot")
					if(!(target in slot_names))
						return TRUE
				if("container")
					var/atom/container = locate_in_mannequin(target)
					if(!container || !is_container(container))
						return TRUE
				if("accessory")
					var/obj/item/clothing/clothing = locate_in_mannequin(target)
					if(!istype(clothing) || !LAZYLEN(clothing.valid_accessory_slots))
						return TRUE
				else
					return TRUE
			picker = list("kind" = kind, "target" = target)
			picker_items = get_picker_items()
			return TRUE

		if("close_picker")
			picker = null
			picker_items = list()
			return TRUE

		if("pick")
			var/obj/item/item_type = text2path(params["path"])
			if(!picker || !ispath(item_type, /obj/item) || is_excluded_type(item_type))
				return TRUE
			var/target = picker["target"]
			switch(picker["kind"])
				if("slot")
					if(equip_type(target, item_type))
						picker = null
				if("container")
					var/atom/container = locate_in_mannequin(target)
					if(!container || !is_container(container))
						picker = null
					else
						insert_type(container, item_type)
				if("accessory")
					var/obj/item/clothing/clothing = locate_in_mannequin(target)
					if(!istype(clothing))
						picker = null
					else
						attach_type(clothing, item_type)
			picker_items = picker ? get_picker_items() : list()
			return TRUE

		if("unequip")
			var/slot = params["slot"]
			if(!(slot in slot_names))
				return TRUE
			var/list/slots = serialize_mannequin()
			slots -= slot
			var/list/errors = rebuild(slots)
			if(length(errors))
				set_message("Removed. Also dropped: [jointext(errors, "; ")]", TRUE)
			return TRUE

		if("remove")
			var/obj/item/item = locate_in_mannequin(params["ref"])
			if(!istype(item))
				return TRUE
			var/slot = mannequin.get_slot_by_item(item)
			if(slot in slot_names)
				var/list/slots = serialize_mannequin()
				slots -= slot
				var/list/errors = rebuild(slots)
				if(length(errors))
					set_message("Removed. Also dropped: [jointext(errors, "; ")]", TRUE)
				return TRUE
			if(istype(item, /obj/item/clothing/accessory))
				var/obj/item/clothing/accessory/accessory = item
				mark_edited(accessory.has_suit)
			else
				mark_edited(item.loc)
			delete_item(item)
			mannequin.regenerate_icons()
			return TRUE

		if("rotate")
			mannequin.setDir(turn(mannequin.dir, params["clockwise"] ? -90 : 90))
			return TRUE

		if("clear")
			clear_mannequin()
			return TRUE

		if("load_preset")
			var/preset_choice = tgui_input_list(user, "Which preset's gear to load? It replaces the current gear.", "Load Preset", GLOB.equipment_presets.categories["All"])
			if(!preset_choice)
				return TRUE
			var/datum/equipment_preset/preset = GLOB.equipment_presets.categories["All"][preset_choice]
			if(!preset)
				return TRUE
			clear_mannequin()
			// The species comes from load_race(): synthetics, Working Joes, monkeys and the like
			set_species(SPECIES_HUMAN)
			preset.load_race(mannequin)
			// Fits the looks to the species, as load_race() may change the species but not the looks
			set_appearance(list())
			// What the species hands out (zombie claws) is not the preset's gear, the species gives it again in the round
			clear_mannequin()
			preset.load_gear(mannequin)
			// The ID comes from the preset's idtype, not from its gear
			var/obj/item/id_card = mannequin.get_item_by_slot(WEAR_ID)
			if(id_card)
				delete_item(id_card)
			// Gear outside the edited slots (handcuffs and the like) is dropped so the export matches what is shown
			for(var/obj/item/stray in mannequin.contents)
				if(!(mannequin.get_slot_by_item(stray) in slot_names) && !QDELETED(stray))
					qdel(stray)
			mannequin.regenerate_icons()
			// The window may have redrawn the picture while the list was open, before the gear changed
			preview_outdated = TRUE
			set_message("Loaded the gear of [preset.name].")
			return TRUE

		if("set_name")
			var/new_name = strip_html("[params["name"]]", MAX_NAME_LEN)
			if(new_name)
				preset_name = new_name
			return TRUE

		if("set_path")
			var/new_path = sanitize_preset_path("[params["path"]]")
			if(new_path)
				preset_path = new_path
			return TRUE

		if("export")
			var/list/slots = serialize_mannequin()
			var/list/appearance = custom_appearance ? get_appearance() : null
			var/species_name = mannequin.species.name
			export_code = generate_code(slots, appearance, species_name)
			var/list/export = list(
				"name" = preset_name,
				"path" = "/datum/equipment_preset/[preset_path]",
				"species" = species_name,
				"slots" = slots,
			)
			if(appearance)
				export["appearance"] = appearance
			export["code"] = export_code
			export_json = json_encode(export, JSON_PRETTY_PRINT)
			return TRUE

		if("close_export")
			export_json = null
			export_code = null
			return TRUE

		if("download")
			if(!export_json || !user.client)
				return TRUE
			var/file_name = "[sanitize_filename(replacetext(preset_path, "/", "_"))].json"
			var/temporary_path = "[GEAR_BUILDER_EXPORT_FOLDER][user.ckey]_[file_name]"
			fdel(temporary_path)
			if(!text2file(export_json, temporary_path))
				set_message("Could not write the export file.", TRUE)
				return TRUE
			DIRECT_OUTPUT(user, ftp(file(temporary_path), file_name))
			return TRUE

		if("import")
			// The window sends the JSON in parts, since a tgui message over about 20 KB is dropped
			var/part = params["part"]
			var/parts = params["parts"]
			if(!istext(params["json"]) || !isnum(part) || !isnum(parts) || part < 1 || part > parts || parts > GEAR_BUILDER_IMPORT_MAX_PARTS)
				return TRUE
			if(part == 1)
				import_parts = list()
			if(length(import_parts) != part - 1)
				import_parts = null
				set_message("Part of the import got lost, try again.", TRUE)
				return TRUE
			import_parts += params["json"]
			if(part < parts)
				return FALSE
			var/json_text = jointext(import_parts, "")
			import_parts = null
			// Not rustg_json_is_valid(): it refuses JSON nested 8 levels deep, which a backpack with an MRE in it already is
			var/list/imported
			try
				imported = json_decode(json_text)
			catch
				set_message("That is not valid JSON.", TRUE)
				return TRUE
			if(!islist(imported) || !islist(imported["slots"]))
				set_message("The JSON has no \"slots\".", TRUE)
				return TRUE
			if(istext(imported["name"]))
				preset_name = strip_html(imported["name"], MAX_NAME_LEN)
			if(istext(imported["path"]))
				preset_path = sanitize_preset_path(replacetext(imported["path"], "/datum/equipment_preset/", "")) || preset_path
			// The species goes first, it decides the hair styles and the slots the gear can go in
			set_species(istext(imported["species"]) ? imported["species"] : SPECIES_HUMAN)
			custom_appearance = islist(imported["appearance"])
			if(custom_appearance)
				set_appearance(imported["appearance"])
			var/list/errors = rebuild(imported["slots"])
			if(length(errors))
				set_message("Imported with problems: [jointext(errors, "; ")]", TRUE)
			else
				set_message("Imported.")
			return TRUE

		if("set_appearance")
			var/field = params["field"]
			if(!(field in list("gender", "skin_color", "body_type", "body_size", "underwear", "undershirt", "h_style", "f_style")))
				return TRUE
			set_appearance(list("[field]" = params["value"]))
			custom_appearance = TRUE
			return TRUE

		if("pick_color")
			var/static/list/color_fields = list(
				"hair_color" = "hair",
				"facial_hair_color" = "facial hair",
				"eye_color" = "eye",
			)
			var/field = params["field"]
			if(!color_fields[field])
				return TRUE
			var/new_color = tgui_color_picker(user, "Choose the [color_fields[field]] color:", "Gear Preset Builder", get_appearance()[field])
			if(!new_color || QDELETED(src))
				return TRUE
			set_appearance(list("[field]" = new_color))
			custom_appearance = TRUE
			return TRUE

		if("randomize_appearance")
			mannequin.gender = pick(MALE, FEMALE)
			var/datum/preferences/random_preferences = new()
			random_preferences.randomize_appearance(mannequin)
			// randomize_appearance() picks human looks, so the species setup and the values it offers are put back
			apply_race_setup(mannequin)
			var/list/options = get_species_options(mannequin.species.name)
			var/list/random_look = list()
			if(length(options["skin_colors"]))
				var/list/random_skin = pick(options["skin_colors"])
				random_look["skin_color"] = random_skin["name"]
			if(length(options["hair_styles"]))
				var/list/random_hair = pick(options["hair_styles"])
				random_look["h_style"] = random_hair["name"]
			set_appearance(random_look)
			custom_appearance = TRUE
			return TRUE

		if("toggle_custom_appearance")
			custom_appearance = !custom_appearance
			return TRUE

		if("set_species")
			if(!istext(params["species"]) || !GLOB.all_species[params["species"]])
				return TRUE
			// Rebuilt from the gear before the change, as a preset puts its gear on after load_race(): without what
			// the species hands out (zombie claws) or throws off, and without what the new body cannot wear
			var/list/slots = serialize_mannequin()
			set_species(params["species"])
			var/list/errors = rebuild(slots)
			if(length(errors))
				set_message("Dropped what [params["species"]] cannot wear: [jointext(errors, "; ")]", TRUE)
			return TRUE

		if("spawn")
			var/turf/spawn_turf = get_turf(user)
			if(!spawn_turf)
				return TRUE
			var/mob/living/carbon/human/spawned = new(spawn_turf)
			// Gear cannot be put on a mob without a HUD
			spawned.create_hud()
			spawned.set_species(mannequin.species.name)
			apply_race_setup(spawned)
			if(custom_appearance)
				set_appearance(get_appearance(), spawned)
			var/list/errors = list()
			apply_slots(spawned, serialize_mannequin(), errors)
			message_admins("[key_name_admin(user)] spawned a human with the gear preset builder at [ADMIN_VERBOSEJMP(spawn_turf)].")
			log_admin("[key_name(user)] spawned a human with the gear preset builder at [AREACOORD(spawn_turf)].")
			if(length(errors))
				set_message("Spawned with problems: [jointext(errors, "; ")]", TRUE)
			else
				set_message("Spawned at your location.")
			return TRUE

/// Marks the item that owns a container (or the item itself) as changed in the builder
/datum/gear_preset_builder/proc/mark_edited(atom/target)
	if(istype(target, /obj/item/storage/internal))
		target = target.loc
	if(target)
		edited_refs[REF(target)] = TRUE

/// Sets the message shown in the window
/datum/gear_preset_builder/proc/set_message(text, is_error = FALSE)
	message = text
	message_is_error = is_error

/// Returns the text as a type path below /datum/equipment_preset/ (lowercase words joined by single slashes), or "" if nothing is left of it
/datum/gear_preset_builder/proc/sanitize_preset_path(text)
	var/list/parts = list()
	for(var/part in splittext(lowertext(trim(text)), "/"))
		part = replacetext(part, regex(@"[^a-z0-9_]", "g"), "_")
		if(part)
			parts += part
	return jointext(parts, "/")

/// Returns the name of an item size for the window
/datum/gear_preset_builder/proc/get_size_name(w_class)
	if(w_class >= 1 && w_class <= length(size_names))
		return size_names[w_class]
	return "[w_class]"

/// Fills the catalog with every item type that has an icon
/datum/gear_preset_builder/proc/build_catalog()
	catalog = list()
	catalog_data = list()
	for(var/obj/item/item_type as anything in typesof(/obj/item))
		if(is_excluded_type(item_type))
			continue
		if(!initial(item_type.icon_state) || !initial(item_type.name))
			continue
		var/w_class = initial(item_type.w_class)
		catalog += list(list(
			"path" = item_type,
			"slots" = initial(item_type.flags_equip_slot),
			"w_class" = w_class,
			"cost" = initial(item_type.storage_cost) || w_class,
			"nodrop" = initial(item_type.flags_item) & NODROP,
		))
		catalog_data += list(list(
			"path" = "[item_type]",
			"name" = strip_improper("[initial(item_type.name)]"),
			"icon" = "[initial(item_type.icon)]",
			"icon_state" = initial(item_type.icon_state),
			"size" = get_size_name(w_class),
			"desc" = get_short_desc("[initial(item_type.desc)]"),
			"common" = is_common_type(item_type),
		))

/// Returns an item description as plain text for a tooltip, without HTML tags and cut to a few sentences
/datum/gear_preset_builder/proc/get_short_desc(desc)
	var/static/regex/html_tags = regex(@"<[^>]*>", "g")
	var/static/regex/spaces = regex(@"\s+", "g")
	desc = trim(spaces.Replace(html_tags.Replace(strip_improper(desc), " "), " "))
	if(length_char(desc) > GEAR_BUILDER_DESC_LENGTH)
		desc = "[copytext_char(desc, 1, GEAR_BUILDER_DESC_LENGTH)]..."
	return desc

/// Returns TRUE if the item type is in one of the branches of excluded_types
/datum/gear_preset_builder/proc/is_excluded_type(item_type)
	for(var/excluded_type in excluded_types)
		if(ispath(item_type, excluded_type))
			return TRUE
	return FALSE

/// Returns TRUE if the item type is in one of the branches of common_types
/datum/gear_preset_builder/proc/is_common_type(item_type)
	for(var/common_type in common_types)
		if(ispath(item_type, common_type))
			return TRUE
	return FALSE

/// Returns TRUE if the atom is one of the containers get_containers() finds
/datum/gear_preset_builder/proc/is_container(atom/target)
	if(target in get_containers(target))
		return TRUE
	return isitem(target.loc) && (target in get_containers(target.loc))

/// Returns the window data of the open picker: its title and, for a container, how full it is
/datum/gear_preset_builder/proc/get_picker_data()
	var/list/data = list("kind" = picker["kind"])
	switch(picker["kind"])
		if("slot")
			data["title"] = slot_names[picker["target"]]
		if("container")
			var/atom/container = locate_in_mannequin(picker["target"])
			if(container)
				var/obj/item/owner = isstorage(container) && istype(container, /obj/item/storage/internal) ? container.loc : container
				data["container"] = get_container_data(owner, container)
				data["title"] = "[strip_improper(owner.name)]: [data["container"]["name"]]"
		if("accessory")
			var/atom/clothing = locate_in_mannequin(picker["target"])
			if(clothing)
				data["title"] = "Accessories of [strip_improper(clothing.name)]"
	return data

/// Returns the indexes into the catalog, counted from 0, of the entries that fit where the picker is open
/datum/gear_preset_builder/proc/get_picker_items()
	var/list/items = list()
	switch(picker["kind"])
		if("slot")
			var/slot = picker["target"]
			for(var/i in 1 to length(catalog))
				if(can_wear_type(slot, catalog[i]))
					items += i - 1
		if("container")
			var/atom/container = locate_in_mannequin(picker["target"])
			if(!container)
				return items
			var/free = get_free_room(container)
			if(free <= 0)
				return items
			for(var/i in 1 to length(catalog))
				if(can_insert_type(container, catalog[i], free))
					items += i - 1
		if("accessory")
			var/obj/item/clothing/clothing = locate_in_mannequin(picker["target"])
			if(!istype(clothing))
				return items
			// Accessories already attached per accessory slot, as list(slot = count)
			var/list/attached_counts = list()
			for(var/obj/item/clothing/accessory/attached in clothing.accessories)
				attached_counts[attached.worn_accessory_slot] += 1
			for(var/i in 1 to length(catalog))
				if(can_attach_type(clothing, catalog[i], attached_counts))
					items += i - 1
	return items

/**
 * Returns TRUE if a catalog entry can be worn in the slot by the mannequin as it is dressed
 *
 * Follows /obj/item/proc/mob_can_equip() from the type's vars, ignoring whether the slot is taken since picking replaces it
 */
/datum/gear_preset_builder/proc/can_wear_type(slot, list/entry)
	var/obj/item/item_type = entry["path"]
	var/slot_flags = entry["slots"]
	switch(slot)
		if(WEAR_BODY)
			if(!(slot_flags & SLOT_ICLOTHING))
				return FALSE
		if(WEAR_JACKET)
			if(!(slot_flags & SLOT_OCLOTHING))
				return FALSE
			// Some uniforms only go with certain suits, see /obj/item/clothing/suit/mob_can_equip()
			var/obj/item/clothing/under/uniform = mannequin.w_uniform
			if(uniform?.suit_restricted)
				var/allowed = FALSE
				for(var/allowed_type in uniform.suit_restricted)
					if(ispath(item_type, allowed_type))
						allowed = TRUE
						break
				if(!allowed)
					return FALSE
		if(WEAR_HEAD)
			if(!(slot_flags & SLOT_HEAD))
				return FALSE
		if(WEAR_FACE)
			if(!(slot_flags & SLOT_FACE))
				return FALSE
		if(WEAR_EYES)
			if(!(slot_flags & SLOT_EYES))
				return FALSE
		if(WEAR_HANDS)
			if(!(slot_flags & SLOT_HANDS))
				return FALSE
		if(WEAR_FEET)
			if(!(slot_flags & SLOT_FEET))
				return FALSE
		if(WEAR_BACK)
			if(!(slot_flags & SLOT_BACK))
				return FALSE
		if(WEAR_L_EAR, WEAR_R_EAR)
			if(!(slot_flags & SLOT_EAR))
				return FALSE
		if(WEAR_WAIST)
			if(!mannequin.w_uniform || !(slot_flags & SLOT_WAIST))
				return FALSE
		if(WEAR_L_STORE, WEAR_R_STORE)
			if(!mannequin.w_uniform || (slot_flags & SLOT_NO_STORE))
				return FALSE
			if(entry["w_class"] > SIZE_SMALL && !(slot_flags & SLOT_STORE))
				return FALSE
		if(WEAR_J_STORE)
			if(!(slot_flags & SLOT_SUIT_STORE))
				if((slot_flags & SLOT_BLOCK_SUIT_STORE) || !mannequin.wear_suit)
					return FALSE
				var/allowed = FALSE
				for(var/allowed_type in mannequin.wear_suit.allowed)
					if(ispath(item_type, allowed_type))
						allowed = TRUE
						break
				if(!allowed)
					return FALSE
		if(WEAR_L_HAND, WEAR_R_HAND)
			pass()
		else
			return FALSE
	return is_uniform_restriction_met(item_type)

/// Returns TRUE if the mannequin wears what the item type's uniform_restricted needs, which upstream checks for every slot, hands included
/datum/gear_preset_builder/proc/is_uniform_restriction_met(item_type)
	var/list/restrictions = get_uniform_restrictions(item_type)
	if(!restrictions)
		return TRUE
	for(var/obj/item/restriction_type as anything in restrictions)
		var/restriction_slots = initial(restriction_type.flags_equip_slot)
		if((restriction_slots & SLOT_ICLOTHING) && istype(mannequin.w_uniform, restriction_type))
			return TRUE
		if((restriction_slots & SLOT_OCLOTHING) && istype(mannequin.wear_suit, restriction_type))
			return TRUE
	return FALSE

/// Returns the uniform_restricted of an item type, or FALSE if it has none, creating one item of the type the first time
/datum/gear_preset_builder/proc/get_uniform_restrictions(item_type)
	if(item_type in uniform_restrictions)
		return uniform_restrictions[item_type]
	var/is_restrictable = FALSE
	for(var/restrictable_type in restrictable_types)
		if(ispath(item_type, restrictable_type))
			is_restrictable = TRUE
			break
	if(!is_restrictable)
		return FALSE
	var/obj/item/probe = new item_type()
	uniform_restrictions[item_type] = length(probe.uniform_restricted) ? probe.uniform_restricted.Copy() : FALSE
	qdel(probe)
	CHECK_TICK
	return uniform_restrictions[item_type]

/// Returns the free room of a container: slots left, or storage space left for storages without slots
/datum/gear_preset_builder/proc/get_free_room(atom/container)
	if(istype(container, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = container
		return shoes.stored_item ? 0 : 1
	var/obj/item/storage/storage = container
	var/list/container_items = get_container_items(container)
	if(!isnull(storage.storage_slots))
		return storage.storage_slots - length(container_items)
	var/used_space = 0
	for(var/obj/item/thing as anything in container_items)
		used_space += thing.get_storage_cost()
	return storage.max_storage_space - used_space

/**
 * Returns TRUE if a catalog entry fits into the container
 *
 * Follows /obj/item/storage/proc/can_be_inserted() from the type's vars
 * * free - the container's free room from get_free_room()
 */
/datum/gear_preset_builder/proc/can_insert_type(atom/container, list/entry, free)
	var/obj/item/item_type = entry["path"]
	if(istype(container, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = container
		return is_type_in_typecache(item_type, shoes.allowed_items_typecache)
	var/obj/item/storage/storage = container
	if(entry["nodrop"] || !storage.can_hold_type(item_type, mannequin))
		return FALSE
	if(entry["w_class"] > storage.max_w_class)
		var/bypassed = FALSE
		for(var/bypass_type in storage.bypass_w_limit)
			if(ispath(item_type, bypass_type))
				bypassed = TRUE
				break
		if(!bypassed)
			return FALSE
	if(isnull(storage.storage_slots) && entry["cost"] > free)
		return FALSE
	if(ispath(item_type, /obj/item/storage) && entry["w_class"] >= storage.w_class && !istype(storage, /obj/item/storage/backpack/holding))
		return FALSE
	return TRUE

/**
 * Returns TRUE if a catalog entry is an accessory that can be attached to the clothing
 *
 * Follows /obj/item/clothing/proc/can_attach_accessory() from the type's vars
 * * attached_counts - accessories already attached per accessory slot, as list(slot = count)
 */
/datum/gear_preset_builder/proc/can_attach_type(obj/item/clothing/clothing, list/entry, list/attached_counts)
	var/obj/item/clothing/accessory/accessory_type = entry["path"]
	if(!ispath(accessory_type, /obj/item/clothing/accessory))
		return FALSE
	var/accessory_slot = initial(accessory_type.worn_accessory_slot)
	if(!(accessory_slot in clothing.valid_accessory_slots))
		return FALSE
	return attached_counts[accessory_slot] < initial(accessory_type.worn_accessory_limit)

/// Puts a new item of the type into a slot, replacing what is there, returns TRUE on success
/datum/gear_preset_builder/proc/equip_type(slot, obj/item/item_type)
	var/obj/item/current = mannequin.get_item_by_slot(slot)
	if(!current)
		var/obj/item/item = new item_type()
		if(!mannequin.equip_to_slot_if_possible(item, slot, disable_warning = TRUE))
			set_message("[strip_improper(item.name)] cannot be worn in [slot_names[slot]].", TRUE)
			qdel(item)
			return FALSE
		mannequin.regenerate_icons()
		return TRUE

	// Replacing the uniform or the suit drops the gear that needs them, so the whole outfit is rebuilt around the new item
	var/list/old_slots = serialize_mannequin()
	var/list/new_slots = old_slots.Copy()
	new_slots[slot] = list("type" = "[item_type]")
	var/list/errors = rebuild(new_slots)
	if(!mannequin.get_item_by_slot(slot))
		rebuild(old_slots)
		set_message("[strip_improper(initial(item_type.name))] cannot be worn in [slot_names[slot]].", TRUE)
		return FALSE
	if(length(errors))
		set_message("Replaced. Also dropped: [jointext(errors, "; ")]", TRUE)
	return TRUE

/// Puts a new item of the type into a container of the mannequin's gear, returns TRUE on success
/datum/gear_preset_builder/proc/insert_type(atom/container, obj/item/item_type)
	var/obj/item/item = new item_type()
	var/reason = get_insert_failure(container, item)
	if(reason || !insert_item(container, item, mannequin))
		set_message("[strip_improper(item.name)] does not fit: [reason || "the container refused it"].", TRUE)
		qdel(item)
		return FALSE
	mark_edited(container)
	mannequin.regenerate_icons()
	return TRUE

/// Attaches a new accessory of the type to clothing of the mannequin's gear, returns TRUE on success
/datum/gear_preset_builder/proc/attach_type(obj/item/clothing/clothing, obj/item/item_type)
	var/obj/item/clothing/accessory/accessory = new item_type()
	if(!istype(accessory) || !clothing.can_attach_accessory(accessory))
		set_message("[strip_improper(accessory.name)] cannot be attached to [strip_improper(clothing.name)].", TRUE)
		qdel(accessory)
		return FALSE
	attach_accessory_for(clothing, accessory, mannequin)
	mark_edited(clothing)
	mannequin.regenerate_icons()
	return TRUE

/**
 * Attaches an accessory to clothing as if the wearer did it
 *
 * A medal is awarded to the wearer first, as the round start service medals are, since it only attaches for its recipient.
 * * owner - the mob the clothing is for
 */
/datum/gear_preset_builder/proc/attach_accessory_for(obj/item/clothing/clothing, obj/item/clothing/accessory/accessory, mob/living/carbon/human/owner)
	if(istype(accessory, /obj/item/clothing/accessory/medal))
		var/obj/item/clothing/accessory/medal/medal = accessory
		medal.recipient_name = owner.real_name
	clothing.attach_accessory(owner, accessory, TRUE)

/// Returns the atom with this ref if it is part of the mannequin's gear, else null
/datum/gear_preset_builder/proc/locate_in_mannequin(ref)
	if(!istext(ref))
		return null
	var/atom/target = locate(ref)
	if(!istype(target) || target == mannequin)
		return null
	for(var/atom/holder = target.loc; holder; holder = holder.loc)
		if(holder == mannequin)
			return target
	return null

/**
 * Returns the containers of an item in a fixed order: the item itself if it is a storage,
 * the internal storages inside it (suit and helmet pockets, webbing), then shoes that can hold an item
 */
/datum/gear_preset_builder/proc/get_containers(obj/item/item)
	var/list/containers = list()
	if(!istype(item))
		return containers
	if(isstorage(item) && !istype(item, /obj/item/storage/internal))
		containers += item
	for(var/obj/item/storage/internal/internal in item.contents)
		containers += internal
	if(istype(item, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = item
		if(shoes.allowed_items_typecache)
			containers += shoes
	return containers

/// Returns the items inside a container from get_containers()
/datum/gear_preset_builder/proc/get_container_items(atom/container)
	var/list/items = list()
	if(istype(container, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = container
		if(shoes.stored_item)
			items += shoes.stored_item
		return items
	for(var/obj/item/thing in container.contents)
		if(istype(thing, /obj/item/storage/internal))
			continue
		items += thing
	return items

/// Returns why the item cannot go into the container, or null if it can
/datum/gear_preset_builder/proc/get_insert_failure(atom/container, obj/item/item)
	if(istype(container, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = container
		if(shoes.stored_item)
			return "already holds [strip_improper(shoes.stored_item.name)]"
		if(!shoes.can_be_inserted(item))
			return "cannot hold this"
		return null
	var/obj/item/storage/storage = container
	if(!istype(storage))
		return "not a storage"
	if(!storage.can_hold_type(item.type, mannequin))
		return "cannot hold this"
	if(item.w_class > storage.max_w_class && !is_type_in_list(item, storage.bypass_w_limit))
		return "too big ([get_size_name(item.w_class)], fits up to [get_size_name(storage.max_w_class)])"
	if(!storage.has_room(item))
		return "full"
	if(!storage.can_be_inserted(item, mannequin, TRUE))
		return "refused"
	return null

/// Puts an item into a container from get_containers() if it fits, returns TRUE on success
/datum/gear_preset_builder/proc/insert_item(atom/container, obj/item/item, mob/living/carbon/human/owner)
	if(istype(container, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = container
		return shoes.attempt_insert_item(owner, item)
	var/obj/item/storage/storage = container
	if(!istype(storage) || !storage.can_be_inserted(item, owner, TRUE))
		return FALSE
	return storage.handle_item_insertion(item, TRUE)

/// Deletes an item of the mannequin's gear, wherever it is
/datum/gear_preset_builder/proc/delete_item(obj/item/item)
	var/atom/holder = item.loc
	if(istype(item, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/accessory = item
		var/obj/item/clothing/clothes = accessory.has_suit
		if(clothes)
			// Not remove_accessory(): on_removed() hands the accessory to usr, the admin
			LAZYREMOVE(clothes.accessories, accessory)
			clothes.overlays -= accessory.get_inv_overlay()
			accessory.has_suit = null
			clothes.update_clothing_icon()
	else if(istype(holder, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/shoes = holder
		if(shoes.stored_item == item)
			shoes.stored_item = null
			shoes.update_icon()
	else if(ismob(holder))
		var/mob/wearer = holder
		wearer.drop_inv_item_to_loc(item, null, force = TRUE)
	qdel(item)
	if(isstorage(holder))
		var/obj/item/storage/storage = holder
		storage.update_icon()

/// Deletes all the gear of the mannequin
/datum/gear_preset_builder/proc/clear_mannequin()
	for(var/slot in slot_names + WEAR_ID)
		var/obj/item/item = mannequin.get_item_by_slot(slot)
		if(item)
			delete_item(item)
	// Items taken off with nowhere to go, like what a zombie throws "on the floor" in nullspace, stay inside the mannequin
	for(var/obj/item/stray in mannequin.contents)
		if(!QDELETED(stray) && !(mannequin.get_slot_by_item(stray) in slot_names))
			qdel(stray)
	edited_refs.Cut()
	mannequin.regenerate_icons()

/// Replaces the mannequin's gear with the slots, returns the list of what could not be put on
/datum/gear_preset_builder/proc/rebuild(list/slots)
	var/list/errors = list()
	clear_mannequin()
	apply_slots(mannequin, slots, errors)
	mannequin.regenerate_icons()
	return errors

/// Puts on the target the gear of slots, as list(slot = item tree), adding what could not be put on to errors
/datum/gear_preset_builder/proc/apply_slots(mob/living/carbon/human/target, list/slots, list/errors)
	for(var/slot in slot_names)
		var/list/tree = slots[slot]
		if(!islist(tree))
			continue
		var/obj/item/item = build_item(tree, target, errors)
		if(!item)
			continue
		if(!target.equip_to_slot_if_possible(item, slot, disable_warning = TRUE))
			errors += "[strip_improper(item.name)] ([slot_names[slot]])"
			qdel(item)

/**
 * Creates an item in nullspace from an item tree
 *
 * Returns the item, or null if the tree has no valid item type
 * * tree - the item tree, see [/datum/gear_preset_builder]
 * * owner - the mob it is meant for, which storages and shoes check
 * * errors - list that what could not be put on or inside is added to
 */
/datum/gear_preset_builder/proc/build_item(list/tree, mob/living/carbon/human/owner, list/errors)
	var/item_type = text2path(tree["type"])
	if(!ispath(item_type, /obj/item) || is_excluded_type(item_type))
		errors += "unknown type [tree["type"]]"
		return null
	var/obj/item/item = new item_type()
	apply_item_tree(item, tree, owner, errors)
	return item

/**
 * Makes the accessories and contents of an item match an item tree
 *
 * What the item already has is kept where the tree has an item of the same type, so only what is missing is created
 * and only what is extra is deleted. An untouched item of a type with random contents keeps what it spawned with.
 * What is missing goes in even if the storage would not let it in by hand: the tree describes gear that already
 * existed, and some storages spawn with what they do not accept (MREs).
 * Arguments are as in build_item().
 */
/datum/gear_preset_builder/proc/apply_item_tree(obj/item/item, list/tree, mob/living/carbon/human/owner, list/errors)
	if(tree["edited"])
		edited_refs[REF(item)] = TRUE
	else if(get_default_info(item.type)["random"])
		return

	if(istype(item, /obj/item/clothing) && islist(tree["accessories"]))
		var/obj/item/clothing/clothing = item
		var/list/unmatched = clothing.accessories ? clothing.accessories.Copy() : list()
		var/list/to_build = list()
		for(var/list/accessory_tree in tree["accessories"])
			var/obj/item/existing = take_same_type(unmatched, accessory_tree)
			if(existing)
				apply_item_tree(existing, accessory_tree, owner, errors)
			else
				to_build += list(accessory_tree)
		for(var/obj/item/clothing/accessory/leftover as anything in unmatched)
			delete_item(leftover)
		for(var/list/accessory_tree as anything in to_build)
			var/obj/item/clothing/accessory/accessory = build_item(accessory_tree, owner, errors)
			if(!accessory)
				continue
			if(!istype(accessory) || !clothing.can_attach_accessory(accessory))
				errors += "[strip_improper(accessory.name)] (on [strip_improper(clothing.name)])"
				qdel(accessory)
				continue
			attach_accessory_for(clothing, accessory, owner)

	var/list/contents_trees = tree["contents"]
	if(!islist(contents_trees))
		return
	var/list/containers = get_containers(item)
	for(var/i in 1 to length(containers))
		var/atom/container = containers[i]
		var/list/unmatched = get_container_items(container)
		var/list/to_build = list()
		if(i <= length(contents_trees) && islist(contents_trees[i]))
			for(var/list/child_tree in contents_trees[i])
				var/obj/item/existing = take_same_type(unmatched, child_tree)
				if(existing)
					apply_item_tree(existing, child_tree, owner, errors)
				else
					to_build += list(child_tree)
		for(var/obj/item/leftover as anything in unmatched)
			delete_item(leftover)
		for(var/list/child_tree as anything in to_build)
			var/obj/item/child = build_item(child_tree, owner, errors)
			if(!child)
				continue
			if(insert_item(container, child, owner))
				continue
			if(isstorage(container))
				var/obj/item/storage/storage = container
				storage.handle_item_insertion(child, TRUE)
				continue
			errors += "[strip_improper(child.name)] (in [strip_improper(item.name)])"
			qdel(child)

/// Removes from candidates and returns the first item of the item tree's type, or null if there is none
/datum/gear_preset_builder/proc/take_same_type(list/candidates, list/tree)
	var/item_type = text2path(tree["type"])
	for(var/obj/item/candidate as anything in candidates)
		if(candidate.type == item_type)
			candidates -= candidate
			return candidate
	return null

/// Returns the item tree of an item with exactly what it has, see [/datum/gear_preset_builder]
/datum/gear_preset_builder/proc/serialize_item(obj/item/item)
	var/list/tree = list("type" = "[item.type]")
	if(edited_refs[REF(item)])
		tree["edited"] = TRUE
	if(istype(item, /obj/item/clothing))
		var/obj/item/clothing/clothing = item
		var/list/accessories = list()
		for(var/obj/item/clothing/accessory/accessory in clothing.accessories)
			accessories += list(serialize_item(accessory))
		tree["accessories"] = accessories
	var/list/containers = get_containers(item)
	if(length(containers))
		var/list/contents = list()
		for(var/atom/container as anything in containers)
			var/list/items = list()
			for(var/obj/item/thing as anything in get_container_items(container))
				items += list(serialize_item(thing))
			contents += list(items)
		tree["contents"] = contents
	return tree

/// Returns the mannequin's gear as list(slot = item tree)
/datum/gear_preset_builder/proc/serialize_mannequin()
	var/list/slots = list()
	for(var/slot in slot_names)
		var/obj/item/item = mannequin.get_item_by_slot(slot)
		if(item)
			slots[slot] = serialize_item(item)
	return slots

/// Returns the window data of an item of the mannequin's gear, with its accessories and containers
/datum/gear_preset_builder/proc/get_item_data(obj/item/item)
	var/list/data = list(
		"ref" = REF(item),
		"name" = strip_improper(item.name),
		"path" = "[item.type]",
		"icon" = "[item.icon]",
		"icon_state" = item.icon_state,
		"size" = get_size_name(item.w_class),
	)
	if(istype(item, /obj/item/clothing))
		var/obj/item/clothing/clothing = item
		if(LAZYLEN(clothing.valid_accessory_slots))
			data["accepts_accessories"] = TRUE
			var/list/accessories = list()
			for(var/obj/item/clothing/accessory/accessory in clothing.accessories)
				accessories += list(get_item_data(accessory))
			data["accessories"] = accessories

	var/list/containers = list()
	for(var/atom/container as anything in get_containers(item))
		containers += list(get_container_data(item, container))
	data["containers"] = containers
	return data

/// Returns the window data of a container of an item: its fill, size limit and items
/datum/gear_preset_builder/proc/get_container_data(obj/item/item, atom/container)
	var/list/container_items = get_container_items(container)
	var/list/items = list()
	for(var/obj/item/thing as anything in container_items)
		items += list(get_item_data(thing))
	var/list/container_data = list(
		"ref" = REF(container),
		"name" = get_container_name(item, container),
		"items" = items,
	)
	if(istype(container, /obj/item/clothing/shoes))
		container_data["used"] = length(items)
		container_data["max"] = 1
		container_data["unit"] = "slots"
		return container_data
	var/obj/item/storage/storage = container
	container_data["max_size"] = get_size_name(storage.max_w_class)
	if(isnull(storage.storage_slots))
		var/used_space = 0
		for(var/obj/item/thing as anything in container_items)
			used_space += thing.get_storage_cost()
		container_data["used"] = used_space
		container_data["max"] = storage.max_storage_space
		container_data["unit"] = "space"
	else
		container_data["used"] = length(items)
		container_data["max"] = storage.storage_slots
		container_data["unit"] = "slots"
	return container_data

/// Returns the name of a container of an item for the window
/datum/gear_preset_builder/proc/get_container_name(obj/item/item, atom/container)
	if(container == item)
		return istype(item, /obj/item/clothing/shoes) ? "Boot slot" : "Storage"
	var/variable_name = get_container_variable(item, container)
	return variable_name ? capitalize(variable_name) : "Storage"

/// Returns the variable of the item that refers to its internal storage, or null if none does
/datum/gear_preset_builder/proc/get_container_variable(obj/item/item, atom/container)
	for(var/variable_name in item.vars)
		if(variable_name == "contents" || variable_name == "vis_contents")
			continue
		if(item.vars[variable_name] == container)
			return variable_name
	return null

// Appearance

/**
 * Returns what the appearance panel offers for a species, leaving out what does not change how that species looks
 *
 * As list("skin_colors" = list(list("name", "color" or null)), "body_types", "body_sizes" = names,
 * "underwear", "undershirts" = list("male" = names, "female" = names) or null,
 * "hair_styles", "facial_hair_styles" = list(list("name", "icon", "icon_state", "gender")), "hair_colored" = boolean)
 */
/datum/gear_preset_builder/proc/get_species_options(species_name)
	var/static/list/options_by_species = list()
	if(options_by_species[species_name])
		return options_by_species[species_name]
	var/datum/species/species = GLOB.all_species[species_name]
	var/list/options = list(
		"skin_colors" = list(),
		"body_types" = list(),
		"body_sizes" = list(),
		"underwear" = null,
		"undershirts" = null,
		"hair_styles" = list(),
		"hair_colored" = FALSE,
		"facial_hair_styles" = list(),
	)
	if(species.flags & HAS_SKIN_COLOR)
		var/list/own_skin_colors = species_skin_colors[species_name]
		if(own_skin_colors)
			for(var/color_name in own_skin_colors)
				options["skin_colors"] += list(list("name" = color_name, "color" = null))
		else
			for(var/color_name in GLOB.skin_color_list)
				var/datum/skin_color/skin_color = GLOB.skin_color_list[color_name]
				options["skin_colors"] += list(list("name" = color_name, "color" = skin_color.color))
			// Build and size only pick the body sprites of species with special_body_types, see get_limb_icon_name()
			if(species.special_body_types)
				options["body_types"] = get_keys(GLOB.body_type_list)
				options["body_sizes"] = get_keys(GLOB.body_size_list)
	if(species.flags & HAS_UNDERWEAR)
		// The global lists map names to datums, only the names go to the window
		options["underwear"] = list("male" = get_keys(GLOB.underwear_m), "female" = get_keys(GLOB.underwear_f))
		options["undershirts"] = list("male" = get_keys(GLOB.undershirt_m), "female" = get_keys(GLOB.undershirt_f))
	var/list/hair_styles = get_hair_styles(species_name)
	for(var/style_name in hair_styles)
		var/datum/sprite_accessory/hair = hair_styles[style_name]
		if(!is_style_allowed(hair, species_name))
			continue
		if(hair.do_coloration)
			options["hair_colored"] = TRUE
		options["hair_styles"] += list(list("name" = style_name, "icon" = "[hair.icon]", "icon_state" = hair.icon_state, "gender" = "any"))
	for(var/style_name in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/facial_hair/facial_hair = GLOB.facial_hair_styles_list[style_name]
		if(!is_style_allowed(facial_hair, species_name))
			continue
		options["facial_hair_styles"] += list(list(
			"name" = style_name,
			"icon" = "[facial_hair.icon]",
			"icon_state" = facial_hair.icon_state,
			"gender" = facial_hair.gender == MALE ? "male" : (facial_hair.gender == FEMALE ? "female" : "any"),
		))
	options_by_species[species_name] = options
	return options

/// Returns the hair styles of a species, as /datum/species/proc/get_hairstyle() finds them by name
/datum/gear_preset_builder/proc/get_hair_styles(species_name)
	return species_name == SPECIES_YAUTJA ? GLOB.yautja_hair_styles_list : GLOB.hair_styles_list

/// Returns TRUE if the species can pick the hair or facial hair style, as in the preferences hair picker
/datum/gear_preset_builder/proc/is_style_allowed(datum/sprite_accessory/style, species_name)
	return istype(style) && style.selectable && (species_name in style.species_allowed)

/**
 * Pads the flat icon of the mannequin with transparency so the mannequin's own tile is in its middle
 *
 * getFlatIcon() grows the icon toward whichever side overlays stick out, by their pixel offsets, so a large
 * sprite that is not centered (zombie claws in hand) would push the mannequin into a corner of the picture.
 */
/datum/gear_preset_builder/proc/center_preview(icon/flat)
	// Pixels of the picture left of and below the mannequin's tile, found as getFlatIcon() places the overlays
	var/left = 0
	var/bottom = 0
	for(var/image/overlay as anything in mannequin.overlays + mannequin.underlays)
		if(overlay.alpha == 0 || (overlay.plane != FLOAT_PLANE && overlay.plane != mannequin.plane))
			continue
		left = max(left, -overlay.pixel_x)
		bottom = max(bottom, -overlay.pixel_y)
	var/margin_x = max(left, flat.Width() - world.icon_size - left)
	var/margin_y = max(bottom, flat.Height() - world.icon_size - bottom)
	flat.Crop(1 + left - margin_x, 1 + bottom - margin_y, left + world.icon_size + margin_x, bottom + world.icon_size + margin_y)

/// Returns the keys of an assoc list as a plain list, which the window gets as an array rather than an object
/datum/gear_preset_builder/proc/get_keys(list/assoc_list)
	var/list/keys = list()
	for(var/key in assoc_list)
		keys += key
	return keys

/// Turns the mannequin into the species, which presets do in load_race(), and fits its appearance to it
/datum/gear_preset_builder/proc/set_species(species_name)
	if(!GLOB.all_species[species_name] || mannequin.species?.name == species_name)
		return
	mannequin.set_species(species_name)
	apply_race_setup(mannequin)
	set_appearance(list())

/// Sets what the body sprites of the mob's species need besides set_species(), as the presets of that species do in load_race()
/datum/gear_preset_builder/proc/apply_race_setup(mob/living/carbon/human/target)
	if(target.species.name == SPECIES_YAUTJA)
		// As /datum/equipment_preset/yautja/load_race() does
		target.body_type = "pred"
		target.bubble_icon = "pred"
		if(!(target.skin_color in PRED_SKIN_COLOR))
			target.skin_color = pick(PRED_SKIN_COLOR)
		return
	target.bubble_icon = initial(target.bubble_icon)

/**
 * Returns the mannequin's appearance as the export stores it
 *
 * As list("gender" = "male" or "female", "skin_color", "body_type", "body_size", "underwear", "undershirt", "h_style", "f_style" = names,
 * "hair_color", "facial_hair_color", "eye_color" = "#rrggbb")
 */
/datum/gear_preset_builder/proc/get_appearance()
	return list(
		"gender" = mannequin.gender == FEMALE ? "female" : "male",
		"skin_color" = mannequin.skin_color,
		"body_type" = mannequin.body_type,
		"body_size" = mannequin.body_size,
		"underwear" = mannequin.underwear,
		"undershirt" = mannequin.undershirt,
		"h_style" = mannequin.h_style,
		"hair_color" = rgb(mannequin.r_hair, mannequin.g_hair, mannequin.b_hair),
		"f_style" = mannequin.f_style,
		"facial_hair_color" = rgb(mannequin.r_facial, mannequin.g_facial, mannequin.b_facial),
		"eye_color" = rgb(mannequin.r_eyes, mannequin.g_eyes, mannequin.b_eyes),
	)

/**
 * Changes a mob's appearance to the fields of appearance that are present and valid for its species
 *
 * Fields the species offers but the mob has an invalid value for, after a change of species or gender, get a valid one.
 * * appearance - as get_appearance() returns it
 * * target - the mob to change, the mannequin if null
 */
/datum/gear_preset_builder/proc/set_appearance(list/appearance, mob/living/carbon/human/target)
	if(!target)
		target = mannequin
	var/list/options = get_species_options(target.species.name)
	var/gender = appearance["gender"]
	if(gender == "male" || gender == "female")
		target.gender = gender == "female" ? FEMALE : MALE
		target.body_presentation = target.gender
	var/gender_key = target.gender == FEMALE ? "female" : "male"

	var/list/skin_names = list()
	for(var/list/skin as anything in options["skin_colors"])
		skin_names += skin["name"]
	target.skin_color = pick_valid(appearance["skin_color"], target.skin_color, skin_names, SKIN_COLOR_PALE2)
	target.body_type = pick_valid(appearance["body_type"], target.body_type, options["body_types"], BODY_TYPE_LEAN)
	target.body_size = pick_valid(appearance["body_size"], target.body_size, options["body_sizes"], BODY_SIZE_AVERAGE)
	if(options["underwear"])
		// Underwear is listed per gender, and a name from the other list would break the underwear overlays
		target.underwear = pick_valid(appearance["underwear"], target.underwear, options["underwear"][gender_key])
		target.undershirt = pick_valid(appearance["undershirt"], target.undershirt, options["undershirts"][gender_key])

	var/list/hair_names = list()
	for(var/list/style as anything in options["hair_styles"])
		hair_names += style["name"]
	target.h_style = pick_valid(appearance["h_style"], target.h_style, hair_names, "Bald")
	var/list/facial_hair_names = list()
	for(var/list/style as anything in options["facial_hair_styles"])
		if(style["gender"] == "any" || style["gender"] == gender_key)
			facial_hair_names += style["name"]
	target.f_style = pick_valid(appearance["f_style"], target.f_style, facial_hair_names, "Shaved")

	var/list/hair_color = parse_color(appearance["hair_color"])
	if(hair_color)
		target.r_hair = hair_color[1]
		target.g_hair = hair_color[2]
		target.b_hair = hair_color[3]
	var/list/facial_hair_color = parse_color(appearance["facial_hair_color"])
	if(facial_hair_color)
		target.r_facial = facial_hair_color[1]
		target.g_facial = facial_hair_color[2]
		target.b_facial = facial_hair_color[3]
	var/list/eye_color = parse_color(appearance["eye_color"])
	if(eye_color)
		target.r_eyes = eye_color[1]
		target.g_eyes = eye_color[2]
		target.b_eyes = eye_color[3]
	target.update_body()
	target.update_hair()
	target.regenerate_icons()
	if(target == mannequin)
		preview_outdated = TRUE

/**
 * Returns the value a field of the appearance should have
 *
 * * wanted - the value asked for, used if valid
 * * current - the value the mob has, kept if valid
 * * valid - the values the species offers; when empty, the field does not matter to it and current is kept
 * * preferred - the fallback when neither is valid, if valid itself, else the first of valid
 */
/datum/gear_preset_builder/proc/pick_valid(wanted, current, list/valid, preferred)
	if(!length(valid))
		return current
	if(istext(wanted) && (wanted in valid))
		return wanted
	if(current in valid)
		return current
	if(preferred in valid)
		return preferred
	return valid[1]

/// Returns a "#rrggbb" color as list(red, green, blue), or null if it is not one
/datum/gear_preset_builder/proc/parse_color(color)
	var/static/regex/color_format = regex(@"^#[0-9a-fA-F]{6}$")
	if(!istext(color) || !color_format.Find(color))
		return null
	return rgb2num(color)

/// Returns the `load_race()` code that turns a mob of the preset into the species, or null for humans
/datum/gear_preset_builder/proc/generate_race_code(species_name)
	if(species_name == SPECIES_HUMAN)
		return null
	var/list/lines = list(
		"/datum/equipment_preset/[preset_path]/load_race(mob/living/carbon/human/new_human, client/mob_client)",
		"\tnew_human.set_species(\"[species_name]\")",
	)
	if(species_name == SPECIES_YAUTJA)
		// What apply_race_setup() does, as /datum/equipment_preset/yautja/load_race() does
		lines += "\tnew_human.skin_color = pick(PRED_SKIN_COLOR)"
		lines += "\tnew_human.body_type = \"pred\""
		lines += "\tnew_human.bubble_icon = \"pred\""
	return jointext(lines, "\n")

/**
 * Returns the `load_name()` code that gives a mob of the preset the appearance
 *
 * Only writes the fields that change how the species looks, see get_species_options().
 * * appearance - as get_appearance() returns it
 * * species_name - the species of the mob
 */
/datum/gear_preset_builder/proc/generate_appearance_code(list/appearance, species_name)
	var/list/options = get_species_options(species_name)
	var/gender_define = appearance["gender"] == "female" ? "FEMALE" : "MALE"
	var/list/lines = list(
		"/datum/equipment_preset/[preset_path]/load_name(mob/living/carbon/human/new_human, randomise, client/mob_client)",
		"\tnew_human.gender = [gender_define]",
		"\tnew_human.body_presentation = [gender_define]",
	)
	if(species_name == SPECIES_YAUTJA)
		// As /datum/equipment_preset/yautja/load_name() does
		lines += "\tnew_human.change_real_name(new_human, \"\[capitalize(pick(GLOB.pred_names))\] \[capitalize(pick(GLOB.pred_last_names))\]\")"
		lines += "\tnew_human.age = rand(100, 150)"
	else
		lines += "\tnew_human.change_real_name(new_human, random_name(new_human.gender))"
		lines += "\tnew_human.age = rand(21, 45)"
	if(length(options["skin_colors"]))
		lines += "\tnew_human.skin_color = \"[appearance["skin_color"]]\""
	if(length(options["body_types"]))
		lines += "\tnew_human.body_type = \"[appearance["body_type"]]\""
		lines += "\tnew_human.body_size = \"[appearance["body_size"]]\""
	if(options["underwear"])
		lines += "\tnew_human.underwear = \"[appearance["underwear"]]\""
		lines += "\tnew_human.undershirt = \"[appearance["undershirt"]]\""
	if(length(options["hair_styles"]))
		lines += "\tnew_human.h_style = \"[appearance["h_style"]]\""
		if(options["hair_colored"])
			lines += color_code_lines("hair", appearance["hair_color"])
	if(length(options["facial_hair_styles"]))
		lines += "\tnew_human.f_style = \"[appearance["f_style"]]\""
		lines += color_code_lines("facial", appearance["facial_hair_color"])
	lines += color_code_lines("eyes", appearance["eye_color"])
	lines += "\tnew_human.update_body()"
	lines += "\tnew_human.update_hair()"
	return jointext(lines, "\n")

/// Returns the code lines that set the red, green and blue vars of a mob's color, named r_[suffix] and so on
/datum/gear_preset_builder/proc/color_code_lines(suffix, color)
	var/list/channels = rgb2num(color)
	return list(
		"\tnew_human.r_[suffix] = [channels[1]]",
		"\tnew_human.g_[suffix] = [channels[2]]",
		"\tnew_human.b_[suffix] = [channels[3]]",
	)

// Code export

/**
 * Returns what an item type spawns with
 *
 * As list("tree" = item tree, "containers" = list, "random" = boolean), where "containers" has, per container from
 * get_containers(), the expression it is reached by from the item in the exported code ("" for the item itself,
 * ".pockets" for its pockets), or null if no variable refers to it, and "random" is TRUE if the type spawns with
 * different contents each time.
 */
/datum/gear_preset_builder/proc/get_default_info(item_type)
	if(default_info[item_type])
		return default_info[item_type]
	var/obj/item/item = new item_type()
	var/list/container_expressions = list()
	for(var/atom/container as anything in get_containers(item))
		if(container == item)
			container_expressions += ""
			continue
		var/variable_name = get_container_variable(item, container)
		container_expressions += variable_name ? ".[variable_name]" : null
	var/list/tree = serialize_item(item)
	qdel(item)

	var/is_random = FALSE
	for(var/i in 1 to 2)
		var/obj/item/sample = new item_type()
		var/list/sample_tree = serialize_item(sample)
		qdel(sample)
		if(!trees_match(tree, sample_tree, check_random = FALSE))
			is_random = TRUE
			break

	var/list/info = list(
		"tree" = tree,
		"containers" = container_expressions,
		"random" = is_random,
	)
	default_info[item_type] = info
	return info

/**
 * Returns TRUE if two item trees describe the same gear
 *
 * Items of a type with random contents match if neither was edited.
 * * check_random - FALSE to compare the contents even for such types, used to find out whether a type is one
 */
/datum/gear_preset_builder/proc/trees_match(list/tree, list/other, check_random = TRUE)
	if(!islist(tree) || !islist(other) || tree["type"] != other["type"])
		return FALSE
	if(check_random)
		var/list/info = get_default_info(text2path(tree["type"]))
		if(info["random"])
			return !tree["edited"] && !other["edited"]
	if(!children_match(tree["accessories"], other["accessories"]))
		return FALSE
	var/list/contents = islist(tree["contents"]) ? tree["contents"] : list()
	var/list/other_contents = islist(other["contents"]) ? other["contents"] : list()
	if(length(contents) != length(other_contents))
		return FALSE
	for(var/i in 1 to length(contents))
		if(!children_match(contents[i], other_contents[i]))
			return FALSE
	return TRUE

/// Returns TRUE if two lists of item trees describe the same gear in any order
/datum/gear_preset_builder/proc/children_match(list/children, list/other_children)
	var/list/unmatched = islist(other_children) ? other_children.Copy() : list()
	if(!islist(children))
		children = list()
	if(length(children) != length(unmatched))
		return FALSE
	for(var/list/child as anything in children)
		var/found = FALSE
		for(var/list/other_child as anything in unmatched)
			if(trees_match(child, other_child))
				unmatched -= list(other_child)
				found = TRUE
				break
		if(!found)
			return FALSE
	return TRUE

/**
 * Compares an item tree with what its type spawns with
 *
 * Returns list("accessories" = list(trees), "contents" = list(list(trees) per container)) with what the tree adds
 * on top of the defaults, or null if the tree also lacks some of them
 */
/datum/gear_preset_builder/proc/get_additions(list/tree)
	var/list/info = get_default_info(text2path(tree["type"]))
	var/list/additions = list("accessories" = list(), "contents" = list())
	if(info["random"])
		return tree["edited"] ? null : additions
	var/list/default_tree = info["tree"]
	if(islist(tree["accessories"]))
		var/list/added = get_added_children(tree["accessories"], default_tree["accessories"])
		if(!added)
			return null
		additions["accessories"] = added
	var/list/default_contents = default_tree["contents"]
	var/list/contents = tree["contents"]
	for(var/i in 1 to length(default_contents))
		if(!islist(contents))
			additions["contents"] += list(list())
			continue
		var/list/added = get_added_children(i <= length(contents) ? contents[i] : list(), default_contents[i])
		if(!added)
			return null
		additions["contents"] += list(added)
	return additions

/// Returns the trees in children that are not in default_children, or null if some of default_children are missing
/datum/gear_preset_builder/proc/get_added_children(list/children, list/default_children)
	var/list/added = islist(children) ? children.Copy() : list()
	if(!islist(default_children))
		return added
	for(var/list/default_child as anything in default_children)
		var/found = FALSE
		for(var/list/child as anything in added)
			if(trees_match(child, default_child))
				added -= list(child)
				found = TRUE
				break
		if(!found)
			return null
	return added

/// Returns TRUE if the item tree is a medal, which the exported code has to award to the mob before attaching it
/datum/gear_preset_builder/proc/is_medal(list/tree)
	return ispath(text2path(tree["type"]), /obj/item/clothing/accessory/medal)

/// Returns TRUE if the item tree is exactly what its type spawns with
/datum/gear_preset_builder/proc/is_default(list/tree)
	var/list/additions = get_additions(tree)
	if(!additions || length(additions["accessories"]))
		return FALSE
	for(var/list/added as anything in additions["contents"])
		if(length(added))
			return FALSE
	return TRUE

/**
 * Returns the code of the preset: its type, the `load_gear()` of the gear and, when needed, its `load_race()` and `load_name()`
 *
 * * slots - the gear, as list(slot = item tree)
 * * appearance - the appearance as get_appearance() returns it, or null to leave the mob's looks random
 * * species_name - the species of the mob, a `load_race()` is written for any other than human
 */
/datum/gear_preset_builder/proc/generate_code(list/slots, list/appearance, species_name = SPECIES_HUMAN)
	var/list/lines = list()
	// Names the generated code already uses
	var/list/used_names = list("new_human" = TRUE, "thing" = TRUE, "attached" = TRUE)
	for(var/slot in slot_names)
		var/list/tree = slots[slot]
		if(islist(tree))
			add_slot_code(slot, tree, lines, used_names)
	var/list/code = list(
		"/datum/equipment_preset/[preset_path]",
		"\tname = \"[replacetext(preset_name, "\"", "\\\"")]\"",
	)
	if(appearance)
		// load_name() only runs for presets that randomise the mob unless this is set
		code += "\tuses_special_name = TRUE"
	code += ""
	var/race_code = generate_race_code(species_name)
	if(race_code)
		code += race_code
		code += ""
	if(appearance)
		code += generate_appearance_code(appearance, species_name)
		code += ""
	code += "/datum/equipment_preset/[preset_path]/load_gear(mob/living/carbon/human/new_human)"
	for(var/line in lines)
		code += "\t[line]"
	return jointext(code, "\n")

/// Adds to lines the code that equips the item tree in the slot
/datum/gear_preset_builder/proc/add_slot_code(slot, list/tree, list/lines, list/used_names)
	var/list/additions = get_additions(tree)
	if(additions && can_add_through_slots(slot, tree, additions))
		lines += "new_human.equip_to_slot_or_del(new [tree["type"]](new_human), [slot_defines[slot]])"
		for(var/list/accessory_tree as anything in additions["accessories"])
			add_child_code(accessory_tree, "WEAR_ACCESSORY", lines, used_names)
		var/list/container_expressions = get_default_info(text2path(tree["type"]))["containers"]
		for(var/i in 1 to length(additions["contents"]))
			var/in_slot = get_in_slot_define(slot, tree, container_expressions[i])
			for(var/list/child_tree as anything in additions["contents"][i])
				add_child_code(child_tree, in_slot, lines, used_names)
		return
	var/variable_name = add_variable_code(tree, "new_human", slot_variables[slot], lines, used_names)
	lines += "new_human.equip_to_slot_or_del([variable_name], [slot_defines[slot]])"

/// Returns TRUE if everything the tree adds can be put on with WEAR_ACCESSORY and WEAR_IN_* after the item is worn in the slot
/datum/gear_preset_builder/proc/can_add_through_slots(slot, list/tree, list/additions)
	if(length(additions["accessories"]) && slot != WEAR_BODY)
		return FALSE
	var/list/container_expressions = get_default_info(text2path(tree["type"]))["containers"]
	for(var/i in 1 to length(additions["contents"]))
		if(length(additions["contents"][i]) && !get_in_slot_define(slot, tree, container_expressions[i]))
			return FALSE
	return TRUE

/// Returns the WEAR_IN_* define that reaches a container of the item worn in the slot, or null if none does
/datum/gear_preset_builder/proc/get_in_slot_define(slot, list/tree, container_expression)
	var/item_type = text2path(tree["type"])
	if(container_expression == "")
		if(ispath(item_type, /obj/item/clothing/shoes))
			return slot == WEAR_FEET ? "WEAR_IN_SHOES" : null
		return storage_slot_defines[slot]
	if(container_expression != ".pockets")
		return null
	if(slot == WEAR_JACKET && ispath(item_type, /obj/item/clothing/suit/storage))
		return "WEAR_IN_JACKET"
	if(slot == WEAR_HEAD && ispath(item_type, /obj/item/clothing/head/helmet/marine))
		return "WEAR_IN_HELMET"
	return null

/// Adds to lines the code that puts the item tree into the mob through a WEAR_* define
/datum/gear_preset_builder/proc/add_child_code(list/tree, slot_define, list/lines, list/used_names)
	if(is_default(tree) && !is_medal(tree))
		lines += "new_human.equip_to_slot_or_del(new [tree["type"]](new_human), [slot_define])"
		return
	var/variable_name = add_variable_code(tree, "new_human", null, lines, used_names)
	lines += "new_human.equip_to_slot_or_del([variable_name], [slot_define])"

/**
 * Adds to lines the code that creates the item tree in a variable, with its accessories and contents
 *
 * Returns the name of the variable
 * * tree - the item tree
 * * location - code of the atom the item is created in
 * * base_name - name for the variable, or null to name it after the type
 * * lines - list of code lines to add to
 * * used_names - variable names taken so far, as list(name = TRUE)
 */
/datum/gear_preset_builder/proc/add_variable_code(list/tree, location, base_name, list/lines, list/used_names)
	var/list/path_parts = splittext(tree["type"], "/")
	var/variable_name = base_name || path_parts[length(path_parts)]
	if(used_names[variable_name])
		var/number = 2
		while(used_names["[variable_name]_[number]"])
			number++
		variable_name = "[variable_name]_[number]"
	used_names[variable_name] = TRUE

	lines += "var[tree["type"]]/[variable_name] = new([location])"
	if(is_medal(tree))
		// A medal only attaches for its recipient, see attach_accessory_for()
		lines += "[variable_name].recipient_name = new_human.real_name"
	var/list/info = get_default_info(text2path(tree["type"]))
	var/list/container_expressions = info["containers"]
	var/list/additions = get_additions(tree)
	var/list/accessories_to_add
	var/list/contents_to_add
	if(additions)
		accessories_to_add = additions["accessories"]
		contents_to_add = additions["contents"]
	else
		// Something it spawns with was taken out, so it is emptied and filled from scratch
		accessories_to_add = islist(tree["accessories"]) ? tree["accessories"] : list()
		contents_to_add = islist(tree["contents"]) ? tree["contents"] : list()
		if(islist(tree["accessories"]) && length(info["tree"]["accessories"]))
			lines += "for(var/obj/item/clothing/accessory/attached as anything in [variable_name].accessories.Copy())"
			lines += "\t[variable_name].remove_accessory(null, attached)"
			lines += "\tqdel(attached)"
		var/list/default_contents = info["tree"]["contents"]
		for(var/i in 1 to length(default_contents))
			if(!length(default_contents[i]) || !islist(tree["contents"]))
				continue
			if(isnull(container_expressions[i]))
				lines += "// TODO: empty container [i] of [variable_name], no variable refers to it"
			else if(container_expressions[i] == "" && ispath(text2path(tree["type"]), /obj/item/clothing/shoes))
				lines += "QDEL_NULL([variable_name].stored_item)"
			else
				lines += "for(var/obj/item/thing in [variable_name][container_expressions[i]])"
				lines += "\tqdel(thing)"

	for(var/list/accessory_tree as anything in accessories_to_add)
		if(is_default(accessory_tree) && !is_medal(accessory_tree))
			lines += "[variable_name].attach_accessory(new_human, new [accessory_tree["type"]]([variable_name]), TRUE)"
		else
			var/accessory_name = add_variable_code(accessory_tree, variable_name, null, lines, used_names)
			lines += "[variable_name].attach_accessory(new_human, [accessory_name], TRUE)"

	for(var/i in 1 to min(length(contents_to_add), length(container_expressions)))
		var/container_expression = container_expressions[i]
		for(var/list/child_tree as anything in contents_to_add[i])
			if(isnull(container_expression))
				lines += "// TODO: put [child_tree["type"]] into container [i] of [variable_name], no variable refers to it"
				continue
			var/is_shoes = container_expression == "" && ispath(text2path(tree["type"]), /obj/item/clothing/shoes)
			var/container_code = "[variable_name][container_expression]"
			if(is_shoes)
				container_code = "new_human"
			var/child_code
			if(is_default(child_tree))
				child_code = "new [child_tree["type"]]([container_code])"
			else
				child_code = add_variable_code(child_tree, container_code, null, lines, used_names)
			if(is_shoes)
				lines += "[variable_name].attempt_insert_item(new_human, [child_code])"
			else if(is_default(child_tree))
				lines += child_code
	return variable_name

#undef GEAR_BUILDER_DESC_LENGTH
#undef GEAR_BUILDER_IMPORT_MAX_PARTS
#undef GEAR_BUILDER_EXPORT_FOLDER
