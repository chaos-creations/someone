/**
 * Vision mode of a rig's vision module: night vision, a scanner or a HUD
 */
/datum/rig_vision
	/// Name of the mode in messages
	var/mode = "vision"
	/// SEE_* flags it adds to the sight of the wearer
	var/vision_flags = NONE
	/// How far, in tiles, the wearer sees in the dark with it; 0 to leave it alone
	var/see_in_dark = 0
	/// Alpha the darkness gets for the wearer with it, lower is brighter; 255 to leave it alone
	var/lighting_alpha = 255
	/// Type of the mob HUD it shows, a MOB_HUD_* value, or null for none
	var/hud_type
	/// Whether it tints the view like night vision goggles do
	var/night_vision = FALSE

/**
 * Starts showing the mode to the wearer
 *
 * Arguments:
 * * wearer - the wearer of the rig
 * * source - the vision module
 */
/datum/rig_vision/proc/apply(mob/living/carbon/human/wearer, obj/item/rig_module/vision/source)
	if(hud_type)
		var/datum/mob_hud/mob_hud = GLOB.huds[hud_type]
		mob_hud.add_hud_to(wearer, source)
	if(night_vision)
		var/matrix_color = NV_COLOR_GREEN
		if(wearer.client?.prefs?.night_vision_preference)
			matrix_color = wearer.client.prefs.nv_color_list[wearer.client.prefs.night_vision_preference]
		wearer.add_client_color_matrix("rig_night_vision", 99, color_matrix_multiply(color_matrix_saturation(0), color_matrix_from_string(matrix_color)))
		wearer.overlay_fullscreen("rig_night_vision", /atom/movable/screen/fullscreen/flash/noise/nvg)

/**
 * Stops showing the mode to the wearer
 *
 * Arguments:
 * * wearer - the wearer of the rig
 * * source - the vision module
 */
/datum/rig_vision/proc/remove(mob/living/carbon/human/wearer, obj/item/rig_module/vision/source)
	if(hud_type)
		var/datum/mob_hud/mob_hud = GLOB.huds[hud_type]
		mob_hud.remove_hud_from(wearer, source)
	if(night_vision)
		wearer.remove_client_color_matrix("rig_night_vision", 1 SECONDS)
		wearer.clear_fullscreen("rig_night_vision", 0.5 SECONDS)

/datum/rig_vision/night
	mode = "night vision"
	see_in_dark = 12
	lighting_alpha = 100
	night_vision = TRUE

/datum/rig_vision/thermal
	mode = "thermal scanner"
	vision_flags = SEE_MOBS

/datum/rig_vision/meson
	mode = "meson scanner"
	vision_flags = SEE_TURFS

/datum/rig_vision/medhud
	mode = "medical HUD"
	hud_type = MOB_HUD_MEDICAL_ADVANCED

/datum/rig_vision/sechud
	mode = "security HUD"
	hud_type = MOB_HUD_SECURITY_ADVANCED

/**
 * Vision module, a visor with one or more vision modes
 *
 * Works with the helmet deployed. Using it turns it on in its first mode, then switches to the next mode each time,
 * and turns it off after the last.
 */
/obj/item/rig_module/vision
	name = "hardsuit visor"
	desc = "A layered, translucent visor system for a hardsuit."
	icon_state = "optics"
	interface_name = "optical scanners"
	interface_desc = "An integrated multi-mode vision system: night vision, thermal and meson scanners."
	toggleable = TRUE
	module_cooldown = 0
	active_power_cost = 2
	/// Types of the vision modes, in the order it cycles through; turned into the datums at Initialize()
	var/list/datum/rig_vision/vision_modes = list(
		/datum/rig_vision/night,
		/datum/rig_vision/thermal,
		/datum/rig_vision/meson,
	)
	/// Index of the current mode in vision_modes
	var/vision_index = 1

/obj/item/rig_module/vision/Initialize(mapload, ...)
	. = ..()
	var/list/mode_datums = list()
	for(var/mode_type in vision_modes)
		mode_datums += new mode_type()
	vision_modes = mode_datums

/obj/item/rig_module/vision/Destroy()
	. = ..()
	QDEL_LIST(vision_modes)

/obj/item/rig_module/vision/get_examine_text(mob/user)
	. = ..()
	var/list/mode_names = list()
	for(var/datum/rig_vision/vision_mode as anything in vision_modes)
		mode_names += vision_mode.mode
	. += SPAN_NOTICE("Its modes: [english_list(mode_names)].")

/obj/item/rig_module/vision/get_status_name()
	if(active)
		var/datum/rig_vision/vision_mode = vision_modes[vision_index]
		return "[interface_name] ([vision_mode.mode])"
	return ..()

/obj/item/rig_module/vision/get_install_problem(obj/item/rig/rig)
	if(rig.visor)
		return "[rig] already has [rig.visor]; take it out first."
	return null

/obj/item/rig_module/vision/installed(obj/item/rig/new_holder)
	. = ..()
	holder.visor = src

