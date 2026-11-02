/// Returns what fired this as seen from where it flies: the vehicle for shots from its weapons, since the crew firing them sits in the interior
/obj/projectile/proc/get_shooter()
	var/obj/item/hardpoint/hardpoint = shot_from
	if(istype(hardpoint) && hardpoint.owner)
		return hardpoint.owner
	return firer
