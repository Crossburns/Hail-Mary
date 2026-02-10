// =============================================================================
// FEV PURGE SYSTEM
// A dungeon control system that can trigger an FEV storm weather event
// =============================================================================

#define FEV_PURGE_TIME 15 MINUTES
#define FEV_OVERRIDE_TIME 20 SECONDS
#define FEV_RECURRING_INTERVAL 20 MINUTES
#define FEV_RECURRING_DURATION 5 MINUTES
#define FEV_BREACH_CHECK_INTERVAL 5 SECONDS // (kept defined but UNUSED now; you can delete if you want)

// IMPORTANT: put your DMI under icons/
#define FEV_FOG_DMI 'code/modules/f13/32x32_sprites.dmi'

// You can provide 1, 2, or 3 states. If a state is missing, it falls back gracefully.
// Movement/animation STILL depends on the state being animated in the DMI.
#define FEV_FOG_TELEGRAPH_STATE "FEV_fog_warn"
#define FEV_FOG_MAIN_STATE      "FEV_fog"
#define FEV_FOG_END_STATE       "FEV_fog_fade"

// Target trait: if your wasteland z-levels aren't ZTRAIT_STATION, the base weather system may not pick them.
// This file includes a runtime fallback to still hit area_types even if impacted_z_levels comes up empty.
#define FEV_TARGET_TRAIT ZTRAIT_STATION


// =============================================================================
// ICON HELPERS
// =============================================================================

/proc/icon_state_exists(icon/icon_file, state)
	if(!icon_file || !state)
		return FALSE
	var/static/list/icon_state_cache = list() // icon_file => list(states)
	var/list/states = icon_state_cache[icon_file]
	if(!states)
		states = icon_states(icon_file)
		icon_state_cache[icon_file] = states
	return (state in states)


// =============================================================================
// FEV STORM LOOPING SOUNDS
// =============================================================================

/// Storm wind sounds for outside areas during FEV storm
/datum/looping_sound/fev_storm_wind
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/f13effects/sandstorm_loop.ogg', 8 SECONDS, 1)
	)
	mid_length = 8 SECONDS
	start_sound = list(SOUND_LOOP_ENTRY('sound/f13effects/sandstorm_warning.ogg', 5 SECONDS, 1))
	start_length = 50
	volume = 35

/// Vats of Goo music loop during FEV storm
/datum/looping_sound/fev_vats_of_goo
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/f13music/vats_of_goo.ogg', 180 SECONDS, 1) // Adjust as needed
	)
	mid_length = 180 SECONDS
	volume = 25

/// Rain sounds during FEV storm - outside
/datum/looping_sound/fev_rain_outside
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/weather/rain/outdoors/rain-01.ogg', 8 SECONDS, 1),
		SOUND_LOOP_ENTRY('sound/weather/rain/outdoors/rain-02.ogg', 8 SECONDS, 1),
		SOUND_LOOP_ENTRY('sound/weather/rain/outdoors/rain-03.ogg', 8 SECONDS, 1)
	)
	mid_length = 8 SECONDS
	volume = 40

/// Rain sounds during FEV storm - inside
/datum/looping_sound/fev_rain_inside
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/weather/rain/indoors/rain-01.ogg', 8 SECONDS, 1),
		SOUND_LOOP_ENTRY('sound/weather/rain/indoors/rain-02.ogg', 8 SECONDS, 1),
		SOUND_LOOP_ENTRY('sound/weather/rain/indoors/rain-03.ogg', 8 SECONDS, 1)
	)
	mid_length = 8 SECONDS
	volume = 20


// =============================================================================
// FEV STORM WEATHER EVENT (NO SEEPAGE VERSION)
// =============================================================================

