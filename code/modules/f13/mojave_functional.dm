// Functional Mojave wrappers using existing Hail-Mary behavior.
// These are generic shells: set icon/icon_state in the map editor.

/obj/structure/chair/f13/mojave
	name = "chair"
	desc = "A pre-war chair."
	icon = 'mojave/icons/structure/chairs.dmi'
	icon_state = "chair"
	item_chair = null
	flags_1 = NODECONSTRUCT_1

/obj/structure/chair/f13/mojave/Initialize(mapload)
	. = ..()
	mojave_apply_chair_profile()

/obj/structure/chair/f13/mojave/proc/mojave_apply_chair_profile()
	var/state = lowertext("[icon_state]")
	if(findtext(state, "office_chair"))
		name = "office chair"
		desc = findtext(state, "broken") ? "Hardly spins." : "Still spins."
		return
	if(findtext(state, "captain_chair"))
		name = "captain's chair"
		desc = "Show everyone who is in charge."
		return
	if(findtext(state, "retro_chair"))
		name = "retro chair"
		desc = "With a fiberglass body, this chair harkens to a future that never came."
		return
	if(findtext(state, "armchair"))
		name = "armchair"
		desc = "A once plush velour accent piece, this chair's upholstery has faded."
		return
	if(findtext(state, "ergo_chair"))
		name = "ergonomic chair"
		desc = "Even in a nuclear wasteland, one should never neglect their back."
		anchored = FALSE
		return
	if(findtext(state, "barstool"))
		name = "bar stool"
		desc = "A bar stool. It's held up against time rather well."
		return
	if(findtext(state, "plastic_chair"))
		name = "plastic chair"
		desc = "The most generic chair known to pre-war man."
		return
	if(findtext(state, "wood_chair"))
		name = findtext(state, "padded") ? "padded wooden chair" : "wooden chair"
		desc = findtext(state, "padded") ? "An antique wooden chair with a large, plush red cushion." : "An antique wooden chair with a small green cushion."
		return
	if(findtext(state, "metal_chair") || findtext(state, "diner_chair") || findtext(state, "folding"))
		if(findtext(state, "broken"))
			name = "broken metal chair"
			desc = "A broken chair that is somehow more comfortable than a regular one."
		else if(findtext(state, "unfinished"))
			name = "unfinished metal chair"
			desc = "Without a backrest, this chair is essentially a stool with rods."
		else if(findtext(state, "folding"))
			name = "metal folding chair"
			desc = "Before the war, these were viewed as the lowest form of seat."
		else
			name = "metal chair"
			desc = "An uncomfortable chair."
		return

/obj/structure/bed/f13/mojave
	name = "bed"
	desc = "A pre-war bed."
	icon = 'mojave/icons/structure/beds.dmi'
	icon_state = "bed"
	flags_1 = NODECONSTRUCT_1

/obj/structure/bed/f13/mojave/Initialize(mapload)
	. = ..()
	mojave_apply_bed_profile()

/obj/structure/bed/f13/mojave/proc/mojave_apply_bed_profile()
	var/state = lowertext("[icon_state]")
	if(findtext(state, "surgery"))
		name = "surgery bed"
		desc = "More of a platform than a bed, this is an excellent boost to efficiency on operation."
		return
	if(findtext(state, "medical"))
		name = "medical bed"
		desc = "A stiff bed often found in medical locations."
		return
	if(findtext(state, "rollingbed"))
		name = "roller bed"
		desc = "A bed on wheels."
		return
	if(findtext(state, "dirty_mattress"))
		name = "dirty mattress"
		desc = "A stained mattress with questionable origins."
		return
	if(findtext(state, "mattress"))
		name = "mattress"
		desc = "A plain mattress."
		return
	if(findtext(state, "cot"))
		name = "cot"
		desc = "A simple military cot."
		return
	if(findtext(state, "wire_bed"))
		name = "wire bed"
		desc = "A bare wire bed frame."
		return
	if(findtext(state, "wood_bed"))
		name = "wooden bed"
		desc = "A sturdy wooden bed."
		return
	if(findtext(state, "metal_bed"))
		name = "metal bed"
		desc = "A durable pre-war metal bed."
		return

/obj/structure/bed/f13/mojave/medical
	name = "medical bed"
	desc = "A stiff bed often found in medical locations."
	icon = 'mojave/icons/structure/beds.dmi'
	icon_state = "bed_medical"
	density = TRUE

/obj/structure/bed/f13/mojave/medical/post_buckle_mob(mob/living/M)
	M.pixel_y = initial(M.pixel_y)

/obj/structure/bed/f13/mojave/medical/post_unbuckle_mob(mob/living/M)
	M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
	M.pixel_y = M.get_standard_pixel_y_offset(M.lying)

/obj/structure/bed/f13/mojave/medical/surgery
	name = "surgery bed"
	desc = "An elevated bed used for surgery."
	icon_state = "bed_surgery"

/obj/structure/bed/roller/f13/mojave
	name = "roller bed"
	icon = 'mojave/icons/structure/beds.dmi'
	icon_state = "rollingbed_down"
	flags_1 = NODECONSTRUCT_1

/obj/structure/bed/roller/f13/mojave/post_buckle_mob(mob/living/M)
	density = TRUE
	icon_state = "rollingbed_up"
	M.pixel_y = initial(M.pixel_y)

/obj/structure/bed/roller/f13/mojave/post_unbuckle_mob(mob/living/M)
	density = FALSE
	icon_state = "rollingbed_down"
	M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
	M.pixel_y = M.get_standard_pixel_y_offset(M.lying)

/obj/structure/table/rolling/f13/mojave
	name = "rolling table"
	desc = "A rolling table useful in medical and workshop environments."
	icon = 'mojave/icons/structure/standalone_tables.dmi'
	icon_state = "table_rolling"
	flags_1 = NODECONSTRUCT_1

/obj/structure/table/f13/mojave
	name = "table"
	desc = "A pre-war table."
	icon = 'mojave/icons/structure/standalone_tables.dmi'
	icon_state = "table"
	flags_1 = NODECONSTRUCT_1
	smooth = FALSE
	canSmoothWith = null

/obj/structure/table/f13/mojave/Initialize(mapload)
	. = ..()
	mojave_apply_table_profile()
	if(!mojave_bitmask && istext(icon_state))
		var/regex/R = regex("^low-[0-9]+$")
		if(R.Find(icon_state))
			mojave_bitmask = TRUE
			mojave_base_icon_state = "low"
			mojave_smooth_group = "mojave_low_wall"
			mojave_update_bitmask(src)

/obj/structure/table/f13/mojave/proc/mojave_apply_table_profile()
	var/state = lowertext("[icon_state]")
	if(findtext(state, "surgery"))
		name = "surgery table"
		desc = "An elevated operating table."
		return
	if(findtext(state, "operat"))
		name = "operating table"
		desc = "An old operating table."
		return
	if(findtext(state, "dice"))
		name = "dice table"
		desc = "Shoot the dice with your friends."
		return
	if(findtext(state, "desk"))
		name = findtext(state, "metal") ? "metal desk" : "wood desk"
		desc = "A full-size desk from before the war."
		return
	if(findtext(state, "rolling"))
		name = "rolling table"
		desc = "A rolling table useful in medical and workshop environments."
		return
	if(findtext(state, "wood"))
		name = "wood table"
		desc = "A simple wooden table."
		return
	if(findtext(state, "metal") || findtext(state, "table"))
		name = "metal table"
		desc = "A square piece of metal standing on four legs."
		return

