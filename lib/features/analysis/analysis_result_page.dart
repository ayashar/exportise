import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';
import 'design_reference_page.dart';

class AnalysisResultPage extends StatefulWidget {
  const AnalysisResultPage({super.key});

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  bool _isDetailsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 118),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ResultHeader(),
                  const SizedBox(height: 28),
                  Text(
                    'Hasil Analisis',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.primary05,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tas Anyaman Bali',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.neutral09,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analisis tren konsumen dan peluang ekspor untuk kategori kerajinan tangan tradisional',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.neutral08,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _RecommendationCard(),
                  const SizedBox(height: 24),
                  const _ScoreCard(),
                  const SizedBox(height: 24),
                  const _BrainsAdvice(),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Analisis Ulang',
                          variant: AppButtonVariant.ghost,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppButton(
                          label: 'Referensi Desain',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const DesignReferencePage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _DetailsAccordionHeader(
                    isExpanded: _isDetailsExpanded,
                    onTap: () {
                      setState(() {
                        _isDetailsExpanded = !_isDetailsExpanded;
                      });
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _isDetailsExpanded
                        ? const _AnalysisDetailsContent()
                        : const SizedBox(width: double.infinity),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsAccordionHeader extends StatelessWidget {
  const _DetailsAccordionHeader({
    required this.isExpanded,
    required this.onTap,
  });

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Rincian Analisis',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.primary05,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutral02,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary02),
            ),
            child: Center(
              child: AppIcon(
                isExpanded ? AppIcons.up() : AppIcons.dropdown(),
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

class _AnalysisDetailsContent extends StatelessWidget {
  const _AnalysisDetailsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const _SentimentCard(),
        const SizedBox(height: 22),
        const _SeasonCard(),
        const SizedBox(height: 22),
        const _FavoriteColorCard(),
        const SizedBox(height: 22),
        const _PopularCommentsCard(),
        const SizedBox(height: 22),
        const _PriceReferenceCard(),
        const SizedBox(height: 24),
        Text(
          'Celah Peluang',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _OpportunityCard(
          icon: _OpportunityIcon.truck,
          title: 'Kemasan Cantik Musim Panas',
          body:
              'Naikkan skor kemasan (72%) dengan kotak estetik bernuansa Earth Brown untuk memikat lonjakan pembeli tas anyaman menjelang tren April-Mei.',
        ),
        const SizedBox(height: 12),
        const _OpportunityCard(
          icon: _OpportunityIcon.sparkle,
          title: 'Sentuhan Katun Sage yang Unik',
          body:
              'Padukan anyaman Anda yang kuat (88%) dengan furing/tali katun berwarna Sage (23% permintaan) untuk menciptakan tas anyaman berdesain unik yang langka.',
        ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader();

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
        _CircleIconButton(
          icon: AppIcons.bell(),
          onTap: () => _openNotifications(context),
        ),
        const SizedBox(width: 12),
        _CircleIconButton(icon: AppIcons.download()),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.system01,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.neutral03),
        ),
        child: Center(
          child: AppIcon(icon, color: AppColors.primary05, dimension: 18),
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard();

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.primary05,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary04,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Amerika Serikat',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.primary08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Jepang',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary05,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Eropa',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary05,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Skor Kesiapan Ekspor',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const _StatusBadge(label: 'Siap', tone: _StatusTone.ready),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
              children: [
                TextSpan(
                  text: '82',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.primary05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' /100'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              _ScoreSegment(active: true),
              _ScoreSegment(active: true),
              _ScoreSegment(active: true),
              _ScoreSegment(active: true),
              _ScoreSegment(active: false),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Produk Anda memiliki potensi tinggi karena keselarasan material dengan tren ramah lingkungan di USA.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSegment extends StatelessWidget {
  const _ScoreSegment({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 7,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary04 : AppColors.neutral03,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _BrainsAdvice extends StatelessWidget {
  const _BrainsAdvice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppColors.primary04, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary04,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                AppIcons.brain(PhosphorIconsStyle.fill),
                color: AppColors.primary08,
                dimension: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saran BrainS',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tas anyaman Anda sangat potensial dengan nilai Estetika (94%) dan Material (88%) yang luar biasa. Cukup perbaiki tampilan kemasan dan luncurkan produk sebelum April untuk menyapu bersih puncak pasar summer di Amerika Serikat.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    height: 1.25,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentCard extends StatelessWidget {
  const _SentimentCard();

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle(
            icon: Icons.insert_chart_outlined,
            title: 'Analisis Sentimen',
          ),
          SizedBox(height: 20),
          _MetricBar(label: 'Estetika', value: 0.94, percent: '94%'),
          SizedBox(height: 12),
          _MetricBar(label: 'Material', value: 0.88, percent: '88%'),
          SizedBox(height: 12),
          _MetricBar(label: 'Kemasan', value: 0.72, percent: '72%'),
          SizedBox(height: 18),
          _DetailBox(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.neutral09),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.neutral09,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.percent,
    required this.value,
  });

  final String label;
  final String percent;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.neutral08,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              percent,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.primary05,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.neutral03,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary04,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rincian',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppIcon(AppIcons.up(), color: AppColors.neutral08, dimension: 14),
            ],
          ),
          const SizedBox(height: 14),
          const _DetailParagraph(
            title: 'Estetika',
            text:
                '94% Konsumen global menunjukkan sentimen positif tinggi terhadap estetika produk pada market saat ini',
          ),
          const _DetailParagraph(
            title: 'Material',
            text:
                'Material produk di market global memperoleh tingkat kepuasan konsumen yang tinggi sebesar 88%',
          ),
          const _DetailParagraph(
            title: 'Kemasan',
            text:
                '72% Sentimen konsumen terhadap kemasan masih menunjukkan adanya ruang improvisasi pada market global',
          ),
        ],
      ),
    );
  }
}

class _DetailParagraph extends StatelessWidget {
  const _DetailParagraph({required this.text, required this.title});

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.primary05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard();

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: AppIcons.season(), title: 'Musim Permintaan'),
          const SizedBox(height: 28),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _MonthBar(month: 'Jan', height: 48),
                _MonthBar(month: 'Feb', height: 62),
                _MonthBar(month: 'Mar', height: 84),
                _MonthBar(month: 'Apr', height: 104, active: true),
                _MonthBar(month: 'Mei', height: 104, active: true),
                _MonthBar(month: 'Jun', height: 76),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Permintaan memuncak pada bulan April-Mei di Amerika Serikat untuk kategori pakaian',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.height,
    required this.month,
    this.active = false,
  });

  final bool active;
  final double height;
  final String month;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.neutral03 : AppColors.neutral02,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            month,
            style: AppTypography.bodySm.copyWith(
              color: active ? AppColors.primary05 : AppColors.neutral07,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteColorCard extends StatelessWidget {
  const _FavoriteColorCard();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SimpleSectionLabel('Warna Favorite'),
          SizedBox(height: 18),
          _ColorDemand(
            color: Color(0xFF9A541C),
            name: 'Earth Brown',
            demand: '42% Permintaan',
          ),
          SizedBox(height: 12),
          _ColorDemand(
            color: Color(0xFFF4EFD4),
            name: 'Natural Cream',
            demand: '35% Permintaan',
            bordered: true,
          ),
          SizedBox(height: 12),
          _ColorDemand(
            color: Color(0xFFA8B79A),
            name: 'Sage',
            demand: '23% Permintaan',
          ),
        ],
      ),
    );
  }
}