/datum/weather/fev_storm
	name = "FEV storm"
	desc = "Aerosolized Forced Evolutionary Virus blankets the area, mutating any unprotected organisms."
	probability = 0 // Never occurs naturally - only triggered by the console

	telegraph_duration = 300 // deciseconds (300 = 30 seconds)
	telegraph_overlay = FEV_FOG_TELEGRAPH_STATE
	telegraph_message = span_userdanger("WARNING: Atmospheric contamination detected. FEV aerosol release imminent. Seek sealed shelter immediately!")
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = "<span class='userdanger'><i>A sickly green mist descends! The air burns with mutagenic compounds - get inside or suit up!</i></span>"
	weather_overlay = FEV_FOG_MAIN_STATE
	weather_duration_lower = 9000 // 15 minutes
	weather_duration_upper = 12000 // 20 minutes
	weather_sound = 'sound/ambience/acidrain_mid.ogg'
	weather_color = "#00ff00" // Green tint

	end_duration = 100
	end_message = span_userdanger("The FEV contamination dissipates. The air should be safe now... probably.")
	end_sound = 'sound/ambience/acidrain_end.ogg'
	end_overlay = FEV_FOG_END_STATE

	// Area targeting - affects wasteland outdoor areas
	area_types = list(/area/f13/wasteland, /area/f13/desert, /area/f13/farm, /area/f13/forest)
	tag_weather = WEATHER_FEV

	// If your wasteland isn't ZTRAIT_STATION, base selection may yield no impacted_z_levels.
	// We add a fallback in telegraph() to still populate impacted_areas based on area_types.
	target_trait = FEV_TARGET_TRAIT

	protect_indoors = TRUE
	is_dangerous = TRUE
	immunity_type = "fev"
	obscures_sight = TRUE // Reduces visibility like sandstorm

	barometer_predictable = FALSE
	carbons_only = TRUE

	/// Looping sound datums (instanced per-weather in Initialize/New)
	var/datum/looping_sound/fev_storm_wind/sound_wind
	var/datum/looping_sound/fev_vats_of_goo/sound_music
	var/datum/looping_sound/fev_rain_outside/sound_rain_outside
	var/datum/looping_sound/fev_rain_inside/sound_rain_inside

	/// Is this the first storm or a recurring one?
	var/is_first_storm = TRUE

	/// Timer id for recurring storms (so you can cancel if you ever want)
	var/recurring_timer_id = null

	/// Outdoor/indoor area lists (used for sound routing only)
	var/list/outdoor_areas = list()
	var/list/indoor_areas = list()

	/// Cache original area visuals so we never permanently trash custom areas
	var/list/area_visual_cache = list() // area -> list(icon=..., icon_state=..., layer=..., alpha=..., color=..., opacity=...)

/datum/weather/fev_storm/New()
	..()
	sound_wind = new
	sound_music = new
	sound_rain_outside = new
	sound_rain_inside = new


// =============================================================================
// VISUAL CACHE
// =============================================================================

/datum/weather/fev_storm/proc/cache_area_visuals(area/A)
	if(!A || area_visual_cache[A])
		return
	area_visual_cache[A] = list(
		"icon" = A.icon,
		"icon_state" = A.icon_state,
		"layer" = A.layer,
		"alpha" = A.alpha,
		"color" = A.color,
		"opacity" = A.opacity
	)

/datum/weather/fev_storm/proc/restore_area_visuals(area/A)
	if(!A)
		return
	var/list/s = area_visual_cache[A]
	if(!s)
		return
	A.icon = s["icon"]
	A.icon_state = s["icon_state"]
	A.layer = s["layer"]
	A.alpha = s["alpha"]
	A.color = s["color"]
	A.set_opacity(s["opacity"])

/datum/weather/fev_storm/proc/restore_all_area_visuals()
	for(var/area/A as anything in area_visual_cache)
		if(QDELETED(A))
			continue
		restore_area_visuals(A)
	area_visual_cache.Cut()


// =============================================================================
// INTERNAL HELPERS
// =============================================================================

/datum/weather/fev_storm/proc/is_allowed_area(area/A)
	if(!A)
		return FALSE
	for(var/path in area_types)
		if(istype(A, path))
			return TRUE
	return FALSE

/datum/weather/fev_storm/proc/get_all_areas_from_mapping()
	// Collect areas across every z in SSmapping.areas_in_z
	var/list/all = list()
	if(!SSmapping || !SSmapping.areas_in_z)
		return all
	for(var/z_key in SSmapping.areas_in_z)
		var/list/l = SSmapping.areas_in_z[z_key]
		if(islist(l) && l.len)
			all += l
	return all

