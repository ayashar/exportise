import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

class DesignReferencePage extends StatelessWidget {
  const DesignReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _DesignHeader(),
                  SizedBox(height: 30),
                  _DesignTitle(),
                  SizedBox(height: 28),
                  _DesignReferenceCard(
                    imagePath: 'assets/images/analysis/design_ref_a.png',
                    title: 'Variasi A',
                    subtitle: 'Modern Alami',
                    body:
                        'Pas untuk dipakai jalan-jalan atau acara santai. Warnanya cerah dan terlihat modern.',
                    tags: ['Gagang Kulit Vegan', 'Lining Linen Putih'],
                    recommended: true,
                  ),
                  SizedBox(height: 28),
                  _DesignReferenceCard(
                    imagePath: 'assets/images/analysis/design_ref_b.png',
                    title: 'Variasi B',
                    subtitle: 'Rustic Natural',
                    body:
                        'Sesuai untuk pasar East Coast AS yang menghargai nilai autentisitas kerajinan tangan (artisanal) dan keberlanjutan material.',
                    tags: ['Handle Kayu Jati', 'Pola Anyam Renggang'],
                  ),
                  SizedBox(height: 28),
                  _DesignReferenceCard(
                    imagePath: 'assets/images/analysis/design_ref_c.png',
                    title: 'Variasi C',
                    subtitle: 'Minimalist Japandi',
                    body:
                        'Model paling simpel dan rapi. Cocok untuk Umma yang suka gaya sederhana tapi tetap cantik.',
                    tags: [
                      'Penutup Magnet Tersembunyi',
                      'Detail Anyam Geometris',
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                selectedTab: AppTab.analysis,
                onTabSelected: (tab) {
                  if (tab == AppTab.home) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
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

class _DesignHeader extends StatelessWidget {
  const _DesignHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openProfile(context),
          child: const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/images/home/profile.png'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openProfile(context),
            child: Text(
              'Arunika Tas',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.neutral09,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: () => _openNotifications(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.system01,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neutral03),
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

class _DesignTitle extends StatelessWidget {
  const _DesignTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(AppIcons.bag(), color: AppColors.neutral09, dimension: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tas Anyaman',
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.neutral09,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Amerika Serikat',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.neutral08,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutral02,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary02),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIcons.refresh(),
                color: AppColors.neutral08,
                dimension: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Ulangi',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.neutral08,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesignReferenceCard extends StatelessWidget {
  const _DesignReferenceCard({
    required this.body,
    required this.imagePath,
    required this.subtitle,
    required this.tags,
    required this.title,
    this.recommended = false,
  });

  final String body;
  final String imagePath;
  final bool recommended;
  final String subtitle;
  final List<String> tags;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x127A5900),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                imagePath,
                width: double.infinity,
                height: 340,
                fit: BoxFit.cover,
              ),
              if (recommended)
                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary04,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.sparkle(PhosphorIconsStyle.fill),
                          color: AppColors.primary08,
                          dimension: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rekomendasi Terbaik',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.primary08,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  body,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.neutral08,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Rekomendasi Elemen',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.primary05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => _DesignTag(tag)).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: AppIcon(
                          AppIcons.download(),
                          color: AppColors.neutral08,
                          dimension: 18,
                        ),
                        label: Text(
                          'Unduh',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.neutral08,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        label: 'Diskusi',
                        leadingIcon: AppIcons.chat(),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const BrainStudioPage.designReference(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignTag extends StatelessWidget {
  const _DesignTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary08),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.neutral08,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
