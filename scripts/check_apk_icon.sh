#!/usr/bin/env bash
# Verifies that the launcher icon packaged into a built APK matches the supplied
# source artwork.
#
# Release builds shorten `res/` paths (res/9w.png and friends), so the real icon
# files are resolved from the resource table with `aapt2 dump resources` and
# handed to scripts/verify_icons.py, which checks the density sizes and compares
# each icon's pixels with the source.
#
# Usage: scripts/check_apk_icon.sh <apk> [source_png]
set -uo pipefail

APK="${1:?usage: check_apk_icon.sh <apk> [source]}"
SRC="${2:-assets/icon/app_icon.png}"
: "${ANDROID_HOME:=$HOME/.apkpreview/sdk}"
AAPT2="$ANDROID_HOME/build-tools/36.0.0/aapt2"

if [[ ! -x "$AAPT2" ]]; then
  echo "aapt2 not found at $AAPT2" >&2
  exit 2
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "== resolving launcher icon from the resource table =="
"$AAPT2" dump resources "$APK" > "$WORK/resources.txt" 2>/dev/null

# Turn:
#   (mdpi) (file) res/9w.png type=PNG
# into "mdpi res/9w.png" for the five buckets under mipmap/ic_launcher.
awk '
  /mipmap\/ic_launcher/ { found = 1; next }
  found && match($0, /\(([a-z]+dpi)\)/) {
    density = substr($0, RSTART + 1, RLENGTH - 2)
    if (match($0, /\(file\)[ ]+res\/[^ ]*\.png/)) {
      f = substr($0, RSTART, RLENGTH)
      sub(/^\(file\)[[:space:]]*/, "", f)
      print density, f
      count++
      if (count >= 5) exit
    }
  }' "$WORK/resources.txt" > "$WORK/icons.txt"

ARGS=()
while read -r density file; do
  [[ -z "$density" || -z "$file" ]] && continue
  unzip -o -q "$APK" "$file" -d "$WORK" || continue
  printf '  %s -> %s\n' "$density" "$file"
  ARGS[${#ARGS[@]}]="$density:$WORK/$file"
done < "$WORK/icons.txt"

echo
if [[ ${#ARGS[@]} -eq 0 ]]; then
  printf '  \033[31mFAIL\033[0m  no density-specific ic_launcher icons found in the APK\n'
  exit 1
fi

python3 "$(dirname "$0")/verify_icons.py" "$SRC" "${ARGS[@]}"