/datum/weather/fev_storm/proc/ensure_impacts()
	// If the base weather system gave us nothing (usually wrong target_trait),
	// we manually populate impacted_areas and impacted_z_levels from mapping areas.
	if(impacted_areas && impacted_areas.len)
		return

	var/list/all = get_all_areas_from_mapping()
	if(!all.len)
		return

	impacted_areas = list()
	for(var/area/A as anything in all)
		if(!A || QDELETED(A))
			continue
		if(is_allowed_area(A))
			impacted_areas += A
		CHECK_TICK


// =============================================================================
// WEATHER LIFECYCLE
// =============================================================================

/datum/weather/fev_storm/telegraph()
	. = ..()

	// If wrong target_trait -> nothing impacted -> fix it here.
	ensure_impacts()

	// Set up sound output areas
	indoor_areas = list()
	outdoor_areas = list()

	if(!sound_wind) sound_wind = new
	if(!sound_music) sound_music = new
	if(!sound_rain_outside) sound_rain_outside = new
	if(!sound_rain_inside) sound_rain_inside = new

	var/list/eligible_areas = list()

	// Prefer impacted_z_levels if it exists, otherwise fall back to impacted_areas (manual)
	if(impacted_z_levels && impacted_z_levels.len && SSmapping && SSmapping.areas_in_z)
		for(var/z in impacted_z_levels)
			eligible_areas += SSmapping.areas_in_z[z]
	else
		eligible_areas = impacted_areas ? impacted_areas.Copy() : list()

	// Cache originals BEFORE any overlay touches them + build indoor/outdoor lists
	for(var/area/place as anything in eligible_areas)
		if(!place || QDELETED(place))
			continue

		cache_area_visuals(place)

		if(place.outdoors)
			outdoor_areas += place
		else
			indoor_areas += place

		CHECK_TICK

	sound_wind.output_atoms = outdoor_areas
	sound_music.output_atoms = outdoor_areas + indoor_areas // music everywhere
	sound_rain_outside.output_atoms = outdoor_areas
	sound_rain_inside.output_atoms = indoor_areas

	// Telegraph: wind only (rain starts during main storm)
	sound_wind.start()

/datum/weather/fev_storm/start()
	. = ..()
	// Start storm ambience when main stage begins
	sound_music.start()
	sound_rain_outside.start()
	sound_rain_inside.start()

/datum/weather/fev_storm/wind_down()
	. = ..()
	// Stop music during wind down (rain/wind can continue until end() stops them)
	if(sound_music) sound_music.stop()

/datum/weather/fev_storm/end()
	. = ..()
	// Stop all sounds
	if(sound_wind) sound_wind.stop()
	if(sound_rain_outside) sound_rain_outside.stop()
	if(sound_rain_inside) sound_rain_inside.stop()
	if(sound_music) sound_music.stop()

	// Restore any area visuals we altered (single source of truth: end() only)
	restore_all_area_visuals()

	// If this was the first storm, schedule recurring storms
	if(is_first_storm)
		is_first_storm = FALSE
		schedule_recurring_storm()

/datum/weather/fev_storm/proc/schedule_recurring_storm()
	// Store timer id so you can cancel later if needed
	if(recurring_timer_id)
		deltimer(recurring_timer_id)
	recurring_timer_id = addtimer(CALLBACK(GLOBAL_PROC, /proc/trigger_recurring_fev_storm), FEV_RECURRING_INTERVAL, TIMER_STOPPABLE)

/// Global proc to trigger recurring FEV storms
/proc/trigger_recurring_fev_storm()
	SSweather.run_weather(/datum/weather/fev_storm/recurring)

/// Recurring FEV storm - shorter duration (5 minutes)
/datum/weather/fev_storm/recurring
	weather_duration_lower = 3000 // 5 minutes
	weather_duration_upper = 3000 // 5 minutes
	is_first_storm = FALSE