/obj/machinery/f13/mojave_terminal
	name = "desktop terminal"
	desc = "A RobCo Industries terminal, widely available for commercial and private use before the war."
	icon = 'mojave/icons/structure/terminals.dmi'
	icon_state = "terminal"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/base_terminal_state = "terminal"
	var/screen_state = "terminal_screen"
	var/terminal_tag = "Home"
	var/system_name = "ROBCO50"
	var/active = TRUE
	var/broken = FALSE
	var/rigged = FALSE
	var/is_wall_terminal = FALSE
	var/flippable = FALSE

/obj/machinery/f13/mojave_terminal/Initialize(mapload)
	. = ..()
	mojave_apply_terminal_profile_from_state(icon_state)
	update_icon()

/obj/machinery/f13/mojave_terminal/proc/mojave_apply_terminal_profile_from_state(state)
	var/lower = lowertext("[state]")
	base_terminal_state = "terminal"
	screen_state = "terminal_screen"
	terminal_tag = "Home"
	system_name = "ROBCO50"
	active = TRUE
	broken = FALSE
	rigged = FALSE
	is_wall_terminal = FALSE
	flippable = FALSE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	pixel_y = 8
	pixel_x = 0
	light_color = LIGHT_COLOR_GREEN
	light_range = 1.5
	light_power = 0.6
	name = "desktop terminal"
	desc = "A RobCo Industries terminal, widely available for commercial and private use before the war."

	if(findtext(lower, "wallterminal") || findtext(lower, "terminal_classic"))
		is_wall_terminal = TRUE
		flippable = TRUE
		density = FALSE
		layer = OBJ_LAYER
		pixel_y = 0
		name = "wall mounted terminal"
		desc = "A RobCo Industries terminal. This one is mounted to a wall."
		screen_state = "wallterminal_screen"
		base_terminal_state = "wallterminal"
		active = FALSE

		if(findtext(lower, "wallterminal_new"))
			base_terminal_state = "wallterminal_new"
		else if(findtext(lower, "wallterminal_rusted"))
			base_terminal_state = "wallterminal_rusted"
		else if(findtext(lower, "terminal_classic"))
			base_terminal_state = "terminal_classic"
			screen_state = "terminal_classic_screen"
			light_color = LIGHT_COLOR_DARK_BLUE
			flippable = FALSE
			active = TRUE
			name = "classic terminal"
			desc = "A classic wall-mounted terminal from before the war."

		if(findtext(lower, "_down"))
			active = TRUE

		if(findtext(lower, "_ruined"))
			broken = TRUE
	else
		if(findtext(lower, "terminal_new"))
			base_terminal_state = "terminal_new"
		else if(findtext(lower, "terminal_rusted"))
			base_terminal_state = "terminal_rusted"
		else if(findtext(lower, "terminal_handmade"))
			base_terminal_state = "terminal_handmade"
			screen_state = "terminal_handmade_screen"
			name = "crafted terminal"
			desc = "A wastelander-built terminal that somehow still works."
		else if(findtext(lower, "terminal_vault"))
			base_terminal_state = "terminal_vault"
			screen_state = "terminal_vault_screen"
			name = "terminal stand"
			desc = "A heavy-duty Vault-Tec terminal stand."
			light_color = LIGHT_COLOR_DARK_BLUE
			terminal_tag = "vault"
			system_name = "ROBCO38"
		else if(findtext(lower, "terminal_security"))
			base_terminal_state = "terminal_security"
			screen_state = "terminal_security_screen"
			name = "security terminal"
			desc = "A hardened terminal with restricted controls."

		if(findtext(lower, "_screen"))
			active = TRUE
		if(findtext(lower, "_ruined"))
			broken = TRUE
		if(findtext(lower, "_rigged"))
			rigged = TRUE

	icon_state = base_terminal_state

/obj/machinery/f13/mojave_terminal/update_icon_state()
	if(broken)
		icon_state = "[base_terminal_state]_ruined"
		return
	if(rigged)
		icon_state = "[base_terminal_state]_rigged"
		return
	if(is_wall_terminal && flippable)
		icon_state = active ? "[base_terminal_state]_down" : base_terminal_state
		return
	icon_state = base_terminal_state

/obj/machinery/f13/mojave_terminal/update_overlays()
	. = ..()
	if(!active || broken || !screen_state)
		return
	. += image(icon, screen_state, ABOVE_OBJ_LAYER, dir)

/obj/machinery/f13/mojave_terminal/proc/mojave_terminal_ui(mob/user)
	if(!user)
		return
	var/list/lines = list()
	lines += "<b>[terminal_tag] Terminal</b>"
	lines += "System: [system_name]"
	lines += "Status: [broken ? "BROKEN" : (active ? "ONLINE" : "OFFLINE")]"
	if(rigged)
		lines += "Warning: tamper flags detected."
	var/html = "<html><body style='font-family:Courier New;background:#062113;color:#4aed92;margin:8px;'>[jointext(lines, "<br>")]</body></html>"
	var/datum/browser/popup = new(user, "mojave_terminal_[REF(src)]", name, 420, 260)
	popup.set_content(html)
	popup.open()

/obj/machinery/f13/mojave_terminal/attack_hand(mob/living/user)
	if(!active || broken)
		to_chat(user, span_warning("[src] does not respond."))
		return
	playsound(src, 'sound/machines/terminal_button01.ogg', 40, TRUE)
	mojave_terminal_ui(user)

/obj/machinery/f13/mojave_terminal/AltClick(mob/user)
	. = ..()
	if(!is_wall_terminal || !flippable || broken)
		return
	if(!user?.canUseTopic(src, BE_CLOSE))
		return
	active = !active
	playsound(src, active ? 'sound/machines/terminal_on.ogg' : 'sound/machines/terminal_off.ogg', 40, TRUE)
	update_icon()

/obj/structure/f13/mojave_lamp
	name = "table lamp"
	desc = "An old pre-war table lamp."
	icon = 'mojave/icons/structure/lamps.dmi'
	icon_state = "tablelamp"
	layer = BELOW_MOB_LAYER
	anchored = TRUE
	density = FALSE
	max_integrity = 125
	var/on = FALSE
	var/off_state = "tablelamp"
	var/on_state = "tablelamp_on"
	var/lamp_light_range = 4.5
	var/lamp_light_power = 1
	var/lamp_light_color = LIGHT_COLOR_TUNGSTEN

/obj/structure/f13/mojave_lamp/Initialize(mapload)
	. = ..()
	mojave_apply_lamp_profile_from_state(icon_state)
	update_icon()

