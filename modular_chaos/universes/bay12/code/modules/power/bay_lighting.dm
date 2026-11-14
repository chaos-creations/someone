//Light fixtures, light bulbs and fixture frames of Baystation 12 (code/modules/power/lighting.dm in the source)

// The states of a bulb, the values of the CM ones that lightreplacer.dm undefines
#define BAY_LIGHT_OK 0
#define BAY_LIGHT_EMPTY 1
#define BAY_LIGHT_BROKEN 2
#define BAY_LIGHT_BURNED 3

// The construction stages of a fixture frame
#define LIGHT_STAGE_EMPTY 1
#define LIGHT_STAGE_WIRED 2
#define LIGHT_STAGE_COMPLETE 3

/// The temperature of a lit bulb, in kelvin, which gloves must stand to take it out unhurt
#define LIGHT_BULB_TEMPERATURE 400
/// Power a fixture uses for each unit of the range times the power of its light, in watts
#define BAY_LIGHTING_POWER_FACTOR 5
/// Units of phoron in a bulb that make it blow up when it is switched on
#define LIGHT_PHORON_EXPLODE_THRESHOLD 5

/// The tone the lights of the area take: AREA_LIGHTING_*
/area/var/lighting_tone = AREA_LIGHTING_DEFAULT

/**
 * Has the Bay lights of the area turn emergency lighting on or off, /area/proc/set_emergency_lighting() in the source
 *
 * * enable - whether to turn it on
 */
/area/proc/set_emergency_lighting(enable)
	for(var/obj/structure/machinery/light/bay/light in src)
		light.set_emergency_lighting(enable)

/**
 * A Bay light fixture
 *
 * A CM fixture, whose status the CM code that breaks, fixes and replaces lights keeps setting, holding a Bay bulb that
 * lights it in its own colour: the tone of the area for the bulbs a map places, at random otherwise. When the APC
 * turns the lights of its area off to save its cell, the fixture lights up in the emergency mode of its bulb, run off
 * the environment channel. A new bulb may burn out each time it lights up, the more so the more it has.
 */
/obj/structure/machinery/light/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/lighting.dmi'
	icon_state = "tube_map"
	desc = "A lighting fixture."
	fitting = "light tube"
	light_type = /obj/item/light_bulb/bay/tube
	/// The bulb in the fixture, null if it has none
	var/obj/item/light_bulb/bay/lightbulb
	/// The lighting mode of the bulb it uses, one of LIGHTMODE_*; null for its normal light
	var/current_mode
	/// Whether it spawns broken
	var/spawn_broken = FALSE
	/// The frame it leaves when taken apart
	var/construct_type = /obj/structure/machinery/light_construct/bay

/obj/structure/machinery/light/bay/Initialize(mapload, obj/structure/machinery/light_construct/bay/construct)
	. = ..()
	if(construct)
		construct_type = construct.type
		construct.transfer_fingerprints_to(src)
		setDir(construct.dir)
		status = BAY_LIGHT_EMPTY
	else
		lightbulb = new light_type(src, get_color_from_area())
		status = lightbulb.status
		if(prob(lightbulb.broken_chance) || spawn_broken)
			broken(TRUE)
	on = has_power()
	update(FALSE)

/obj/structure/machinery/light/bay/Destroy()
	QDEL_NULL(lightbulb)
	return ..()

/// The colour of the tone of the area, null if it has none
/obj/structure/machinery/light/bay/proc/get_color_from_area()
	var/area/light_area = get_area(src)
	switch(light_area?.lighting_tone)
		if(AREA_LIGHTING_WHITE)
			return LIGHT_COLOUR_WHITE
		if(AREA_LIGHTING_WARM)
			return LIGHT_COLOUR_WARM
		if(AREA_LIGHTING_COOL)
			return LIGHT_COLOUR_COOL

// Placed by its icon, against the wall it faces only
/obj/structure/machinery/light/bay/set_pixel_location()
	pixel_x = 0
	pixel_y = 0
	var/turf/facing = get_step(get_turf(src), dir)
	if(!istype(facing) || !facing.density)
		return
	switch(dir)
		if(NORTH)
			pixel_y = 21
		if(EAST)
			pixel_x = 10
		if(WEST)
			pixel_x = -10