/datum/weather/fev_storm/recurring/end()
	. = ..()
	// Schedule the next recurring storm
	schedule_recurring_storm()


// =============================================================================
// AREA UPDATES (FOG VISUALS)
// =============================================================================

/// Override to use custom FEV fog sprite (auto-detect states exist).
/// NOTE: “movement” depends on your DMI state being animated.
/datum/weather/fev_storm/update_areas()
	// If the base system failed to select areas (wrong target_trait), fix it.
	ensure_impacts()

	// Detect which custom states exist once, then pick best available per-stage.
	var/static/custom_checked = FALSE
	var/static/has_tele = FALSE
	var/static/has_main = FALSE
	var/static/has_end  = FALSE

	if(!custom_checked)
		custom_checked = TRUE
		has_tele = icon_state_exists(FEV_FOG_DMI, FEV_FOG_TELEGRAPH_STATE)
		has_main = icon_state_exists(FEV_FOG_DMI, FEV_FOG_MAIN_STATE)
		has_end  = icon_state_exists(FEV_FOG_DMI, FEV_FOG_END_STATE)

	for(var/area/N as anything in impacted_areas)
		if(!N || QDELETED(N))
			continue

		// Cache on first touch in case impacted_areas changes mid-storm
		cache_area_visuals(N)

		N.layer = overlay_layer
		N.color = weather_color

		var/use_custom = (has_tele || has_main || has_end)
		N.icon = use_custom ? FEV_FOG_DMI : 'icons/effects/weather_effects.dmi'

		switch(stage)
			if(STARTUP_STAGE)
				if(use_custom)
					if(has_tele) N.icon_state = FEV_FOG_TELEGRAPH_STATE
					else if(has_main) N.icon_state = FEV_FOG_MAIN_STATE
					else if(has_end) N.icon_state = FEV_FOG_END_STATE
				else
					N.icon_state = "acid_rain"

				N.alpha = 110
				N.set_opacity(FALSE)

			if(MAIN_STAGE)
				if(use_custom)
					if(has_main) N.icon_state = FEV_FOG_MAIN_STATE
					else if(has_tele) N.icon_state = FEV_FOG_TELEGRAPH_STATE
					else if(has_end) N.icon_state = FEV_FOG_END_STATE
				else
					N.icon_state = "acid_rain"

				N.alpha = 170
				N.set_opacity(obscures_sight)

			if(WIND_DOWN_STAGE)
				if(use_custom)
					if(has_end) N.icon_state = FEV_FOG_END_STATE
					else if(has_main) N.icon_state = FEV_FOG_MAIN_STATE
					else if(has_tele) N.icon_state = FEV_FOG_TELEGRAPH_STATE
				else
					N.icon_state = "acid_rain"

				N.alpha = 110
				N.set_opacity(FALSE)

			if(END_STAGE)
				// Do NOT restore here; end() restores everything once.
				// Leaving this blank prevents double-restore weirdness.
				;

		CHECK_TICK


// =============================================================================
// DAMAGE / EFFECTS
// =============================================================================

/datum/weather/fev_storm/weather_act(mob/living/L)
	if(is_fev_protected(L))
		return

	L.adjustToxLoss(3)
	L.adjust_bodytemperature(rand(5, 15))

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.apply_effect(10, EFFECT_IRRADIATE)

	if(prob(5))
		L.hallucination += rand(10, 30)

	if(prob(10))
		to_chat(L, span_danger("The green mist burns your skin! You feel your cells... shifting."))

/// Check if a mob is protected from FEV exposure
/proc/is_fev_protected(mob/living/L)
	if(!L)
		return TRUE

	if("fev" in L.weather_immunities)
		return TRUE

	if(!ishuman(L))
		return FALSE

	var/mob/living/carbon/human/H = L

	if(H.wear_suit)
		var/obj/item/clothing/suit/S = H.wear_suit

		if(istype(S, /obj/item/clothing/suit/armor/power_armor))
			return TRUE
		if(istype(S, /obj/item/clothing/suit/bio_suit))
			return TRUE
		if(istype(S, /obj/item/clothing/suit/radiation))
			return TRUE
		if(istype(S, /obj/item/clothing/suit/space/rad))
			return TRUE
		if(istype(S, /obj/item/clothing/suit/armor/heavy/salvaged_pa))
			return TRUE

		if(S.armor && S.armor.getRating("bio") >= 80)
			return TRUE

	if(HAS_TRAIT(H, TRAIT_RADIMMUNE))
		return TRUE

	return FALSE


