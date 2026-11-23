/obj/item/storage/pill_bottle
	flags_human_ai = HEALING_ITEM

/obj/item/storage/pill_bottle/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || issynth(target))
		return FALSE

	if(skilllock && !skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		return FALSE

	var/obj/item/reagent_container/pill/pill = locate() in src
	if(!pill)
		return FALSE

	return ai_brain.is_safe_dose(target, pill.reagents)

/obj/item/storage/pill_bottle/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/obj/item/reagent_container/pill/pill = locate() in src
	if(!pill?.reagents)
		return

	var/list/pill_reagents = list()
	for(var/datum/reagent/reagent as anything in pill.reagents.reagent_list)
		pill_reagents[reagent.id] = reagent.volume

	remove_from_storage(pill, user)
	pill.attack(target, user)
	if(QDELETED(pill))
		ai_brain.add_pending_reagents(target, pill_reagents)
		if(!ai_brain.ai_sleep(ai_brain.medium_action_delay * ai_brain.action_delay_mult))
			return
	// Packets don't take pills back
	else if((pill.loc == user) && !attempt_item_insertion(pill, TRUE, user))
		pill.forceMove(get_turf(user))

/obj/item/storage/pill_bottle/ai_is_spent()
	return !(locate(/obj/item/reagent_container/pill) in src)

// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/storage/firstaid/softpack
	icon = 'modular_chaos/icons/obj/items/storage/medical.dmi'
	name = "standard-issue first-aid pack"
	desc = "A soft first-aid pack typically containing essential medical supplies for use in the field."
	icon_state = "softpack"
	w_class = SIZE_MEDIUM
	empty_icon = "softpack_empty"
	use_sound = 'sound/items/zip.ogg'

/obj/item/storage/firstaid/softpack/fill_preset_inventory()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_container/hypospray/autoinjector/oxycodone(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexalinp(src)

/obj/item/storage/firstaid/softpack/brute
	icon = 'modular_chaos/icons/obj/items/storage/medical.dmi'
	name = "brute first-aid pack"
	desc = "A soft first-aid pack containing equipment for physical treatment in the field."
	icon_state = "softpack_purple"

/obj/item/storage/firstaid/softpack/brute/fill_preset_inventory()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/tool/surgery/surgical_line(src)
	new /obj/item/reagent_container/hypospray/autoinjector/iron(src)
	new /obj/item/reagent_container/hypospray/autoinjector/bicaridine(src)

/obj/item/storage/firstaid/softpack/burn
	icon = 'modular_chaos/icons/obj/items/storage/medical.dmi'
	name = "burn first-aid pack"
	desc = "A soft first-aid pack containing equipment for burns treatment in the field."
	icon_state = "softpack_darkorange"

/obj/item/storage/firstaid/softpack/burn/fill_preset_inventory()
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/reagent_container/hypospray/kilodermlipo(src)
	new /obj/item/tool/surgery/synthgraft(src)
	new /obj/item/reagent_container/hypospray/autoinjector/oxycodone(src)
	new /obj/item/reagent_container/hypospray/autoinjector/kelotane(src)

/obj/item/storage/pill_bottle/keloderm
	name = "\improper Kelotane-Dermaline pill bottle"
	icon_state = "pill_canister2"
	pill_type_to_fill = /obj/item/reagent_container/pill/keloderm
	maptext_label = "KD"

/obj/item/storage/pill_bottle/merabica
	name = "\improper Meralyne-Bicaridine pill bottle"
	icon_state = "pill_canister8"
	pill_type_to_fill = /obj/item/reagent_container/pill/merabica
	maptext_label = "MB"

/obj/item/storage/pill_bottle/dexalinplus
	name = "\improper Dexalin+ pill bottle"
	icon_state = "pill_canister1"
	pill_type_to_fill = /obj/item/reagent_container/pill/dexalinplus
	maptext_label = "D+"

/obj/item/storage/pill_bottle/imialk
	name = "\improper Imidazoline-Alkysine pill bottle"
	icon_state = "pill_canister5"
	pill_type_to_fill = /obj/item/reagent_container/pill/imialk
	maptext_label = "IA"

/obj/item/storage/pill_bottle/iron
	name = "\improper Iron pill bottle"
	icon_state = "pill_canister4"
	pill_type_to_fill = /obj/item/reagent_container/pill/iron
	maptext_label = "FE"

/obj/item/storage/pill_bottle/nitrogenwater
	name = "\improper Nitrogen-Water pill bottle"
	icon_state = "pill_canister12"
	pill_type_to_fill = /obj/item/reagent_container/pill/nitrogenwater
	maptext_label = "NW"

/obj/item/storage/pill_bottle/tricord
	name = "\improper Tricordazine pill bottle"
	icon_state = "pill_canister"
	item_state = "pill_canister"
	pill_type_to_fill = /obj/item/reagent_container/pill/tricordrazine
	maptext_label = "Ti"
