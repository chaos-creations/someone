//Portable generators of Baystation 12 (code/modules/power/port_gen.dm in the source)

#define TEMPERATURE_DIVISOR 40
#define TEMPERATURE_CHANGE_MAX 20

/// The sound of a running Bay generator, its engine on a loop
/datum/looping_sound/generator/bay
	start_sound = null
	start_length = 0
	mid_sounds = 'modular_chaos/universes/bay12/sound/machines/engine.ogg'
	mid_length = 3 SECONDS
	end_sound = null

/**
 * A Bay P.A.C.M.A.N. generator
 *
 * A CM one (fuel loading, bolting, deconstruction and parts as there) that runs as the source's: it is set to a power
 * level rather than a percentage, keeps running past its safe level while it heats up, and blows up once it has been
 * overheating for long enough. It keeps processing while off to cool down. As atmos is not ported, the air around it
 * neither cools nor heats it, and it gives off no exhaust; its fuel are the CM sheets until Bay materials are ported.
 *
 * Its power_gen_percent follows its level, so a CM APC it feeds outside Bay areas gets what it makes.
 */
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay
	name = "\improper P.A.C.M.A.N.-type Portable Generator"
	desc = "A power generator that runs on solid phoron sheets. Rated for 80 kW max safe output."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/portgen.dmi'
	icon_state = "portgen0"
	power_gen = 20000
	time_per_sheet = 96
	sheet_name = "Phoron Sheets"
	/// The power level it runs at, power_gen watts each
	var/power_output = 1
	/// The highest power level it can be set to
	var/max_power_output = 5
	/// The highest power level it can run at without overheating, which its interface shows
	var/max_safe_output = 4
	/// The temperature it starts to overheat above, in degrees Celsius
	var/max_temperature = 300
	/// How much each power level raises the temperature it runs at, in degrees Celsius
	var/temperature_gain = 50
	/// Its temperature, in degrees Celsius
	var/operating_temperature = 0
	/// How many ticks it has been overheating for, less those it has since cooled down for
	var/overheating = 0
	/// The overheating at which it blows up
	var/max_overheat = 150
	/// The devastation, heavy and light ranges of the explosion it blows up with
	var/list/explosion_ranges = list(0, 3, 5)

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/Initialize()
	. = ..()
	sheet_name = initial(sheet_name)
	QDEL_NULL(soundloop)
	soundloop = new /datum/looping_sound/generator/bay(src)
	set_power_output(power_output)

/// Whether it is broken or knocked out by an EMP, IsBroken() in the source
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/proc/is_broken()
	return stat & (BROKEN|EMPED)

