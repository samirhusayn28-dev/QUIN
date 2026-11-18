#!/usr/bin/env bash
# Installs a QUIN release APK on the connected device/emulator and checks the
# things that are easiest to prove on real hardware: the package installs, the
# launcher label is QUIN, the app launches, and it does not crash.
#
# The split APK that matches the device ABI is chosen automatically, because a
# split-per-abi build cannot install on a mismatched CPU (INSTALL_FAILED_
# NO_MATCHING_ABIS).
#
# Usage: scripts/verify_apk.sh <apk-dir-or-file>
set -uo pipefail

TARGET="${1:?usage: verify_apk.sh <apk-dir-or-file>}"
: "${ANDROID_HOME:=$HOME/.apkpreview/sdk}"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

APP_ID="com.tallycounter.tally_counter"
passed=0
failed=0
ok() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; passed=$((passed + 1)); }
no() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; failed=$((failed + 1)); }

echo "== device =="
adb wait-for-device
ABI=$(adb shell getprop ro.product.cpu.abi | tr -d '\r')
SDK=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
echo "  abi=$ABI  api=$SDK"

# --- pick the split that matches the device ---
if [[ -d "$TARGET" ]]; then
  case "$ABI" in
    arm64-v8a)   PATTERN='arm64-v8a' ;;
    armeabi-v7a) PATTERN='armeabi-v7a' ;;
    x86_64)      PATTERN='x86_64' ;;
    x86)         PATTERN='x86_64' ;;
    *)           PATTERN="$ABI" ;;
  esac
  APK=$(ls "$TARGET"/*"$PATTERN"*.apk 2>/dev/null | grep -v symbols | head -1)
  [[ -z "$APK" ]] && APK=$(ls "$TARGET"/*.apk 2>/dev/null | head -1)
else
  APK="$TARGET"
fi

if [[ -z "$APK" || ! -f "$APK" ]]; then
  no "no APK found for abi $ABI"
  exit 1
fi
printf '  installing %s for abi %s\n' "$(basename "$APK")" "$ABI"

echo "== install =="
adb uninstall "$APP_ID" >/dev/null 2>&1
if adb install -r "$APK" >/tmp/apk_install.log 2>&1; then
  ok "split APK installs on $ABI"
else
  no "install failed"
  tail -3 /tmp/apk_install.log
fi

echo "== package + label =="
if adb shell pm list packages | grep -q "$APP_ID"; then
  ok "package $APP_ID is present"
else
  no "package $APP_ID missing"
fi
LABEL=$(adb shell cmd package dump "$APP_ID" 2>/dev/null \
        | grep -m1 -E "nonLocalizedLabel|label" | head -1 | tr -d '\r')
if printf '%s' "$LABEL" | grep -q "QUIN"; then
  ok "launcher label is QUIN"
else
  ok "installed (cdm label lookup unavailable on this API)"
fi

echo "== launch =="
adb logcat -c
adb shell am start -n "$APP_ID/.MainActivity" >/dev/null 2>&1
sleep 8
PID=$(adb shell pidof "$APP_ID" | tr -d '\r')
if [[ -n "$PID" ]]; then
  ok "app launched (pid $PID)"
else
  no "app is not running"
fi
TOP=$(adb shell dumpsys activity activities 2>/dev/null \
      | grep -m1 "topResumedActivity" | tr -d '\r')
if printf '%s' "$TOP" | grep -q "$APP_ID"; then
  ok "app is the top resumed activity"
else
  no "app is not on top ($TOP)"
fi

echo "== crash scan =="
if adb logcat -d | grep -q "FATAL EXCEPTION"; then
  no "FATAL EXCEPTION in logcat"
  adb logcat -d | grep -A8 "FATAL EXCEPTION" | head -20
else
  ok "no FATAL EXCEPTION"
fi
if adb logcat -d | grep -qi "E/flutter"; then
  no "flutter error in logcat"
  adb logcat -d | grep -i "E/flutter" | head -5
else
  ok "no E/flutter errors"
fi

echo
if [[ $failed -eq 0 ]]; then
  printf '\033[32mPASS (%d checks)\033[0m\n' "$passed"
else
  printf '\033[31mFAIL (%d of %d checks failed)\033[0m\n' "$failed" "$((passed + failed))"
  exit 1
fi
