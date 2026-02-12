// code/modules/f13/grid_faction/bridge.dm
// Isolated bridge for faction <-> wasteland grid synchronization.

GLOBAL_VAR(grid_faction_bridge)

/proc/get_grid_faction_bridge()
	if(!GLOB.grid_faction_bridge)
		GLOB.grid_faction_bridge = new /datum/grid_faction_bridge()
	return GLOB.grid_faction_bridge

/datum/grid_faction_bridge
	/// Build a standardized sync result row.
	proc/new_sync_result(district)
		return list(
			"ok" = FALSE,
			"district" = district,
			"owner" = null,
			"reason" = "unknown"
		)

	/// Core source-of-truth sync path used by faction subsystem and district nodes.
	proc/sync_district_to_grid(datum/controller/subsystem/faction_control/controller, district, owner_override = null, atom/source = null)
		var/list/result = new_sync_result(district)
		if(!controller)
			result["reason"] = "missing_controller"
			log_sync(result, source)
			return result

		if(!istext(district) || !length(district))
			result["reason"] = "missing_district"
			log_sync(result, source)
			return result

		controller.bootstrap_districts()
		controller.ensure_district(district)

		var/owner = null
		if(istext(owner_override) && length(owner_override))
			owner = "[owner_override]"
			controller.district_owner[district] = owner
		else
			owner = controller.district_owner[district]

		if(!istext(owner) || !length(owner))
			result["reason"] = "missing_owner"
			log_sync(result, source)
			return result

		_wasteland_grid_bootstrap_districts()
		if(isnull(GLOB.wasteland_grid_district_off_until[district]))
			GLOB.wasteland_grid_district_off_until[district] = world.time
		if(isnull(GLOB.wasteland_grid_district_applied_on[district]))
			GLOB.wasteland_grid_district_applied_on[district] = _grid_is_district_on(district)

		_grid_reconcile_district_power()
		result["ok"] = TRUE
		result["owner"] = owner
		result["reason"] = "ok"
		log_sync(result, source)
		return result

	proc/log_sync(list/result, atom/source = null)
		var/d = result ? result["district"] : null
		var/o = result ? result["owner"] : null
		var/r = result ? result["reason"] : "unknown"
		var/ok = (result && result["ok"]) ? TRUE : FALSE
		var/source_txt = source ? "[source.type]" : "none"
		log_game("Faction/Grid sync: district='[d]' owner='[o]' ok=[ok ? "1" : "0"] reason='[r]' source='[source_txt]'.")
		if(SSblackbox)
			SSblackbox.record_feedback("nested tally", "district_grid_sync", 1, list(ok ? "success" : "fail", "[r]"))

	proc/rebuild_district_to_grid_bindings(datum/controller/subsystem/faction_control/controller)
		var/list/report = list()
		if(!controller)
			report += "faction controller unavailable"
			return report
		controller.bootstrap_districts()
		for(var/district in controller.district_owner)
			var/owner = controller.district_owner[district]
			var/list/r = sync_district_to_grid(controller, district, owner, null)
			report += "district=[district] owner=[owner] ok=[r["ok"] ? "YES" : "NO"] reason=[r["reason"]]"
		if(islist(GLOB.player_faction_district_nodes))
			for(var/obj/structure/player_faction_district_node/N in GLOB.player_faction_district_nodes)
				if(!N || QDELETED(N))
					continue
				N.refresh_visual_state()
		return report

	proc/audit_district_node_state(datum/controller/subsystem/faction_control/controller)
		var/list/report = list()
		if(!islist(GLOB.player_faction_district_nodes) || !length(GLOB.player_faction_district_nodes))
			report += "No player faction district nodes registered."
			return report
		for(var/obj/structure/player_faction_district_node/N in GLOB.player_faction_district_nodes)
			if(!N || QDELETED(N))
				continue
			var/d = N.district_id
			var/owner = (controller && d) ? controller.get_owner(d) : null
			var/state = N.node_state
			var/is_online = !!N.online
			var/linked = !!N.is_grid_linked()
			report += "node=[N] district=[d ? d : "unset"] owner=[owner ? owner : "none"] state=[state] online=[is_online ? "YES" : "NO"] grid_linked=[linked ? "YES" : "NO"]"
		return report

	proc/reconcile_player_faction_node_links(datum/controller/subsystem/faction_control/controller)
		if(!islist(GLOB.player_faction_district_nodes) || !length(GLOB.player_faction_district_nodes))
			return
		for(var/obj/structure/player_faction_district_node/N in GLOB.player_faction_district_nodes)
			if(!N || QDELETED(N))
				continue
			if(!N.online)
				continue
			var/linked = !!N.is_grid_linked()
			if(linked)
				continue
			N.handle_desync("grid linkage missing during reconciliation")
			log_game("Faction/Grid reconcile forced node offline: [N] district='[N.district_id]'.")
			if(SSblackbox)
				SSblackbox.record_feedback("nested tally", "district_grid_sync", 1, list("forced_offline", "desync"))
