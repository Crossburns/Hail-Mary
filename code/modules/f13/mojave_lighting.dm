// Mojave static light props (no custom lighting system changes).

/obj/structure/f13/mojave_light_prop
	name = "mojave light"
	desc = "A Mojave light fixture."
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	layer = OBJ_LAYER
	plane = GAME_PLANE
	light_range = 4
	light_power = 1
	light_color = LIGHT_COLOR_TUNGSTEN
	light_on = TRUE

/obj/structure/f13/mojave_light_prop/Initialize(mapload)
	. = ..()
	if(mojave_try_convert_to_functional())
		return INITIALIZE_HINT_QDEL

/obj/structure/f13/mojave_light_prop/proc/mojave_try_convert_to_functional()
	if(!icon || !istext(icon_state) || !length(icon_state))
		return FALSE
	var/icon_path = lowertext("[icon]")
	var/lower_state = lowertext(icon_state)

	if(icon_path == "mojave/icons/structure/lamps.dmi")
		if(icon_state == "Lighting Clutter")
			return FALSE
		var/obj/structure/f13/mojave_lamp/LP = new(get_turf(src))
		LP.dir = src.dir
		LP.alpha = src.alpha
		LP.color = src.color
		LP.icon = icon
		LP.icon_state = icon_state
		LP.mojave_apply_lamp_profile_from_state(icon_state)
		LP.update_icon()
		LP.mojave_refresh_light()
		return TRUE

	if(icon_path == "mojave/icons/structure/lighting.dmi")
		if(findtext(lower_state, "light_tube") || findtext(lower_state, "light_bulb"))
			var/obj/machinery/light/f13/mojave/LF = new(get_turf(src))
			LF.dir = src.dir
			LF.alpha = src.alpha
			LF.color = src.color
			LF.icon = icon
			LF.icon_state = icon_state
			LF.mojave_apply_requested_state(icon_state)
			LF.update_icon()
			return TRUE

	if(icon_path == "mojave/icons/structure/medical.dmi")
		if(icon_state == "medlamp" || icon_state == "medlamp_on")
			var/obj/structure/f13/mojave_lamp/ML = new(get_turf(src))
			ML.dir = src.dir
			ML.alpha = src.alpha
			ML.color = src.color
			ML.icon = icon
			ML.icon_state = icon_state
			ML.mojave_apply_lamp_profile_from_state(icon_state)
			ML.update_icon()
			ML.mojave_refresh_light()
			return TRUE

	return FALSE

/obj/structure/f13/mojave_light_prop/low
	layer = BELOW_OBJ_LAYER
