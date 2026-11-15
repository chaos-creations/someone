//Banners, barricades, memorabilia and plushies of Baystation 12 (code/game/objects/structures/banner.dm and barricade.dm,
//maps/torch/structures/memorabilia.dm and code/game/objects/items/toys.dm in the source)

/**
 * A Bay religious banner
 *
 * Rolled up and down by anyone next to it, and set to a symbol by a click. The source lets only the chaplain pick the
 * symbol; jobs are not ported, so anyone can.
 */
/obj/structure/bay_banner
	name = "religious banner"
	desc = "A banner used to contain religious symbols."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/banner.dmi'
	icon_state = "blank_up"
	anchored = TRUE
	density = FALSE
	/// Whether it is rolled up
	var/rolled = TRUE
	/// The symbol it shows, a key of symbols
	var/selected = "blank"
	/// The symbols it can show, by the state they are drawn in, with what they are
	var/static/list/symbols = list(
		"blank" = "no symbol",
		"crucifix" = "the cross, a symbol of Christianity",
		"starofdavid" = "the Star of David, a symbol of Judaism",
		"crescentandstar" = "the crescent and star, a symbol of Islam",
		"aum" = "the Aum, a symbol of Hinduism",
		"khanda" = "the Khanda, a symbol of Sikhism",
		"ninepointedstar" = "the nine-pointed star, a symbol of the Baha'i Faith",
		"dharmachakra" = "the dharmachakra, a symbol of Buddhism",
		"redandblackstar" = "the red and black star, a symbol of the Quakers",
		"pentacle" = "the pentacle, a symbol of Wicca",
		"awen" = "the Awen, a symbol of Druidry",
		"ahimsa" = "the Ahimsa, a symbol of Jainism",
		"yinandyang" = "the yin and yang, a symbol of Taoism",
		"torii" = "the torii, a symbol of Shinto",
		"lhossek" = "the Lhossek skull, a symbol of the Grand Stratagem, an Unathi faith",
		"threearrows" = "the Three Arrows, a symbol of the Fruitful Lights, an Unathi faith",
		"bushroot" = "the Hrukhza bush root, a symbol of the Hand of the Vine, an Unathi faith",
		"sundial" = "the sundial, a symbol of Precursor worship, an Unathi faith",
		"cupofknowledge" = "the Cup of Knowledge, a symbol of Markesheli, an Unathi faith",
	)

/obj/structure/bay_banner/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/structure/bay_banner/update_icon()
	icon_state = "[selected]_[rolled ? "up" : "down"]"

/obj/structure/bay_banner/get_examine_text(mob/user)
	. = ..()
	if(!rolled)
		. += "It shows [symbols[selected]]."

/obj/structure/bay_banner/verb/toggle()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Banner"

	if(usr.is_mob_incapacitated())
		return
	rolled = !rolled
	to_chat(usr, SPAN_NOTICE("You roll [rolled ? "up" : "down"] [src]."))
	update_icon()

/obj/structure/bay_banner/attack_hand(mob/user)
	var/symbol = tgui_input_list(user, "Pick a symbol:", name, symbols)
	if(!symbol || user.is_mob_incapacitated() || !Adjacent(user))
		return
	selected = symbol
	update_icon()

/**
 * A Bay barricade of a Bay material, wood unless mapped with another
 *
 * It blocks its whole tile, lets what flies over tables fly over it, and takes the damage of hits, bullets, slashes and
 * blasts until it is smashed apart. Its material repairs it, and five rods make it a spiked barricade. Wood is
 * repaired with CM planks and gives them back until the sheets of the source are ported; other materials give nothing.
 */
/obj/structure/bay_barricade
	name = "barricade"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/barricade.dmi'
	icon_state = "barricade"
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	/// The name of the Bay material it is made of
	var/material = BAY_MATERIAL_WOOD
	/// The most health it has, set from its material
	var/max_health

/obj/structure/bay_barricade/Initialize(mapload, material)
	if(material)
		src.material = material
	. = ..()
	var/material/barricade_material = get_bay_material(src.material)
	if(!barricade_material)
		return INITIALIZE_HINT_QDEL
	name = "[barricade_material.display_name] barricade"
	desc = "A heavy, solid barrier made of [barricade_material.display_name]."
	color = barricade_material.icon_colour
	max_health = round(barricade_material.integrity * 1.33)
	health = max_health

/obj/structure/bay_barricade/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if(PF)
		PF.flags_can_pass_all = PASS_OVER

