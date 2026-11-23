// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/// An IV bag of saline for blood loss and minor poisoning, on the blood pack sprite filled in the reagent's colour
/obj/item/reagent_container/blood/saline
	name = "saline solution pack"
	volume = 100

/obj/item/reagent_container/blood/saline/Initialize()
	. = ..()
	desc = "A basic first aid solution of water, sodium chloride and glucose made to treat " + SPAN_HELPFUL("blood loss, the symptoms of minor poisoning and hyperthermia.") + " While it does not have any lasting negative effects when overdosed on, " + SPAN_WARNING("administering more than half a bag at a time causes temporary blurred vision and disorientation.")
	reagents.add_reagent("saline", volume)
	update_icon()
