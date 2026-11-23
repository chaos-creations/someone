/**
 * Personal locker of a platoon marine, ported from cmss13-pve.
 *
 * Platoon presets spawn marines with little more than an ID: their uniform, boots and headset wait here, along with
 * their loadout, rank pins and medals. When a marine with a matching job spawns, the first free locker for that job
 * is claimed for them (see [/datum/equipment_preset/proc/claim_personal_locker]) and only they can open it.
 */
/obj/structure/closet/secure_closet/marine_personal
	name = "personal locker"
	desc = "It's an immobile card-locked storage unit."
	icon_state = "secure1"
	/// Real name of the marine this locker belongs to, null while it is free
	var/owner
	/// Whether the locker starts filled with its job's uniform (see [/obj/structure/closet/secure_closet/marine_personal/proc/spawn_gear])
	var/has_cryo_gear = TRUE
	/// Title of the job that can claim this locker, either the job's own title or the squad role it stands in for (JOB_SQUAD_MARINE and so on)
	var/job

/obj/structure/closet/secure_closet/marine_personal/Initialize(mapload, ...)
	. = ..()
	GLOB.personal_closets += src
	if(has_cryo_gear)
		spawn_gear()

/obj/structure/closet/secure_closet/marine_personal/Destroy()
	GLOB.personal_closets -= src
	return ..()

/obj/structure/closet/secure_closet/marine_personal/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("It has a name tag[owner ? ": [owner]." : ". They are still in hypersleep..."]")

/obj/structure/closet/secure_closet/marine_personal/allowed(mob/user)
	return owner && owner == user.real_name

/// Fills the locker with the uniform of its owner
/obj/structure/closet/secure_closet/marine_personal/proc/spawn_gear()
	new /obj/item/clothing/under/marine(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine(src)

// ==USCM FORECON== //

/obj/structure/closet/secure_closet/marine_personal/forecon/spawn_gear()
	new /obj/item/clothing/under/marine/standard(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/forecon(src)

/obj/structure/closet/secure_closet/marine_personal/forecon/rifleman
	job = JOB_SQUAD_MARINE

/obj/structure/closet/secure_closet/marine_personal/forecon/smartgunner
	job = JOB_SQUAD_SMARTGUN

/obj/structure/closet/secure_closet/marine_personal/forecon/corpsman
	job = JOB_SQUAD_MEDIC

/obj/structure/closet/secure_closet/marine_personal/forecon/corpsman/spawn_gear()
	new /obj/item/clothing/under/marine/medic(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/forecon/medic(src)

/obj/structure/closet/secure_closet/marine_personal/forecon/squad_leader
	job = JOB_SQUAD_TEAM_LEADER

/obj/structure/closet/secure_closet/marine_personal/forecon/squad_leader/spawn_gear()
	new /obj/item/clothing/under/marine/standard(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/forecon/tl(src)

/obj/structure/closet/secure_closet/marine_personal/forecon/platoon_leader
	job = JOB_SQUAD_LEADER

/obj/structure/closet/secure_closet/marine_personal/forecon/platoon_leader/spawn_gear()
	new /obj/item/clothing/under/marine/standard(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/forecon/lead(src)

/obj/structure/closet/secure_closet/marine_personal/forecon/rto
	job = JOB_SQUAD_RTO

/obj/structure/closet/secure_closet/marine_personal/forecon/rto/spawn_gear()
	new /obj/item/clothing/under/marine/standard(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/forecon/rto(src)
