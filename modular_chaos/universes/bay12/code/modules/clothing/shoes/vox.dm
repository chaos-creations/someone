/**
 * Vox magclaws (/obj/item/clothing/shoes/magboots/vox in Baystation 12), the only footwear that fits a Vox
 *
 * Not upstream's magboots, whose toggle swaps their own icon: the claws dig into the floor, which keeps the Vox from
 * slipping and the claws from being taken off until they let go.
 */
/obj/item/clothing/shoes/vox_magclaws
	name = "vox magclaws"
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/shoes/shoes.dmi'
	icon_state = "boots-vox"
	item_state = "boots-vox"
	species_restricted = list(SPECIES_VOX)
	actions_types = list(/datum/action/item_action/toggle)
	/// Whether the claws grip the floor
	var/gripping = FALSE

/obj/item/clothing/shoes/vox_magclaws/attack_self(mob/user)
	. = ..()
	if(gripping)
		gripping = FALSE
		flags_inventory &= ~NOSLIPPING
		flags_item &= ~NODROP
		to_chat(user, SPAN_NOTICE("You relax your deathgrip on the flooring."))
		return
	var/mob/living/carbon/human/human = user
	if(!istype(human) || human.shoes != src)
		to_chat(user, SPAN_WARNING("You will have to put on [src] before you can do that."))
		return
	gripping = TRUE
	flags_inventory |= NOSLIPPING
	flags_item |= NODROP
	to_chat(user, SPAN_NOTICE("You dig your claws deeply into the flooring, bracing yourself."))

/obj/item/clothing/shoes/vox_magclaws/get_examine_text(mob/user)
	. = ..()
	. += "Its claws [gripping ? "grip the floor" : "are relaxed"]."
