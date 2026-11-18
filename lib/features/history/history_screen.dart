import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../tally_styles/registry.dart';
import '../stats/stats_math.dart' hide Session;
import '../widgets/widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ScrollController _scroll = ScrollController();
  String? _filterCounterId;
  DateTime? _filterDate;
  String _search = '';
  int _lastRequestedFor = -1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  /// Pull another page when the user nears the end of the loaded window.
  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels < position.maxScrollExtent - 400) return;

    final loaded = ref.read(allTapsProvider).value ?? const <Tap>[];
    final limit = ref.read(historyPageLimitProvider);
    if (loaded.length < limit) return; // reached the true end
    if (_lastRequestedFor == loaded.length) return; // already asked for this page
    _lastRequestedFor = loaded.length;
    ref.read(historyPageLimitProvider.notifier).showMore();
  }

  @override
  Widget build(BuildContext context) {
    final countersAsync = ref.watch(countersStreamProvider);
    final tapsAsync = ref.watch(allTapsProvider);
    final sessionsAsync = ref.watch(allSessionsProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(),
      appBar: AppBar(
        title: Text('History', style: AppTypography.grotesk(size: 20, weight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final s = await showDialog<String>(
                context: context,
                builder: (_) => _SearchDialog(initial: _search),
              );
              if (s != null) setState(() => _search = s);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterSheet(countersAsync.value ?? []),
          ),
          if (_filterCounterId != null || _filterDate != null || _search.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _filterCounterId = null;
                _filterDate = null;
                _search = '';
              }),
            ),
        ],
      ),
      body: countersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error', style: AppTypography.grotesk(size: 16))),
        data: (counters) {
          if (counters.isEmpty) {
            return Center(child: Text('No counters yet', style: AppTypography.grotesk(size: 16)));
          }
          final counterMap = {for (final c in counters) c.id: c};
          final taps = tapsAsync.value ?? [];
          final sessions = sessionsAsync.value ?? [];

          final filteredTaps = taps.where((t) {
            if (_filterCounterId != null && t.counterId != _filterCounterId) return false;
            if (_filterDate != null) {
              final d = _filterDate!;
              if (t.at.year != d.year || t.at.month != d.month || t.at.day != d.day) return false;
            }
            if (_search.isNotEmpty) {
              final c = counterMap[t.counterId];
              final nameMatch = c != null && c.name.toLowerCase().contains(_search.toLowerCase());
              final noteMatch = (t.note ?? '').toLowerCase().contains(_search.toLowerCase());
              if (!nameMatch && !noteMatch) return false;
            }
            return true;
          }).toList();

          if (filteredTaps.isEmpty) {
            return Center(child: Text('No entries', style: AppTypography.grotesk(size: 16, color: NeoPalette.inkSoft)));
          }

          // Group by day, then by session (or ad-hoc via gap detection).
          final byDay = <DateTime, List<Tap>>{};
          for (final t in filteredTaps) {
            final key = DateTime(t.at.year, t.at.month, t.at.day);
            byDay.putIfAbsent(key, () => <Tap>[]).add(t);
          }
          final dayKeys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

          final rows = <Widget>[];
          var staggerIndex = 0;
          for (final day in dayKeys) {
            final dayTaps = byDay[day]!..sort((a, b) => b.at.compareTo(a.at));
            rows.add(_DayHeader(day: day, count: dayTaps.length, key: ValueKey('day_$day')));
            final sessionGroups = _groupIntoSessions(dayTaps, sessions);
            for (final group in sessionGroups) {
              rows.add(
                _SessionBlock(
                  key: ValueKey('session_${group.key}'),
                  group: group,
                  counter: counterMap[group.counterId],
                  animationIndex: staggerIndex++,
                  onEditTap: (tap) => _editTap(tap),
                  onDeleteTap: (tap) => _deleteTap(tap),
                  onEditSession: (session) => _editSession(session),
                ),
              );
            }
          }

          return AnimationLimiter(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 80),
              children: rows,
            ),
          );
        },
      ),
    );
  }

  /// Group taps (already sorted desc) into sessions: consecutive taps with a gap
  /// <= 30 min. Prefer attached `sessionId` when present.
  List<_SessionGroup> _groupIntoSessions(List<Tap> dayTaps, List<Session> sessions) {
    final sessionIds = {for (final s in sessions) s.id: s};
    final groups = <_SessionGroup>[];
    _SessionGroup? current;
    for (final t in dayTaps) {
      final sid = t.sessionId;
      if (current != null) {
        if (sid != null && current.sessionId == sid) {
          current.taps.add(t);
          continue;
        }
        if (sid == null && current.sessionId == null) {
          final gap = current.taps.last.at.difference(t.at).inMinutes.abs();
          if (gap <= 30) {
            current.taps.add(t);
            continue;
          }
        }
      }
      current = _SessionGroup(
        key: sid ?? 'adhoc_${t.id}',
        sessionId: sid,
        counterId: t.counterId,
        taps: <Tap>[t],
        session: sid != null ? sessionIds[sid] : null,
      );
      groups.add(current);
    }
    // Attach session metadata for ad-hoc groups by matching counter.
    for (final g in groups) {
      g.session ??= sessions.where((s) => s.id == g.sessionId).firstOrNull;
    }
    return groups;
  }

  Future<void> _editTap(Tap tap) async {
    final ctrl = TextEditingController(text: tap.note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.neo.paperAlt,
        title: Text('Edit entry', style: AppTypography.grotesk(size: 18, weight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Note'),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      await ref.read(databaseProvider).updateTapNote(tap.id, result.trim().isEmpty ? null : result.trim());
    }
  }

  Future<void> _deleteTap(Tap tap) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.neo.paperAlt,
        title: Text('Delete entry?', style: AppTypography.grotesk(size: 18, weight: FontWeight.w700)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await ref.read(databaseProvider).deleteTap(tap.id);
  }

  Future<void> _editSession(Session session) async {
    final labelCtrl = TextEditingController(text: session.label ?? '');
    final tagsCtrl = TextEditingController(text: session.tags ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.neo.paperAlt,
        title: Text('Session', style: AppTypography.grotesk(size: 18, weight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Note')),
            const SizedBox(height: 12),
            TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (result == true) {
      await ref.read(databaseProvider).updateSessionMeta(
            session.id,
            label: labelCtrl.text.trim().isEmpty ? null : labelCtrl.text.trim(),
            tags: tagsCtrl.text.trim().isEmpty ? null : tagsCtrl.text.trim(),
          );
    }
  }

  Future<void> _showFilterSheet(List<Counter> counters) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.neo.paperAlt,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Filter by counter', style: AppTypography.grotesk(size: 16, weight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('All counters'),
              onTap: () {
                setState(() => _filterCounterId = null);
                Navigator.pop(ctx);
              },
            ),
            ...counters.map((c) => ListTile(
                  leading: Icon(Icons.circle, color: Color(c.accentColor), size: 16),
                  title: Text(c.name),
                  onTap: () {
                    setState(() => _filterCounterId = c.id);
                    Navigator.pop(ctx);
                  },
                )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_filterDate == null ? 'Pick a specific date' : 'Date: ${_filterDate!.toIso8601String().split('T').first}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: _filterDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _filterDate = picked);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionGroup {
  _SessionGroup({
    required this.key,
    required this.sessionId,
    required this.counterId,
    required this.taps,
    this.session,
  });

  final String key;
  final String? sessionId;
  final String counterId;
  final List<Tap> taps;
  Session? session;

  int get total => taps.fold<int>(0, (s, t) => s + t.delta);
  DateTime get start => taps.last.at;
  DateTime get end => taps.first.at;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.count, super.key});

  final DateTime day;
  final int count;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final label = day == today
        ? 'Today'
        : day == today.subtract(const Duration(days: 1))
            ? 'Yesterday'
            : '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return Container(
      color: NeoPalette.paper,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: <Widget>[
          Text(label, style: AppTypography.display(18, 1.0, -0.2)),
          const SizedBox(width: 8),
          Text('· $count', style: AppTypography.mono(size: 12, color: NeoPalette.inkSoft)),
        ],
      ),
    );
  }
}

