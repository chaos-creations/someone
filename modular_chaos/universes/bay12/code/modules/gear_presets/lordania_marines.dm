/// The Lordanian Sovereign Systems, a human state of the Baystation 12 universe
/datum/equipment_preset/lordania
	name = "Lordanian Sovereign Systems"
	faction = FACTION_LORDANIA
	faction_group = list(FACTION_LORDANIA)
	idtype = /obj/item/card/id/dogtag

/**
 * A marine of the infantry squad of the LSS Marine Corps, from Proxi-BoS-Bay12 (maps/torch/job/marine_jobs.dm)
 *
 * A squad is a squad leader, a combat medic, a technician and two riflemen. They wear the Marine utility uniform and
 * an infantry rig, which takes the place of the backpack, and carry the gear of their role, but no weapons yet. Each
 * role has two presets: with the rig on the back, and with the rig already sealed and online.
 */
/datum/equipment_preset/lordania/marine
	name = "LSS Marine"
	/// Type of the rig worn on the back
	var/rig_type = /obj/item/rig/infantry/equipped
	/// Whether the rig is sealed around the marine when they spawn
	var/rig_sealed = FALSE

/datum/equipment_preset/lordania/marine/load_gear(mob/living/carbon/human/new_human, client/mob_client)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/lordania/utility/green, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/lordania, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/lordania, WEAR_HANDS)
	// The Lordanian marines have no radio channel of their own yet
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress, WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new rig_type, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full, WEAR_R_STORE)
	load_role_gear(new_human)
	put_in_rig(new_human, new /obj/item/device/flashlight)
	put_in_rig(new_human, new /obj/item/storage/box/mre)
	if(!rig_sealed)
		return
	var/obj/item/rig/rig = new_human.back
	if(istype(rig))
		rig.seal_suit(instant = TRUE)

/**
 * Equips the gear of the role, after the uniform, the rig and the first aid pouch
 *
 * Arguments:
 * * new_human - the marine
 */
/datum/equipment_preset/lordania/marine/proc/load_role_gear(mob/living/carbon/human/new_human)
	return

/**
 * Puts an item into the storage of the rig on the back, or deletes it if it doesn't fit, as
 * /mob/proc/equip_to_slot_or_del() does: WEAR_IN_BACK takes only a backpack
 *
 * Arguments:
 * * new_human - the marine
 * * item - the item, newly created
 */
/datum/equipment_preset/lordania/marine/proc/put_in_rig(mob/living/carbon/human/new_human, obj/item/item)
	var/obj/item/rig/rig = new_human.back
	var/obj/item/storage/internal/container = istype(rig) ? rig.storage?.container : null
	if(!container?.can_be_inserted(item, new_human, stop_messages = TRUE))
		qdel(item)
		return
	container.handle_item_insertion(item, TRUE, new_human)

/datum/equipment_preset/lordania/marine/squad_leader
	name = "LSS Marine Squad Leader"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = JOB_LORDANIA_MARINE_SQUAD_LEADER
	job_title = JOB_LORDANIA_MARINE_SQUAD_LEADER
	role_comm_title = "SL"
	minimap_icon = "leader"
	skills = /datum/skills/SL
	rig_type = /obj/item/rig/infantry/sl/equipped

/datum/equipment_preset/lordania/marine/squad_leader/load_role_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range, WEAR_IN_L_STORE)
	put_in_rig(new_human, new /obj/item/device/megaphone)

/datum/equipment_preset/lordania/marine/squad_leader/active_rig
	name = "LSS Marine Squad Leader (Active Rig)"
	rig_sealed = TRUE

/datum/equipment_preset/lordania/marine/medic
	name = "LSS Marine Combat Medic"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = JOB_LORDANIA_MARINE_MEDIC
	job_title = JOB_LORDANIA_MARINE_MEDIC
	role_comm_title = "Med"
	minimap_icon = "medic"
	skills = /datum/skills/combat_medic
	rig_type = /obj/item/rig/infantry/equipped/medic

/datum/equipment_preset/lordania/marine/medic/load_role_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/full, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/autoinjector/full, WEAR_L_STORE)
	put_in_rig(new_human, new /obj/item/device/healthanalyzer)

/datum/equipment_preset/lordania/marine/medic/active_rig
	name = "LSS Marine Combat Medic (Active Rig)"
	rig_sealed = TRUE

/datum/equipment_preset/lordania/marine/technician
	name = "LSS Marine Technician"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = JOB_LORDANIA_MARINE_TECHNICIAN
	job_title = JOB_LORDANIA_MARINE_TECHNICIAN
	role_comm_title = "Tech"
	minimap_icon = "engi"
	skills = /datum/skills/combat_engineer
	rig_type = /obj/item/rig/infantry/equipped/technician

/datum/equipment_preset/lordania/marine/technician/load_role_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding, WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/electronics/full, WEAR_L_STORE)

/datum/equipment_preset/lordania/marine/technician/active_rig
	name = "LSS Marine Technician (Active Rig)"
	rig_sealed = TRUE

/datum/equipment_preset/lordania/marine/rifleman
	name = "LSS Marine Rifleman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = JOB_LORDANIA_MARINE_RIFLEMAN
	job_title = JOB_LORDANIA_MARINE_RIFLEMAN
	role_comm_title = "Rfn"
	minimap_icon = "private"
	skills = /datum/skills/pfc

/datum/equipment_preset/lordania/marine/rifleman/load_role_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full, WEAR_L_STORE)

/datum/equipment_preset/lordania/marine/rifleman/active_rig
	name = "LSS Marine Rifleman (Active Rig)"
	rig_sealed = TRUE
