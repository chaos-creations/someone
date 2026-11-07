// Rigs of the Baystation 12 universe (modular_chaos/universes/bay12/code/modules/clothing/spacesuits/rig/), which is
// included after this file: its types are known here, its defines aren't.

/// Every rig has its sprites: the control module, the worn one, its pieces unsealed and sealed, worn by whoever they fit; every module has its sprite and overlays
/datum/unit_test/rig_sprites

/datum/unit_test/rig_sprites/Run()
	var/datum/species/vox/vox_species = GLOB.all_species["Vox"]
	var/vox_bodytype = vox_species.get_bodytype()
	var/list/piece_slots = list(WEAR_HEAD, WEAR_JACKET, WEAR_HANDS, WEAR_FEET)
	for(var/rig_type in typesof(/obj/item/rig))
		var/obj/item/rig/rig = allocate(rig_type)
		TEST_ASSERT(icon_exists(rig.icon, rig.icon_state), "[rig_type] has no icon state [rig.icon_state] in [rig.icon]")
		var/image/back_overlay = rig.get_mob_overlay(slot = WEAR_BACK, default_bodytype = "Human")
		TEST_ASSERT(icon_exists(back_overlay.icon, back_overlay.icon_state), "[rig_type] is worn as [back_overlay.icon_state], which [back_overlay.icon] doesn't have")
		if(rig.helmet_overlay_state)
			TEST_ASSERT(icon_exists(rig.icon, rig.helmet_overlay_state), "[rig_type] draws [rig.helmet_overlay_state] over its helmet, which [rig.icon] doesn't have")
		for(var/obj/item/clothing/piece as anything in rig.get_pieces())
			var/slot = rig.get_piece_slot(piece)
			TEST_ASSERT(slot in piece_slots, "[piece.type] of [rig_type] has no slot")
			var/vox_only = islist(piece.species_restricted) && piece.species_restricted[1] != "exclude" && (vox_bodytype in piece.species_restricted)
			for(var/sealed in list(FALSE, TRUE))
				var/state = rig.get_piece_state(piece, sealed)
				TEST_ASSERT(icon_exists(piece.icon, state), "[piece.type] of [rig_type] has no icon state [state] in [piece.icon]")
				piece.icon_state = state
				var/worn_icon
				var/worn_state
				// The Vox sheets fall back to the human sprites, which would hide a missing Vox one
				if(vox_only)
					worn_icon = LAZYACCESS(piece.sprite_sheets, vox_bodytype)
					worn_state = piece.get_icon_state(null, slot)
				else
					var/image/worn_overlay = piece.get_mob_overlay(slot = slot, default_bodytype = "Human")
					worn_icon = worn_overlay.icon
					worn_state = worn_overlay.icon_state
				TEST_ASSERT(worn_icon && icon_exists(worn_icon, worn_state), "[piece.type] of [rig_type] is worn as [worn_state], which [worn_icon] doesn't have")

	for(var/module_type in typesof(/obj/item/rig_module))
		var/obj/item/rig_module/module = allocate(module_type)
		// The plain module box is the unnamed state, which icon_exists() doesn't take
		if(module.icon_state)
			TEST_ASSERT(icon_exists(module.icon, module.icon_state), "[module_type] has no icon state [module.icon_state] in [module.icon]")
		for(var/overlay_state in list(module.suit_overlay_active, module.suit_overlay_inactive))
			if(overlay_state)
				TEST_ASSERT(icon_exists(module.suit_overlay_icon, overlay_state), "[module_type] has no overlay [overlay_state] in [module.suit_overlay_icon]")

/// A rig on the back seals around a human over their own gloves, powers its modules from its cell, holds items in its storage, feeds its air tank to the sealed helmet, and comes off once unsealed, giving the gloves back
/datum/unit_test/rig_wearing