// =============================================================================
// FEV CONTROL CONSOLE
// =============================================================================

/obj/machinery/computer/fev_control
	name = "FEV Purge Control Mainframe"
	desc = "A massive pre-war mainframe controlling the facility's FEV aerosolization system. Warning lights blink ominously across its surface."
	icon = 'code/modules/f13/mainframe.dmi'
	icon_state = "mainframe"
	icon_keyboard = null
	icon_screen = null
	density = TRUE
	light_color = LIGHT_COLOR_RED

	/// The ID for linked shutters/doors that open on purge completion
	var/door_id = "fev_vault_door"

	/// Is the purge sequence active?
	var/purge_active = FALSE

	/// Timer ID for the purge
	var/purge_timer_id = null

	/// When did the purge start (for UI display)
	var/purge_start_time = 0

	/// Is someone attempting to override?
	var/override_in_progress = FALSE

	/// Override timer ID
	var/override_timer_id = null

	/// Linked backup generator (bypasses power cut)
	var/obj/machinery/fev_backup_generator/linked_generator = null

	/// Generator link ID for finding the generator
	var/generator_link_id = "fev_generator"

/obj/machinery/computer/fev_control/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(find_generator)), 5 SECONDS)

/obj/machinery/computer/fev_control/proc/find_generator()
	for(var/obj/machinery/fev_backup_generator/G in GLOB.machines)
		if(G.link_id == generator_link_id)
			linked_generator = G
			G.linked_console = src
			break

/obj/machinery/computer/fev_control/process()
	if(!purge_active)
		return

	if(!is_operational())
		if(!linked_generator || !linked_generator.is_operational())
			abort_purge("POWER FAILURE - Purge sequence aborted.")
			return

/obj/machinery/computer/fev_control/attack_hand(mob/living/user)
	if(!is_operational())
		to_chat(user, span_warning("The console has no power."))
		return
	. = ..()
	ui_interact(user)

/obj/machinery/computer/fev_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FEVControl", name)
		ui.open()

/obj/machinery/computer/fev_control/ui_data(mob/user)
	var/list/data = list()
	data["purge_active"] = purge_active
	data["override_in_progress"] = override_in_progress

	if(purge_active)
		var/time_remaining = max(0, (purge_start_time + FEV_PURGE_TIME) - world.time)
		data["time_remaining"] = round(time_remaining / 600)
		data["time_remaining_seconds"] = round((time_remaining % 600) / 10)
	else
		data["time_remaining"] = 0
		data["time_remaining_seconds"] = 0

	data["has_power"] = is_operational()
	data["has_backup"] = linked_generator ? linked_generator.is_operational() : FALSE
	data["generator_repaired"] = linked_generator ? linked_generator.repaired : FALSE

	return data

/obj/machinery/computer/fev_control/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("start_purge")
			if(!purge_active)
				start_purge(usr)
			return TRUE

		if("start_override")
			if(purge_active && !override_in_progress)
				start_override(usr)
			return TRUE

		if("cancel_override")
			if(override_in_progress)
				cancel_override()
			return TRUE

/obj/machinery/computer/fev_control/proc/start_purge(mob/user)
	if(purge_active)
		return

	purge_active = TRUE
	purge_start_time = world.time
	icon_state = "mainframe_on"

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(T && T.z == z)
			to_chat(M, span_userdanger("FACILITY ALERT: FEV Purge sequence initiated. Estimated time to release: 15 minutes. Seek protective equipment or evacuate immediately!"))
			SEND_SOUND(M, sound('sound/machines/alarm.ogg'))

	purge_timer_id = addtimer(CALLBACK(src, PROC_REF(complete_purge)), FEV_PURGE_TIME, TIMER_STOPPABLE)

	log_game("[key_name(user)] initiated FEV purge sequence at [AREACOORD(src)]")
	message_admins("[ADMIN_LOOKUPFLW(user)] initiated FEV purge sequence at [AREACOORD(src)]")

