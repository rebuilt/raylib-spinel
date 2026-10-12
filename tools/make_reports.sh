#!/usr/bin/env bash
# make_reports.sh — regenerate the dated coverage + MRI-drift snapshots.
#
# coverage_audit.py and mri_drift.py only print to stdout; the files under
# reference/reports/ are dated snapshots = a short header + that stdout
# verbatim. Running this rewrites both so they cannot drift out of sync by
# hand-editing (the header date/version included).
#
# Usage: tools/make_reports.sh [YYYY-MM-DD]
#   DATE defaults to today. Pass a date to stamp the snapshot with the day the
#   underlying work landed rather than the day the snapshot was refreshed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATE="${1:-$(date +%F)}"
OUT="$ROOT/reference/reports"
mkdir -p "$OUT"

coverage="$(python3 "$ROOT/tools/coverage_audit.py")"
drift="$(python3 "$ROOT/tools/mri_drift.py")"

# Latest installed MRI version, read from the drift tool's own output so the
# header cannot go stale.
mri_ver="$(printf '%s\n' "$drift" \
  | sed -n 's/^== MRI \([^ ]*\) vs raylib-spinel surface$/\1/p' | head -1)"
[ -n "$mri_ver" ] || mri_ver="unknown"

{
  printf '# API coverage audit — %s\n\n' "$DATE"
  printf 'Baseline: raylib-bindings generator jsons (raylib 6.1-dev). Tool: `tools/coverage_audit.py`.\n\n'
  printf '%s\n' "$coverage"
} > "$OUT/coverage.md"

{
  printf '# MRI raylib-bindings drift report — %s\n\n' "$DATE"
  printf 'Tool: `tools/mri_drift.py`. Compares installed MRI gem versions and the MRI %s surface against raylib-spinel.\n\n' "$mri_ver"
  printf '%s\n' "$drift"
} > "$OUT/mri_drift.md"

echo "wrote $OUT/coverage.md"
echo "wrote $OUT/mri_drift.md"
