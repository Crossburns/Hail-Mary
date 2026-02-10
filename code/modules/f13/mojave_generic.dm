// Generic Mojave sprite helpers (map-use; set icon/icon_state in editor)

/obj/structure/f13/mojave_prop
	name = "structure"
	desc = "A piece of Mojave-era infrastructure."
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	icon = 'mojave/icons/objects/clutter/clutter_world.dmi'
	icon_state = "junk_1"
	layer = OBJ_LAYER
	plane = GAME_PLANE

/obj/structure/f13/mojave_prop/Initialize(mapload)
	. = ..()
	if(mojave_try_convert_to_functional())
		return INITIALIZE_HINT_QDEL
	mojave_apply_default_label()
	if(desc == initial(desc))
		desc = "A piece of Mojave-era infrastructure."

/obj/structure/f13/mojave_prop/proc/mojave_apply_default_label()
	if(name == initial(name) || name == "mojave prop" || name == "mojave prop (dense)" || name == "mojave prop (low)")
		var/label = "[icon_state]"
		label = replacetext(label, "_", " ")
		label = replacetext(label, "-", " ")
		label = trim(label)
		if(length(label))
			name = capitalize(label)

/obj/structure/f13/mojave_prop/proc/mojave_try_convert_to_functional()
	if(!icon || !istext(icon_state) || !length(icon_state))
		return FALSE
	var/icon_path = lowertext("[icon]")
	var/list/state_pool = icon_states(icon)
	if(!state_pool)
		state_pool = list()
	if(icon_path == "mojave/icons/structure/doors.dmi")
		if(!findtext(icon_state, "_closed") && !findtext(icon_state, "_open"))
			return FALSE
		var/obj/structure/f13/mojave_toggle_door/D = new(get_turf(src))
		D.dir = src.dir
		D.alpha = src.alpha
		D.color = src.color
		D.icon = icon
		D.icon_state_closed = icon_state
		if(findtext(icon_state, "_closed"))
			D.icon_state_open = replacetext(icon_state, "_closed", "_open")
		else if(findtext(icon_state, "_open"))
			D.icon_state_open = icon_state
			D.icon_state_closed = replacetext(icon_state, "_open", "_closed")
			D.density = FALSE
		else
			D.icon_state_open = "[icon_state]_open"
		if(findtext(D.icon_state_closed, "wood"))
			D.name = "wood door"
			D.desc = "A sturdy wooden door."
		else if(findtext(D.icon_state_closed, "wirefence") || findtext(D.icon_state_closed, "barbfence"))
			D.name = "fence gate"
			D.desc = "A reinforced fence gate."
		else
			D.name = "metal door"
			D.desc = "A heavy pre-war metal door."
		D.icon_state = D.icon_state_closed
		if(!D.density)
			D.icon_state = D.icon_state_open
		D.update_icon()
		return TRUE
	if(icon_path == "mojave/icons/structure/talldoor.dmi")
		if(icon_state != "door0" && icon_state != "door1" && icon_state != "doorc0" && icon_state != "doorc1")
			return FALSE
		var/obj/structure/f13/mojave_toggle_door/T = new(get_turf(src))
		T.dir = src.dir
		T.alpha = src.alpha
		T.color = src.color
		T.icon = icon
		T.icon_state_closed = icon_state
		switch(icon_state)
			if("door0")
				T.icon_state_open = "door1"
			if("door1")
				T.icon_state_closed = "door0"
				T.icon_state_open = "door1"
				T.density = FALSE
			if("doorc0")
				T.icon_state_open = "doorc1"
			if("doorc1")
				T.icon_state_closed = "doorc0"
				T.icon_state_open = "doorc1"
				T.density = FALSE
			else
				T.icon_state_open = icon_state
		T.name = "security door"
		T.desc = "A reinforced security door."
		T.icon_state = T.icon_state_closed
		if(!T.density)
			T.icon_state = T.icon_state_open
		T.update_icon()
		return TRUE
	if(icon_path == "mojave/icons/structure/shutters.dmi")
		if(!findtext(icon_state, "closed-") && !findtext(icon_state, "open-") && !findtext(icon_state, "opening-") && !findtext(icon_state, "closing-"))
			return FALSE
		var/obj/structure/f13/mojave_toggle_shutter/S = new(get_turf(src))
		S.dir = src.dir
		S.alpha = src.alpha
		S.color = src.color
		S.icon = icon
		var/closed_state = icon_state
		if(findtext(closed_state, "opening-"))
			closed_state = replacetext(closed_state, "opening-", "closed-")
		else if(findtext(closed_state, "open-"))
			closed_state = replacetext(closed_state, "open-", "closed-")
		else if(findtext(closed_state, "closing-"))
			closed_state = replacetext(closed_state, "closing-", "closed-")
		S.icon_state_closed = closed_state
		S.icon_state_open = replacetext(closed_state, "closed-", "open-")
		if(findtext(icon_state, "open-"))
			S.density = FALSE
		S.name = "mechanical shutters"
		S.desc = "Mechanical pre-war shutters, somewhat still functional."
		S.mojave_parse_state()
		S.icon_state = S.icon_state_closed
		if(!S.density)
			S.icon_state = S.icon_state_open
		S.update_icon()
		return TRUE
	if(icon_path == "mojave/icons/obstacles/obstacles.dmi")
		if(icon_state == "door" || icon_state == "dooropen" || icon_state == "door_rust" || icon_state == "door_rustopen")
			var/obj/structure/f13/mojave_toggle_door/C = new(get_turf(src))
			C.dir = src.dir
			C.alpha = src.alpha
			C.color = src.color
			C.icon = icon
			if(icon_state == "dooropen")
				C.icon_state_closed = "door"
				C.icon_state_open = "dooropen"
				C.density = FALSE
			else if(icon_state == "door_rustopen")
				C.icon_state_closed = "door_rust"
				C.icon_state_open = "door_rustopen"
				C.density = FALSE
			else if(icon_state == "door_rust")
				C.icon_state_closed = "door_rust"
				C.icon_state_open = "door_rustopen"
			else
				C.icon_state_closed = "door"
				C.icon_state_open = "dooropen"
			C.name = "cell door"
			C.desc = "A reinforced cell door."
			C.icon_state = C.density ? C.icon_state_closed : C.icon_state_open
			C.update_icon()
			return TRUE
	if(icon_path == "mojave/icons/structure/crates.dmi")
		var/obj/structure/closet/crate/f13/mojave/CR = new(get_turf(src))
		CR.dir = src.dir
		CR.alpha = src.alpha
		CR.color = src.color
		CR.icon = icon
		if(icon_state in state_pool)
			CR.icon_state = icon_state
		CR.mojave_closed_icon_state = CR.icon_state
		CR.mojave_apply_profile()
		CR.mojave_detect_open_state()
		CR.icon_state = CR.mojave_closed_icon_state
		CR.update_icon()
		return TRUE
	if(icon_path == "mojave/icons/structure/storage.dmi")
		var/obj/structure/closet/f13/mojave_storage/ST = new(get_turf(src))
		ST.dir = src.dir
		ST.alpha = src.alpha
		ST.color = src.color
		ST.icon = icon
		if(icon_state in state_pool)
			ST.icon_state = icon_state
		ST.mojave_closed_state = ST.icon_state
		ST.mojave_recompute_profile()
		ST.icon_state = ST.mojave_closed_state
		ST.update_icon()
		return TRUE
	if(icon_path == "mojave/icons/structure/chairs.dmi")
		var/obj/structure/chair/f13/mojave/CH = new(get_turf(src))
		CH.dir = src.dir
		CH.alpha = src.alpha
		CH.color = src.color
		CH.icon = icon
		if(icon_state in state_pool)
			CH.icon_state = icon_state
		CH.mojave_apply_chair_profile()
		return TRUE
	if(icon_path == "mojave/icons/structure/beds.dmi")
		if(icon_state == "rollingbed_down" || icon_state == "rollingbed_up")
			var/obj/structure/bed/roller/f13/mojave/RB = new(get_turf(src))
			RB.dir = src.dir
			RB.alpha = src.alpha
			RB.color = src.color
			RB.icon = icon
			RB.icon_state = icon_state
			return TRUE
		var/obj/structure/bed/f13/mojave/BD = new(get_turf(src))
		BD.dir = src.dir
		BD.alpha = src.alpha
		BD.color = src.color
		BD.icon = icon
		if(icon_state in state_pool)
			BD.icon_state = icon_state
		BD.mojave_apply_bed_profile()
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
		if(icon_state == "bodybag" || icon_state == "bodybag_open")
			var/obj/structure/closet/body_bag/f13/mojave/BB = new(get_turf(src))
			BB.dir = src.dir
			BB.alpha = src.alpha
			BB.color = src.color
			BB.icon = icon
			BB.icon_state = icon_state
			if(icon_state == "bodybag_open")
				BB.opened = TRUE
				BB.density = FALSE
			return TRUE
		if(icon_state == "bodybag_folded")
			var/obj/item/bodybag/f13/mojave/FBB = new(get_turf(src))
			FBB.alpha = src.alpha
			FBB.color = src.color
			return TRUE
	if(icon_path == "mojave/icons/structure/terminals.dmi")
		var/obj/machinery/f13/mojave_terminal/TM = new(get_turf(src))
		TM.dir = src.dir
		TM.alpha = src.alpha
		TM.color = src.color
		TM.icon = icon
		TM.icon_state = icon_state
		TM.mojave_apply_terminal_profile_from_state(icon_state)
		TM.update_icon()
		return TRUE
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
		var/lower_state = lowertext(icon_state)
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
	if(icon_path == "mojave/icons/structure/standalone_tables.dmi")
		if(icon_state == "table_rolling")
			var/obj/structure/table/rolling/f13/mojave/RT = new(get_turf(src))
			RT.dir = src.dir
			RT.alpha = src.alpha
			RT.color = src.color
			RT.icon = icon
			RT.icon_state = icon_state
			return TRUE
		var/obj/structure/table/f13/mojave/TB = new(get_turf(src))
		TB.dir = src.dir
		TB.alpha = src.alpha
		TB.color = src.color
		TB.icon = icon
		if(icon_state in state_pool)
			TB.icon_state = icon_state
		TB.mojave_apply_table_profile()
		return TRUE
	if(findtext(icon_path, "mojave/icons/structure/smooth_structures/tables/"))
		var/obj/structure/table/f13/mojave/STB = new(get_turf(src))
		STB.dir = src.dir
		STB.alpha = src.alpha
		STB.color = src.color
		STB.icon = icon
		if(icon_state in state_pool)
			STB.icon_state = icon_state
		STB.mojave_apply_table_profile()
		return TRUE
	if(icon_path == "mojave/icons/structure/smooth_structures/sandbags.dmi")
		var/obj/structure/f13/mojave_sandbag/SB = new(get_turf(src))
		SB.dir = src.dir
		SB.alpha = src.alpha
		SB.color = src.color
		SB.icon = icon
		if(icon_state in state_pool)
			SB.icon_state = icon_state
		mojave_update_bitmask(SB)
		return TRUE
	if(icon_path == "mojave/icons/obstacles/obstacles.dmi")
		if(findtext(lowertext(icon_state), "sandbag"))
			var/obj/structure/f13/mojave_sandbag/obstacle/SBO = new(get_turf(src))
			SBO.dir = src.dir
			SBO.alpha = src.alpha
			SBO.color = src.color
			SBO.icon = icon
			SBO.icon_state = icon_state
			return TRUE
	return FALSE

