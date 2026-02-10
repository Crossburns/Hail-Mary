// =============================================================================
// PLAYER FACTION SYSTEM
// Allows wastelanders and outlaws to create their own factions,
// claim territory, and build faction infrastructure.
// =============================================================================

GLOBAL_LIST_EMPTY(player_factions)
GLOBAL_LIST_EMPTY(claimed_areas_by_faction)
GLOBAL_LIST_EMPTY(player_faction_district_nodes)

#define MAX_FACTION_NAME_LENGTH 32
#define MIN_FACTION_NAME_LENGTH 3
#define FACTION_CLAIM_COOLDOWN 5 MINUTES
#define FACTION_CREATION_COST 5000 // caps
#define PLAYER_FACTION_NODE_OFFLINE "offline"
#define PLAYER_FACTION_NODE_SYNCING "syncing"
#define PLAYER_FACTION_NODE_ONLINE "online"
#define PLAYER_FACTION_NODE_ERROR "error"
#define PLAYER_FACTION_NODE_CONTESTED "contested"

// =============================================================================
// PLAYER FACTION DATUM
// =============================================================================

/datum/player_faction
	/// Unique ID for this faction
	var/id
	/// Display name
	var/name = "Unnamed Faction"
	/// Short tag (3-5 chars) for territory marking
	var/faction_tag = "UNK"
	/// Description set by founder
	var/desc = "A wasteland faction."
	/// Founder's ckey
	var/founder_ckey
	/// Founder's character name
	var/founder_name
	/// List of member ckeys
	var/list/members = list()
	/// List of officer ckeys (can claim territory)
	var/list/officers = list()
	/// List of claimed area types
	var/list/claimed_areas = list()
	/// The faction's territory area
	var/area/player_faction_territory/territory_area = null
	/// Has built their district node?
	var/has_district_node = FALSE
	/// Has built their control console?
	var/has_control_console = FALSE
	/// Creation timestamp
	var/created_at
	/// Faction color (for map display)
	var/faction_color = "#888888"
	/// Caps in faction treasury
	var/treasury = 0
	/// Last territory claim time
	var/last_claim_time = 0
	/// District id used for grid integration
	var/district_id = null

/datum/player_faction/New(founder_ckey, faction_name, input_tag)
	..()
	id = "faction_[rand(10000, 99999)]_[world.time]"
	name = faction_name
	faction_tag = uppertext(input_tag)
	src.founder_ckey = founder_ckey
	founder_name = "Unknown"
	created_at = world.time
	members += founder_ckey
	officers += founder_ckey
	GLOB.player_factions += src

/datum/player_faction/Destroy()
	// Release all claimed areas
	for(var/area/A in claimed_areas)
		release_area(A)
	GLOB.player_factions -= src
	return ..()

/datum/player_faction/proc/is_member(ckey)
	return (ckey in members)

/datum/player_faction/proc/is_officer(ckey)
	return (ckey in officers)

/datum/player_faction/proc/is_founder(ckey)
	return (ckey == founder_ckey)

/datum/player_faction/proc/add_member(ckey)
	if(ckey in members)
		return FALSE
	members += ckey
	return TRUE

/datum/player_faction/proc/remove_member(ckey)
	if(ckey == founder_ckey)
		return FALSE // Can't remove founder
	members -= ckey
	officers -= ckey
	return TRUE

/datum/player_faction/proc/promote_officer(ckey)
	if(!(ckey in members))
		return FALSE
	if(ckey in officers)
		return FALSE
	officers += ckey
	return TRUE

/datum/player_faction/proc/demote_officer(ckey)
	if(ckey == founder_ckey)
		return FALSE
	officers -= ckey
	return TRUE

/datum/player_faction/proc/can_claim_territory(mob/user)
	if(!user || !user.ckey)
		return FALSE
	if(!is_officer(user.ckey))
		return FALSE
	// Only enforce cooldown after at least one successful claim.
	if(last_claim_time > 0 && world.time < last_claim_time + FACTION_CLAIM_COOLDOWN)
		return FALSE
	return TRUE

/datum/player_faction/proc/claim_area(area/A, mob/user)
	if(!A || !user)
		return FALSE
	if(!can_claim_territory(user))
		return FALSE

	// Check if area is already claimed
	for(var/datum/player_faction/F in GLOB.player_factions)
		if(A in F.claimed_areas)
			return FALSE

	// Check if it's a protected area (main faction bases, etc)
	if(is_protected_area(A))
		return FALSE

	claimed_areas += A
	GLOB.claimed_areas_by_faction[A] = src
	last_claim_time = world.time

	// Update area name to show ownership
	var/original_name = A.name
	A.name = "[faction_tag] Territory - [original_name]"

	// Announce claim
	_announce_faction_claim(user, A, original_name)

	return TRUE

/datum/player_faction/proc/release_area(area/A)
	if(!(A in claimed_areas))
		return FALSE

	claimed_areas -= A
	GLOB.claimed_areas_by_faction -= A

	// Restore original name (strip our prefix)
	var/tag_prefix = "[faction_tag] Territory - "
	if(findtext(A.name, tag_prefix) == 1)
		A.name = copytext(A.name, length(tag_prefix) + 1)
	else if(istype(A, /area/player_faction_territory))
		A.name = initial(A.name)

	return TRUE

/datum/player_faction/proc/is_protected_area(area/A)
	if(!A)
		return TRUE

	// Protect main faction areas
	var/area_name = lowertext(A.name)
	var/list/protected_keywords = list(
		"ncr", "legion", "brotherhood", "bos", "enclave",
		"vault", "spawn", "ooc", "admin", "centcom",
		"reactor", "mass fusion", "grid"
	)

	for(var/keyword in protected_keywords)
		if(findtext(area_name, keyword))
			return TRUE

	return FALSE

