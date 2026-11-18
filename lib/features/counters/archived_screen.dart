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

/// Dedicated home for archived counters. Every card can be restored or
/// permanently deleted, but never accidentally counted.
class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(allCountersStreamProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(),
      appBar: AppBar(
        title: Text('Archived', style: AppTypography.display(22, 1.0, -0.4)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: counters.when(
        data: (items) {
          final archived = items.where((c) => c.archived).toList();
          if (archived.isEmpty) {
            return const NeoStateView(
              state: StateKind.empty,
              title: 'Nothing archived',
              subtitle: 'Swipe a counter left to tuck it away here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: archived.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => _ArchivedCard(counter: archived[i]),
          );
        },
        loading: () => NeoStateView(
          state: StateKind.loading,
          title: 'Loading archive...',
          delay: const Duration(milliseconds: 80),
        ),
        error: (_, __) => const NeoStateView(
          state: StateKind.error,
          title: 'Failed to load',
          subtitle: 'Something went wrong.',
        ),
      ),
    );
  }
}

class _ArchivedCard extends ConsumerWidget {
  const _ArchivedCard({required this.counter});

  final Counter counter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Color(counter.accentColor);
    final tint = Color.lerp(context.neo.paper, accent, 0.14)!;
    final groups = counter.currentValue ~/ kTallyGroupSize;
    final rem = counter.currentValue % kTallyGroupSize;

    return NeoCard(
      color: tint,
      padding: const EdgeInsets.all(16),
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
                  style: AppTypography.grotesk(size: 18, weight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${counter.currentValue}',
                style: AppTypography.display(22, 1.0, -0.6),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$groups groups + $rem',
            style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: NeoButton(
                  label: 'Restore',
                  icon: Icons.unarchive_outlined,
                  expand: true,
                  onPressed: () => ref
                      .read(databaseProvider)
                      .updateCounter(id: counter.id, archived: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeoButton(
                  label: 'Delete',
                  icon: Icons.delete_outline,
                  variant: NeoButtonVariant.danger,
                  expand: true,
                  onPressed: () => _delete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showNeoConfirm(
      context: context,
      title: 'Delete "${counter.name}"?',
      message: 'This removes all history and cannot be undone.',
      accent: NeoPalette.red,
      icon: Icons.delete_outline,
    );
    if (!ok) return;
    final snapshot = await ref.read(counterActionsProvider).delete(counter.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${counter.name}" deleted'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref.read(counterActionsProvider).restore(snapshot),
          ),
        ),
      );
  }
}
