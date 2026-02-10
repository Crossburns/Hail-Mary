// Shared assets and bridge singleton for grid/faction integration.

#ifndef GRID_FACTION_ASSET_DMI
#define GRID_FACTION_ASSET_DMI 'icons/obj/f13/grid_faction_assets.dmi'
#endif

GLOBAL_DATUM_INIT(grid_faction_bridge, /datum/grid_faction_bridge, new)

/proc/get_grid_faction_bridge()
	return GLOB.grid_faction_bridge
