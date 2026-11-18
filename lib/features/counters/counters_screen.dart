import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../features/widgets/widgets.dart';
import '../../tally_styles/registry.dart';
import '../settings/developer_card.dart';

/// Home screen. Top bar is the QUIN title plus exactly three icons — create,
/// archive, developer — and the body is the searchable, reorderable counter
/// list. Archived counters live on their own screen, reached from the archive
/// icon.
class CountersScreen extends ConsumerStatefulWidget {
  const CountersScreen({super.key});

  @override
  ConsumerState<CountersScreen> createState() => _CountersScreenState();
}

class _CountersScreenState extends ConsumerState<CountersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counters = ref.watch(countersStreamProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.counters),
      appBar: AppBar(
        title: Text('QUIN', style: AppTypography.display(24, 1.0, -0.4)),
        actions: <Widget>[
          IconButton(
            key: const Key('create-counter-button'),
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/counter/new'),
            tooltip: 'New counter',
          ),
          IconButton(
            key: const Key('archive-button'),
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => context.push('/archived'),
            tooltip: 'Archived counters',
          ),
          IconButton(
            key: const Key('developer-card-button'),
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showDeveloperDialog(context),
            tooltip: 'About the developer',
          ),
        ],
      ),
      body: counters.when(
        data: (items) {
          bool matches(Counter c) =>
              _query.isEmpty ||
              c.name.toLowerCase().contains(_query.toLowerCase());

          final active = items.where(matches).toList();

          Widget cardFor(Counter c) => CounterCard(
                key: ValueKey(c.id),
                counter: c,
                onTap: () => context.push('/counter/${c.id}'),
                onEdit: () => context.push('/counter/${c.id}/edit'),
                onDuplicate: () => _duplicate(c),
                onArchive: () => _archive(c),
                onDelete: () => _delete(c),
              );

          if (active.isEmpty) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _SearchField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: NeoStateView(
                    state: StateKind.empty,
                    title: _query.isEmpty ? 'No counters yet' : 'No matches',
                    subtitle: _query.isEmpty
                        ? 'Create your first counter to get started.'
                        : 'Try another search.',
                    actionLabel: _query.isEmpty ? '+ Create Counter' : 'Clear search',
                    onAction: () {
                      if (_query.isEmpty) {
                        context.push('/counter/new');
                      } else {
                        setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          }

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _SearchField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.all(16),
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = active.map((c) => c.id).toList();
                    final item = ids.removeAt(oldIndex);
                    ids.insert(newIndex, item);
                    ref.read(databaseProvider).reorderCounters(ids);
                  },
                  children: active.map(cardFor).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => NeoStateView(
          state: StateKind.loading,
          title: 'Loading counters...',
          delay: const Duration(milliseconds: 80),
        ),
        error: (_, __) => NeoStateView(
          state: StateKind.error,
          title: 'Failed to load',
          subtitle: 'Something went wrong.',
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(countersStreamProvider),
        ),
      ),
    );
  }

  Future<void> _duplicate(Counter c) async {
    final db = ref.read(databaseProvider);
    await db.createCounter(
      name: '${c.name} (copy)',
      description: c.description,
      startValue: c.startValue,
      targetValue: c.targetValue,
      direction: c.direction,
      stepSize: c.stepSize,
      accentColor: c.accentColor,
      lineStyle: c.lineStyle,
      numberPosX: c.numberPosX,
      numberPosY: c.numberPosY,
      numberScale: c.numberScale,
      numberOpacity: c.numberOpacity,
      numberColor: c.numberColor,
      autoArchive: c.autoArchive,
      celebrateOnTarget: c.celebrateOnTarget,
      showGroupBreakdown: c.showGroupBreakdown,
      autoCount: c.autoCount,
      autoIntervalMs: c.autoIntervalMs,
    );
  }

  /// Swipe left / menu: move the counter into the archive.
  Future<void> _archive(Counter c) async {
    final db = ref.read(databaseProvider);
    await db.updateCounter(id: c.id, archived: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${c.name}" archived'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref
                .read(databaseProvider)
                .updateCounter(id: c.id, archived: false),
          ),
        ),
      );
  }

  /// Permanently deletes (swipe right / menu): confirm, delete from Drift, then
  /// offer an Undo that restores the counter and its full tap history.
  Future<bool> _delete(Counter c) async {
    final ok = await showNeoConfirm(
      context: context,
      title: 'Delete "${c.name}"?',
      message: 'This removes all history and cannot be undone.',
      accent: NeoPalette.red,
      icon: Icons.delete_outline,
    );
    if (!ok) return false;
    final snapshot = await ref.read(counterActionsProvider).delete(c.id);
    if (!mounted) return true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${c.name}" deleted'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref.read(counterActionsProvider).restore(snapshot),
          ),
        ),
      );
    return true;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search counters...',
        hintStyle: AppTypography.grotesk(size: 15, color: NeoPalette.muted),
        prefixIcon: const Icon(Icons.search, color: NeoPalette.muted),
        filled: true,
        fillColor: context.neo.paperAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoPalette.radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: AppTypography.grotesk(size: 16),
      onChanged: onChanged,
    );
  }
}

