// The drying timer holds a weakref to the human, who may have been deleted by the time the blood dries
/datum/element/bloody_feet/clear_blood(datum/target)
	CAN_BE_REDEFINED(TRUE)
	if(isweakref(target))
		var/datum/weakref/target_ref = target
		target = target_ref.resolve()
		if(!target)
			return
	return ..(target)