/obj/structure/f13/mojave_lamp/proc/mojave_apply_lamp_profile_from_state(state)
	var/lower = lowertext("[state]")
	var/icon_path = lowertext("[icon]")
	on = FALSE
	off_state = state
	on_state = "[state]_on"
	lamp_light_range = 4.5
	lamp_light_power = 1
	lamp_light_color = LIGHT_COLOR_TUNGSTEN
	density = FALSE
	layer = BELOW_MOB_LAYER
	name = "table lamp"
	desc = "An old pre-war table lamp."

	if(findtext(lower, "_on"))
		on = TRUE
		off_state = replacetext(lower, "_on", "")
	else
		off_state = lower

	if(icon_path == "mojave/icons/structure/medical.dmi" || findtext(off_state, "medlamp"))
		off_state = "medlamp"
		on_state = "medlamp_on"
		name = "medical lamp"
		desc = "A once-sterile lamp used in medical areas."
		density = TRUE
		layer = OBJ_LAYER
		lamp_light_range = 4
		lamp_light_power = 2
		lamp_light_color = COLOR_WHITE
	else if(findtext(off_state, "handmadelamp"))
		off_state = "handmadelamp"
		on_state = "handmadelamp_on"
		name = "makeshift lamp"
		desc = "A rough lamp built from spare parts."
		lamp_light_range = 3.5
		lamp_light_power = 0.8
	else if(findtext(off_state, "tablelamp"))
		off_state = "tablelamp"
		on_state = "tablelamp_on"
		name = "table lamp"
		desc = "An old pre-war table lamp."
		lamp_light_range = 4.5
		lamp_light_power = 1
	else if(findtext(off_state, "lamp"))
		off_state = "lamp"
		on_state = "lamp_on"
		name = "mining lamp"
		desc = "Looks like an old mining lamp."
		lamp_light_range = 4.5
		lamp_light_power = 0.8

	icon_state = on ? on_state : off_state

/obj/structure/f13/mojave_lamp/update_icon_state()
	icon_state = on ? on_state : off_state

/obj/structure/f13/mojave_lamp/update_overlays()
	. = ..()

/obj/structure/f13/mojave_lamp/proc/mojave_refresh_light()
	set_light(lamp_light_range, on ? lamp_light_power : 0, lamp_light_color)

/obj/structure/f13/mojave_lamp/attack_hand(mob/living/user, list/modifiers)
	on = !on
	playsound(src, 'mojave/sound/ms13effects/buttonpush.ogg', 20, TRUE)
	update_icon()
	mojave_refresh_light()
	to_chat(user, span_notice("You switch [src] [on ? "on" : "off"]."))

/obj/machinery/light/f13/mojave
	icon = 'mojave/icons/structure/lighting.dmi'
	overlayicon = 'mojave/icons/structure/lighting_overlay.dmi'
	base_state = "light_tube"
	icon_state = "light_tube"
	name = "light fixture"
	desc = "A lighting fixture."
	brightness = 6
	bulb_power = 0.9
	bulb_colour = "#e9d8b2"
	fitting = "tube"
	start_with_cell = FALSE
	no_emergency = TRUE
	requires_wasteland_grid = FALSE
	var/mojave_requested_state = "light_tube"

/obj/machinery/light/f13/mojave/Initialize()
	mojave_requested_state = icon_state
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(mojave_apply_requested_state), mojave_requested_state), 5)
	mojave_apply_dir_offsets()

/obj/machinery/light/f13/mojave/setDir(newdir)
	. = ..()
	mojave_apply_dir_offsets()

/obj/machinery/light/f13/mojave/proc/mojave_apply_dir_offsets()
	pixel_x = 0
	pixel_y = 0
	switch(dir)
		if(SOUTH)
			pixel_y = -2
		if(NORTH)
			pixel_y = 35
		if(WEST)
			pixel_x = -16
			pixel_y = 16
		if(EAST)
			pixel_x = 16
			pixel_y = 16

/obj/machinery/light/f13/mojave/proc/mojave_apply_requested_state(requested_state)
	if(QDELETED(src))
		return
	var/lower = lowertext("[requested_state]")
	if(findtext(lower, "light_bulb_indust"))
		base_state = "light_bulb_indust"
		fitting = "bulb"
		brightness = 5
		bulb_power = 0.8
		bulb_colour = "#ddd2b9"
	else if(findtext(lower, "light_bulb"))
		base_state = "light_bulb"
		fitting = "bulb"
		brightness = 5
		bulb_power = 0.8
		bulb_colour = "#ddd2b9"
	else
		base_state = "light_tube"
		fitting = "tube"
		brightness = 6
		bulb_power = 0.9
		bulb_colour = "#e9d8b2"

	if(findtext(lower, "-broken"))
		status = LIGHT_BROKEN
	else if(findtext(lower, "-empty"))
		status = LIGHT_EMPTY
	else if(findtext(lower, "-burned"))
		status = LIGHT_BURNED
	else
		status = LIGHT_OK

	on = (status == LIGHT_OK)
	update(FALSE)

/obj/structure/f13/mojave_sandbag
	name = "sandbag"
	desc = "Stacked bags of material, designed to cover people from lead rain."
	icon = 'mojave/icons/structure/smooth_structures/sandbags.dmi'
	icon_state = "sandbags-0"
	density = TRUE
	anchored = TRUE
	max_integrity = 250
	proj_pass_rate = 35
	climbable = TRUE
	climb_stun = 0
	mojave_bitmask = TRUE
	mojave_base_icon_state = "sandbags"
	mojave_smooth_group = "mojave_sandbag"

/obj/structure/f13/mojave_sandbag/Initialize(mapload)
	. = ..()
	mojave_update_bitmask(src)

/obj/structure/f13/mojave_sandbag/Destroy()
	var/list/to_update = list()
	var/list/dirs = list(NORTH, EAST, SOUTH, WEST)
	for(var/d in dirs)
		var/turf/T = get_step(src, d)
		if(!T)
			continue
		for(var/atom/A in T)
			if(A.mojave_bitmask && mojave_groups_match(A))
				to_update += A
	. = ..()
	for(var/atom/A in to_update)
		if(QDELETED(A))
			continue
		mojave_update_bitmask(A)

/obj/structure/f13/mojave_sandbag/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/cloth(loc, 3)
	qdel(src)

/obj/structure/f13/mojave_sandbag/obstacle
	icon = 'mojave/icons/obstacles/obstacles.dmi'
	mojave_bitmask = FALSE
	mojave_base_icon_state = null
	mojave_smooth_group = null

/obj/structure/f13/mojave_sandbag/obstacle/single
	icon_state = "sandbag_single"

/obj/structure/f13/mojave_sandbag/obstacle/horizontal
	icon_state = "sandbag_horizontal"

/obj/item/bodybag/f13/mojave
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'mojave/icons/structure/medical.dmi'
	icon_state = "bodybag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/f13/mojave
	w_class = WEIGHT_CLASS_HUGE

/obj/structure/closet/body_bag/f13/mojave
	name = "body bag"
	desc = "An old body bag. Put your foe into these."
	icon = 'mojave/icons/structure/medical.dmi'
	icon_state = "bodybag"
	foldedbag_path = /obj/item/bodybag/f13/mojave
	anchored = FALSE
	material_drop = null
	mob_storage_capacity = 1
	drag_delay = 0.10 SECONDS

