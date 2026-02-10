// Placeable ecology presets for mappers.
// These let map editors stamp ecology behavior on specific tiles without area var edits.

GLOBAL_LIST_EMPTY(fauna_presets_by_turf)
GLOBAL_LIST_EMPTY(fauna_presets_by_z)

/datum/fauna_preset_runtime
	var/turf/turf_ref = null
	var/z = 0
	var/fauna_habitat = null
	var/fauna_no_spawn = null
	var/fauna_spawn_mult = null
	var/fauna_forage_rich = null
	var/fauna_forage_bonus = null
	var/water_source = null
	var/fauna_migration_bias = null
	var/priority = 10

/obj/effect/f13/fauna_preset
	name = "fauna preset"
	desc = "Mapper-only ecology preset marker."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	anchored = TRUE
	density = FALSE
	layer = POINT_LAYER
	alpha = 170
	invisibility = INVISIBILITY_MAXIMUM

	// These mirror area fauna vars; null means no override.
	var/fauna_habitat = null
	var/fauna_no_spawn = null
	var/fauna_spawn_mult = null
	var/fauna_forage_rich = null
	var/fauna_forage_bonus = null
	var/water_source = null
	var/fauna_migration_bias = null
	var/priority = 10

/obj/effect/f13/fauna_preset/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		return INITIALIZE_HINT_QDEL
	if(!islist(GLOB.fauna_presets_by_turf))
		GLOB.fauna_presets_by_turf = list()
	if(!islist(GLOB.fauna_presets_by_z))
		GLOB.fauna_presets_by_z = list()
	var/key = "[T.x],[T.y],[T.z]"
	var/datum/fauna_preset_runtime/existing = GLOB.fauna_presets_by_turf[key]
	if(!istype(existing, /datum/fauna_preset_runtime))
		existing = null
	if(existing && existing.priority > priority)
		return INITIALIZE_HINT_QDEL
	if(existing && existing.z)
		var/z_key = "z:[existing.z]"
		var/list/old_z_bucket = GLOB.fauna_presets_by_z[z_key]
		if(islist(old_z_bucket))
			old_z_bucket -= existing
	var/datum/fauna_preset_runtime/runtime = new
	runtime.turf_ref = T
	runtime.z = T.z
	runtime.fauna_habitat = fauna_habitat
	runtime.fauna_no_spawn = fauna_no_spawn
	runtime.fauna_spawn_mult = fauna_spawn_mult
	runtime.fauna_forage_rich = fauna_forage_rich
	runtime.fauna_forage_bonus = fauna_forage_bonus
	runtime.water_source = water_source
	runtime.fauna_migration_bias = fauna_migration_bias
	runtime.priority = priority
	GLOB.fauna_presets_by_turf[key] = runtime
	var/runtime_z_key = "z:[runtime.z]"
	if(!islist(GLOB.fauna_presets_by_z[runtime_z_key]))
		GLOB.fauna_presets_by_z[runtime_z_key] = list()
	GLOB.fauna_presets_by_z[runtime_z_key] += runtime
	return INITIALIZE_HINT_QDEL

/obj/effect/f13/fauna_preset/lush_oasis
	name = "fauna preset - lush oasis"
	desc = "High-forage node: stronger prey recovery and sustained activity."
	fauna_habitat = "wasteland"
	fauna_spawn_mult = 1.4
	fauna_forage_rich = TRUE
	fauna_forage_bonus = 4
	water_source = TRUE
	fauna_migration_bias = -4
	priority = 20

/obj/effect/f13/fauna_preset/barren_waste
	name = "fauna preset - barren waste"
	desc = "Low-forage node: sparse populations, outward migration pressure."
	fauna_habitat = "wasteland"
	fauna_spawn_mult = 0.5
	fauna_forage_rich = FALSE
	fauna_forage_bonus = -4
	water_source = FALSE
	fauna_migration_bias = 6
	priority = 20

/obj/effect/f13/fauna_preset/dead_zone
	name = "fauna preset - dead zone"
	desc = "No fauna materialization zone."
	fauna_no_spawn = TRUE
	priority = 30

/obj/effect/f13/fauna_preset/cave_nest
	name = "fauna preset - cave nest"
	desc = "Cave-biased habitat with elevated predator pressure potential."
	fauna_habitat = "cave"
	fauna_spawn_mult = 1.4
	fauna_forage_bonus = 2
	fauna_migration_bias = -2
	priority = 20
