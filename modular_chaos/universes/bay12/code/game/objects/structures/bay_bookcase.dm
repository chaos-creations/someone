//Bookcases of Baystation 12 (code/modules/library/lib_items.dm in the source)

/// The most books the sprites of a Bay bookcase show
#define BAY_BOOKCASE_SHOWN_BOOKS 5

/**
 * A Bay bookcase
 *
 * A CM bookcase (books put in and taken out, and a pen to title it, as there) with the sprites of the source, which a
 * screwdriver takes apart into wood as there rather than a wrench into metal.
 */
/obj/structure/bookcase/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/furniture/bookcase.dmi'

/obj/structure/bookcase/bay/update_icon()
	icon_state = "book-[min(length(contents), BAY_BOOKCASE_SHOWN_BOOKS)]"

/obj/structure/bookcase/bay/attackby(obj/item/attacking_item, mob/user)
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		return
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
		return ..()
	playsound(src, 'sound/items/Screwdriver.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] begins dismantling [src] with \a [attacking_item]."), SPAN_NOTICE("You begin dismantling [src] with [attacking_item]."))
	if(!do_after(user, 2.5 SECONDS * user.get_skill_duration_multiplier(SKILL_CONSTRUCTION), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
		return
	playsound(src, 'sound/items/Screwdriver.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] dismantles [src] with \a [attacking_item]."), SPAN_NOTICE("You dismantle [src] with [attacking_item]."))
	deconstruct(TRUE)

// Taken apart into wood of CM until the materials of the source have stacks
/obj/structure/bookcase/bay/deconstruct(disassembled)
	for(var/obj/item/book/book in contents)
		book.forceMove(loc)
	if(disassembled)
		new /obj/item/stack/sheet/wood(loc, 5)
	density = FALSE
	qdel(src)

/// A Bay bookcase of xenoarchaeology manuals, whose manuals come with xenoarchaeology
/obj/structure/bookcase/bay/manuals/xenoarchaeology
	name = "Xenoarchaeology Manuals bookcase"

#undef BAY_BOOKCASE_SHOWN_BOOKS
