import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/settings/app_settings.dart';
import '../../data/settings/settings_provider.dart';
import '../../features/widgets/widgets.dart';
import '../../tally_styles/line_style.dart';
import '../../tally_styles/line_style_painter.dart';
import 'celebration.dart';
import 'tally_mark.dart';
import 'volume_buttons.dart';

/// The tally screen.
///
/// The counter row is the single source of truth: the number, the active group
/// and the completed grid are all derived from it, so they can never disagree.
/// A tap updates in-memory state first (instant, never blocking on the
/// database), then the coalescing writer persists the burst off the UI path.
///
/// Nothing here paints a paper or a texture behind the tally — the marks sit
/// straight on the app's background. The completed groups are a faint, lightly
/// blurred background layer, and their opacity rides on the mark colour instead
/// of a separate opacity widget.
class WesternTallyScreen extends ConsumerStatefulWidget {
  const WesternTallyScreen({
    super.key,
    required this.counterId,
    this.enableKeepAwake = true,
  });

  final String counterId;
  final bool enableKeepAwake;

  @override
  ConsumerState<WesternTallyScreen> createState() => _WesternTallyScreenState();
}

class _WesternTallyScreenState extends ConsumerState<WesternTallyScreen>
    with TickerProviderStateMixin {
  /// Pulses *only* the newest mark when a plain tap lands.
  late final AnimationController _markCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  );

  late final AnimationController _celebrationCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  /// Drives the 5th-tap sequence: the diagonal sweeps (~150 ms), holds
  /// (~400 ms), then the whole group shrinks and slides into the grid.
  late final AnimationController _groupSpin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  /// Drives the two per-frame animations that live *inside* the active tally:
  /// the newest-mark pulse (`_markCtrl`) and the fifth-tap slide
  /// (`_groupSpin`). Subscribing here — instead of calling `setState` — keeps a
  /// pulse from rebuilding the grid, the number or the top bar.
  late final Listenable _tallyMotion =
      Listenable.merge(<Listenable>[_markCtrl, _groupSpin]);

  final ScrollController _gridController = ScrollController();

  /// The value we are optimistically showing while writes are in flight.
  int? _optimistic;

  /// Presses applied locally but not yet written.
  int _pending = 0;
  bool _flushing = false;

  /// The value whose freshly-completed group is animating into the grid.
  int? _spinValue;

  bool? _volumeCapture;
  VoidCallback? _disposeVolume;

  final Debouncer _volumeGate = Debouncer(const Duration(milliseconds: 150));
  final Debouncer _accidentGate = Debouncer(const Duration(milliseconds: 120));

  /// The auto-count timer: non-null only while the counter is set to count
  /// itself. [_syncAutoTimer] keeps it aligned with the counter's toggle +
  /// time slot on every rebuild, so a manual count never restarts it.
  Timer? _autoTimer;
  int _autoTimerMs = 0;

  /// Fractions of the 5th-tap sequence (sweep ≈150 ms, hold ≈400 ms).
  static const double _diagonalEnd = 0.18;
  static const double _holdEnd = 0.65;
  static const double _topBarHeight = 56;

  /// Width ÷ height of a group's real bounding box, derived from the painter's
  /// own ratios (4 gaps + overhang each side + stroke).
  static const double _groupAspect = 1.0754;

  /// The active group is deliberately smaller than the old full-bleed one.
  static const double _activeScale = 0.55;

  /// The completed-groups background layer: faint, evenly spread.
  static const double _completedOpacity = 0.18;

  @override
  void initState() {
    super.initState();
    _groupSpin.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _spinValue != null &&
          mounted) {
        setState(() => _spinValue = null);
      }
    });
    if (widget.enableKeepAwake) _setWakelock(true);
    _disposeVolume = VolumeButtons.listen(_onVolume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _configureVolume(ref.read(appSettingsProvider).volumeButtonCounting);
    });
  }

  Future<void> _configureVolume(bool enabled) async {
    if (_volumeCapture == enabled) return;
    _volumeCapture = enabled;
    await VolumeButtons.setEnabled(enabled);
  }

  void _setWakelock(bool on) {
    WakelockPlus.toggle(enable: on).catchError((Object _) {});
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _markCtrl.dispose();
    _celebrationCtrl.dispose();
    _groupSpin.dispose();
    _gridController.dispose();
    _disposeVolume?.call();
    if (_volumeCapture == true) {
      VolumeButtons.setEnabled(false);
    }
    if (widget.enableKeepAwake) _setWakelock(false);
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Instant tap path
  // -------------------------------------------------------------------------

  void _scheduleFlush() {
    if (_flushing) return;
    scheduleMicrotask(_flush);
  }

  /// Persists the coalesced burst in a single transaction, off the UI path.
  Future<void> _flush() async {
    if (_flushing) return;
    _flushing = true;
    final db = ref.read(databaseProvider);
    while (_pending != 0) {
      final n = _pending;
      _pending = 0;
      try {
        await db.tapCounterBatch(widget.counterId, n);
      } catch (_) {
        _flushing = false;
        return;
      }
    }
    _flushing = false;
    if (mounted && _pending == 0) {
      final current = ref.read(counterProvider(widget.counterId)).value;
      if (current != null && current.currentValue == _optimistic) {
        setState(() => _optimistic = null);
      }
    }
  }

  /// Applies [n] presses to in-memory state immediately, then queues the write.
  void _count([int n = 1]) {
    final counter = ref.read(counterProvider(widget.counterId)).value;
    if (counter == null) return;
    final prefs = ref.read(appSettingsProvider);

    if (prefs.accidentalTapProtection && !_accidentGate.allow()) return;

    final from = _optimistic ?? counter.currentValue;
    final next = from + n * counter.stepSize * counter.direction;
    setState(() => _optimistic = next);

    _pending += n;
    _scheduleFlush();

    if (prefs.sound) SystemSound.play(SystemSoundType.click);

    final groupDone = next > 0 && next % kTallyGroupSize == 0;
    if (prefs.haptics) {
      if (groupDone) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }

    if (groupDone && _spinValue != next) {
      setState(() => _spinValue = next);
      _groupSpin
        ..reset()
        ..forward();
    } else {
      _markCtrl.forward(from: 0);
    }

    if (counter.targetValue != null && counter.celebrateOnTarget) {
      final d = counter.direction;
      final reached = (d == 1 && next >= counter.targetValue!) ||
          (d == -1 && next <= counter.targetValue!);
      if (reached) {
        _celebrationCtrl.forward(from: 0);
        if (prefs.haptics) HapticFeedback.heavyImpact();
        if (counter.autoArchive) {
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            ref
                .read(databaseProvider)
                .updateCounter(id: widget.counterId, archived: true);
          });
        }
      }
    }
  }

  /// The single hardware-volume entry point: one press, at most one count.
  void _onVolume(bool up) {
    if (!_volumeGate.allow()) return;
    _count(up ? 1 : -1);
  }

  void _onUndo() {
    final counter = ref.read(counterProvider(widget.counterId)).value;
    if (counter == null) return;
    final prefs = ref.read(appSettingsProvider);
    final from = _optimistic ?? counter.currentValue;
    final next = from - counter.stepSize * counter.direction;
    setState(() {
      _optimistic = next;
      _spinValue = null;
      _groupSpin.reset();
    });
    _pending -= 1;
    _scheduleFlush();
    if (prefs.haptics) HapticFeedback.lightImpact();
  }

  Future<void> _onReset() async {
    final prefs = ref.read(appSettingsProvider);
    final ok = await showNeoConfirm(
      context: context,
      title: 'Reset counter?',
      message: 'This cannot be undone.',
      accent: NeoPalette.red,
      icon: Icons.restart_alt_rounded,
    );
    if (!ok) return;
    _optimistic = null;
    _pending = 0;
    await ref.read(counterActionsProvider).reset(widget.counterId);
    if (!mounted) return;
    setState(() {
      _spinValue = null;
      _groupSpin.reset();
    });
    if (prefs.haptics) HapticFeedback.heavyImpact();
  }

  // -------------------------------------------------------------------------
  // Auto-count timer
  // -------------------------------------------------------------------------

  /// Aligns the periodic timer with the counter's current toggle + time slot.
  ///
  /// Called from the data branch on every rebuild. It is a no-op while the
  /// timer already matches, so the per-tap stream updates never churn it, and
  /// switching auto off cancels within the same frame as the write.
  void _syncAutoTimer(Counter counter) {
    final want = counter.autoCount ? counter.autoIntervalMs : 0;
    if (want <= 0) {
      if (_autoTimer != null) {
        _autoTimer!.cancel();
        _autoTimer = null;
        _autoTimerMs = 0;
      }
      return;
    }
    if (_autoTimer != null && _autoTimerMs == want) return;
    _autoTimer?.cancel();
    _autoTimerMs = want;
    _autoTimer = Timer.periodic(Duration(milliseconds: want), (_) {
      if (!mounted) {
        _autoTimer?.cancel();
        _autoTimer = null;
        _autoTimerMs = 0;
        return;
      }
      _count(1);
    });
  }

  /// The top-bar toggle: manual ↔ automatic, written straight to the counter.
  Future<void> _toggleAutoCount(Counter counter) async {
    final prefs = ref.read(appSettingsProvider);
    final next = !counter.autoCount;
    if (!next) {
      _autoTimer?.cancel();
      _autoTimer = null;
      _autoTimerMs = 0;
    }
    if (prefs.haptics) HapticFeedback.selectionClick();
    await ref
        .read(databaseProvider)
        .updateCounter(id: counter.id, autoCount: next);
    // The stream rebuilds this screen, which runs _syncAutoTimer; kick a
    // rebuild explicitly too so enabling is instant even before the write
    // lands on small delays.
    if (mounted) setState(() {});
  }

  /// Time-slot editor: change the slot (and the toggle) while counting.
  Future<void> _openAutoCountSettings(Counter counter) async {
    await showNeoDialog<void>(
      context: context,
      builder: (context) => _AutoCountDialog(
        initialAuto: counter.autoCount,
        initialMs: counter.autoIntervalMs,
        onSave: (auto, intervalMs) async {
          if (!auto) {
            _autoTimer?.cancel();
            _autoTimer = null;
            _autoTimerMs = 0;
          }
          await ref.read(databaseProvider).updateCounter(
                id: counter.id,
                autoCount: auto,
                autoIntervalMs: intervalMs,
              );
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appSettingsProvider.select((s) => (
          tapArea: s.tapArea,
        )));

    // Once the stream has caught up with our optimistic value, hand control
    // back to the database row.
    ref.listen(counterProvider(widget.counterId), (_, next) {
      final v = next.value;
      if (v != null &&
          _optimistic != null &&
          v.currentValue == _optimistic &&
          _pending == 0 &&
          !_flushing) {
        setState(() => _optimistic = null);
      }
    });

    final counterAsync = ref.watch(counterProvider(widget.counterId));

    return counterAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Error'))),
      data: (counter) {
        if (counter == null) {
          return const Scaffold(body: Center(child: Text('Counter not found')));
        }
        // Keep the auto-count timer aligned with the counter's toggle + slot.
        _syncAutoTimer(counter);
        final total = _optimistic ?? counter.currentValue;
        final lineStyle = LineStyle.fromId(counter.lineStyle);
        final accent = Color(counter.accentColor);
        final shown = total < 0 ? 0 : total;
        final groups = shown ~/ kTallyGroupSize;
        final remainder = shown % kTallyGroupSize;
        final spinning = _groupSpin.isAnimating &&
            _spinValue == shown &&
            shown > 0 &&
            remainder == 0;

        final gridGroups = spinning ? (groups - 1).clamp(0, groups) : groups;
        final activeMarks = spinning ? kTallyGroupSize : remainder;

        return CelebrationOverlay(
          controller: _celebrationCtrl,
          color: accent,
          child: Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final shortest = math.min(w, h);

                  // The whole body below the top bar is the tap area.
                  final band = Rect.fromLTRB(0, _topBarHeight, w, h);

                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Completed groups are the *background*: they start at the
                      // very top, fill left → right → down, are faint and
                      // lightly blurred, and never take a pointer event.
                      _completedGroups(gridGroups, lineStyle),
                      _completedLabel(groups),
                      // The in-progress group sits in front, centred.
                      _activeTally(band, lineStyle, activeMarks, spinning),
                      // Translucent, and above the background layer: a tap
                      // counts while a drag still scrolls nothing underneath.
                      _tapTarget(prefs.tapArea),
                      // The big number is painted last so it overlays
                      // everything, but it is `IgnorePointer`, so it never
                      // swallows a tap.
                      _buildTotal(counter, accent, band, shortest),
                      _topBar(counter, accent, shown),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// A small, subtle "Completed: N" readout in the top-left of the tally area.
  Widget _completedLabel(int groups) {
    return Positioned(
      top: _topBarHeight + 4,
      left: 12,
      child: IgnorePointer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.check_circle_outline,
              size: 14,
              color: NeoPalette.muted,
            ),
            const SizedBox(width: 6),
            Text(
              'Completed: $groups',
              style: AppTypography.grotesk(size: 11, color: NeoPalette.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tapTarget(TapArea area) {
    final detector = GestureDetector(
      key: const Key('tally-tap-target'),
      behavior: HitTestBehavior.translucent,
      onTap: _count,
      onLongPress: _onUndo,
      child: const SizedBox.expand(),
    );
    if (area == TapArea.large) return Positioned.fill(child: detector);
    return Positioned.fill(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: area.fraction,
          heightFactor: area.fraction,
          child: detector,
        ),
      ),
    );
  }

  Widget _topBar(Counter counter, Color accent, int shown) {
    return Positioned(
      top: 0,
      left: 8,
      right: 8,
      height: _topBarHeight,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              counter.name,
              style: AppTypography.grotesk(size: 18, weight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (counter.targetValue != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                border: Border.all(color: NeoPalette.ink, width: 2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$shown / ${counter.targetValue}',
                style: AppTypography.mono(size: 12),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
            onPressed: _onUndo,
          ),
          IconButton(
            key: const Key('auto-count-toggle-button'),
            icon: Icon(
              counter.autoCount ? Icons.timer : Icons.timer_outlined,
              color: counter.autoCount ? accent : NeoPalette.inkSoft,
            ),
            tooltip:
                counter.autoCount ? 'Auto count: on' : 'Auto count: off',
            onPressed: () => _toggleAutoCount(counter),
          ),
          IconButton(
            key: const Key('auto-count-settings-button'),
            icon: const Icon(Icons.more_time, color: NeoPalette.inkSoft),
            tooltip: 'Auto count settings',
            onPressed: () => _openAutoCountSettings(counter),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset',
            onPressed: _onReset,
          ),
          IconButton(
            key: const Key('number-position-editor-button'),
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Number position',
            onPressed: () => context.push('/counter/${counter.id}/number'),
          ),
        ],
      ),
    );
  }

  Widget _activeTally(
    Rect band,
    LineStyle lineStyle,
    int marks,
    bool spinning,
  ) {
    // The active group is ~45% smaller than the old full-bleed one.
    final full = math.min(band.width * 0.9, band.height * 0.82 * _groupAspect);
    final width = full * _activeScale;
    final height = width / _groupAspect;

    return Positioned.fromRect(
      rect: band,
      child: IgnorePointer(
        child: Center(
          // Only this small subtree rebuilds per frame while a pulse or the
          // fifth-tap slide runs — the grid, number and top bar never do.
          child: AnimatedBuilder(
            animation: _tallyMotion,
            builder: (context, _) {
              var scale = 1.0;
              var dy = 0.0;
              if (spinning && _groupSpin.isAnimating) {
                final v = _groupSpin.value;
                if (v > _holdEnd) {
                  final t = ((v - _holdEnd) / (1 - _holdEnd)).clamp(0.0, 1.0);
                  scale = 1 - 0.62 * Curves.easeInBack.transform(t);
                  dy = band.height * 0.3 * Curves.easeIn.transform(t);
                }
              }
              // The diagonal sweeps, then the whole group shrinks and slides
              // into the grid; at rest the diagonal is fully drawn.
              final fifth = spinning
                  ? Curves.easeOut
                      .transform((_groupSpin.value / _diagonalEnd).clamp(0.0, 1.0))
                  : 1.0;
              // Only the newest mark pulses; it must read the live controller
              // value each frame, otherwise it would freeze at scale 0.
              final newest = _markCtrl.isAnimating
                  ? Curves.easeOutBack.transform(_markCtrl.value)
                  : 1.0;

              return RepaintBoundary(
                child: Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, dy),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: ActiveTallyGroup(
                        lineStyle: lineStyle,
                        marks: marks,
                        fifthProgress: fifth,
                        newestScale: newest,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Completed groups as the *background*: no border, no box.
  ///
  /// They start at the very top of the body, fill left → right → downward, are
  /// faint and lightly blurred, and never take a pointer event. The whole layer
  /// lives in one repaint boundary, so a tap never repaints it — it repaints
  /// only when a group completes (or it auto-scrolls to the newest one).
  Widget _completedGroups(int groups, LineStyle lineStyle) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: _GroupGrid(
              groups: groups,
              lineStyle: lineStyle,
              scrollController: _gridController,
              color: NeoPalette.ink.withValues(alpha: _completedOpacity),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotal(
    Counter counter,
    Color accent,
    Rect band,
    double shortest,
  ) {
    final size =
        (shortest * 0.17 * counter.numberScale).clamp(44.0, 220.0).toDouble();
    final color =
        counter.numberColor == null ? NeoPalette.ink : Color(counter.numberColor!);
    final opacity = counter.numberOpacity.clamp(0.05, 1.0).toDouble();
    // No `Opacity` widget on the tally screen: alpha rides on the colour.
    final style = AppTypography.display(size, 1.0, -1)
        .copyWith(color: color.withValues(alpha: opacity));
    final cx = band.left + counter.numberPosX.clamp(0.0, 1.0) * band.width;
    final cy = band.top + counter.numberPosY.clamp(0.08, 0.92) * band.height;

    return Positioned(
      left: cx,
      top: cy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: IgnorePointer(
          child: RepaintBoundary(
            // Hero pair with the counter card, so tapping a card grows its
            // number into the tally screen instead of cutting.
            child: Hero(
              tag: 'counter-${counter.id}',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RollingOdometer(
                    value: _optimistic ?? counter.currentValue,
                    style: style,
                    color: style.color ?? color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The completed-groups grid: a faint background layer that fills top-left →
/// right → downward, lazily builds only what is visible, and keeps the newest
/// group in view without re-laying-out the older ones.
class _GroupGrid extends StatelessWidget {
  const _GroupGrid({
    required this.groups,
    required this.lineStyle,
    required this.scrollController,
    required this.color,
  });

  final int groups;
  final LineStyle lineStyle;
  final ScrollController scrollController;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (groups <= 0) return const SizedBox.shrink();
    return _AutoScrollingGrid(
      itemCount: groups,
      controller: scrollController,
      builder: (context, i) => CompletedGroupMark(
        lineStyle: lineStyle,
        color: color,
      ),
    );
  }
}

class _AutoScrollingGrid extends StatefulWidget {
  const _AutoScrollingGrid({
    required this.itemCount,
    required this.builder,
    required this.controller,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) builder;
  final ScrollController controller;

  @override
  State<_AutoScrollingGrid> createState() => _AutoScrollingGridState();
}

class _AutoScrollingGridState extends State<_AutoScrollingGrid> {
  @override
  void didUpdateWidget(covariant _AutoScrollingGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount > oldWidget.itemCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.controller.hasClients) return;
        widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: widget.controller,
      padding: EdgeInsets.zero,
      // The layer never takes a gesture; it is scrolled programmatically to
      // keep the newest group visible, so taps and drags always count/scroll
      // nothing beneath it.
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 48,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: widget.itemCount,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: widget.builder,
    );
  }
}

/// The auto-count settings dialog reached from the tally top bar: a toggle
/// (manual ↔ automatic) plus the time slot — any number of seconds or
/// minutes — that the timer uses. The slot survives dialog closes (it is
/// written on Save only), and sub-second entries clamp to one second.
class _AutoCountDialog extends StatefulWidget {
  const _AutoCountDialog({
    required this.initialAuto,
    required this.initialMs,
    required this.onSave,
  });

  final bool initialAuto;
  final int initialMs;
  final Future<void> Function(bool auto, int intervalMs) onSave;

  @override
  State<_AutoCountDialog> createState() => _AutoCountDialogState();
}

class _AutoCountDialogState extends State<_AutoCountDialog> {
  late bool _auto;
  late String _unit; // 's' = seconds, 'm' = minutes
  late final TextEditingController _slotCtrl;

  @override
  void initState() {
    super.initState();
    _auto = widget.initialAuto;
    final ms = widget.initialMs;
    if (ms >= 60000 && ms % 60000 == 0) {
      _unit = 'm';
      _slotCtrl = TextEditingController(text: '${ms ~/ 60000}');
    } else {
      _unit = 's';
      final sec = (ms / 1000).round();
      _slotCtrl = TextEditingController(text: '${sec < 1 ? 1 : sec}');
    }
  }

  @override
  void dispose() {
    _slotCtrl.dispose();
    super.dispose();
  }

  /// The typed slot in milliseconds; anything below 1 unit clamps to one
  /// second so a timer can never spin at sub-second speed.
  int get _ms {
    final v = int.tryParse(_slotCtrl.text.trim()) ?? 0;
    final n = v < 1 ? 1 : v;
    return _unit == 'm' ? n * 60000 : n * 1000;
  }

  void _switchUnit(String unit) {
    if (unit == _unit) return;
    final v = int.tryParse(_slotCtrl.text.trim()) ?? 1;
    final n = v < 1 ? 1 : v;
    setState(() {
      if (unit == 'm') {
        final minutes = (n / 60).ceil();
        _slotCtrl.text = '${minutes < 1 ? 1 : minutes}';
        _unit = 'm';
      } else {
        _slotCtrl.text = '${n * 60}';
        _unit = 's';
      }
    });
  }

  void _save() {
    Navigator.of(context).pop();
    widget.onSave(_auto, _ms);
  }

  @override
  Widget build(BuildContext context) {
    final n = _slotCtrl.text.trim().isEmpty ? '1' : _slotCtrl.text.trim();
    final unitWord = _unit == 'm'
        ? (n == '1' ? 'minute' : 'minutes')
        : (n == '1' ? 'second' : 'seconds');
    return NeoDialog(
      title: 'Auto count',
      icon: Icons.timer_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NeoToggleTile(
            title: 'Auto count',
            subtitle: 'Off = manual taps · On = counts itself',
            value: _auto,
            onChanged: (v) => setState(() => _auto = v),
          ),
          const SizedBox(height: 14),
          Text('Time slot',
              style:
                  AppTypography.grotesk(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _slotCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '1',
                    filled: true,
                    fillColor: context.neo.paperAlt,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(NeoPalette.radiusSmall),
                      borderSide:
                          const BorderSide(color: NeoPalette.ink, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  style: AppTypography.grotesk(size: 16),
                ),
              ),
              const SizedBox(width: 10),
              NeoChip(
                label: 'Seconds',
                selected: _unit == 's',
                color: NeoPalette.orange,
                onTap: () => _switchUnit('s'),
              ),
              const SizedBox(width: 8),
              NeoChip(
                label: 'Minutes',
                selected: _unit == 'm',
                color: NeoPalette.orange,
                onTap: () => _switchUnit('m'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Adds 1 automatically after every $n $unitWord while auto count is on.',
            style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
          ),
        ],
      ),
      actions: <Widget>[
        NeoButton(
          label: 'Cancel',
          variant: NeoButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        NeoButton(
          label: 'Save',
          variant: NeoButtonVariant.primary,
          onPressed: _save,
        ),
      ],
    );
  }
}
