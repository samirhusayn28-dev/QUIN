import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../features/tally/tally_mark.dart';
import '../../features/widgets/widgets.dart';
import '../../tally_styles/line_style.dart';
import '../../tally_styles/line_style_painter.dart';

/// Game-HUD style editor for the big number: drag it anywhere, with canva-style
/// smart guides that snap (and buzz) on the centre. Colour, size and opacity are
/// all saved per counter, and the real tally is drawn live behind it.
class NumberPositionScreen extends ConsumerStatefulWidget {
  const NumberPositionScreen({
    super.key,
    required this.counterId,
    this.initial = const NumberLayout(),
  });

  final String counterId;

  /// Optional starting layout, used when editing from the counter form before
  /// the counter has ever been saved with a HUD position.
  final NumberLayout initial;

  @override
  ConsumerState<NumberPositionScreen> createState() =>
      _NumberPositionScreenState();
}

/// A counter's number layout as plain values.
class NumberLayout {
  const NumberLayout({
    this.x = 0.5,
    this.y = 0.13,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.color,
  });

  final double x;
  final double y;
  final double scale;
  final double opacity;
  final int? color;
}

class _NumberPositionScreenState extends ConsumerState<NumberPositionScreen> {
  late double _x = widget.initial.x;
  late double _y = widget.initial.y;
  late double _scale = widget.initial.scale;
  late double _opacity = widget.initial.opacity;
  late int? _color = widget.initial.color;

  bool _dragging = false;
  bool _xLocked = false;
  bool _yLocked = false;
  Offset _grab = Offset.zero;
  bool _loaded = false;