/// A single counter card. Three-dot menu at the card's top-right; swipe right
/// to delete, swipe left to archive.
class CounterCard extends ConsumerWidget {
  const CounterCard({
    super.key,
    required this.counter,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onArchive,
    required this.onDelete,
    this.archived = false,
    this.trailing,
  });

  final Counter counter;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final Future<void> Function() onArchive;
  final Future<void> Function() onDelete;
  final bool archived;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Color(counter.accentColor);
    final groups = counter.currentValue ~/ kTallyGroupSize;
    final rem = counter.currentValue % kTallyGroupSize;
    final card = context.neo.paper;
    final tint = Color.lerp(card, accent, 0.14)!;

    // Swipe right = permanent delete, swipe left = archive, matching the icons
    // revealed on each side. Both resolve to `false`, so the card springs back
    // and the Drift stream does the actual change once the write lands.
    return Dismissible(
      key: ValueKey('dismiss-${counter.id}'),
      background: _SwipeAction(
        icon: Icons.delete_outline,
        label: 'Delete',
        color: NeoPalette.red,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeAction(
        icon: Icons.archive_outlined,
        label: 'Archive',
        color: NeoPalette.cyan,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onDelete();
        } else {
          await onArchive();
        }
        return false;
      },
      child: Hero(
        tag: 'counter-${counter.id}',
        child: Material(
          color: Colors.transparent,
          child: NeoCard(
            color: tint,
            padding: const EdgeInsets.all(16),
            shadowOffset: archived ? Offset.zero : NeoPalette.shadowOffset,
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accent,
                        border: Border.all(color: NeoPalette.ink, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        counter.name,
                        style: AppTypography.grotesk(
                            size: 18, weight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null) trailing!,
                    // The three-dot menu lives at the card's top-right.
                    PopupMenuButton<String>(
                      key: Key('counter-menu-${counter.id}'),
                      icon: const Icon(Icons.more_vert, color: NeoPalette.ink),
                      onSelected: (v) {
                        switch (v) {
                          case 'edit':
                            onEdit();
                          case 'duplicate':
                            onDuplicate();
                          case 'archive':
                            onArchive();
                          case 'delete':
                            onDelete();
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'duplicate', child: Text('Duplicate')),
                        const PopupMenuItem(
                            value: 'archive', child: Text('Archive')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: NeoPalette.red)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: RollingOdometer(
                          value: counter.currentValue,
                          style: AppTypography.display(40, 1.0, -1),
                          color: NeoPalette.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${marksForCount(counter.currentValue)}/$kTallyGroupSize'
                            ' · ${groups}g + $rem',
                            style: AppTypography.grotesk(
                                size: 12, color: NeoPalette.inkSoft),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (counter.targetValue != null)
                            Text(
                              'Target: ${counter.targetValue}',
                              style: AppTypography.grotesk(
                                  size: 11, weight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    this.alignment = Alignment.centerRight,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final onRight = alignment == Alignment.centerRight;
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(left: onRight ? 0 : 20, right: onRight ? 20 : 0),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!onRight) Icon(icon, color: NeoPalette.white, size: 24),
          if (!onRight) const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.grotesk(
                size: 14, weight: FontWeight.w700, color: NeoPalette.white),
          ),
          if (onRight) const SizedBox(width: 8),
          if (onRight) Icon(icon, color: NeoPalette.white, size: 24),
        ],
      ),
    );
  }
}
