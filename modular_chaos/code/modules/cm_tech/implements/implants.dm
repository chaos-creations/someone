// Some presets (UPP specialist and machinegunner) create an implant in nullspace and only call on_implanted(), so the implant is not in its
// host and outlives it, hard deleting the host through the host var. The implant now goes with its host instead.
/obj/item/device/internal_implant/on_implanted(mob/living/M)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	RegisterSignal(M, COMSIG_PARENT_QDELETING, PROC_REF(on_host_deleted))

/// Deletes the implant along with its host
/obj/item/device/internal_implant/proc/on_host_deleted(datum/source)
	SIGNAL_HANDLER
	host = null
	qdel(src)