/obj/structure/closet/body_bag/f13/mojave/open
	icon_state = "bodybag_open"
	opened = TRUE
	density = FALSE

/obj/structure/closet/crate/f13/mojave
	name = "wasteland crate"
	desc = "Holds wastelands, presumably."
	icon = 'mojave/icons/structure/crates.dmi'
	icon_state = "vault_standard"
	drag_delay = 1 SECONDS
	max_integrity = 300
	anchored = TRUE
	var/mojave_pry_only = FALSE
	var/mojave_force_pry_only = FALSE
	var/mojave_has_open_state = FALSE
	var/mojave_closed_icon_state = null
	var/mojave_open_icon_state = null
	var/mojave_altstates = 0
	var/can_hold_padlock = TRUE
	var/obj/item/lock_construct/padlock = null
	var/mojave_spawn_locked_padlock = FALSE

/obj/structure/closet/crate/f13/mojave/verb_toggleopen()
	if(mojave_pry_only)
		return
	return ..()

/obj/structure/closet/crate/f13/mojave/Initialize(mapload)
	. = ..()
	mojave_closed_icon_state = icon_state
	mojave_apply_profile()
	if(mojave_altstates > 0 && !findtext(mojave_closed_icon_state, "-") && prob(35))
		mojave_closed_icon_state = "[mojave_closed_icon_state]-[rand(1, mojave_altstates)]"
		icon_state = mojave_closed_icon_state
	mojave_detect_open_state()
	if(mojave_force_pry_only || !mojave_has_open_state)
		mojave_pry_only = TRUE
	if(!padlock)
		for(var/obj/item/lock_construct/L in contents)
			padlock = L
			break
	if(mojave_spawn_locked_padlock)
		if(!padlock)
			padlock = new /obj/item/lock_construct(src)
		padlock.locked = TRUE
	mojave_sync_padlock_state()
	if(mojave_pry_only)
		integrity_failure = 0
	update_icon()

/obj/structure/closet/crate/f13/mojave/Destroy()
	if(padlock)
		padlock.forceMove(get_turf(src))
		padlock = null
	return ..()

/obj/structure/closet/crate/f13/mojave/proc/mojave_sync_padlock_state()
	if(padlock)
		locked = padlock.locked

/obj/structure/closet/crate/f13/mojave/proc/mojave_attach_padlock(obj/item/lock_construct/P, mob/living/user)
	if(!can_hold_padlock || !P)
		return FALSE
	if(padlock)
		if(user)
			to_chat(user, span_warning("[src] already has \a [padlock] attached."))
		return TRUE
	if(user)
		if(!user.transferItemToLoc(P, src))
			return TRUE
	padlock = P
	mojave_sync_padlock_state()
	if(user)
		user.visible_message(span_notice("[user] attaches [P] to [src]."), span_notice("You attach [P] to [src]."))
	return TRUE

/obj/structure/closet/crate/f13/mojave/proc/mojave_try_pry_padlock(obj/item/I, mob/living/user)
	if(!padlock)
		return FALSE
	if(padlock.pry_off(user, src))
		QDEL_NULL(padlock)
		locked = FALSE
	return TRUE

/obj/structure/closet/crate/f13/mojave/proc/mojave_try_lockpick(obj/item/lockpick_set/picking, mob/living/user)
	if(!istype(picking) || !padlock || !padlock.locked)
		return FALSE
	if(picking.in_use)
		return TRUE
	picking.in_use = TRUE
	user.visible_message(span_notice("[user] starts to pick [src]'s lock."), span_notice("You start picking [src]'s lock."), span_italic("You hear metal scraping."))
	playsound(get_turf(src), pick('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg'), 25, 1, ignore_walls = FALSE)
	if(!do_after(user, 4 SECONDS, target = src))
		user.show_message(span_alert(pick("Wrist slipped... try again...", "Almost got it...", "One more tumbler...", "Come on...")))
		picking.in_use = FALSE
		picking.use_pick(user)
		return TRUE
	if(prob(15))
		user.show_message(span_green(pick("Got it!", "Easy!", "Done!")))
		padlock.locked = FALSE
		locked = FALSE
	else
		user.show_message(span_alert(pick("Almost got it...", "One more tumbler...", "Come on...")))
	picking.in_use = FALSE
	picking.use_pick(user)
	return TRUE

/obj/structure/closet/crate/f13/mojave/proc/mojave_detect_open_state()
	mojave_has_open_state = FALSE
	mojave_open_icon_state = null
	var/list/states = icon_states(icon)
	if(!states || !mojave_closed_icon_state)
		return
	var/list/candidates = list("[mojave_closed_icon_state]open", "[mojave_closed_icon_state]_open", "[mojave_closed_icon_state]-open")
	var/regex/R = regex("^(.*)-[0-9]+$")
	if(R.Find(mojave_closed_icon_state))
		var/base = R.group[1]
		candidates += list("[base]open", "[base]_open", "[base]-open")
	for(var/state in candidates)
		if(state in states)
			mojave_open_icon_state = state
			mojave_has_open_state = TRUE
			return