/datum/player_faction/proc/get_member_count()
	return length(members)

/datum/player_faction/proc/get_territory_count()
	return length(claimed_areas)

/datum/player_faction/proc/get_territory_area()
	return territory_area

/datum/player_faction/proc/get_claim_cooldown_remaining()
	if(last_claim_time <= 0)
		return 0
	var/until = last_claim_time + FACTION_CLAIM_COOLDOWN
	return max(0, round((until - world.time) / 10))

/datum/player_faction/proc/get_grid_owner_name()
	return name

/datum/player_faction/proc/ensure_grid_district_id()
	if(istext(district_id) && length(district_id))
		return district_id
	var/base = "PF [faction_tag]"
	var/new_id = base
	var/suffix = 2
	if(SSfaction_control)
		while(SSfaction_control.district_income[new_id] && SSfaction_control.get_owner(new_id) && SSfaction_control.get_owner(new_id) != get_grid_owner_name())
			new_id = "[base] [suffix]"
			suffix++
		SSfaction_control.ensure_district(new_id)
		district_id = new_id
		if(territory_area)
			territory_area:grid_district = district_id
		SSfaction_control.sync_district_to_grid(district_id, get_grid_owner_name(), null)
		return district_id
	district_id = new_id
	if(territory_area)
		territory_area:grid_district = district_id
	return district_id

/// Get UI data for faction control display
/datum/player_faction/proc/get_ui_data()
	var/list/data = list()
	data["id"] = id
	data["name"] = name
	data["tag"] = faction_tag
	data["desc"] = desc
	data["founder_name"] = founder_name
	data["member_count"] = get_member_count()
	data["territory_count"] = get_territory_count()
	data["has_district_node"] = has_district_node
	data["has_control_console"] = has_control_console
	data["color"] = faction_color
	data["treasury"] = treasury

	// Get online member count
	var/online_count = 0
	for(var/mob/M in GLOB.player_list)
		if(M.ckey && is_member(M.ckey))
			online_count++
	data["online_count"] = online_count

	return data

/// Global proc to get all player factions for UI
/proc/get_all_player_factions_ui_data()
	var/list/factions_data = list()
	for(var/datum/player_faction/F in GLOB.player_factions)
		factions_data += list(F.get_ui_data())
	return factions_data

/proc/_announce_faction_claim(mob/user, area/A, original_name)
	var/msg = "<b>[user.real_name]</b> has claimed <b>[original_name]</b> for their faction!"
	for(var/mob/M in A)
		to_chat(M, span_boldwarning(msg))

// =============================================================================
// FACTION CREATION ITEM
// =============================================================================

/obj/item/faction_charter
	name = "blank faction charter"
	desc = "An official document that can be used to establish a new wasteland faction. Cannot be used by members of major factions (NCR, Brotherhood, Legion, Town, Mass Fusion)."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/faction_charter/attack_self(mob/living/user)
	. = ..()
	if(!user || !user.client)
		return

	// Check if user is not in a major faction
	var/list/creation_result = can_create_faction(user)
	if(!creation_result["allowed"])
		to_chat(user, span_warning("[creation_result["reason"]]"))
		return

	// Check if already in a player faction
	var/datum/player_faction/existing = get_player_faction(user.ckey)
	if(existing)
		to_chat(user, span_warning("You are already a member of the player faction '[existing.name]'. Leave that faction first before creating a new one."))
		return

	// Get faction name
	var/faction_name = stripped_input(user, "Enter your faction's name (3-32 characters):", "Faction Name", "", MAX_FACTION_NAME_LENGTH)
	if(!faction_name || length(faction_name) < MIN_FACTION_NAME_LENGTH)
		to_chat(user, span_warning("Invalid faction name."))
		return

	// Check for duplicate names
	for(var/datum/player_faction/F in GLOB.player_factions)
		if(lowertext(F.name) == lowertext(faction_name))
			to_chat(user, span_warning("A faction with that name already exists."))
			return

	// Get faction tag
	var/faction_tag = stripped_input(user, "Enter a short tag for your faction (3-5 characters, used for territory marking):", "Faction Tag", "", 5)
	if(!faction_tag || length(faction_tag) < 3)
		to_chat(user, span_warning("Invalid faction tag. Must be 3-5 characters."))
		return

	// Check for duplicate tags
	for(var/datum/player_faction/F in GLOB.player_factions)
		if(lowertext(F.faction_tag) == lowertext(faction_tag))
			to_chat(user, span_warning("A faction with that tag already exists."))
			return

	// Get description
	var/faction_desc = stripped_input(user, "Enter a description for your faction:", "Faction Description", "A wasteland faction.", 256)

	// Create the faction
	var/datum/player_faction/new_faction = new(user.ckey, faction_name, faction_tag)
	new_faction.founder_name = user.real_name
	new_faction.desc = faction_desc

	to_chat(user, span_boldnotice("You have established [faction_name]! Use the faction management console to manage your faction."))

	// Log it
	log_game("[key_name(user)] created player faction: [faction_name] ([faction_tag])")

	// Consume the charter
	qdel(src)