/**
 * Brings the bulb in line with the status of the fixture
 *
 * CM code sets the status of a fixture to break, fix, empty or refill it; the fixture then takes its bulb out, puts
 * a new one in or sets the one it has.
 */
/obj/structure/machinery/light/bay/proc/sync_bulb()
	if(status == BAY_LIGHT_EMPTY)
		QDEL_NULL(lightbulb)
		return
	if(!lightbulb)
		lightbulb = new light_type(src, get_color_from_area())
	lightbulb.set_status(status)

/obj/structure/machinery/light/bay/update_icon()
	overlays.Cut()
	icon_state = "[base_state]_empty"
	set_pixel_location()
	var/shown_state
	switch(status)
		if(BAY_LIGHT_OK)
			shown_state = "[base_state][on]"
		if(BAY_LIGHT_BURNED)
			shown_state = "[base_state]_burned"
		if(BAY_LIGHT_BROKEN)
			shown_state = "[base_state]_broken"
	if(!lightbulb || !shown_state)
		return
	if(on)
		overlays += emissive_appearance(icon, shown_state)
	var/image/bulb_image = image(icon, shown_state)
	bulb_image.color = get_mode_color()
	overlays += bulb_image

/// The colour the bulb shows in its current mode, null without a bulb
/obj/structure/machinery/light/bay/proc/get_mode_color()
	if(!lightbulb)
		return null
	if(current_mode && (current_mode in lightbulb.lighting_modes))
		return lightbulb.lighting_modes[current_mode]["l_color"]
	return lightbulb.b_colour

/**
 * Updates the icon, the light and the power use of the fixture, on_update_icon() in the source
 *
 * * trigger - whether a change of its light counts as switching the bulb on, which may burn it out
 */
/obj/structure/machinery/light/bay/update(trigger = TRUE)
	sync_bulb()
	if(status != BAY_LIGHT_OK)
		on = FALSE
	update_icon()
	if(!on)
		update_use_power(USE_POWER_NONE)
		set_light(0)
		return
	var/list/light_values
	if(current_mode && (current_mode in lightbulb.lighting_modes))
		light_values = lightbulb.lighting_modes[current_mode]
	else
		light_values = list("l_range" = lightbulb.b_range, "l_power" = lightbulb.b_power, "l_color" = lightbulb.b_colour)
	var/changed = light_range != light_values["l_range"] || light_power != light_values["l_power"] || light_color != light_values["l_color"]
	set_light(light_values["l_range"], light_values["l_power"], light_values["l_color"])
	active_power_usage = light_values["l_range"] * light_values["l_power"] * BAY_LIGHTING_POWER_FACTOR
	// The power use follows the light, which a change of mode changes
	update_use_power(use_power == USE_POWER_ACTIVE ? -1 : USE_POWER_ACTIVE)
	if(trigger && changed)
		switch_check()

/// Switches the bulb on, which may burn it out or blow it up
/obj/structure/machinery/light/bay/proc/switch_check()
	status = lightbulb.switch_on()
	if(status != BAY_LIGHT_OK)
		update(FALSE)

/obj/structure/machinery/light/bay/seton(state)
	on = state && status == BAY_LIGHT_OK
	update()

// The light switch of its area, and the power of the channel it runs on, which emergency lighting changes
/obj/structure/machinery/light/bay/has_power()
	var/area/light_area = get_area(src)
	if(!light_area?.lightswitch)
		return FALSE
	if(!needs_power || light_area.unlimited_power)
		return TRUE
	return light_area.powered(power_channel)

/obj/structure/machinery/light/bay/power_change()
	seton(has_power())

/**
 * Sets the lighting mode of the bulb
 *
 * * new_mode - one of LIGHTMODE_*, null for its normal light
 */
/obj/structure/machinery/light/bay/proc/set_mode(new_mode)
	if(current_mode == new_mode)
		return
	current_mode = new_mode
	update(FALSE)

/**
 * Moves the power use of the fixture to another channel
 *
 * * new_channel - the power channel, POWER_CHANNEL_*
 */
/obj/structure/machinery/light/bay/proc/set_power_channel(new_channel)
	if(power_channel == new_channel)
		return
	use_power(-last_power_usage, power_channel)
	power_channel = new_channel
	use_power(last_power_usage, power_channel)

