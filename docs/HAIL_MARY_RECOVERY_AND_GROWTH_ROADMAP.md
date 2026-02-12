# Hail Mary Recovery and Growth Roadmap

Last updated: 2026-02-10

This document is split into two large tracks:
- Track A: "Fix Verification and Stability Recovery" (everything to inspect and repair).
- Track B: "Integration, Refinement, Polish, and New Systems" (make the game genuinely fun, deep, and stable).

Use this as the project board source of truth. Every item should end with a linked PR and validation note.

---

## Execution Rules

- Priority bands:
  - P0 = game-breaking, compile/runtime/map corruption.
  - P1 = major feature broken or high-friction gameplay.
  - P2 = quality, consistency, polish.
  - P3 = stretch goals and long-horizon systems.
- Completion rule:
  - No item counts as done unless there is a reproducible validation step.
- Merge policy:
  - Keep fix PRs separate from feature PRs.
  - Do not mix map mass-edits with core code refactors in one PR.

---

## Track A: Fix Verification and Stability Recovery

### A0. Build, Includes, and Typepath Integrity (P0)

Goal: game compiles every time, no missing includes, no unknown map types.

Tasks:
- [ ] A0.1 Add a scripted check for every `#include` in `hailmary.dme` to verify file existence.
- [ ] A0.2 Add a scripted map scan that extracts every typepath from active `.dmm` maps and verifies it resolves in compiled code.
- [ ] A0.3 Add a check for duplicate module roots (`code/modules/f13/grid_faction`, `fallout/code/modules/f13/grid_faction`, `fallout/grid_faction`) and fail CI if duplicates exist.
- [ ] A0.4 Validate all active map files in `_maps/pahrump-only.json` and any production map list.
- [ ] A0.5 Add a CI target that runs `tools/build/build dm` and fails fast on first compile regression.

Done when:
- Compile is green on clean checkout.
- Unknown type popup is eliminated on map load/save flows.

---

### A1. Asset and Icon Integrity (P0)

Goal: no missing icons, no invalid icon_state references, no placeholder asset regressions.

Tasks:
- [ ] A1.1 Audit all `icon =` usages under `code/modules/f13/` to verify each file path exists.
- [ ] A1.2 Audit all `icon_state =` values for referenced icon files where states are static literals.
- [ ] A1.3 Remove or quarantine any placeholder art assets used in runtime-critical objects (for example fake consolidated `.dmi` packs).
- [ ] A1.4 Build a generated report of `missing icon file`, `missing icon_state`, and `state exists in wrong file`.
- [ ] A1.5 Explicitly verify Mojave decor/object catalogs still point to correct source `.dmi` files.

Done when:
- Asset audit report returns zero P0/P1 issues.
- No "invisible because missing icon" regressions remain in key gameplay objects.

---

### A2. Invisible Blockers and Collision Logic (P0)

Goal: blockers block movement correctly, are non-interactive, and are truly hidden.

Tasks:
- [ ] A2.1 Enumerate all blocker archetypes (invisible walls, map blockers, temporary blockers, scripted blockers).
- [ ] A2.2 Validate expected fields per blocker:
  - `density`
  - `anchored`
  - `opacity` (if needed)
  - `invisibility`/alpha
  - `mouse_opacity`
  - interaction procs (`attack_hand`, `examine`, click intercepts).
- [ ] A2.3 Add a regression test map or admin verb that spawns each blocker type and confirms behavior.
- [ ] A2.4 Remove any accidental inheriting visual overlays from Mojave or generic structure parents.

Done when:
- Blockers cannot be interacted with as gameplay objects.
- Players cannot walk through intended blocked paths.

---

### A3. Mass Fusion Faction Reliability Pass (P0/P1)

Goal: Mass Fusion is fully functional from job selection to spawn to gameplay systems.

Tasks:
- [ ] A3.1 Validate role definitions in `code/modules/jobs/job_types/mass_fusion.dm` and align slot counts with mapped spawn landmarks.
- [ ] A3.2 Validate `position_categories` and `exp_jobsmap` wiring for all Mass Fusion roles in `code/modules/jobs/jobs.dm`.
- [ ] A3.3 Validate all `massfusion*` start landmarks in map files and ensure they map to existing types.
- [ ] A3.4 Validate all faction-specific machines:
  - bounty machines
  - parcel receiver pads/terminals
  - grid consoles
  - district consoles
- [ ] A3.5 Validate faction control ownership and district linking for Mass Fusion areas.
- [ ] A3.6 Run a full roundstart scenario with all Mass Fusion roles filled.

