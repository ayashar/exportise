import 'package:flutter/material.dart';

import '../../core/download/asset_downloader.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../analysis/analysis_input_page.dart';
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
                  _NotificationSectionHeader(
                    title: 'Hari ini',
                    actionLabel: 'Tandai semua sudah di baca',
                  ),
                  SizedBox(height: 18),
                  _ReportNotificationCard(),
                  SizedBox(height: 36),
                  _NotificationSectionHeader(title: 'Kemarin'),
                  SizedBox(height: 18),
                  _ReportNotificationCard(),
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
              'Arunika Tas',
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
  const _NotificationSectionHeader({required this.title, this.actionLabel});

  final String? actionLabel;
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
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: AppTypography.bodySm.copyWith(color: AppColors.primary05),
          ),
      ],
    );
  }
}

class _ReportNotificationCard extends StatelessWidget {
  const _ReportNotificationCard();

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
          Row(
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
                    AppIcons.filePdf(),
                    color: AppColors.primary08,
                    dimension: 24,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Laporan Tas Anyaman\nAmerika Serikat',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral08,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerRight, child: _DownloadPdfButton()),
        ],
      ),
    );
  }
}

class _DownloadPdfButton extends StatefulWidget {
  @override
  State<_DownloadPdfButton> createState() => _DownloadPdfButtonState();
}

class _DownloadPdfButtonState extends State<_DownloadPdfButton> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _isDownloading ? null : _download,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primary02),
        ),
        backgroundColor: AppColors.neutral01,
      ),
      label: Text(
        _isDownloading ? 'Mengunduh...' : 'Unduh PDF',
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.neutral08,
          fontWeight: FontWeight.w700,
        ),
      ),
      icon: AppIcon(
        AppIcons.download(),
        color: AppColors.neutral08,
        dimension: 18,
      ),
    );
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);

    try {
      final result = await downloadAsset(
        assetPath: 'assets/reports/laporan_tas_anyaman_amerika_serikat.pdf',
        fileName: 'laporan-tas-anyaman-amerika-serikat.pdf',
      );

      if (!mounted) {
        return;
      }

      final message = result.path == null
          ? '${result.fileName} sedang diunduh.'
          : '${result.fileName} tersimpan di ${result.path}.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unduhan PDF belum berhasil. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
}
