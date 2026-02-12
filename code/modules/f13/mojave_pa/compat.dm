// Mojave PA compatibility shim for HM.
// Keep this scoped to PA-only requirements.

#ifndef MAIN_MODULE_PA
#define MAIN_MODULE_PA "mainmodulepa"
#endif
#ifndef PASSIVE_MODULE_PA
#define PASSIVE_MODULE_PA "passivemodulepa"
#endif

#ifndef SNUG_FIT
#define SNUG_FIT 0
#endif
#ifndef BLOCKS_SHOVE_KNOCKDOWN
#define BLOCKS_SHOVE_KNOCKDOWN 0
#endif
#ifndef LARGE_WORN_ICON
#define LARGE_WORN_ICON 0
#endif
#ifndef NO_PIXEL_RANDOM_DROP
#define NO_PIXEL_RANDOM_DROP 0
#endif
#ifndef LOCKABLE_1
#define LOCKABLE_1 (1<<0)
#endif

#ifndef LEFT_HANDS
#define LEFT_HANDS 1
#endif
#ifndef RIGHT_HANDS
#define RIGHT_HANDS 2
#endif

#ifndef COMSIG_ATOM_TAKE_DAMAGE
#define COMSIG_ATOM_TAKE_DAMAGE "atom_take_damage"
#endif
#ifndef COMPONENT_NO_TAKE_DAMAGE
#define COMPONENT_NO_TAKE_DAMAGE (1<<0)
#endif

#ifndef FOOTSTEP_PA
#define FOOTSTEP_PA "footstep_pa"
#endif

#ifndef FATNESS_OBESE
#define FATNESS_OBESE 3
#endif

#ifndef IGNORE_INCAPACITATED
#define IGNORE_INCAPACITATED 0
#endif

#ifndef MELEE_ATTACK
#define MELEE_ATTACK 1
#endif

#ifndef FIRE
#define FIRE "fire"
#endif

#ifndef CLASS1_PLASMA
#define CLASS1_PLASMA 1
#endif
#ifndef CLASS2_EDGE
#define CLASS2_EDGE 2
#endif
#ifndef CLASS2_CRUSH
#define CLASS2_CRUSH 2
#endif
#ifndef CLASS2_CUT
#define CLASS2_CUT 2
#endif
#ifndef CLASS2_PIERCE
#define CLASS2_PIERCE 2
#endif
#ifndef CLASS2_STAB
#define CLASS2_STAB 2
#endif
#ifndef CLASS2_LASER
#define CLASS2_LASER 2
#endif
#ifndef CLASS2_FIRE
#define CLASS2_FIRE 2
#endif
#ifndef CLASS3_LASER
#define CLASS3_LASER 3
#endif
#ifndef CLASS3_PLASMA
#define CLASS3_PLASMA 3
#endif
#ifndef CLASS4_EDGE
#define CLASS4_EDGE 4
#endif
#ifndef CLASS4_CRUSH
#define CLASS4_CRUSH 4
#endif
#ifndef CLASS4_CUT
#define CLASS4_CUT 4
#endif
#ifndef CLASS4_PIERCE
#define CLASS4_PIERCE 4
#endif
#ifndef CLASS4_STAB
#define CLASS4_STAB 4
#endif
#ifndef CLASS4_LASER
#define CLASS4_LASER 4
#endif
#ifndef CLASS4_PLASMA
#define CLASS4_PLASMA 4
#endif
#ifndef CLASS5_PLASMA
#define CLASS5_PLASMA 5
#endif
#ifndef CLASS4_FIRE
#define CLASS4_FIRE 4
#endif
#ifndef CLASS5_CRUSH
#define CLASS5_CRUSH 5
#endif
#ifndef CLASS5_CUT
#define CLASS5_CUT 5
#endif
#ifndef CLASS5_PIERCE
#define CLASS5_PIERCE 5
#endif
#ifndef CLASS5_STAB
#define CLASS5_STAB 5
#endif
#ifndef CLASS5_LASER
#define CLASS5_LASER 5
#endif
#ifndef CLASS5_FIRE
#define CLASS5_FIRE 5
#endif

