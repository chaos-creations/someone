// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/// The Wey-Med Plus of the USS Rover with the cmss13-pve stock: the soul Health Diagnostic Equipment in place of health analyzers,
/// saline packs and Tricordazine pills, and no defibrillators or stasis bags
/obj/structure/machinery/cm_vending/sorted/medical/no_access/pve

/obj/structure/machinery/cm_vending/sorted/medical/no_access/pve/populate_product_list(scale)
	listed_products = list(
		list("FIELD SUPPLIES", -1, null, null),
		list("Burn Kit", floor(scale * 10), /obj/item/stack/medical/advanced/ointment, VENDOR_ITEM_REGULAR),
		list("Trauma Kit", floor(scale * 10), /obj/item/stack/medical/advanced/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Ointment", floor(scale * 10), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Roll of Gauze", floor(scale * 10), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Splints", floor(scale * 10), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),
		list("Saline IV bag", floor(scale * 4), /obj/item/reagent_container/blood/saline, VENDOR_ITEM_REGULAR),

		list("AUTOINJECTORS", -1, null, null),
		list("Autoinjector (Bicaridine)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/bicaridine, VENDOR_ITEM_REGULAR),
		list("Autoinjector (Dexalin+)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/dexalinp, VENDOR_ITEM_REGULAR),
		list("Autoinjector (Inaprovaline)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/inaprovaline, VENDOR_ITEM_REGULAR),
		list("Autoinjector (Kelotane)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/kelotane, VENDOR_ITEM_REGULAR),
		list("Autoinjector (Oxycodone)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/oxycodone, VENDOR_ITEM_REGULAR),
		list("Autoinjector (Tramadol)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/tramadol, VENDOR_ITEM_REGULAR),
		list("Autoinjector (Tricord)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/tricord, VENDOR_ITEM_REGULAR),

		list("LIQUID BOTTLES", -1, null, null),
		list("Bottle (Bicaridine)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/bicaridine, VENDOR_ITEM_REGULAR),
		list("Bottle (Dylovene)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/antitoxin, VENDOR_ITEM_REGULAR),
		list("Bottle (Dexalin)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/dexalin, VENDOR_ITEM_REGULAR),
		list("Bottle (Inaprovaline)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/inaprovaline, VENDOR_ITEM_REGULAR),
		list("Bottle (Kelotane)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/kelotane, VENDOR_ITEM_REGULAR),
		list("Bottle (Oxycodone)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/oxycodone, VENDOR_ITEM_REGULAR),
		list("Bottle (Peridaxon)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/peridaxon, VENDOR_ITEM_REGULAR),
		list("Bottle (Tramadol)", floor(scale * 3), /obj/item/reagent_container/glass/bottle/tramadol, VENDOR_ITEM_REGULAR),

		list("PILL BOTTLES", -1, null, null),
		list("Pill Bottle (Bicaridine)", floor(scale * 4), /obj/item/storage/pill_bottle/bicaridine, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Dexalin)", floor(scale * 4), /obj/item/storage/pill_bottle/dexalin, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Dylovene)", floor(scale * 4), /obj/item/storage/pill_bottle/antitox, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Inaprovaline)", floor(scale * 4), /obj/item/storage/pill_bottle/inaprovaline, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Kelotane)", floor(scale * 4), /obj/item/storage/pill_bottle/kelotane, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Peridaxon)", floor(scale * 3), /obj/item/storage/pill_bottle/peridaxon, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Tramadol)", floor(scale * 4), /obj/item/storage/pill_bottle/tramadol, VENDOR_ITEM_REGULAR),
		list("Pill Bottle (Tricordazine)", floor(scale * 3), /obj/item/storage/pill_bottle/tricord, VENDOR_ITEM_REGULAR),

		list("MEDICAL UTILITIES", -1, null, null),
		list("Surgical Line", floor(scale * 2), /obj/item/tool/surgery/surgical_line, VENDOR_ITEM_REGULAR),
		list("Synth-Graft", floor(scale * 2), /obj/item/tool/surgery/synthgraft, VENDOR_ITEM_REGULAR),
		list("Hypospray", floor(scale * 3), /obj/item/reagent_container/hypospray/tricordrazine, VENDOR_ITEM_REGULAR),
		list("Health Diagnostic Equipment", floor(scale * 3), /obj/item/device/healthanalyzer/soul, VENDOR_ITEM_REGULAR),
		list("M276 Pattern Medical Storage Rig", floor(scale * 2), /obj/item/storage/belt/medical, VENDOR_ITEM_REGULAR),
		list("Medical HUD Glasses", floor(scale * 3), /obj/item/clothing/glasses/hud/health, VENDOR_ITEM_REGULAR),
		list("Syringe", floor(scale * 7), /obj/item/reagent_container/syringe, VENDOR_ITEM_REGULAR),
	)
