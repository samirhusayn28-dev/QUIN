import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';

/// Primary destinations shown in the always-visible bottom navigation.
enum AppTab {
  counters(icon: Icons.grid_view_rounded, label: 'Counters', route: '/'),
  stats(icon: Icons.insights_rounded, label: 'Stats', route: '/stats'),
  settings(icon: Icons.settings_rounded, label: 'Settings', route: '/settings');

  const AppTab({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;
}

/// Neo-brutalist bottom navigation. Keeps Settings (and Stats/History) visible
/// from every main screen instead of hiding them behind an app-bar icon.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.current});

  /// The highlighted destination, or null when the current screen is not one of
  /// the three primary tabs (e.g. the history or archive screens).
  final AppTab? current;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.neo.paper,
        border: const Border(top: BorderSide(color: NeoPalette.ink, width: 3)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              for (final tab in AppTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    selected: tab == current,
                    onTap: () {
                      if (tab == current) return;
                      context.go(tab.route);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? NeoPalette.ink : NeoPalette.inkSoft;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: selected
                  ? BoxDecoration(
                      color: context.neo.sticker,
                      border: Border.all(color: NeoPalette.ink, width: 2),
                      borderRadius: BorderRadius.circular(999),
                    )
                  : null,
              child: Icon(tab.icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                maxLines: 1,
                style: AppTypography.grotesk(
                  size: 11,
                  weight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