/**
 * Turns the emergency lighting of the bulb on or off, run off the environment channel while on
 *
 * * enable - whether to turn it on
 */
/obj/structure/machinery/light/bay/proc/set_emergency_lighting(enable)
	if(!lightbulb)
		return
	if(enable)
		if(!(LIGHTMODE_EMERGENCY in lightbulb.lighting_modes))
			return
		set_power_channel(POWER_CHANNEL_ENVIRON)
		current_mode = LIGHTMODE_EMERGENCY
	else
		if(current_mode != LIGHTMODE_EMERGENCY)
			return
		set_power_channel(initial(power_channel))
		current_mode = null
	seton(has_power())

// Bay fixtures give no hints of taking out their bulbs with a screwdriver, which CM ones do
/obj/structure/machinery/light/bay/get_examine_text(mob/user)
	. = list("[icon2html(src, user)] That's \a [src].", desc)
	switch(status)
		if(BAY_LIGHT_OK)
			. += "It is turned [on ? "on" : "off"]."
		if(BAY_LIGHT_EMPTY)
			. += "The [fitting] has been removed."
		if(BAY_LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(BAY_LIGHT_BROKEN)
			. += "The [fitting] has been smashed."

/**
 * Puts a bulb in the fixture
 *
 * * bulb - the bulb
 */
/obj/structure/machinery/light/bay/proc/insert_bulb(obj/item/light_bulb/bay/bulb)
	bulb.forceMove(src)
	lightbulb = bulb
	status = bulb.status
	seton(has_power())

/// Takes the bulb out of the fixture, returning it
/obj/structure/machinery/light/bay/proc/remove_bulb()
	var/obj/item/light_bulb/bay/bulb = lightbulb
	lightbulb = null
	bulb.forceMove(loc)
	bulb.update()
	status = BAY_LIGHT_EMPTY
	seton(FALSE)
	return bulb

/obj/structure/machinery/light/bay/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/device/lightreplacer))
		return ..()
	if(istype(attacking_item, /obj/item/light_bulb))
		if(lightbulb)
			to_chat(user, SPAN_WARNING("There is a [fitting] already inserted."))
			return
		if(!istype(attacking_item, light_type))
			to_chat(user, SPAN_WARNING("This type of light requires a [fitting]."))
			return
		if(!user.drop_inv_item_to_loc(attacking_item, src))
			return
		user.visible_message(SPAN_NOTICE("[user] inserts \a [attacking_item] into \the [src]."),
			SPAN_NOTICE("You insert \the [attacking_item] into \the [src]."), SPAN_NOTICE("You hear something being screwed in."))
		insert_bulb(attacking_item)
		return
	if(!lightbulb)
		if(HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, TRUE)
			user.visible_message(SPAN_NOTICE("[user] opens \the [src]'s casing."),
				SPAN_NOTICE("You open up \the [src]'s casing."), SPAN_NOTICE("You hear screws being loosened."))
			var/obj/structure/machinery/light_construct/bay/frame = new construct_type(loc)
			frame.setDir(dir)
			frame.stage = LIGHT_STAGE_WIRED
			frame.fixture_path = type
			frame.update_icon()
			transfer_fingerprints_to(frame)
			qdel(src)
			return
		user.visible_message(SPAN_WARNING("[user] shoves \a [attacking_item] into \the [src]!"),
			SPAN_DANGER("You stick \the [attacking_item] into \the [src]!"))
		if(has_power() && (attacking_item.flags_atom & CONDUCT))
			var/datum/effect_system/spark_spread/sparks = new
			sparks.set_up(3, 1, src)
			sparks.start()
			if(prob(75))
				electrocute_mob(user, get_area(src), src, rand(0.7, 1))
		return
	if(status == BAY_LIGHT_BROKEN || attacking_item.force <= 0)
		return
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.animation_attack_on(src)
	if(prob(1 + attacking_item.force * 5))
		user.visible_message(SPAN_WARNING("[user] smashes \the [src]!"), SPAN_WARNING("You smash \the [src]!"),
			SPAN_WARNING("You hear a small glass object shatter."))
		if(on && (attacking_item.flags_atom & CONDUCT) && prob(12))
			electrocute_mob(user, get_area(src), src, 0.3)
		broken()
		return
	user.visible_message(SPAN_WARNING("[user] hits \the [src]!"), SPAN_WARNING("You hit \the [src]!"),
		SPAN_WARNING("You hear glass cracking."))
	playsound(loc, "glassbreak", 25, TRUE)

