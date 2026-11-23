// Vendors of the FORECON platoon, ported from cmss13-pve

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/forecon
	name = "\improper ColMarTech FORECON Uniform Vendor"
	icon = 'modular_chaos/icons/obj/structures/machinery/vending.dmi'
	icon_state = "forecon_gear"

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/forecon/populate_product_list(scale)
	listed_products = list(
		list("STANDARD EQUIPMENT", -1, null, null, null),
		list("Marine Combat Boots", floor(scale * 15), /obj/item/clothing/shoes/marine/jungle/knife, VENDOR_ITEM_REGULAR),
		list("Marine Uniform", floor(scale * 15), /obj/item/clothing/under/marine/standard, VENDOR_ITEM_REGULAR),
		list("Marine Black Gloves", round(scale * 15), /obj/item/clothing/gloves/marine, VENDOR_ITEM_REGULAR),
		list("Marine Brown Gloves", round(scale * 15), /obj/item/clothing/gloves/marine/brown, VENDOR_ITEM_REGULAR),
		list("Marine Radio Headset", round(scale * 15), /obj/item/device/radio/headset/almayer/marine/forecon, VENDOR_ITEM_REGULAR),
		list("M5 Pattern Camera Headset", floor(scale * 15), /obj/item/device/overwatch_camera, VENDOR_ITEM_REGULAR),
		list("Patrol Cap, Jungle BDU", floor(scale * 15), /obj/item/clothing/head/cmcap/jungle, VENDOR_ITEM_REGULAR),
		list("Patrol Cap, Snow", floor(scale * 15), /obj/item/clothing/head/cmcap/snow, VENDOR_ITEM_REGULAR),
		list("Patrol Cap, Desert", floor(scale * 15), /obj/item/clothing/head/cmcap/desert, VENDOR_ITEM_REGULAR),
		list("Patrol Cap, Khaki", round(scale * 5), /obj/item/clothing/head/cmcap/khaki, VENDOR_ITEM_REGULAR),
		list("Boonie Hat, Jungle", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie/jungle, VENDOR_ITEM_REGULAR),
		list("Boonie Hat, Desert", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie/tan, VENDOR_ITEM_REGULAR),
		list("Boonie Hat, Snow", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie/snow, VENDOR_ITEM_REGULAR),

		list("WEBBINGS", -1, null, null),
		list("M3-R Pattern Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m3/recon, VENDOR_ITEM_REGULAR),
		list("M3-R Pattern Shotgun Shell Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m3/recon/shotgun, VENDOR_ITEM_REGULAR),
		list("M3-R Pattern M40 Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m3/recon/m40, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 3, /obj/item/clothing/accessory/storage/droppouch, VENDOR_ITEM_REGULAR),
		list("Shoulder Holster", round(max(1,(scale * 0.5))), /obj/item/clothing/accessory/storage/holster, VENDOR_ITEM_REGULAR),

		list("ARMOR", -1, null, null),
		list("M3-R Pattern Recon Armor", round(scale * 10), /obj/item/clothing/suit/storage/marine/medium/rto/forecon, VENDOR_ITEM_REGULAR),
		list("M3 Pattern Vambraces", round(scale * 10), /obj/item/clothing/accessory/pads/bracers/standard, VENDOR_ITEM_REGULAR),
		list("M3 Pattern Greaves", round(scale * 10), /obj/item/clothing/accessory/pads/greaves/standard, VENDOR_ITEM_REGULAR),
		list("M3 Pattern Kneepads", round(scale * 10), /obj/item/clothing/accessory/pads/kneepads/standard, VENDOR_ITEM_REGULAR),

		list("BACKPACK", -1, null, null, null),
		list("Lightweight IMP Backpack", round(scale * 15), /obj/item/storage/backpack/marine/standard, VENDOR_ITEM_REGULAR),
		list("USCM Satchel", round(scale * 15), /obj/item/storage/backpack/marine/satchel, VENDOR_ITEM_REGULAR),
		list("USCM Technical Satchel", floor(scale * 15), /obj/item/storage/backpack/marine/satchel/tech, VENDOR_ITEM_REGULAR),

		list("BELTS", -1, null, null),
		list("M276 Pattern Ammo Load Rig", round(scale * 15), /obj/item/storage/belt/marine/standard, VENDOR_ITEM_REGULAR),
		list("M276 Pattern M40 Grenade Rig", round(scale * 10), /obj/item/storage/belt/grenade, VENDOR_ITEM_REGULAR),
		list("M276 Pattern General Pistol Holster Rig", round(scale * 15), /obj/item/storage/belt/gun/m4a3/standard, VENDOR_ITEM_REGULAR),
		list("M276 Pattern General Revolver Holster Rig", floor(scale * 15), /obj/item/storage/belt/gun/m44, VENDOR_ITEM_REGULAR),
		list("M276 Pattern M82F Holster Rig", round(scale * 5), /obj/item/storage/belt/gun/flaregun, VENDOR_ITEM_REGULAR),
		list("M276 G8-A General Utility Pouch", round(scale * 15), /obj/item/storage/backpack/general_belt/standard, VENDOR_ITEM_REGULAR),

		list("POUCHES", -1, null, null, null),
		list("First-Aid Pouch", floor(scale * 15), /obj/item/storage/pouch/firstaid, VENDOR_ITEM_REGULAR),
		list("Flare Pouch (Full)", floor(scale * 15), /obj/item/storage/pouch/flare/full, VENDOR_ITEM_REGULAR),
		list("Magazine Pouch", floor(scale * 15), /obj/item/storage/pouch/magazine, VENDOR_ITEM_REGULAR),
		list("Medium General Pouch", floor(scale * 15), /obj/item/storage/pouch/general/medium, VENDOR_ITEM_REGULAR),
		list("Pistol Magazine Pouch", floor(scale * 15), /obj/item/storage/pouch/magazine/pistol, VENDOR_ITEM_REGULAR),
		list("Pistol Pouch", floor(scale * 15), /obj/item/storage/pouch/pistol, VENDOR_ITEM_REGULAR),

		list("RESTRICTED POUCHES", -1, null, null, null),
		list("Construction Pouch", 1.25, /obj/item/storage/pouch/construction, VENDOR_ITEM_REGULAR),
		list("Explosive Pouch", 1.25, /obj/item/storage/pouch/explosive, VENDOR_ITEM_REGULAR),
		list("First Responder Pouch", 2.5, /obj/item/storage/pouch/first_responder, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", floor(scale * 2), /obj/item/storage/pouch/magazine/pistol/large, VENDOR_ITEM_REGULAR),
		list("Tools Pouch", 1.25, /obj/item/storage/pouch/tools, VENDOR_ITEM_REGULAR),
		list("Sling Pouch", 1.25, /obj/item/storage/pouch/sling, VENDOR_ITEM_REGULAR),
		list("Incinerator Fuel Tank Pouch", 1.25, /obj/item/storage/pouch/flamertank, VENDOR_ITEM_REGULAR),
		list("Shotgun Shell Pouch", 1.25, /obj/item/storage/pouch/shotgun, VENDOR_ITEM_REGULAR),

		list("MASK", -1, null, null, null),
		list("M5 Gas Mask", floor(scale * 15), /obj/item/clothing/mask/gas/military, VENDOR_ITEM_REGULAR),
		list("Tactical Wrap", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf/tacticalmask, VENDOR_ITEM_REGULAR),
		list("Heat Absorbent Coif", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf, VENDOR_ITEM_REGULAR),

		list("ADDITIONAL CLOTHING", -1, null, null),
		list("Poncho, Green", round(scale * 10), /obj/item/clothing/accessory/poncho/green, VENDOR_ITEM_REGULAR),
		list("Poncho, Brown", round(scale * 10), /obj/item/clothing/accessory/poncho/brown, VENDOR_ITEM_REGULAR),
		list("Poncho, Black", round(scale * 10), /obj/item/clothing/accessory/poncho/black, VENDOR_ITEM_REGULAR),
		list("Bandana, Jungle", round(scale * 5), /obj/item/clothing/head/cmbandana, VENDOR_ITEM_REGULAR),
		list("Bandana, Desert", round(scale * 5), /obj/item/clothing/head/cmbandana/tan, VENDOR_ITEM_REGULAR),
		list("Beanie, Jungle", round(scale * 5), /obj/item/clothing/head/beanie/green, VENDOR_ITEM_REGULAR),
		list("Beanie, Urban", round(scale * 5), /obj/item/clothing/head/beanie/gray, VENDOR_ITEM_REGULAR),
		list("Beanie, Desert", round(scale * 5), /obj/item/clothing/head/beanie/tan, VENDOR_ITEM_REGULAR),
		list("Durag, Black", round(scale * 5), /obj/item/clothing/head/durag/black, VENDOR_ITEM_REGULAR),
		list("Durag, Camo Conforming", round(scale * 5), /obj/item/clothing/head/durag, VENDOR_ITEM_REGULAR),
		list("Expedition Cap, Jungle", round(scale * 5), /obj/item/clothing/head/cmcap/flap/jungle, VENDOR_ITEM_REGULAR),
		list("Expedition Cap, Desert", round(scale * 5), /obj/item/clothing/head/cmcap/flap/desert, VENDOR_ITEM_REGULAR),
		list("Expedition Cap, Snow", round(scale * 5), /obj/item/clothing/head/cmcap/flap/snow, VENDOR_ITEM_REGULAR),
		list("USCM Headset", round(scale * 5), /obj/item/clothing/head/headset/, VENDOR_ITEM_REGULAR),
		list("Headband, Brown", round(scale * 5), /obj/item/clothing/head/headband/brown, VENDOR_ITEM_REGULAR),
		list("Headband, Gray", round(scale * 5), /obj/item/clothing/head/headband/brown, VENDOR_ITEM_REGULAR),
		list("Headband, Red", round(scale * 5), /obj/item/clothing/head/headband/red, VENDOR_ITEM_REGULAR),
		list("Headband, Green", round(scale * 5), /obj/item/clothing/head/headband, VENDOR_ITEM_REGULAR),
		list("Headband, Tan", round(scale * 5), /obj/item/clothing/head/headband/tan, VENDOR_ITEM_REGULAR),

		list("MISCELLANEOUS", -1, null, null, null),
		list("Ballistic goggles", round(scale * 10), /obj/item/clothing/glasses/mgoggles, VENDOR_ITEM_REGULAR),
		list("Ballistic goggles, sun-shaded", round(scale * 10), /obj/item/clothing/glasses/mgoggles/black, VENDOR_ITEM_REGULAR),
		list("Ballistic goggles, laser-shaded (brown)", round(scale * 10), /obj/item/clothing/glasses/mgoggles/orange, VENDOR_ITEM_REGULAR),
		list("Ballistic goggles, laser-shaded (green)", round(scale * 10), /obj/item/clothing/glasses/mgoggles/green, VENDOR_ITEM_REGULAR),
		list("Firearm Lubricant", round(scale * 15), /obj/item/prop/helmetgarb/gunoil, VENDOR_ITEM_REGULAR),
		list("FORECON Shoulder Patch", round(scale * 15), /obj/item/clothing/accessory/patch/forecon, VENDOR_ITEM_REGULAR),
		list("USCM Shoulder Patch", round(scale * 15), /obj/item/clothing/accessory/patch/uscmpatch, VENDOR_ITEM_REGULAR),
		list("LRRP Bedroll", round(scale * 20), /obj/item/roller/bedroll, VENDOR_ITEM_REGULAR),
		list("Marine Issue Compass", round(scale * 20), /obj/item/prop/helmetgarb/compass, VENDOR_ITEM_REGULAR),
		)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/forecon
	icon = 'modular_chaos/icons/obj/structures/machinery/vending.dmi'
	icon_state = "prep"

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/forecon/populate_product_list(scale)
	listed_products = list(
		list("FOOD", -1, null, null),
		list("Extended Patrol MRE", round(scale * 5), /obj/item/storage/box/mre/fsr, VENDOR_ITEM_REGULAR),
		list("MRE Box", round(scale * 1), /obj/item/ammo_box/magazine/misc/mre/fsr, VENDOR_ITEM_REGULAR),

		list("MEDICAL", -1, null, null),
		list("Gauze", round(scale * 15), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Ointment", round(scale * 15), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Splints", round(scale * 15), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),
		list("Emergency Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/emergency, VENDOR_ITEM_REGULAR),
		list("Bicaridine Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/bicaridine/skillless, VENDOR_ITEM_REGULAR),
		list("Kelotane Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/kelotane/skillless, VENDOR_ITEM_REGULAR),
		list("Tricordrazine Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/tricord/skillless, VENDOR_ITEM_REGULAR),
		list("Tramadol Injector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/tramadol/skillless, VENDOR_ITEM_REGULAR),

		list("TOOLS", -1, null, null),
		list("Entrenching Tool (ET)", round(scale * 2), /obj/item/tool/shovel/etool/folded, VENDOR_ITEM_REGULAR),
		list("Screwdriver", round(scale * 5), /obj/item/tool/screwdriver, VENDOR_ITEM_REGULAR),
		list("Wirecutters", round(scale * 5), /obj/item/tool/wirecutters, VENDOR_ITEM_REGULAR),
		list("Crowbar", round(scale * 5), /obj/item/tool/crowbar, VENDOR_ITEM_REGULAR),
		list("Wrench", round(scale * 5), /obj/item/tool/wrench, VENDOR_ITEM_REGULAR),
		list("Multitool", round(scale * 1), /obj/item/device/multitool, VENDOR_ITEM_REGULAR),
		list("Welding Tool", round(scale * 1), /obj/item/tool/weldingtool, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", -1, null, null),
		list("Plastic Explosives", round(scale * 2), /obj/item/explosive/plastic, VENDOR_ITEM_REGULAR),
		list("Breaching Charge", round(scale * 2), /obj/item/explosive/plastic/breaching_charge, VENDOR_ITEM_REGULAR),

		list("FLARE AND LIGHT", -1, null, null),
		list("Combat Flashlight", round(scale * 5), /obj/item/device/flashlight/combat, VENDOR_ITEM_REGULAR),
		list("Box of Flashlights", round(scale * 1), /obj/item/ammo_box/magazine/misc/flashlight, VENDOR_ITEM_REGULAR),
		list("Box of Flares", round(scale * 1), /obj/item/ammo_box/magazine/misc/flares, VENDOR_ITEM_REGULAR),
		list("M94 Marking Flare Pack", round(scale * 10), /obj/item/storage/box/m94, VENDOR_ITEM_REGULAR),
		list("M89-S Signal Flare Pack", round(scale * 1), /obj/item/storage/box/m94/signal, VENDOR_ITEM_REGULAR),
		list("M72A2 HIPF Starshell Grenade Packet", round(scale * 3), /obj/item/storage/box/packet/flare, VENDOR_ITEM_REGULAR),

		list("SIDEARMS", -1, null, null), //forecon loves their pistols
		list("M48A4 Service Pistol", round(scale * 5), /obj/item/weapon/gun/pistol/m1911/socom, VENDOR_ITEM_REGULAR),
		list("M44 Combat Revolver", round(scale * 5), /obj/item/weapon/gun/revolver/m44, VENDOR_ITEM_REGULAR),
		list("M4A3 Service Pistol", round(scale * 5), /obj/item/weapon/gun/pistol/m4a3, VENDOR_ITEM_REGULAR),
		list("VP78 pistol", round(scale * 5), /obj/item/weapon/gun/pistol/vp78, VENDOR_ITEM_REGULAR),
		list("M82F Flare Gun", round(scale * 3), /obj/item/weapon/gun/flare, VENDOR_ITEM_REGULAR),

		list("SIDEARM AMMUNITION", -1, null, null),
		list("M1911 Magazine (.45)", round(scale * 20), /obj/item/ammo_magazine/pistol/m1911, VENDOR_ITEM_REGULAR),
		list("M44 Speedloader (.44)", round(scale * 20), /obj/item/ammo_magazine/revolver, VENDOR_ITEM_REGULAR),
		list("M4A3 Magazine (9mm)", round(scale * 20), /obj/item/ammo_magazine/pistol, VENDOR_ITEM_REGULAR),
		list("VP78 magazine (9mm)", round(scale * 20), /obj/item/ammo_magazine/pistol/vp78, VENDOR_ITEM_REGULAR),

		list("MISCELLANEOUS", -1, null, null),
		list("Extinguisher", round(scale * 5), /obj/item/tool/extinguisher, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", round(scale * 1), /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Roller Bed", round(scale * 2), /obj/item/roller, VENDOR_ITEM_REGULAR),
		list("Machete Scabbard (Full)", round(scale * 5), /obj/item/storage/large_holster/machete/full, VENDOR_ITEM_REGULAR),
		list("Binoculars", round(scale * 1), /obj/item/device/binoculars, VENDOR_ITEM_REGULAR),
		list("Spare PDT/L Battle Buddy Kit", round(scale * 3), /obj/item/storage/box/pdt_kit/advanced, VENDOR_ITEM_REGULAR),
		list("Rail Flashlight", round(scale * 5), /obj/item/attachable/flashlight, VENDOR_ITEM_REGULAR),
		list("Two-point Sling", round(scale * 5), /obj/item/attachable/sling, VENDOR_ITEM_REGULAR),
		list("M13 Fighting Knife", round(scale * 5), /obj/item/weapon/knife/marine, VENDOR_ITEM_REGULAR),
		)
