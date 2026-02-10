/datum/grid_faction_bridge
	/// Reconcile pass cadence in faction subsystem ticks.
	var/reconcile_interval = 30
	var/last_reconcile_tick = 0

/datum/grid_faction_bridge/proc/sync_district_to_grid(datum/controller/subsystem/faction_control/FC, district, owner_override = null, atom/source = null)
	if(!FC)
		return list("ok" = FALSE, "district" = district, "owner" = null, "reason" = "missing_faction_control")
	if(!istext(district) || !length(district))
		return list("ok" = FALSE, "district" = district, "owner" = null, "reason" = "missing_district_id")

	if(hascall(FC, "ensure_district"))
		call(FC, "ensure_district")(district)

	var/owner = owner_override
	if(!istext(owner) || !length(owner))
		if(hascall(FC, "get_owner"))
			owner = call(FC, "get_owner")(district)

	if(istext(owner) && length(owner))
		if(islist(FC.district_owner))
			FC.district_owner[district] = owner
	else
		owner = null

	// Keep district utility cache coherent after owner/sync updates.
	if(islist(FC.district_utility_cache))
		FC.district_utility_cache[district] = null

	// Ensure grid-side district structures are initialized.
	_wasteland_grid_bootstrap_districts()

	return list(
		"ok" = TRUE,
		"district" = district,
		"owner" = owner,
		"reason" = "ok"
	)

/datum/grid_faction_bridge/proc/log_sync(list/result, atom/source = null)
	if(!islist(result))
		return
	var/district = result["district"]
	var/owner = result["owner"]
	var/reason = result["reason"]
	var/ok = !!result["ok"]
	var/source_ref = source ? "[source.type]@[AREACOORD(source)]" : "none"
	log_game("Faction/Grid sync: ok=[ok ? 1 : 0] district='[district]' owner='[owner]' reason='[reason]' source='[source_ref]'")
	if(SSblackbox)
		SSblackbox.record_feedback("nested tally", "district_grid_sync", 1, list(
			ok ? "ok" : "fail",
			"[reason]",
			"[district ? district : "none"]"
		))

/datum/grid_faction_bridge/proc/rebuild_district_to_grid_bindings(datum/controller/subsystem/faction_control/FC)
	var/list/report = list()
	if(!FC)
		report += "faction control unavailable"
		return report
	if(!islist(FC.district_owner))
		report += "no district owner map to rebuild"
		return report

	var/rebuilt = 0
	var/failed = 0
	for(var/district in FC.district_owner)
		var/owner = FC.district_owner[district]
		var/list/result = sync_district_to_grid(FC, district, owner, null)
		if(result["ok"])
			rebuilt++
		else
			failed++
			report += "[district]: sync failed ([result["reason"]])"

	reconcile_player_faction_node_links(FC)
	report.Insert(1, "rebuilt=[rebuilt] failed=[failed]")
	return report

/datum/grid_faction_bridge/proc/audit_district_node_state(datum/controller/subsystem/faction_control/FC)
	var/list/report = list()
	if(!islist(GLOB.player_faction_district_nodes) || !length(GLOB.player_faction_district_nodes))
		report += "no player faction district nodes registered"
		return report

	for(var/obj/structure/player_faction_district_node/N in GLOB.player_faction_district_nodes)
		if(!N || QDELETED(N))
			continue
		var/district = hascall(N, "resolve_district_id") ? call(N, "resolve_district_id")() : N:district_id
		var/owner = FC && hascall(FC, "get_owner") ? call(FC, "get_owner")(district) : null
		var/linked = hascall(N, "is_grid_linked") ? call(N, "is_grid_linked")() : FALSE
		report += "[N.type] district=[district ? district : "none"] owner=[owner ? owner : "none"] state=[N:node_state] online=[N:online ? "1" : "0"] linked=[linked ? "1" : "0"]"

	if(!length(report))
		report += "no valid district nodes found"
	return report

/datum/grid_faction_bridge/proc/reconcile_player_faction_node_links(datum/controller/subsystem/faction_control/FC)
	if(!islist(GLOB.player_faction_district_nodes) || !length(GLOB.player_faction_district_nodes))
		return
	if(world.time < (last_reconcile_tick + reconcile_interval))
		return
	last_reconcile_tick = world.time

	var/list/online_by_district = list()
	for(var/obj/structure/player_faction_district_node/N in GLOB.player_faction_district_nodes)
		if(!N || QDELETED(N))
			continue
		var/d = hascall(N, "resolve_district_id") ? call(N, "resolve_district_id")() : N:district_id
		if(!istext(d) || !length(d))
			continue

		if(N:online)
			if(!isnull(online_by_district[d]))
				if(hascall(N, "handle_desync"))
					call(N, "handle_desync")("duplicate_online_node")
				continue
			online_by_district[d] = N

			var/is_linked = hascall(N, "is_grid_linked") ? call(N, "is_grid_linked")() : FALSE
			if(!is_linked && hascall(N, "handle_desync"))
				call(N, "handle_desync")("periodic_owner_mismatch")