/// Returns list("allowed" = TRUE/FALSE, "reason" = "explanation string")
/proc/can_create_faction(mob/living/L)
	if(!L)
		return list("allowed" = FALSE, "reason" = "Invalid user.")

	// Resolve job title robustly across forks (assigned_role can be text or /datum/job).
	var/job_title = null
	var/assigned_role = L.mind?.assigned_role
	if(istext(assigned_role))
		job_title = "[assigned_role]"
	else if(istype(assigned_role, /datum/job))
		var/datum/job/J = assigned_role
		job_title = J.title

	// Check current major-faction alignment via faction subsystem first.
	var/current_faction = null
	if(SSfaction_control && hascall(SSfaction_control, "get_mob_faction"))
		current_faction = call(SSfaction_control, "get_mob_faction")(L)
	if(current_faction && SSfaction_control && hascall(SSfaction_control, "normalize_faction"))
		current_faction = call(SSfaction_control, "normalize_faction")(current_faction)
	var/faction_lower = lowertext("[current_faction]")
	var/list/blocked_faction_keywords = list(
		"ncr", "legion", "bos", "brotherhood", "town", "eastwood", "mass fusion", "enclave", "vault"
	)
	for(var/fk in blocked_faction_keywords)
		if(findtext(faction_lower, fk))
			return list("allowed" = FALSE, "reason" = "Major faction members cannot establish new factions. Current faction: '[current_faction]'.")

	if(!job_title || !length(job_title))
		return list("allowed" = TRUE, "reason" = "No job assigned - allowed.") // No job = can create faction

	// ALLOWED JOBS - Wastelanders, Outlaws, and independent roles can create factions
	var/list/allowed_jobs = list(
		// Wasteland jobs
		"Wastelander",
		"Outlaw",
		"Den Mob Enforcer",
		"Den Mob Boss",
		"Den Doctor",
		"Sentient Machine",
		"Preacher",
		"Vigilante",
		"Far-Lands Tribals",
		// Tribal jobs (independent)
		"Chief",
		"Shaman",
		"Head Hunter",
		"Druid",
		"Villager",
		"Hunter",
		"Spirit-Pledged",
		"Guardian",
		// Super Mutants
		"Super Mutant",
		"Super Mutant Leader",
		// Hells Nomads
		"Hells Nomad",
		"Hells Nomad Boss",
		// Khan (if exists)
		"Khan"
	)

	// Check if in allowed list
	for(var/allowed in allowed_jobs)
		if(job_title == allowed)
			return list("allowed" = TRUE, "reason" = "Job '[job_title]' is allowed.")

	// Keyword fallback for independent roles (prevents brittle exact-title lockouts).
	var/job_title_lower = lowertext(job_title)
	var/list/independent_keywords = list(
		"wastelander", "outlaw", "tribal", "nomad", "wanderer", "mutant", "khan"
	)
	for(var/kw in independent_keywords)
		if(findtext(job_title_lower, kw))
			return list("allowed" = TRUE, "reason" = "Independent role '[job_title]' is allowed.")

	// BLOCKED JOBS - Major faction members cannot create player factions
	var/list/blocked_jobs = list(
		// NCR
		"NCR Colonel", "NCR Personal Aide", "NCR Captain", "NCR Lieutenant",
		"NCR Sergeant", "NCR Drill Sergeant", "NCR Brahmin Baron",
		"NCR Veteran Ranger", "NCR Ranger", "NCR Heavy Trooper",
		"NCR Combat Engineer", "NCR Military Police", "NCR Combat Medic",
		"NCR Corporal", "NCR Trooper", "NCR Conscript",
		"NCR Medical Officer", "NCR Logistics Officer", "NCR Rear Echelon", "NCR Citizen",
		// Brotherhood of Steel
		"Elder Envoy", "Sentinel", "Paladin Commander", "Head Scribe",
		"Knight-Captain", "Star Paladin", "Paladin", "Senior Scribe",
		"Scribe", "Knight Sergeant", "Senior Knight", "Knight", "Initiate",
		// Legion
		"Legion Legate", "Legion Orator", "Legion Centurion", "Legion Lictor",
		"Legion Veteran Decanus", "Legion Prime Decanus", "Legion Recruit Decanus",
		"Legion Vexillarius", "Legion Explorer", "Veteran Legionnaire",
		"Prime Legionnaire", "Recruit Legionnaire", "Legion Immune",
		"Legion Forgemaster", "Legion Auxilia", "Legion Slave",
		"Legion Venator", "Legion Slavemaster", "Legion Citizen",
		// Town/Eastwood
		"Mayor", "Secretary", "Sheriff", "Deputy", "Farmer", "Prospector",
		"Doctor", "Barkeep", "Citizen", "Radio Host", "Detective",
		"Banker", "Quartermaster", "Trade Worker", "Vertibird Pilot",
		// Mass Fusion
		"Mass Fusion Supervisor", "Mass Fusion Scavenger",
		"Mass Fusion Reactor Operator", "Mass Fusion Grid Technician",
		"Mass Fusion Relay Engineer", "Mass Fusion Hazard Recovery Tech",
		// Followers (Town medical)
		"Senior Doctor", "Town Scientist", "Town Doctor", "Nurse", "Town Paramedic",
		// Enclave
		"Enclave Captain", "Enclave Lieutenant", "Enclave Sergeant",
		"Enclave Corporal", "Enclave Specialist", "Enclave Private", "Enclave Scientist",
		// Vault
		"Overseer", "Chief of Security", "Vault-tec Doctor", "Vault-tec Scientist",
		"Vault-tec Security", "Vault-tec Engineer", "Vault Dweller"
	)

	// Check if in blocked list
	for(var/blocked in blocked_jobs)
		if(job_title == blocked)
			return list("allowed" = FALSE, "reason" = "Members of NCR, Brotherhood, Legion, Town, Mass Fusion, and other major factions cannot establish new factions. Your job '[job_title]' is blocked.")

	// Default: allow unknown jobs (benefit of the doubt)
	return list("allowed" = TRUE, "reason" = "Job '[job_title]' is not in any list - allowed by default.")

/proc/get_player_faction(ckey)
	for(var/datum/player_faction/F in GLOB.player_factions)
		if(F.is_member(ckey))
			return F
	return null

/proc/get_player_faction_by_id(id)
	for(var/datum/player_faction/F in GLOB.player_factions)
		if(F.id == id)
			return F
	return null

