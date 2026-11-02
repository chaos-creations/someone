/obj/structure/machinery/m56d_hmg
	/// The ammunition that reloads the gun, for human AI gunners
	var/obj/item/ammo_magazine/ammo_box_type = /obj/item/ammo_magazine/m56d

// Human AI gunners have no client, which the upstream check would throw off the gun right away
/obj/structure/machinery/m56d_hmg/check_eye(mob/living/user)
	CAN_BE_REDEFINED(TRUE)
	if(user.client || !user.is_ai_controlled())
		return ..()
	if(user.body_position != STANDING_UP || get_dist(user, src) > 0 || user.is_mob_incapacitated())
		user.unset_interaction()

/// Returns TRUE if the target is within the shoot_degree cone that fire_shot() lets bullets out of
/obj/structure/machinery/m56d_hmg/proc/in_firing_arc(atom/target)
	var/turf/gun_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(!gun_turf || !target_turf || (gun_turf == target_turf))
		return FALSE

	var/difference = abs(Get_Angle(gun_turf, target_turf) - dir2angle(dir))
	if(difference > 180)
		difference = 360 - difference
	return difference <= shoot_degree

/// Returns TRUE if a gunner can shoot at the target from this gun, turning it if the gun allows that
/obj/structure/machinery/m56d_hmg/proc/can_aim_at(atom/target)
	return in_firing_arc(target)