// Takes the bulb out, which burns a hand that is not protected, unless its owner means to take it out anyway
/obj/structure/machinery/light/bay/attack_hand(mob/user)
	add_fingerprint(user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.species.can_shred(human_user))
			human_user.visible_message(SPAN_WARNING("[user] shreds \the [src]!"), SPAN_WARNING("You shred \the [src]!"),
				SPAN_WARNING("You hear glass shattering!"))
			broken()
			return
	if(!lightbulb)
		to_chat(user, SPAN_WARNING("There is no [fitting] in this light."))
		return
	if(on)
		var/protected = TRUE
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			var/obj/item/clothing/gloves/gloves = human_user.gloves
			protected = gloves?.max_heat_protection_temperature > LIGHT_BULB_TEMPERATURE
		if(!protected && user.a_intent == INTENT_HELP)
			to_chat(user, SPAN_WARNING("You try to remove the [fitting], but it's too hot and you don't want to burn your hand."))
			return
		if(!protected)
			// Only humans go unprotected
			var/mob/living/carbon/human/human_user = user
			human_user.apply_damage(3, BURN, human_user.hand ? "l_hand" : "r_hand")
			to_chat(user, SPAN_WARNING("Your hand burns and sizzles as you remove the hot [fitting]."))
		else
			to_chat(user, SPAN_NOTICE("You remove the [fitting]."))
	else
		to_chat(user, SPAN_NOTICE("You remove the [fitting]."))
	user.put_in_active_hand(remove_bulb())

/obj/structure/machinery/light/bay/broken(skip_sound_and_sparks = FALSE)
	if(!lightbulb && status == BAY_LIGHT_EMPTY)
		return
	return ..()

/// A Bay small bulb fixture
/obj/structure/machinery/light/bay/small
	icon_state = "bulb_map"
	base_state = "bulb"
	desc = "A small lighting fixture."
	fitting = "light bulb"
	light_type = /obj/item/light_bulb/bay/bulb
	construct_type = /obj/structure/machinery/light_construct/bay/small

/// A Bay emergency light, a small fixture with a red bulb
/obj/structure/machinery/light/bay/small/emergency
	light_type = /obj/item/light_bulb/bay/bulb/red

/// A Bay small fixture with a red bulb
/obj/structure/machinery/light/bay/small/red
	light_type = /obj/item/light_bulb/bay/bulb/red

/// A Bay spotlight, which takes large tubes
/obj/structure/machinery/light/bay/spot
	name = "spotlight"
	desc = "A more robust socket for light tubes that demand more power."
	fitting = "large light tube"
	light_type = /obj/item/light_bulb/bay/tube/large
	construct_type = /obj/structure/machinery/light_construct/bay/spot

/**
 * A Bay ready light, a small fixture whose red bulb turns green when its state is set
 */
/obj/structure/machinery/light/bay/small/readylight
	light_type = /obj/item/light_bulb/bay/bulb/red/readylight
	/// Whether it shows ready
	var/state = FALSE

/**
 * Sets whether the light shows ready
 *
 * * new_state - whether it does
 */
/obj/structure/machinery/light/bay/small/readylight/proc/set_state(new_state)
	state = new_state
	set_mode(state ? LIGHTMODE_READY : null)

/**
 * A Bay light bulb or tube
 *
 * A CM bulb in its own colour, with the lighting modes it supports. Phoron injected into it with a syringe blows it up
 * the next time it lights up; any other fluid burns it out.
 */
/obj/item/light_bulb/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/lighting.dmi'
	w_class = SIZE_TINY
	/// The chance it is broken when a map places it, in percent
	var/broken_chance = 2
	/// The power of its light
	var/b_power = 0.7
	/// The range of its light, in tiles
	var/b_range = 5
	/// The colour of its light
	var/b_colour = LIGHT_COLOUR_WARM
	/**
	 * Its alternative lighting modes: LIGHTMODE_* to the range ("l_range"), power ("l_power") and colour ("l_color") of
	 * its light in that mode
	 */
	var/list/lighting_modes = list()
	/// The sound it makes when it lights up
	var/sound_on
	/// Whether it picks a colour at random from random_tone_options when nothing sets its colour
	var/random_tone = TRUE
	/// The colours it picks from
	var/list/random_tone_options = LIGHT_STANDARD_COLORS