#ifndef TRAIT_FORCED_STANDING
#define TRAIT_FORCED_STANDING "forced_standing"
#endif
#ifndef TRAIT_NOMOBSWAP
#define TRAIT_NOMOBSWAP "nomobswap"
#endif
#ifndef TRAIT_NON_FLAMMABLE
#define TRAIT_NON_FLAMMABLE "non_flammable"
#endif
#ifndef TRAIT_SHOVEIMMUNE
#define TRAIT_SHOVEIMMUNE "shove_immune"
#endif

/atom/proc/run_atom_subarmor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	return damage_amount

/obj/item/ms13/pa_module
	var/inhand_icon_state = null

/obj/item/ms13/power_armor
	var/pickup_sound = null
	var/drop_sound = null
	var/uses_integrity = TRUE
	var/atom_integrity = 100
	var/list/subarmor = null
	var/grid_height = 0
	var/grid_width = 0
	proc/get_integrity()
		return atom_integrity
	proc/update_integrity(new_integrity)
		atom_integrity = max(0, new_integrity)
		return atom_integrity
	proc/update_appearance()
		return
	proc/atom_break(damage_flag)
		return
	proc/atom_destruction(damage_flag)
		return

/obj/item/clothing/head/helmet/space/hardsuit/ms13/power_armor
	var/worn_icon = null
	var/worn_y_offset = 0
	var/uses_integrity = TRUE
	var/atom_integrity = 100
	var/list/subarmor = null
	proc/get_integrity()
		return atom_integrity
	proc/update_integrity(new_integrity)
		atom_integrity = max(0, new_integrity)
		return atom_integrity
	proc/update_appearance()
		return
	proc/atom_break(damage_flag)
		return
	proc/atom_destruction(damage_flag)
		return

/obj/item/clothing/suit/space/hardsuit/ms13/power_armor
	var/worn_icon = null
	var/worn_icon_state = null
	var/worn_y_offset = 0
	var/list/clothing_traits = list()
	var/ms13_flags_1 = 0
	var/cell_cover_open = FALSE
	var/obj/item/stock_parts/cell/cell = null
	var/helmet_on = FALSE
	var/uses_integrity = TRUE
	var/atom_integrity = 100
	var/list/subarmor = null
	proc/get_integrity()
		return atom_integrity
	proc/update_integrity(new_integrity)
		atom_integrity = max(0, new_integrity)
		return atom_integrity
	proc/update_appearance()
		return
	proc/atom_break(damage_flag)
		return
	proc/atom_destruction(damage_flag)
		return

/obj/item/radio/headset/ms13/var/force_superspace = FALSE
/obj/item/radio/headset/ms13/var/radio_broadcast = 0

/mob/living/carbon/var/fatness = 0
/mob/living/carbon/human/var/can_buckle_to = TRUE
/mob/living/carbon/human/var/base_pixel_y = 0

/datum/element/radiation_protected_clothing
/datum/component/clothing_fov_visor
/datum/element/footstep

/proc/pick_weight(list/L)
	if(!islist(L) || !length(L))
		return null
	var/total_weight = 0
	for(var/key in L)
		var/value = L[key]
		if(isnum(value) && value > 0)
			total_weight += value
	if(total_weight <= 0)
		return pick(L)
	var/roll = rand(1, total_weight)
	for(var/key in L)
		var/value = L[key]
		if(!isnum(value) || value <= 0)
			continue
		roll -= value
		if(roll <= 0)
			return key
	return pick(L)

/obj/item/clothing/suit/space/hardsuit/ms13/power_armor/proc/toggle_spacesuit_cell(mob/user)
	cell_cover_open = !cell_cover_open
	if(user)
		to_chat(user, span_notice("You [cell_cover_open ? "open" : "close"] the power cell compartment."))

/obj/item/clothing/suit/space/hardsuit/ms13/power_armor/proc/canStrip(mob/stripper, mob/owner)
	return TRUE

/obj/item/clothing/suit/space/hardsuit/ms13/power_armor/proc/doStrip(mob/stripper, mob/owner)
	return TRUE

/obj/item/clothing/suit/space/hardsuit/ms13/power_armor/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/ms13/lock
	name = "lock"
	desc = "A lock that can be mounted to compatible equipment."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	var/lock_open = TRUE
