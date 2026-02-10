//Combat Profile Bioware
//Special combat-focused bioware augmentations
//Only one profile can be active at a time (BIOWARE_COMBAT_PROFILE slot)

#define BIOWARE_COMBAT_PROFILE "bioware_combat_profile"

// ==================== BASIC COMBAT PROFILES ====================

/datum/surgery/advanced/bioware/combat_profile
	bioware_target = BIOWARE_COMBAT_PROFILE
	requires_trait = "ABDUCTOR"
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/advanced/bioware/combat_profile/warform_lacing
	name = "Warform Lacing"
	desc = "A surgical procedure that weaves hyper-dense muscle fibers and reinforced tendons into the limbs, \
	granting superior melee combat capabilities. However, the added mass reduces mobility and precision shooting."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_warform_lacing,
				/datum/surgery_step/close)

/datum/surgery_step/install_warform_lacing
	name = "weave combat muscle fibers"
	implements = list(TOOL_SCALPEL = 100, TOOL_HEMOSTAT = 85, /obj/item/pen = 55)
	time = 150

/datum/surgery_step/install_warform_lacing/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin weaving reinforced muscle fibers into [target]'s limbs."),
		"[user] begins weaving reinforced muscle fibers into [target]'s limbs.",
		"[user] starts manipulating [target]'s musculature.")

/datum/surgery_step/install_warform_lacing/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You successfully install warform lacing into [target]!"),
		"[user] successfully installs warform lacing into [target]!",
		"[user] finishes manipulating [target]'s musculature.")
	new /datum/bioware/combat_profile/warform_lacing(target)
	return TRUE

/datum/bioware/combat_profile/warform_lacing
	name = "Warform Lacing"
	desc = "Dense muscle fibers enhance melee combat but reduce mobility and precision."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/warform_lacing/on_gain()
	..()
	owner.physiology.brute_mod *= 0.85 // Takes 15% less physical damage
	owner.physiology.stamina_mod *= 0.9 // Better stamina
	owner.physiology.do_after_speed *= 1.2 // Slower actions (bulky)
	owner.physiology.hunger_mod *= 1.3 // Needs more food

/datum/bioware/combat_profile/warform_lacing/on_lose()
	..()
	owner.physiology.brute_mod /= 0.85
	owner.physiology.stamina_mod /= 0.9
	owner.physiology.do_after_speed /= 1.2
	owner.physiology.hunger_mod /= 1.3

/datum/surgery/advanced/bioware/combat_profile/deadeye_weave
	name = "Deadeye Weave"
	desc = "A surgical procedure that upgrades the nervous system for enhanced hand-eye coordination and reaction time, \
	dramatically improving ranged combat accuracy. The modifications make close combat more difficult."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_deadeye_weave,
				/datum/surgery_step/close)

/datum/surgery_step/install_deadeye_weave
	name = "splice targeting neural pathways"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCALPEL = 85, /obj/item/stack/cable_coil = 55)
	time = 140

/datum/surgery_step/install_deadeye_weave/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin splicing enhanced targeting pathways into [target]'s nervous system."),
		"[user] begins splicing enhanced targeting pathways into [target]'s nervous system.",
		"[user] starts manipulating [target]'s neural pathways.")

/datum/surgery_step/install_deadeye_weave/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You successfully install deadeye weave into [target]!"),
		"[user] successfully installs deadeye weave into [target]!",
		"[user] finishes manipulating [target]'s neural pathways.")
	new /datum/bioware/combat_profile/deadeye_weave(target)
	return TRUE

/datum/bioware/combat_profile/deadeye_weave
	name = "Deadeye Weave"
	desc = "Enhanced neural pathways improve ranged combat but reduce melee effectiveness."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/deadeye_weave/on_gain()
	..()
	owner.physiology.do_after_speed *= 0.9 // Faster actions
	owner.physiology.stamina_mod *= 1.1 // Worse stamina (specialized for range)
	owner.physiology.brute_mod *= 1.1 // Takes more damage in melee
	owner.physiology.stun_mod *= 0.9 // Better stun resistance

