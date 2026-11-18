/// Launch-time state resolved in `main()` before the first frame.
///
/// The onboarding decision needs two async lookups (the persisted flag and the
/// counter count), so it is computed once at startup and then read
/// synchronously by the router. The defaults keep tests and secondary entry
/// points on the counters list unless they deliberately opt in.
class LaunchState {
  LaunchState._();

  /// Where the app opens. `/` unless this is a fresh install.
  static String initialLocation = '/';

  /// Whether onboarding has been completed (or skipped) already. `true` by
  /// default so unit/widget tests are not redirected into onboarding.
  static bool onboardingDone = true;

  /// Applies the startup decision: onboarding only for a genuinely new user
  /// who has no counters and has never finished (or skipped) setup.
  static void apply({
    required bool flagSet,
    required bool hasCounters,
  }) {
    onboardingDone = flagSet || hasCounters;
    initialLocation = onboardingDone ? '/' : '/onboarding';
  }
}
