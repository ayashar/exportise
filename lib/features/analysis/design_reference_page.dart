import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_models.dart';
import '../../core/api/api_repository.dart';
import '../../core/api/app_session.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

class DesignReferencePage extends StatefulWidget {
  const DesignReferencePage({super.key, required this.analysProductId});

  final int analysProductId;

  @override
  State<DesignReferencePage> createState() => _DesignReferencePageState();
}

class _DesignReferencePageState extends State<DesignReferencePage> {
  final _repository = ApiRepository();

  late Future<_DesignReferenceData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<_DesignReferenceData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                    message: _errorMessage(snapshot.error),
                    onRetry: _refresh,
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return _ErrorState(
                    message: 'Referensi desain belum tersedia.',
                    onRetry: _refresh,
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 124),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _DesignHeader(),
                      const SizedBox(height: 28),
                      _DesignTitle(product: data.product, onRefresh: _refresh),
                      const SizedBox(height: 26),
                      if (data.references.isEmpty)
                        const _EmptyState()
                      else
                        Column(
                          children: [
                            for (
                              var index = 0;
                              index < data.references.length;
                              index++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 26),
                                child: _DesignReferenceCard(
                                  isBest: index == 0,
                                  reference: data.references[index],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
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

  Future<_DesignReferenceData> _loadData() async {
    final product = await _repository.getAnalysisProduct(
      widget.analysProductId,
    );
    final references = await _repository.listDesignReferences(
      widget.analysProductId,
    );
    return _DesignReferenceData(product: product, references: references);
  }

  Future<void> _refresh() async {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Gagal memuat design reference.';
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
              AppSession.instance.displayName,
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
  const _DesignTitle({required this.onRefresh, required this.product});

  final VoidCallback onRefresh;
  final AnalysisProduct product;

  @override
  Widget build(BuildContext context) {
    final market = _recommendedMarket(product);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: AppIcon(
                  AppIcons.bag(),
                  color: AppColors.neutral09,
                  dimension: 21,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.neutral09,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      market,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.neutral08,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: 'Ulangi',
          leadingIcon: AppIcons.refresh(),
          size: AppButtonSize.sm,
          variant: AppButtonVariant.outline,
          onPressed: onRefresh,
        ),
      ],
    );
  }

  String _recommendedMarket(AnalysisProduct product) {
    final summary = product.summary;
    final market = summary?['recommended_market'];
    if (market is Map) {
      final primary = market['primary'];
      if (primary != null && primary.toString().isNotEmpty) {
        return primary.toString();
      }
    }

    return product.category;
  }
}

class _DesignReferenceCard extends StatelessWidget {
  const _DesignReferenceCard({required this.isBest, required this.reference});

  final bool isBest;
  final DesignReference reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _ReferenceImage(imageUrl: reference.imageUrl),
              if (isBest)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary04,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Rekomendasi Terbaik',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.primary08,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formattedTitle(reference.title),
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  reference.description,
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
                  children: reference.tags.map((tag) => _Tag(tag)).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Unduh',
                        leadingIcon: AppIcons.download(),
                        size: AppButtonSize.sm,
                        variant: AppButtonVariant.ghost,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppButton(
                        label: 'Diskusi',
                        leadingIcon: AppIcons.chat(),
                        size: AppButtonSize.sm,
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

  String _formattedTitle(String title) {
    final parts = title.split(' ');
    if (parts.length <= 2) {
      return title;
    }

    return '${parts.take(2).join(' ')}\n${parts.skip(2).join(' ')}';
  }
}

class _ReferenceImage extends StatelessWidget {
  const _ReferenceImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final currentImageUrl = imageUrl;
    final isNetwork =
        currentImageUrl != null && currentImageUrl.startsWith('http');

    return ClipRRect(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: currentImageUrl == null || currentImageUrl.isEmpty
            ? Container(
                color: AppColors.neutral03,
                alignment: Alignment.center,
                child: AppIcon(
                  AppIcons.package(),
                  color: AppColors.neutral07,
                  dimension: 40,
                ),
              )
            : isNetwork
            ? Image.network(
                currentImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _ReferenceImageFallback(),
              )
            : Image.asset(
                currentImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _ReferenceImageFallback(),
              ),
      ),
    );
  }
}

class _ReferenceImageFallback extends StatelessWidget {
  const _ReferenceImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral03,
      alignment: Alignment.center,
      child: AppIcon(
        AppIcons.package(),
        color: AppColors.neutral07,
        dimension: 40,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral03),
      ),
      child: Text(
        'Belum ada rekomendasi desain. Jalankan analisis produk terlebih dahulu.',
        style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Coba lagi', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _DesignReferenceData {
  const _DesignReferenceData({required this.product, required this.references});

  final AnalysisProduct product;
  final List<DesignReference> references;
}
