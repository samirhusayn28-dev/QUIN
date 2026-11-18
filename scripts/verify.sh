#!/usr/bin/env bash
#
# Quality gate for the Tally Counter hardening pass. Runs every check and
# prints one PASS / FAIL / WARN / SKIP line per step. Exits non-zero only when
# a step FAILs; size WARN and integration SKIP never fail the run.
#
# Usage:
#   scripts/verify.sh                # full run
#   scripts/verify.sh --skip-integration
#   PERF_DEVICE=<device-id> scripts/verify.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export PATH="$HOME/development/flutter/bin:$PATH"

LOG_DIR="${TMPDIR:-/tmp}/tally-verify"
mkdir -p "$LOG_DIR"

SKIP_INTEGRATION=0
for arg in "$@"; do
  [[ "$arg" == "--skip-integration" ]] && SKIP_INTEGRATION=1
done

declare -a RESULTS=()
failures=0

record() { # <status> <name> <detail>
  RESULTS+=("$1|$2|${3:-}")
  printf '%-5s %s%s\n' "$1" "$2" "${3:+ - $3}"
}

run_flutter_test() { # <name> <path>
  local name="$1"
  local path="$2"
  local log="$LOG_DIR/${name}.log"
  if flutter test "$path" -r compact >"$log" 2>&1; then
    record PASS "$name" "$(tr '\r' '\n' <"$log" | grep -oE '\+[0-9]+: All tests passed!' | tail -1)"
  else
    record FAIL "$name" "see $log"
    tr '\r' '\n' <"$log" | grep -vE '^[0-9]{2}:[0-9]{2}' | tail -25
    failures=$((failures + 1))
  fi
}

# 1. Static analysis ---------------------------------------------------------
echo "== analyze =="
if flutter analyze >"$LOG_DIR/analyze.log" 2>&1; then
  record PASS "analyze"
else
  record FAIL "analyze" "see $LOG_DIR/analyze.log"
  tail -20 "$LOG_DIR/analyze.log"
  failures=$((failures + 1))
fi

# 2-4. Test suites -----------------------------------------------------------
echo "== tests =="
run_flutter_test unit test/unit
run_flutter_test widget test/widget
run_flutter_test golden test/golden

# 5. Integration / perf (real device only) -----------------------------------
echo "== integration perf =="
detect_device() {
  if [[ -n "${PERF_DEVICE:-}" ]]; then echo "$PERF_DEVICE"; return; fi
  if command -v adb >/dev/null 2>&1; then
    adb devices 2>/dev/null | awk 'NR>1 && $2=="device" && $1 !~ /^emulator-/ {print $1; exit}'
  fi
}

if [[ "$SKIP_INTEGRATION" == "1" ]]; then
  record SKIP "integration perf" "--skip-integration"
else
  device="$(detect_device || true)"
  if [[ -z "${device:-}" ]]; then
    record SKIP "integration perf" "no physical device connected (emulators excluded); set PERF_DEVICE"
  elif flutter test integration_test/perf_test.dart -d "$device" -r compact >"$LOG_DIR/integration.log" 2>&1; then
    record PASS "integration perf" "device $device"
  else
    record FAIL "integration perf" "device $device, see $LOG_DIR/integration.log"
    tail -25 "$LOG_DIR/integration.log"
    failures=$((failures + 1))
  fi
fi

# 6. Size --------------------------------------------------------------------
echo "== size =="
if ./scripts/check_size.sh >"$LOG_DIR/size.log" 2>&1; then
  if grep -q 'SIZE: WARN' "$LOG_DIR/size.log"; then
    record WARN "size" "$(grep -oE 'arm64-v8a is [0-9.]+ MB' "$LOG_DIR/size.log" | head -1)"
  else
    record PASS "size" "$(grep -oE 'arm64-v8a is [0-9.]+ MB' "$LOG_DIR/size.log" | head -1)"
  fi
else
  record FAIL "size" "see $LOG_DIR/size.log"
  tail -10 "$LOG_DIR/size.log"
  failures=$((failures + 1))
fi

# 7. Feature lock ------------------------------------------------------------
echo "== features =="
if ./scripts/check_features.sh >"$LOG_DIR/features.log" 2>&1; then
  record PASS "features" "$(grep -oE 'PASS \([0-9]+ checks\)' "$LOG_DIR/features.log" | tail -1)"
else
  record FAIL "features" "see $LOG_DIR/features.log"
  grep -E 'FAIL' "$LOG_DIR/features.log" | tail -20
  failures=$((failures + 1))
fi

# Summary --------------------------------------------------------------------
echo
echo "===================== verify summary ====================="
for row in "${RESULTS[@]}"; do
  IFS='|' read -r status name detail <<<"$row"
  printf '%-5s %-18s %s\n' "$status" "$name" "$detail"
done
echo "=========================================================="

if (( failures > 0 )); then
  echo "VERIFY: FAIL ($failures step(s) failed)"
  exit 1
fi
echo "VERIFY: PASS"