/obj/structure/closet/crate/f13/mojave/proc/mojave_apply_profile()
	var/state = lowertext("[icon_state]")
	if(findtext(state, "wood_crate") || findtext(state, "plain_crate") || findtext(state, "3x_crate") || findtext(state, "sarsaparilla_crate") || findtext(state, "army_crate"))
		name = "\improper wooden crate"
		desc = "A wood storage crate, robust and study to all except a crowbar."
		mojave_force_pry_only = TRUE
		open_sound = 'sound/machines/door_open.ogg'
		close_sound = 'sound/machines/door_close.ogg'
		material_drop = /obj/item/stack/sheet/mineral/wood
		material_drop_amount = 2
		max_integrity = 500
		proj_pass_rate = 45
		mojave_altstates = 0
		if(findtext(state, "plain_crate") || findtext(state, "3x_crate") || findtext(state, "sarsaparilla_crate") || findtext(state, "army_crate"))
			anchored = FALSE
			max_integrity = 400
			proj_pass_rate = 70
		if(findtext(state, "plain_crate"))
			mojave_altstates = 3
		else if(findtext(state, "sarsaparilla_crate"))
			mojave_altstates = 1
		else if(findtext(state, "army_crate"))
			mojave_altstates = 2
		return
	if(state == "vault_standard")
		name = "\improper Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. Looks like it didn't handle life outside too well."
		proj_pass_rate = 70
		return
	if(state == "vault_standard_clean")
		name = "\improper Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life."
		proj_pass_rate = 70
		return
	if(state == "vault_compact")
		name = "compact Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. This one is fun-sized. Looks like it didn't handle life outside too well."
		proj_pass_rate = 85
		return
	if(state == "vault_compact_clean")
		name = "compact Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. This one is fun-sized."
		proj_pass_rate = 85
		return
	if(state == "vault_long")
		name = "long Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. This one is long, for extra storage. Looks like it didn't handle life outside too well."
		proj_pass_rate = 70
		return
	if(state == "vault_long_clean")
		name = "long Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. This one is long, for extra storage."
		proj_pass_rate = 70
		return
	if(state == "vault_big")
		name = "big Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. This one's got the Vault-Tec logo, in case you forgot who made it. Looks like it didn't handle life outside too well."
		proj_pass_rate = 70
		return
	if(state == "vault_big_clean")
		name = "big Vault-Tec crate"
		desc = "A crate designed for the rigours of vault life. This one's got the Vault-Tec logo, in case you forgot who made it."
		proj_pass_rate = 70
		return
	if(state == "footlocker_wood")
		name = "wooden footlocker"
		desc = "The best way to store various supplies."
		proj_pass_rate = 90
		return
	if(state == "enclave")
		name = "high-tech crate"
		desc = "Stores items, in style!"
		proj_pass_rate = 85
		return
	if(state == "register")
		name = "cash register"
		desc = "A busted up old cash register. It's almost as worthless as the cash inside it."
		anchored = TRUE
		proj_pass_rate = 50
		return
	if(state == "register_clean")
		name = "pristine cash register"
		desc = "A beautiful example of a cash register, seemingly untouched by the war. Shame the same can't be said about the economy."
		anchored = TRUE
		proj_pass_rate = 50
		return
	if(state == "army")
		name = "army crate"
		desc = "A crate used for transporting or storing goods. This one has army star drawn on it."
		proj_pass_rate = 85
		return
	if(state == "aluminum")
		name = "aluminum crate"
		desc = "A crate used for transporting or storing goods. This one is made of aluminum."
		proj_pass_rate = 85
		return
	if(state == "red")
		name = "red crate"
		desc = "A crate used for transporting or storing goods. This one is colored red."
		proj_pass_rate = 85
		return
	if(state == "vault")
		name = "vault crate"
		desc = "A crate used for transporting or storing goods. This one has vault logo on it."
		proj_pass_rate = 85
		return
	if(state == "medical")
		name = "medical locker"
		desc = "Useful for storing blood, organs, or just about whatever you could wish for. Has some handles and rollers under it for transporation, but is very bulky."
		anchored = FALSE
		proj_pass_rate = 60
		return
	if(state == "break-opens")
		name = "break-open crate"
		desc = "A tightly sealed crate that has to be pried apart."
		mojave_force_pry_only = TRUE
		proj_pass_rate = 45
		return
	if(state == "lock")
		name = "locked crate"
		desc = "A sealed crate with a heavy lock."
		mojave_spawn_locked_padlock = TRUE
		return

/obj/structure/closet/crate/f13/mojave/update_icon_state()
	if(mojave_pry_only)
		icon_state = mojave_closed_icon_state ? mojave_closed_icon_state : initial(icon_state)
		return
	if(opened)
		if(mojave_open_icon_state)
			icon_state = mojave_open_icon_state
		else
			icon_state = "[mojave_closed_icon_state]open"
	else
		icon_state = mojave_closed_icon_state ? mojave_closed_icon_state : initial(icon_state)

/obj/structure/closet/crate/f13/mojave/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(locked && padlock)
		to_chat(user, span_warning("The [src] is locked."))
		return
	if(mojave_pry_only)
		add_fingerprint(user)
		if(manifest)
			tear_manifest(user)
		return
	return ..()

/obj/structure/closet/crate/f13/mojave/examine(mob/user)
	. = ..()
	if(mojave_pry_only)
		. += span_notice("The [src] is tightly sealed, but you could use a <b>crowbar</b> or similar prying tool to <b>open</b> it.")
	if(padlock)
		. += span_notice("A [padlock] is attached. It is currently [padlock.locked ? "locked" : "unlocked"].")

/obj/structure/closet/crate/f13/mojave/tool_interact(obj/item/W, mob/user)
	if(istype(W, /obj/item/lock_construct) && can_hold_padlock)
		return mojave_attach_padlock(W, user)
	if(istype(W, /obj/item/key))
		if(!padlock)
			to_chat(user, span_warning("[src] has no lock attached."))
			return TRUE
		padlock.check_key(W, user)
		mojave_sync_padlock_state()
		return TRUE
	if(istype(W, /obj/item/lockpick_set))
		return mojave_try_lockpick(W, user)
	if(user.a_intent != INTENT_HARM && W.tool_behaviour == TOOL_CROWBAR && padlock)
		return mojave_try_pry_padlock(W, user)
	if(locked && padlock && user.a_intent != INTENT_HARM && !(W.item_flags & NOBLUDGEON))
		to_chat(user, span_warning("The [src] is locked."))
		return TRUE
	if(mojave_pry_only)
		if(W.tool_behaviour == TOOL_CROWBAR)
			user.visible_message(span_notice("[user] starts to break \the [src] open."), span_notice("You start to break \the [src] open."), span_italic("You hear splitting wood."))
			W.play_tool_sound(src)
			if(do_after(user, 10 SECONDS * W.toolspeed, target = src))
				playsound(src.loc, 'mojave/sound/ms13effects/wood_deconstruction.ogg', 50, TRUE)
				user.visible_message(span_notice("[user] pries \the [src] open."), span_notice("You pry open \the [src]."), span_italic("You hear splitting wood."))
				deconstruct(TRUE)
			return TRUE
		if(user.a_intent != INTENT_HARM && !(W.item_flags & NOBLUDGEON))
			to_chat(user, span_notice("The [src] is tightly sealed. You need a crowbar to open it."))
			return TRUE
	return ..()

/obj/structure/closet/crate/f13/mojave/deconstruct(disassembled = TRUE)
	if(!mojave_pry_only)
		return ..()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/stack/sheet/mineral/wood(loc, 2)
		else
			new /obj/item/stack/sheet/mineral/wood(loc, 1)
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)
	qdel(src)

/obj/structure/closet/f13/mojave_storage
	name = "storage"
	desc = "A storage container."
	icon = 'mojave/icons/structure/storage.dmi'
	icon_state = "lockers"
	anchored = TRUE
	var/mojave_closed_state = null
	var/mojave_open_state = null
	var/can_hold_padlock = TRUE
	var/obj/item/lock_construct/padlock = null

/obj/structure/closet/f13/mojave_storage/Initialize(mapload)
	. = ..()
	mojave_closed_state = icon_state
	mojave_recompute_profile()
	update_icon()

/obj/structure/closet/f13/mojave_storage/proc/mojave_recompute_profile()
	mojave_apply_storage_profile()
	if(!padlock)
		for(var/obj/item/lock_construct/L in contents)
			padlock = L
			break
	mojave_sync_padlock_state()
	if(!mojave_open_state)
		var/list/states = icon_states(icon)
		if(states && mojave_closed_state)
			var/list/candidates = list("[mojave_closed_state]_open", "[mojave_closed_state]open", "[mojave_closed_state]-open", "[mojave_closed_state]_door", "[mojave_closed_state]-door")
			for(var/state in candidates)
				if(state in states)
					mojave_open_state = state
					break

