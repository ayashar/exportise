import 'package:flutter/material.dart';

import '../../core/api/app_session.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../analysis/analysis_input_page.dart';
import '../brains/brain_studio_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 118),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _NotificationHeader(),
                  SizedBox(height: 38),
                  _NotificationSectionHeader(title: 'Notifikasi'),
                  SizedBox(height: 18),
                  _EmptyNotificationCard(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                selectedTab: AppTab.home,
                onTabSelected: (tab) {
                  if (tab == AppTab.home) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  if (tab == AppTab.analysis) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AnalysisInputPage(),
                      ),
                    );
                  }
                  if (tab == AppTab.reports) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const HistoryPage(),
                      ),
                    );
                  }
                  if (tab == AppTab.brains) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const BrainStudioPage.fresh(),
                      ),
                    );
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

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/home/profile.png'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            child: Text(
              AppSession.instance.displayName,
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.neutral09,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationSectionHeader extends StatelessWidget {
  const _NotificationSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.primary05,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyNotificationCard extends StatelessWidget {
  const _EmptyNotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x127A5900),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
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
                AppIcons.bell(),
                color: AppColors.primary08,
                dimension: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aktivitas analisis, laporan, dan pembaruan akun akan muncul di sini.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