class _SimpleSectionLabel extends StatelessWidget {
  const _SimpleSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodySm.copyWith(
        color: AppColors.neutral08,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ColorDemand extends StatelessWidget {
  const _ColorDemand({
    required this.color,
    required this.demand,
    required this.name,
    this.bordered = false,
  });

  final bool bordered;
  final Color color;
  final String demand;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
            border: bordered ? Border.all(color: AppColors.neutral05) : null,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.neutral08,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              demand,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.neutral07,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PopularCommentsCard extends StatelessWidget {
  const _PopularCommentsCard();

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SimpleSectionLabel('Komentar Popular'),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              _KeywordChip('Bahan Katun'),
              _KeywordChip('Kemasan Cantik'),
              _KeywordChip('Bagus'),
              _KeywordChip('bentuk unik'),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary08),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.neutral08,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriceReferenceCard extends StatelessWidget {
  const _PriceReferenceCard();

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: AppIcons.currency(), title: 'Referensi Harga'),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _PriceBox(title: 'Eksklusif', value: 'Rp1jt - Rp1,4jt'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PriceBox(title: 'Umum', value: 'Rp280rb - 440rb'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sentuhan Budaya Jogja',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.primary05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Padukan furing tas dengan motif Batik atau Lurik bernuansa Earth Brown dan Sage untuk menciptakan kesan handcrafted eksklusif yang sangat bernilai di pasar AS.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral07,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.body,
    required this.icon,
    required this.title,
  });

  final String body;
  final _OpportunityIcon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary02),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.primary04,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                icon.data,
                color: AppColors.primary08,
                dimension: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _OpportunityIcon { sparkle, truck }

extension on _OpportunityIcon {
  IconData get data {
    return switch (this) {
      _OpportunityIcon.sparkle => AppIcons.sparkle(),
      _OpportunityIcon.truck => AppIcons.truck(),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.tone});

  final String label;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          color: tone.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _StatusTone { ready, repair, notReady }

extension on _StatusTone {
  Color get background {
    return switch (this) {
      _StatusTone.ready => AppColors.tertiary01,
      _StatusTone.repair => AppColors.secondary01,
      _StatusTone.notReady => AppColors.error02,
    };
  }

  Color get foreground {
    return switch (this) {
      _StatusTone.ready => AppColors.tertiary03,
      _StatusTone.repair => AppColors.secondary05,
      _StatusTone.notReady => AppColors.system01,
    };
  }
}

class _AnalysisSectionCard extends StatelessWidget {
  const _AnalysisSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}
