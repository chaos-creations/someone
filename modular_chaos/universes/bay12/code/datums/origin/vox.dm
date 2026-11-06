/**
 * Origin of a Vox: one of the five arkships of the Vox Empire, the moon-sized ships that are the only home the Vox have
 *
 * Its characters get Vox names, from the syllables of Vox-pidgin.
 */
/datum/origin/vox
	star_system = STAR_SYSTEM_VOX_ARKFLEET
	planet_type = PLANET_TYPE_ASTEROID
	planet_size = 30

/datum/origin/vox/generate_human_name(gender = MALE)
	var/datum/language/vox_language = GLOB.all_languages[LANGUAGE_VOX]
	var/name = ""
	for(var/i in 1 to rand(2, 4))
		name += pick(vox_language.syllables)
	return capitalize(lowertext(name))

/datum/origin/vox/starlight_herald
	name = ORIGIN_VOX_STARLIGHT_HERALD
	desc = "You hatched on the leading ark of the Empire, the most crowded and the most holy of them: its Archon commands every Vox, and pilgrims come to its temples to touch what remains of the Creators."
	planet_seed = 9101
	planet_size = 38

/datum/origin/vox/stalwart_guardian
	name = ORIGIN_VOX_STALWART_GUARDIAN
	desc = "You grew up on the fortress ark, where a blind, limping admiral keeps every Vox to the old military doctrines and the forges arm the whole Empire."
	planet_seed = 9202

/datum/origin/vox/curious_acolyte
	name = ORIGIN_VOX_CURIOUS_ACOLYTE
	desc = "You come from the ark whose confused Apex digs ever deeper into the lost technology of the Creators, sending its admiral from one excavation of their ruins to the next."
	planet_seed = 9303
	planet_size = 28

/datum/origin/vox/dutiful_blade
	name = ORIGIN_VOX_DUTIFUL_BLADE
	desc = "You were born on the processing ark, the industrial heart of the Empire, where the trophies and scrap of the fleets are melted down into everything the arks need."
	planet_seed = 9404
	planet_size = 34

/datum/origin/vox/vigilant_prophet
	name = ORIGIN_VOX_VIGILANT_PROPHET
	desc = "You were grown on the shipyard ark, where ore, biomass and wrecks feed the forges that birth the living starships of the Vox and the crews that fly them."
	planet_seed = 9505

/// The Vox Empire: the arkships drift together through the void, around the light of their fleet instead of a star
/datum/star_system/vox_arkfleet
	name = STAR_SYSTEM_VOX_ARKFLEET
	star_seed = 6217
	star_size = 48
	star_colors = list("#f2e6ff", "#e8d8ff", "#b48cff", "#7a4fd1", "#3a1f6e", "#b48cff", "#e8d8ff")
	star_spin = 0.5
	background_seed = 6601
	background_colorscheme = "NYX8"
	background_planets = TRUE
