// Vox organs, as Baystation 12 has them (code/modules/organs/internal/species/vox.dm). They keep upstream's keys
// (/datum/species/var/has_organ) and work like the human ones, so upstream code finds them; only the organs they leave
// behind when removed are their own. The gizzard, the cortical stack and the hindtongue are extra ones without effects:
// what they do in Baystation 12 (eating matter, the backup of the mind, speaking Vox-pidgin) isn't ported.

/datum/internal_organ/heart/vox
	parent_limb = "groin"
	removed_type = /obj/item/organ/heart/vox

/datum/internal_organ/lungs/vox
	name = "air capillary sack"
	removed_type = /obj/item/organ/lungs/vox

/datum/internal_organ/liver/vox
	name = "waste tract"
	removed_type = /obj/item/organ/liver/vox

/datum/internal_organ/kidneys/vox
	name = "filtration bladder"
	parent_limb = "chest"
	removed_type = /obj/item/organ/kidneys/vox

/datum/internal_organ/eyes/vox
	removed_type = /obj/item/organ/eyes/vox

/datum/internal_organ/vox_gizzard
	name = "gizzard"
	parent_limb = "groin"
	removed_type = /obj/item/organ/vox_gizzard

/datum/internal_organ/vox_stack
	name = "cortical stack"
	parent_limb = "head"
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/vox_stack

/datum/internal_organ/vox_hindtongue
	name = "hindtongue"
	parent_limb = "head"
	removed_type = /obj/item/organ/vox_hindtongue
