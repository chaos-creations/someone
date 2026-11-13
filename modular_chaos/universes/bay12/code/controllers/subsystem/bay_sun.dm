//The sun of Baystation 12 solar panels (the solar stage of code/controllers/subsystems/misc.dm in the source)

/**
 * The sun of Bay solar panels, the misc subsystem of the source in its solar stage
 *
 * Without the overmap and its stars, the sun turns around the ship at a rate set at random for the round, as it does
 * in the source on maps without a star. Every update it turns, then has each solar control console turn its panels.
 */
SUBSYSTEM_DEF(bay_sun)
	name = "Bay Sun"
	wait = 30 SECONDS
	flags = SS_NO_INIT|SS_KEEP_TIMING
	/// The direction of the sun, in degrees clockwise from north
	var/angle
	/// How far the sun turns every update, in degrees, clockwise if positive
	var/rate
	/// The x step of a line traced towards the sun, along which the larger of the two steps is 1
	var/dx = 0
	/// The y step of a line traced towards the sun, along which the larger of the two steps is 1
	var/dy = 0
	/// The solar control consoles on a network, which the sun updates
	var/list/obj/structure/machinery/power/bay_solar_control/controllers = list()
	/// The consoles still to update this run
	var/list/obj/structure/machinery/power/bay_solar_control/current_run = list()

/datum/controller/subsystem/bay_sun/PreInit()
	. = ..()
	angle = rand(0, 359)
	rate = (rand(0, 1) || -1) * rand(50, 200) * 0.01 * 18

/datum/controller/subsystem/bay_sun/stat_entry(msg)
	msg = "A:[round(angle, 0.1)] R:[round(rate, 0.1)] C:[length(controllers)]"
	return ..()

/datum/controller/subsystem/bay_sun/fire(resumed = FALSE)
	if(!resumed)
		angle = (angle + rate + 360) % 360
		var/sine = sin(angle)
		var/cosine = cos(angle)
		var/larger = max(abs(sine), abs(cosine))
		dx = sine / larger
		dy = cosine / larger
		current_run = controllers.Copy()
	while(length(current_run))
		var/obj/structure/machinery/power/bay_solar_control/controller = current_run[length(current_run)]
		current_run.len--
		if(QDELETED(controller) || !controller.powernet)
			controllers -= controller
			continue
		controller.update()
		if(MC_TICK_CHECK)
			return