/obj/structure/f13/mojave_prop/dense
	density = TRUE

/obj/structure/f13/mojave_prop/low
	layer = BELOW_OBJ_LAYER

/obj/effect/f13/mojave_decal
	name = "mojave decal"
	desc = "A Mojave decal. Set icon and icon_state in the map editor."
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	icon = 'mojave/icons/decals/ground_decals.dmi'
	icon_state = "grime_1"
	layer = BELOW_OBJ_LAYER
	plane = FLOOR_PLANE

/obj/effect/f13/mojave_decal/wall
	name = "mojave wall decal"
	desc = "A Mojave wall decal. Set icon and icon_state in the map editor."
	layer = TURF_DECAL_LAYER
	plane = ABOVE_WALL_PLANE

/turf/open/floor/mojave_generic
	name = "mojave floor"
	desc = "A Mojave floor turf. Set icon and icon_state in the map editor."
	icon = 'mojave/icons/turf/floors.dmi'
	icon_state = "floor_1"
	plane = FLOOR_PLANE

/turf/open/floor/mojave_sprite
	parent_type = /turf/open/floor/mojave_generic
	mojave_bitmask = TRUE

/turf/open/floor/mojave_sprite/Initialize()
	. = ..()
	mojave_update_bitmask(src)

/turf/open/floor/mojave_sprite/AfterChange()
	. = ..()
	mojave_update_bitmask(src)

/turf/closed/wall/mojave_generic
	name = "mojave wall"
	desc = "A Mojave wall turf. Set icon and icon_state in the map editor."
	icon = 'mojave/icons/turf/walls/brick.dmi'
	icon_state = "brick_1"

/turf/closed/wall/mojave_sprite
	parent_type = /turf/closed/wall/mojave_generic
	mojave_bitmask = TRUE
	mojave_smooth_group = "mojave_wall"
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/turf/closed/wall/mojave_sprite/Initialize()
	. = ..()
	mojave_update_bitmask(src)

/turf/closed/wall/mojave_sprite/AfterChange()
	. = ..()
	mojave_update_bitmask(src)