/datum/bioware/combat_profile/deadeye_weave/on_lose()
	..()
	owner.physiology.do_after_speed /= 0.9
	owner.physiology.stamina_mod /= 1.1
	owner.physiology.brute_mod /= 1.1
	owner.physiology.stun_mod /= 0.9

/datum/surgery/advanced/bioware/combat_profile/juggernaut_plating
	name = "Juggernaut Plating"
	desc = "A surgical procedure that grafts bio-metallic plating beneath the skin and reinforces the skeletal structure, \
	creating a walking tank. The subject becomes extremely durable but loses mobility and speed."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_juggernaut_plating,
				/datum/surgery_step/close)

/datum/surgery_step/install_juggernaut_plating
	name = "graft bio-metallic subdermal plating"
	implements = list(TOOL_CAUTERY = 100, TOOL_WELDER = 85, /obj/item/stack/sheet/bone = 65)
	time = 180

/datum/surgery_step/install_juggernaut_plating/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin grafting bio-metallic plating into [target]'s body."),
		"[user] begins grafting bio-metallic plating into [target]'s body.",
		"[user] starts reinforcing [target]'s skeletal structure.")

/datum/surgery_step/install_juggernaut_plating/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You successfully install juggernaut plating into [target]!"),
		"[user] successfully installs juggernaut plating into [target]!",
		"[user] finishes reinforcing [target]'s skeletal structure.")
	new /datum/bioware/combat_profile/juggernaut_plating(target)
	return TRUE

/datum/bioware/combat_profile/juggernaut_plating
	name = "Juggernaut Plating"
	desc = "Bio-metallic plating provides extreme durability but severely reduces mobility."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/juggernaut_plating/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, "juggernaut_plating") // Can't be dismembered
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "juggernaut_plating") // Doesn't slow from damage
	owner.physiology.brute_mod *= 0.75 // Takes 25% less brute
	owner.physiology.burn_mod *= 0.9 // Takes 10% less burn
	owner.physiology.tox_mod *= 1.3 // Takes 30% more toxin (heavy metals)
	owner.physiology.oxy_mod *= 1.2 // Takes 20% more oxy (heavy)
	owner.physiology.do_after_speed *= 1.4 // 40% slower actions
	owner.physiology.hunger_mod *= 1.5 // 50% more hunger

/datum/bioware/combat_profile/juggernaut_plating/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, "juggernaut_plating")
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "juggernaut_plating")
	owner.physiology.brute_mod /= 0.75
	owner.physiology.burn_mod /= 0.9
	owner.physiology.tox_mod /= 1.3
	owner.physiology.oxy_mod /= 1.2
	owner.physiology.do_after_speed /= 1.4
	owner.physiology.hunger_mod /= 1.5

// ==================== ADVANCED COMBAT PROFILES ====================

/datum/surgery/advanced/bioware/combat_profile/berserker
	name = "Berserker Glands"
	desc = "Installs hyperactive adrenal clusters that flood the body with combat stimulants when injured. \
	The user becomes stronger and faster as they take damage, but medical treatments are less effective."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_berserker_glands,
				/datum/surgery_step/close)

/datum/surgery_step/install_berserker_glands
	name = "graft hyperactive adrenal clusters"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCALPEL = 85, /obj/item/reagent_containers/syringe = 55)
	time = 180

/datum/surgery_step/install_berserker_glands/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin grafting unstable adrenal glands into [target]'s endocrine system."),
		"[user] begins grafting unstable adrenal glands into [target]'s endocrine system.",
		"[user] performs dangerous glandular surgery on [target].")

/datum/surgery_step/install_berserker_glands/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You complete the berserker gland installation in [target]."),
		"[user] completes the berserker gland installation in [target].",
		"[user] finishes aggressive endocrine surgery on [target].")
	new /datum/bioware/combat_profile/berserker_glands(target)
	return TRUE

