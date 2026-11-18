import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the app is currently in the foreground (resumed).
///
/// Flipped by [LifecycleGate] through a [WidgetsBindingObserver]; animations
/// and tickers read it (via the root [TickerMode]) to pause when the app is
/// backgrounded, so no frame work happens off-screen.
final appForegroundProvider =
    NotifierProvider<AppForegroundController, bool>(AppForegroundController.new);

class AppForegroundController extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool value) {
    if (state != value) state = value;
  }
}

/// Pauses every ticker below it while the app is not resumed.
///
/// Uses a [WidgetsBindingObserver] so platform-driven lifecycle changes (which
/// do not always rebuild a widget) still stop the animations.
class LifecycleGate extends ConsumerStatefulWidget {
  const LifecycleGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LifecycleGate> createState() => _LifecycleGateState();
}

class _LifecycleGateState extends ConsumerState<LifecycleGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    ref.read(appForegroundProvider.notifier).set(foreground);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = ref.watch(appForegroundProvider);
    return TickerMode(enabled: foreground, child: widget.child);
  }
}
