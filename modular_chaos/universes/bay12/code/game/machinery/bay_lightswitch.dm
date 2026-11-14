//Light switches of Baystation 12 (code/game/machinery/lightswitch.dm in the source)

/**
 * Turns the lights of the area on or off, /area/proc/set_lightswitch() in the source
 *
 * Every light switch of the area turns with it.
 * * new_switch - whether the lights are on
 */
/area/proc/set_lightswitch(new_switch)
	if(lightswitch == new_switch)
		return
	lightswitch = new_switch
	for(var/obj/structure/machinery/light_switch/light_switch in src)
		if(istype(light_switch, /obj/structure/machinery/light_switch/bay))
			var/obj/structure/machinery/light_switch/bay/bay_switch = light_switch
			bay_switch.sync_state()
		else
			light_switch.on = new_switch
			light_switch.updateicon()
	updateicon()
	power_change()

/**
 * A Bay light switch
 *
 * A CM light switch that starts off, as the source's do, so the lights of a room with one are off until someone turns
 * them on. Its light is green when on and red when off.
 */
/obj/structure/machinery/light_switch/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/buttons.dmi'
	icon_state = "light0"
	idle_power_usage = 20
	power_channel = POWER_CHANNEL_LIGHT
	on = FALSE
	/// The type of the area it switches instead of its own, other_area in the source
	var/other_area
	/// The sounds it makes when turned, one of them at random
	var/static/list/switch_sounds = list(
		'modular_chaos/universes/bay12/sound/machines/switch1.ogg',
		'modular_chaos/universes/bay12/sound/machines/switch2.ogg',
		'modular_chaos/universes/bay12/sound/machines/switch3.ogg',
		'modular_chaos/universes/bay12/sound/machines/switch4.ogg',
	)

/obj/structure/machinery/light_switch/bay/Initialize()
	. = ..()
	area = other_area ? locate(other_area) : get_area(src)
	if(name == initial(name))
		name = "light switch ([area.name])"
	on = initial(on)
	area.set_lightswitch(on)
	updateicon()

/obj/structure/machinery/light_switch/bay/updateicon()
	overlays.Cut()
	if(inoperable())
		icon_state = "light-p"
		set_light(0)
		return
	icon_state = "light[on]"
	var/switch_color = on ? "#82ff4c" : "#f86060"
	overlays += emissive_appearance(icon, "light[on]-overlay")
	var/image/switch_light = image(icon, "light[on]-overlay")
	switch_light.color = switch_color
	overlays += switch_light
	set_light(2, 0.25, switch_color)

/obj/structure/machinery/light_switch/bay/get_examine_text(mob/user)
	. = list("[icon2html(src, user)] That's \a [src].", desc)
	if(get_dist(user, src) <= 1)
		. += "A light switch. It is [on ? "on" : "off"]."

/**
 * Turns the switch, and the lights of its area with it
 *
 * * new_state - whether it is on
 */
/obj/structure/machinery/light_switch/bay/proc/set_state(new_state)
	if(on == new_state)
		return
	on = new_state
	area.set_lightswitch(on)
	updateicon()

/// Turns the switch to how the lights of its area are
/obj/structure/machinery/light_switch/bay/proc/sync_state()
	if(!area || on == area.lightswitch)
		return FALSE
	on = area.lightswitch
	updateicon()
	return TRUE

/obj/structure/machinery/light_switch/bay/attack_hand(mob/user)
	if(inoperable())
		return
	playsound(src, pick(switch_sounds), 30)
	set_state(!on)

// Powered by the area it switches
/obj/structure/machinery/light_switch/bay/power_change()
	if(area?.powered(power_channel) || !needs_power)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	sync_state()
	updateicon()
