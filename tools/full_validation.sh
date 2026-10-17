#!/bin/bash
# full_validation.sh -- the complete raylib-spinel validation sequence.
#
# `hello_raylib`'s `make check` is the fast gate (scene builds, registries,
# adapter audits, duplicate audit, the synthetic gem corpus, the scene sweep
# and the pixel check). Run this script periodically, or before a release:
# it adds the slower corpus sections, which compile every gem example.
#
#   tools/full_validation.sh            # everything, in order
#   tools/full_validation.sh --quick    # skip the differential run section
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
rc=0
step() {
  echo
  echo "=== $* ==="
}

step "spin test (package unit tests)"
spin test || rc=1

step "synthetic corpus (CRuby vs Spinel, gate)"
python3 tools/run_gem_corpus.py --only synthetic --check || rc=1

step "gem examples, analysis section (spinel -c over every example)"
python3 tools/run_gem_corpus.py --only examples || rc=1

step "adapter + duplicate audits"
python3 tools/check_shim_unwraps.py || rc=1
ruby tools/check_duplicate_methods.rb || rc=1

if [ "${1:-}" != "--quick" ]; then
  step "gem examples, differential run section (CRuby vs Spinel, screenshots)"
  python3 tools/run_gem_corpus.py --only run || rc=1
fi

step "hello_raylib gate (make check: scenes, single TU, sweep, pixels)"
make -C "$ROOT/../hello_raylib" check || rc=1

step "hello_raylib ring lap (every scene through the real F6 handoff)"
make -C "$ROOT/../hello_raylib" ring || rc=1

echo
if [ "$rc" = 0 ]; then echo "full validation: OK"; else echo "full validation: FAILURES above"; fi
exit "$rc"
