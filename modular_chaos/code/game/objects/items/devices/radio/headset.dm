//############################## FORECON ###############################
// Headsets of the FORECON platoon, which talks on the FORECON squad frequency.

/obj/item/device/radio/headset/almayer/marine/forecon
	name = "marine FORECON radio headset"
	desc = "This is used by FORECON members. When worn, grants access to Squad Leader tracker. Click tracker with empty hand to open Squad Info window."
	icon_state = "soc_headset"
	frequency = FORECON_FREQ

/obj/item/device/radio/headset/almayer/marine/forecon/lead
	name = "marine FORECON leader radio headset"
	desc = "This is used by the FORECON squad leader. Channels are as follows: :u - requisitions, :v - marine command, :j - JTAC. When worn, grants access to Squad Leader tracker. Click tracker with empty hand to open Squad Info window."
	initial_keys = list(/obj/item/device/encryptionkey/almayer, /obj/item/device/encryptionkey/squadlead)
	locate_setting = TRACKER_LZ
	volume = RADIO_VOLUME_CRITICAL

/obj/item/device/radio/headset/almayer/marine/forecon/tl
	name = "marine FORECON assistant leader radio headset"
	desc = "This is used by the FORECON assistant squad leader. Channels are as follows: :u - requisitions, :j - JTAC. When worn, grants access to Squad Leader tracker. Click tracker with empty hand to open Squad Info window."
	initial_keys = list(/obj/item/device/encryptionkey/almayer, /obj/item/device/encryptionkey/jtac)
	volume = RADIO_VOLUME_RAISED

/obj/item/device/radio/headset/almayer/marine/forecon/rto
	name = "marine FORECON radio operator headset"
	desc = "This is used by the FORECON radio telephone operator. Channels are as follows: :u - requisitions, :v - marine command, :j - JTAC. When worn, grants access to Squad Leader tracker. Click tracker with empty hand to open Squad Info window."
	initial_keys = list(/obj/item/device/encryptionkey/almayer, /obj/item/device/encryptionkey/squadlead)
	volume = RADIO_VOLUME_RAISED

/obj/item/device/radio/headset/almayer/marine/forecon/medic
	name = "marine FORECON corpsman radio headset"
	desc = "This is used by the FORECON corpsman. To access the medical channel, use :m. When worn, grants access to Squad Leader tracker. Click tracker with empty hand to open Squad Info window."
	initial_keys = list(/obj/item/device/encryptionkey/almayer, /obj/item/device/encryptionkey/med)
