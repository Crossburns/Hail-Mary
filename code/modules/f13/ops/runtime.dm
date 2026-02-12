// code/modules/f13/ops/runtime.dm
// Unified operations runtime for faction/grid/contracts integration.

/datum/f13_ops_module
	/// Stable identifier for diagnostics and configuration.
	var/module_id = "base"
	/// If FALSE, module tick hooks are skipped.
	var/enabled = TRUE
	/// Optional human-readable status string.
	var/last_status = "idle"

	/// Called when the module is registered with the runtime.
	proc/on_register(datum/f13_ops_runtime/runtime, datum/controller/subsystem/faction_control/FC)
		last_status = "registered"

	/// Called by runtime at module cadence.
	proc/on_tick(datum/f13_ops_runtime/runtime, datum/controller/subsystem/faction_control/FC)
		last_status = "tick"

	/// Called when runtime is shutting down or module is removed.
	proc/on_unregister(datum/f13_ops_runtime/runtime, datum/controller/subsystem/faction_control/FC)
		last_status = "unregistered"


/datum/f13_ops_world_pressure
	/// 0..100 pressure channels sampled from existing game systems.
	var/reactor_pressure = 0
	var/weather_pressure = 0
	var/fauna_pressure = 0
	/// district => combined pressure (0..100)
	var/list/district_pressure = list()
	/// district => tier string
	var/list/district_pressure_tier = list()
	/// world.time
	var/last_update = 0

/datum/f13_ops_world_pressure/proc/sample_reactor_pressure()
	var/faults = islist(GLOB.wasteland_grid_faults) ? length(GLOB.wasteland_grid_faults) : 0
	var/heat = max(0, round(GLOB.wasteland_grid_core_heat))
	var/rads = max(0, round(GLOB.wasteland_grid_background_rads))
	// Keep this light and tunable. Faults dominate, then heat/rads.
	return clamp(round((faults * 8) + (heat * 0.35) + (rads * 2)), 0, 100)

/datum/f13_ops_world_pressure/proc/sample_weather_pressure()
	var/value = 0
	var/datum/weather/W = SSweather?.current_weather
	if(W)
		value += 15
		var/stage = W.vars["stage"]
		if(isnum(stage))
			value += round(stage) * 12
		if("perceived_weather" in W.vars)
			var/perceived = W.vars["perceived_weather"]
			if(istext(perceived) && length(perceived))
				value += 10
	return clamp(round(value), 0, 100)

/datum/f13_ops_world_pressure/proc/sample_fauna_pressure()
	if(!SSfauna_ecosystem)
		return 0
	var/total = 0
	var/count = 0
	if(islist(SSfauna_ecosystem.zone_player_pressure))
		for(var/k in SSfauna_ecosystem.zone_player_pressure)
			total += round(SSfauna_ecosystem.zone_player_pressure[k] || 0)
			count++
	if(islist(SSfauna_ecosystem.zone_danger_memory))
		for(var/k2 in SSfauna_ecosystem.zone_danger_memory)
			total += round(SSfauna_ecosystem.zone_danger_memory[k2] || 0)
			count++
	if(count <= 0)
		return 0
	return clamp(round(total / count), 0, 100)

/datum/f13_ops_world_pressure/proc/tier_for_value(v)
	if(v >= 75)
		return "critical"
	if(v >= 50)
		return "high"
	if(v >= 25)
		return "elevated"
	return "stable"

/datum/f13_ops_world_pressure/proc/recompute(datum/controller/subsystem/faction_control/FC)
	if(!FC)
		return

	reactor_pressure = sample_reactor_pressure()
	weather_pressure = sample_weather_pressure()
	fauna_pressure = sample_fauna_pressure()

	if(!islist(district_pressure))
		district_pressure = list()
	if(!islist(district_pressure_tier))
		district_pressure_tier = list()

	var/base = (reactor_pressure * 0.45) + (weather_pressure * 0.25) + (fauna_pressure * 0.30)
	for(var/d in FC.district_income)
		var/water = FC.get_district_water_level(d)
		var/logistics = FC.get_district_logistics_level(d)
		var/stability = FC.get_district_stability(d)
		var/infra = (water + logistics + stability) / 3
		// Poor infrastructure amplifies pressure while strong districts dampen it.
		var/infra_mult = 1 + ((50 - infra) / 100)
		var/combined = clamp(round(base * infra_mult), 0, 100)
		district_pressure[d] = combined
		district_pressure_tier[d] = tier_for_value(combined)

	last_update = world.time

