import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/core/device/device_capabilities.dart';
import 'package:tally_counter/data/database/app_database.dart';
import 'package:tally_counter/data/providers.dart';

/// Channel names touched by the app's native bridges. Mocked so widget tests
/// never hit a real platform channel.
const List<String> _mockChannels = <String>[
  'tally_counter/volume',
  'tally_counter/notification',
  'tally_counter/device',
  'home_widget',
  'home_widget/background',
];

void mockPlatformChannels() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in _mockChannels) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (call) async => null);
  }
}

/// An in-memory database seeded with data so every data-driven screen renders
/// its *populated* state (and the tests can also render the empty state).
Future<AppDatabase> seededDatabase({bool withData = true}) async {
  final db = AppDatabase(NativeDatabase.memory());
  if (!withData) return db;

  final drinks = await db.createCounter(name: 'Drinks', accentColor: 0xFF45C4F5);
  final pushups = await db.createCounter(
    name: 'Pushups',
    accentColor: 0xFFFF5C8A,
    targetValue: 1000,
    startValue: 0,
  );
  await db.createCounter(
    name: 'Long Name Counter That Should Wrap Nicely On Narrow Screens',
    accentColor: 0xFFFFD23F,
    targetValue: 10000,
  );

  for (var i = 0; i < 23; i++) {
    await db.tapCounter(drinks.id);
  }
  for (var i = 0; i < 7; i++) {
    await db.tapCounter(pushups.id);
  }
  return db;
}

/// The most recent Flutter error captured while pumping a subject. Useful for
/// diagnosing overflow failures (the message alone omits the widget location).
FlutterErrorDetails? lastFlutterErrorDetails;

FlutterExceptionHandler? _previousErrorHandler;

void _captureError(FlutterErrorDetails details) {
  lastFlutterErrorDetails = details;
  _previousErrorHandler?.call(details);
}

/// Wraps the current [FlutterError.onError] so the harness can surface the full
/// diagnostics of an overflow. Safe to call repeatedly; re-wraps once per test
/// because the test binding restores its own handler between tests.
void _installErrorCapture() {
  if (FlutterError.onError == _captureError) return;
  _previousErrorHandler = FlutterError.onError;
  FlutterError.onError = _captureError;
}

/// Pumps [subject] inside a ProviderScope + MaterialApp with the given surface
/// size, text scale and brightness.
Future<void> pumpSubject(
  WidgetTester tester,
  Widget subject, {
  AppDatabase? db,
  Size size = const Size(412, 915),
  double textScale = 1.0,
  Brightness brightness = Brightness.light,
  bool reducedEffects = false,
}) async {
  _installErrorCapture();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final database = db ?? await seededDatabase();

  final theme = brightness == Brightness.dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        if (reducedEffects) reducedEffectsProvider.overrideWithValue(true),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: subject,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 60));
}