/// Check if an area is within a faction's territory
/proc/is_in_faction_territory(datum/player_faction/faction, area/A)
	if(!faction || !A)
		return FALSE
	// Check if it's the faction's territory area
	if(faction.territory_area && A == faction.territory_area)
		return TRUE
	// Also check claimed_areas list for legacy support
	if(A in faction.claimed_areas)
		return TRUE
	return FALSE

// =============================================================================
// FACTION CONTROL CONSOLE
// =============================================================================

/obj/machinery/f13/player_faction_console
	name = "faction control console"
	desc = "A console for managing a player-created faction."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "terminal_vault"
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// The faction this console belongs to
	var/datum/player_faction/linked_faction = null
	/// Is this console placed and locked?
	var/deployed = FALSE

/obj/machinery/f13/player_faction_console/Initialize()
	. = ..()
	if(!deployed)
		name = "undeployed faction console"
		desc = "A faction control console that needs to be deployed. Use it while holding it to deploy."

/obj/machinery/f13/player_faction_console/attack_hand(mob/user)
	. = ..()
	if(!user || !user.client)
		return

	if(!deployed)
		to_chat(user, span_warning("This console needs to be deployed first. Pick it up and use it in your hand."))
		return

	if(!linked_faction)
		to_chat(user, span_warning("This console is not linked to any faction."))
		return

	if(!linked_faction.is_member(user.ckey))
		to_chat(user, span_warning("You are not a member of [linked_faction.name]."))
		return

	show_faction_menu(user)

/obj/machinery/f13/player_faction_console/proc/show_faction_menu(mob/user)
	if(!linked_faction)
		return

	var/is_officer = linked_faction.is_officer(user.ckey)
	var/is_founder = linked_faction.is_founder(user.ckey)

	var/dat = "<center><h2>[linked_faction.name]</h2></center>"
	dat += "<b>Tag:</b> [linked_faction.faction_tag]<br>"
	dat += "<b>Founder:</b> [linked_faction.founder_name]<br>"
	dat += "<b>Members:</b> [linked_faction.get_member_count()]<br>"
	dat += "<b>Territories:</b> [linked_faction.get_territory_count()]<br>"
	dat += "<b>Treasury:</b> [linked_faction.treasury] caps<br>"
	dat += "<hr>"
	dat += "<b>Description:</b><br>[linked_faction.desc]<br>"
	dat += "<hr>"

	// Member list
	dat += "<b>Members:</b><br>"
	for(var/member_ckey in linked_faction.members)
		var/rank = "Member"
		if(member_ckey == linked_faction.founder_ckey)
			rank = "Founder"
		else if(member_ckey in linked_faction.officers)
			rank = "Officer"
		dat += "- [member_ckey] ([rank])<br>"

	dat += "<hr>"

	// Territory list
	if(linked_faction.get_territory_count() > 0)
		dat += "<b>Claimed Territories:</b><br>"
		for(var/area/A in linked_faction.claimed_areas)
			dat += "- [A.name]<br>"
		dat += "<hr>"

	// Actions
	dat += "<b>Actions:</b><br>"

	if(is_officer)
		dat += "<a href='?src=[REF(src)];action=claim'>Claim Current Area</a><br>"
		dat += "<a href='?src=[REF(src)];action=release'>Release Territory</a><br>"
		dat += "<a href='?src=[REF(src)];action=invite'>Invite Player</a><br>"

	if(is_founder)
		dat += "<a href='?src=[REF(src)];action=promote'>Promote to Officer</a><br>"
		dat += "<a href='?src=[REF(src)];action=demote'>Demote Officer</a><br>"
		dat += "<a href='?src=[REF(src)];action=kick'>Kick Member</a><br>"
		dat += "<a href='?src=[REF(src)];action=edit_desc'>Edit Description</a><br>"
		dat += "<a href='?src=[REF(src)];action=disband'>DISBAND FACTION</a><br>"

	dat += "<a href='?src=[REF(src)];action=leave'>Leave Faction</a><br>"

	var/datum/browser/popup = new(user, "faction_console", "[linked_faction.name] Management", 450, 600)
	popup.set_content(dat)
	popup.open()

