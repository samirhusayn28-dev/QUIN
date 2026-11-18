import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/providers.dart';
import '../../features/widgets/widgets.dart';
import '../../tally_styles/registry.dart';
import '../tally/number_position_screen.dart';

class CounterEditScreen extends ConsumerStatefulWidget {
  const CounterEditScreen({super.key, this.counterId});

  final String? counterId;

  @override
  ConsumerState<CounterEditScreen> createState() => _CounterEditScreenState();
}

class _CounterEditScreenState extends ConsumerState<CounterEditScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late final AnimationController _previewCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  bool _isUp = true;
  int _startValue = 0;
  int? _targetValue;
  int _stepSize = 1;
  int _accentColor = 0xFFFFD23F;
  String _lineStyle = LineStyle.fallback.id;
  bool _autoArchive = false;
  bool _celebrateOnTarget = true;

  /// Auto-count time slot: the tally counts +1 by itself after every slot.
  bool _autoCount = false;
  late final TextEditingController _autoSlotCtrl =
      TextEditingController(text: '1');
  String _autoSlotUnit = 's'; // 's' = seconds, 'm' = minutes

  Map<String, Object?>? _initialSnapshot;

  Map<String, Object?> _snapshot() => <String, Object?>{
        'name': _nameCtrl.text,
        'desc': _descCtrl.text,
        'isUp': _isUp,
        'start': _startValue,
        'target': _targetValue,
        'step': _stepSize,
        'accent': _accentColor,
        'style': _lineStyle,
        'autoArchive': _autoArchive,
        'celebrate': _celebrateOnTarget,
        'autoCount': _autoCount,
        'autoSlotMs': _autoCount ? _slotMs() : 0,
      };

  bool get _dirty =>
      _initialSnapshot != null && !mapEquals(_initialSnapshot, _snapshot());

  @override
  void initState() {
    super.initState();
    if (widget.counterId != null) {
      _loadCounter();
    } else {
      _initialSnapshot = _snapshot();
      _previewCtrl.forward();
    }
  }

  Future<void> _loadCounter() async {
    final c = await ref.read(databaseProvider).watchCounter(widget.counterId!).first;
    if (c != null && mounted) {
      setState(() {
        _nameCtrl.text = c.name;
        _descCtrl.text = c.description ?? '';
        _startValue = c.startValue;
        _targetValue = c.targetValue;
        _isUp = c.direction == 1;
        _stepSize = c.stepSize;
        _accentColor = c.accentColor;
        _lineStyle = c.lineStyle;
        _autoArchive = c.autoArchive;
        _celebrateOnTarget = c.celebrateOnTarget;
        _autoCount = c.autoCount;
        _applyIntervalMs(c.autoIntervalMs);
      });
      _initialSnapshot = _snapshot();
      _previewCtrl.forward();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _autoSlotCtrl.dispose();
    _previewCtrl.dispose();
    super.dispose();
  }

  /// The chosen time slot in milliseconds (seconds ×1000, minutes ×60000).
  int _slotMs() {
    final v = int.tryParse(_autoSlotCtrl.text.trim()) ?? 0;
    final n = v < 1 ? 1 : v;
    return _autoSlotUnit == 'm' ? n * 60000 : n * 1000;
  }

  /// Seeds the slot fields from a stored millisecond value: whole minutes
  /// read as minutes, everything else as seconds.
  void _applyIntervalMs(int ms) {
    if (ms >= 60000 && ms % 60000 == 0) {
      _autoSlotUnit = 'm';
      _autoSlotCtrl.text = '${ms ~/ 60000}';
    } else {
      _autoSlotUnit = 's';
      final sec = (ms / 1000).round();
      _autoSlotCtrl.text = '${sec < 1 ? 1 : sec}';
    }
  }

  /// Toggles the unit, converting the typed value so the slot never silently
  /// changes meaning (5 seconds becomes 1 minute, not 5 minutes).
  void _switchUnit(String unit) {
    if (unit == _autoSlotUnit) return;
    final v = int.tryParse(_autoSlotCtrl.text.trim()) ?? 1;
    final n = v < 1 ? 1 : v;
    setState(() {
      if (unit == 'm') {
        final minutes = (n / 60).ceil();
        _autoSlotCtrl.text = '${minutes < 1 ? 1 : minutes}';
        _autoSlotUnit = 'm';
      } else {
        _autoSlotCtrl.text = '${n * 60}';
        _autoSlotUnit = 's';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.counterId != null;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Back',
            onPressed: _handleBack,
          ),
          title: Text(isEditing ? 'Edit Counter' : 'New Counter',
              style: AppTypography.grotesk(size: 18, weight: FontWeight.w700)),
          actions: <Widget>[
            NeoButton(
              label: isEditing ? 'Save' : 'Create',
              size: NeoButtonSize.small,
              variant: NeoButtonVariant.primary,
              onPressed: _save,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: AnimatedBuilder(
          animation: _previewCtrl,
          builder: (context, _) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPreview(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _sectionTitle('Identity'),
                          const SizedBox(height: 8),
                          _buildNameField(),
                          const SizedBox(height: 12),
                          _buildDescriptionField(),
                          const SizedBox(height: 24),
                          _sectionTitle('Counting'),
                          const SizedBox(height: 8),
                          _buildCountingFields(),
                          const SizedBox(height: 24),
                          _sectionTitle('Auto count'),
                          const SizedBox(height: 8),
                          _buildAutoCountFields(),
                          const SizedBox(height: 24),
                          _sectionTitle('Theme'),
                          const SizedBox(height: 8),
                          _buildThemeFields(),
                          const SizedBox(height: 24),
                          _sectionTitle('Behavior'),
                          const SizedBox(height: 8),
                          _buildStyleFields(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// System back / close button. Prompts before discarding unsaved edits.
  Future<void> _handleBack() async {
    if (_dirty) {
      final discard = await showNeoConfirm(
        context: context,
        title: 'Discard changes?',
        message: 'Your edits will be lost.',
        accent: NeoPalette.red,
        icon: Icons.warning_amber_rounded,
      );
      if (!discard) return;
    }
    if (mounted) context.go('/');
  }

  Widget _sectionTitle(String text) => Text(text,
      style: AppTypography.grotesk(size: 14, weight: FontWeight.w700,
          color: NeoPalette.inkSoft, spacing: 0.5));

  Widget _buildNameField() => TextFormField(
        controller: _nameCtrl,
        decoration: _inputDecoration('Name'),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        style: AppTypography.grotesk(size: 16),
      );

  Widget _buildDescriptionField() => TextFormField(
        controller: _descCtrl,
        decoration: _inputDecoration('Description (optional)'),
        style: AppTypography.grotesk(size: 16),
        maxLines: 2,
      );

  Widget _buildCountingFields() => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _NumberField(
                  label: 'Start',
                  value: _startValue,
                  onChanged: (v) => setState(() => _startValue = v ?? 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  label: 'Step',
                  value: _stepSize,
                  onChanged: (v) => setState(() => _stepSize = math.max(1, v ?? 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _NumberField(
                  label: 'Target (optional)',
                  value: _targetValue,
                  onChanged: (v) => setState(() => _targetValue = v),
                  nullable: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeoToggleTile(
                  title: 'Count Down',
                  value: !_isUp,
                  onChanged: (v) => setState(() => _isUp = !v),
                  subtitle: _isUp ? 'Up' : 'Down',
                ),
              ),
            ],
          ),
        ],
      );

  /// Auto-count: on/off plus a user-typed time slot (any number of seconds or
  /// minutes) that drives the tally screen's built-in timer.
  Widget _buildAutoCountFields() {
    final n = _autoSlotCtrl.text.trim().isEmpty ? '1' : _autoSlotCtrl.text.trim();
    final unit = _autoSlotUnit == 'm'
        ? (n == '1' ? 'minute' : 'minutes')
        : (n == '1' ? 'second' : 'seconds');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        NeoToggleTile(
          title: 'Auto count',
          subtitle: 'Count +1 by itself after every time slot',
          value: _autoCount,
          onChanged: (v) => setState(() => _autoCount = v),
        ),
        if (_autoCount) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _autoSlotCtrl,
                  decoration: _inputDecoration('Time slot'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: AppTypography.grotesk(size: 16),
                  validator: (v) {
                    final value = int.tryParse((v ?? '').trim());
                    if (value == null || value < 1) return 'Enter 1 or more';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              NeoChip(
                label: 'Seconds',
                selected: _autoSlotUnit == 's',
                color: NeoPalette.orange,
                onTap: () => _switchUnit('s'),
              ),
              const SizedBox(width: 8),
              NeoChip(
                label: 'Minutes',
                selected: _autoSlotUnit == 'm',
                color: NeoPalette.orange,
                onTap: () => _switchUnit('m'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The tally adds 1 automatically after every $n $unit. '
            'You can change or toggle it any time while counting.',
            style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
          ),
        ],
      ],
    );
  }

  Widget _buildThemeFields() => Column(
        children: <Widget>[
          _ColorPickerRow(
            label: 'Accent',
            color: _accentColor,
            onChanged: (c) => setState(() => _accentColor = c),
          ),
        ],
      );

  Widget _buildStyleFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.counterId != null) ...<Widget>[
            NeoCard(
              padding: const EdgeInsets.all(14),
              shadowOffset: Offset.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Number position',
                      style: AppTypography.grotesk(
                          size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Drag the big number anywhere with Canva-style smart guides.',
                    style: AppTypography.grotesk(
                        size: 12, color: NeoPalette.inkSoft),
                  ),
                  const SizedBox(height: 10),
                  NeoButton(
                    label: 'Edit number position',
                    icon: Icons.tune_rounded,
                    variant: NeoButtonVariant.accent,
                    expand: true,
                    onPressed: _openNumberEditor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          NeoToggleTile(
            title: 'Celebrate on target',
            subtitle: 'Particles + haptics when goal reached',
            value: _celebrateOnTarget,
            onChanged: (v) => setState(() => _celebrateOnTarget = v),
          ),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: 'Auto-archive on target',
            subtitle: 'Move to archive when goal reached',
            value: _autoArchive,
            onChanged: (v) => setState(() => _autoArchive = v),
          ),
        ],
      );

  Future<void> _openNumberEditor() async {
    final id = widget.counterId;
    if (id == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NumberPositionScreen(counterId: id),
      ),
    );
  }

  Widget _buildPreview() {
    final neo = context.neo;
    return NeoCard(
      shadowOffset: neo.shadowOffset,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(_accentColor),
                  border: Border.all(color: NeoPalette.ink, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    _nameCtrl.text.isEmpty ? 'Counter Name' : _nameCtrl.text,
                    style: AppTypography.grotesk(
                        size: 18, weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                  color: NeoPalette.ink.withValues(alpha: 0.25), width: 2),
              borderRadius: BorderRadius.circular(NeoPalette.radius),
            ),
            child: Center(
              child: TallyStyleCanvas(
                styleId: _lineStyle,
                count: _isUp
                    ? _startValue + _stepSize * 2
                    : _startValue - _stepSize * 2,
                strokeScale: 0.9,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: <Widget>[
              Text('Start: $_startValue',
                  style: AppTypography.grotesk(size: 14)),
              if (_targetValue != null)
                Text('Target: $_targetValue',
                    style: AppTypography.grotesk(size: 14)),
              Text('Step: ${_isUp ? '+' : ''}$_stepSize',
                  style: AppTypography.grotesk(size: 14)),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTypography.grotesk(size: 14, color: NeoPalette.inkSoft),
        filled: true,
        fillColor: context.neo.paperAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          borderSide: const BorderSide(color: NeoPalette.ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          borderSide: const BorderSide(color: NeoPalette.pink, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = ref.read(databaseProvider);
    if (widget.counterId != null) {
      await db.updateCounter(
        id: widget.counterId!,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        clearDescription: _descCtrl.text.trim().isEmpty,
        startValue: _startValue,
        targetValue: _targetValue,
        clearTarget: _targetValue == null,
        direction: _isUp ? 1 : -1,
        stepSize: _stepSize,
        accentColor: _accentColor,
        lineStyle: _lineStyle,
        autoArchive: _autoArchive,
        celebrateOnTarget: _celebrateOnTarget,
        showGroupBreakdown: true,
        autoCount: _autoCount,
        autoIntervalMs: _slotMs(),
      );
    } else {
      await db.createCounter(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        startValue: _startValue,
        targetValue: _targetValue,
        direction: _isUp ? 1 : -1,
        stepSize: _stepSize,
        accentColor: _accentColor,
        lineStyle: _lineStyle,
        autoArchive: _autoArchive,
        celebrateOnTarget: _celebrateOnTarget,
        showGroupBreakdown: true,
        autoCount: _autoCount,
        autoIntervalMs: _slotMs(),
      );
    }
    if (mounted) context.go('/');
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.nullable = false,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool nullable;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _inputDecoration(context, label),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      style: AppTypography.grotesk(size: 16),
      onChanged: (v) {
        onChanged(v.isEmpty ? (nullable ? null : 0) : int.tryParse(v) ?? 0);
      },
      validator: (v) {
        if (!nullable && (v == null || v.isEmpty)) return 'Required';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTypography.grotesk(size: 14, color: NeoPalette.inkSoft),
        filled: true,
        fillColor: context.neo.paperAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          borderSide: const BorderSide(color: NeoPalette.ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          borderSide: const BorderSide(color: NeoPalette.pink, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

class _ColorPickerRow extends StatelessWidget {
  const _ColorPickerRow({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final int color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 80,
          child: Text(label, style: AppTypography.grotesk(size: 14, weight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: NeoPalette.stickers.map((c) {
                final selected = c.toARGB32() == color;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: NeoChip(
                    label: '',
                    selected: selected,
                    color: c,
                    dense: true,
                    onTap: () => onChanged(c.toARGB32()),
                    icon: selected ? Icons.check : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showCustomPicker(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(color),
              border: Border.all(color: NeoPalette.ink, width: 3),
              borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
            ),
            child: Center(
              child: Icon(Icons.colorize, color: _contrastColor(Color(color)), size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Color _contrastColor(Color c) =>
      c.computeLuminance() > 0.5 ? NeoPalette.ink : NeoPalette.white;

  void _showCustomPicker(BuildContext context) {
    showNeoDialog(
      context: context,
      builder: (context) => _CustomColorPicker(
        initialColor: Color(color),
        onChanged: (c) => onChanged(c.toARGB32()),
      ),
    );
  }
}

class _CustomColorPicker extends ConsumerStatefulWidget {
  const _CustomColorPicker({required this.initialColor, required this.onChanged});

  final Color initialColor;
  final ValueChanged<Color> onChanged;

  @override
  ConsumerState<_CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends ConsumerState<_CustomColorPicker> {
  late int _r, _g, _b;

  @override
  void initState() {
    super.initState();
    _r = widget.initialColor.r.toInt();
    _g = widget.initialColor.g.toInt();
    _b = widget.initialColor.b.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return NeoDialog(
      title: 'Custom Color',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromRGBO(_r, _g, _b, 1),
              border: Border.all(color: NeoPalette.ink, width: 3),
              borderRadius: BorderRadius.circular(NeoPalette.radius),
            ),
          ),
          const SizedBox(height: 16),
          _SliderRow(label: 'R', value: _r, onChanged: (v) => setState(() => _r = v), color: NeoPalette.red),
          _SliderRow(label: 'G', value: _g, onChanged: (v) => setState(() => _g = v), color: NeoPalette.lime),
          _SliderRow(label: 'B', value: _b, onChanged: (v) => setState(() => _b = v), color: NeoPalette.cyan),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(child: NeoButton(label: 'Cancel', variant: NeoButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: NeoButton(label: 'Apply', variant: NeoButtonVariant.primary,
                  onPressed: () {
                    widget.onChanged(Color.fromRGBO(_r, _g, _b, 1));
                    Navigator.pop(context);
                  })),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(width: 24, child: Text(label, style: AppTypography.grotesk(size: 14, weight: FontWeight.w700, color: color))),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              activeColor: color,
              inactiveColor: color.withValues(alpha: 0.3),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.end, style: AppTypography.grotesk(size: 12))),
        ],
      ),
    );
  }
}
