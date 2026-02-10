// Mojave terrain + floors (manual, map-usable). Uses Mojave-scoped bitmask smoothing.

/turf/open/floor/plating/mojave
	baseturfs = /turf/open/floor/plating/mojave
	attachment_holes = FALSE
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/floor/plating/mojave/interior
	name = "mojave floor"
	desc = "A Mojave floor."
	baseturfs = /turf/open/floor/plating/mojave/interior

/turf/open/floor/plating/mojave/outside
	sunlight_state = SUNLIGHT_SOURCE

/turf/open/floor/plating/mojave/outside/Initialize()
	. = ..()
	flags_2 |= GLOBAL_LIGHT_TURF_2

/turf/open/floor/plating/mojave/outside/bitmask
	mojave_bitmask = TRUE
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/turf/open/floor/plating/mojave/outside/bitmask/Initialize()
	. = ..()
	mojave_update_bitmask(src)

/turf/open/floor/plating/mojave/outside/bitmask/AfterChange()
	. = ..()
	mojave_update_bitmask(src)

/turf/open/floor/plating/mojave/outside/misc
	name = "mojave terrain"
	desc = "A Mojave surface."
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/roof_misc
	name = "mojave roof"
	desc = "Old roofing."
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

// Ground (non-bitmask variant)
/turf/open/floor/plating/mojave/outside/ground
	name = "ground"
	desc = "Hard-packed ground."
	icon = 'mojave/icons/turf/ground.dmi'
	icon_state = "desert_1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/ground/Initialize()
	. = ..()
	icon_state = "desert_[rand(1,3)]"

// Desert
/turf/open/floor/plating/mojave/outside/bitmask/desert
	name = "desert"
	desc = "A stretch of desert."
	icon = 'mojave/icons/turf/64x/drought_1.dmi'
	icon_state = "dirt-0"
	mojave_base_icon_state = "dirt"
	mojave_smooth_group = "mojave_desert"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/bitmask/desert/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/64x/drought_1.dmi'
		if(2) icon = 'mojave/icons/turf/64x/drought_2.dmi'
		if(3) icon = 'mojave/icons/turf/64x/drought_3.dmi'
	mojave_update_bitmask(src)

// Road
/turf/open/floor/plating/mojave/outside/bitmask/road
	name = "\proper road"
	desc = "A stretch of road."
	icon = 'mojave/icons/turf/64x/road_1.dmi'
	icon_state = "road-0"
	mojave_base_icon_state = "road"
	mojave_smooth_group = "mojave_road"
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/bitmask/road/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/64x/road_1.dmi'
		if(2) icon = 'mojave/icons/turf/64x/road_2.dmi'
		if(3) icon = 'mojave/icons/turf/64x/road_3.dmi'
	mojave_update_bitmask(src)

// Snow
/turf/open/floor/plating/mojave/outside/bitmask/snow
	name = "snow"
	desc = "Fresh powder."
	icon = 'mojave/icons/turf/64x/snow_1.dmi'
	icon_state = "snow-0"
	mojave_base_icon_state = "snow"
	mojave_smooth_group = "mojave_snow"
	footstep = FOOTSTEP_SNOW
	barefootstep = FOOTSTEP_SNOW
	clawfootstep = FOOTSTEP_SNOW
	slowdown = 1
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/bitmask/snow/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/64x/snow_1.dmi'
		if(2) icon = 'mojave/icons/turf/64x/snow_2.dmi'
		if(3) icon = 'mojave/icons/turf/64x/snow_3.dmi'
	mojave_update_bitmask(src)

// Ice
/turf/open/floor/plating/mojave/outside/bitmask/ice
	name = "ice"
	desc = "A sheet of ice."
	icon = 'mojave/icons/turf/64x/ice_1.dmi'
	icon_state = "ice-0"
	mojave_base_icon_state = "ice"
	mojave_smooth_group = "mojave_ice"
	footstep = FOOTSTEP_SNOW
	barefootstep = FOOTSTEP_SNOW
	clawfootstep = FOOTSTEP_SNOW
	slowdown = 0.2
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/bitmask/ice/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/64x/ice_1.dmi'
		if(2) icon = 'mojave/icons/turf/64x/ice_2.dmi'
		if(3) icon = 'mojave/icons/turf/64x/ice_3.dmi'
	mojave_update_bitmask(src)

// Roofs
/turf/open/floor/plating/mojave/outside/bitmask/roof
	name = "roof"
	desc = "Old roofing."
	icon = 'mojave/icons/turf/roof_asphalt.dmi'
	icon_state = "roof-0"
	mojave_base_icon_state = "roof"
	mojave_smooth_group = "mojave_roof"
	baseturfs = /turf/open/floor/plating/mojave/outside/ground

/turf/open/floor/plating/mojave/outside/bitmask/roof/metal
	icon = 'mojave/icons/turf/roof_metal.dmi'

/turf/open/floor/plating/mojave/outside/bitmask/roof/metal/rusty
	icon = 'mojave/icons/turf/roof_rusty.dmi'

/turf/open/floor/plating/mojave/outside/bitmask/roof/sheet
	icon = 'mojave/icons/turf/roof_sheet.dmi'

/turf/open/floor/plating/mojave/outside/bitmask/roof/wood
	icon = 'mojave/icons/turf/roof_wood.dmi'

// Mojave water
/turf/open/water/mojave
	name = "water"
	desc = "Mojave water."
	icon = 'mojave/icons/turf/water.dmi'
	baseturfs = /turf/open/water/mojave
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/water/mojave/fishing
	name = "fishing hole"
	desc = "A shallow fishing hole."
	icon = 'mojave/icons/turf/fishing_hole.dmi'