/obj/machinery/f13/player_faction_console/Topic(href, href_list)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(!user || !user.client || !linked_faction)
		return

	if(!linked_faction.is_member(user.ckey))
		return

	switch(href_list["action"])
		if("claim")
			if(!linked_faction.is_officer(user.ckey))
				return
			var/area/current_area = get_area(user)
			if(!current_area)
				to_chat(user, span_warning("Cannot determine your current area."))
				return
			if(linked_faction.claim_area(current_area, user))
				to_chat(user, span_boldnotice("Successfully claimed [current_area.name] for [linked_faction.name]!"))
			else
				to_chat(user, span_warning("Cannot claim this area. It may be protected, already claimed, or on cooldown."))

		if("release")
			if(!linked_faction.is_officer(user.ckey))
				return
			var/list/area_names = list()
			for(var/area/A in linked_faction.claimed_areas)
				area_names += A.name
			if(!length(area_names))
				to_chat(user, span_warning("No territories to release."))
				return
			var/choice = input(user, "Select territory to release:", "Release Territory") as null|anything in area_names
			if(!choice)
				return
			for(var/area/A in linked_faction.claimed_areas)
				if(A.name == choice)
					linked_faction.release_area(A)
					to_chat(user, span_notice("Released [choice]."))
					break

		if("invite")
			if(!linked_faction.is_officer(user.ckey))
				return
			var/target_name = input(user, "Enter the ckey of the player to invite:", "Invite Player") as null|text
			if(!target_name)
				return
			target_name = ckey(target_name)
			if(linked_faction.add_member(target_name))
				to_chat(user, span_notice("Invited [target_name] to the faction."))
				// Notify the player if online
				for(var/mob/M in GLOB.player_list)
					if(M.ckey == target_name)
						to_chat(M, span_boldnotice("You have been invited to join [linked_faction.name]!"))
						break
			else
				to_chat(user, span_warning("Could not invite that player."))

		if("promote")
			if(!linked_faction.is_founder(user.ckey))
				return
			var/list/promotable = linked_faction.members - linked_faction.officers
			if(!length(promotable))
				to_chat(user, span_warning("No members to promote."))
				return
			var/choice = input(user, "Select member to promote:", "Promote") as null|anything in promotable
			if(choice && linked_faction.promote_officer(choice))
				to_chat(user, span_notice("Promoted [choice] to officer."))

		if("demote")
			if(!linked_faction.is_founder(user.ckey))
				return
			var/list/demotable = linked_faction.officers - linked_faction.founder_ckey
			if(!length(demotable))
				to_chat(user, span_warning("No officers to demote."))
				return
			var/choice = input(user, "Select officer to demote:", "Demote") as null|anything in demotable
			if(choice && linked_faction.demote_officer(choice))
				to_chat(user, span_notice("Demoted [choice] to member."))

		if("kick")
			if(!linked_faction.is_founder(user.ckey))
				return
			var/list/kickable = linked_faction.members - linked_faction.founder_ckey
			if(!length(kickable))
				to_chat(user, span_warning("No members to kick."))
				return
			var/choice = input(user, "Select member to kick:", "Kick") as null|anything in kickable
			if(choice && linked_faction.remove_member(choice))
				to_chat(user, span_notice("Kicked [choice] from the faction."))

		if("edit_desc")
			if(!linked_faction.is_founder(user.ckey))
				return
			var/new_desc = stripped_input(user, "Enter new faction description:", "Edit Description", linked_faction.desc, 256)
			if(new_desc)
				linked_faction.desc = new_desc
				to_chat(user, span_notice("Description updated."))

		if("leave")
			if(linked_faction.is_founder(user.ckey))
				to_chat(user, span_warning("Founders cannot leave. You must disband the faction or transfer leadership."))
				return
			if(alert(user, "Are you sure you want to leave [linked_faction.name]?", "Leave Faction", "Yes", "No") == "Yes")
				linked_faction.remove_member(user.ckey)
				to_chat(user, span_notice("You have left [linked_faction.name]."))
				return

		if("disband")
			if(!linked_faction.is_founder(user.ckey))
				return
			if(alert(user, "Are you SURE you want to disband [linked_faction.name]? This cannot be undone!", "DISBAND", "Yes, Disband", "Cancel") == "Yes, Disband")
				var/faction_name = linked_faction.name
				qdel(linked_faction)
				linked_faction = null
				to_chat(user, span_boldwarning("You have disbanded [faction_name]."))
				qdel(src)
				return

	show_faction_menu(user)

// =============================================================================
// DEPLOYABLE FACTION CONSOLE (buildable item)
// =============================================================================

/obj/item/deployable_faction_console
	name = "faction control console kit"
	desc = "A kit to deploy a faction control console. Each faction can only have one."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "dvd"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/deployable_faction_console/attack_self(mob/living/user)
	. = ..()
	if(!user || !user.client)
		return

	var/datum/player_faction/faction = get_player_faction(user.ckey)
	if(!faction)
		to_chat(user, span_warning("You are not a member of any faction."))
		return

	if(!faction.is_officer(user.ckey))
		to_chat(user, span_warning("Only faction officers can deploy the control console."))
		return

	if(faction.has_control_console)
		to_chat(user, span_warning("[faction.name] already has a control console deployed."))
		return

	// Check if in claimed territory
	var/area/current_area = get_area(user)
	if(!is_in_faction_territory(faction, current_area))
		to_chat(user, span_warning("You can only deploy the control console in your faction's claimed territory."))
		return

	// Deploy it
	var/obj/machinery/f13/player_faction_console/console = new(get_turf(user))
	console.linked_faction = faction
	console.deployed = TRUE
	console.name = "[faction.name] Control Console"
	console.desc = "The command console for [faction.name]."
	faction.has_control_console = TRUE

	to_chat(user, span_boldnotice("You have deployed [faction.name]'s control console!"))
	log_game("[key_name(user)] deployed faction console for [faction.name]")

	qdel(src)

// =============================================================================
// FACTION DISTRICT NODE
// =============================================================================

/obj/structure/player_faction_district_node
	name = "faction district node"
	desc = "A power distribution node that connects a player faction's territory to the wasteland grid."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "terminal_vault"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/datum/player_faction/linked_faction = null
	var/online = FALSE
	var/node_state = PLAYER_FACTION_NODE_OFFLINE
	var/district_id = null
	var/last_sync_tick = 0
	var/last_sync_reason = "never synced"
	var/sync_warmup_seconds = 5

/obj/structure/player_faction_district_node/Initialize()
	. = ..()
	if(!islist(GLOB.player_faction_district_nodes))
		GLOB.player_faction_district_nodes = list()
	GLOB.player_faction_district_nodes += src
	addtimer(CALLBACK(src, PROC_REF(_deferred_bootstrap)), 1)
	refresh_visual_state()

/obj/structure/player_faction_district_node/Destroy()
	if(islist(GLOB.player_faction_district_nodes))
		GLOB.player_faction_district_nodes -= src
	if(linked_faction)
		linked_faction.has_district_node = FALSE
	if(online && istext(district_id) && length(district_id))
		_grid_set_district_forced(district_id, TRUE)
	return ..()

/obj/structure/player_faction_district_node/proc/_deferred_bootstrap()
	if(QDELETED(src))
		return
	resolve_district_id()
	refresh_visual_state()

/obj/structure/player_faction_district_node/proc/resolve_district_id()
	if(istext(district_id) && length(district_id))
		return district_id
	if(!linked_faction)
		return null
	district_id = linked_faction.ensure_grid_district_id()
	return district_id

