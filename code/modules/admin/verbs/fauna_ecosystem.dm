/client/proc/cmd_fauna_debug_toggle()
	set category = "Admin.Game"
	set name = "Fauna: Toggle Debug Logging"

	if(!check_rights(R_ADMIN))
		return
	if(!SSfauna_ecosystem)
		if(mob)
			to_chat(mob, span_warning("Fauna ecosystem subsystem unavailable."))
		return

	SSfauna_ecosystem.debug_logging = !SSfauna_ecosystem.debug_logging
	if(mob)
		to_chat(mob, span_notice("Fauna debug logging: [SSfauna_ecosystem.debug_logging ? "ON" : "OFF"]."))

/client/proc/cmd_fauna_snapshot()
	set category = "Admin.Game"
	set name = "Fauna: Ecosystem Snapshot"

	if(!check_rights(R_ADMIN))
		return
	if(!SSfauna_ecosystem)
		if(mob)
			to_chat(mob, span_warning("Fauna ecosystem subsystem unavailable."))
		return

	if(mob)
		to_chat(mob, span_notice(SSfauna_ecosystem.fauna_debug_summary()))

	var/list/habitats = list("wasteland", "cave", "building", "other")
	for(var/z in 1 to world.maxz)
		for(var/habitat in habitats)
			var/key = SSfauna_ecosystem.zone_key(z, habitat)
			var/food = round(SSfauna_ecosystem.zone_food[key] || 0, 0.1)
			var/pressure = round(SSfauna_ecosystem.zone_player_pressure[key] || 0, 0.1)
			var/hunting = round(SSfauna_ecosystem.zone_hunting_pressure[key] || 0, 0.1)
			var/carrion = round(SSfauna_ecosystem.zone_carrion_level[key] || 0, 0.1)
			var/danger = round(SSfauna_ecosystem.zone_danger_memory[key] || 0, 0.1)
			if(food <= 0 && pressure <= 0 && hunting <= 0 && carrion <= 0 && danger <= 0)
				continue
			if(mob)
				to_chat(mob, span_notice("z[z] [habitat]: food=[food] pressure=[pressure] hunting=[hunting] carrion=[carrion] danger=[danger]"))

/client/proc/cmd_fauna_set_tuning()
	set category = "Admin.Game"
	set name = "Fauna: Set Runtime Tuning"

	if(!check_rights(R_ADMIN))
		return
	if(!SSfauna_ecosystem)
		if(mob)
			to_chat(mob, span_warning("Fauna ecosystem subsystem unavailable."))
		return

	var/list/options = list(
		"virtual_tick_multiplier",
		"materialize_multiplier",
		"hunting_impact_multiplier",
		"carrion_attract_multiplier"
	)
	var/choice = input(src, "Choose tuning variable to change.", "Fauna Tuning") as null|anything in options
	if(!choice)
		return

	var/current = SSfauna_ecosystem.vars[choice]
	var/new_value = input(src, "Set [choice] (current [current]).", "Fauna Tuning", current) as null|num
	if(isnull(new_value))
		return

	new_value = clamp(new_value, 0.1, 5)
	SSfauna_ecosystem.vars[choice] = new_value
	if(mob)
		to_chat(mob, span_notice("Set [choice] to [new_value]."))
	log_admin("[key_name(src)] set fauna tuning [choice] to [new_value].")
	message_admins(span_adminnotice("[key_name_admin(src)] set fauna tuning [choice] to [new_value]."))

/client/proc/cmd_fauna_adjust_zone_state()
	set category = "Admin.Game"
	set name = "Fauna: Adjust Zone State"

	if(!check_rights(R_ADMIN))
		return
	if(!SSfauna_ecosystem)
		if(mob)
			to_chat(mob, span_warning("Fauna ecosystem subsystem unavailable."))
		return

	var/z = input(src, "Z level", "Fauna Zone", 1) as null|num
	if(isnull(z))
		return
	z = clamp(round(z), 1, world.maxz)

	var/list/habitats = list("wasteland", "cave", "building", "other")
	var/habitat = input(src, "Habitat", "Fauna Zone") as null|anything in habitats
	if(!habitat)
		return

	var/list/metrics = list("food", "pressure", "hunting", "carrion", "danger")
	var/metric = input(src, "Metric", "Fauna Zone") as null|anything in metrics
	if(!metric)
		return

	var/key = SSfauna_ecosystem.zone_key(z, habitat)
	SSfauna_ecosystem.ensure_zone_state(z, habitat)
	var/current
	if(metric == "food")
		current = SSfauna_ecosystem.zone_food[key]
	else if(metric == "pressure")
		current = SSfauna_ecosystem.zone_player_pressure[key]
	else if(metric == "hunting")
		current = SSfauna_ecosystem.zone_hunting_pressure[key]
	else if(metric == "danger")
		current = SSfauna_ecosystem.zone_danger_memory[key]
	else
		current = SSfauna_ecosystem.zone_carrion_level[key]

	var/new_value = input(src, "Set [metric] (current [current]).", "Fauna Zone", current) as null|num
	if(isnull(new_value))
		return
	new_value = clamp(new_value, 0, 100)

	if(metric == "food")
		SSfauna_ecosystem.zone_food[key] = new_value
	else if(metric == "pressure")
		SSfauna_ecosystem.zone_player_pressure[key] = new_value
	else if(metric == "hunting")
		SSfauna_ecosystem.zone_hunting_pressure[key] = new_value
	else if(metric == "danger")
		SSfauna_ecosystem.zone_danger_memory[key] = new_value
	else
		SSfauna_ecosystem.zone_carrion_level[key] = new_value

	if(mob)
		to_chat(mob, span_notice("Set z[z] [habitat] [metric] to [new_value]."))
	log_admin("[key_name(src)] set fauna zone z[z] [habitat] [metric] to [new_value].")
	message_admins(span_adminnotice("[key_name_admin(src)] set fauna zone z[z] [habitat] [metric] to [new_value]."))