class _SessionBlock extends StatefulWidget {
  const _SessionBlock({
    required this.group,
    required this.counter,
    required this.animationIndex,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onEditSession,
    super.key,
  });

  final _SessionGroup group;
  final Counter? counter;
  final int animationIndex;
  final ValueChanged<Tap> onEditTap;
  final ValueChanged<Tap> onDeleteTap;
  final ValueChanged<Session> onEditSession;

  @override
  State<_SessionBlock> createState() => _SessionBlockState();
}

class _SessionBlockState extends State<_SessionBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final counter = widget.counter;
    final style = LineStyle.fromId(counter?.lineStyle);
    final strokeColor = style.stroke;

    return AnimationConfiguration.staggeredList(
      position: widget.animationIndex,
      duration: const Duration(milliseconds: 240),
      child: SlideAnimation(
        verticalOffset: 20,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: context.neo.paperAlt,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: NeoPalette.ink, width: 2),
              borderRadius: BorderRadius.circular(NeoPalette.radius),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(NeoPalette.radius),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Hero(
                          tag: 'history_icon_${g.key}',
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: TallyStyleCanvas(
                              styleId: style.id,
                              count: g.total,
                              color: strokeColor,
                              panel: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(counter?.name ?? 'Counter',
                                  style: AppTypography.grotesk(size: 15, weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                '${_fmtTime(g.start)} – ${_fmtTime(g.end)}  ·  ${g.taps.length} taps  ·  Δ ${g.total}',
                                style: AppTypography.mono(size: 11, color: NeoPalette.inkSoft),
                              ),
                              if (g.session?.label != null && g.session!.label!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(g.session!.label!,
                                      style: AppTypography.grotesk(size: 12, weight: FontWeight.w700)),
                                ),
                              if (g.session?.tags != null && g.session!.tags!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Wrap(
                                    spacing: 4,
                                    children: g.session!.tags!.split(',').where((t) => t.trim().isNotEmpty).map((t) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Color(counter?.accentColor ?? 0xFFFFD23F).withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('#${t.trim()}', style: AppTypography.mono(size: 10)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: NeoPalette.inkSoft),
                      ],
                    ),
                    if (_expanded) ...<Widget>[
                      const SizedBox(height: 10),
                      _MiniChart(taps: g.taps.reversed.toList(), color: strokeColor),
                      const SizedBox(height: 10),
                      if (g.session != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            icon: const Icon(Icons.edit_note, size: 18),
                            label: const Text('Edit session note/tags'),
                            onPressed: () => widget.onEditSession(g.session!),
                          ),
                        ),
                      const Divider(height: 20),
                      ...g.taps.map((t) => _TapRow(
                            tap: t,
                            counterName: counter?.name ?? '',
                            onEdit: () => widget.onEditTap(t),
                            onDelete: () => widget.onDeleteTap(t),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.tap,
    required this.counterName,
    required this.onEdit,
    required this.onDelete,
  });

  final Tap tap;
  final String counterName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            '${tap.at.hour.toString().padLeft(2, '0')}:${tap.at.minute.toString().padLeft(2, '0')}:${tap.at.second.toString().padLeft(2, '0')}',
            style: AppTypography.mono(size: 11, color: NeoPalette.inkSoft),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: NeoPalette.ink,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Δ ${tap.delta}', style: AppTypography.mono(size: 10, color: NeoPalette.paper)),
          ),
          const SizedBox(width: 8),
          if (tap.note != null && tap.note!.isNotEmpty)
            Expanded(
              child: Text(tap.note!, style: AppTypography.grotesk(size: 12), overflow: TextOverflow.ellipsis),
            )
          else
            const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.taps, required this.color});

  final List<Tap> taps;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final events = taps.map((t) => TapEvent(timestamp: t.at, delta: t.delta, counterId: t.counterId)).toList();
    final hourly = StatsMath.hourOfDay(events.isEmpty ? <TapEvent>[] : events);
    final maxV = hourly.fold<int>(0, (m, h) => h.value > m ? h.value : m);
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(24, (h) {
          final v = hourly[h].value;
          final hh = maxV > 0 ? (v / maxV) : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: Container(
                height: (hh * 56).clamp(1.0, 56.0),
                decoration: BoxDecoration(
                  color: v > 0 ? color : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog({required this.initial});

  final String initial;

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.neo.paperAlt,
      title: const Text('Search'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Counter name or note'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, _ctrl.text), child: const Text('OK')),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}