/datum/f13_ops_world_pressure/proc/get_district_pressure(district)
	if(isnull(district_pressure[district]))
		return 0
	return clamp(round(district_pressure[district]), 0, 100)

/datum/f13_ops_world_pressure/proc/get_district_tier(district)
	var/tier = district_pressure_tier[district]
	return istext(tier) ? tier : "stable"

/datum/f13_ops_world_pressure/proc/export_rows(datum/controller/subsystem/faction_control/FC, faction = null)
	var/list/rows = list()
	if(!FC || !islist(FC.district_income))
		return rows
	for(var/d in FC.district_income)
		var/owner = FC.get_owner(d)
		if(faction && owner != faction)
			continue
		rows += list(list(
			"district" = d,
			"owner" = owner ? "[owner]" : "",
			"pressure" = get_district_pressure(d),
			"tier" = get_district_tier(d)
		))
	return rows


/datum/f13_ops_task_broker
	/// ckey => world.time of the latest recommendation ping.
	var/list/last_recommendation_at = list()
	/// Minimum spacing between recommendations to avoid spam.
	var/recommendation_cooldown = 90 SECONDS

/datum/f13_ops_task_broker/proc/get_role_title(mob/M)
	if(!M)
		return null
	if(M.mind && istext(M.mind.assigned_role) && length(M.mind.assigned_role))
		return "[M.mind.assigned_role]"
	if(istext(M.job) && length(M.job))
		return "[M.job]"
	return null

/datum/f13_ops_task_broker/proc/get_spawn_briefing(mob/M, datum/controller/subsystem/faction_control/FC)
	var/title = get_role_title(M)
	if(!istext(title) || !length(title))
		return list()
	var/title_l = lowertext(title)
	var/list/lines = list()
	if(findtext(title_l, "mass fusion"))
		lines += "Keep district utility online: power, water, and logistics all matter."
		lines += "Use contracts to stabilize districts before chasing bonus payout loops."
		lines += "If pressure is high, prioritize maintenance and hazard mitigation first."
	else if(findtext(title_l, "scav"))
		lines += "Run parts into districts with low logistics or low stability."
		lines += "Coordinate with command before long trips to keep routes aligned."
	else if(findtext(title_l, "technician") || findtext(title_l, "engineer"))
		lines += "Protect relay uptime. Grid outages now affect income and contract quality."
		lines += "Fix local bottlenecks first: low water/logistics causes cascading penalties."
	else
		lines += "Check district status before committing to contracts."
		lines += "Favor actions that restore utility in owned districts."
	return lines

/datum/f13_ops_task_broker/proc/recommend_task(mob/M, datum/controller/subsystem/faction_control/FC, datum/f13_ops_world_pressure/P)
	if(!M || !FC || !P)
		return null

	var/ck = M.ckey
	if(ck && last_recommendation_at[ck] && world.time < (last_recommendation_at[ck] + recommendation_cooldown))
		return null

	var/f = FC.get_mob_faction(M)
	if(!f)
		return null

	var/list/owned = FC.get_owned_districts(f)
	if(!length(owned))
		return null

	var/chosen = null
	var/best_score = -1
	for(var/d in owned)
		var/list/U = FC.get_district_utility_state(d)
		var/pressure = P.get_district_pressure(d)
		var/score = pressure
		if(!U["power"]) score += 40
		if(!U["water"]) score += 25
		if(!U["logistics"]) score += 25
		if(score > best_score)
			best_score = score
			chosen = d

	if(!chosen)
		return null

	var/list/U2 = FC.get_district_utility_state(chosen)
	var/title = "Stabilize district [chosen]"
	var/reason = "High pressure and utility deficits are reducing district output."
	var/focus = "utility"
	if(!U2["power"])
		title = "Restore power route for [chosen]"
		reason = "District power is offline. Income and systems are degraded."
		focus = "power"
	else if(!U2["water"])
		title = "Restore water support for [chosen]"
		reason = "Water deficit is limiting district utility and growth."
		focus = "water"
	else if(!U2["logistics"])
		title = "Restore logistics for [chosen]"
		reason = "Logistics collapse is suppressing uptime and contract reliability."
		focus = "logistics"

	if(ck)
		last_recommendation_at[ck] = world.time

	return list(
		"id" = "district_stabilize",
		"title" = title,
		"district" = chosen,
		"focus" = focus,
		"reason" = reason,
		"priority" = clamp(round(best_score), 0, 100)
	)