/obj/structure/player_faction_district_node/proc/refresh_visual_state()
	switch(node_state)
		if(PLAYER_FACTION_NODE_ONLINE)
			icon_state = "terminal_vault_screen"
		if(PLAYER_FACTION_NODE_SYNCING)
			icon_state = "terminal_vault_screen"
		else
			icon_state = "terminal_vault"

/obj/structure/player_faction_district_node/proc/get_owner_name()
	if(!linked_faction)
		return null
	return linked_faction.get_grid_owner_name()

/obj/structure/player_faction_district_node/proc/is_grid_linked()
	var/d = resolve_district_id()
	if(!istext(d) || !length(d))
		return FALSE
	if(!SSfaction_control)
		return FALSE
	var/current_owner = SSfaction_control.get_owner(d)
	var/expected_owner = get_owner_name()
	if(!istext(expected_owner) || !length(expected_owner))
		return FALSE
	return ("[current_owner]" == "[expected_owner]")

/obj/structure/player_faction_district_node/proc/sync_to_grid(mob/user)
	var/d = resolve_district_id()
	if(!istext(d) || !length(d))
		last_sync_reason = "missing district id"
		last_sync_tick = world.time
		return FALSE
	if(!SSfaction_control)
		last_sync_reason = "faction subsystem unavailable"
		last_sync_tick = world.time
		return FALSE
	var/owner_name = get_owner_name()
	var/list/sync_result = SSfaction_control.sync_district_to_grid(d, owner_name, src)
	last_sync_tick = world.time
	last_sync_reason = sync_result["reason"]
	if(sync_result["ok"])
		return TRUE
	if(user)
		to_chat(user, span_warning("District sync failed: [sync_result["reason"]]."))
	return FALSE

/obj/structure/player_faction_district_node/proc/record_activation_attempt(action, success, reason)
	log_game("Player faction node [action]: district='[district_id]' state='[node_state]' success=[success ? "1" : "0"] reason='[reason]'.")
	if(SSblackbox)
		SSblackbox.record_feedback("nested tally", "district_node_activation", 1, list(action, success ? "success" : "fail", "[reason]"))

/obj/structure/player_faction_district_node/proc/enforce_single_active_node()
	if(!islist(GLOB.player_faction_district_nodes))
		return
	var/d = resolve_district_id()
	if(!d)
		return
	for(var/obj/structure/player_faction_district_node/N in GLOB.player_faction_district_nodes)
		if(!N || QDELETED(N) || N == src)
			continue
		if(N.resolve_district_id() != d)
			continue
		if(!N.online)
			continue
		N.handle_desync("another node is now canonical for [d]")

/obj/structure/player_faction_district_node/proc/bring_online(mob/user)
	if(!GLOB.wasteland_grid_online)
		to_chat(user, span_warning("Cannot bring online - main grid is offline."))
		record_activation_attempt("bring_online", FALSE, "grid_offline")
		return
	node_state = PLAYER_FACTION_NODE_SYNCING
	refresh_visual_state()
	if(!sync_to_grid(user))
		online = FALSE
		node_state = PLAYER_FACTION_NODE_ERROR
		refresh_visual_state()
		record_activation_attempt("bring_online", FALSE, last_sync_reason)
		return
	to_chat(user, span_notice("District node syncing to reactor grid ([sync_warmup_seconds]s warmup)."))
	addtimer(CALLBACK(src, PROC_REF(finalize_online), user), sync_warmup_seconds SECONDS)

/obj/structure/player_faction_district_node/proc/finalize_online(mob/user)
	if(QDELETED(src))
		return
	if(!sync_to_grid(user))
		online = FALSE
		node_state = PLAYER_FACTION_NODE_ERROR
		refresh_visual_state()
		record_activation_attempt("finalize_online", FALSE, last_sync_reason)
		return
	enforce_single_active_node()
	_grid_set_district_forced(district_id, FALSE)
	online = TRUE
	node_state = PLAYER_FACTION_NODE_ONLINE
	refresh_visual_state()
	if(user)
		to_chat(user, span_notice("District node is now ONLINE and linked to district [district_id]."))
	record_activation_attempt("finalize_online", TRUE, "ok")

/obj/structure/player_faction_district_node/proc/take_offline(mob/user, reason = "operator_request")
	online = FALSE
	node_state = PLAYER_FACTION_NODE_OFFLINE
	refresh_visual_state()
	var/d = resolve_district_id()
	if(d)
		_grid_set_district_forced(d, TRUE)
	if(user)
		to_chat(user, span_notice("District node is now OFFLINE."))
	record_activation_attempt("take_offline", TRUE, reason)

/obj/structure/player_faction_district_node/proc/handle_desync(reason = "desync")
	online = FALSE
	node_state = PLAYER_FACTION_NODE_ERROR
	refresh_visual_state()
	if(istext(district_id) && length(district_id))
		_grid_set_district_forced(district_id, TRUE)
	last_sync_reason = reason
	record_activation_attempt("reconcile_force_off", FALSE, reason)

/obj/structure/player_faction_district_node/proc/on_owner_changed()
	if(!online)
		return
	node_state = PLAYER_FACTION_NODE_SYNCING
	refresh_visual_state()
	if(!sync_to_grid(null))
		handle_desync("owner_changed_sync_failed")
		return
	node_state = PLAYER_FACTION_NODE_ONLINE
	refresh_visual_state()

