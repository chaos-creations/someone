// Holy books of the three cults of Auralis, the creators the Vox worship

/obj/item/storage/bible/vox
	name = "the Talons of the Kritiki"
	desc = "Postulates of the great leader and warrior, Auralis Kritiki."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/vox/vox_altar.dmi'
	icon_state = "bibleforce"
	deity_name = "Auralis Reverence"

/obj/item/storage/bible/vox/codex
	name = "the Light of the Chakala"
	desc = "Postulates of the smartest scientist and philosopher, Auralis Chakala."
	icon_state = "biblecodex"

/obj/item/storage/bible/vox/guard
	name = "the Mantle of the Kihikihi"
	desc = "Postulates of a fair and generous judge and guardians, Auralis Kihikihi."
	icon_state = "bibleguard"

/obj/item/storage/bible/vox/guard/fill_preset_inventory()
	new /obj/item/clothing/mask/gas/vox(src)
	new /obj/item/tank/emergency_nitrogen(src)
	new /obj/item/reagent_container/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/device/flashlight/flare(src)
