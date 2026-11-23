// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/reagent_container/glass/bottle/dexalinplus
	name = "\improper Dexalin+ bottle"
	desc = "A small bottle filled with dexalin+. Hyper-condensed microcapsules quickly release oxygen into the bloodstream, immediately offsetting the effects of O2 deprivation."
	volume = 140
	amount_per_transfer_from_this = 140

/obj/item/reagent_container/glass/bottle/dexalinplus/Initialize()
	. = ..()
	reagents.add_reagent("dexalinp", 140)
	update_icon()

/obj/item/reagent_container/glass/bottle/imialk
	name = "\improper Imidazoline-Alkysine bottle"
	desc = "A small bottle of imidazoline and alkysine, used to heal brain and eye damage."
	volume = 140
	amount_per_transfer_from_this = 140

/obj/item/reagent_container/glass/bottle/imialk/Initialize()
	. = ..()
	reagents.add_reagent("imidazoline", 70)
	reagents.add_reagent("alkysine", 70)
	update_icon()

/obj/item/reagent_container/glass/bottle/merabica
	name = "\improper Meralyne-Bicaridine bottle"
	desc = "A small bottle of meralyne and bicaridine. Rapidly heals brute damage."
	volume = 140
	amount_per_transfer_from_this = 140

/obj/item/reagent_container/glass/bottle/merabica/Initialize()
	. = ..()
	reagents.add_reagent("bicaridine", 70)
	reagents.add_reagent("meralyne", 70)
	update_icon()

/obj/item/reagent_container/glass/bottle/keloderm
	name = "\improper Kelotane-Dermaline bottle"
	desc = "A small bottle of kelotane & dermaline, a pair of burn regrowth drugs."
	volume = 140
	amount_per_transfer_from_this = 140

/obj/item/reagent_container/glass/bottle/keloderm/Initialize()
	. = ..()
	reagents.add_reagent("kelotane", 70)
	reagents.add_reagent("dermaline", 70)
	update_icon()
