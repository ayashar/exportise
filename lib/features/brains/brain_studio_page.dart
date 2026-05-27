import 'package:flutter/material.dart';

import '../../core/download/asset_downloader.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../analysis/analysis_input_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

enum ChatbotMode { designReference, fresh }

class BrainStudioPage extends StatelessWidget {
  const BrainStudioPage.designReference({super.key})
    : mode = ChatbotMode.designReference;

  const BrainStudioPage.fresh({super.key}) : mode = ChatbotMode.fresh;

  final ChatbotMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 192),
              child: Column(
                children: [
                  const _ChatHeader(),
                  const SizedBox(height: 44),
                  const _BrainIntro(),
                  const SizedBox(height: 48),
                  if (mode == ChatbotMode.designReference)
                    const _DesignReferenceConversation()
                  else
                    const _FreshConversation(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _ChatComposer(),
                  AppBottomNavigation(
                    selectedTab: AppTab.brains,
                    onTabSelected: (tab) {
                      if (tab == AppTab.home) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

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

class _BrainIntro extends StatelessWidget {
  const _BrainIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary04,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: AppIcon(
              AppIcons.brain(PhosphorIconsStyle.fill),
              color: AppColors.primary08,
              dimension: 30,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'BrainStudio',
          style: AppTypography.headlineSm.copyWith(color: AppColors.neutral09),
        ),
        const SizedBox(height: 8),
        Text(
          'Asisten AI desain produk untuk\nmenembus pasar internasional.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _DesignReferenceConversation extends StatelessWidget {
  const _DesignReferenceConversation();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AiMessage(
          text:
              'Hai Arunika Tas! Senang bisa berdiskusi bersama kamu, bagaimana menurut kamu terkait produk ini? Apakah kamu punya ide pengembangan desain produknya?',
        ),
        SizedBox(height: 18),
        _ChatImageCard(
          imagePath: 'assets/images/analysis/design_ref_a.png',
          title: 'Variasi A',
          subtitle: 'Modern Alami',
        ),
        SizedBox(height: 32),
        _UserMessage(
          text:
              'Saya ingin modifikasi untuk bentuk tas pegangangan tasnya lebih setengah lingkaran',
        ),
        SizedBox(height: 36),
        _AiMessage(
          text:
              'Ide yang bagus! baiklah saya akan memberikan kamu referensi desainnya sesuai yang kamu minta',
        ),
        SizedBox(height: 18),
        _ChatImageCard(
          imagePath: 'assets/images/analysis/history_result_circle.jpg',
          title: 'The Manhattan',
          subtitle: 'Circle',
          downloadFileName: 'the-manhattan-circle.jpg',
        ),
        SizedBox(height: 34),
        _UserMessage(text: 'OKE INI BAGUUSS! TERIMA KASIH'),
      ],
    );
  }
}

class _FreshConversation extends StatelessWidget {
  const _FreshConversation();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _UserMessage(
          text:
              'Saya ingin mendesain koleksi pakaian premium untuk diekspor ke pasar Amerika Serikat. Estetikanya harus modern, minimalis, dan menggunakan bahan ramah lingkungan, tapi potongannya tetap terlihat modis dan cocok untuk dipakainya di area urban (perkotaan) di sana.',
        ),
        const SizedBox(height: 34),
        const _AiMessage(
          text:
              'Pilihan yang menarik. Untuk pasar AS, kita bisa mengangkat konsep Eco-Utility Minimalist. Kita buat lini pakaian dasar (essential pieces) seperti oversized blazer atau unisex trench coat menggunakan bahan campuran rami organik (organic hemp) dan katun daur ulang dengan warna-warna bumi (earthy tones) yang netral. Potongannya longgar, nyaman, tapi punya struktur yang tegas. Berikut adalah draf pertama untuk desain pakaiannya',
        ),
        const SizedBox(height: 18),
        const _ChatImageCard(
          imagePath: 'assets/images/chat/chat_jacket_a.png',
          title: 'Eco-Utility Essential',
        ),
        const SizedBox(height: 34),
        const _UserMessage(
          text:
              'Bagus sekali! Tapi karakter konsumen AS biasanya suka gaya yang sedikit lebih berani (bold) dan fungsional. Bisakah kita buat desainnya lebih praktis, mungkin ditambahkan detail saku utilitarian (saku kargo tersembunyi) dan aksen warna kontras yang khas seperti navy blue atau terracotta?',
        ),
        const SizedBox(height: 34),
        const _AiMessage(
          text:
              'Tentu. Menambahkan elemen utilitarian seperti saku taktis yang menyatu rapi dengan desain minimalis sangat cocok dengan budaya AS yang dinamis dan menyukai kepraktisan (function-meets-fashion). Memberi sentuhan warna terracotta atau navy blue juga akan membuatnya langsung menarik perhatian di etalase retail.',
        ),
        const SizedBox(height: 18),
        const _ChatImageCard(
          imagePath: 'assets/images/chat/chat_jacket_b.png',
          title: 'Eco-Utility',
          subtitle: 'Essential',
          downloadFileName: 'eco-utility-essential.png',
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Analisis sekarang',
          isFullWidth: true,
          size: AppButtonSize.sm,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AnalysisInputPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AiMessage extends StatelessWidget {
  const _AiMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrainAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: _MessageBubble(
            text: text,
            color: AppColors.system01,
            borderColor: AppColors.neutral03,
          ),
        ),
      ],
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.88,
        child: _MessageBubble(
          text: text,
          color: AppColors.neutral02,
          borderColor: AppColors.primary02,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.borderColor,
    required this.color,
    required this.text,
  });

  final Color borderColor;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F7A5900),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.neutral08,
          height: 1.45,
        ),
      ),
    );
  }
}

class _BrainAvatar extends StatelessWidget {
  const _BrainAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary08),
      ),
      child: Center(
        child: AppIcon(
          AppIcons.brain(PhosphorIconsStyle.fill),
          color: AppColors.primary05,
          dimension: 22,
        ),
      ),
    );
  }
}

class _ChatImageCard extends StatelessWidget {
  const _ChatImageCard({
    required this.imagePath,
    required this.title,
    this.downloadFileName,
    this.subtitle,
  });

  final String? downloadFileName;
  final String imagePath;
  final String? subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.system01,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral03),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F7A5900),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                imagePath,
                width: double.infinity,
                height: 206,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle == null ? title : '$title\n$subtitle',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.neutral08,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (downloadFileName != null)
                      _DownloadChatAssetButton(
                        assetPath: imagePath,
                        fileName: downloadFileName!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadChatAssetButton extends StatefulWidget {
  const _DownloadChatAssetButton({
    required this.assetPath,
    required this.fileName,
  });

  final String assetPath;
  final String fileName;

  @override
  State<_DownloadChatAssetButton> createState() =>
      _DownloadChatAssetButtonState();
}

class _DownloadChatAssetButtonState extends State<_DownloadChatAssetButton> {
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
        _isDownloading ? '...' : 'Unduh',
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.neutral08,
          fontWeight: FontWeight.w600,
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

class _ChatComposer extends StatelessWidget {
  const _ChatComposer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.system01,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A7A5900),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            AppIcon(
              AppIcons.addCircle(),
              color: AppColors.system07,
              dimension: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Tanyakan ide desain...',
                style: AppTypography.bodyMd.copyWith(color: AppColors.system06),
              ),
            ),
            AppIcon(AppIcons.mic(), color: AppColors.system07, dimension: 22),
            const SizedBox(width: 16),
            AppIcon(AppIcons.send(), color: AppColors.neutral08, dimension: 28),
          ],
        ),
      ),
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