  static const List<double> _guides = <double>[0.0, 1 / 3, 0.5, 2 / 3, 1.0];
  static const double _snap = 0.025;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final counter = await ref.read(databaseProvider).getCounter(widget.counterId);
    if (counter == null || !mounted) return;
    setState(() {
      _x = counter.numberPosX;
      _y = counter.numberPosY;
      _scale = counter.numberScale;
      _opacity = counter.numberOpacity;
      _color = counter.numberColor;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await ref.read(databaseProvider).updateCounter(
          id: widget.counterId,
          numberPosX: _x,
          numberPosY: _y,
          numberScale: _scale,
          numberOpacity: _opacity,
          numberColor: _color,
          clearNumberColor: _color == null,
        );
    if (mounted) Navigator.of(context).maybePop();
  }

  void _reset() {
    setState(() {
      _x = 0.5;
      _y = 0.13;
      _scale = 1.0;
      _opacity = 1.0;
      _color = null;
    });
    HapticFeedback.mediumImpact();
  }

  /// Snaps a free value to the nearest guide, reporting whether it locked.
  (double, bool) _snapTo(double value) {
    for (final g in _guides) {
      if ((value - g).abs() <= _snap) return (g, true);
    }
    return (value, false);
  }

  @override
  Widget build(BuildContext context) {
    final counterAsync = ref.watch(counterProvider(widget.counterId));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Number Position',
            style: AppTypography.display(20, 1.0, -0.4)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: NeoButton(
              label: 'Save',
              size: NeoButtonSize.small,
              variant: NeoButtonVariant.primary,
              onPressed: _loaded ? _save : null,
            ),
          ),
        ],
      ),
      body: counterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (counter) {
          if (counter == null) {
            return const Center(child: Text('Counter not found'));
          }
          return Column(
            children: <Widget>[
              Expanded(child: _editor(counter)),
              _controls(),
            ],
          );
        },
      ),
    );
  }

  Widget _editor(Counter counter) {
    final lineStyle = LineStyle.fromId(counter.lineStyle);
    final accent = Color(counter.accentColor);
    final value = counter.currentValue < 0 ? 0 : counter.currentValue;
    final remainder = value % kTallyGroupSize;
    final marks = value == 0 ? 0 : (remainder == 0 ? kTallyGroupSize : remainder);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final shortest = w < h ? w : h;
        final numSize =
            (shortest * 0.17 * _scale).clamp(30.0, 220.0).toDouble();
        final color = _color == null ? NeoPalette.ink : Color(_color!);
        final cx = _x * w;
        final cy = _y * h;
        final tallyWidth = (w * 0.8).clamp(120.0, 460.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) {
            final center = Offset(cx, cy);
            _grab = d.localPosition - center;
            setState(() => _dragging = true);
          },
          onPanUpdate: (d) {
            var nx = ((d.localPosition.dx - _grab.dx) / w).clamp(0.04, 0.96);
            var ny = ((d.localPosition.dy - _grab.dy) / h).clamp(0.04, 0.96);
            final (sx, xLocked) = _snapTo(nx);
            final (sy, yLocked) = _snapTo(ny);
            nx = sx;
            ny = sy;
            if (xLocked && !_xLocked) HapticFeedback.selectionClick();
            if (yLocked && !_yLocked) HapticFeedback.selectionClick();
            setState(() {
              _x = nx;
              _y = ny;
              _xLocked = xLocked;
              _yLocked = yLocked;
            });
          },
          onPanEnd: (_) => setState(() {
            _dragging = false;
            _xLocked = false;
            _yLocked = false;
          }),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _GuidePainter(
                    activeX: _xLocked ? _x : null,
                    activeY: _yLocked ? _y : null,
                    visible: _dragging,
                    color: accent,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: tallyWidth,
                  height: tallyWidth / 1.9,
                  child: ActiveTallyGroup(
                    lineStyle: lineStyle,
                    marks: marks,
                    color: accent,
                  ),
                ),
              ),
              Positioned(
                left: cx,
                top: cy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _opacity.clamp(0.05, 1.0).toDouble(),
                      child: Container(
                        decoration: _dragging
                            ? BoxDecoration(
                                border: Border.all(
                                  color: NeoPalette.pink,
                                  width: 2,
                                ),
                              )
                            : null,
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          _loaded ? '${counter.currentValue}' : '—',
                          style: AppTypography.display(numSize, 1.0, -1)
                              .copyWith(color: color),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 10,
                child: Text(
                  'Drag the number — guides snap on the centre',
                  style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _controls() {
    return NeoCard(
      color: context.neo.paperAlt,
      shadowOffset: Offset.zero,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('NUMBER COLOUR',
              style: AppTypography.grotesk(
                  size: 11, weight: FontWeight.w700, spacing: 1.1)),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                _swatch(null, 'Auto'),
                for (final c in NeoPalette.stickers) _swatch(c.toARGB32(), null),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _slider(
            'Size',
            _scale,
            0.6,
            2.2,
            (v) => setState(() => _scale = v),
          ),
          _slider(
            'Opacity',
            _opacity,
            0.2,
            1.0,
            (v) => setState(() => _opacity = v),
          ),
        ],
      ),
    );
  }

  Widget _swatch(int? value, String? label) {
    final selected = _color == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _color = value),
        child: Container(
          width: 52,
          decoration: BoxDecoration(
            color: value == null ? NeoPalette.paper : Color(value),
            border: Border.all(
              color: selected ? NeoPalette.pink : NeoPalette.ink,
              width: selected ? 4 : 2,
            ),
            borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          ),
          alignment: Alignment.center,
          child: label == null
              ? null
              : Text(label,
                  style: AppTypography.grotesk(
                      size: 12, weight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 66,
          child: Text(label,
              style: AppTypography.grotesk(size: 13, weight: FontWeight.w700)),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: NeoPalette.ink,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(value.toStringAsFixed(2),
              textAlign: TextAlign.end,
              style: AppTypography.mono(size: 11)),
        ),
      ],
    );
  }
}

/// Canva-style smart guides: edge, thirds and centre lines, with the line the
/// number is currently locked to highlighted.
class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.activeX,
    required this.activeY,
    required this.visible,
    required this.color,
  });

  final double? activeX;
  final double? activeY;
  final bool visible;
  final Color color;

  static const List<double> _lines = <double>[0.0, 1 / 3, 0.5, 2 / 3, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final faint = Paint()
      ..color = NeoPalette.ink.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    final strong = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (final f in _lines) {
      final x = f * size.width;
      final isActive = activeX != null && (activeX! - f).abs() < 0.001;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isActive ? strong : faint,
      );
      final y = f * size.height;
      final activeYLine = activeY != null && (activeY! - f).abs() < 0.001;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        activeYLine ? strong : faint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) =>
      old.visible != visible ||
      old.activeX != activeX ||
      old.activeY != activeY ||
      old.color != color;
}
