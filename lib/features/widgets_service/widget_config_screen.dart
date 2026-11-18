import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import 'widget_keys.dart';

/// Presented when the user drops a widget on the home screen and the launcher
/// asks the app to configure widget [appWidgetId]. Also reachable directly to
/// re-bind an existing widget.
class WidgetConfigScreen extends ConsumerStatefulWidget {
  const WidgetConfigScreen({super.key, required this.appWidgetId});

  final int appWidgetId;

  @override
  ConsumerState<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends ConsumerState<WidgetConfigScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final id = await HomeWidget.getWidgetData<int>(
        WidgetKeys.widgetCounter(widget.appWidgetId));
    if (mounted && id != null) {
      setState(() => _selectedId = id.toString());
    }
  }

  Future<void> _save(List<Counter> counters) async {
    final id = _selectedId ?? counters.first.id;
    await HomeWidget.saveWidgetData<String>(
        WidgetKeys.widgetCounter(widget.appWidgetId), id);
    final ids = await HomeWidget.getWidgetData<String>(WidgetKeys.widgetIds) ?? '';
    final set = ids.split(',').where((e) => e.isNotEmpty).toSet()
      ..add(widget.appWidgetId.toString());
    await HomeWidget.saveWidgetData<String>(
        WidgetKeys.widgetIds, set.join(','));

    await ref.read(widgetSyncProvider).syncAll();

    if (mounted) {
      await HomeWidget.finishHomeWidgetConfigure();
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final counters = ref.watch(countersStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Widget counter', style: AppTypography.grotesk(size: 20, weight: FontWeight.w700)),
      ),
      body: counters.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error', style: AppTypography.grotesk(size: 16))),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text('Create a counter first', style: AppTypography.grotesk(size: 16)));
          }
          _selectedId ??= items.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text('Choose which counter this widget shows.',
                  style: AppTypography.grotesk(size: 14, color: NeoPalette.inkSoft)),
              const SizedBox(height: 12),
              ...items.map((c) => _CounterTile(
                    counter: c,
                    selected: _selectedId == c.id,
                    onTap: () => setState(() => _selectedId = c.id),
                  )),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(items),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({required this.counter, required this.selected, required this.onTap});

  final Counter counter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NeoPalette.paper,
            border: Border.all(color: NeoPalette.ink, width: selected ? 3 : 2),
            borderRadius: BorderRadius.circular(NeoPalette.radius),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.circle, color: Color(counter.accentColor), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(counter.name, style: AppTypography.grotesk(size: 16, weight: FontWeight.w700)),
                    Text('${counter.currentValue}', style: AppTypography.mono(size: 12, color: NeoPalette.inkSoft)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle),
            ],
          ),
        ),
      ),
    );
  }
}
