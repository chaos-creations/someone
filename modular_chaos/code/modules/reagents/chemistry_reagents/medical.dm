// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/datum/reagent/medical/adrenaline_concentrated
	name = "Concentrated Adrenaline"
	id = "adrenaline_concentrated"
	description = "A natural muscle and heart stimulant that is in a high concerntration. Useful for restarting the heart and preventing unconciousness but in this concentrated form it will cause minor suffocation. Overdosing may stress the heart and cause tissue damage."
	reagent_state = LIQUID
	color = "#FFE702" // Yellow-ish
	overdose = LOWM_REAGENTS_OVERDOSE
	overdose_critical = LOWM_REAGENTS_OVERDOSE_CRITICAL
	custom_metabolism = AMOUNT_PER_TIME(1, 10 SECONDS)
	chemclass = CHEM_CLASS_COMMON
	properties = list(PROPERTY_PAINKILLING = 10, PROPERTY_ELECTROGENETIC = 6, PROPERTY_OXYGENATING = 3, PROPERTY_REVITALIZING = 1, PROPERTY_INTRAVENOUS = 1, PROPERTY_CARDIOTOXIC = 2.5)
	flags = REAGENT_TYPE_MEDICAL | REAGENT_SCANNABLE

/datum/reagent/medical/saline
	name = "Saline Solution"
	id = "saline"
	description = "A mixture of water, sodium chloride and glucose made to treat blood loss, the symptoms of minor poisoning or hyperthermia."
	reagent_state = LIQUID
	color = COLOR_SILVER
	chemfiresupp = TRUE
	intensitymod = 0.1
	burncolor = "#ffff00"
	burncolormod = 2
	overdose = 999
	overdose_critical = 999 // on_mob_life() handles large doses instead
	chemclass = CHEM_CLASS_COMMON
	properties = list(PROPERTY_HYPOTHERMIC = 0.5, PROPERTY_HEMOGENIC = 1, PROPERTY_ANTITOXIC = 1, PROPERTY_OXYGENATING = 1)

/datum/reagent/medical/saline/on_mob_life(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/human = M
	if(volume >= 40 && prob(25))
		human.EyeBlur(3)
	if(volume >= 60 && prob(25))
		human.EyeBlur(9)
		M.make_dizzy(3)
	if(volume >= 100 && prob(25))
		human.vomit()
