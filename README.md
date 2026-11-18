# QUIN

A neo-brutalist Flutter tally counter with seven whole-app color themes, an auto-count time slot (seconds or minutes), home-screen widgets, lock-screen counting, history, stats, and local backups.

## Downloads

Prebuilt Android APKs are on the [Releases page](https://github.com/samirhusayn28-dev/QUIN/releases). Most phones need `QUIN-arm64-v8a-release.apk`.

## Prerequisites

- Flutter 3.x (stable or compatible with Dart 3.9+)
- Android Studio/Android SDK with build-tools 36.0.0 (or latest)
- Xcode for iOS (macOS)

## Setup

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd tally_counter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Run (profile for DevTools)

For performance profiling (DevTools):

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd tally_counter
flutter run --profile --device-id [DEVICE_ID]
```

## Android

### Build debug APK

```bash
flutter build apk --debug
```

### Build release APK (split per ABI, obfuscated)

```bash
flutter build apk --release --split-per-abi \
  --obfuscate --split-debug-info=build/symbols
```

The artifacts land in `build/app/outputs/flutter-apk/`; `scripts/check_size.sh`
reports their size (WARN above the ARM64 budget).

### Build App Bundle

```bash
flutter build appbundle --release
```

## Home-screen widget setup (Android)

1. Run the release APK on your device.
2. Long-press the home screen → Widgets → Tally Counter.
3. Add Small or Medium widget.
4. Tap the widget → Widget Configuration → select a counter.

The widget uses `home_widget` and writes to the same Drift DB via a background isolate.

## Lock-screen counting (Android)

Enable "Live count on lock screen" in Settings. This starts a persistent notification (with +1/−1 actions) visible on the lock screen.

## iOS

iOS requires the `TallyWidgetExtension` target in Xcode (not auto-added in CLI). See `ios/TallyWidgetExtension/README.md` for details.

## Quality gates

```bash
./scripts/verify.sh              # analyze + tests + size + feature lock
./scripts/verify.sh --skip-integration
PERF_DEVICE=<device-id> ./scripts/verify.sh
```

`verify.sh` prints one `PASS` / `FAIL` / `WARN` / `SKIP` line per step:

| Step | What it runs |
| --- | --- |
| analyze | `flutter analyze` |
| unit | `flutter test test/unit` |
| widget | `flutter test test/widget` (responsive matrix + leak tracking) |
| golden | `flutter test test/golden` |
| integration perf | `flutter test integration_test/perf_test.dart -d <device>` (SKIP without a physical device) |
| size | `./scripts/check_size.sh` (WARN above the ARM64 budget) |
| features | `./scripts/check_features.sh` (feature lock) |

## Performance notes

- Every screen is rendered at 360x640, 412x915, 768x1024 and 1280x800, at
  text scale 1.0/1.5, in light and dark, and must be overflow/exception free.
- The integration journey taps 200 times and opens every route while capturing
  frame timings; budgets are average build+raster < 8 ms, worst frame < 16 ms,
  cold start < 1.5 s, and the report is written to `/perf_report.json`.
- Hot paths: Drift indexes on `taps(counter_id, at)` and `taps(session_id)`,
  a paged history window (100 rows per page), `RepaintBoundary` around the
  stats terminal cards, Riverpod `select()` for the tally settings, cached
  fragment shaders warmed before `runApp`, and low-end device detection that
  disables the grain shader.
