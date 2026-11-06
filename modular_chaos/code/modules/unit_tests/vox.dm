// The Vox of the Baystation 12 universe (modular_chaos/universes/bay12/), which is included after this file:
// its types are known here, its defines aren't.

/// Slot in which each kind of Vox clothing is worn, for /datum/unit_test/vox_sprites
#define VOX_CLOTHING_SLOTS list( \
	/obj/item/clothing/under = WEAR_BODY, \
	/obj/item/clothing/suit = WEAR_JACKET, \
	/obj/item/clothing/head = WEAR_HEAD, \
	/obj/item/clothing/mask = WEAR_FACE, \
	/obj/item/clothing/gloves = WEAR_HANDS, \
	/obj/item/clothing/shoes = WEAR_FEET, \
)

/// Every Vox clothing is only for the Vox and has its icon state, and the state it is worn in in the sheet a Vox wears it from; every Vox hair style has its state
/datum/unit_test/vox_sprites

/datum/unit_test/vox_sprites/Run()
	var/datum/species/vox/vox_species = GLOB.all_species["Vox"]
	TEST_ASSERT(istype(vox_species), "The Vox species isn't in GLOB.all_species")
	var/vox_bodytype = vox_species.get_bodytype()
	var/list/clothing_slots = VOX_CLOTHING_SLOTS
	// The base types of the sets have no icon state of their own, only their subtypes
	var/list/vox_clothing_types = list()
	for(var/base_type in list(/obj/item/clothing/under/vox, /obj/item/clothing/suit/armor/vox, /obj/item/clothing/suit/space/vox, /obj/item/clothing/head/helmet/vox, /obj/item/clothing/head/helmet/space/vox))
		vox_clothing_types += subtypesof(base_type)
	for(var/clothing_type in list(/obj/item/clothing/suit/armor/vox_scrap, /obj/item/clothing/suit/storage/vox, /obj/item/clothing/mask/gas/vox, /obj/item/clothing/mask/gas/swat/vox, /obj/item/clothing/gloves/vox, /obj/item/clothing/shoes/vox_magclaws))
		vox_clothing_types += typesof(clothing_type)
	for(var/clothing_type in vox_clothing_types)
		var/obj/item/clothing/clothing = allocate(clothing_type)
		TEST_ASSERT(islist(clothing.species_restricted) && clothing.species_restricted[1] != "exclude" && (vox_bodytype in clothing.species_restricted), "[clothing_type] isn't only for the Vox")
		TEST_ASSERT(icon_exists(clothing.icon, clothing.icon_state), "[clothing_type] has no icon state [clothing.icon_state] in [clothing.icon]")
		var/slot
		for(var/kind in clothing_slots)
			if(istype(clothing, kind))
				slot = clothing_slots[kind]
				break
		if(!slot)
			continue
		var/sheet = LAZYACCESS(clothing.sprite_sheets, vox_bodytype)
		TEST_ASSERT(sheet, "[clothing_type] is worn only by the Vox but has no Vox sprite sheet")
		var/worn_state = clothing.get_icon_state(null, slot)
		TEST_ASSERT(icon_exists(sheet, worn_state), "[clothing_type] is worn as [worn_state], which [sheet] doesn't have")

	for(var/style_name in GLOB.hair_styles_list)
		var/datum/sprite_accessory/hair/style = GLOB.hair_styles_list[style_name]
		if(!(vox_species.name in style.species_allowed))
			continue
		TEST_ASSERT(icon_exists(style.icon, "[style.icon_state]_s"), "Vox hair style [style_name] has no state [style.icon_state]_s in [style.icon]")

/// A Vox wears only clothing that fits it, gets its mask and nitrogen tank with an equipment preset, and suffocates and is poisoned by air but breathes nitrogen
/datum/unit_test/vox_body

/datum/unit_test/vox_body/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human)
	vox.set_species("Vox")
	TEST_ASSERT(istype(vox.species, /datum/species/vox), "A human didn't become a Vox")
	TEST_ASSERT(vox.internal_organs_by_name["cortical stack"], "A Vox has no cortical stack")
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	// Only the slots of the HUD can be equipped, which equipment presets create
	vox.create_hud()
	human.create_hud()

	var/obj/item/clothing/gloves/human_gloves = allocate(/obj/item/clothing/gloves/black)
	TEST_ASSERT(!vox.equip_to_slot_if_possible(human_gloves, WEAR_HANDS, disable_warning = TRUE), "A Vox put on human gloves")
	TEST_ASSERT(human.equip_to_slot_if_possible(human_gloves, WEAR_HANDS, disable_warning = TRUE), "A human didn't put on human gloves")
	var/obj/item/clothing/gloves/vox_gloves = allocate(/obj/item/clothing/gloves/vox)
	TEST_ASSERT(vox.equip_to_slot_if_possible(vox_gloves, WEAR_HANDS, disable_warning = TRUE), "A Vox didn't put on Vox gauntlets")
	var/obj/item/clothing/gloves/other_vox_gloves = allocate(/obj/item/clothing/gloves/vox)
	TEST_ASSERT(!human.equip_to_slot_if_possible(other_vox_gloves, WEAR_HANDS, disable_warning = TRUE), "A human put on Vox gauntlets")

	vox.species.equip_survival_gear(vox)
	TEST_ASSERT(istype(vox.wear_mask, /obj/item/clothing/mask/gas/vox), "A Vox didn't get a Vox breathing mask")
	TEST_ASSERT(istype(vox.internal, /obj/item/tank/emergency_nitrogen), "A Vox doesn't breathe from a nitrogen tank")

	var/oxyloss = vox.getOxyLoss()
	var/toxloss = vox.getToxLoss()
	vox.handle_breath(list(GAS_TYPE_AIR, T20C, ONE_ATMOSPHERE))
	TEST_ASSERT(vox.getOxyLoss() > oxyloss, "A Vox didn't suffocate on air")
	TEST_ASSERT(vox.getToxLoss() > toxloss, "A Vox wasn't poisoned by air")
	toxloss = vox.getToxLoss()
	vox.handle_breath(list(GAS_TYPE_NITROGEN, T20C, ONE_ATMOSPHERE))
	TEST_ASSERT_EQUAL(vox.getToxLoss(), toxloss, "A Vox was poisoned by nitrogen")

#undef VOX_CLOTHING_SLOTS