/obj/item/light_bulb/bay/Initialize(mapload, light_color)
	. = ..()
	if(light_color)
		b_colour = light_color
	else if(random_tone)
		b_colour = pick(random_tone_options)
	update()

/obj/item/light_bulb/bay/update()
	color = b_colour
	switch(status)
		if(BAY_LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(BAY_LIGHT_BURNED)
			icon_state = "[base_state]_burned"
			desc = "A burnt-out [name]."
		if(BAY_LIGHT_BROKEN)
			icon_state = "[base_state]_broken"
			desc = "A broken [name]."
	overlays.Cut()
	var/image/attachment = image(icon, "[base_state]_attachment[status == BAY_LIGHT_BROKEN ? "_broken" : ""]")
	attachment.appearance_flags = RESET_COLOR
	overlays += attachment

/**
 * Sets the state of the bulb, which a broken one is sharp in
 *
 * * new_status - BAY_LIGHT_OK, BAY_LIGHT_BURNED or BAY_LIGHT_BROKEN
 */
/obj/item/light_bulb/bay/proc/set_status(new_status)
	if(status == new_status)
		return
	status = new_status
	if(status == BAY_LIGHT_BROKEN)
		force = 5
		sharp = IS_SHARP_ITEM_SIMPLE
	update()

/**
 * Lights the bulb up, which may burn it out, and blows it up if it has phoron in it
 *
 * Returns its state afterwards.
 */
/obj/item/light_bulb/bay/proc/switch_on()
	switchcount++
	if(reagents?.total_volume)
		if(reagents.get_reagent_amount("phoron") >= LIGHT_PHORON_EXPLODE_THRESHOLD)
			visible_message(SPAN_DANGER("\The [src] flares brilliantly!"), SPAN_DANGER("You hear a loud crack!"))
			message_admins("Rigged light explosion, last touched by [fingerprintslast]")
			set_status(BAY_LIGHT_BROKEN)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), get_turf(src), 0, 0, 3, 0), 0.5 SECONDS)
		else
			visible_message(SPAN_WARNING("\The [src] short-circuits as something burns out its filament!"))
			set_status(BAY_LIGHT_BURNED)
			if(sound_on)
				playsound(src, sound_on, 50)
	else if(prob(min(60, switchcount * switchcount * 0.01)))
		set_status(BAY_LIGHT_BURNED)
	else if(sound_on)
		playsound(src, sound_on, 35)
	return status

/obj/item/light_bulb/bay/attackby(obj/item/attacking_item, mob/user)
	if(!istype(attacking_item, /obj/item/reagent_container/syringe) || status != BAY_LIGHT_OK)
		return ..()
	var/obj/item/reagent_container/syringe/syringe = attacking_item
	if(!syringe.reagents.total_volume)
		return ..()
	if(reagents)
		to_chat(user, SPAN_WARNING("\The [src] is already filled with fluid!"))
		return
	create_reagents(5)
	syringe.reagents.trans_to(src, 5)
	to_chat(user, SPAN_WARNING("You inject the solution into \the [src]."))
	if(reagents.get_reagent_amount("phoron") >= LIGHT_PHORON_EXPLODE_THRESHOLD)
		message_admins("[key_name_admin(user)] injected a light with phoron, rigging it to explode.")

/obj/item/light_bulb/bay/get_examine_text(mob/user)
	. = ..()
	if(reagents?.total_volume && Adjacent(user))
		. += SPAN_WARNING("There's some sort of fluid inside \the [src].")

/// A Bay light tube
/obj/item/light_bulb/bay/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	b_range = 5
	lighting_modes = list(
		LIGHTMODE_EMERGENCY = list("l_range" = 4, "l_power" = 1, "l_color" = LIGHT_COLOUR_E_RED),
	)
	sound_on = 'modular_chaos/universes/bay12/sound/machines/lightson.ogg'

