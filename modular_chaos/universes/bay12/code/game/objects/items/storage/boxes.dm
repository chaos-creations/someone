/obj/item/storage/box/vox
	name = "vox survival kit"
	desc = "A box decorated in warning colors that contains a limited supply of survival tools. The panel and black stripe indicate this one contains nitrogen."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/storage/storage.dmi'
	icon_state = "survivalvox"
	w_class = SIZE_SMALL
	storage_slots = 5

/obj/item/storage/box/vox/fill_preset_inventory()
	new /obj/item/clothing/mask/gas/vox(src)
	new /obj/item/tank/emergency_nitrogen(src)
	new /obj/item/reagent_container/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/device/flashlight/flare(src)
