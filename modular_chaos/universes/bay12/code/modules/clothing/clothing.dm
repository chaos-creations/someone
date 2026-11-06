/// Slots in which clothing has to fit the body of the species (/obj/item/clothing/var/species_restricted)
#define SPECIES_FITTED_SLOTS list(WEAR_BODY, WEAR_JACKET, WEAR_HEAD, WEAR_HANDS, WEAR_FEET, WEAR_FACE, WEAR_EYES)

/obj/item/clothing
	/**
	 * Body types (/datum/species/proc/get_bodytype()) that can wear this, or, when the list starts with "exclude",
	 * the ones that can't; null for everyone. Checked only in SPECIES_FITTED_SLOTS, as Baystation 12 does it.
	 */
	var/list/species_restricted

/obj/item/clothing/Initialize(mapload, ...)
	. = ..()
	var/list/species_sheets = get_default_species_sprite_sheets()
	for(var/bodytype in species_sheets)
		if(!LAZYISIN(sprite_sheets, bodytype))
			LAZYSET(sprite_sheets, bodytype, species_sheets[bodytype])

/**
 * Returns the sprite sheets by body type every clothing of this kind has unless it sets its own, or null
 *
 * Like upstream gives monkeys their sheets on the base types of clothing, the Vox get theirs here, so that every
 * clothing that has a state in them is drawn on a Vox in its Vox version.
 */
/obj/item/clothing/proc/get_default_species_sprite_sheets()
	return null

/obj/item/clothing/mob_can_equip(mob/equipping_mob, slot, disable_warning = FALSE)
	if(ishuman(equipping_mob) && (slot in SPECIES_FITTED_SLOTS) && !fits_species(equipping_mob))
		if(!disable_warning)
			to_chat(equipping_mob, SPAN_WARNING("[src] doesn't fit your body."))
		return FALSE
	return ..()

/**
 * Returns whether the human's species can wear this, see species_restricted
 *
 * Arguments:
 * * human - the human trying to wear it
 */
/obj/item/clothing/proc/fits_species(mob/living/carbon/human/human)
	if(!length(species_restricted) || !human.species)
		return TRUE
	var/bodytype = human.species.get_bodytype(human)
	if(species_restricted[1] == "exclude")
		return !(bodytype in species_restricted)
	return (bodytype in species_restricted)

/obj/item/clothing/under/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/under_bos.dmi')
	return sheets

/obj/item/clothing/suit/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/suit_bos.dmi')
	return sheets

/obj/item/clothing/head/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/head_bos.dmi')
	return sheets

/obj/item/clothing/glasses/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/eyes_bos.dmi')
	return sheets

// Masks, gloves and shoes don't fit the beak, the talons and the claws of a Vox, who wear their own

/obj/item/clothing/mask
	species_restricted = list("exclude", SPECIES_VOX)

/obj/item/clothing/mask/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/mask_bos.dmi')
	return sheets

/obj/item/clothing/gloves
	species_restricted = list("exclude", SPECIES_VOX)

/obj/item/clothing/gloves/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/hands_bos.dmi')
	return sheets

/obj/item/clothing/shoes
	species_restricted = list("exclude", SPECIES_VOX)

/obj/item/clothing/shoes/get_default_species_sprite_sheets()
	var/static/list/sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/feet_bos.dmi')
	return sheets

#undef SPECIES_FITTED_SLOTS