/obj/machinery/computer/fev_control/proc/start_override(mob/user)
	if(!purge_active || override_in_progress)
		return

	override_in_progress = TRUE
	to_chat(user, span_notice("Initiating manual override... Hold position for 20 seconds."))

	override_timer_id = addtimer(CALLBACK(src, PROC_REF(complete_override), user), FEV_OVERRIDE_TIME, TIMER_STOPPABLE)

/obj/machinery/computer/fev_control/proc/cancel_override()
	if(!override_in_progress)
		return

	override_in_progress = FALSE
	if(override_timer_id)
		deltimer(override_timer_id)
		override_timer_id = null

/obj/machinery/computer/fev_control/proc/complete_override(mob/user)
	if(!override_in_progress)
		return

	override_in_progress = FALSE
	abort_purge("MANUAL OVERRIDE - Purge sequence terminated by [user ? user.real_name : "unknown"].")

	log_game("[key_name(user)] manually overrode FEV purge at [AREACOORD(src)]")

/obj/machinery/computer/fev_control/proc/abort_purge(reason)
	if(!purge_active)
		return

	purge_active = FALSE
	icon_state = "mainframe"

	if(purge_timer_id)
		deltimer(purge_timer_id)
		purge_timer_id = null

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(T && T.z == z)
			to_chat(M, span_boldnotice("FACILITY ALERT: [reason]"))

/obj/machinery/computer/fev_control/proc/complete_purge()
	if(!purge_active)
		return

	purge_active = FALSE
	purge_timer_id = null
	icon_state = "mainframe"

	open_vault_door()
	start_fev_storm()

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(T && T.z == z)
			to_chat(M, span_userdanger("FACILITY ALERT: FEV Purge complete. Aerosolization in progress. Executive Emergency Vault unsealed."))

	log_game("FEV purge completed at [AREACOORD(src)] - storm started and vault opened")

/obj/machinery/computer/fev_control/proc/open_vault_door()
	// Safer: doors might not live in GLOB.machines in your fork.
	for(var/obj/machinery/door/poddoor/D in world)
		if(D.id == door_id)
			INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))

/obj/machinery/computer/fev_control/proc/start_fev_storm()
	SSweather.run_weather(/datum/weather/fev_storm)


// =============================================================================
// FEV BACKUP GENERATOR
// =============================================================================

/obj/machinery/fev_backup_generator
	name = "FEV System Backup Generator"
	desc = "A heavily damaged backup power generator for the FEV control systems. It needs extensive repairs before it can function."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	density = TRUE
	anchored = TRUE

	/// Link ID to connect to the console
	var/link_id = "fev_generator"

	/// Linked console
	var/obj/machinery/computer/fev_control/linked_console = null

	/// Has this been repaired?
	var/repaired = FALSE

	/// Materials required to repair
	var/metal_required = 500
	var/titanium_required = 50
	var/parts_required = 10

	/// Current repair progress
	var/metal_added = 0
	var/titanium_added = 0
	var/parts_added = 0

/obj/machinery/fev_backup_generator/examine(mob/user)
	. = ..()
	if(!repaired)
		. += span_warning("This generator is heavily damaged and non-functional.")
		. += span_notice("Repair requirements:")
		. += span_notice("- Metal sheets: [metal_added]/[metal_required]")
		. += span_notice("- Titanium: [titanium_added]/[titanium_required]")
		. += span_notice("- Advanced crafting parts: [parts_added]/[parts_required]")
	else
		. += span_notice("The generator is fully repaired and operational.")
		if(linked_console)
			. += span_notice("It is linked to the FEV control console.")

