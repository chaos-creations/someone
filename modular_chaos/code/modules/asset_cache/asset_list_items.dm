/// Icons of the Human Defense Creator Panel
/datum/asset/spritesheet/defense_menu
	name = "defensemenu"

/datum/asset/spritesheet/defense_menu/register()
	var/list/menu_states = icon_states('modular_chaos/icons/misc/human_defense_menu.dmi')
	for(var/icon_state in menu_states)
		var/icon/icon_sprite = icon('modular_chaos/icons/misc/human_defense_menu.dmi', icon_state)
		icon_sprite.Scale(128, 128)
		Insert(icon_state, icon_sprite)

	// Defenses without a menu sprite are shown as they look in the world
	for(var/datum/human_ai_defense/defense_type as anything in subtypesof(/datum/human_ai_defense))
		var/sprite_name = defense_type::icon_state
		var/atom/spawned_type = defense_type::path_to_spawn
		if(!sprite_name || !spawned_type || (sprite_name in menu_states) || sprites[sprite_name])
			continue

		var/object_icon = spawned_type::icon
		var/object_icon_state = spawned_type::icon_state
		if(!object_icon || !(object_icon_state in icon_states(object_icon)))
			continue

		var/icon/icon_sprite = icon(object_icon, object_icon_state, SOUTH, 1)
		icon_sprite.Scale(128, 128)
		Insert(sprite_name, icon_sprite)

	return ..()

/// Homeworld pictures of the origins ([/datum/origin/var/planet_image]) for the origin picker
/datum/asset/simple/origin_planets

/datum/asset/simple/origin_planets/register()
	for(var/origin_name in GLOB.origins)
		var/datum/origin/origin = GLOB.origins[origin_name]
		var/asset_name = origin.get_planet_asset_name()
		if(asset_name)
			assets[asset_name] = origin.planet_image
	return ..()