/**
 * Sets the power level, and the share of power_gen a CM APC counts it for
 *
 * * new_output - the power level
 */
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/proc/set_power_output(new_output)
	power_output = new_output
	power_gen_percent = power_output * 100
	soundloop?.volume = 10 + 15 * power_output

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/process()
	if(is_on && HasFuel() && !is_broken() && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel()
	else
		if(is_on)
			is_on = FALSE
			soundloop.stop()
		handleInactive()
		if(!operating_temperature && !overheating)
			stop_processing()
	update_icon()
	updateDialog()

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/TogglePower()
	if(is_on)
		is_on = FALSE
		soundloop.stop()
	else if(HasFuel() && !is_broken())
		is_on = TRUE
		start_processing()
		soundloop.start()
	update_icon()

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/update_icon()
	icon_state = is_on ? "[initial(icon_state)]on" : initial(icon_state)

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/get_examine_text(mob/user)
	. = ..()
	if(overheating)
		. += SPAN_DANGER("\The [src] is overheating!")

/// Removes one stack's worth of fuel from the generator
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/DropFuel()
	if(!sheets)
		return
	var/obj/item/stack/sheet/fuel = new sheet_path(loc)
	var/amount = min(sheets, fuel.max_amount)
	fuel.amount = amount
	fuel.update_icon()
	sheets -= amount

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/UseFuel()
	// How much material it uses this tick; HasFuel() made sure there is enough
	var/needed_sheets = power_output / time_per_sheet
	if(needed_sheets > sheet_left)
		sheets--
		sheet_left = (1 + sheet_left) - needed_sheets
	else
		sheet_left -= needed_sheets

	// The temperature it heads for at this power level
	var/average = (56 + 76) / 2 + power_output * temperature_gain
	var/bias = clamp(round((average - operating_temperature) / TEMPERATURE_DIVISOR, 1), -TEMPERATURE_CHANGE_MAX, TEMPERATURE_CHANGE_MAX)
	operating_temperature += bias + rand(-7, 7)

	if(operating_temperature > max_temperature)
		overheat()
	else if(overheating > 0)
		overheating--

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/handleInactive()
	var/cooling_temperature = 20
	if(operating_temperature > cooling_temperature)
		var/temperature_loss = clamp(round((operating_temperature - cooling_temperature) / TEMPERATURE_DIVISOR, 1), 2, TEMPERATURE_CHANGE_MAX)
		operating_temperature = max(operating_temperature - temperature_loss, cooling_temperature)
	else
		operating_temperature = 0
	if(overheating)
		overheating--

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/overheat()
	overheating++
	if(overheating > max_overheat)
		explode()

/// Blows the generator up
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/proc/explode()
	sheets = 0
	sheet_left = 0
	explosion(loc, explosion_ranges[1], explosion_ranges[2], explosion_ranges[3], -1)
	qdel(src)

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/emp_act(severity)
	. = ..()
	if(!is_on)
		return
	var/duration
	switch(severity)
		if(1)
			stat |= BROKEN
			if(prob(75))
				explode()
				return
			duration = 10 MINUTES
		if(2)
			if(prob(25))
				stat |= BROKEN
			if(prob(10))
				explode()
				return
			duration = 30 SECONDS
	stat |= EMPED
	addtimer(CALLBACK(src, PROC_REF(resolve_emp)), duration)

/// Ends the outage an EMP caused
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/proc/resolve_emp()
	stat &= ~EMPED

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/attack_alien(mob/living/carbon/xenomorph/attacking_xeno)
	. = ..()
	if(!is_on)
		soundloop.stop()
		update_icon()
		// Stopped by the CM generator, it still has to cool down
		start_processing()

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/attackby(obj/item/attacking_item, mob/user)
	if(is_on && HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		to_chat(user, SPAN_WARNING("Turn off \the [src] before wrenching its bolts."))
		return
	return ..()

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, SPAN_WARNING("The generator needs to be secured first."))
		return
	return ..()

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/tgui_interact(mob/user, datum/tgui/ui)
	if(is_broken())
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/BayPacman", name)
		ui.open()

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/ui_data(mob/user)
	// 1 sheet = 1000 cm3, as the source says
	return list(
		"active" = is_on,
		"output_set" = power_output,
		"output_max" = max_power_output,
		"output_safe" = max_safe_output,
		"output_watts" = power_output * power_gen,
		"temperature_current" = operating_temperature,
		"temperature_max" = max_temperature,
		"temperature_overheat" = overheating ? overheating / max_overheat * 100 : 0,
		"fuel_stored" = round(sheets * 1000 + sheet_left * 1000),
		"fuel_capacity" = round(max_sheets * 1000, 0.1),
		"fuel_usage" = is_on ? round(power_output / time_per_sheet * 1000) : 0,
		"fuel_type" = sheet_name,
	)

// Its actions are named apart from those of the CM generator, whose ui_act() runs first and handles its own
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("enable")
			if(!is_on)
				TogglePower()
			return TRUE
		if("disable")
			if(is_on)
				TogglePower()
			return TRUE
		if("eject_fuel")
			if(!is_on)
				DropFuel()
			return TRUE
		if("output_lower")
			if(power_output > 1)
				set_power_output(power_output - 1)
			return TRUE
		if("output_higher")
			if(power_output < max_power_output)
				set_power_output(power_output + 1)
			return TRUE

/**
 * A Bay S.U.P.E.R.P.A.C.M.A.N. generator
 *
 * It glows past its safe level as in the source; as CM has no radiation, it gives off none.
 */
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/super
	name = "\improper S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	desc = "A power generator that utilizes uranium sheets as fuel. Can run for much longer than the standard PACMAN type generators. Rated for 80 kW max safe output."
	icon_state = "portgen1"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	sheet_name = "Uranium Sheets"
	time_per_sheet = 576
	board_path = /obj/item/circuitboard/machine/pacman/super
	explosion_ranges = list(2, 5, 9)
	/// The strength of its radiation in the source, which sets how far it glows
	var/rad_power = 4

/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/super/update_icon()
	. = ..()
	overlays.Cut()
	if(!is_on || power_output < max_safe_output)
		set_light(0)
		return
	var/image/glow = image(icon, "[initial(icon_state)]rad")
	glow.blend_mode = BLEND_ADD
	glow.alpha = round(255 * power_output / max_power_output)
	overlays += glow
	set_light(rad_power + power_output - max_safe_output, 0.7, "#3b97ca")

/// A Bay M.R.S.P.A.C.M.A.N. generator
/obj/structure/machinery/power/power_generator/port_gen/pacman/bay/mrs
	name = "\improper M.R.S.P.A.C.M.A.N.-type Portable Generator"
	desc = "An advanced power generator that runs on tritium. Rated for 200 kW maximum safe output!"
	icon_state = "portgen2"
	sheet_path = /obj/item/stack/sheet/mineral/tritium
	sheet_name = "Tritium Fuel Sheets"
	power_gen = 25000
	max_power_output = 10
	max_safe_output = 8
	time_per_sheet = 576
	max_temperature = 800
	temperature_gain = 90
	board_path = /obj/item/circuitboard/machine/pacman/mrs
	explosion_ranges = list(3, 6, 12)

#undef TEMPERATURE_DIVISOR
#undef TEMPERATURE_CHANGE_MAX
