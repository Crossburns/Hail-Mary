#!/bin/bash
set -euo pipefail

python3 tools/ci/roadmap_recovery_audit.py \
  --map-config _maps/pahrump-only.json \
  --json-out data/ci_reports/roadmap_recovery_audit.json