/obj/structure/player_faction_district_node/examine(mob/user)
	. = ..()
	if(linked_faction)
		. += span_notice("Linked to: [linked_faction.name]")
		. += span_notice("District: [resolve_district_id() ? resolve_district_id() : "Unassigned"]")
		. += span_notice("Owner: [get_owner_name() ? get_owner_name() : "Unclaimed"]")
		. += span_notice("State: [uppertext(node_state)] | Grid linked: [is_grid_linked() ? "YES" : "NO"]")
		if(last_sync_tick > 0)
			. += span_notice("Last sync: [round((world.time - last_sync_tick) / 10)]s ago ([last_sync_reason])")
	else
		. += span_warning("Not linked to any faction.")

/obj/structure/player_faction_district_node/attack_hand(mob/user)
	. = ..()
	if(!user || !user.client)
		return

	if(!linked_faction)
		to_chat(user, span_warning("This node is not linked to any faction."))
		return

	if(!linked_faction.is_officer(user.ckey))
		to_chat(user, span_warning("Only faction officers can operate this node."))
		return

	var/choice = alert(user, "State: [uppertext(node_state)]\nDistrict: [resolve_district_id() ? resolve_district_id() : "Unassigned"]\nOwner: [get_owner_name() ? get_owner_name() : "Unclaimed"]", "Faction District Node", online ? "Take Offline" : "Bring Online", "Resync", "Cancel")

	if(choice == "Bring Online")
		bring_online(user)

	else if(choice == "Take Offline")
		take_offline(user, "operator_request")
	else if(choice == "Resync")
		if(sync_to_grid(user))
			to_chat(user, span_notice("District/grid sync completed successfully."))
			if(online)
				_grid_set_district_forced(resolve_district_id(), FALSE)
			node_state = online ? PLAYER_FACTION_NODE_ONLINE : PLAYER_FACTION_NODE_OFFLINE
			refresh_visual_state()
			record_activation_attempt("manual_resync", TRUE, "ok")
		else
			node_state = PLAYER_FACTION_NODE_ERROR
			refresh_visual_state()
			record_activation_attempt("manual_resync", FALSE, last_sync_reason)

// =============================================================================
// DEPLOYABLE DISTRICT NODE
// =============================================================================

/obj/item/deployable_district_node
	name = "district node kit"
	desc = "A kit to deploy a district power node. Each faction can only have one."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "dvd"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/deployable_district_node/attack_self(mob/living/user)
	. = ..()
	if(!user || !user.client)
		return

	var/datum/player_faction/faction = get_player_faction(user.ckey)
	if(!faction)
		to_chat(user, span_warning("You are not a member of any faction."))
		return

	if(!faction.is_officer(user.ckey))
		to_chat(user, span_warning("Only faction officers can deploy the district node."))
		return

	if(faction.has_district_node)
		to_chat(user, span_warning("[faction.name] already has a district node deployed."))
		return

	// Check if in claimed territory
	var/area/current_area = get_area(user)
	if(!is_in_faction_territory(faction, current_area))
		to_chat(user, span_warning("You can only deploy the district node in your faction's claimed territory."))
		return

	// Deploy it
	var/obj/structure/player_faction_district_node/node = new(get_turf(user))
	node.linked_faction = faction
	node.district_id = faction.ensure_grid_district_id()
	node.name = "[faction.name] District Node"
	node.desc = "The power distribution node for [faction.name]'s territory."
	node.refresh_visual_state()
	faction.has_district_node = TRUE

	to_chat(user, span_boldnotice("You have deployed [faction.name]'s district node!"))
	log_game("[key_name(user)] deployed district node for [faction.name]")

	qdel(src)

// =============================================================================
// TERRITORY CLAIM BEACON (claims 10x10 turf area)
// =============================================================================

#define CLAIM_RADIUS 5 // 10x10 area (5 in each direction from center)

/obj/item/territory_claim_beacon
	name = "territory claim beacon"
	desc = "A device used to claim a 10x10 territory for your faction. Plant it in unclaimed land away from major faction bases."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "dvd"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/territory_claim_beacon/attack_self(mob/living/user)
	. = ..()
	if(!user || !user.client)
		return

	var/datum/player_faction/faction = get_player_faction(user.ckey)
	if(!faction)
		to_chat(user, span_warning("You are not a member of any faction."))
		return

	if(!faction.is_officer(user.ckey))
		to_chat(user, span_warning("Only faction officers can claim territory."))
		return

	if(!faction.can_claim_territory(user))
		var/remaining_s = faction.get_claim_cooldown_remaining()
		if(remaining_s > 0)
			to_chat(user, span_warning("Territory claim is on cooldown. Please wait [remaining_s]s."))
		else
			to_chat(user, span_warning("Territory claim cannot be started right now."))
		return

	var/turf/center = get_turf(user)
	if(!center)
		to_chat(user, span_warning("Cannot determine your current location."))
		return

	// Check if any turfs in the 10x10 area are in protected/faction areas
	var/list/turfs_to_claim = list()
	var/blocked = FALSE
	var/blocked_reason = ""

	for(var/turf/T in range(CLAIM_RADIUS, center))
		var/area/A = get_area(T)
		if(!A)
			continue

		// Check if area is protected
		if(is_faction_protected_area(A))
			blocked = TRUE
			blocked_reason = "This location is too close to a major faction's territory ([A.name])."
			break

		// Check if area is already claimed by a player faction
		if(GLOB.claimed_areas_by_faction[A])
			var/datum/player_faction/claiming_faction = GLOB.claimed_areas_by_faction[A]
			if(claiming_faction != faction)
				blocked = TRUE
				blocked_reason = "This location overlaps with [claiming_faction.name]'s territory."
				break

		turfs_to_claim += T

	if(blocked)
		to_chat(user, span_warning("[blocked_reason]"))
		return

	if(!length(turfs_to_claim))
		to_chat(user, span_warning("No valid turfs to claim in this area."))
		return

	// Create a new claimed territory area or claim existing
	claim_territory_turfs(faction, turfs_to_claim, user)
	var/area/player_faction_territory/claimed_territory = faction.get_territory_area()

	to_chat(user, span_boldnotice("Successfully claimed a 10x10 territory for [faction.name]!"))
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	faction.last_claim_time = world.time

	// Create a visual marker at the center
	var/obj/structure/faction_claim_marker/marker = new(center)
	marker.linked_faction = faction
	marker.claimed_area = claimed_territory
	marker.name = "[faction.faction_tag] Territory Marker"

	log_game("[key_name(user)] claimed 10x10 territory for [faction.name] at [AREACOORD(center)]")
	qdel(src)

