# F13 Ops Runtime

## Purpose
Provide one integration layer between faction control, district utility, contracts, hazards, and world pressure without replacing existing gameplay code paths.

## Feature List
- District snapshot API (`get_district_snapshot`, `list_district_snapshots`)
- World pressure model (reactor + weather + fauna)
- Role briefing and lightweight task recommendation broker
- Module hook interface (`/datum/f13_ops_module`)
- Dashboard extension payload (`data["ops"]`)
- Admin verb snapshot (`Grid: Ops Snapshot`)

## Setup Steps
1. Ensure `#include "code\modules\f13\ops\runtime.dm"` is present in `hailmary.dme`.
2. Confirm `SSfaction_control` creates and ticks `ops_runtime` in `Initialize` and `fire`.
3. Use `SSfaction_control.get_faction_dashboard(user)` and read `ops` payload for UI integration.
4. Use admin verb `Grid: Ops Snapshot` for live verification.

## Config Knobs
These live in datum vars and can be adjusted in code:
- `f13_ops_runtime.tick_interval`
- `f13_ops_runtime.pressure_tick_interval`
- `f13_ops_task_broker.recommendation_cooldown`

## Extension Tips
- Add new modules by inheriting `/datum/f13_ops_module`.
- Register modules via `ops_runtime.register_module(module, SSfaction_control)`.
- Keep modules additive: emit guidance/modifiers, avoid mutating core state unless required.
- Prefer existing subsystem data (`SSweather`, `SSfauna_ecosystem`, grid globals) rather than duplicating trackers.
