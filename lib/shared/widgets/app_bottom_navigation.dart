import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppTab { home, analysis, brains, reports }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedTab,
    this.onTabSelected,
  });

  final ValueChanged<AppTab>? onTabSelected;
  final AppTab selectedTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.neutral01,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.secondary08),
          boxShadow: const [
            BoxShadow(
              color: Color(0x147A5900),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: AppIcons.home(),
              label: 'Home',
              active: selectedTab == AppTab.home,
              onTap: () => onTabSelected?.call(AppTab.home),
            ),
            _BottomNavItem(
              icon: AppIcons.trendUp(),
              label: 'Analisis',
              active: selectedTab == AppTab.analysis,
              onTap: () => onTabSelected?.call(AppTab.analysis),
            ),
            _BottomNavItem(
              icon: AppIcons.brain(),
              label: 'BrainS',
              active: selectedTab == AppTab.brains,
              onTap: () => onTabSelected?.call(AppTab.brains),
            ),
            _BottomNavItem(
              icon: AppIcons.document(),
              label: 'Laporanku',
              active: selectedTab == AppTab.reports,
              onTap: () => onTabSelected?.call(AppTab.reports),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.secondary04 : AppColors.primary06;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, color: color, dimension: 22),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: color,
                fontSize: label.length > 8 ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
