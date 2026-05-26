import 'package:flutter/material.dart';

import '../../core/download/asset_downloader.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../analysis/analysis_input_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _HistoryTab _selectedTab = _HistoryTab.reference;

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
                  const _HistoryHeader(),
                  const SizedBox(height: 28),
                  _HistorySegmentedControl(
                    selectedTab: _selectedTab,
                    onChanged: (tab) {
                      setState(() => _selectedTab = tab);
                    },
                  ),
                  const SizedBox(height: 22),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _selectedTab == _HistoryTab.reference
                        ? const _ReferenceHistoryList()
                        : const _ResultHistoryList(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                selectedTab: AppTab.reports,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

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

class _HistorySegmentedControl extends StatelessWidget {
  const _HistorySegmentedControl({
    required this.onChanged,
    required this.selectedTab,
  });

  final ValueChanged<_HistoryTab> onChanged;
  final _HistoryTab selectedTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _HistorySegment(
            label: 'Referensi',
            active: selectedTab == _HistoryTab.reference,
            onTap: () => onChanged(_HistoryTab.reference),
          ),
          _HistorySegment(
            label: 'Hasil',
            active: selectedTab == _HistoryTab.result,
            onTap: () => onChanged(_HistoryTab.result),
          ),
        ],
      ),
    );
  }
}

class _HistorySegment extends StatelessWidget {
  const _HistorySegment({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary04 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: active ? AppColors.primary08 : AppColors.neutral08,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceHistoryList extends StatelessWidget {
  const _ReferenceHistoryList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('reference-history'),
      children: [
        _ReferenceHistoryCard(
          imagePath: 'assets/images/analysis/design_ref_a.png',
          fileName: 'variasi-a-modern-alami.png',
          title: 'Variasi A',
          subtitle: 'Modern Alami',
          body:
              'Pas untuk dipakai jalan-jalan atau acara santai. Warnanya cerah dan terlihat modern.',
          tags: ['Gagang Kulit Vegan', 'Lining Linen Putih'],
          recommended: true,
        ),
        SizedBox(height: 28),
        _ReferenceHistoryCard(
          imagePath: 'assets/images/analysis/design_ref_b.png',
          fileName: 'variasi-b-rustic-natural.png',
          title: 'Variasi B',
          subtitle: 'Rustic Natural',
          body:
              'Sesuai untuk pasar East Coast AS yang menghargai nilai autentisitas kerajinan tangan (artisanal) dan keberlanjutan material.',
          tags: ['Handle Kayu Jati', 'Pola Anyam Renggang'],
        ),
        SizedBox(height: 28),
        _ReferenceHistoryCard(
          imagePath: 'assets/images/analysis/design_ref_c.png',
          fileName: 'variasi-c-minimalist-japandi.png',
          title: 'Variasi C',
          subtitle: 'Minimalist Japandi',
          body:
              'Model paling simpel dan rapi. Cocok untuk Umma yang suka gaya sederhana tapi tetap cantik.',
          tags: ['Penutup Magnet Tersembunyi', 'Detail Anyam Geometris'],
        ),
      ],
    );
  }
}

class _ResultHistoryList extends StatelessWidget {
  const _ResultHistoryList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('result-history'),
      children: [
        _ResultHistoryCard(
          imagePath: 'assets/images/analysis/history_result_circle.jpg',
          fileName: 'the-manhattan-circle.jpg',
          title: 'The Manhattan Circle',
          body:
              'Pas untuk dipakai jalan-jalan atau acara santai. Warnanya cerah dan terlihat modern.',
          tags: ['Gagang Kulit Vegan', 'Lining Linen Putih'],
        ),
      ],
    );
  }
}

class _ReferenceHistoryCard extends StatelessWidget {
  const _ReferenceHistoryCard({
    required this.body,
    required this.fileName,
    required this.imagePath,
    required this.subtitle,
    required this.tags,
    required this.title,
    this.recommended = false,
  });

  final String body;
  final String fileName;
  final String imagePath;
  final bool recommended;
  final String subtitle;
  final List<String> tags;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _HistoryCardFrame(
      imagePath: imagePath,
      recommended: recommended,
      imageHeight: 360,
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
          const SizedBox(height: 12),
          Text(
            body,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          const _RecommendationLabel(),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _HistoryTag(tag)).toList(),
          ),
          const SizedBox(height: 26),
          Align(
            alignment: Alignment.centerRight,
            child: _DownloadTextButton(
              assetPath: imagePath,
              fileName: fileName,
              label: 'Unduh',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHistoryCard extends StatelessWidget {
  const _ResultHistoryCard({
    required this.body,
    required this.fileName,
    required this.imagePath,
    required this.tags,
    required this.title,
  });

  final String body;
  final String fileName;
  final String imagePath;
  final List<String> tags;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _HistoryCardFrame(
      imagePath: imagePath,
      imageHeight: 367,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral09,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 26),
          const _RecommendationLabel(),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _HistoryTag(tag)).toList(),
          ),
          const SizedBox(height: 34),
          Align(
            alignment: Alignment.centerRight,
            child: _DownloadTextButton(
              assetPath: imagePath,
              fileName: fileName,
              label: 'Unduh JPG',
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCardFrame extends StatelessWidget {
  const _HistoryCardFrame({
    required this.child,
    required this.imageHeight,
    required this.imagePath,
    this.recommended = false,
  });

  final Widget child;
  final double imageHeight;
  final String imagePath;
  final bool recommended;

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
                height: imageHeight,
                fit: BoxFit.cover,
              ),
              if (recommended)
                Positioned(
                  top: 18,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _DownloadTextButton extends StatefulWidget {
  const _DownloadTextButton({
    required this.assetPath,
    required this.fileName,
    required this.label,
  });

  final String assetPath;
  final String fileName;
  final String label;

  @override
  State<_DownloadTextButton> createState() => _DownloadTextButtonState();
}

class _DownloadTextButtonState extends State<_DownloadTextButton> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _isDownloading ? null : _download,
      icon: AppIcon(
        AppIcons.download(),
        color: AppColors.neutral08,
        dimension: 18,
      ),
      label: Text(
        _isDownloading ? 'Mengunduh...' : widget.label,
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.neutral08,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);

    try {
      final result = await downloadAsset(
        assetPath: widget.assetPath,
        fileName: widget.fileName,
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
        const SnackBar(content: Text('Unduhan belum berhasil. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
}

class _RecommendationLabel extends StatelessWidget {
  const _RecommendationLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Rekomendasi Elemen',
      style: AppTypography.bodySm.copyWith(
        color: AppColors.primary05,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HistoryTag extends StatelessWidget {
  const _HistoryTag(this.label);

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

enum _HistoryTab { reference, result }
