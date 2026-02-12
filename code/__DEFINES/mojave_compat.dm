// =============================================================================
// MOJAVE COMPAT SHIM
// Goal: compile even if upstream TG vars/procs/components aren't present.
// This is intentionally "dumb": no-op procs + placeholder vars/types.
// =============================================================================

// --------------------
// PLANES / LAYERS / FLAGS (fallbacks)
// --------------------
#define ABOVE_GAME_PLANE  21
#define OVER_TILE_PLANE   20
#define GAME_PLANE_UPPER  22
#define GAME_PLANE_FOV_HIDDEN 19

#define UPDATE_OVERLAYS 1
#define UPDATE_ICON_STATE 1

#define SMOOTH_BITMASK 1

// Smoothing group fallbacks (values don't matter for compile)
#define SMOOTH_GROUP_MS13_WALL            101
#define SMOOTH_GROUP_MS13_WALL_METAL      102
#define SMOOTH_GROUP_MS13_WALL_WOOD       103
#define SMOOTH_GROUP_MS13_WALL_SCRAP      104
#define SMOOTH_GROUP_MS13_WALL_ADOBE      105
#define SMOOTH_GROUP_MS13_WALL_BRICK      106
#define SMOOTH_GROUP_MS13_WALL_REINFORCED 107
#define SMOOTH_GROUP_MS13_LOW_WALL        108
#define SMOOTH_GROUP_MS13_WINDOW          109
#define SMOOTH_GROUP_MS13_MINERALS        110
#define SMOOTH_GROUP_MS13_DESERT          111
#define SMOOTH_GROUP_MS13_SIDEWALK        112
#define SMOOTH_GROUP_MS13_TILE            113
#define SMOOTH_GROUP_MS13_SNOW            114
#define SMOOTH_GROUP_MS13_ROAD            115
#define SMOOTH_GROUP_MS13_WATER           116
#define SMOOTH_GROUP_MS13_OPENSPACE       117
#define SMOOTH_GROUP_MS13_TABLE_METAL     118
#define SMOOTH_GROUP_MS13_TABLE_WOOD      119
#define SMOOTH_GROUP_MS13_TABLE_SMALL     120
#define SMOOTH_GROUP_MS13_TABLE_PLAYER    121
#define SMOOTH_GROUP_MS13_SANDBAGS        122
#define SMOOTH_GROUP_MS13_BONEPILE        123
#define SMOOTH_GROUP_MS13_ROOF_NORMAL     124
#define SMOOTH_GROUP_MS13_ROOF_SHEET      125
#define SMOOTH_GROUP_MS13_ROOF_METAL      126
#define SMOOTH_GROUP_MS13_ROOF_WOOD       127
#define SMOOTH_GROUP_MS13_ICE             128
#define SMOOTH_GROUP_TURF_OPEN            129
#define SMOOTH_GROUP_CATWALK              130

// Misc defines referenced
#define BUILDING_ATMOSPHERE 1

#define DOAFTER_SOURCE_DECON 1
#define DOAFTER_SOURCE_DOORS 1
#define DOAFTER_SOURCE_WINDOWBASH 1
#define DOAFTER_SOURCE_FISHING 1
#define DOAFTER_SOURCE_BREAKICE 1
#define DOAFTER_SOURCE_LADDERBLOCKERS 1
#define DOAFTER_SOURCE_FIREKICK 1
#define DOAFTER_SOURCE_ADDGRILL 1
#define DOAFTER_SOURCE_MAKEPLANKS 1

#define SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN 0
#define returnSECONDARY_ATTACK_CANCEL_ATTACK_CHAIN 0
#define returnSECONDARY_ATTACK_CONTINUE_CHAIN 0
#define returnCONTEXTUAL_SCREENTIP_SET 0

#define SCREENTIP_CONTEXT_LMB 1
#define SCREENTIP_CONTEXT_RMB 2
#define SCREENTIP_CONTEXT_CTRL_LMB 3

#define COMSIG_LIVING_DOORCRUSHED "living_doorcrushed"
#define COMSIG_CLOSET_POST_OPEN   "closet_post_open"

#define LOCKABLE_1  (1<<0)
#define PASSSTRUCTURE 1

#define TOOL_KNIFE 1
#define TOOL_FISHINGROD 2
#define LOCKING_ITEM 3
#define SHARP_AXE 4

#define CLEAN_WASH 1

#define NO_DEXTERITY 1
#define PHASING 1

#define TRAIT_REMOVE_SLOWDOWN "remove_slowdown"
#define TRAIT_ADD_SLOWDOWN    "add_slowdown"
#define TRAIT_IN_POWERARMOUR  "in_powerarmour"
#define TRAIT_BALD            "bald"

#define CATWALK_ON_TURF "catwalk_on_turf"
#define BOARDS_ON_TURF  "boards_on_turf"
#define STAIRS_ON_TURF  "stairs_on_turf"

#define CLICK_CD_BREAKOUT 10

#define ICON_X 1
#define ICON_Y 2

#define LYING_DOWN 1
#define IS_DEAD_OR_INCAP(M) (FALSE)