/datum/bioware/combat_profile/berserker_glands
	name = "Berserker Glands"
	desc = "Hyperactive combat glands that trigger when wounded. Damage makes you stronger, but you're vulnerable to fire."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/berserker_glands/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "berserker_glands") // Doesn't slow down from injuries
	owner.physiology.stun_mod *= 0.7 // Very resistant to stuns when hurt
	owner.physiology.brute_mod *= 0.9 // Slightly tougher
	// BUT: vulnerable to fire
	owner.physiology.burn_mod *= 1.5 // Very vulnerable to fire
	owner.physiology.tox_mod *= 1.3 // Weakened healing system

/datum/bioware/combat_profile/berserker_glands/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "berserker_glands")
	owner.physiology.stun_mod /= 0.7
	owner.physiology.brute_mod /= 0.9
	owner.physiology.burn_mod /= 1.5
	owner.physiology.tox_mod /= 1.3

/datum/surgery/advanced/bioware/combat_profile/ghost
	name = "Ghost Protocol"
	desc = "Rewires muscle fiber density and bone structure for near-silent movement and extreme flexibility. \
	The user becomes a phantom on the battlefield, but structural integrity is severely compromised."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_ghost_protocol,
				/datum/surgery_step/close)

/datum/surgery_step/install_ghost_protocol
	name = "restructure for stealth biomechanics"
	implements = list(TOOL_SCALPEL = 100, TOOL_DRILL = 80, /obj/item/wirecutters = 60)
	time = 185

/datum/surgery_step/install_ghost_protocol/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin restructuring [target]'s musculature for stealth mobility."),
		"[user] begins restructuring [target]'s musculature.",
		"[user] performs invasive biomechanical surgery on [target].")

/datum/surgery_step/install_ghost_protocol/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You complete the ghost protocol on [target]. They seem lighter somehow."),
		"[user] completes the ghost protocol on [target].",
		"[user] finishes biomechanical surgery on [target].")
	new /datum/bioware/combat_profile/ghost_protocol(target)
	return TRUE

/datum/bioware/combat_profile/ghost_protocol
	name = "Ghost Protocol"
	desc = "Silent movement and enhanced agility. Extremely fragile to all damage types."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/ghost_protocol/on_gain()
	..()
	owner.physiology.brute_mod *= 1.5 // Takes 50% more physical damage
	owner.physiology.burn_mod *= 1.4 // Takes 40% more burn damage
	owner.physiology.stamina_mod *= 0.6 // Great stamina/dodge
	owner.physiology.stun_mod *= 1.3 // Easier to stun
	owner.physiology.do_after_speed *= 0.8 // 20% faster actions

/datum/bioware/combat_profile/ghost_protocol/on_lose()
	..()
	owner.physiology.brute_mod /= 1.5
	owner.physiology.burn_mod /= 1.4
	owner.physiology.stamina_mod /= 0.6
	owner.physiology.stun_mod /= 1.3
	owner.physiology.do_after_speed /= 0.8

// ==================== EXTREME COMBAT PROFILES ====================

/datum/surgery/advanced/bioware/combat_profile/necro_metabolism
	name = "Necro-Metabolic Conversion"
	desc = "Kills the subject and reanimates them through artificial metabolic pathways. \
	The user is clinically dead - no pulse, no breathing, immune to bleeding and toxins. \
	Requires fresh food consumed regularly to maintain animation. The walking dead."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_necro_metabolism,
				/datum/surgery_step/close)

/datum/surgery_step/install_necro_metabolism
	name = "induce controlled necrosis"
	implements = list(TOOL_CAUTERY = 100, /obj/item/organ/heart = 90, /obj/item/reagent_containers/syringe = 75)
	time = 250

/datum/surgery_step/install_necro_metabolism/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("You begin stopping [target]'s heart and replacing it with artificial necro-metabolism..."),
		"[user] begins inducing controlled death in [target].",
		"[user] performs horrifying reanimation surgery on [target].")