/obj/item/light_bulb/bay/tube/warm
	name = "light tube (warm)"
	desc = "A replacement light tube. This one provides soft, warm lighting."
	b_colour = LIGHT_COLOUR_WARM
	random_tone = FALSE

/obj/item/light_bulb/bay/tube/cool
	name = "light tube (cool)"
	desc = "A replacement light tube. This one provides crisp, cool lighting."
	b_colour = LIGHT_COLOUR_COOL
	random_tone = FALSE

/obj/item/light_bulb/bay/tube/white
	name = "light tube (white)"
	desc = "A replacement light tube. This one provides clean, white lighting."
	b_colour = LIGHT_COLOUR_WHITE
	random_tone = FALSE

/// A Bay light tube of a random colour, mostly for testing
/obj/item/light_bulb/bay/tube/party/Initialize(mapload, light_color)
	. = ..()
	b_colour = rgb(pick(0, 255), pick(0, 255), pick(0, 255))
	update()

/// A Bay large light tube, for spotlights
/obj/item/light_bulb/bay/tube/large
	name = "large light tube"
	w_class = SIZE_SMALL
	b_range = 8

/obj/item/light_bulb/bay/tube/large/warm
	name = "large light tube (warm)"
	desc = "A replacement light tube. This one provides soft, warm lighting."
	b_colour = LIGHT_COLOUR_WARM
	random_tone = FALSE

/obj/item/light_bulb/bay/tube/large/cool
	name = "large light tube (cool)"
	desc = "A replacement light tube. This one provides crisp, cool lighting."
	b_colour = LIGHT_COLOUR_COOL
	random_tone = FALSE

/obj/item/light_bulb/bay/tube/large/white
	name = "large light tube (white)"
	desc = "A replacement light tube. This one provides clean, white lighting."
	b_colour = LIGHT_COLOUR_WHITE
	random_tone = FALSE

/obj/item/light_bulb/bay/tube/large/party/Initialize(mapload, light_color)
	. = ..()
	b_colour = rgb(pick(0, 255), pick(0, 255), pick(0, 255))
	update()

/// A Bay light bulb
/obj/item/light_bulb/bay/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	broken_chance = 3
	b_range = 4
	lighting_modes = list(
		LIGHTMODE_EMERGENCY = list("l_range" = 3, "l_power" = 1, "l_color" = LIGHT_COLOUR_E_RED),
	)

/obj/item/light_bulb/bay/bulb/warm
	name = "light bulb (warm)"
	desc = "A replacement light bulb. This one provides soft, warm lighting."
	b_colour = LIGHT_COLOUR_WARM
	random_tone = FALSE

/obj/item/light_bulb/bay/bulb/cool
	name = "light bulb (cool)"
	desc = "A replacement light bulb. This one provides crisp, cool lighting."
	b_colour = LIGHT_COLOUR_COOL
	random_tone = FALSE

/obj/item/light_bulb/bay/bulb/white
	name = "light bulb (white)"
	desc = "A replacement light bulb. This one provides clean, white lighting."
	b_colour = LIGHT_COLOUR_WHITE
	random_tone = FALSE

/// A Bay red light bulb, which keeps its colour whatever the tone of its area
/obj/item/light_bulb/bay/bulb/red
	color = LIGHT_COLOUR_E_RED
	b_colour = LIGHT_COLOUR_E_RED
	random_tone = FALSE

/obj/item/light_bulb/bay/bulb/red/Initialize(mapload, light_color)
	return ..(mapload, LIGHT_COLOUR_E_RED)

/// The bulb of a ready light
/obj/item/light_bulb/bay/bulb/red/readylight
	lighting_modes = list(
		LIGHTMODE_READY = list("l_range" = 5, "l_power" = 1, "l_color" = LIGHT_COLOUR_READY),
	)

/**
 * A Bay light fixture frame
 *
 * A CM frame, wired then closed with a screwdriver into the fixture it was made for.
 */
/obj/structure/machinery/light_construct/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/lighting.dmi'
	layer = FLY_LAYER
	/// The fixture it becomes
	var/fixture_path = /obj/structure/machinery/light/bay

/obj/structure/machinery/light_construct/bay/Initialize()
	. = ..()
	update_icon()