Done when:
- No role latejoins due to missing spawnpoint mismatch.
- Mass Fusion can fully participate in contracts, grid, and quest loops.

---

### A4. Faction Control / Grid Bridge Cleanup (P0/P1)

Goal: one clear architecture for faction-grid integration with no dead code, no invalid dynamic calls.

Tasks:
- [ ] A4.1 Decide architecture:
  - Keep bridge abstraction and remove dead trailing code.
  - Or remove bridge and keep direct subsystem logic.
- [ ] A4.2 Eliminate invalid DM patterns (`GLOBAL_PROC` misuse, unsafe `:` runtime field abuse where typed access is possible).
- [ ] A4.3 Remove unreachable blocks after `return` in faction/grid procs.
- [ ] A4.4 Ensure district sync logging and reconciliation paths are single-source.
- [ ] A4.5 Document final flow: capture -> owner update -> district sync -> node state -> grid route effect.

Done when:
- No dead code remains in critical sync procs.
- No runtime from invalid dynamic dispatch patterns.

---

### A5. Mojave Sprite and Legacy Split Hygiene (P1)

Goal: legacy imports are isolated and Mojave assets resolve from intended modules.

Tasks:
- [ ] A5.1 Classify `imported_sprites.dm` as legacy-only and ensure gameplay-critical paths do not depend on it.
- [ ] A5.2 Validate include ordering for Mojave modules:
  - decor catalogs
  - direction files
  - toggle files
  - functional objects.
- [ ] A5.3 Build a quick "Mojave critical object spawn test" for map loader sanity.
- [ ] A5.4 Remove stale compatibility shims once all maps are migrated.

Done when:
- Mojave objects render and orient correctly.
- Legacy sprite file can be excluded without gameplay breakage.

---

### A6. FEV Vat and Large Sprite Object Validation (P1)

Goal: all FEV vats and large-format structures are present, visible, and interactive as intended.

Tasks:
- [ ] A6.1 Audit all references to `160x128_FEV_VAT.dmi` and related object types.
- [ ] A6.2 Validate map placements for vats and ensure paths still exist.
- [ ] A6.3 Validate interaction procs on vats after recent faction/grid refactors.
- [ ] A6.4 Add a content checklist for large sprites (`128x128`, `160x128`, `192x192`, `256x192`) to catch missing assets early.

Done when:
- FEV vat objects no longer "disappear" or fail to initialize.

---

### A7. QuestMachines + Courier/Bounty Pipeline (P1)

Goal: faction courier and bounty ecosystem works end-to-end.

Tasks:
- [ ] A7.1 Validate QuestMachines includes and file paths under `fallout/code/modules/QuestMachines/`.
- [ ] A7.2 Validate parcel sender/receiver/terminal typepaths on maps.
- [ ] A7.3 Validate each faction bounty machine variant (`town`, `ncr`, `legion`, `bos`, `massfusion`).
- [ ] A7.4 Validate roundstart availability and recovery after map reload.

Done when:
- All faction courier loops are testable in one dev round.

---

### A8. Runtime, Logs, and Debug Instrumentation (P1/P2)

Goal: catch regressions early and make broken state obvious.

Tasks:
- [ ] A8.1 Add admin diagnostics command for:
  - district owner map
  - node state + grid link status
  - unresolved typepath counters
  - missing asset counters.
- [ ] A8.2 Standardize error log tags for faction/grid/jobs/map issues.
- [ ] A8.3 Add "smoke test" command list for pre-release checks.

Done when:
- Debugging a broken feature takes minutes, not hours.

---

### A9. QA Matrix and Release Gate (P0/P1)

Goal: every release candidate passes a repeatable regression matrix.

Required matrix:
- [ ] Compile clean (`tools/build/build dm`).
- [ ] Load target map(s) without unknown type popups.
- [ ] Spawn each major faction role at roundstart.
- [ ] Validate district capture and grid routing for BOS/NCR/Legion/Town/Mass Fusion.
- [ ] Validate bounty and courier machines for all factions.
- [ ] Validate invisible blocker map zones.
- [ ] Validate FEV vat and selected Mojave large assets in-game.
- [ ] Validate TGUI for faction control and any related control consoles.

Release gate:
- No P0 open.
- No untriaged P1.
- Known P2/P3 items listed in changelog.

---

## Track B: Integration, Refinement, Polish, and New Systems

### Product Pillars

