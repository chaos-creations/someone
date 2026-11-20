/**
 * Adds the fork's hub settings to upstream's hub status.
 *
 * Shows or hides the world on the hub by the HUB flag, puts the HUB_BANNER_URL image before upstream's
 * status, and appends a whitelist notice and HUB_BODY after it.
 */
/world/update_status()
	CAN_BE_REDEFINED(TRUE)
	..()
	visibility = CONFIG_GET(flag/hub) ? 1 : 0

	var/banner_url = CONFIG_GET(string/hub_banner_url)
	var/status_text = world.status
	if(banner_url)
		status_text = "<img src=\"[banner_url]\"><br>[status_text]"
	if(CONFIG_GET(flag/entry_whitelist))
		status_text += "<br><b>Whitelist only</b>"
	var/hub_body = CONFIG_GET(string/hub_body)
	if(hub_body)
		status_text += hub_body

	world.status = status_text