/datum/surgery_step/install_necro_metabolism/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_boldwarning("[target]'s heart stops. Then they sit up anyway."),
		"[user] has created something that should not exist.",
		"[user] finishes the impossible surgery. [target] is no longer alive.")
	new /datum/bioware/combat_profile/necro_metabolism(target)
	return TRUE

/datum/bioware/combat_profile/necro_metabolism
	name = "Necro-Metabolic Conversion"
	desc = "You are dead. You don't bleed, breathe, or need a pulse. You need constant food to function."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/necro_metabolism/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NOBREATH, "necro_metabolism") // Don't need air
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "necro_metabolism") // No wound penalties
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, "necro_metabolism") // Don't go into soft crit
	owner.physiology.tox_mod *= 0.3 // Nearly immune to toxins (already dead)
	owner.physiology.oxy_mod *= 0.2 // Reduced oxygen damage
	owner.physiology.hunger_mod *= 4.0 // Need constant food
	owner.physiology.burn_mod *= 1.6 // Very vulnerable to fire (dry flesh)
	owner.physiology.bleed_mod *= 0.5 // Bleed much less

/datum/bioware/combat_profile/necro_metabolism/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, "necro_metabolism")
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "necro_metabolism")
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, "necro_metabolism")
	owner.physiology.tox_mod /= 0.3
	owner.physiology.oxy_mod /= 0.2
	owner.physiology.hunger_mod /= 4.0
	owner.physiology.burn_mod /= 1.6
	owner.physiology.bleed_mod /= 0.5

/datum/surgery/advanced/bioware/combat_profile/blood_battery
	name = "Hemovoltaic Battery"
	desc = "Converts blood into raw bioelectric energy. Each heartbeat generates power for superhuman bursts. \
	The user constantly bleeds internally and must consume blood to survive. Strength at the cost of hemorrhage."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_blood_battery,
				/datum/surgery_step/close)

/datum/surgery_step/install_blood_battery
	name = "graft hemovoltaic conversion organs"
	implements = list(/obj/item/stock_parts/cell = 100, TOOL_CAUTERY = 85, /obj/item/organ/heart = 80)
	time = 210

/datum/surgery_step/install_blood_battery/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin installing blood-to-energy conversion organs into [target]."),
		"[user] begins installing strange bio-electric organs into [target].",
		"[user] performs experimental energy surgery on [target].")

/datum/surgery_step/install_blood_battery/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("[target]'s veins glow with electric blue light as the battery activates."),
		"[user] completes the blood battery. [target]'s veins glow unnaturally.",
		"[user] finishes dangerous energy surgery on [target].")
	new /datum/bioware/combat_profile/blood_battery(target)
	return TRUE

/datum/bioware/combat_profile/blood_battery
	name = "Hemovoltaic Battery"
	desc = "Blood becomes power. Superhuman bursts, but you hemorrhage constantly."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/blood_battery/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "blood_battery") // Immune to shocks
	owner.physiology.stamina_mod *= 0.5 // Incredible stamina
	owner.physiology.stun_mod *= 0.6 // Hard to stop
	// BUT: constantly bleeding
	owner.physiology.bleed_mod *= 2.5 // Bleeds 2.5x faster
	owner.physiology.brute_mod *= 1.4 // Takes more physical damage
	owner.physiology.hunger_mod *= 2.5 // Needs blood constantly

/datum/bioware/combat_profile/blood_battery/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "blood_battery")
	owner.physiology.stamina_mod /= 0.5
	owner.physiology.stun_mod /= 0.6
	owner.physiology.bleed_mod /= 2.5
	owner.physiology.brute_mod /= 1.4
	owner.physiology.hunger_mod /= 2.5

/datum/surgery/advanced/bioware/combat_profile/living_bomb
	name = "Volatile Compound Synthesis"
	desc = "Organs continuously synthesize explosive compounds. The user can detonate at will for devastating damage. \
	Impact trauma may trigger premature detonation. You are a walking bomb."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_volatile_synthesis,
				/datum/surgery_step/close)

