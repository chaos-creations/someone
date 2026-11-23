/// Intercom of the Dropship Cyclone, on its own channel
/obj/item/device/radio/intercom/cyclone
	name = "dropship cyclone intercom"
	frequency = CYCLONE_FREQ

/obj/item/device/radio/intercom/cyclone/Initialize()
	// GLOB.radiochannels is filled by upstream; the Cyclone's channel joins it so radios show its name
	GLOB.radiochannels[RADIO_CHANNEL_CYCLONE] = CYCLONE_FREQ
	return ..()
