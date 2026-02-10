/client/proc/cmd_grid_snapshot()
	set category = "Admin.Game"
	set name = "Grid: Snapshot"

	if(!check_rights(R_ADMIN))
		return
	_wasteland_grid_bootstrap()

	if(mob)
		to_chat(mob, span_notice("=== Wasteland Grid Snapshot ==="))
		to_chat(mob, span_notice("Online: [GLOB.wasteland_grid_online ? "YES" : "NO"]  State: [GLOB.wasteland_grid_state]"))
		to_chat(mob, span_notice("Fuel: [round(GLOB.wasteland_grid_fuel)]  Coolant: [round(GLOB.wasteland_grid_coolant)]  Output MW: [round(GLOB.grid_output)]"))
		to_chat(mob, span_notice("Heat: [round(GLOB.wasteland_grid_core_heat)]  Containment: [round(GLOB.wasteland_grid_containment)]  Integrity: [round(GLOB.wasteland_grid_integrity)]  BG Rads: [round(GLOB.wasteland_grid_background_rads, 0.1)]"))
		to_chat(mob, span_notice("Faults: [length(GLOB.wasteland_grid_faults)]"))

/client/proc/cmd_grid_set_online()
	set category = "Admin.Game"
	set name = "Grid: Set Online/Offline"

	if(!check_rights(R_ADMIN))
		return
	_wasteland_grid_bootstrap()

	var/choice = input(src, "Set grid to:", "Wasteland Grid", GLOB.wasteland_grid_online ? "Online" : "Offline") as null|anything in list("Online", "Offline")
	if(!choice)
		return

	var/new_state = (choice == "Online")
	set_wasteland_grid_online(new_state)
	log_admin("[key_name(src)] set wasteland grid [new_state ? "ONLINE" : "OFFLINE"].")
	message_admins(span_adminnotice("[key_name_admin(src)] set wasteland grid [new_state ? "ONLINE" : "OFFLINE"]."))

/client/proc/cmd_grid_adjust_resources()
	set category = "Admin.Game"
	set name = "Grid: Adjust Fuel/Coolant"

	if(!check_rights(R_ADMIN))
		return
	_wasteland_grid_bootstrap()

	var/metric = input(src, "Adjust which resource?", "Wasteland Grid", "Fuel") as null|anything in list("Fuel", "Coolant")
	if(!metric)
		return
	var/current = (metric == "Fuel") ? GLOB.wasteland_grid_fuel : GLOB.wasteland_grid_coolant
	var/new_value = input(src, "Set [metric] (0..200). Current: [round(current)]", "Wasteland Grid", round(current)) as null|num
	if(isnull(new_value))
		return
	new_value = clamp(round(new_value), 0, 200)

	if(metric == "Fuel")
		GLOB.wasteland_grid_fuel = new_value
	else
		GLOB.wasteland_grid_coolant = new_value
	_recalc_wasteland_grid_state()
	_sync_wasteland_grid_reactor()

	log_admin("[key_name(src)] set grid [lowertext(metric)] to [new_value].")
	message_admins(span_adminnotice("[key_name_admin(src)] set grid [lowertext(metric)] to [new_value]."))

/client/proc/cmd_grid_set_district_power()
	set category = "Admin.Game"
	set name = "Grid: Force District Power"

	if(!check_rights(R_ADMIN))
		return
	_wasteland_grid_bootstrap_districts()

	var/list/districts = list()
	if(SSfaction_control && islist(SSfaction_control.district_income))
		for(var/d in SSfaction_control.district_income)
			districts += "[d]"
	if(!length(districts))
		for(var/d in GLOB.wasteland_grid_district_off_until)
			districts += "[d]"
		for(var/d in GLOB.wasteland_grid_district_forced_off)
			if(!(d in districts))
				districts += "[d]"
	if(!length(districts))
		if(mob)
			to_chat(mob, span_warning("No districts found. Ensure district controllers are initialized."))
		return

	var/district = input(src, "Select district:", "Wasteland Grid") as null|anything in districts
	if(!district)
		return
	var/mode = input(src, "Power mode for [district]:", "Wasteland Grid", "Normal") as null|anything in list("Normal", "Forced OFF", "Timed OFF")
	if(!mode)
		return

	switch(mode)
		if("Normal")
			_grid_set_district_forced(district, FALSE)
		if("Forced OFF")
			_grid_set_district_forced(district, TRUE)
		if("Timed OFF")
			var/seconds = input(src, "Seconds to keep [district] off:", "Wasteland Grid", 300) as null|num
			if(isnull(seconds))
				return
			seconds = max(1, round(seconds))
			_grid_set_district_off(district, seconds * 10)

	_grid_reconcile_district_power()
	log_admin("[key_name(src)] set district [district] grid mode to [mode].")
	message_admins(span_adminnotice("[key_name_admin(src)] set district [district] grid mode to [mode]."))

/client/proc/cmd_grid_rebuild_district_bindings()
	set category = "Admin.Game"
	set name = "Grid: Rebuild District->Grid Bindings"

	if(!check_rights(R_ADMIN))
		return
	if(!SSfaction_control || !hascall(SSfaction_control, "rebuild_district_to_grid_bindings"))
		if(mob)
			to_chat(mob, span_warning("Faction control subsystem is unavailable."))
		return

	var/list/report = call(SSfaction_control, "rebuild_district_to_grid_bindings")()
	if(mob)
		to_chat(mob, span_notice("=== District->Grid Rebuild ==="))
		if(!length(report))
			to_chat(mob, span_warning("No districts were rebuilt."))
		else
			for(var/line in report)
				to_chat(mob, span_notice("[line]"))
	log_admin("[key_name(src)] triggered district->grid binding rebuild.")
	message_admins(span_adminnotice("[key_name_admin(src)] triggered district->grid binding rebuild."))

/client/proc/cmd_grid_audit_district_nodes()
	set category = "Admin.Game"
	set name = "Grid: Audit District Node State"

	if(!check_rights(R_ADMIN))
		return
	if(!SSfaction_control || !hascall(SSfaction_control, "audit_district_node_state"))
		if(mob)
			to_chat(mob, span_warning("Faction control subsystem is unavailable."))
		return

	var/list/report = call(SSfaction_control, "audit_district_node_state")()
	if(mob)
		to_chat(mob, span_notice("=== District Node Audit ==="))
		if(!length(report))
			to_chat(mob, span_warning("No district nodes found."))
		else
			for(var/line in report)
				to_chat(mob, span_notice("[line]"))