/// Check if an area belongs to a major faction (NCR, Legion, BOS, etc.)
/proc/is_faction_protected_area(area/A)
	if(!A)
		return TRUE

	var/area_name = lowertext(A.name)
	var/area_type = lowertext("[A.type]")

	// Protected keywords in area names
	var/list/protected_keywords = list(
		"ncr", "legion", "brotherhood", "bos", "enclave",
		"vault", "spawn", "ooc", "admin", "centcom",
		"reactor", "mass fusion", "grid", "eastwood",
		"headquarters", "base", "bunker", "fort", "outpost"
	)

	for(var/keyword in protected_keywords)
		if(findtext(area_name, keyword) || findtext(area_type, keyword))
			return TRUE

	return FALSE

/// Claim turfs for a faction
/proc/claim_territory_turfs(datum/player_faction/faction, list/turfs, mob/user)
	if(!faction || !length(turfs))
		return

	// Get or create the faction's territory area
	var/area/player_faction_territory/territory = faction.get_territory_area()
	if(!territory)
		territory = new()
		territory.name = "[faction.faction_tag] Territory"
		faction.territory_area = territory
	if(faction.ensure_grid_district_id())
		territory:grid_district = faction.district_id

	// Move turfs to the faction's territory area
	for(var/turf/T in turfs)
		var/area/old_area = get_area(T)
		if(old_area && old_area != territory)
			territory.contents += T

	// Track the claim
	if(!(territory in faction.claimed_areas))
		faction.claimed_areas += territory
		GLOB.claimed_areas_by_faction[territory] = faction

	// Announce
	_announce_faction_claim(user, territory, "a new territory")

/// Player faction territory area type
/area/player_faction_territory
	name = "Player Faction Territory"
	icon_state = "green"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY

/// Faction claim marker structure
/obj/structure/faction_claim_marker
	name = "faction territory marker"
	desc = "A marker indicating this territory is claimed by a player faction."
	icon = GRID_FACTION_ASSET_DMI
	icon_state = "warnings"
	anchored = TRUE
	density = TRUE
	max_integrity = 350
	integrity_failure = 125

	var/datum/player_faction/linked_faction = null
	var/area/player_faction_territory/claimed_area = null

/obj/structure/faction_claim_marker/Destroy()
	if(linked_faction)
		var/area/player_faction_territory/area_to_release = claimed_area
		if(!area_to_release || !(area_to_release in linked_faction.claimed_areas))
			area_to_release = linked_faction.territory_area
		if(area_to_release && (area_to_release in linked_faction.claimed_areas))
			linked_faction.release_area(area_to_release)
			if(linked_faction.territory_area == area_to_release)
				linked_faction.territory_area = null
			minor_announce("[linked_faction.name]'s territory marker was destroyed. Their claim has been revoked.", "Territory Update")
	return ..()

/obj/structure/faction_claim_marker/examine(mob/user)
	. = ..()
	if(linked_faction)
		. += span_notice("This territory belongs to: [linked_faction.name]")
		. += span_notice("Tag: [linked_faction.faction_tag]")

#undef CLAIM_RADIUS

// =============================================================================
// ADMIN COMMANDS
// =============================================================================

/client/proc/list_player_factions()
	set name = "List Player Factions"
	set category = "Admin.Game"

	if(!check_rights(R_ADMIN))
		return

	var/dat = "<h2>Player Factions</h2>"

	if(!length(GLOB.player_factions))
		dat += "No player factions exist."
	else
		for(var/datum/player_faction/F in GLOB.player_factions)
			dat += "<hr>"
			dat += "<b>[F.name]</b> ([F.faction_tag])<br>"
			dat += "ID: [F.id]<br>"
			dat += "Founder: [F.founder_ckey] ([F.founder_name])<br>"
			dat += "Members: [F.get_member_count()]<br>"
			dat += "Territories: [F.get_territory_count()]<br>"
			dat += "Has Console: [F.has_control_console ? "Yes" : "No"]<br>"
			dat += "Has Node: [F.has_district_node ? "Yes" : "No"]<br>"

	var/datum/browser/popup = new(usr, "admin_factions", "Player Factions", 500, 600)
	popup.set_content(dat)
	popup.open()

// =============================================================================
// VENDOR FOR FACTION SUPPLIES
// =============================================================================

/obj/machinery/vending/f13/faction_supplies
	name = "Frontier Outfitters"
	desc = "Supplies for establishing your own wasteland faction. Prices: Charter 5000 caps, Beacon 500 caps, Console 2000 caps, Node 3000 caps."
	icon_state = "liberationstation"
	products = list(
		/obj/item/faction_charter = 3,
		/obj/item/territory_claim_beacon = 10,
		/obj/item/deployable_faction_console = 5,
		/obj/item/deployable_district_node = 5
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

#undef MAX_FACTION_NAME_LENGTH
#undef MIN_FACTION_NAME_LENGTH
#undef FACTION_CLAIM_COOLDOWN
#undef FACTION_CREATION_COST
#undef PLAYER_FACTION_NODE_OFFLINE
#undef PLAYER_FACTION_NODE_SYNCING
#undef PLAYER_FACTION_NODE_ONLINE
#undef PLAYER_FACTION_NODE_ERROR
#undef PLAYER_FACTION_NODE_CONTESTED
