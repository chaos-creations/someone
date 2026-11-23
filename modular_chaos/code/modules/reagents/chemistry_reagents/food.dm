// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/datum/reagent/dehydrated_egg_powder
	name = "Powdered Egg"
	id = "dehydrated_egg_powder"
	description = "Powderized egg-whites and egg-yolk ready to be mixed with water."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	chemclass = CHEM_CLASS_COMMON
	properties = list(PROPERTY_NUTRITIOUS = 2)
	flags = REAGENT_NO_GENERATION

/datum/reagent/dehydrated_milk_powder
	name = "Dehydrated Milk Powder"
	id = "dehydrated_milk_powder"
	description = "Dehydrated milk-product powder waiting to be mixed with water."
	reagent_state = SOLID
	color = "#DFDFDF" // rgb: 223, 223, 223
	chemclass = CHEM_CLASS_COMMON
	properties = list(PROPERTY_NUTRITIOUS = 2)
	flags = REAGENT_NO_GENERATION
