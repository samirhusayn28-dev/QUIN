import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/motion_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../data/providers.dart';
import '../../data/settings/app_settings.dart';
import '../../router/launch_state.dart';
import '../../tally_styles/registry.dart';
import '../tally/tally_mark.dart';
import '../widgets/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  late final AnimationController _countCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  int _page = 0;
  int _liveCount = 0;
  Timer? _countTimer;
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  int _accent = 0xFFFFD23F;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _startLiveCount();
  }

  @override
  void dispose() {
    _countTimer?.cancel();
    _pageController.dispose();
    _pulse.dispose();
    _countCtrl.dispose();
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _startLiveCount() {
    _liveCount = 0;
    _countTimer?.cancel();
    _countTimer = Timer.periodic(const Duration(milliseconds: 240), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _liveCount = (_liveCount + 1) % 26);
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = context.motion;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (p) {
                  setState(() => _page = p);
                  if (p == 0) _startLiveCount();
                  if (p == 1 || p == 2) {
                    _countTimer?.cancel();
                  }
                },
                children: <Widget>[
                  _page1(m),
                  _page2(m),
                  _page3(m),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(3, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: m.fast,
                        curve: m.snappy,
                        width: active ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: active ? NeoPalette.ink : NeoPalette.inkSoft.withValues(alpha: 0.3),
                          border: Border.all(color: NeoPalette.ink, width: 2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  NeoButton(
                    label: _page == 2 ? 'Create & Start' : 'Next',
                    variant: NeoButtonVariant.primary,
                    expand: true,
                    size: NeoButtonSize.large,
                    onPressed: _creating ? null : () async {
                      if (_page < 2) {
                        await _pageController.animateToPage(
                          _page + 1,
                          duration: m.medium,
                          curve: m.snappy,
                        );
                        return;
                      }
                      await _createFirst();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (_page > 0)
                        TextButton(
                          onPressed: _creating
                              ? null
                              : () => _pageController.animateToPage(
                                    0,
                                    duration: m.fast,
                                    curve: m.snappy,
                                  ),
                          child: Text('Back',
                              style: AppTypography.grotesk(
                                  size: 14, color: NeoPalette.inkSoft)),
                        )
                      else
                        const SizedBox.shrink(),
                      TextButton(
                        key: const Key('onboarding-skip'),
                        onPressed: _creating ? null : _skipOnboarding,
                        child: Text('Skip',
                            style: AppTypography.grotesk(
                                size: 14, color: NeoPalette.inkSoft)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page1(MotionTokens m) {
    return SpringEntrance(
      offset: const Offset(0, 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('QUIN', style: AppTypography.display(64, 1.0, -2)),
              const SizedBox(height: 8),
              Text('Count anything. Hand-drawn.',
                  style: AppTypography.grotesk(size: 20, weight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Four strokes and a slash — the oldest way to count.',
                  style: AppTypography.grotesk(size: 15, color: NeoPalette.inkSoft)),
              const SizedBox(height: 28),
              NeoCard(
                color: NeoPalette.yellow,
                child: RepaintBoundary(
                  child: SizedBox(
                    height: 220,
                    child: Center(
                      child: AnimatedScale(
                        scale: 1.0 + _pulse.value * 0.05,
                        duration: m.fast,
                        child: ActiveTallyGroup(
                          lineStyle: LineStyle.fallback,
                          marks: marksForCount(_liveCount),
                          color: NeoPalette.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tap to count. See the tally draw itself.', style: AppTypography.grotesk(size: 16)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page2(MotionTokens m) {
    return SpringEntrance(
      index: 1,
      offset: const Offset(0.08, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('One bold stroke', style: AppTypography.display(32, 1.06, -1.2)),
            const SizedBox(height: 8),
            Text('Four bars and a slash — the same tally, every time.',
                style: AppTypography.grotesk(size: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: NeoCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RepaintBoundary(
                      child: SizedBox(
                        height: 130,
                        child: Center(
                          child: LineStylePreview(
                            style: LineStyle.fallback,
                            color: NeoPalette.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _bullet('Four taps draw four bars.'),
                    _bullet('The fifth draws the diagonal slash.'),
                    _bullet('Five done, a fresh group starts.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: NeoPalette.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTypography.grotesk(size: 14.5)),
          ),
        ],
      ),
    );
  }

  Widget _page3(MotionTokens m) {
    final accentSwatches = <int>[0xFFFFD23F, 0xFFFF5C7A, 0xFF4D9DE0, 0xFF22C55E, 0xFFFF7A1A, 0xFF22D3EE];
    return SpringEntrance(
      index: 2,
      offset: const Offset(0.08, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Create your first counter', style: AppTypography.display(28, 1.08, -1.2)),
              const SizedBox(height: 8),
              Text('Give it a name and pick an accent.', style: AppTypography.grotesk(size: 16)),
              const SizedBox(height: 20),
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Name', style: AppTypography.grotesk(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    Text('Target (optional)', style: AppTypography.grotesk(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Accent color', style: AppTypography.grotesk(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: accentSwatches.map((c) {
                        final selected = _accent == c;
                        return GestureDetector(
                          onTap: () => setState(() => _accent = c),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              border: Border.all(color: NeoPalette.ink, width: selected ? 4 : 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Onboarding is a one-time thing: the flag is written the moment the user
  /// creates a counter *or* skips, and the app checks it (plus whether any
  /// counters already exist) before ever routing here again.
  Future<void> _skipOnboarding() async {
    await ref
        .read(databaseProvider)
        .setSetting(SettingsKeys.onboardingComplete, '1');
    // Unblock the router *before* navigating home, or the launch gate would
    // bounce us straight back here.
    LaunchState.onboardingDone = true;
    if (mounted) context.go('/');
  }

  Future<void> _createFirst() async {
    setState(() => _creating = true);
    final db = ref.read(databaseProvider);
    await db.setSetting(SettingsKeys.onboardingComplete, '1');
    LaunchState.onboardingDone = true;
    final target = int.tryParse(_targetCtrl.text);
    final name = _nameCtrl.text.trim().isEmpty ? 'My Counter' : _nameCtrl.text.trim();
    await db.createCounter(
      name: name,
      targetValue: target,
      lineStyle: LineStyle.fallback.id,
      accentColor: _accent,
    );
    if (!mounted) return;
    context.go('/');
  }
}