// Access fallbacks (values irrelevant)
#define ACCESS_TOWN_MAYOR 1
#define ACCESS_TOWN_LAW 2
#define ACCESS_TOWN_DOCTOR 3
#define ACCESS_TOWN_WORKER 4
#define ACCESS_TOWN_ALL 5
#define ACCESS_BROTHERHOOD 6
#define ACCESS_BROTHERHOOD_HPALADIN 7
#define ACCESS_BARONY_RESTRICTED 8
#define ACCESS_BARON_QUARTERS 9
#define ACCESS_BARONY_DOCTOR 10

// Crafting benches
#define CRAFTING_BENCH_GENERAL 1
#define CRAFTING_BENCH_RELOADING 2
#define CRAFTING_BENCH_ARMTAILOR 3
#define CRAFTING_BENCH_WEAPONS 4
#define CRAFTING_BENCH_ELECTRIC 5
#define CRAFTING_BENCH_CAMPFIRE 6
#define CRAFTING_BENCH_SMELTER 7
#define CRAFTING_BENCH_CHEM 8

// Footsteps
#define FOOTSTEP_ROOF 1
#define FOOTSTEP_CATWALK 2

// Well thirst
#define SECONDS_OF_LIFE_PER_WATER_U 1

// --------------------
// Placeholder types referenced all over Mojave
// --------------------

// Projectiles
/obj/projectile
	var/damage = 0
	var/mob/firer

/obj/projectile/beam/ms13
/obj/projectile/bullet
/obj/projectile/bullet/ms13
/obj/projectile/bullet/ms13/plasma

// Elements
/datum/element/item_scaling
/datum/element/world_icon
/datum/element/wall_mount
/datum/element/climbable
/datum/element/vapour_emitter
/datum/element/radioactive

// Components
/datum/component/footstep_changer
/datum/component/thirst
/datum/component/machine_washable
	var/washed = FALSE
/datum/component/storage/concrete/ms13/washing

// Looping sounds
/datum/looping_sound/fire_soft
/datum/looping_sound/ms13/washing_machine
/datum/looping_sound/ms13/neonsign
/datum/looping_sound/ms13/neonsign/busted

// Vapours
/datum/vapours/smoke
/datum/vapours/carbon_air_vapour
/datum/vapours/sulfur_concentrate
#define VAPOUR_ACTIVE_EMITTER_CAP 50

// Reagents (water)
/datum/reagent/consumable/ms13/water
/datum/reagent/consumable/ms13/water/dirty
/datum/reagent/consumable/ms13/water/unfiltered

// Wounds (if missing)
/datum/wound/slash/moderate
/datum/wound/slash/severe

// Items / sheets / stacks
/obj/item/stack/sheet/ms13
/obj/item/stack/sheet/ms13/scrap
/obj/item/stack/sheet/ms13/scrap/two
/obj/item/stack/sheet/ms13/scrap_parts
/obj/item/stack/sheet/ms13/scrap_electronics
/obj/item/stack/sheet/ms13/scrap_electronics/two
/obj/item/stack/sheet/ms13/scrap_copper
/obj/item/stack/sheet/ms13/scrap_copper/two
/obj/item/stack/sheet/ms13/scrap_steel
/obj/item/stack/sheet/ms13/scrap_alu
/obj/item/stack/sheet/ms13/scrap_lead
/obj/item/stack/sheet/ms13/scrap_brass
/obj/item/stack/sheet/ms13/wood
/obj/item/stack/sheet/ms13/wood/log
/obj/item/stack/sheet/ms13/wood/plank
/obj/item/stack/sheet/ms13/wood/scrap_wood
/obj/item/stack/sheet/ms13/wood/scrap_wood/two
/obj/item/stack/sheet/ms13/glass
/obj/item/stack/sheet/ms13/cloth
/obj/item/stack/sheet/ms13/thread
/obj/item/stack/sheet/ms13/leather
/obj/item/stack/sheet/ms13/plastic
/obj/item/stack/sheet/ms13/rubber
/obj/item/stack/sheet/ms13/ceramic
/obj/item/stack/sheet/ms13/circuits

// Lights
/obj/item/light/ms13/tube
/obj/item/light/ms13/bulb

// Food / fish slabs (stubs)
/obj/item/food/meat/slab/ms13/fish
/obj/item/food/meat/slab/ms13/fish/sockeye
/obj/item/food/meat/slab/ms13/fish/smallmouth
/obj/item/food/meat/slab/ms13/fish/largemouth
/obj/item/food/meat/slab/ms13/fish/pink
/obj/item/food/meat/slab/ms13/fish/chum
/obj/item/food/meat/slab/ms13/fish/sturgeon
/obj/item/food/meat/slab/ms13/fish/asian
/obj/item/food/meat/slab/ms13/fish/lamprey
/obj/item/food/meat/slab/ms13/fish/blinky

// Misc items referenced
/obj/item/ms13/brick
/obj/item/paper/ms13
/obj/item/ms13/component/cell
/obj/item/ms13/component/vacuum_tube

// Areas referenced (stubs)
/area/ms13
/area/ms13/desert
/area/ms13/legioncamp
/area/ms13/drylanders
/area/ms13/goldman
/area/ms13/water_baron
/area/ms13/snow
/area/ms13/snow/forest
/area/ms13/snow/lightforest
/area/ms13/snow/deepforest
/area/ms13/underground/mountain
