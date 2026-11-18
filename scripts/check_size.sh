#!/usr/bin/env bash
#
# Reports the size of the release APKs and warns when the 64-bit ARM build
# exceeds the ARM64 budget. Never fails the build on a size warning: the app is
# feature-locked, so a fat APK is reported, not trimmed by removing features.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK_DIR="${1:-$ROOT/build/app/outputs/flutter-apk}"
LIMIT_BYTES=$(( ${SIZE_LIMIT_MB:-15} * 1000 * 1000 ))
LIMIT_MB="${SIZE_LIMIT_MB:-15}"

file_size() {
  if stat -f%z "$1" >/dev/null 2>&1; then
    stat -f%z "$1"
  else
    stat -c%s "$1"
  fi
}

human() {
  # Bytes -> "12.3 MB"
  awk -v b="$1" 'BEGIN { printf "%.1f MB", b / 1000000 }'
}

shopt -s nullglob
apks=("$APK_DIR"/app-*-release.apk)
if [[ ${#apks[@]} -eq 0 ]]; then
  echo "SIZE: FAIL - no release APKs found in $APK_DIR"
  echo "      run: flutter build apk --release --split-per-abi"
  exit 1
fi

status=0
for apk in "${apks[@]}"; do
  bytes="$(file_size "$apk")"
  printf '  %-42s %10s\n' "$(basename "$apk")" "$(human "$bytes")"
done

arm64="$APK_DIR/app-arm64-v8a-release.apk"
if [[ -f "$arm64" ]]; then
  bytes="$(file_size "$arm64")"
  if (( bytes > LIMIT_BYTES )); then
    echo "SIZE: WARN - arm64-v8a is $(human "$bytes") (budget ${LIMIT_MB} MB)"
    status=0
  else
    echo "SIZE: PASS - arm64-v8a is $(human "$bytes") (budget ${LIMIT_MB} MB)"
  fi
else
  echo "SIZE: WARN - arm64-v8a APK not found; checked the APKs above"
fi

exit $status
