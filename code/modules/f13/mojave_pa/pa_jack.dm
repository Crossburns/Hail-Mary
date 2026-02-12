/obj/structure/ms13/pa_jack
	name = "power armor hoist"
	desc = "A heavy duty hoist used to stabilize and lift power armor for modification and repair."
	icon = 'mojave/icons/objects/workbench.dmi'
	icon_state = "station"
	pixel_y = -16
	pixel_x = -16
	anchored = TRUE
	var/obj/item/clothing/suit/space/hardsuit/ms13/power_armor/obj_connected = null

/obj/structure/ms13/pa_jack/examine(mob/user)
	. = ..()
	. += "Alt-click this to connect or disconnect power armor."

/obj/structure/ms13/pa_jack/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	if(!obj_connected)
		playsound(src, 'mojave/sound/ms13effects/chain_jostle.ogg', 25, TRUE)
		if(do_after(user, 4 SECONDS, target = src))
			obj_connected = locate(/obj/item/clothing/suit/space/hardsuit/ms13/power_armor) in loc
			if(istype(obj_connected))
				var/icon/chains = new(icon, "chains")
				add_overlay(chains)
				obj_connected.link_to = src
				to_chat(user, span_notice("You connect the power armor to [src]."))
				return TRUE
			obj_connected = null
	else
		playsound(src, 'mojave/sound/ms13effects/chain_jostle.ogg', 25, TRUE)
		if(do_after(user, 4 SECONDS, target = src))
			cut_overlays()
			obj_connected.link_to = null
			obj_connected = null
			to_chat(user, span_notice("You disconnect the power armor from [src]."))
			return TRUE
	return FALSE