/obj/structure/bay_barricade/attackby(obj/item/attacking_item, mob/living/user)
	if(istype(attacking_item, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = attacking_item
		if(rods.get_amount() < 5)
			to_chat(user, SPAN_WARNING("You need at least five rods to build a cheval de frise."))
			return
		user.visible_message(SPAN_NOTICE("[user] starts adding some [rods.name] to [src]."), SPAN_NOTICE("You start adding some [rods.name] to [src]."))
		if(!do_after(user, 4 SECONDS * user.get_skill_duration_multiplier(SKILL_CONSTRUCTION), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || !rods.use(5))
			return
		var/obj/structure/bay_barricade/spike/spiked = new(loc, material)
		spiked.setDir(user.dir)
		transfer_fingerprints_to(spiked)
		user.visible_message(SPAN_NOTICE("[user] adds some [rods.name] to [src]."), SPAN_NOTICE("You add some [rods.name] to [src]."))
		qdel(src)
		return

	if(istype(attacking_item, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/stack = attacking_item
		if(material != BAY_MATERIAL_WOOD || !istype(stack, /obj/item/stack/sheet/wood))
			to_chat(user, SPAN_WARNING("[stack] is the wrong type of material to repair [src]."))
			return
		if(health >= max_health)
			to_chat(user, SPAN_WARNING("[src] doesn't need repairs."))
			return
		user.visible_message(SPAN_NOTICE("[user] starts repairing [src] with some [stack.name]."), SPAN_NOTICE("You start repairing [src] with some [stack.name]."))
		if(!do_after(user, 2 SECONDS * user.get_skill_duration_multiplier(SKILL_CONSTRUCTION), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || health >= max_health || !stack.use(1))
			return
		health = max_health
		user.visible_message(SPAN_NOTICE("[user] repairs [src] with some [stack.name]."), SPAN_NOTICE("You repair [src] with some [stack.name]."))
		return

	if(user.a_intent == INTENT_HARM && attacking_item.force && !(attacking_item.flags_item & NOBLUDGEON))
		user.animation_attack_on(src)
		playsound(src, 'modular_chaos/universes/bay12/sound/effects/woodhit.ogg', 25, TRUE)
		take_damage(attacking_item.force)
		return ATTACKBY_HINT_UPDATE_NEXT_MOVE
	return ..()

/obj/structure/bay_barricade/attack_alien(mob/living/carbon/xenomorph/xeno)
	xeno.animation_attack_on(src)
	playsound(src, 'modular_chaos/universes/bay12/sound/effects/woodhit.ogg', 25, TRUE)
	xeno.visible_message(SPAN_DANGER("[xeno] slashes [src]!"), SPAN_DANGER("We slash [src]!"), null, 5, CHAT_TYPE_XENO_COMBAT)
	take_damage(xeno.melee_damage_upper)
	return XENO_ATTACK_ACTION

/obj/structure/bay_barricade/bullet_act(obj/projectile/bullet)
	take_damage(bullet.damage)
	return TRUE

/obj/structure/bay_barricade/ex_act(severity)
	take_damage(severity)

/**
 * Takes damage, smashing it apart once its health runs out
 *
 * * damage - how much
 */
/obj/structure/bay_barricade/proc/take_damage(damage)
	health -= damage
	if(health <= 0)
		visible_message(SPAN_DANGER("The barricade is smashed apart!"))
		deconstruct(FALSE)

/obj/structure/bay_barricade/deconstruct(disassembled = TRUE)
	if(material == BAY_MATERIAL_WOOD)
		new /obj/item/stack/sheet/wood(loc)
	return ..()

/**
 * A Bay spiked barricade, a cheval de frise
 *
 * Its spikes of steel, CM's rods, hurt whoever runs into it; less when they walk.
 */
/obj/structure/bay_barricade/spike
	name = "spiked barricade"
	icon_state = "cheval"
	climbable = FALSE
	/// The name of the Bay material of its spikes
	var/rod_material = MATERIAL_STEEL
	/// The brute damage of running into it
	var/damage
	/// How it hurts those who run into it
	var/list/poke_description = list("gored", "spiked", "speared", "stuck", "stabbed")
	/// When each mob last ran into it, against spam
	var/list/last_bumped_by = list()

/obj/structure/bay_barricade/spike/Initialize(mapload, material)
	. = ..()
	var/material/barricade_material = get_bay_material(src.material)
	var/material/spike_material = get_bay_material(rod_material)
	name = "spiked barricade"
	desc = "A rather simple [barricade_material.display_name] spiked barricade, also known as a cheval-de-frise. It menaces with spikes of [spike_material.display_name] which look like they would hurt to walk in to."
	damage = spike_material.hardness * 0.85
	var/image/spikes = image(icon, "cheval_spikes")
	spikes.color = spike_material.icon_colour
	spikes.appearance_flags = RESET_COLOR
	overlays += spikes

/obj/structure/bay_barricade/spike/Destroy()
	last_bumped_by = null
	return ..()

/obj/structure/bay_barricade/spike/Collided(atom/movable/moving_atom)
	. = ..()
	var/mob/living/victim = moving_atom
	if(!istype(victim))
		return
	var/weakref = WEAKREF(victim)
	if(world.time - last_bumped_by[weakref] <= 1.5 SECONDS)
		return
	last_bumped_by[weakref] = world.time
	var/damage_dealt = damage
	if(victim.m_intent == MOVE_INTENT_WALK || isanimal(victim))
		damage_dealt *= 0.25
	victim.apply_damage(damage_dealt, BRUTE, pick("chest", "groin", "l_leg", "r_leg"), sharp = TRUE)
	visible_message(SPAN_DANGER("[victim] is [pick(poke_description)] by [src]!"))

/// Bay memorabilia of the Torch
/obj/structure/bay_decorative
	name = "decorations"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER

/**
 * The salvaged ED-209 of the Torch
 *
 * Chained in place, raised on its stand while anchored; an engineer salvages parts from it with a screwdriver, CM's
 * cell and parts until the source's are ported, until it has none left.
 */
/obj/structure/bay_decorative/ed209
	name = "salvaged ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled. This one has had multiple parts stripped off and its internal systems are exposed. You can make out a charred stencil reading 'SFV Jonah'."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/ed209.dmi'
	icon_state = "ed2090-salvage"
	wrenchable = TRUE
	/// Whether it has nothing left to salvage
	var/salvaged = FALSE
	/// What can be salvaged from it
	var/list/loot = list(/obj/item/cell/super, /obj/item/stock_parts/manipulator/nano, /obj/item/stock_parts/micro_laser/high, /obj/item/robot_parts/robot_component/actuator)

/obj/structure/bay_decorative/ed209/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/structure/bay_decorative/ed209/update_icon()
	pixel_z = anchored ? 8 : 0

/obj/structure/bay_decorative/ed209/toggle_anchored(obj/item/tool, mob/user)
	. = ..()
	update_icon()

/obj/structure/bay_decorative/ed209/get_examine_text(mob/user)
	. = ..()
	if(anchored)
		. += "Magnetic chains hold it in place. Somebody isn't taking any risks with this one."

/obj/structure/bay_decorative/ed209/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
		return ..()
	if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_NOVICE))
		to_chat(user, SPAN_WARNING("You're not skilled enough to salvage [src]."))
		return
	if(salvaged)
		to_chat(user, SPAN_WARNING("It doesn't seem like there's anything of use left on [src]."))
		return
	user.visible_message(SPAN_NOTICE("[user] starts rummaging through [src] with \a [attacking_item]."), SPAN_NOTICE("You start looking for useful components in [src] with [attacking_item]."))
	if(!do_after(user, 2 SECONDS * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || salvaged)
		return
	playsound(src, 'sound/items/Crowbar.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] detaches some components from [src] with \a [attacking_item]."), SPAN_NOTICE("You detach some useful components from [src] with [attacking_item]."))
	var/part_type = pick(loot)
	user.put_in_hands(new part_type(get_turf(user)))
	salvaged = prob(25) // Sometimes more, sometimes less

/// The mass driver slug of the Torch, which scrapes along the floor when pushed
/obj/structure/bay_decorative/md_slug
	name = "charred mass driver slug"
	desc = "A damaged, and used mass-driver slug. This one has likely seen the broad-end of an armoured hull. It has a small stamp, etched on the side. 'SFV Nathan Hale, INV: 654-2305'. "
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/munitions.dmi'
	icon_state = "hale_slug"
	anchored = FALSE
	density = TRUE
	/// The sounds of its scraping
	var/list/move_sounds = list(
		'modular_chaos/universes/bay12/sound/effects/metalscrape1.ogg',
		'modular_chaos/universes/bay12/sound/effects/metalscrape2.ogg',
		'modular_chaos/universes/bay12/sound/effects/metalscrape3.ogg',
	)

/obj/structure/bay_decorative/md_slug/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	var/turf/here = get_turf(src)
	if(!istype(here, /turf/open/space) && !istype(here, /turf/open/floor/bay/carpet))
		playsound(here, pick(move_sounds), 50, TRUE)

/**
 * A Bay plushie, a big one that stands on the floor
 *
 * Hugged, poked, strangled or bopped by the intent of the click, and says its phrase.
 */
/obj/structure/bay_plushie
	name = "generic plush"
	desc = "A very generic plushie. It seems to not want to exist."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/plushies.dmi'
	anchored = FALSE
	density = TRUE
	climbable = TRUE
	/// What it says when touched
	var/phrase = "I don't want to exist anymore!"

/obj/structure/bay_plushie/attack_hand(mob/living/user)
	var/action_word = "bop"
	switch(user.a_intent)
		if(INTENT_HELP)
			action_word = "hug"
		if(INTENT_DISARM)
			action_word = "poke"
		if(INTENT_GRAB)
			action_word = "strangle"
	user.visible_message(SPAN_NOTICE("[user] [action_word]s [src]."), SPAN_NOTICE("You [action_word] [src]."))
	if(phrase)
		audible_message(SPAN_NOTICE("[src] says, \"[phrase]\""), null, 3)
	playsound(src, 'sound/effects/rustle1.ogg', 50, TRUE)

/obj/structure/bay_plushie/drone
	name = "plush drone"
	desc = "A plushie of a happy drone! It appears to be smiling, and has a small tag which reads \"N.D.V. Icarus Gift Shop\"."
	icon_state = "droneplushie"
	phrase = "Beep boop!"
