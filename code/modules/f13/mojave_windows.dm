// Mojave windows (manual, curated). Uses Mojave bitmask smoothing for glass variants.

/obj/structure/window/mojave
	name = "mojave window"
	desc = "A Mojave window."
	icon = 'mojave/icons/turf/walls/glass.dmi'
	icon_state = "glass-0"
	mojave_bitmask = TRUE
	mojave_base_icon_state = "glass"
	mojave_smooth_group = list("mojave_window", "mojave_wall")
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/obj/structure/window/mojave/Initialize(mapload)
	. = ..()
	mojave_update_bitmask(src)

/obj/structure/window/mojave/reinforced
	name = "reinforced mohave window"
	desc = "A reinforced Mojave window."
	max_integrity = 300

/obj/structure/window/fulltile/mojave
	name = "mojave full window"
	desc = "A Mojave fulltile window."
	icon = 'mojave/icons/turf/walls/glass.dmi'
	icon_state = "glass-0"
	mojave_bitmask = TRUE
	mojave_base_icon_state = "glass"
	mojave_smooth_group = list("mojave_window", "mojave_wall")
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/obj/structure/window/fulltile/mojave/Initialize(mapload)
	. = ..()
	mojave_update_bitmask(src)

/obj/structure/window/reinforced/fulltile/mojave
	name = "reinforced mohave full window"
	desc = "A reinforced Mojave fulltile window."
	icon = 'mojave/icons/turf/walls/glass.dmi'
	icon_state = "glass-0"
	max_integrity = 300
	mojave_bitmask = TRUE
	mojave_base_icon_state = "glass"
	mojave_smooth_group = list("mojave_window", "mojave_wall")
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/obj/structure/window/reinforced/fulltile/mojave/Initialize(mapload)
	. = ..()
	mojave_update_bitmask(src)
