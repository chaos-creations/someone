// Organs removed from a Vox, see modular_chaos/universes/bay12/code/modules/organs/organ_internal.dm

/obj/item/organ/heart/vox
	name = "vox heart"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "vox heart"
	dead_icon = null
	organ_type = /datum/internal_organ/heart/vox

/obj/item/organ/lungs/vox
	name = "air capillary sack"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "vox lung"
	gender = NEUTER
	organ_type = /datum/internal_organ/lungs/vox

/obj/item/organ/liver/vox
	name = "waste tract"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "liver"
	color = "#0033cc"
	organ_type = /datum/internal_organ/liver/vox

/obj/item/organ/kidneys/vox
	name = "filtration bladder"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "lungs"
	color = "#99ccff"
	gender = NEUTER
	organ_type = /datum/internal_organ/kidneys/vox

/obj/item/organ/eyes/vox
	color = "#0033cc"
	organ_type = /datum/internal_organ/eyes/vox

/obj/item/organ/vox_gizzard
	name = "gizzard"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "stomach"
	color = "#0033cc"
	organ_tag = "gizzard"
	organ_type = /datum/internal_organ/vox_gizzard

/obj/item/organ/vox_stack
	name = "cortical stack"
	desc = "A small cybernetic implant every Vox carries at the base of the skull, holding a backup of the mind."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "cortical-stack"
	robotic = ORGAN_ROBOT
	organ_tag = "cortical stack"
	organ_type = /datum/internal_organ/vox_stack

/obj/item/organ/vox_hindtongue
	name = "hindtongue"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/surgery_tools.dmi'
	icon_state = "hindtongue"
	organ_tag = "hindtongue"
	organ_type = /datum/internal_organ/vox_hindtongue
