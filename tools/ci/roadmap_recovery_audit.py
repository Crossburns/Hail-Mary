#!/usr/bin/env python3
"""
Roadmap recovery audit suite.

This script implements automated checks for the recovery roadmap:
- A0: include/map integrity + map typepath resolution + duplicate module roots
- A1: icon/icon_state integrity audits
- A2: blocker archetype inventory and property sanity warnings
- A3: Mass Fusion role/landmark/machine validation
- A4: bridge/runtime-pattern sanity checks (GLOBAL_PROC, dead bridge delegation)
- A5: legacy Mojave include hygiene
- A6: FEV vat asset/reference/map validation
- A7: QuestMachines courier/bounty pipeline validation
- A8: validation smoke command generation (report section)
- A9: release gate-ready summary
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import zlib
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set, Tuple


ROOT = Path(__file__).resolve().parents[2]
TOOLS_DIR = ROOT / "tools"
if str(TOOLS_DIR) not in sys.path:
    sys.path.insert(0, str(TOOLS_DIR))

MAPMERGE_AVAILABLE = False
MAPMERGE_IMPORT_ERROR: Optional[str] = None
try:
    from mapmerge2.dmm import DMM, parse_map_atom

    MAPMERGE_AVAILABLE = True
except Exception as exc:
    DMM = None
    parse_map_atom = None
    MAPMERGE_IMPORT_ERROR = str(exc)


INCLUDE_RE = re.compile(r'^\s*#include\s+"([^"]+)"')
TYPE_DECL_RE = re.compile(r'^\s*(/?[A-Za-z0-9_][A-Za-z0-9_]*(?:/[A-Za-z0-9_]+)+)\s*(?://.*)?$')
TYPE_MEMBER_RE = re.compile(r'^\s*(/?[A-Za-z0-9_][A-Za-z0-9_]*(?:/[A-Za-z0-9_]+)+)/(?:proc/|verb/)?[A-Za-z0-9_]+\s*\(')
ICON_RE = re.compile(r"^\s*icon\s*=\s*'([^']+)'\s*(?://.*)?$")
ICON_STATE_RE = re.compile(r'^\s*icon_state\s*=\s*(?:"([^"]+)"|\'([^\']+)\')\s*(?://.*)?$')
FIELD_RE = re.compile(r'^\s*(density|anchored|opacity|invisibility|alpha|mouse_opacity)\s*=\s*([^/\n]+)')
PROC_START_RE = re.compile(r'^/datum/controller/subsystem/faction_control/proc/([A-Za-z0-9_]+)\(')
MAP_ATOM_PATH_RE = re.compile(r'(?<![A-Za-z0-9_])(/[A-Za-z0-9_][A-Za-z0-9_/]*)')
OPTIONAL_MISSING_INCLUDES = {
    "templates.dm",
}


@dataclass
class AuditResults:
    failures: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    infos: List[str] = field(default_factory=list)
    metrics: Dict[str, object] = field(default_factory=dict)

    def fail(self, msg: str) -> None:
        self.failures.append(msg)

    def warn(self, msg: str) -> None:
        self.warnings.append(msg)

    def info(self, msg: str) -> None:
        self.infos.append(msg)


def _norm_rel(path_text: str) -> str:
    return path_text.replace("\\", "/")


def _normalize_type_path(type_path: str) -> str:
    if type_path.startswith("/"):
        return type_path
    return f"/{type_path}"


def _resolve_include(base_file: Path, include_text: str) -> Path:
    include_rel = Path(_norm_rel(include_text))
    direct = (base_file.parent / include_rel).resolve()
    if direct.exists():
        return direct
    return (ROOT / include_rel).resolve()


def _safe_read_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8", errors="replace").splitlines()


def gather_include_graph(start_file: Path, res: AuditResults) -> Tuple[Set[Path], List[str]]:
    visited: Set[Path] = set()
    to_visit: List[Path] = [start_file.resolve()]
    missing: List[str] = []

    while to_visit:
        cur = to_visit.pop()
        if cur in visited:
            continue
        visited.add(cur)
        if not cur.exists():
            missing.append(f"{cur} (root include missing)")
            continue

        for line_no, line in enumerate(_safe_read_lines(cur), start=1):
            m = INCLUDE_RE.match(line)
            if not m:
                continue
            raw_include = m.group(1)
            inc = _resolve_include(cur, raw_include)
            if not inc.exists():
                normalized = _norm_rel(raw_include)
                if any(normalized.endswith(opt) for opt in OPTIONAL_MISSING_INCLUDES):
                    res.warn(f"A0.1 optional include not present in this checkout: {cur.relative_to(ROOT)}:{line_no} -> {raw_include}")
                    continue
                missing.append(f"{cur.relative_to(ROOT)}:{line_no} -> {raw_include}")
                continue
            if inc not in visited:
                to_visit.append(inc)

    for item in missing:
        res.fail(f"A0.1 missing include: {item}")
    res.metrics["include_file_count"] = len(visited)
    res.metrics["missing_include_count"] = len(missing)
    return visited, missing


def _type_parent(type_path: str) -> Optional[str]:
    idx = type_path.rfind("/")
    if idx <= 0:
        return None
    return type_path[:idx]


def collect_type_metadata(dm_files: Iterable[Path]) -> Dict[str, Dict[str, object]]:
    type_info: Dict[str, Dict[str, object]] = {}

    for dm_file in sorted(dm_files):
        cur_type: Optional[str] = None
        for line_no, line in enumerate(_safe_read_lines(dm_file), start=1):
            stripped = line.lstrip()
            if stripped.startswith("//"):
                continue

            m_type = TYPE_DECL_RE.match(line)
            if m_type:
                type_path = _normalize_type_path(m_type.group(1))
                cur_type = type_path
                if type_path not in type_info:
                    type_info[type_path] = {
                        "file": dm_file,
                        "line": line_no,
                        "parent": _type_parent(type_path),
                        "icon": None,
                        "icon_state": None,
                        "fields": {},
                    }
                continue

            m_member = TYPE_MEMBER_RE.match(line)
            if m_member:
                type_path = _normalize_type_path(m_member.group(1))
                if type_path not in type_info:
                    type_info[type_path] = {
                        "file": dm_file,
                        "line": line_no,
                        "parent": _type_parent(type_path),
                        "icon": None,
                        "icon_state": None,
                        "fields": {},
                    }
                cur_type = None
                continue

            if stripped.startswith("/") or re.match(r"^[A-Za-z0-9_]+/[A-Za-z0-9_]+", stripped):
                cur_type = None
                continue

            if not cur_type:
                continue
            entry = type_info[cur_type]

            m_icon = ICON_RE.match(line)
            if m_icon:
                entry["icon"] = m_icon.group(1)
                continue

            m_state = ICON_STATE_RE.match(line)
            if m_state:
                entry["icon_state"] = m_state.group(1) or m_state.group(2)
                continue

            m_field = FIELD_RE.match(line)
            if m_field:
                field_name = m_field.group(1)
                field_value = m_field.group(2).strip()
                entry["fields"][field_name] = field_value

    return type_info


def resolve_type_icon(type_path: str, type_info: Dict[str, Dict[str, object]]) -> Optional[str]:
    seen: Set[str] = set()
    cur = type_path
    while cur and cur not in seen:
        seen.add(cur)
        info = type_info.get(cur)
        if not info:
            cur = _type_parent(cur)
            continue
        icon_val = info.get("icon")
        if isinstance(icon_val, str) and icon_val:
            return icon_val
        cur = info.get("parent") if isinstance(info.get("parent"), str) else _type_parent(cur)
    return None


def resolve_type_field(type_path: str, field_name: str, type_info: Dict[str, Dict[str, object]]) -> Optional[str]:
    seen: Set[str] = set()
    cur = type_path
    while cur and cur not in seen:
        seen.add(cur)
        info = type_info.get(cur)
        if not info:
            cur = _type_parent(cur)
            continue
        fields = info.get("fields", {})
        if isinstance(fields, dict) and field_name in fields:
            return str(fields[field_name])
        cur = info.get("parent") if isinstance(info.get("parent"), str) else _type_parent(cur)
    return None


def resolve_resource_path(source_file: Path, raw_path: str) -> Path:
    norm = _norm_rel(raw_path)
    direct = (source_file.parent / norm).resolve()
    if direct.exists():
        return direct
    return (ROOT / norm).resolve()


def flatten_list(value: object) -> List[object]:
    if isinstance(value, list):
        out: List[object] = []
        for item in value:
            out.extend(flatten_list(item))
        return out
    return [value]

def load_map_configs(res: AuditResults) -> Dict[str, Dict[str, object]]:
    configs: Dict[str, Dict[str, object]] = {}
    maps_dir = ROOT / "_maps"
    for cfg_file in sorted(maps_dir.glob("*.json")):
        try:
            data = json.loads(cfg_file.read_text(encoding="utf-8"))
            configs[str(cfg_file)] = data
        except Exception as exc:
            res.fail(f"A0.4 invalid map config JSON: {cfg_file.relative_to(ROOT)} ({exc})")
    res.metrics["map_config_count"] = len(configs)
    return configs


def map_files_from_config(cfg_data: Dict[str, object]) -> List[Path]:
    map_path = str(cfg_data.get("map_path", "")).strip()
    files_raw = flatten_list(cfg_data.get("map_file", []))
    files = [str(x).strip() for x in files_raw if str(x).strip()]
    out: List[Path] = []
    for rel in files:
        out.append((ROOT / "_maps" / map_path / rel).resolve())
    return out


def validate_map_config_files(configs: Dict[str, Dict[str, object]], res: AuditResults) -> None:
    missing = 0
    total = 0
    for cfg_path, data in configs.items():
        cfg_rel = Path(cfg_path).relative_to(ROOT)
        for map_file in map_files_from_config(data):
            total += 1
            if not map_file.exists():
                missing += 1
                res.fail(f"A0.4 missing map file in config {cfg_rel}: {map_file.relative_to(ROOT)}")
    res.metrics["configured_map_file_count"] = total
    res.metrics["missing_configured_map_file_count"] = missing


def extract_map_type_counts(map_files: Iterable[Path], res: AuditResults) -> Counter:
    counter: Counter = Counter()
    parsed = 0
    if MAPMERGE_AVAILABLE:
        res.metrics["map_parser_mode"] = "mapmerge2"
        for map_file in map_files:
            if not map_file.exists():
                continue
            try:
                dmm = DMM.from_file(str(map_file))
            except Exception as exc:
                res.fail(f"A0.2 map parse error: {map_file.relative_to(ROOT)} ({exc})")
                continue

            parsed += 1
            for _, key in dmm.grid.items():
                tile = dmm.dictionary.get(key)
                if not tile:
                    continue
                for atom in tile:
                    path, _vars = parse_map_atom(atom)
                    if isinstance(path, str) and path.startswith("/"):
                        counter[path.lower()] += 1
    else:
        res.metrics["map_parser_mode"] = "regex_fallback"
        if MAPMERGE_IMPORT_ERROR:
            res.warn(
                f"A0.2 mapmerge2 parser unavailable ({MAPMERGE_IMPORT_ERROR}); using fallback typepath extraction."
            )
        for map_file in map_files:
            if not map_file.exists():
                continue
            try:
                text = map_file.read_text(encoding="utf-8", errors="replace")
            except Exception as exc:
                res.fail(f"A0.2 map read error: {map_file.relative_to(ROOT)} ({exc})")
                continue
            parsed += 1
            for path in MAP_ATOM_PATH_RE.findall(text):
                if path.startswith("/proc/"):
                    continue
                counter[path.lower()] += 1

    res.metrics["parsed_map_count"] = parsed
    res.metrics["map_typepath_count"] = len(counter)
    return counter


def check_duplicate_module_roots(res: AuditResults) -> None:
    roots = [
        ROOT / "code/modules/f13/grid_faction",
        ROOT / "fallout/code/modules/f13/grid_faction",
        ROOT / "fallout/grid_faction",
    ]
    non_empty = []
    for root in roots:
        if not root.exists():
            continue
        has_file = any(p.is_file() for p in root.rglob("*"))
        if has_file:
            non_empty.append(root)

    if len(non_empty) > 1:
        rels = ", ".join(str(p.relative_to(ROOT)) for p in non_empty)
        res.fail(f"A0.3 duplicate non-empty grid_faction roots detected: {rels}")
    res.metrics["nonempty_grid_faction_roots"] = [str(p.relative_to(ROOT)) for p in non_empty]


def parse_dmi_description_states(icon_file: Path) -> Optional[Set[str]]:
    data = icon_file.read_bytes()
    if len(data) < 8 or data[:8] != b"\x89PNG\r\n\x1a\n":
        return None

    pos = 8
    description_text: Optional[str] = None
    while pos + 12 <= len(data):
        length = int.from_bytes(data[pos : pos + 4], "big")
        ctype = data[pos + 4 : pos + 8]
        start = pos + 8
        end = start + length
        if end + 4 > len(data):
            break
        chunk_data = data[start:end]
        pos = end + 4

        text_value: Optional[str] = None
        if ctype == b"tEXt":
            split = chunk_data.split(b"\x00", 1)
            if len(split) == 2:
                keyword = split[0].decode("latin-1", errors="ignore")
                if keyword == "Description":
                    text_value = split[1].decode("utf-8", errors="replace")
        elif ctype == b"zTXt":
            idx = chunk_data.find(b"\x00")
            if idx > 0 and idx + 2 <= len(chunk_data):
                keyword = chunk_data[:idx].decode("latin-1", errors="ignore")
                comp_method = chunk_data[idx + 1]
                comp_blob = chunk_data[idx + 2 :]
                if keyword == "Description" and comp_method == 0:
                    try:
                        text_value = zlib.decompress(comp_blob).decode("utf-8", errors="replace")
                    except Exception:
                        text_value = None
        elif ctype == b"iTXt":
            parts = chunk_data.split(b"\x00", 5)
            if len(parts) == 6 and parts[0] == b"Description":
                comp_flag_blob = parts[1]
                comp_method_blob = parts[2]
                text_blob = parts[5]
                comp_flag = comp_flag_blob[0] if comp_flag_blob else 0
                comp_method = comp_method_blob[0] if comp_method_blob else 0
                if comp_flag == 1 and comp_method == 0:
                    try:
                        text_blob = zlib.decompress(text_blob)
                    except Exception:
                        text_blob = b""
                text_value = text_blob.decode("utf-8", errors="replace")

        if text_value is not None:
            description_text = text_value
            break

    if not description_text:
        return None

    states: Set[str] = set()
    for line in description_text.splitlines():
        line = line.strip()
        if line.startswith("state = "):
            m = re.match(r'^state\s*=\s*"(.+)"$', line)
            if m:
                states.add(m.group(1))
    return states


def check_icon_integrity(
    type_info: Dict[str, Dict[str, object]],
    compile_dm_files: Iterable[Path],
    res: AuditResults,
) -> None:
    compile_dm_files = set(compile_dm_files)
    f13_dm_files = [p for p in compile_dm_files if str(p.relative_to(ROOT)).startswith("code/modules/f13/")]
    f13_dm_set = set(f13_dm_files)

    icon_missing: List[str] = []
    icon_state_missing: List[str] = []
    icon_state_wrong_file: List[str] = []

    dmi_cache: Dict[Path, Optional[Set[str]]] = {}
    state_index: Dict[str, Set[Path]] = defaultdict(set)

    def get_states(icon_path: Path) -> Optional[Set[str]]:
        if icon_path in dmi_cache:
            return dmi_cache[icon_path]
        if not icon_path.exists():
            dmi_cache[icon_path] = None
            return None
        states = parse_dmi_description_states(icon_path)
        dmi_cache[icon_path] = states
        if states:
            for st in states:
                state_index[st].add(icon_path)
        return states

    for tpath, info in type_info.items():
        src_file = info.get("file")
        if not isinstance(src_file, Path) or src_file not in f13_dm_set:
            continue
        raw_icon = info.get("icon")
        if isinstance(raw_icon, str) and raw_icon:
            icon_abs = resolve_resource_path(src_file, raw_icon)
            if not icon_abs.exists():
                icon_missing.append(f"{src_file.relative_to(ROOT)}:{info.get('line')} {tpath} -> {raw_icon}")

    for tpath, info in type_info.items():
        src_file = info.get("file")
        if not isinstance(src_file, Path) or src_file not in f13_dm_set:
            continue
        icon_state = info.get("icon_state")
        if not isinstance(icon_state, str) or not icon_state:
            continue

        icon_raw = resolve_type_icon(tpath, type_info)
        if not icon_raw:
            continue
        icon_path = resolve_resource_path(src_file, icon_raw)
        if not icon_path.exists():
            continue
        states = get_states(icon_path)
        if not states:
            continue
        if icon_state in states:
            continue
        candidates = state_index.get(icon_state, set())
        if candidates:
            other = sorted(str(p.relative_to(ROOT)) for p in candidates if p != icon_path)
            if other:
                icon_state_wrong_file.append(
                    f"{src_file.relative_to(ROOT)}:{info.get('line')} {tpath} state='{icon_state}' icon='{icon_raw}' maybe in {other[0]}"
                )
                continue
        icon_state_missing.append(
            f"{src_file.relative_to(ROOT)}:{info.get('line')} {tpath} state='{icon_state}' icon='{icon_raw}'"
        )

    for item in icon_missing:
        res.fail(f"A1.1 missing icon file: {item}")
    for item in icon_state_missing:
        res.fail(f"A1.2 missing icon_state: {item}")
    for item in icon_state_wrong_file:
        res.fail(f"A1.4 icon_state appears in wrong file: {item}")

    res.metrics["a1_missing_icon_file_count"] = len(icon_missing)
    res.metrics["a1_missing_icon_state_count"] = len(icon_state_missing)
    res.metrics["a1_state_wrong_file_count"] = len(icon_state_wrong_file)


def check_placeholder_asset_usage(compile_files: Iterable[Path], res: AuditResults) -> None:
    macro_hits: List[str] = []
    literal_hits: List[str] = []
    for f in compile_files:
        if f.suffix.lower() != ".dm":
            continue
        for line_no, line in enumerate(_safe_read_lines(f), start=1):
            stripped = line.strip()
            if "GRID_FACTION_ASSET_DMI" in line and not stripped.startswith("#define"):
                macro_hits.append(f"{f.relative_to(ROOT)}:{line_no}: {stripped}")
            if "icons/obj/f13/grid_faction_assets.dmi" in line and not stripped.startswith("#define"):
                literal_hits.append(f"{f.relative_to(ROOT)}:{line_no}: {stripped}")

    placeholder = ROOT / "icons/obj/f13/grid_faction_assets.dmi"
    if macro_hits or literal_hits:
        for hit in macro_hits[:50]:
            res.fail(f"A1.3 placeholder asset macro usage detected: {hit}")
        for hit in literal_hits[:50]:
            res.fail(f"A1.3 placeholder asset literal usage detected: {hit}")
        extra = (len(macro_hits) + len(literal_hits)) - 100
        if extra > 0:
            res.fail(f"A1.3 placeholder asset hit list truncated: additional {extra} not shown")
    elif placeholder.exists():
        res.warn("A1.3 placeholder asset pack exists at icons/obj/f13/grid_faction_assets.dmi but is not referenced")

    res.metrics["a1_placeholder_asset_macro_hit_count"] = len(macro_hits)
    res.metrics["a1_placeholder_asset_literal_hit_count"] = len(literal_hits)

def check_blocker_inventory(type_info: Dict[str, Dict[str, object]], res: AuditResults) -> None:
    blocker_hints = re.compile(r"(invisible_blocker|/blocker|map_block|no[_]?walk|no[_]?entry)", re.IGNORECASE)
    blocker_types: List[str] = []
    warning_count = 0

    for tpath in sorted(type_info.keys()):
        if not (
            tpath.startswith("/obj/structure/")
            or tpath.startswith("/obj/effect/")
            or tpath.startswith("/turf/")
        ):
            continue
        if not blocker_hints.search(tpath):
            continue
        blocker_types.append(tpath)
        density = resolve_type_field(tpath, "density", type_info)
        anchored = resolve_type_field(tpath, "anchored", type_info)
        mouse_opacity = resolve_type_field(tpath, "mouse_opacity", type_info)
        invisibility = resolve_type_field(tpath, "invisibility", type_info)
        looks_invisible = "invis" in tpath.lower()
        looks_blocker = "blocker" in tpath.lower() or "map_block" in tpath.lower() or "no_walk" in tpath.lower() or "no_entry" in tpath.lower()

        if looks_invisible:
            if mouse_opacity and mouse_opacity.strip() not in ("0", "FALSE", "MOUSE_OPACITY_TRANSPARENT"):
                warning_count += 1
                res.warn(
                    f"A2.2 blocker warning: {tpath} has mouse_opacity={mouse_opacity}; expected 0/FALSE for non-interactive invisible blockers"
                )
            if looks_blocker and density and density.strip() in ("0", "FALSE"):
                warning_count += 1
                res.warn(f"A2.2 blocker warning: {tpath} has density={density}; expected blocking density")

        if looks_blocker and not density:
            warning_count += 1
            res.warn(f"A2.1 blocker inventory: {tpath} has no explicit density assignment")
        if looks_blocker and not anchored:
            warning_count += 1
            res.warn(f"A2.1 blocker inventory: {tpath} has no explicit anchored assignment")
        if looks_invisible and not invisibility:
            warning_count += 1
            res.warn(f"A2.1 blocker inventory: {tpath} has no explicit invisibility assignment")

    res.metrics["a2_blocker_type_count"] = len(blocker_types)
    res.metrics["a2_blocker_warning_count"] = warning_count
    if not blocker_types:
        res.warn("A2.1 blocker inventory: no blocker-like type paths detected by heuristic")


def parse_mass_fusion_jobs(path: Path) -> Dict[str, Dict[str, object]]:
    jobs: Dict[str, Dict[str, object]] = {}
    if not path.exists():
        return jobs

    current_job: Optional[str] = None
    for line in _safe_read_lines(path):
        m_job = re.match(r'^\s*/datum/job/mass_fusion/([A-Za-z0-9_]+)\s*$', line)
        if m_job:
            current_job = m_job.group(1)
            jobs[current_job] = {"title": None, "spawn_positions": None}
            continue
        if line.startswith("/") and not line.startswith("/datum/job/mass_fusion/"):
            current_job = None
        if not current_job:
            continue
        m_title = re.match(r'^\s*title\s*=\s*"([^"]+)"\s*$', line)
        if m_title:
            jobs[current_job]["title"] = m_title.group(1)
            continue
        m_spawn = re.match(r'^\s*spawn_positions\s*=\s*(-?\d+)\s*$', line)
        if m_spawn:
            jobs[current_job]["spawn_positions"] = int(m_spawn.group(1))

    return jobs


def check_mass_fusion(
    type_info: Dict[str, Dict[str, object]],
    map_type_counts: Counter,
    res: AuditResults,
) -> None:
    mass_fusion_file = ROOT / "code/modules/jobs/job_types/mass_fusion.dm"
    jobs = parse_mass_fusion_jobs(mass_fusion_file)
    if not jobs:
        res.fail("A3.1 missing or unreadable mass_fusion job definitions")
        return

    landmark_for_job = {
        "supervisor": "/obj/effect/landmark/start/f13/massfusionsupervisor",
        "scavenger": "/obj/effect/landmark/start/f13/massfusionscavenger",
        "reactor_operator": "/obj/effect/landmark/start/f13/massfusionreactoroperator",
        "grid_technician": "/obj/effect/landmark/start/f13/massfusiongridtechnician",
        "relay_engineer": "/obj/effect/landmark/start/f13/massfusionrelayengineer",
        "hazard_recovery": "/obj/effect/landmark/start/f13/massfusionhazardrecovery",
    }

    declared = {k.lower() for k in type_info.keys()}
    mismatch_count = 0
    for job_key, landmark_path in landmark_for_job.items():
        if job_key not in jobs:
            res.fail(f"A3.1 missing Mass Fusion job node: {job_key}")
            mismatch_count += 1
            continue
        spawn = jobs[job_key].get("spawn_positions")
        if not isinstance(spawn, int):
            res.fail(f"A3.1 missing spawn_positions for Mass Fusion job: {job_key}")
            mismatch_count += 1
            continue

        if landmark_path.lower() not in declared:
            res.fail(f"A3.3 missing landmark type definition: {landmark_path}")
            mismatch_count += 1
            continue
        mapped = int(map_type_counts.get(landmark_path.lower(), 0))
        if mapped < max(0, spawn):
            res.fail(
                f"A3.3 spawn/landmark mismatch: {job_key} spawn_positions={spawn}, mapped_landmarks={mapped} ({landmark_path})"
            )
            mismatch_count += 1

    required_machine_paths = [
        "/obj/machinery/bounty_machine/faction/courier/massfusion",
        "/obj/structure/f13/parcel_receiver_pad/massfusion",
        "/obj/machinery/f13/parcel_receiver_terminal/massfusion",
        "/obj/machinery/f13/grid_relay_console/massfusion",
        "/obj/machinery/f13/grid_faction_district_console/massfusion",
    ]
    for machine_path in required_machine_paths:
        if machine_path.lower() not in declared:
            res.fail(f"A3.4 missing machine type definition: {machine_path}")
        elif map_type_counts.get(machine_path.lower(), 0) <= 0:
            res.warn(f"A3.4 machine type not mapped in active map set: {machine_path}")

    faction_control_file = ROOT / "code/controllers/subsystem/faction_control.dm"
    text = faction_control_file.read_text(encoding="utf-8", errors="replace").lower()
    required_snippets = [
        '"mass fusion" = faction_mass_fusion',
        '"massfusion" = faction_mass_fusion',
        "/area/f13/building/massfusion",
        'return "mass fusion"',
    ]
    for snippet in required_snippets:
        if snippet not in text:
            res.fail(f"A3.5 missing faction control Mass Fusion linkage snippet: {snippet}")

    res.metrics["a3_mass_fusion_mismatch_count"] = mismatch_count


def check_bridge_patterns(compile_files: Iterable[Path], res: AuditResults) -> None:
    global_proc_hits = []
    for f in compile_files:
        if f.suffix.lower() != ".dm":
            continue
        for line_no, line in enumerate(_safe_read_lines(f), start=1):
            if re.search(r"call\s*\(\s*GLOBAL_PROC\s*,", line):
                global_proc_hits.append(f"{f.relative_to(ROOT)}:{line_no}: {line.strip()}")
    for hit in global_proc_hits:
        res.fail(f"A4.2 invalid dynamic call(GLOBAL_PROC, ...) detected: {hit}")
    res.metrics["a4_invalid_global_proc_call_count"] = len(global_proc_hits)

    target = ROOT / "code/controllers/subsystem/faction_control.dm"
    lines = _safe_read_lines(target)
    proc_blocks: Dict[str, List[str]] = {}
    cur_name: Optional[str] = None
    for line in lines:
        m = PROC_START_RE.match(line)
        if m:
            cur_name = m.group(1)
            proc_blocks[cur_name] = [line]
            continue
        if cur_name:
            if line.startswith("/datum/controller/subsystem/faction_control/proc/"):
                cur_name = None
            else:
                proc_blocks[cur_name].append(line)

    bridge_delegate_targets = [
        "sync_district_to_grid",
        "_log_district_grid_sync",
        "rebuild_district_to_grid_bindings",
        "audit_district_node_state",
        "reconcile_player_faction_node_links",
    ]
    dead_code_hits = 0
    for proc_name in bridge_delegate_targets:
        block = proc_blocks.get(proc_name)
        if not block:
            continue
        return_idx = None
        for idx, line in enumerate(block):
            if re.search(r"return\s+bridge\.", line):
                return_idx = idx
                break
        if return_idx is None:
            continue
        trailing = [x.strip() for x in block[return_idx + 1 :] if x.strip() and not x.strip().startswith("//")]
        if trailing:
            dead_code_hits += 1
            res.fail(f"A4.3 dead code after bridge return in proc {proc_name}")
    res.metrics["a4_dead_code_proc_count"] = dead_code_hits


def check_legacy_mojave(compile_files: Iterable[Path], res: AuditResults) -> None:
    rels = {str(p.relative_to(ROOT)).replace("\\", "/").lower() for p in compile_files}
    legacy = "code/modules/f13/imported_sprites.dm"
    if legacy in rels:
        res.fail("A5.1 legacy imported_sprites.dm is included in compile graph")
    else:
        res.info("A5.1 imported_sprites.dm is excluded from compile graph (expected)")


def check_fev_vats(type_info: Dict[str, Dict[str, object]], map_type_counts: Counter, res: AuditResults) -> None:
    fev_icon = (ROOT / "code/modules/f13/160x128_FEV_VAT.dmi").resolve()
    if not fev_icon.exists():
        res.fail("A6.1 missing FEV vat icon file: code/modules/f13/160x128_FEV_VAT.dmi")
        return

    fev_types: Set[str] = set()
    for tpath, info in type_info.items():
        src = info.get("file")
        if not isinstance(src, Path):
            continue
        icon_raw = resolve_type_icon(tpath, type_info)
        if not icon_raw:
            continue
        icon_abs = resolve_resource_path(src, icon_raw)
        if icon_abs.resolve() == fev_icon:
            fev_types.add(tpath.lower())

    if not fev_types:
        res.fail("A6.1 no type definitions resolve to 160x128_FEV_VAT.dmi")
        return

    mapped_instances = 0
    for tpath, count in map_type_counts.items():
        if tpath in fev_types:
            mapped_instances += int(count)
    if mapped_instances <= 0:
        res.fail("A6.2 no mapped instances found for FEV vat icon-backed types in active map set")

    res.metrics["a6_fev_type_count"] = len(fev_types)
    res.metrics["a6_fev_mapped_instance_count"] = mapped_instances


def check_questmachines(type_info: Dict[str, Dict[str, object]], map_type_counts: Counter, res: AuditResults) -> None:
    declared = {k.lower() for k in type_info.keys()}
    required_variants = [
        "/obj/machinery/bounty_machine/faction/courier/town",
        "/obj/machinery/bounty_machine/faction/courier/ncr",
        "/obj/machinery/bounty_machine/faction/courier/legion",
        "/obj/machinery/bounty_machine/faction/courier/bos",
        "/obj/machinery/bounty_machine/faction/courier/massfusion",
    ]
    for p in required_variants:
        if p.lower() not in declared:
            res.fail(f"A7.3 missing bounty machine variant type: {p}")
        elif map_type_counts.get(p.lower(), 0) <= 0:
            res.warn(f"A7.3 bounty machine variant not mapped in active map set: {p}")

    parcel_variants = [
        "/obj/structure/f13/parcel_receiver_pad/massfusion",
        "/obj/machinery/f13/parcel_receiver_terminal/massfusion",
    ]
    for p in parcel_variants:
        if p.lower() not in declared:
            res.fail(f"A7.2 missing parcel receiver type: {p}")
        elif map_type_counts.get(p.lower(), 0) <= 0:
            res.warn(f"A7.2 parcel receiver type not mapped in active map set: {p}")

def check_ops_runtime_integration(res: AuditResults) -> None:
    dme_path = ROOT / "hailmary.dme"
    dme_text = dme_path.read_text(encoding="utf-8", errors="replace")
    if 'code\\modules\\f13\\ops\\runtime.dm' not in dme_text and 'code/modules/f13/ops/runtime.dm' not in dme_text:
        res.fail("B0.1 missing include for code/modules/f13/ops/runtime.dm in hailmary.dme")

    fc_path = ROOT / "code/controllers/subsystem/faction_control.dm"
    fc_text = fc_path.read_text(encoding="utf-8", errors="replace")
    required_fc_snippets = [
        "var/datum/f13_ops_runtime/ops_runtime",
        "ops_runtime.bootstrap(src)",
        "ops_runtime.tick(src)",
        "proc/get_district_snapshot(",
        "proc/list_district_snapshots(",
        "proc/get_recommended_task_for_mob(",
        'data["ops"] = ops_runtime.get_dashboard_extension(src, user, f)',
    ]
    for snippet in required_fc_snippets:
        if snippet not in fc_text:
            res.fail(f"B0.1 missing faction_control ops integration snippet: {snippet}")

    admin_verbs = ROOT / "code/modules/admin/admin_verbs.dm"
    admin_text = admin_verbs.read_text(encoding="utf-8", errors="replace")
    if "/client/proc/cmd_grid_ops_snapshot" not in admin_text:
        res.fail("B0.1 missing admin verb registration: /client/proc/cmd_grid_ops_snapshot")

    admin_ops = ROOT / "code/modules/admin/verbs/wasteland_grid.dm"
    admin_ops_text = admin_ops.read_text(encoding="utf-8", errors="replace")
    if "/client/proc/cmd_grid_ops_snapshot()" not in admin_ops_text:
        res.fail("B0.1 missing admin verb implementation: /client/proc/cmd_grid_ops_snapshot()")

    res.metrics["b0_ops_runtime_integration"] = "ok"


def check_map_typepaths_resolve(type_info: Dict[str, Dict[str, object]], map_type_counts: Counter, res: AuditResults) -> None:
    declared = {k.lower() for k in type_info.keys()}
    resolvable = set(declared)
    for tpath in declared:
        parent = _type_parent(tpath)
        while parent:
            resolvable.add(parent)
            parent = _type_parent(parent)

    unknown: List[str] = []
    ignored_macro_generated = 0
    for p in map_type_counts.keys():
        if p in resolvable:
            continue

        # Mapping helper macros may synthesize directional paths without explicit declarations.
        if "/directional/" in p:
            directional_base = p.split("/directional/")[0]
            if directional_base in resolvable:
                continue

        # Mapping helper macros also synthesize /hidden and /visible variants in some modules.
        if p.endswith("/hidden") or p.endswith("/visible"):
            parent = _type_parent(p)
            if parent and parent in resolvable:
                continue

        # Some well-known families are generated by mapping helper macros.
        if p.startswith("/obj/machinery/door/window/"):
            ignored_macro_generated += 1
            continue
        if p.startswith("/obj/machinery/atmospherics/pipe/simple/scrubbers/") and (
            p.endswith("/hidden") or p.endswith("/visible")
        ):
            ignored_macro_generated += 1
            continue

        unknown.append(p)
    unknown = sorted(unknown)
    parser_mode = str(res.metrics.get("map_parser_mode", "mapmerge2"))
    if parser_mode == "mapmerge2":
        for p in unknown[:300]:
            res.fail(f"A0.2 unknown mapped typepath: {p}")
        if len(unknown) > 300:
            res.fail(f"A0.2 unknown mapped typepaths truncated: additional {len(unknown) - 300} not shown")
    else:
        for p in unknown[:100]:
            res.warn(f"A0.2 (fallback parser) unresolved typepath candidate: {p}")
        if len(unknown) > 100:
            res.warn(f"A0.2 (fallback parser) unresolved candidates truncated: additional {len(unknown) - 100} not shown")
    if ignored_macro_generated:
        res.info(f"A0.2 ignored {ignored_macro_generated} macro-generated map typepaths during static resolution")
    res.metrics["a0_unknown_map_type_count"] = len(unknown)

def choose_active_maps(configs: Dict[str, Dict[str, object]], args: argparse.Namespace) -> List[Path]:
    chosen_cfgs: List[Path] = []
    if args.all_map_configs:
        chosen_cfgs = [Path(p) for p in configs.keys()]
    elif args.map_config:
        chosen_cfgs = [(ROOT / p).resolve() for p in args.map_config]
    else:
        chosen_cfgs = [(ROOT / "_maps/pahrump-only.json").resolve()]

    active_maps: List[Path] = []
    for cfg in chosen_cfgs:
        key = str(cfg.resolve())
        if key not in configs:
            continue
        for mp in map_files_from_config(configs[key]):
            if mp not in active_maps:
                active_maps.append(mp)
    return active_maps


def print_summary(res: AuditResults) -> None:
    print("=== Roadmap Recovery Audit ===")
    print(f"Failures: {len(res.failures)}")
    print(f"Warnings: {len(res.warnings)}")
    print(f"Info: {len(res.infos)}")
    print("")
    if res.failures:
        print("Failures:")
        for msg in res.failures:
            print(f"- {msg}")
        print("")
    if res.warnings:
        print("Warnings:")
        for msg in res.warnings:
            print(f"- {msg}")
        print("")
    if res.infos:
        print("Info:")
        for msg in res.infos:
            print(f"- {msg}")
        print("")
    print("Metrics:")
    for key in sorted(res.metrics.keys()):
        print(f"- {key}: {res.metrics[key]}")


def write_json_report(res: AuditResults, path: Path) -> None:
    payload = {
        "failures": res.failures,
        "warnings": res.warnings,
        "infos": res.infos,
        "metrics": res.metrics,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Run roadmap recovery audit checks.")
    parser.add_argument(
        "--dme",
        default="hailmary.dme",
        help="Entry DME path relative to repo root (default: hailmary.dme)",
    )
    parser.add_argument(
        "--map-config",
        action="append",
        help="Map JSON config relative path (can be repeated). Default: _maps/pahrump-only.json",
    )
    parser.add_argument(
        "--all-map-configs",
        action="store_true",
        help="Use all _maps/*.json as active map config set for typepath scan",
    )
    parser.add_argument(
        "--json-out",
        help="Optional JSON report output path relative to repo root",
    )
    args = parser.parse_args()

    res = AuditResults()

    dme_path = (ROOT / args.dme).resolve()
    if not dme_path.exists():
        res.fail(f"A0.1 DME not found: {dme_path}")
        print_summary(res)
        return 1

    include_files, _missing = gather_include_graph(dme_path, res)
    compile_dm_files = [p for p in include_files if p.suffix.lower() == ".dm" and p.exists()]
    type_info = collect_type_metadata(compile_dm_files)
    res.metrics["declared_type_count"] = len(type_info)
    res.metrics["compile_dm_file_count"] = len(compile_dm_files)

    configs = load_map_configs(res)
    validate_map_config_files(configs, res)
    active_maps = choose_active_maps(configs, args)
    res.metrics["active_map_count"] = len(active_maps)

    map_type_counts = extract_map_type_counts(active_maps, res)

    check_duplicate_module_roots(res)
    check_map_typepaths_resolve(type_info, map_type_counts, res)
    check_icon_integrity(type_info, compile_dm_files, res)
    check_placeholder_asset_usage(include_files, res)
    check_blocker_inventory(type_info, res)
    check_mass_fusion(type_info, map_type_counts, res)
    check_bridge_patterns(include_files, res)
    check_legacy_mojave(include_files, res)
    check_fev_vats(type_info, map_type_counts, res)
    check_questmachines(type_info, map_type_counts, res)
    check_ops_runtime_integration(res)

    if args.json_out:
        out_path = (ROOT / args.json_out).resolve()
        write_json_report(res, out_path)
        res.info(f"wrote JSON report to {out_path.relative_to(ROOT)}")

    print_summary(res)
    return 1 if res.failures else 0


if __name__ == "__main__":
    sys.exit(main())