/obj/item/rig_module/vision/removed()
	if(holder?.visor == src)
		holder.visor = null
	return ..()

/obj/item/rig_module/vision/use_module()
	if(!active)
		return activate() ? RIG_MODULE_USE_DONE : RIG_MODULE_USE_FAILED
	if(vision_index < length(vision_modes))
		switch_mode(vision_index + 1)
		return RIG_MODULE_USE_DONE
	deactivate()
	vision_index = 1
	return RIG_MODULE_USE_DONE

/obj/item/rig_module/vision/activate()
	if(!holder?.wearer || holder.wearer.head != holder.helmet)
		if(holder?.wearer)
			to_chat(holder.wearer, SPAN_WARNING("[capitalize(interface_name)] needs the helmet deployed."))
		return FALSE
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer = holder.wearer
	RegisterSignal(wearer, COMSIG_HUMAN_POST_UPDATE_SIGHT, PROC_REF(on_update_sight))
	var/datum/rig_vision/vision_mode = vision_modes[vision_index]
	vision_mode.apply(wearer, src)
	wearer.update_sight()
	playsound_client(wearer.client, 'sound/handling/hud_on.ogg', null, 75)
	to_chat(wearer, SPAN_NOTICE("You activate your [vision_mode.mode]."))

/obj/item/rig_module/vision/deactivate()
	var/mob/living/carbon/human/wearer = holder?.wearer
	. = ..()
	if(!. || !wearer)
		return
	UnregisterSignal(wearer, COMSIG_HUMAN_POST_UPDATE_SIGHT)
	var/datum/rig_vision/vision_mode = vision_modes[vision_index]
	vision_mode.remove(wearer, src)
	wearer.update_sight()
	playsound_client(wearer.client, 'sound/handling/hud_off.ogg', null, 75)
	to_chat(wearer, SPAN_NOTICE("You deactivate your [interface_name]."))

/**
 * Switches the active module to another mode
 *
 * Arguments:
 * * new_index - index of the mode in vision_modes
 */
/obj/item/rig_module/vision/proc/switch_mode(new_index)
	var/mob/living/carbon/human/wearer = holder.wearer
	var/datum/rig_vision/old_mode = vision_modes[vision_index]
	old_mode.remove(wearer, src)
	vision_index = new_index
	var/datum/rig_vision/new_mode = vision_modes[vision_index]
	new_mode.apply(wearer, src)
	wearer.update_sight()
	to_chat(wearer, SPAN_NOTICE("You cycle your sensors to <b>[new_mode.mode]</b> mode."))

/obj/item/rig_module/vision/proc/on_update_sight(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	var/datum/rig_vision/vision_mode = vision_modes[vision_index]
	source.sight |= vision_mode.vision_flags
	if(vision_mode.see_in_dark)
		source.see_in_dark = max(source.see_in_dark, vision_mode.see_in_dark)
	if(vision_mode.lighting_alpha < source.lighting_alpha)
		source.lighting_alpha = vision_mode.lighting_alpha
	source.sync_lighting_plane_alpha()

/obj/item/rig_module/vision/multi
	name = "hardsuit optical package"
	desc = "A complete visor system of optical scanners and vision modes."
	icon_state = "fulloptics"
	interface_name = "multi optical visor"
	interface_desc = "An integrated multi-mode vision system: night vision, thermal and meson scanners, medical and security HUDs."
	vision_modes = list(
		/datum/rig_vision/meson,
		/datum/rig_vision/night,
		/datum/rig_vision/thermal,
		/datum/rig_vision/sechud,
		/datum/rig_vision/medhud,
	)

/obj/item/rig_module/vision/meson
	name = "hardsuit meson scanner"
	icon_state = "meson"
	interface_name = "meson scanner"
	interface_desc = "An integrated meson scanner."
	vision_modes = list(/datum/rig_vision/meson)

/obj/item/rig_module/vision/thermal
	name = "hardsuit thermal scanner"
	icon_state = "thermal"
	interface_name = "thermal scanner"
	interface_desc = "An integrated thermal scanner."
	vision_modes = list(/datum/rig_vision/thermal)

/obj/item/rig_module/vision/night
	name = "hardsuit night vision interface"
	desc = "A multi input night vision system for a hardsuit."
	icon_state = "night"
	interface_name = "night vision interface"
	interface_desc = "An integrated night vision system."
	vision_modes = list(/datum/rig_vision/night)

/obj/item/rig_module/vision/sechud
	name = "hardsuit security HUD"
	desc = "A simple tactical information system for a hardsuit."
	icon_state = "securityhud"
	interface_name = "security HUD"
	interface_desc = "An integrated security heads up display."
	vision_modes = list(/datum/rig_vision/sechud)

/obj/item/rig_module/vision/medhud
	name = "hardsuit medical HUD"
	desc = "A simple medical status indicator for a hardsuit."
	icon_state = "healthhud"
	interface_name = "medical HUD"
	interface_desc = "An integrated medical heads up display."
	vision_modes = list(/datum/rig_vision/medhud)