/obj/structure/closet/f13/mojave_storage/Destroy()
	if(padlock)
		padlock.forceMove(get_turf(src))
		padlock = null
	return ..()

/obj/structure/closet/f13/mojave_storage/proc/mojave_sync_padlock_state()
	if(padlock)
		locked = padlock.locked

/obj/structure/closet/f13/mojave_storage/proc/mojave_attach_padlock(obj/item/lock_construct/P, mob/living/user)
	if(!can_hold_padlock || !P)
		return FALSE
	if(padlock)
		if(user)
			to_chat(user, span_warning("[src] already has \a [padlock] attached."))
		return TRUE
	if(user)
		if(!user.transferItemToLoc(P, src))
			return TRUE
	padlock = P
	mojave_sync_padlock_state()
	if(user)
		user.visible_message(span_notice("[user] attaches [P] to [src]."), span_notice("You attach [P] to [src]."))
	return TRUE

/obj/structure/closet/f13/mojave_storage/proc/mojave_try_pry_padlock(obj/item/I, mob/living/user)
	if(!padlock)
		return FALSE
	if(padlock.pry_off(user, src))
		QDEL_NULL(padlock)
		locked = FALSE
	return TRUE

/obj/structure/closet/f13/mojave_storage/proc/mojave_try_lockpick(obj/item/lockpick_set/picking, mob/living/user)
	if(!istype(picking) || !padlock || !padlock.locked)
		return FALSE
	if(picking.in_use)
		return TRUE
	picking.in_use = TRUE
	user.visible_message(span_notice("[user] starts to pick [src]'s lock."), span_notice("You start picking [src]'s lock."), span_italic("You hear metal scraping."))
	playsound(get_turf(src), pick('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg'), 25, 1, ignore_walls = FALSE)
	if(!do_after(user, 4 SECONDS, target = src))
		user.show_message(span_alert(pick("Wrist slipped... try again...", "Almost got it...", "One more tumbler...", "Come on...")))
		picking.in_use = FALSE
		picking.use_pick(user)
		return TRUE
	if(prob(15))
		user.show_message(span_green(pick("Got it!", "Easy!", "Done!")))
		padlock.locked = FALSE
		locked = FALSE
	else
		user.show_message(span_alert(pick("Almost got it...", "One more tumbler...", "Come on...")))
	picking.in_use = FALSE
	picking.use_pick(user)
	return TRUE

/obj/structure/closet/f13/mojave_storage/proc/mojave_apply_storage_profile()
	var/state = lowertext("[icon_state]")
	if(findtext(state, "enclave"))
		name = "\improper Enclave locker"
		desc = "Used to hold various truly American things. No muties allowed!"
		return
	if(findtext(state, "filing_cabinet"))
		name = "filing cabinet"
		desc = "A metal filing cabinet for paper records."
		return
	if(findtext(state, "circabinet"))
		name = "cabinet"
		desc = "A rounded pre-war cabinet."
		return
	if(findtext(state, "fridge"))
		name = "refrigerator"
		desc = "A once powered refrigerator unit. Useful for keeping your food in one place."
		return
	if(findtext(state, "safe"))
		name = "safe"
		desc = "A bulky and secure safe. No possible way to move this thing alone, much too heavy."
		if(findtext(state, "safe_wall"))
			name = "wall safe"
			desc = "A safe that's been cemended into the wall. Good luck ever getting this thing out. The only option is to figure out a way to open it."
			pixel_y = 32
			density = FALSE
			wall_mounted = TRUE
		return
	if(findtext(state, "locker") || findtext(state, "lockers"))
		name = "metal locker"
		desc = "A large metal locker for all of your stuff."
		return
	if(findtext(state, "firstaid"))
		name = "emergency aid kit"
		desc = "A first aid kit, mounted to the wall. Commonly used for emergencies before the war."
		pixel_y = 32
		density = FALSE
		wall_mounted = TRUE
		anchored = TRUE
		anchorable = FALSE
		return
	if(findtext(state, "vent"))
		name = "vent"
		desc = "A vent used to move air to and from places."
		pixel_y = 24
		density = FALSE
		anchored = TRUE
		return
	if(findtext(state, "toolbox"))
		name = "toolbox"
		desc = "A sturdy toolbox."
		return
	if(findtext(state, "normwasher"))
		name = "washing machine"
		desc = "An old washing machine, before the war this did all the washing for you! But now it washes nothing."
		return
	if(findtext(state, "industwasher"))
		name = "industrial washing machine"
		desc = "A large washing machine, for when you need to wash a lot of clothes! Unfortunately, it's been broken for a long time."
		return
	if(name == initial(name) || name == "storage unit" || name == "storage")
		var/label = "[icon_state]"
		label = replacetext(label, "_", " ")
		label = replacetext(label, "-", " ")
		label = trim(label)
		if(length(label))
			name = capitalize(label)
	if(desc == initial(desc) || desc == "A storage unit." || desc == "A storage container.")
		desc = "A storage container recovered from Mojave stock."

/obj/structure/closet/f13/mojave_storage/update_icon()
	. = ..()
	if(opened)
		if(mojave_open_state)
			icon_state = mojave_open_state
		else
			icon_state = mojave_closed_state
	else
		icon_state = mojave_closed_state

/obj/structure/closet/f13/mojave_storage/update_overlays()
	return

/obj/structure/closet/f13/mojave_storage/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(locked && padlock)
		to_chat(user, span_warning("The [src] is locked."))
		return
	return ..()

/obj/structure/closet/f13/mojave_storage/examine(mob/user)
	. = ..()
	if(padlock)
		. += span_notice("A [padlock] is attached. It is currently [padlock.locked ? "locked" : "unlocked"].")

/obj/structure/closet/f13/mojave_storage/tool_interact(obj/item/W, mob/user)
	if(istype(W, /obj/item/lock_construct) && can_hold_padlock)
		return mojave_attach_padlock(W, user)
	if(istype(W, /obj/item/key))
		if(!padlock)
			to_chat(user, span_warning("[src] has no lock attached."))
			return TRUE
		padlock.check_key(W, user)
		mojave_sync_padlock_state()
		return TRUE
	if(istype(W, /obj/item/lockpick_set))
		return mojave_try_lockpick(W, user)
	if(user.a_intent != INTENT_HARM && W.tool_behaviour == TOOL_CROWBAR && padlock)
		return mojave_try_pry_padlock(W, user)
	if(locked && padlock && user.a_intent != INTENT_HARM && !(W.item_flags & NOBLUDGEON))
		to_chat(user, span_warning("The [src] is locked."))
		return TRUE
	return ..()

// Mojave Sun-style doors/shutters (functional)
/obj/machinery/door/unpowered/f13/mojave
	icon = 'mojave/icons/structure/doors.dmi'
	name = "door"
	desc = "A pre-war door, still barely functioning."
	pixel_x = -16
	pixel_y = -8
	layer = CLOSED_DOOR_LAYER
	closingLayer = CLOSED_DOOR_LAYER
	density = TRUE
	assemblytype = null
	max_integrity = 1150
	armor = ARMOR_VALUE_MEDIUM
	damage_deflection = 15
	safe = TRUE
	visible = TRUE
	var/door_type = null
	var/icon_state_closed = null
	var/icon_state_open = null
	var/has_damage_overlay = TRUE
	var/mirrored = FALSE
	var/mojave_open_sound = 'sound/machines/door_open.ogg'
	var/mojave_close_sound = 'sound/machines/door_close.ogg'
	var/locked_sound = 'mojave/sound/ms13effects/door_locked.ogg'
	var/can_hold_padlock = TRUE
	var/obj/item/lock_construct/padlock = null

