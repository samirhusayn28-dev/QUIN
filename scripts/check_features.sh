#!/usr/bin/env bash
#
# Feature lock for QUIN. Every user-facing feature of the current spec must
# still be present. This is a guard rail: it fails if a feature file or marker
# is removed, never because of a size or style preference.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0
checks=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; checks=$((checks + 1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; failures=$((failures + 1)); checks=$((checks + 1)); }

check_file() { # <path> <label>
  [[ -f "$1" ]] && pass "$2" || fail "$2 (missing $1)"
}

check_grep() { # <pattern> <path> <label>
  if grep -qE "$1" "$2" 2>/dev/null; then pass "$3"; else fail "$3 (no /$1/ in $2)"; fi
}

check_absent() { # <file> <pattern> <label>
  if grep -qE "$2" "$1" 2>/dev/null; then fail "$3 (/$2/ still in $1)"; else pass "$3"; fi
}

echo "Feature checklist"

echo "  -- A. identity + icon"
check_grep 'android:label="QUIN"' android/app/src/main/AndroidManifest.xml "Android app label is QUIN"
check_grep '<string>QUIN</string>' ios/Runner/Info.plist "iOS display name is QUIN"
check_grep "'QUIN'" lib/app.dart "app title is QUIN"
check_grep "image_path: assets/icon/app_icon.png" pubspec.yaml "icon source is the supplied artwork"
check_grep "adaptive_icon_background: assets/icon/ic_background.png" pubspec.yaml "adaptive icon background (full bleed)"
check_grep "adaptive_icon_foreground: assets/icon/ic_foreground.png" pubspec.yaml "adaptive icon foreground (artwork only)"
check_grep "adaptive_icon_monochrome: assets/icon/ic_monochrome.png" pubspec.yaml "adaptive icon monochrome layer"
check_grep "min_sdk_android: 21" pubspec.yaml "adaptive icon min sdk"
[[ -d android/app/src/main/res/mipmap-anydpi-v26 ]] && pass "adaptive-icon mipmap dir" || fail "mipmap-anydpi-v26 missing"
check_file android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml "adaptive icon manifest xml"
check_absent android/app/src/main/res/values/colors.xml "ic_launcher_background" "no white launcher background colour"

echo "  -- B/C. no tally background, top bar, bottom nav"
check_absent lib/features/tally/western_tally_screen.dart "ShaderMask\(|BackdropFilter\(|Opacity\(|saveLayer\(" "no shader/blur/opacity on tally screen"
check_grep "Hero\(" lib/features/counters/counters_screen.dart "hero transition pair"
check_grep "Hero" lib/features/tally/western_tally_screen.dart "hero tag on tally screen"
check_grep "'QUIN'" lib/features/counters/counters_screen.dart "QUIN top bar title"
check_grep "developer-card-button" lib/features/counters/counters_screen.dart "developer icon"
check_grep "archive-button" lib/features/counters/counters_screen.dart "archive icon"
check_file lib/features/counters/archived_screen.dart "archived screen"

echo "  -- D. counters: menu right, swipe delete/archive, drag, duplicate, search"
check_grep "more_vert" lib/features/counters/counters_screen.dart "three-dot menu"
check_grep "Dismissible" lib/features/counters/counters_screen.dart "swipe gestures"
check_grep "ReorderableListView" lib/features/counters/counters_screen.dart "drag reorder"
check_grep "Search" lib/features/counters/counters_screen.dart "search field"
check_grep "deleteCounter" lib/data/database/app_database.dart "drift delete"
check_grep "restoreCounter" lib/data/database/app_database.dart "undo restore"

echo "  -- E. one lightweight line look"
check_file lib/tally_styles/line_style.dart "line style model"
check_file lib/tally_styles/line_style_painter.dart "line style painter"
for style in chalk charcoal ink; do
  check_grep "'$style'" lib/tally_styles/line_style.dart "line style: $style"
done
check_grep "class TallyStrokePainter" lib/tally_styles/line_style_painter.dart "single bar painter"
check_grep "_cachedPath" lib/tally_styles/line_style_painter.dart "seeded cached paths"
check_absent lib/features/counters/counter_edit_screen.dart "_LineStyleCard" "no line-style selector on the edit screen"
check_absent lib/features/onboarding/onboarding_screen.dart "NeoChip" "no line-style picker in onboarding"
check_grep "fromId" lib/tally_styles/line_style.dart "legacy style id migration"

echo "  -- F/G. tally screen performance"
check_file lib/features/tally/western_tally_screen.dart "tally screen"
check_file lib/features/tally/tally_mark.dart "completed mark + active group"
check_grep "tapCounterBatch" lib/data/database/app_database.dart "batched tap write"
check_grep "RepaintBoundary" lib/features/tally/western_tally_screen.dart "separate repaint boundaries"
check_grep "scheduleMicrotask" lib/features/tally/western_tally_screen.dart "instant in-memory tap path"
check_grep "class Debouncer" lib/features/tally/volume_buttons.dart "volume debounce"
check_grep "KEYCODE_VOLUME" android/app/src/main/kotlin/com/tallycounter/tally_counter/MainActivity.kt "volume key capture"
check_grep "taps_at_idx" lib/data/database/app_database.dart "timestamp index"
check_grep "schemaVersion => 6" lib/data/database/app_database.dart "schema v6"

echo "  -- H. settings, backup, developer card"
check_file lib/features/settings/settings_screen.dart "settings screen"
check_file lib/features/backup/backup_screen.dart "backup screen"
check_file lib/features/backup/backup_codec.dart "backup zip/AES codec"
check_file lib/features/backup/csv_export.dart "CSV export"
check_grep "Samir Husayn" lib/features/settings/developer_card.dart "developer name"
check_grep "samirhusayn28-dev" lib/features/settings/developer_card.dart "GitHub username"
check_grep "maxWidth: 340" lib/features/settings/developer_card.dart "compact developer dialog"
check_grep "developer-dialog-close" lib/features/settings/developer_card.dart "dialog X close"
check_grep "sameerhussainsoomro22@gmail.com" lib/features/settings/developer_card.dart "developer email"
check_grep "mailto" android/app/src/main/AndroidManifest.xml "mailto query"

echo "  -- I. stats"
check_grep "StatsExportLayout" lib/features/stats/stats_screen.dart "full-height export layout"
check_grep "pixelRatio: 3" lib/features/stats/stats_screen.dart "high-DPI export"
check_grep "SharePlus" lib/features/stats/stats_screen.dart "share sheet export"
check_grep "'QUIN'" lib/features/stats/stats_comparison.dart "QUIN export footer"
check_grep "BentoRow" lib/features/stats/stats_screen.dart "bento grid"

echo "  -- J/K. onboarding, widgets"
check_file lib/features/onboarding/onboarding_screen.dart "onboarding"
check_grep "onboardingComplete" lib/data/settings/app_settings.dart "one-time onboarding flag"
check_grep "LaunchState" lib/router/app_router.dart "launch gating"
check_file lib/features/widgets_service/widget_config_screen.dart "home-screen widget config"
check_grep "HomeWidget" lib/features/widgets_service/widget_sync.dart "home widget bridge"
check_grep "vm:entry-point" lib/features/widgets_service/widget_callbacks.dart "widget isolate entry point"

echo "  -- M. whole-app themes"
check_grep "lavender" lib/data/settings/app_settings.dart "theme variant: lavender"
check_grep "ocean" lib/data/settings/app_settings.dart "theme variant: ocean"
check_grep "blush" lib/data/settings/app_settings.dart "theme variant: blush"
check_grep "latte" lib/data/settings/app_settings.dart "theme variant: latte"
check_grep "paperAlt" lib/core/theme/neo_theme.dart "themed sunken paper"
check_grep "sticker" lib/core/theme/neo_theme.dart "themed sticker colour"
check_grep "accentFor" lib/core/theme/app_theme.dart "theme picker previews accents"
check_absent lib/features/counters/counters_screen.dart "backgroundColor: NeoPalette.paper" "counters background follows theme"

echo "  -- N. auto count time slot"
check_grep "autoIntervalMs" lib/data/database/tables/counters.dart "auto-count slot column"
check_grep "autoCount" lib/data/database/tables/counters.dart "auto-count toggle column"
check_grep "_syncAutoTimer" lib/features/tally/western_tally_screen.dart "tally auto-count timer"
check_grep "auto-count-toggle-button" lib/features/tally/western_tally_screen.dart "in-counter manual/auto toggle"
check_grep "auto-count-settings-button" lib/features/tally/western_tally_screen.dart "in-counter time-slot editor"
check_grep "Auto count" lib/features/counters/counter_edit_screen.dart "auto-count option at creation"
check_grep "_slotMs" lib/features/counters/counter_edit_screen.dart "seconds/minutes slot conversion"
check_grep "'autoCount'" lib/features/backup/backup_models.dart "auto-count survives backup"

echo "  -- L. tests"
check_file test/widget/tally_tap_count_test.dart "taps 1..25 lock-step test"
check_file test/golden/tally_screen_golden_test.dart "tally screen goldens"
check_file test/widget/responsive_screens_test.dart "overflow tests at every size"
check_file test/widget/spec_interactions_test.dart "volume/swipe/onboarding tests"
check_file test/unit/backup_test.dart "backup export/import tests"
check_file integration_test/perf_test.dart "300-tap perf test"

echo
if [[ $failures -gt 0 ]]; then
  printf '\033[31mFAIL (%d of %d checks failed)\033[0m\n' "$failures" "$checks"
  exit 1
fi
printf '\033[32mPASS (%d checks)\033[0m\n' "$checks"
