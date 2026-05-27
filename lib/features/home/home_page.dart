import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../analysis/analysis_input_page.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 118),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeHeader(),
                  const SizedBox(height: 34),
                  const _Greeting(),
                  const SizedBox(height: 30),
                  const _ExporterLevelCard(),
                  const SizedBox(height: 26),
                  _InsightCard(),
                  const SizedBox(height: 32),
                  _QuickActionGrid(),
                  const SizedBox(height: 34),
                  const _SectionHeader(),
                  const SizedBox(height: 16),
                  const _AnalysisCard(
                    imagePath: 'assets/images/home/woven_bag.png',
                    title: 'Tas Anyaman',
                    country: 'Amerika Serikat',
                    status: 'Siap Ekspor',
                    statusColor: AppColors.tertiary02,
                  ),
                  const SizedBox(height: 16),
                  const _AnalysisCard(
                    imagePath: 'assets/images/home/coffee_jacket.png',
                    title: 'Kopi Luwak',
                    country: 'Jepang',
                    status: 'Lanjutkan Analisis',
                    statusColor: AppColors.secondary04,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                selectedTab: AppTab.home,
                onTabSelected: (tab) {
                  if (tab == AppTab.analysis) {
                    _openAnalysis(context);
                  }
                  if (tab == AppTab.reports) {
                    _openReports(context);
                  }
                  if (tab == AppTab.brains) {
                    _openBrains(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openAnalysis(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const AnalysisInputPage()),
  );
}

void _openReports(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => const HistoryPage()));
}

void _openBrains(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const BrainStudioPage.fresh(),
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openProfile(context),
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/home/profile.png'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openProfile(context),
            child: Text(
              'Arunika Tas',
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.neutral09,
              ),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openNotifications(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.system01,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neutral03),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A7A5900),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AppIcon(
                AppIcons.bell(),
                color: AppColors.primary05,
                dimension: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void _openProfile(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => const ProfilePage()));
}

void _openNotifications(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const NotificationPage()),
  );
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Halo! Arunika Tas',
      style: AppTypography.headlineLg.copyWith(
        color: AppColors.neutral09,
        height: 1.1,
      ),
    );
  }
}

class _ExporterLevelCard extends StatelessWidget {
  const _ExporterLevelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: _softCardDecoration(borderRadius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Level Eksportir Pemula',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral09,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '60%',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary05,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 12,
              backgroundColor: AppColors.neutral03,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary04),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '2 langkah lagi untuk naik ke Level Menengah!',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary02),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A7A5900),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary04,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppIcon(
                AppIcons.gear(PhosphorIconsStyle.fill),
                color: AppColors.primary08,
                dimension: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minat kerajinan di pasar global sedang naik daun. Ayo cek kesiapan produkmu!',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Analisis sekarang',
                  size: AppButtonSize.sm,
                  onPressed: () => _openAnalysis(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: _QuickActionIcon.analysis,
            label: 'Analisis\nProduk',
            isActive: true,
            onTap: () => _openAnalysis(context),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _QuickActionTile(
            icon: _QuickActionIcon.brain,
            label: 'Brain Studio',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _QuickActionTile(
            icon: _QuickActionIcon.report,
            label: 'LaporanKu',
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final _QuickActionIcon icon;
  final bool isActive;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive ? AppColors.primary04 : AppColors.system01;
    final foregroundColor = isActive
        ? AppColors.primary08
        : AppColors.neutral08;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x147A5900),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon.data, color: foregroundColor, dimension: 24),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                height: 1.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _QuickActionIcon { analysis, brain, report }

extension on _QuickActionIcon {
  IconData get data {
    return switch (this) {
      _QuickActionIcon.analysis => AppIcons.trendUp(),
      _QuickActionIcon.brain => AppIcons.brain(),
      _QuickActionIcon.report => AppIcons.document(),
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Analisis Terakhir',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral09,
            ),
          ),
        ),
        Text(
          'Lihat Semua',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.primary05,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.country,
    required this.imagePath,
    required this.status,
    required this.statusColor,
    required this.title,
  });

  final String country;
  final String imagePath;
  final String status;
  final Color statusColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(16),
      decoration: _softCardDecoration(borderRadius: 18),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: statusColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.neutral03,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                AppIcons.arrowRight(),
                color: AppColors.primary05,
                dimension: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _softCardDecoration({required double borderRadius}) {
  return BoxDecoration(
    color: AppColors.system01,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: const [
      BoxShadow(
        color: Color(0x127A5900),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );
}