/obj/machinery/fev_backup_generator/attackby(obj/item/I, mob/user, params)
	if(repaired)
		to_chat(user, span_notice("The generator is already fully repaired."))
		return ..()

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		var/needed = metal_required - metal_added
		if(needed <= 0)
			to_chat(user, span_notice("The generator has enough metal."))
			return
		var/to_use = min(M.amount, needed)
		M.use(to_use)
		metal_added += to_use
		to_chat(user, span_notice("You add [to_use] metal sheets. ([metal_added]/[metal_required])"))
		check_repair_complete(user)
		return

	if(istype(I, /obj/item/stack/sheet/mineral/titanium))
		var/obj/item/stack/sheet/mineral/titanium/T = I
		var/needed = titanium_required - titanium_added
		if(needed <= 0)
			to_chat(user, span_notice("The generator has enough titanium."))
			return
		var/to_use = min(T.amount, needed)
		T.use(to_use)
		titanium_added += to_use
		to_chat(user, span_notice("You add [to_use] titanium. ([titanium_added]/[titanium_required])"))
		check_repair_complete(user)
		return

	if(istype(I, /obj/item/stock_parts) || istype(I, /obj/item/circuitboard))
		var/needed = parts_required - parts_added
		if(needed <= 0)
			to_chat(user, span_notice("The generator has enough parts."))
			return
		parts_added += 1
		qdel(I)
		to_chat(user, span_notice("You install the component. ([parts_added]/[parts_required])"))
		check_repair_complete(user)
		return

	return ..()

/obj/machinery/fev_backup_generator/proc/check_repair_complete(mob/user)
	if(metal_added >= metal_required && titanium_added >= titanium_required && parts_added >= parts_required)
		repaired = TRUE
		icon_state = "portgen1"
		to_chat(user, span_boldnotice("The backup generator hums to life! It is now fully operational."))
		playsound(src, 'sound/machines/engine_alert1.ogg', 50, TRUE)

		if(!linked_console)
			for(var/obj/machinery/computer/fev_control/C in GLOB.machines)
				if(C.generator_link_id == link_id)
					linked_console = C
					C.linked_generator = src
					break

		log_game("[key_name(user)] repaired FEV backup generator at [AREACOORD(src)]")

/obj/machinery/fev_backup_generator/is_operational()
	return repaired && !(stat & (BROKEN|NOPOWER))


// =============================================================================
// TGUI INTERFACE
// =============================================================================

/obj/machinery/computer/fev_control/ui_state(mob/user)
	return GLOB.default_state


// =============================================================================
// DEBUG VERSION - Instant trigger, no timer
// =============================================================================

/obj/machinery/computer/fev_control/debug
	name = "FEV Purge Control Mainframe (DEBUG)"
	desc = "A debug version of the FEV control mainframe. Triggers immediately with no countdown."
	var/debug_mode = TRUE

/obj/machinery/computer/fev_control/debug/ui_data(mob/user)
	var/list/data = ..()
	data["debug_mode"] = TRUE
	return data

/obj/machinery/computer/fev_control/debug/ui_act(action, params)
	if(action == "instant_trigger")
		instant_trigger(usr)
		return TRUE
	return ..()

/obj/machinery/computer/fev_control/debug/proc/instant_trigger(mob/user)
	open_vault_door()
	start_fev_storm()

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(T && T.z == z)
			to_chat(M, span_userdanger("FACILITY ALERT: FEV Purge triggered immediately (DEBUG). Executive Emergency Vault unsealed."))

	log_game("[key_name(user)] triggered instant FEV purge (DEBUG) at [AREACOORD(src)]")
	message_admins("[ADMIN_LOOKUPFLW(user)] triggered instant FEV purge (DEBUG) at [AREACOORD(src)]")

#undef FEV_PURGE_TIME
#undef FEV_OVERRIDE_TIME
#undef FEV_RECURRING_INTERVAL
#undef FEV_RECURRING_DURATION
#undef FEV_BREACH_CHECK_INTERVAL
#undef FEV_FOG_DMI
#undef FEV_FOG_TELEGRAPH_STATE
#undef FEV_FOG_MAIN_STATE
#undef FEV_FOG_END_STATE
#undef FEV_TARGET_TRAIT