/datum/unit_test/rig_wearing/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	// Only the slots of the HUD can be equipped
	human.create_hud()
	var/obj/item/clothing/gloves/own_gloves = allocate(/obj/item/clothing/gloves/black)
	TEST_ASSERT(human.equip_to_slot_if_possible(own_gloves, WEAR_HANDS, disable_warning = TRUE), "A human couldn't put on gloves")
	var/obj/item/rig/rig = allocate(/obj/item/rig/infantry)
	rig.seal_delay = 0
	rig.install_module(new /obj/item/rig_module/vision/night(rig))
	TEST_ASSERT(human.equip_to_slot_if_possible(rig, WEAR_BACK, disable_warning = TRUE), "A human couldn't put a rig on the back")
	TEST_ASSERT_EQUAL(rig.wearer, human, "A rig on the back of a human doesn't count them as its wearer")

	rig.toggle_suit(human)
	TEST_ASSERT(rig.sealed && rig.online, "A rig with a charged cell didn't seal and come online")
	TEST_ASSERT_EQUAL(human.head, rig.helmet, "A sealed rig didn't deploy its helmet")
	TEST_ASSERT_EQUAL(human.wear_suit, rig.chest, "A sealed rig didn't deploy its chestpiece")
	TEST_ASSERT_EQUAL(human.gloves, rig.gloves, "A sealed rig didn't deploy its gauntlets over the wearer's gloves")
	TEST_ASSERT_EQUAL(own_gloves.loc, rig.gloves, "The gloves under the gauntlets of a rig aren't kept in them")
	TEST_ASSERT_EQUAL(human.shoes, rig.boots, "A sealed rig didn't deploy its boots")
	TEST_ASSERT_EQUAL(rig.chest.slowdown, rig.online_slowdown, "An online rig slows its wearer as much as an offline one")
	TEST_ASSERT(!human.drop_inv_item_on_ground(rig), "A sealed rig came off its wearer")

	rig.select_module(rig.visor)
	rig.visor.use_module()
	TEST_ASSERT(rig.visor.active, "The vision module of an online rig didn't turn on")
	var/charge_before = rig.cell.charge
	rig.process(2)
	TEST_ASSERT(rig.cell.charge < charge_before, "An online rig with an active module took no charge from its cell")

	var/obj/item/tool/screwdriver/screwdriver = allocate(/obj/item/tool/screwdriver)
	TEST_ASSERT(rig.storage?.container.handle_item_insertion(screwdriver, TRUE, human), "The storage module of a rig didn't take a screwdriver")
	TEST_ASSERT_EQUAL(screwdriver.loc, rig.storage.container, "A screwdriver put into a rig isn't in its storage")

	rig.toggle_air_supply(human)
	TEST_ASSERT_EQUAL(human.internal, rig.air_supply, "The air tank of a sealed rig didn't open to its wearer")
	TEST_ASSERT(human.get_breath_from_internal(), "The wearer of a sealed rig doesn't breathe from its air tank")

	rig.cell.charge = 0
	rig.process(2)
	TEST_ASSERT(!rig.online && !rig.visor.active, "A rig without charge stayed online")
	TEST_ASSERT_EQUAL(rig.chest.slowdown, rig.offline_slowdown, "An offline rig doesn't slow its wearer as much as it should")

	rig.toggle_suit(human)
	TEST_ASSERT(!rig.sealed, "A rig didn't unseal")
	TEST_ASSERT(!human.head && !human.wear_suit && !human.shoes, "An unsealed rig left its pieces on its wearer")
	TEST_ASSERT_EQUAL(human.gloves, own_gloves, "An unsealed rig didn't give its wearer their gloves back")
	TEST_ASSERT(!human.internal, "The air tank of an unsealed rig stayed open")
	TEST_ASSERT(human.drop_inv_item_on_ground(rig), "An unsealed rig couldn't be taken off")
	TEST_ASSERT(!rig.wearer, "A rig on the floor still has a wearer")

/// A Vox seals only into a Vox rig, and a human not into one
/datum/unit_test/rig_species

/datum/unit_test/rig_species/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human)
	vox.set_species("Vox")
	vox.create_hud()
	var/obj/item/rig/vox_rig = allocate(/obj/item/rig/vox/inq)
	vox_rig.seal_delay = 0
	TEST_ASSERT(vox.equip_to_slot_if_possible(vox_rig, WEAR_BACK, disable_warning = TRUE), "A Vox couldn't put a Vox rig on the back")
	vox_rig.toggle_suit(vox)
	TEST_ASSERT(vox_rig.sealed, "A Vox rig didn't seal around a Vox")
	vox_rig.toggle_suit(vox)
	vox.drop_inv_item_on_ground(vox_rig)

	var/obj/item/rig/human_rig = allocate(/obj/item/rig/infantry)
	human_rig.seal_delay = 0
	vox.equip_to_slot_if_possible(human_rig, WEAR_BACK, disable_warning = TRUE)
	human_rig.toggle_suit(vox)
	TEST_ASSERT(!human_rig.sealed, "An infantry rig sealed around a Vox")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.create_hud()
	vox.drop_inv_item_on_ground(human_rig)
	vox_rig.forceMove(get_turf(human))
	human.equip_to_slot_if_possible(vox_rig, WEAR_BACK, disable_warning = TRUE)
	vox_rig.toggle_suit(human)
	TEST_ASSERT(!vox_rig.sealed, "A Vox rig sealed around a human")
