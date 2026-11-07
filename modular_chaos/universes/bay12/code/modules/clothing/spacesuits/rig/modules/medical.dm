/**
 * Health scanner module, a health analyzer in the gauntlet
 *
 * Using it readies it, and the next click on someone next to the wearer, or on the wearer, scans them.
 */
/obj/item/rig_module/health_scanner
	name = "hardsuit health scanner module"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject next to the wearer."
	targeted = TRUE
	use_power_cost = 20
	/// The analyzer it scans with
	var/obj/item/device/healthanalyzer/analyzer

/obj/item/rig_module/health_scanner/Initialize(mapload, ...)
	. = ..()
	analyzer = new(src)

/obj/item/rig_module/health_scanner/Destroy()
	QDEL_NULL(analyzer)
	return ..()

/obj/item/rig_module/health_scanner/engage(atom/target)
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer || !iscarbon(target))
		return FALSE
	if(!wearer.Adjacent(target))
		to_chat(wearer, SPAN_WARNING("[target] is too far away to scan."))
		return FALSE
	. = ..()
	if(!.)
		return
	analyzer.attack(target, wearer)

/**
 * Chemical dispenser module, a reservoir of chemicals injected into the wearer
 *
 * Using it shows the chemicals in a radial menu, and the picked one is injected. It is refilled by using a container
 * with the same chemicals on the rig.
 */
/obj/item/rig_module/chem_dispenser
	name = "hardsuit chemical dispenser"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	icon_state = "injector"
	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream. Refilled by pouring the chemicals into the suit."
	usable = TRUE
	use_power_cost = 50
	module_cooldown = 2 SECONDS
	/// Units of each chemical in its reservoir, by reagent ID; the starting amounts are set here
	var/list/charges = list(
		"bicaridine" = 30,
		"kelotane" = 30,
		"tramadol" = 30,
		"anti_toxin" = 30,
		"dexalinp" = 30,
		"inaprovaline" = 30,
	)
	/// Units each reservoir holds at most
	var/max_charge = 30
	/// Units injected each time
	var/dose = 5

/obj/item/rig_module/chem_dispenser/get_examine_text(mob/user)
	. = ..()
	var/list/contents_text = list()
	for(var/reagent_id in charges)
		contents_text += "[charges[reagent_id]]u of [get_reagent_name(reagent_id)]"
	. += SPAN_NOTICE("It holds [english_list(contents_text)]. Each dose is [dose] units.")

/**
 * Returns the name of a reagent
 *
 * Arguments:
 * * reagent_id - the ID of the reagent
 */
/obj/item/rig_module/chem_dispenser/proc/get_reagent_name(reagent_id)
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	return reagent ? reagent.name : reagent_id

/obj/item/rig_module/chem_dispenser/engage(atom/target)
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer)
		return FALSE
	var/list/choices = list()
	var/list/ids_by_choice = list()
	for(var/reagent_id in charges)
		var/choice_name = "[get_reagent_name(reagent_id)] ([charges[reagent_id]]u)"
		choices[choice_name] = image(icon = 'icons/obj/items/syringe.dmi', icon_state = "autoinjector_3")
		ids_by_choice[choice_name] = reagent_id
	var/choice = show_radial_menu(wearer, wearer, choices, require_near = TRUE)
	if(!choice || holder?.wearer != wearer)
		return FALSE
	var/reagent_id = ids_by_choice[choice]
	if(charges[reagent_id] <= 0)
		to_chat(wearer, SPAN_WARNING("The reservoir of [get_reagent_name(reagent_id)] is empty."))
		return FALSE
	. = ..()
	if(!.)
		return
	var/amount = min(dose, charges[reagent_id])
	charges[reagent_id] -= amount
	wearer.reagents.add_reagent(reagent_id, amount)
	playsound(wearer, 'sound/items/hypospray.ogg', 25, TRUE)
	to_chat(wearer, SPAN_NOTICE("You feel a rushing in your veins as [amount] unit\s of [get_reagent_name(reagent_id)] [amount == 1 ? "is" : "are"] injected."))

/obj/item/rig_module/chem_dispenser/accepts_item(obj/item/item, mob/user)
	if(!item.is_open_container() || !item.reagents)
		return FALSE
	if(!item.reagents.total_volume)
		to_chat(user, SPAN_WARNING("[item] is empty."))
		return TRUE
	var/transferred = 0
	for(var/datum/reagent/reagent as anything in item.reagents.reagent_list.Copy())
		if(!(reagent.id in charges))
			continue
		var/amount = min(reagent.volume, max_charge - charges[reagent.id])
		if(amount <= 0)
			continue
		charges[reagent.id] += amount
		item.reagents.remove_reagent(reagent.id, amount)
		transferred += amount
	if(transferred)
		to_chat(user, SPAN_NOTICE("You transfer [transferred] units into the reservoirs of [src]."))
	else
		to_chat(user, SPAN_WARNING("None of the reagents in [item] fit the reservoirs of [src], or they are full."))
	return TRUE

/obj/item/rig_module/chem_dispenser/combat
	name = "hardsuit combat chemical injector"
	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses combat chemicals directly into the wearer's bloodstream. Refilled by pouring the chemicals into the suit."
	charges = list(
		"oxycodone" = 15,
		"adrenaline" = 15,
		"meralyne" = 15,
		"dermaline" = 15,
	)
	max_charge = 15
