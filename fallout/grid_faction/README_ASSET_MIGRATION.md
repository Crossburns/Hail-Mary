# Grid/Faction PR Asset Migration

Target DMI file: icons/obj/f13/grid_faction_assets.dmi

All icon assignments in these files now point to GRID_FACTION_ASSET_DMI:
- code/modules/f13/wasteland_grid.dm
- code/modules/f13/faction_territory.dm
- code/modules/f13/player_factions.dm

This DMI currently starts as a placeholder copy. Import the icon states listed below from source DMIs.

## Source DMIs and required states

- code/modules/f13/128x128_rock_sprites.dmi
  states: rb1, rb2, rb3, rb4, rb5, rb6, rb7, rb8
- code/modules/f13/128x128_sprites.dmi
  states: Giant_footstep
- code/modules/f13/128x32_vents.dmi
  states: Large_vent
- code/modules/f13/128x320_deco.dmi
  states: Turbine_deco
- code/modules/f13/160x128_FEV_VAT.dmi
  states: FEV_VAT
- code/modules/f13/160x32_sprites.dmi
  states: RoadGate
- code/modules/f13/224x128_billboards.dmi
  states: WestTek_billboard
- code/modules/f13/256x192_sprites.dmi
  states: Crashed_vertibird
- code/modules/f13/32x32_floor.dmi
  states: Vent1, vent2, vent3, vent4
- code/modules/f13/64x64_machinery.dmi
  states: generator_off
- code/modules/f13/64x64_rock_sprites.dmi
  states: R1, R2, R3, R4, R5, R7
- code/modules/f13/64x64_sprites.dmi
  states: PA_holder_empty, Server_deco
- code/modules/f13/terminals.dmi
  states: terminal_vault
- fallout/eris/icons/128x128_reactor.dmi
  states: Reactor_off
- fallout/eris/icons/96x96.dmi
  states: coolant valve, FEV_pod, Filter_unit, Heat_exchanger, Main_Primary_Pump, Primary_pump, Relief_valve, Turbine_main, West_tek_sign
- fallout/eris/icons/Reactor_32x32.dmi
  states: Breaker_cabinet_closed
- icons/effects/effects.dmi
  states: nothing
- icons/obj/assemblies.dmi
  states: dvd
- icons/obj/bureaucracy.dmi
  states: paper
- icons/obj/machines/antimatter.dmi
  states: box, control_off, control_on, jar
- icons/obj/machines/telecomms.dmi
  states: comm_server_o
- icons/obj/machines/teleporter.dmi
  states: tele-o
- icons/obj/storage.dmi
  states: crate
- icons/Relay_Tower.dmi
  states: (no fixed icon_state nearby; dynamic/runtime state used)
- mojave/icons/structure/street_signs.dmi
  states: warnings

## Validation

1. Import listed states into icons/obj/f13/grid_faction_assets.dmi.
2. Build DM: tools/build/build dm.
3. In-map verify district node, faction marker, relay/breaker, console, reactor machinery, and storage visuals.
