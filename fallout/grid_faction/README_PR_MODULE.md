# Grid/Faction PR Module

This folder is the isolated module entrypoint for wasteland grid + faction coupling work.

## Files

- `code/modules/f13/grid_faction/assets.dm`
  - Defines `GRID_FACTION_ASSET_DMI`.
- `code/modules/f13/grid_faction/bridge.dm`
  - Single source of truth for district->grid sync, rebuild, audit, and reconciliation.
- `code/modules/f13/grid_faction/asset_manifest.csv`
  - Raw extract of icon path usage from grid/faction sources.
- `code/modules/f13/grid_faction/README_ASSET_MIGRATION.md`
  - Human-readable list of icon states to migrate into the centralized DMI.

## Centralized Asset File

- `icons/obj/f13/grid_faction_assets.dmi`

All icon assignments in:

- `code/modules/f13/wasteland_grid.dm`
- `code/modules/f13/faction_territory.dm`
- `code/modules/f13/player_factions.dm`

now point at `GRID_FACTION_ASSET_DMI`.

## Include Wiring

`hailmary.dme` now includes:

- `code/modules/f13/grid_faction/assets.dm`
- `code/modules/f13/grid_faction/bridge.dm`

before the main grid/faction files.

## What You Need To Do

1. Move/merge listed icon states into `icons/obj/f13/grid_faction_assets.dmi`.
2. Verify visuals in game.
3. Keep new grid/faction work in this folder and call through the bridge.
