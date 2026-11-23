// Lockers of the FORECON platoon, ported from cmss13-pve

/obj/structure/closet/secure_closet/platoon_sergeant_forecon
	name = "squad leader locker"
	desc = "A secure storage unit for the squad leader."
	req_one_access = list(ACCESS_MARINE_LEADER)

/obj/structure/closet/secure_closet/platoon_sergeant_forecon/Initialize()
	. = ..()
	new /obj/item/device/binoculars/range/designator(src)
	new /obj/item/clothing/accessory/device/whistle(src)

/obj/structure/closet/secure_closet/squad_sergeant_forecon
	name = "assistant squad leader locker"
	desc = "A secure storage unit for an assistant squad leader."
	req_one_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_TL_PREP)

/obj/structure/closet/secure_closet/squad_sergeant_forecon/Initialize()
	. = ..()
	new /obj/item/device/binoculars/range/designator(src)
	new /obj/item/clothing/accessory/device/whistle(src)

/obj/structure/closet/secure_closet/smartgunner_forecon
	name = "smartgunner locker"
	desc = "A secure storage unit for a smartgunner."
	req_one_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_SMARTPREP)

/obj/structure/closet/secure_closet/smartgunner_forecon/Initialize()
	. = ..()
	new /obj/item/weapon/gun/smartgun(src)
	new /obj/item/smartgun_battery(src)
	new /obj/item/clothing/suit/storage/marine/smartgunner/standard(src)
	new /obj/item/storage/belt/gun/smartgunner/garrow(src)
	new /obj/item/ammo_magazine/smartgun(src)
	new /obj/item/ammo_magazine/smartgun(src)
	new /obj/item/clothing/glasses/night/m56_goggles/no_nightvision(src)
	new /obj/item/storage/large_holster/machete/smartgunner/full(src)
	new /obj/item/clothing/accessory/storage/webbing/m56(src)
	new /obj/item/clothing/accessory/storage/webbing/m56/grenade(src)
