// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/clothing/glasses/night/medhud/no_nvg
	name = "\improper Mark 2 Battle Medic sight"
	desc = "A headset and biomonitor readout system. Allows the ability to view the biofunction monitor readouts of other marines and linking to the Command & Control network. Click it to toggle."
	hud_type = MOB_HUD_MEDICAL_ADVANCED
	darkness_view = 0
	vision_flags = 0
	lighting_alpha = 255

/obj/item/clothing/glasses/night/m56_goggles/no_nightvision
	actions_types = list(/datum/action/item_action/toggle)
	darkness_view = 0
	vision_flags = 0
	lighting_alpha = 255
