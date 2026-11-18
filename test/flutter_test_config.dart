import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Shared entry point for every test in `test/`.
///
/// Leak tracking is switched on here but ignored by default; individual tests
/// opt in with `experimentalLeakTesting: LeakTesting.settings.withTrackedAll()`
/// (see `test/widget/leak_test.dart`).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTracking.warnForUnsupportedPlatforms = false;
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();
  await testMain();
}