/datum/surgery_step/install_volatile_synthesis
	name = "implant volatile synthesis glands"
	implements = list(/obj/item/grenade = 100, TOOL_CAUTERY = 80, /obj/item/reagent_containers/syringe = 70)
	time = 220

/datum/surgery_step/install_volatile_synthesis/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("You begin installing explosive synthesis glands into [target]. This seems unwise."),
		"[user] begins installing something extremely dangerous into [target].",
		"[user] performs suicidal explosive surgery on [target].")

/datum/surgery_step/install_volatile_synthesis/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_boldwarning("[target] is now a living explosive. Handle with extreme care."),
		"[user] has created a biological bomb.",
		"[user] finishes the most dangerous surgery possible.")
	new /datum/bioware/combat_profile/living_bomb(target)
	return TRUE

/datum/bioware/combat_profile/living_bomb
	name = "Volatile Compound Synthesis"
	desc = "You are an explosive. Command detonation for massive damage. May explode if critically injured."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/living_bomb/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_BOMBIMMUNE, "living_bomb") // Resistant to explosions
	owner.physiology.burn_mod *= 0.8 // Resistant to heat (explosive compound tolerance)
	owner.physiology.brute_mod *= 2.0 // VERY fragile (might explode)
	owner.physiology.tox_mod *= 1.6 // Toxic compounds inside

/datum/bioware/combat_profile/living_bomb/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_BOMBIMMUNE, "living_bomb")
	owner.physiology.burn_mod /= 0.8
	owner.physiology.brute_mod /= 2.0
	owner.physiology.tox_mod /= 1.6

/datum/surgery/advanced/bioware/combat_profile/crystalline
	name = "Crystalline Metamorphosis"
	desc = "Replaces organic tissues with bio-crystalline structures. The user becomes incredibly durable and sharp. \
	However, crystalline flesh is brittle - catastrophic damage causes system failure."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/install_crystalline_metamorphosis,
				/datum/surgery_step/close)

/datum/surgery_step/install_crystalline_metamorphosis
	name = "initiate crystalline conversion"
	implements = list(/obj/item/stack/sheet/mineral/diamond = 100, TOOL_CAUTERY = 80, /obj/item/stack/sheet/glass = 70)
	time = 240

/datum/surgery_step/install_crystalline_metamorphosis/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("You begin converting [target]'s flesh into living crystal..."),
		"[user] begins a disturbing crystallization process on [target].",
		"[user] performs mineral conversion surgery on [target].")

/datum/surgery_step/install_crystalline_metamorphosis/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_boldwarning("[target]'s skin hardens into translucent crystal. They look beautiful and deadly."),
		"[user] has transformed [target] into living crystal.",
		"[user] finishes the crystallization process.")
	new /datum/bioware/combat_profile/crystalline_metamorphosis(target)
	return TRUE

/datum/bioware/combat_profile/crystalline_metamorphosis
	name = "Crystalline Metamorphosis"
	desc = "Your body is crystal. Incredibly durable, but when broken takes massive damage."
	mod_type = BIOWARE_COMBAT_PROFILE

/datum/bioware/combat_profile/crystalline_metamorphosis/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_PIERCEIMMUNE, "crystalline") // Immune to piercing
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, "crystalline") // Can't be dismembered
	owner.physiology.brute_mod *= 0.5 // Takes half physical damage normally
	owner.physiology.burn_mod *= 0.6 // Resistant to heat
	owner.physiology.tox_mod *= 0.3 // Crystal doesn't poison easily
	owner.physiology.stamina_mod *= 1.4 // Poor stamina (rigid)

/datum/bioware/combat_profile/crystalline_metamorphosis/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, "crystalline")
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, "crystalline")
	owner.physiology.brute_mod /= 0.5
	owner.physiology.burn_mod /= 0.6
	owner.physiology.tox_mod /= 0.3
	owner.physiology.stamina_mod /= 1.4

#undef BIOWARE_COMBAT_PROFILE
