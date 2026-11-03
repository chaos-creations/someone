// Values must match upstream's MENU_* defines in code/modules/client/preferences.dm, which are #undef'd at its end
#define MENU_MARINE "marine"
#define MENU_XENOMORPH "xeno"
#define MENU_CO "co"
#define MENU_SYNTHETIC "synth"
#define MENU_YAUTJA "yautja"
#define MENU_MENTOR "mentor"
#define MENU_SETTINGS "settings"
#define MENU_SPECIAL "special"
#define MENU_ORIGIN "origin"

/datum/preferences
	/// Paper doll loadout editor, shared by all players like the other pickers
	var/static/datum/loadout_doll/loadout_doll = new

/**
 * Shows the character setup window.
 *
 * Re-implements the upstream proc without calling it (the menus are one monolithic proc): Human only keeps appearance,
 * underwear and fluff, origin and religion moved to the Origin tab, the loadout to the window the Loadout tab opens (the paper doll), and
 * the night vision color to Settings. Backpack type, preferred armor, corporate relation, preferred squad and specialist
 * priority are not shown. Keep the rest in sync with ShowChoices() in code/modules/client/preferences.dm.
 */
/datum/preferences/ShowChoices(mob/user)
	CAN_BE_REDEFINED(TRUE)
	if(!user || !user.client)
		return
	update_preview_icon()

	var/dat = "<style>"
	dat += "#column1 {width: 30%; float: left;}"
	dat += "#column2 {width: 30%; float: left;}"
	dat += "#column3 {width: 40%; float: left;}"
	dat += ".square {width: 15px; height: 15px; display: inline-block;}"
	dat += "</style>"
	dat += "<body onselectstart='return false;'>"

	if(!path)
		dat += "Please create an account to save your preferences."
		return

	dat += "<center>"
	dat += "<a href=\"byond://?src=\ref[user];preference=open_load_dialog\"><b>Load Slot</b></a> - "
	dat += "<a href=\"byond://?src=\ref[user];preference=save\"><b>Save Slot</b></a> - "
	dat += "<a href=\"byond://?src=\ref[user];preference=reload\"><b>Reload Slot</b></a>"
	dat += "</center>"

	dat += "<hr>"

	dat += "<center>"
	dat += "<a[current_menu == MENU_MARINE ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_MARINE]\"><b>Human</b></a> - "
	dat += "<a[current_menu == MENU_ORIGIN ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_ORIGIN]\"><b>Origin</b></a> - "
	dat += "<a href=\"byond://?src=\ref[user];preference=loadout_doll\"><b>Loadout</b></a> - "
	dat += "<a[current_menu == MENU_XENOMORPH ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_XENOMORPH]\"><b>Xenomorph</b></a> - "
	if(owner.check_whitelist_status(WHITELIST_COMMANDER))
		dat += "<a[current_menu == MENU_CO ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_CO]\"><b>Commanding Officer</b></a> - "
	if(owner.check_whitelist_status(WHITELIST_SYNTHETIC))
		dat += "<a[current_menu == MENU_SYNTHETIC ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_SYNTHETIC]\"><b>Synthetic</b></a> - "
	if(owner.check_whitelist_status(WHITELIST_YAUTJA))
		dat += "<a[current_menu == MENU_YAUTJA ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=yautja\"><b>Yautja</b></a> - "
	if(owner.check_whitelist_status(WHITELIST_MENTOR))
		dat += "<a[current_menu == MENU_MENTOR ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_MENTOR]\"><b>Mentor</b></a> - "
	dat += "<a[current_menu == MENU_SETTINGS ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_SETTINGS]\"><b>Settings</b></a> - "
	dat += "<a[current_menu == MENU_SPECIAL ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[MENU_SPECIAL]\"><b>Special Roles</b></a>"
	dat += "</center>"

	dat += "<hr>"

	switch(current_menu)
		if(MENU_MARINE)
			dat += "<div id='column1'>"
			dat += "<h1><u><b>Name:</b></u> "
			dat += "<a href='byond://?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a>"
			dat += "<a href='byond://?_src_=prefs;preference=name;task=random'>&reg</A></h1>"
			dat += "<b>Always Pick Random Name:</b> <a href='byond://?_src_=prefs;preference=rand_name'><b>[be_random_name ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Always Pick Random Appearance:</b> <a href='byond://?_src_=prefs;preference=rand_body'><b>[be_random_body ? "Yes" : "No"]</b></a><br><br>"

			dat += "<h2><b><u>Physical Information:</u></b>"
			dat += "<a href='byond://?_src_=prefs;preference=all;task=random'>&reg;</A></h2>"
			dat += "<b>Age:</b> <a href='byond://?_src_=prefs;preference=age;task=input'><b>[age]</b></a><br>"
			dat += "<b>Gender:</b> <a href='byond://?_src_=prefs;preference=gender'><b>[gender == PLURAL ? "Non-Binary" : gender == MALE ? "Male" : "Female"]</b></a><br>"

			dat += "<b>Skin Color:</b> [skin_color]<br>"
			dat += "<b>Body Size:</b> [body_size]<br>"
			dat += "<b>Body Muscularity:</b> [body_type]<br>"
			dat += "<b>Edit Body:</b> <a href='byond://?_src_=prefs;preference=body;task=input'><b>Picker</b></a><br><br>"

			dat += "<b>Traits:</b> <a href='byond://?src=\ref[user];preference=traits'><b>Character Traits</b></a>"
			dat += "<br>"

			dat += "<h2><b><u>Occupation Choices:</u></b></h2>"
			dat += "<br>"
			dat += "\t<a href='byond://?_src_=prefs;preference=job;task=menu'><b>Set Role Preferences</b></a>"
			dat += "<br>"
			dat += "\t<a href='byond://?_src_=prefs;preference=job_slot;task=menu'><b>Assign Character Slots to Roles</b></a>"
			dat += "</div>"

			dat += "<div id='column2'>"
			dat += "<h2><b><u>Hair and Eyes:</u></b></h2>"
			dat += "<b>Hair:</b> [h_style]"
			dat += " | "
			dat += "<span class='square' style='background-color: #[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)];'></span>"
			dat += "<br>"

			dat += "<b>Facial Hair:</b> [f_style]"
			dat += " | "
			dat += "<span class='square' style='background-color: #[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)];'></span>"
			dat += "<br>"

			if(/datum/character_trait/hair_dye in traits)
				dat += "<b>Hair Gradient:</b> [grad_style]"
				dat += " | "
				dat += "<span class='square' style='background-color: #[num2hex(r_gradient, 2)][num2hex(g_gradient, 2)][num2hex(b_gradient)];'></span>"
				dat += "<br>"

			dat += "<b>Edit Hair:</b> <a href='byond://?_src_=prefs;preference=hair;task=input'><b>Picker</b></a><br><br>"

			dat += "<b>Eye:</b> "
			dat += "<a href='byond://?_src_=prefs;preference=eyes;task=input'>"
			dat += "<b>Color</b> <span class='square' style='background-color: #[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)];'></span>"
			dat += "</a>"
			dat += "<br><br>"

			dat += "<h2><b><u>Underwear:</u></b></h2>"
			dat += "<b>Underwear:</b> <a href='byond://?_src_=prefs;preference=underwear;task=input'><b>[underwear]</b></a><br>"
			dat += "<b>Undershirt:</b> <a href='byond://?_src_=prefs;preference=undershirt;task=input'><b>[undershirt]</b></a><br>"

			dat += "<h2><b><u>Preview:</u></b></h2>"
			dat += "<b>Show Job Gear:</b> <a href='byond://?_src_=prefs;preference=toggle_job_gear'><b>[show_job_gear ? "True" : "False"]</b></a><br>"
			dat += "<b>Background:</b> <a href='byond://?_src_=prefs;preference=cycle_bg'><b>Cycle Background</b></a><br>"
			dat += "</div>"

			dat += "<div id='column3'>"
			dat += "<h2><b><u>Fluff Information:</u></b></h2>"
			if(jobban_isbanned(user, "Records"))
				dat += "<b>You are banned from using character records.</b><br>"
			else
				dat += "<b>Records:</b> <a href=\"byond://?src=\ref[user];preference=records;record=1\"><b>Character Records</b></a><br>"

			dat += "<b>Flavor Text:</b> <a href='byond://?src=\ref[user];preference=flavor_text;task=open'><b>[TextPreview(flavor_texts["general"], 15)]</b></a><br>"
			dat += "</div>"

		if(MENU_ORIGIN)
			dat += "<div id='column1'>"
			dat += "<h2><b><u>Background Information:</u></b></h2>"
			dat += "<b>Origin:</b> <a href='byond://?_src_=prefs;preference=origin;task=input'><b>[origin]</b></a><br/>"
			dat += "<b>Religion:</b> <a href='byond://?_src_=prefs;preference=religion;task=input'><b>[religion]</b></a><br/>"
			dat += "</div>"

		if(MENU_XENOMORPH)
			dat += "<div id='column1'>"
			dat += "<h2><b><u>Xenomorph Information:</u></b></h2>"
			var/display_prefix = xeno_prefix ? xeno_prefix : "------"
			var/display_postfix = xeno_postfix ? xeno_postfix : "------"
			dat += "<b>Xeno prefix:</b> <a href='byond://?_src_=prefs;preference=xeno_prefix;task=input'><b>[display_prefix]</b></a><br>"
			dat += "<b>Xeno postfix:</b> <a href='byond://?_src_=prefs;preference=xeno_postfix;task=input'><b>[display_postfix]</b></a><br>"

			dat += "<b>Show Queen Name:</b> <a href='byond://?_src_=prefs;preference=show_queen_name'><b>[show_queen_name? "Yes" : "No"]</b></a><br>"
			dat += "<b>Default Xeno Night Vision Level:</b> <a href='byond://?_src_=prefs;preference=xeno_vision_level_pref;task=input'><b>[xeno_vision_level_pref]</b></a><br>"

			var/tempnumber = rand(1, 999)
			var/postfix_text = xeno_postfix ? ("-"+xeno_postfix) : ""
			var/prefix_text = xeno_prefix ? xeno_prefix : "XX"
			var/xeno_text = "[prefix_text]-[tempnumber][postfix_text]"

			dat += "<b>Xeno sample name:</b> [xeno_text]<br>"
			dat += "<br>"
			dat += "</div>"

		if(MENU_CO)
			if(owner.check_whitelist_status(WHITELIST_COMMANDER))
				dat += "<div id='column1'>"
				dat += "<h2><b><u>Commander Settings:</u></b></h2>"
				dat += "<b>Commander Whitelist Status:</b> <a href='byond://?_src_=prefs;preference=commander_status;task=input'><b>[commander_status]</b></a><br>"
				dat += "<b>Commander Sidearm:</b> <a href='byond://?_src_=prefs;preference=co_sidearm;task=input'><b>[commander_sidearm]</b></a><br>"
				dat += "<b>Commander Affiliation:</b> <a href='byond://?_src_=prefs;preference=co_affiliation;task=input'><b>[affiliation]</b></a><br>"
				dat += "<b>Commander Career Path:</b> <a href='byond://?_src_=prefs;preference=co_career_path;task=input'><b>[co_career_path]</b></a><br>"
				dat += "</div>"
			else
				dat += "<b>You do not have the whitelist for this role.</b>"
		if(MENU_SYNTHETIC)
			if(owner.check_whitelist_status(WHITELIST_SYNTHETIC))
				dat += "<div id='column1'>"
				dat += "<h2><b><u>Synthetic Settings:</u></b></h2>"
				dat += "<b>Synthetic Name:</b> <a href='byond://?_src_=prefs;preference=synth_name;task=input'><b>[synthetic_name]</b></a><br>"
				dat += "<b>Synthetic Type:</b> <a href='byond://?_src_=prefs;preference=synth_type;task=input'><b>[synthetic_type]</b></a><br>"
				dat += "<b>Synthetic Whitelist Status:</b> <a href='byond://?_src_=prefs;preference=synth_status;task=input'><b>[synth_status]</b></a><br>"
				dat += "<b>Synthetic Specialisation:</b> <a href='byond://?_src_=prefs;preference=synth_specialisation;task=input'><b>[synth_specialisation]</b></a><br>"
				dat += "</div>"
			else
				dat += "<b>You do not have the whitelist for this role.</b>"

		if(MENU_MENTOR)
			if(owner.check_whitelist_status(WHITELIST_MENTOR))
				dat += "<b>New Player Ghost HUD:</b> <a href='byond://?_src_=prefs;preference=newplayer_ghost_hud'><b>[observer_huds[HUD_MENTOR_SIGHT] ? "Enabled" : "Disabled"]</b></a><br>"
			else
				dat += "<b>You do not have the whitelist for this role.</b>"
		if(MENU_SETTINGS)
			dat += "<div id='column1'>"
			dat += "<h2><b><u>Input Settings:</u></b></h2>"
			dat += "<b>Mode:</b> <a href='byond://?_src_=prefs;preference=hotkeys'><b>[(hotkeys) ? "Hotkeys Mode" : "Send to Chat"]</b></a><br>"
			dat += "<b>Keybinds:</b> <a href='byond://?_src_=prefs;preference=viewmacros'><b>View Keybinds</b></a><br>"
			dat += "<b>Right-click Contextual Menu:</b> <a href='byond://?_src_=prefs;preference=toggle_right_click_menu'><b>[(toggle_right_click_menu) ? "On" : "Off"]</b></a><br>"
			dat += "<br><b>Say Input Style:</b> <a href='byond://?_src_=prefs;preference=inputstyle'><b>[tgui_say ? "Modern (default)" : "Legacy"]</b></a><br>"
			dat += "<b>Say Input Color:</b> <a href='byond://?_src_=prefs;preference=inputcolor'><b>[tgui_say_light_mode ? "Lightmode" : "Darkmode (default)"]</b></a><br>"

			dat += "<h2><b><u>UI Customization:</u></b></h2>"
			dat += "<b>Style:</b> <a href='byond://?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
			dat += "<b>Color:</b> <a href='byond://?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b> <table style='display:inline;' bgcolor='[UI_style_color]'><tr><td>__</td></tr></table></a><br>"
			dat += "<b>Alpha:</b> <a href='byond://?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br><br>"
			dat += "<b>Stylesheet:</b> <a href='byond://?_src_=prefs;preference=stylesheet'><b>[stylesheet]</b></a><br>"
			dat += "<b>Hide Statusbar:</b> <a href='byond://?_src_=prefs;preference=hide_statusbar'><b>[hide_statusbar ? "TRUE" : "FALSE"]</b></a><br>"
			dat += "<b>Prefer input drop down menus to radial menus, where possible:</b> <a href='byond://?_src_=prefs;preference=no_radials_preference'><b>[no_radials_preference ? "TRUE" : "FALSE"]</b></a><br>"
			if(!no_radials_preference)
				dat += "<b>Hide Radial Menu Labels:</b> <a href='byond://?_src_=prefs;preference=no_radial_labels_preference'><b>[no_radial_labels_preference ? "TRUE" : "FALSE"]</b></a><br>"
			dat += "<b>Custom Cursors:</b> <a href='byond://?_src_=prefs;preference=customcursors'><b>[custom_cursors ? "Enabled" : "Disabled"]</b></a><br>"

			dat += "<h2><b><u>Chat Settings:</u></b></h2>"
			if(CONFIG_GET(flag/ooc_country_flags))
				dat += "<b>OOC Country Flag:</b> <a href='byond://?_src_=prefs;preference=ooc_flag'><b>[(toggle_prefs & TOGGLE_OOC_FLAG) ? "Enabled" : "Disabled"]</b></a><br>"
			if(CLIENT_HAS_RIGHTS(user.client, R_DEBUG))
				dat += "<b>View Master Controller Tab:</b> <a href='byond://?_src_=prefs;preference=ViewMC'><b>[View_MC ? "TRUE" : "FALSE"]</b></a><br>"
			if(unlock_content)
				dat += "<b>BYOND Membership Publicity:</b> <a href='byond://?_src_=prefs;preference=publicity'><b>[(toggle_prefs & TOGGLE_MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>Ghost Ears:</b> <a href='byond://?_src_=prefs;preference=ghost_ears'><b>[(toggles_chat & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost Sight:</b> <a href='byond://?_src_=prefs;preference=ghost_sight'><b>[(toggles_chat & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost Radio:</b> <a href='byond://?_src_=prefs;preference=ghost_radio'><b>[(toggles_chat & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
			dat += "<b>Ghost Spy Radio:</b> <a href='byond://?_src_=prefs;preference=ghost_spyradio'><b>[(toggles_chat & CHAT_LISTENINGBUG) ? "Hear" : "Silence"] listening devices</b></a><br>"
			dat += "<b>Ghost Announcement Clarity:</b> <a href='byond://?_src_=prefs;preference=ghost_announceclarity'><b>[(toggles_chat & CHAT_GHOSTANNOUNCECLARITY) ? "Full Clarity" : "Potentially Garbled"] announcements</b></a><br>"
			dat += "<b>Ghost Hivemind:</b> <a href='byond://?_src_=prefs;preference=ghost_hivemind'><b>[(toggles_chat & CHAT_GHOSTHIVEMIND) ? "Show Hivemind" : "Hide Hivemind"]</b></a><br>"
			dat += "<b>Abovehead Chat:</b> <a href='byond://?_src_=prefs;preference=lang_chat_disabled'><b>[lang_chat_disabled ? "Hide" : "Show"]</b></a><br>"
			dat += "<b>Abovehead Emotes:</b> <a href='byond://?_src_=prefs;preference=langchat_emotes'><b>[(toggles_langchat & LANGCHAT_SEE_EMOTES) ? "Show" : "Hide"]</b></a><br>"
			if(CLIENT_IS_STAFF(user.client))
				dat += "<b>FF Log Color:</b> <a href='byond://?_src_=prefs;preference=fflogcolor'><b>[ff_log_color]</b> <table style='display:inline;' bgcolor='[ff_log_color]'><tr><td>__</td></tr></table></a><br>"
				dat += "<b>FF Log Color (Dead):</b> <a href='byond://?_src_=prefs;preference=ffdlogcolor'><b>[ffd_log_color]</b> <table style='display:inline;' bgcolor='[ffd_log_color]'><tr><td>__</td></tr></table></a><br>"

			dat += "</div>"

			dat += "<div id='column2'>"
			dat += "<h2><b><u>Game Settings:</u></b></h2>"
			dat += "<b>Ambient Occlusion:</b> <a href='byond://?_src_=prefs;preference=ambientocclusion'><b>[toggle_prefs & TOGGLE_AMBIENT_OCCLUSION ? "Enabled" : "Disabled"]</b></a><br>"
			dat += "<b>Fit Viewport:</b> <a href='byond://?_src_=prefs;preference=auto_fit_viewport'>[auto_fit_viewport ? "Auto" : "Manual"]</a><br>"
			dat += "<b>Adaptive Zoom:</b> <a href='byond://?_src_=prefs;preference=adaptive_zoom'>[adaptive_zoom ? "[adaptive_zoom * 2]x" : "Disabled"]</a><br>"
			dat += "<b>Tooltips:</b> <a href='byond://?_src_=prefs;preference=tooltips'><b>[tooltips ? "Enabled" : "Disabled"]</b></a><br>"
			dat += "<b>tgui Window Mode:</b> <a href='byond://?_src_=prefs;preference=tgui_fancy'><b>[(tgui_fancy) ? "Fancy (default)" : "Compatible (slower)"]</b></a><br>"
			dat += "<b>tgui Window Placement:</b> <a href='byond://?_src_=prefs;preference=tgui_lock'><b>[(tgui_lock) ? "Primary monitor" : "Free (default)"]</b></a><br>"
			dat += "<b>Window Scaling:</b> <a href='byond://?_src_=prefs;preference=window_scale'><b>[window_scale ? "Larger windows (default)" : "Smaller zoom"]</b></a><br>"
			dat += "<b>Play Admin Sounds:</b> <a href='byond://?_src_=prefs;preference=hear_admin_sounds'><b>[(toggles_sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play Announcement Sounds As Ghost:</b> <a href='byond://?_src_=prefs;preference=hear_observer_announcements'><b>[(toggles_sound & SOUND_OBSERVER_ANNOUNCEMENTS) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play Fax Sounds As Ghost:</b> <a href='byond://?_src_=prefs;preference=hear_faxes'><b>[(toggles_sound & SOUND_FAX_MACHINE) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Toggle Meme or Atmospheric Sounds:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/toggle_admin_sound_types'>Toggle</a><br>"
			dat += "<b>Set Eye Blur Type:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_eye_blur_type'>Set</a><br>"
			dat += "<b>Set Flash Type:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_flash_type'>Set</a><br>"
			dat += "<b>Set Crit Type:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_crit_type'>Set</a><br>"
			dat += "<b>Allow Flashing Lights:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_flashing_lights_pref'>Set</a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='byond://?_src_=prefs;preference=lobby_music'><b>[(toggles_sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play Round End Music:</b> <a href='byond://?_src_=prefs;preference=end_round_music'><b>[(toggles_sound & SOUND_ROUND_END) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play VOX Announcements:</b> <a href='byond://?_src_=prefs;preference=sound_vox'><b>[(hear_vox) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Night Vision Color:</b> <a href='byond://?_src_=prefs;preference=prefnvg;task=input'><b>[night_vision_preference]</b></a><br>"
			dat += "<b>Default Ghost Night Vision Level:</b> <a href='byond://?_src_=prefs;preference=ghost_vision_pref;task=input'><b>[ghost_vision_pref]</b></a><br>"
			dat += "<b>Button To Activate Xenomorph Abilities:</b> <a href='byond://?_src_=prefs;preference=mouse_button_activation;task=input'><b>[xeno_ability_mouse_pref_to_string(xeno_ability_click_mode)]</b></a><br>"
			dat += "<b>Xeno Cooldown Messages:</b> <a href='byond://?_src_=prefs;preference=show_cooldown_messages'><b>[(show_cooldown_messages) ? "Show" : "Hide"]</b></a><br>"
			dat += "<b>Toggle CMTV Opt-Out:</b> <a href='byond://?_src_=prefs;preference=CMTV_toggle_optout'><b>[CMTV_toggle_optout? "Enabled" : "Disabled"]</b></a><br>"
			dat += "<a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/receive_random_tip'>Read Random Tip of the Round</a><br>"
			if(CONFIG_GET(flag/allow_Metadata))
				dat += "<b>OOC Notes:</b> <a href='byond://?_src_=prefs;preference=metadata;task=input'> Edit </a>"
			dat += "</div>"

			dat += "<div id='column3'>"
			dat += "<h2><b><u>Gameplay Toggles:</u></b></h2>"
			dat += "<b>Enable Playtime Perks:</b> <a href='byond://?_src_=prefs;preference=playtime_perks'><b>[playtime_perks? "Yes" : "No"]</b></a><br>"
			if(user.client.can_skip_role_lock())
				dat += "<b>Skip Playtime Ranks:</b> <a href='byond://?_src_=prefs;preference=skip_playtime_ranks'><b>[skip_playtime_ranks? "Yes" : "No"]</b></a><br>"
			dat += "<b>Toggle Being Able to Hurt Yourself: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_IGNORE_SELF]'><b>[toggle_prefs & TOGGLE_IGNORE_SELF ? "Off" : "On"]</b></a><br>"
			dat += "<b>Toggle Help Intent Safety: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_HELP_INTENT_SAFETY]'><b>[toggle_prefs & TOGGLE_HELP_INTENT_SAFETY ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Automatic Shove: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTO_SHOVE_OFF]'><b>[toggle_prefs & TOGGLE_AUTO_SHOVE_OFF ? "Off" : "On"]</b></a><br>"
			dat += "<b>Toggle Ability Deactivation: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_ABILITY_DEACTIVATION_OFF]'><b>[toggle_prefs & TOGGLE_ABILITY_DEACTIVATION_OFF ? "Off" : "On"]</b></a><br>"
			dat += "<b>Toggle Directional Assist: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_DIRECTIONAL_ATTACK]'><b>[toggle_prefs & TOGGLE_DIRECTIONAL_ATTACK ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Magazine Auto-Ejection: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTO_EJECT_MAGAZINE_OFF];flag_undo=[TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND]'><b>[!(toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_OFF) ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Magazine Auto-Ejection to Offhand: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND];flag_undo=[TOGGLE_AUTO_EJECT_MAGAZINE_OFF]'><b>[toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Magazine Manual Ejection to Offhand: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_EJECT_MAGAZINE_TO_HAND]'><b>[toggle_prefs & TOGGLE_EJECT_MAGAZINE_TO_HAND ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Automatic Punctuation: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTOMATIC_PUNCTUATION]'><b>[toggle_prefs & TOGGLE_AUTOMATIC_PUNCTUATION ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Bullet Cocking to hand: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_COCKING_TO_HAND]'><b>[toggle_prefs & TOGGLE_COCKING_TO_HAND ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Leadership Spoken Orders: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_LEADERSHIP_SPOKEN_ORDERS]'><b>[toggle_prefs & TOGGLE_LEADERSHIP_SPOKEN_ORDERS ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Gun Wielding Assist: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_WIELD_ASSIST]'><b>[toggle_prefs & TOGGLE_WIELD_ASSIST ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Combat Click-Drag Override: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_COMBAT_CLICKDRAG_OVERRIDE]'><b>[toggle_prefs & TOGGLE_COMBAT_CLICKDRAG_OVERRIDE ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Middle-Click Swap Hands: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_MIDDLE_MOUSE_SWAP_HANDS]'><b>[toggle_prefs & TOGGLE_MIDDLE_MOUSE_SWAP_HANDS ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Vendors Vending to Hands: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_VEND_ITEM_TO_HAND]'><b>[toggle_prefs & TOGGLE_VEND_ITEM_TO_HAND ? "On" : "Off"]</b></a><br>"
			dat += "<b>Toggle Semi-Auto Ammo Display Limiter: \
					</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AMMO_DISPLAY_TYPE]'><b>[toggle_prefs & TOGGLE_AMMO_DISPLAY_TYPE ? "On" : "Off"]</b></a><br>"
			dat += "<a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/switch_item_animations'>Toggle Item Animations Detail Level</a><br>"
			dat += "<a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/toggle_dualwield'>Toggle Dual Wield Functionality</a><br>"
			dat += "<a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/toggle_auto_holotag'>Toggle Auto Holotags</a><br>"
			dat += "<a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/toggle_auto_shove'>Toggle Auto Shove</a><br>"
		if(MENU_SPECIAL) //wart
			dat += "<div id='column1'>"
			dat += "<h2><b><u>ERT Settings:</u></b></h2>"
			dat += "<b>Spawn as Leader:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_LEADER]'><b>[toggles_ert & PLAY_LEADER ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Medic:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_MEDIC]'><b>[toggles_ert & PLAY_MEDIC ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Engineer:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_ENGINEER]'><b>[toggles_ert & PLAY_ENGINEER ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Specialist:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_HEAVY]'><b>[toggles_ert & PLAY_HEAVY ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Smartgunner:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_SMARTGUNNER]'><b>[toggles_ert & PLAY_SMARTGUNNER ? "Yes" : "No"]</b></a><br>"

			if(owner.check_whitelist_status(WHITELIST_SYNTHETIC))
				dat += "<b>Spawn as Synth:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_SYNTH]'><b>[toggles_ert & PLAY_SYNTH ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Miscellaneous:</b> <a href='byond://?_src_=prefs;preference=toggles_ert;flag=[PLAY_MISC]'><b>[toggles_ert & PLAY_MISC ? "Yes" : "No"]</b></a><br>"

			dat += "<br><h2><b><u>Special Roles:</u></b></h2>"

			for(var/role_name in GLOB.be_special_flags)
				var/flag = GLOB.be_special_flags[role_name]
				var/ban_check_name = JOB_XENOMORPH // Ever a be_special_flags uses a different ban check, check and switch here

				if(ban_check_name && jobban_isbanned(user, ban_check_name))
					dat += "<b>Be [role_name]:</b> <font color=red><b>\[BANNED]</b></font><br>"
				else if(!can_play_special_job(user.client, ban_check_name))
					dat += "<b>Be [role_name]:</b> <font color=red><b>\[TIMELOCKED]</b></font><br>"
				else
					dat += "<b>Be [role_name]:</b> <a href='byond://?_src_=prefs;preference=be_special;num=[flag]'><b>[be_special & flag ? "Yes" : "No"]</b></a><br>"



			dat += "</div>"
			dat += "<div id='column2'>"
			dat += "<h2><b><u>Hunting Ground ERT Settings:</u></b></h2>"
			dat += "<b>Spawn as Mercenary:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_MERC]'><b>[toggles_ert_pred & PLAY_MERC ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Royal Marine:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_TWE]'><b>[toggles_ert_pred & PLAY_TWE ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as UPP:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_UPP]'><b>[toggles_ert_pred & PLAY_UPP ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as CLF:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_CLF]'><b>[toggles_ert_pred & PLAY_CLF ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as PMC:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_PMC]'><b>[toggles_ert_pred & PLAY_PMC ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Miscellaneous:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_HUNT_MISC]'><b>[toggles_ert_pred & PLAY_HUNT_MISC ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Xeno T2:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_XENO_T2]'><b>[toggles_ert_pred & PLAY_XENO_T2 ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Xeno T3:</b> <a href='byond://?_src_=prefs;preference=toggles_ert_pred;flag=[PLAY_XENO_T3]'><b>[toggles_ert_pred & PLAY_XENO_T3 ? "Yes" : "No"]</b></a><br>"
			dat += "</div>"
			dat += "</body>"
			if(owner.check_whitelist_status(WHITELIST_FAX_RESPONDER))
				dat += "<div id='column3'>"
				dat += "<h2><b><u>Fax Responder Names:</u></b></h2>"
				dat += "<b>USCM High Command:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=uscm'><b>[fax_name_uscm]</b></a><br>"
				dat += "<b>USCM Provost:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=pvst'><b>[fax_name_pvst]</b></a><br>"
				dat += "<b>Weyland-Yutani:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=wy'><b>[fax_name_wy]</b></a><br>"
				dat += "<b>UPP Command:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=upp'><b>[fax_name_upp]</b></a><br>"
				dat += "<b>TWE Command:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=twe'><b>[fax_name_twe]</b></a><br>"
				dat += "<b>Colonial Marshal Bureau:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=cmb'><b>[fax_name_cmb]</b></a><br>"
				dat += "<b>Free Press:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=press'><b>[fax_name_press]</b></a><br>"
				dat += "<b>CLF Command:</b> <a href='byond://?_src_=prefs;preference=fax_name;task=input;fax_faction=clf'><b>[fax_name_clf]</b></a><br>"
				dat += "</div>"


			dat += "<div id='column2'>"
			dat += "<h2><b><u>Survivor Settings:</u></b></h2>"
			dat += "<b>Spawn as Hostile:</b> <a href='byond://?_src_=prefs;preference=toggles_survivor;flag=[PLAY_SURVIVOR_HOSTILE]'><b>[toggles_survivor & PLAY_SURVIVOR_HOSTILE ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Non-Hostile:</b> <a href='byond://?_src_=prefs;preference=toggles_survivor;flag=[PLAY_SURVIVOR_NON_HOSTILE]'><b>[toggles_survivor & PLAY_SURVIVOR_NON_HOSTILE ? "Yes" : "No"]</b></a><br>"

			dat += "<br><h2><b><u>Nightmare Insert Roles:</u></b></h2>"

			dat += "<b>Spawn as Standard:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_STANDARD]'><b>[toggles_insert & PLAY_INSERT_STANDARD ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Corporate:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_CORPORATE]'><b>[toggles_insert & PLAY_INSERT_CORPORATE ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Leader:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_LEADER]'><b>[toggles_insert & PLAY_INSERT_LEADER ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Medic:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_MEDIC]'><b>[toggles_insert & PLAY_INSERT_MEDIC ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Engineer:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_ENGINEER]'><b>[toggles_insert & PLAY_INSERT_ENGINEER ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Smartgunner:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_SMARTGUNNER]'><b>[toggles_insert & PLAY_INSERT_SMARTGUNNER ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Spawn as Specialist:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_SPECIALIST]'><b>[toggles_insert & PLAY_INSERT_SPECIALIST ? "Yes" : "No"]</b></a><br>"

			if(owner.check_whitelist_status(WHITELIST_SYNTHETIC))
				dat += "<b>Spawn as Insert Synth:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_SYNTH]'><b>[toggles_insert & PLAY_INSERT_SYNTH ? "Yes" : "No"]</b></a><br>"
			if(owner.check_whitelist_status(WHITELIST_COMMANDER))
				dat += "<b>Spawn as Insert CO:</b> <a href='byond://?_src_=prefs;preference=toggles_insert;flag=[PLAY_INSERT_CO]'><b>[toggles_insert & PLAY_INSERT_CO ? "Yes" : "No"]</b></a><br>"
			dat += "</div>"

	dat += "</div></body>"

	winshow(user, "preferencewindow", TRUE)
	show_browser(user, dat, "Preferences", "preferencebrowser", width = 1000, height = 800, existing_container = "preferencewindow")
	onclose(user, "preferencewindow", src)

/datum/preferences/process_link(mob/user, list/href_list)
	CAN_BE_REDEFINED(TRUE)
	if(href_list["preference"] == "loadout_doll")
		loadout_doll.tgui_interact(user)
		return TRUE
	return ..()

#undef MENU_MARINE
#undef MENU_XENOMORPH
#undef MENU_CO
#undef MENU_SYNTHETIC
#undef MENU_YAUTJA
#undef MENU_MENTOR
#undef MENU_SETTINGS
#undef MENU_SPECIAL
#undef MENU_ORIGIN
