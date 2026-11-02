/client/MouseDrop(datum/src_object, datum/over_object, src_location, over_location, src_control, over_control, params)
	CAN_BE_REDEFINED(TRUE)
	// A drag in pixel shift mode moves the dragged atom, so it must not also drop it onto what is under the mouse
	var/datum/component/pixel_shifting/pixel_shift_mode = mob?.GetComponent(/datum/component/pixel_shifting)
	if(pixel_shift_mode && isatom(src_object) && pixel_shift_mode.is_shift_drop(src_object))
		return
	return ..()