/datum/f13_ops_runtime
	/// Runtime cadence.
	var/tick_interval = 15 SECONDS
	var/pressure_tick_interval = 45 SECONDS
	var/next_tick = 0
	var/next_pressure_tick = 0
	/// Datums owned by runtime.
	var/datum/f13_ops_world_pressure/pressure_model = null
	var/datum/f13_ops_task_broker/task_broker = null
	/// Registered extension modules.
	var/list/registered_modules = list()
	/// Diagnostics.
	var/last_tick_at = 0
	var/last_pressure_tick_at = 0

/datum/f13_ops_runtime/proc/bootstrap(datum/controller/subsystem/faction_control/FC)
	if(!pressure_model)
		pressure_model = new
	if(!task_broker)
		task_broker = new
	if(!islist(registered_modules))
		registered_modules = list()
	next_tick = world.time + tick_interval
	next_pressure_tick = world.time + pressure_tick_interval

/datum/f13_ops_runtime/proc/register_module(datum/f13_ops_module/M, datum/controller/subsystem/faction_control/FC)
	if(!M)
		return
	if(!islist(registered_modules))
		registered_modules = list()
	if(M in registered_modules)
		return
	registered_modules += M
	M.on_register(src, FC)

/datum/f13_ops_runtime/proc/tick(datum/controller/subsystem/faction_control/FC)
	if(!FC)
		return
	if(world.time < next_tick)
		return

	if(world.time >= next_pressure_tick)
		if(pressure_model)
			pressure_model.recompute(FC)
		last_pressure_tick_at = world.time
		next_pressure_tick = world.time + pressure_tick_interval

	if(islist(registered_modules))
		for(var/datum/f13_ops_module/M in registered_modules)
			if(!M || QDELETED(M) || !M.enabled)
				continue
			M.on_tick(src, FC)

	last_tick_at = world.time
	next_tick = world.time + tick_interval

/datum/f13_ops_runtime/proc/get_district_snapshot(datum/controller/subsystem/faction_control/FC, district)
	if(!FC || !district)
		return null
	var/list/U = FC.get_district_utility_state(district)
	return list(
		"district" = district,
		"owner" = FC.get_owner(district),
		"income" = round(FC.district_income[district] || FACTION_CTRL_DEFAULT_DISTRICT_INCOME),
		"water" = FC.get_district_water_level(district),
		"logistics" = FC.get_district_logistics_level(district),
		"stability" = FC.get_district_stability(district),
		"power_ok" = !!U["power"],
		"water_ok" = !!U["water"],
		"logistics_ok" = !!U["logistics"],
		"effective_mult" = round(U["effective_mult"] || 1.0, 0.01),
		"pressure" = pressure_model ? pressure_model.get_district_pressure(district) : 0,
		"pressure_tier" = pressure_model ? pressure_model.get_district_tier(district) : "stable"
	)

/datum/f13_ops_runtime/proc/list_district_snapshots(datum/controller/subsystem/faction_control/FC)
	var/list/rows = list()
	if(!FC || !islist(FC.district_income))
		return rows
	for(var/d in FC.district_income)
		rows += list(get_district_snapshot(FC, d))
	return rows

/datum/f13_ops_runtime/proc/get_dashboard_extension(datum/controller/subsystem/faction_control/FC, mob/user, faction = null)
	var/list/extra = list()
	if(!FC)
		return extra
	extra["pressure_rows"] = pressure_model ? pressure_model.export_rows(FC, faction) : list()
	extra["pressure_updated_ds_ago"] = pressure_model ? max(0, round((world.time - pressure_model.last_update) / 10)) : -1
	extra["reactor_pressure"] = pressure_model ? pressure_model.reactor_pressure : 0
	extra["weather_pressure"] = pressure_model ? pressure_model.weather_pressure : 0
	extra["fauna_pressure"] = pressure_model ? pressure_model.fauna_pressure : 0
	extra["spawn_briefing"] = task_broker ? task_broker.get_spawn_briefing(user, FC) : list()
	extra["recommended_task"] = task_broker ? task_broker.recommend_task(user, FC, pressure_model) : null
	extra["runtime_tick_ds_ago"] = max(0, round((world.time - last_tick_at) / 10))
	return extra
