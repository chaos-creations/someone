// Species of the Baystation 12 universe, see modular_chaos/universes/bay12/code/modules/mob/living/carbon/human/species/

/// Name of the Vox species (/datum/species/var/name), also the key of their sprite sheets in /obj/item/var/sprite_sheets
#define SPECIES_VOX "Vox"

#define isvox(A) (ishuman(A) && istype(A?:species, /datum/species/vox))
