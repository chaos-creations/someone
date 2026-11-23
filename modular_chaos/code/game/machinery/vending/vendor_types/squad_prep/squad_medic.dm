// Medical vendors of the FORECON platoon, ported from cmss13-pve. Open to the FORECON corpsman as well as the squad one.

GLOBAL_LIST_INIT(cm_vending_clothing_forecon_medic, list(
		list("ARMOR PAINT (CHOOSE 1)", 0, null, null, null),
		list("Red Cross Paint", 0, /obj/item/clothing/accessory/paint/medic, MARINE_CAN_BUY_KIT, VENDOR_ITEM_RECOMMENDED),

		list("OVERWATCH & HUD EQUIPMENT (CHOOSE 1)", 0, null, null, null),
		list("Mark 2 Battle Medic sight", 0, /obj/item/clothing/glasses/night/medhud/no_nvg, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),

		list("ARMOR (CHOOSE 1)", 0, null, null, null),
		list("M3-R Armor", 0, /obj/item/clothing/suit/storage/marine/medium/rto/forecon, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_RECOMMENDED),

		list("BACKPACK (CHOOSE 1)", 0, null, null, null),
		list("Medical Backpack", 0, /obj/item/storage/backpack/marine/medic/standard, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
		list("Medical Satchel", 0, /obj/item/storage/backpack/marine/satchel/medic/standard, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_RECOMMENDED),

		list("BELT (CHOOSE 1)", 0, null, null, null),
		list("M276 Lifesaver Bag (Full)", 0, /obj/item/storage/belt/medical/lifesaver/standard/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Medical Storage Rig (Full)", 0, /obj/item/storage/belt/medical/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),

		list("POUCHES (CHOOSE 2)", 0, null, null, null),
		list("Autoinjector Pouch", 0, /obj/item/storage/pouch/autoinjector, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Medical Kit Pouch", 0, /obj/item/storage/pouch/medkit, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Pressurized Reagent Canister Pouch (Bicaridine)", 0, /obj/item/storage/pouch/pressurized_reagent_canister/bicaridine, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Pressurized Reagent Canister Pouch (Kelotane)", 0, /obj/item/storage/pouch/pressurized_reagent_canister/kelotane, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Pressurized Reagent Canister Pouch (Tricordrazine)", 0, /obj/item/storage/pouch/pressurized_reagent_canister/tricordrazine, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Vial Pouch (Full)", 0, /obj/item/storage/pouch/vials/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

		list("ACCESSORIES (CHOOSE 1)", 0, null, null, null),
		list("M3-R Pattern Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/recon, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M3-R Pattern Shotgun Shell Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/recon/shotgun, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M3-R Pattern M40 Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/recon/m40, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M3-R Pattern Corpsman Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/recon/medic, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_RECOMMENDED),
		list("Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Shoulder Holster", 0, /obj/item/clothing/accessory/storage/holster, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/clothing/medic/forecon
	name = "\improper ColMarTech FORECON Medical Gear Rack"
	vendor_role = list(JOB_SQUAD_MEDIC, JOB_SQUAD_MEDIC_FORECON)
	headset_type = /obj/item/device/radio/headset/almayer/marine/forecon/medic

/obj/structure/machinery/cm_vending/clothing/medic/forecon/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_forecon_medic

// Chemical vendor

GLOBAL_LIST_INIT(cm_vending_chemical_medic, list(

		list("ESSENTIAL MEDICATION (CHOOSE 1)", 0, null, null, null),
		list("Pill Bottle (Imidazoline-Alkysine)", 0, /obj/item/storage/pill_bottle/imialk, MARINE_CAN_BUY_SHOES, VENDOR_ITEM_RECOMMENDED),
		list("Liquid Bottle (Imidazoline-Alkysine)", 0, /obj/item/reagent_container/glass/bottle/imialk, MARINE_CAN_BUY_SHOES, VENDOR_ITEM_RECOMMENDED),

		list("PILL BOTTLES", 0, null, null, null),
		list("Pill Bottle (Meralyne-Bicardine)", 60, /obj/item/storage/pill_bottle/merabica, null, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Kelotane-Dermaline)", 60, /obj/item/storage/pill_bottle/keloderm, null, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Nitrogen-Water)", 30, /obj/item/storage/pill_bottle/nitrogenwater, null, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Dexalin+)", 30, /obj/item/storage/pill_bottle/dexalinplus, null, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Iron)", 30, /obj/item/storage/pill_bottle/iron, null, VENDOR_ITEM_REGULAR),

		list("LIQUID BOTTLES", 0, null, null, null),
		list("Liquid Bottle (Meralyne-Bicardine)", 40, /obj/item/reagent_container/glass/bottle/merabica, null, VENDOR_ITEM_REGULAR),
		list("Liquid Bottle (Kelotane-Dermaline)", 40, /obj/item/reagent_container/glass/bottle/keloderm, null, VENDOR_ITEM_REGULAR),
		list("Liquid Bottle (Dexalin+)", 30, /obj/item/reagent_container/glass/bottle/dexalinplus, null, VENDOR_ITEM_REGULAR),

		list("INJECTORS", 0, null, null, null),
		list("Smart Refill Tank", 40, /obj/item/reagent_container/glass/minitank, null, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/gear/medic_chemical
	name = "\improper ColMarTech Squad Medical Chemical Rack"
	desc = "An automated gear rack for specialized chemicals for the hospital corpsman."
	icon = 'modular_chaos/icons/obj/structures/machinery/vending.dmi'
	icon_state = "med_chem"
	show_points = TRUE
	use_snowflake_points = TRUE
	vendor_role = list(JOB_SQUAD_MEDIC, JOB_SQUAD_MEDIC_FORECON)
	req_access = list(ACCESS_MARINE_MEDPREP)

/obj/structure/machinery/cm_vending/gear/medic_chemical/get_listed_products(mob/user)
	return GLOB.cm_vending_chemical_medic