/obj/machinery/door/unpowered/f13/mojave/proc/mojave_apply_dir_offsets()
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	switch(dir)
		if(NORTH)
			pixel_y = 8
		if(SOUTH)
			pixel_y = -8
		if(EAST)
			pixel_x = -3
			pixel_y = 16
		if(WEST)
			pixel_x = -28
			pixel_y = 16

/obj/machinery/door/unpowered/f13/mojave/Initialize()
	. = ..()
	mojave_apply_dir_offsets()
	if(!icon_state_closed)
		icon_state_closed = icon_state
	if(!icon_state_open && icon_state_closed)
		if(findtext(icon_state_closed, "_closed"))
			icon_state_open = replacetext(icon_state_closed, "_closed", "_open")
		else if(findtext(icon_state_closed, "-closed"))
			icon_state_open = replacetext(icon_state_closed, "-closed", "-open")
		else
			icon_state_open = "[icon_state_closed]_open"
	if(icon_state_open)
		var/list/states = icon_states(icon)
		if(states && !(icon_state_open in states))
			icon_state_open = null
	if(!door_type && icon_state_closed)
		var/tmp = icon_state_closed
		if(findtext(tmp, "_closed"))
			tmp = replacetext(tmp, "_closed", "")
		if(findtext(tmp, "-closed"))
			tmp = replacetext(tmp, "-closed", "")
		door_type = tmp
	if(door_type && findtext(lowertext(door_type), "mirrored"))
		mirrored = TRUE
	if(!padlock)
		for(var/obj/item/lock_construct/L in contents)
			padlock = L
			break
	mojave_sync_padlock_state()
	mojave_configure_visibility()
	mojave_set_identity()
	update_icon()

/obj/machinery/door/unpowered/f13/mojave/setDir(newdir)
	. = ..()
	mojave_apply_dir_offsets()
	update_icon()

/obj/machinery/door/unpowered/f13/mojave/Destroy()
	if(padlock)
		padlock.forceMove(get_turf(src))
		padlock = null
	return ..()

/obj/machinery/door/unpowered/f13/mojave/proc/mojave_sync_padlock_state()
	if(padlock)
		locked = padlock.locked

/obj/machinery/door/unpowered/f13/mojave/proc/mojave_attach_padlock(obj/item/lock_construct/P, mob/living/user)
	if(!can_hold_padlock || !P)
		return FALSE
	if(padlock)
		if(user)
			to_chat(user, span_warning("[src] already has \a [padlock] attached."))
		return TRUE
	if(user)
		if(!user.transferItemToLoc(P, src))
			return TRUE
	padlock = P
	mojave_sync_padlock_state()
	if(user)
		user.visible_message(span_notice("[user] attaches [P] to [src]."), span_notice("You attach [P] to [src]."))
	return TRUE

/obj/machinery/door/unpowered/f13/mojave/proc/mojave_try_pry_padlock(obj/item/I, mob/living/user)
	if(!padlock)
		return FALSE
	if(padlock.pry_off(user, src))
		QDEL_NULL(padlock)
		locked = FALSE
	return TRUE

/obj/machinery/door/unpowered/f13/mojave/proc/mojave_configure_visibility()
	if(!door_type)
		return
	var/lower = lowertext(door_type)
	if(findtext(lower, "window") || findtext(lower, "grate") || findtext(lower, "bar") || findtext(lower, "wirefence") || findtext(lower, "barbfence"))
		visible = FALSE
		opacity = FALSE
		glass = TRUE
		if(findtext(lower, "window"))
			proj_pass_rate = 40
		else
			proj_pass_rate = 80

/obj/machinery/door/unpowered/f13/mojave/proc/mojave_set_identity()
	if(!door_type)
		return
	var/lower = lowertext(door_type)
	if(findtext(lower, "wirefence") || findtext(lower, "barbfence"))
		name = "fence door"
		desc = "A crude fence gate."
	else if(findtext(lower, "bar") || findtext(lower, "grate"))
		name = "barred door"
		desc = "A heavy barred door."
	else if(findtext(lower, "window"))
		name = "windowed door"
		desc = "A door with a reinforced window."
	else if(findtext(lower, "wood"))
		name = "wood door"
		desc = "A sturdy wooden door."
	else
		name = "metal door"
		desc = "A pre-war metal door."

/obj/machinery/door/unpowered/f13/mojave/update_icon_state()
	if(density)
		if(icon_state_closed)
			icon_state = icon_state_closed
		else if(door_type)
			icon_state = "[door_type]_closed"
	else
		if(icon_state_open)
			icon_state = icon_state_open
		else if(icon_state_closed)
			icon_state = icon_state_closed
		else if(door_type)
			icon_state = "[door_type]_open"

/obj/machinery/door/unpowered/f13/mojave/do_animate(animation)
	switch(animation)
		if("opening")
			if(door_type)
				flick("[door_type]_opening", src)
			playsound(src, mojave_open_sound, 40, 1)
		if("closing")
			if(door_type)
				flick("[door_type]_closing", src)
			playsound(src, mojave_close_sound, 40, 1)

/obj/machinery/door/unpowered/f13/mojave/update_overlays()
	. = ..()
	cut_overlays()
	if(!has_damage_overlay || !density)
		return
	var/state = null
	if(obj_integrity < (0.25 * max_integrity))
		state = "damage_closed_3"
	else if(obj_integrity < (0.50 * max_integrity))
		state = "damage_closed_2"
	else if(obj_integrity < (0.75 * max_integrity))
		state = "damage_closed_1"
	if(!state)
		return
	var/px = 0
	var/py = 0
	switch(dir)
		if(EAST)
			px = mirrored ? 17 : -17
			py = -2
		if(WEST)
			px = mirrored ? -17 : 17
			py = -2
		if(NORTH)
			py = -8
		if(SOUTH)
			py = 0
	add_overlay(image(icon, icon_state = state, layer = FLOAT_LAYER, pixel_x = px, pixel_y = py))

/obj/machinery/door/unpowered/f13/mojave/attack_hand(mob/living/M)
	if(locked)
		to_chat(M, span_warning("The [name] is locked."))
		playsound(src, locked_sound, 50, TRUE)
		return
	add_fingerprint(M)
	return try_to_activate_door(M)