/obj/structure/machinery/light_construct/bay/update_icon()
	switch(stage)
		if(LIGHT_STAGE_EMPTY)
			icon_state = "[fixture_type]-construct-stage1"
		if(LIGHT_STAGE_WIRED)
			icon_state = "[fixture_type]-construct-stage2"
		if(LIGHT_STAGE_COMPLETE)
			icon_state = "[fixture_type]_empty"

/obj/structure/machinery/light_construct/bay/attackby(obj/item/attacking_item, mob/user)
	add_fingerprint(user)
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		switch(stage)
			if(LIGHT_STAGE_EMPTY)
				playsound(loc, 'sound/items/Ratchet.ogg', 25, TRUE)
				to_chat(user, SPAN_NOTICE("You begin deconstructing \the [src]."))
				if(!do_after(user, 3 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
					return
				user.visible_message(SPAN_NOTICE("[user] deconstructs \the [src]."),
					SPAN_NOTICE("You deconstruct \the [src]!"), SPAN_NOTICE("You hear ratcheting and metal scraping."))
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, TRUE)
				deconstruct()
			if(LIGHT_STAGE_WIRED)
				to_chat(user, SPAN_WARNING("You have to remove the wires first."))
			if(LIGHT_STAGE_COMPLETE)
				to_chat(user, SPAN_WARNING("You have to unscrew the case first."))
		return
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WIRECUTTERS))
		if(stage != LIGHT_STAGE_WIRED)
			to_chat(user, SPAN_WARNING("There are no exposed wires to cut!"))
			return
		stage = LIGHT_STAGE_EMPTY
		update_icon()
		new /obj/item/stack/cable_coil(get_turf(loc), 1, "red")
		user.visible_message(SPAN_NOTICE("[user] cuts the wires from \the [src]."),
			SPAN_NOTICE("You cut \the [src]'s wires and remove them from the frame."), SPAN_NOTICE("You hear snipping and cables being cut."))
		playsound(loc, 'sound/items/Wirecutter.ogg', 25, TRUE)
		return
	if(istype(attacking_item, /obj/item/stack/cable_coil))
		if(stage != LIGHT_STAGE_EMPTY)
			to_chat(user, SPAN_WARNING("There is no exposed, empty area to wire!"))
			return
		var/obj/item/stack/cable_coil/coil = attacking_item
		if(coil.use(1))
			stage = LIGHT_STAGE_WIRED
			update_icon()
			user.visible_message(SPAN_NOTICE("[user] adds wires to \the [src]."), SPAN_NOTICE("You add wires to \the [src]."))
			playsound(loc, 'sound/items/Deconstruct.ogg', 25, TRUE)
		return
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER) && stage == LIGHT_STAGE_WIRED)
		stage = LIGHT_STAGE_COMPLETE
		update_icon()
		user.visible_message(SPAN_NOTICE("[user] closes \the [src]'s casing."),
			SPAN_NOTICE("You close \the [src]'s casing."), SPAN_NOTICE("You hear screws being tightened."))
		playsound(loc, 'sound/items/Screwdriver.ogg', 25, TRUE)
		var/obj/structure/machinery/light/bay/light = new fixture_path(loc, src)
		light.setDir(dir)
		light.update(FALSE)
		qdel(src)
		return
	return ..()

/// A Bay small light fixture frame
/obj/structure/machinery/light_construct/bay/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	fixture_path = /obj/structure/machinery/light/bay/small
	sheets_refunded = 1

/// A Bay large light fixture frame, for spotlights
/obj/structure/machinery/light_construct/bay/spot
	name = "large light fixture frame"
	desc = "A large light fixture under construction."
	fixture_path = /obj/structure/machinery/light/bay/spot
	sheets_refunded = 3

#undef BAY_LIGHT_OK
#undef BAY_LIGHT_EMPTY
#undef BAY_LIGHT_BROKEN
#undef BAY_LIGHT_BURNED
#undef LIGHT_STAGE_EMPTY
#undef LIGHT_STAGE_WIRED
#undef LIGHT_STAGE_COMPLETE
#undef LIGHT_BULB_TEMPERATURE
#undef BAY_LIGHTING_POWER_FACTOR
#undef LIGHT_PHORON_EXPLODE_THRESHOLD