- Pillar 1: Territorial power fantasy (faction control with real map impact).
- Pillar 2: Operational depth (jobs have meaningful loops, not idle waiting).
- Pillar 3: Emergent conflict and cooperation (systemic reasons to fight/trade/ally).
- Pillar 4: Clear feedback (players always understand what changed and why).

---

### B0. 30-Day Stabilize + Reconnect Systems (P0/P1)

Goal: all existing systems are connected, coherent, and reliable.

Projects:
- [ ] B0.1 Faction x Grid x Contracts integration audit and cleanup.
- [ ] B0.2 Mass Fusion fantasy alignment:
  - supervisor directs plant priorities
  - scavenger actually feeds plant economy
  - grid technicians affect district uptime
  - hazard team has high-risk reward windows.
- [ ] B0.3 Unified world event hooks:
  - reactor stress
  - weather pressure
  - fauna pressure
  - contract demand shifts.
- [ ] B0.4 Remove duplicate UIs and split-brain control paths.

Outcome:
- Systems influence each other instead of feeling isolated.

---

### B1. 60-Day Refinement and Player Experience Polish (P1/P2)

Goal: improve readability, pacing, and moment-to-moment fun.

Projects:
- [ ] B1.1 Faction control UI polish:
  - cleaner district state cards
  - explicit online/offline reasons
  - cooldown and cost visibility
  - warning severity tiers.
- [ ] B1.2 Job onboarding packs:
  - per-role quick-start paper or briefing
  - role-specific first 10 minute checklist
  - common failure mode tips.
- [ ] B1.3 Better world feedback:
  - map-wide alerts for major shifts
  - localized effects for district failures
  - stronger audio/visual cues for hazard windows.
- [ ] B1.4 Better rewards:
  - faction contracts grant meaningful progression and not just currency.
- [ ] B1.5 Reduce dead time:
  - dynamic tasks spawned when players are idle in a role.

Outcome:
- New and returning players both know what to do and why it matters.

---

### B2. 90-Day New System Layer: "Wasteland Campaign Loop" (P2/P3)

Goal: rounds feel like chapters in an ongoing regional struggle.

Projects:
- [ ] B2.1 District condition system:
  - each district tracks security, infrastructure, scarcity, and hazard index.
- [ ] B2.2 Faction strategic doctrines:
  - doctrine modifies contracts, costs, and passive effects.
- [ ] B2.3 Supply chain simulation light:
  - salvage inputs -> production outputs -> district bonuses.
- [ ] B2.4 Soft diplomacy:
  - limited truce/trade agreements with time-limited effects.
- [ ] B2.5 Narrative event chains:
  - events branch from current district conditions and faction choices.

Outcome:
- Higher replayability with distinct faction strategies every round.

---

### B3. Long-Horizon Feature Bank (P3)

Keep these as scoped epics, not immediate commitments:

- [ ] B3.1 "Power Grid Sabotage Ops" mini-antag framework.
- [ ] B3.2 "Faction Logistics Convoys" physical moving objectives on map.
- [ ] B3.3 "District Infrastructure Buildables" that alter map affordances.
- [ ] B3.4 "Faction Reputation with Settlements" affecting neutral NPC systems.
- [ ] B3.5 "Seasonal World Conditions" that alter hazard and resource meta.

---

## Integration Quality Standards (Apply to Every New System)

- [ ] Each new system must expose admin diagnostics.
- [ ] Each new system must have at least one failure-state UI message.
- [ ] Each new system must register with release QA matrix.
- [ ] Each system change must list upstream dependencies and map dependencies.
- [ ] Each feature PR must include rollback notes.

---

## Suggested Delivery Cadence

Weekly:
- Triaged bug scrub with P0/P1 burn-down.
- One integration PR max per week touching core subsystems.
- One content/polish PR track in parallel.

Bi-weekly:
- Playtest focused on one faction loop and one map sector.
- Regression matrix run and recorded in this file.

Monthly:
- Retrospective:
  - what broke
  - what improved round quality
  - what to cut or simplify.

---

## Current Immediate Next Actions (Start Here)

- [ ] N1 Run Track A0 include/typepath automation and commit tooling.
- [ ] N2 Complete Track A2 invisible blocker validation and fix list.
- [ ] N3 Complete Track A3 Mass Fusion live-round validation checklist.
- [ ] N4 Finalize Track A4 bridge architecture decision and cleanup PR.
- [ ] N5 Build first B1 UI polish pass for faction control with clearer warnings.

This "N1-N5" block should be the current sprint.

