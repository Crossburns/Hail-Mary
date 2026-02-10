// =============================================================================
// MAINFRAME OBJECTS
// Large pre-war computer mainframes
// =============================================================================

/obj/structure/mainframe
	name = "mainframe"
	desc = "A large pre-war computer mainframe. Its circuits are dark and silent."
	icon = 'code/modules/f13/mainframe.dmi'
	icon_state = "mainframe"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE

	/// Is the mainframe currently powered/active?
	var/active = FALSE

/obj/structure/mainframe/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("The mainframe hums with activity, status lights blinking.")
	else
		. += span_notice("The mainframe is inactive. It might need power to function.")

/obj/structure/mainframe/proc/turn_on()
	if(active)
		return
	active = TRUE
	icon_state = "mainframe_on"
	playsound(src, 'sound/machines/terminal_on.ogg', 50, TRUE)

/obj/structure/mainframe/proc/turn_off()
	if(!active)
		return
	active = FALSE
	icon_state = "mainframe"
	playsound(src, 'sound/machines/terminal_off.ogg', 50, TRUE)

/obj/structure/mainframe/proc/toggle()
	if(active)
		turn_off()
	else
		turn_on()

/// Pre-activated mainframe
/obj/structure/mainframe/on
	icon_state = "mainframe_on"
	active = TRUE

/obj/structure/mainframe/on/Initialize(mapload)
	. = ..()
	desc = "A large pre-war computer mainframe. Status lights blink rhythmically as it processes data."
