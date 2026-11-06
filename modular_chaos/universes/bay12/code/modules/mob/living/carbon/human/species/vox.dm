/**
 * The Vox, beaked and quilled reptilian scavengers who breathe nitrogen, ported from Baystation 12 (code/modules/species/outsider/vox.dm)
 *
 * Oxygen poisons them, so they need their own mask and a nitrogen tank (see equip_survival_gear()). Their hands, feet and
 * beak take only their own gloves, footwear and masks; other clothing is drawn from the Vox sprite sheets where those have
 * it, and with the human sprite where they don't (sprite_sheet_fallback).
 */
/datum/species/vox
	group = SPECIES_VOX
	name = SPECIES_VOX
	name_plural = "Vox"
	icobase = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/body_bos.dmi'
	deform = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/body_bos.dmi'
	eye_icon = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/eyes_bos.dmi'
	eyes = ""
	flags = HAS_HARDCRIT
	mob_flags = KNOWS_TECHNOLOGY
	unarmed_type = /datum/unarmed_attack/claws/vox
	secondary_unarmed_type = /datum/unarmed_attack/bite/vox
	speech_sounds = list('modular_chaos/universes/bay12/sound/voice/shriek1.ogg')
	speech_chance = 20
	death_message = "lets out a faint, rattling shriek as it collapses and stops moving..."

	breath_type = GAS_TYPE_NITROGEN
	breathable_gases = list(GAS_TYPE_NITROGEN, GAS_TYPE_N2O)
	poisonous_gases = list(GAS_TYPE_OXYGEN, GAS_TYPE_AIR)
	innate_languages = list(LANGUAGE_VOX)
	sprite_sheet_fallback = TRUE

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = -1

	blood_color = "#2299fc"
	flesh_color = "#808d11"

	has_organ = list(
		"heart" = /datum/internal_organ/heart/vox,
		"lungs" = /datum/internal_organ/lungs/vox,
		"liver" = /datum/internal_organ/liver/vox,
		"kidneys" = /datum/internal_organ/kidneys/vox,
		"brain" = /datum/internal_organ/brain,
		"eyes" = /datum/internal_organ/eyes/vox,
		"gizzard" = /datum/internal_organ/vox_gizzard,
		"cortical stack" = /datum/internal_organ/vox_stack,
		"hindtongue" = /datum/internal_organ/vox_hindtongue,
	)

/datum/species/vox/handle_post_spawn(mob/living/carbon/human/vox)
	for(var/language in innate_languages)
		vox.add_language(language)
	return ..()

/**
 * Gives the Vox a Vox breathing mask and an emergency nitrogen tank, and opens the tank
 *
 * The mask goes on the face, or in a hand when the face is taken. The tank goes on the belt, then the suit storage,
 * a pocket or a hand, wherever it fits first.
 */
/datum/species/vox/equip_survival_gear(mob/living/carbon/human/vox)
	// Already breathing from a tank they carry, after a preset was loaded on them again
	if(vox.internal?.loc == vox)
		return
	var/obj/item/clothing/mask/mask = vox.wear_mask
	if(!istype(mask) || !(mask.flags_inventory & ALLOWINTERNALS))
		mask = new /obj/item/clothing/mask/gas/vox(vox)
		if(!vox.equip_to_slot_if_possible(mask, WEAR_FACE, disable_warning = TRUE))
			vox.put_in_hands(mask)
	var/obj/item/tank/emergency_nitrogen/tank = new(vox)
	if(!vox.equip_to_appropriate_slot(tank, slot_equipment_priority = list(WEAR_WAIST, WEAR_J_STORE, WEAR_L_STORE, WEAR_R_STORE)))
		vox.put_in_hands(tank)
	if(vox.wear_mask == mask && tank.loc == vox)
		vox.internal = tank