/obj/machinery/door/unpowered/f13/mojave/attackby(obj/item/I, mob/living/M, params)
	if(istype(I, /obj/item/lock_construct))
		return mojave_attach_padlock(I, M)
	if(istype(I, /obj/item/key))
		if(!padlock)
			to_chat(M, span_warning("[src] has no lock attached."))
			return
		padlock.check_key(I, M)
		mojave_sync_padlock_state()
		return
	if(M.a_intent != INTENT_HARM && I.tool_behaviour == TOOL_CROWBAR && padlock)
		return mojave_try_pry_padlock(I, M)
	if(istype(I, /obj/item/lockpick_set) && padlock && padlock.locked)
		if(try_to_lockpick(I, M))
			padlock.locked = FALSE
			locked = FALSE
		return
	if(locked && M.a_intent != INTENT_HARM)
		to_chat(M, span_warning("The [name] is locked."))
		playsound(src, locked_sound, 50, TRUE)
		return
	if(!(I.item_flags & NOBLUDGEON) && M.a_intent != INTENT_HARM)
		add_fingerprint(M)
		return try_to_activate_door(M)
	return ..()

/obj/machinery/door/unpowered/f13/mojave/Bumped(atom/movable/AM)
	if(locked)
		return
	return ..()

/obj/machinery/door/poddoor/shutters/f13/mojave
	name = "mechanical shutters"
	desc = "Mechanical pre-war shutters, somewhat still functional."
	icon = 'mojave/icons/structure/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	max_integrity = 800
	var/icon_plane
	var/icon_direction
	var/color_type
	var/pre_open = FALSE
	var/icon_state_closed = null
	var/icon_state_open = null
	var/can_hold_padlock = TRUE
	var/obj/item/lock_construct/padlock = null
	var/locked_sound = 'mojave/sound/ms13effects/door_locked.ogg'

/obj/machinery/door/poddoor/shutters/f13/mojave/Initialize()
	. = ..()
	if(!icon_state_closed)
		icon_state_closed = icon_state
	if(!icon_state_open && icon_state_closed)
		icon_state_open = replacetext(icon_state_closed, "closed-", "open-")
	if(!padlock)
		for(var/obj/item/lock_construct/L in contents)
			padlock = L
			break
	mojave_sync_padlock_state()
	mojave_parse_state()
	update_icon()
	if(pre_open)
		density = FALSE
		opacity = FALSE

/obj/machinery/door/poddoor/shutters/f13/mojave/setDir(newdir)
	. = ..()
	mojave_parse_state()
	update_icon()

/obj/machinery/door/poddoor/shutters/f13/mojave/Destroy()
	if(padlock)
		padlock.forceMove(get_turf(src))
		padlock = null
	return ..()

/obj/machinery/door/poddoor/shutters/f13/mojave/proc/mojave_sync_padlock_state()
	if(padlock)
		locked = padlock.locked

/obj/machinery/door/poddoor/shutters/f13/mojave/proc/mojave_attach_padlock(obj/item/lock_construct/P, mob/living/user)
	if(!can_hold_padlock || !P)
		return FALSE
	if(padlock)
		if(user)
			to_chat(user, span_warning("[src] already has \a [padlock] attached."))
		return TRUE
	if(user)
		if(!user.transferItemToLoc(P, src))
			return TRUE
	padlock = P
	mojave_sync_padlock_state()
	if(user)
		user.visible_message(span_notice("[user] attaches [P] to [src]."), span_notice("You attach [P] to [src]."))
	return TRUE

/obj/machinery/door/poddoor/shutters/f13/mojave/proc/mojave_try_pry_padlock(obj/item/I, mob/living/user)
	if(!padlock)
		return FALSE
	if(padlock.pry_off(user, src))
		QDEL_NULL(padlock)
		locked = FALSE
	return TRUE

/obj/machinery/door/poddoor/shutters/f13/mojave/proc/mojave_parse_state()
	if(!icon_state_closed)
		return
	var/list/parts = splittext(icon_state_closed, "-")
	if(length(parts) >= 4)
		icon_direction = parts[2]
		icon_plane = parts[3]
		color_type = parts[4]
	if(icon_plane == "vertical")
		pixel_y = 16
	else
		pixel_y = 0

/obj/machinery/door/poddoor/shutters/f13/mojave/update_icon_state()
	..()
	if(density)
		if(icon_direction && icon_plane && color_type)
			icon_state = "closed-[icon_direction]-[icon_plane]-[color_type]"
		else if(icon_state_closed)
			icon_state = icon_state_closed
	else
		if(icon_direction && icon_plane && color_type)
			icon_state = "open-[icon_direction]-[icon_plane]-[color_type]"
		else if(icon_state_open)
			icon_state = icon_state_open

/obj/machinery/door/poddoor/shutters/f13/mojave/do_animate(animation)
	switch(animation)
		if("opening")
			if(icon_direction && icon_plane && color_type)
				flick("opening-[icon_direction]-[icon_plane]-[color_type]", src)
			playsound(src, 'mojave/sound/ms13effects/garage_open.ogg', 30, TRUE)
		if("closing")
			if(icon_direction && icon_plane && color_type)
				flick("closing-[icon_direction]-[icon_plane]-[color_type]", src)
			playsound(src, 'mojave/sound/ms13effects/garage_close.ogg', 30, TRUE)

/obj/machinery/door/poddoor/shutters/f13/mojave/attack_hand(mob/living/user)
	if(locked)
		to_chat(user, span_warning("The [name] is locked."))
		playsound(src, locked_sound, 50, TRUE)
		return
	return ..()

/obj/machinery/door/poddoor/shutters/f13/mojave/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/lock_construct))
		return mojave_attach_padlock(I, user)
	if(istype(I, /obj/item/key))
		if(!padlock)
			to_chat(user, span_warning("[src] has no lock attached."))
			return
		padlock.check_key(I, user)
		mojave_sync_padlock_state()
		return
	if(user.a_intent != INTENT_HARM && I.tool_behaviour == TOOL_CROWBAR && padlock)
		return mojave_try_pry_padlock(I, user)
	if(istype(I, /obj/item/lockpick_set) && padlock && padlock.locked)
		if(try_to_lockpick(I, user))
			padlock.locked = FALSE
			locked = FALSE
		return
	if(locked && user.a_intent != INTENT_HARM)
		to_chat(user, span_warning("The [name] is locked."))
		playsound(src, locked_sound, 50, TRUE)
		return
	if(user.a_intent != INTENT_HARM && !(I.item_flags & NOBLUDGEON))
		return attack_hand(user)
	return ..()

/obj/machinery/door/poddoor/shutters/f13/mojave/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return

/obj/structure/f13/mojave_toggle_door
	parent_type = /obj/machinery/door/unpowered/f13/mojave
	name = "door"
	desc = "A pre-war door."
	icon = 'mojave/icons/structure/doors.dmi'
	icon_state = "metal_closed"
	icon_state_closed = "metal_closed"
	icon_state_open = "metal_open"

/obj/structure/f13/mojave_toggle_shutter
	parent_type = /obj/machinery/door/poddoor/shutters/f13/mojave
	name = "mojave shutter"
	desc = "A Mojave shutter."
	icon = 'mojave/icons/structure/shutters.dmi'
	icon_state = "closed-solo-horizon-red"
	icon_state_closed = "closed-solo-horizon-red"
	icon_state_open = "open-solo-horizon-red"
