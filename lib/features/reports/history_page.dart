import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_models.dart';
import '../../core/api/api_repository.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../analysis/analysis_input_page.dart';
import '../analysis/analysis_result_page.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _repository = ApiRepository();
  late Future<_HistoryData> _historyFuture;

  _HistoryTab _selectedTab = _HistoryTab.reference;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<_HistoryData>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _HistoryError(
                    message: _errorMessage(snapshot.error),
                    onRetry: _reload,
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return _HistoryError(
                    message: 'Riwayat kosong.',
                    onRetry: _reload,
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 28, 18, 118),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HistoryHeader(),
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
                            ? _ReferenceHistoryList(
                                referenceProduct: data.referenceProduct,
                              )
                            : _ResultHistoryList(products: data.products),
                      ),
                    ],
                  ),
                );
              },
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

  Future<_HistoryData> _loadData() async {
    final products = await _repository.listAnalysisProducts();
    AnalysisProduct? referenceProduct;
    for (final product in products) {
      if (product.designReferences.isNotEmpty) {
        referenceProduct = product;
        break;
      }
    }

    referenceProduct ??= products.isNotEmpty ? products.first : null;

    return _HistoryData(products: products, referenceProduct: referenceProduct);
  }

  Future<void> _reload() async {
    setState(() {
      _historyFuture = _loadData();
    });
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Gagal memuat riwayat.';
  }
}

class _HistoryHeader extends StatelessWidget {
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
  const _ReferenceHistoryList({required this.referenceProduct});

  final AnalysisProduct? referenceProduct;

  @override
  Widget build(BuildContext context) {
    final references =
        referenceProduct?.designReferences ?? const <DesignReference>[];

    return Column(
      key: const ValueKey('reference-history'),
      children: [
        if (referenceProduct == null)
          const _EmptyHistoryCard(
            message: 'Belum ada hasil analisis yang punya design reference.',
          )
        else if (references.isEmpty)
          const _EmptyHistoryCard(
            message: 'Analysis ini belum memiliki design reference.',
          )
        else
          ...references.map(
            (reference) => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: _ReferenceHistoryCard(
                reference: reference,
                analysProductId: referenceProduct!.id,
              ),
            ),
          ),
      ],
    );
  }
}

class _ResultHistoryList extends StatelessWidget {
  const _ResultHistoryList({required this.products});

  final List<AnalysisProduct> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('result-history'),
      children: [
        if (products.isEmpty)
          const _EmptyHistoryCard(
            message: 'Belum ada hasil analisis yang tersimpan.',
          )
        else
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _ResultHistoryCard(product: product),
            ),
          ),
      ],
    );
  }
}

class _ReferenceHistoryCard extends StatelessWidget {
  const _ReferenceHistoryCard({
    required this.reference,
    required this.analysProductId,
  });

  final int analysProductId;
  final DesignReference reference;

  @override
  Widget build(BuildContext context) {
    return _HistoryCardFrame(
      imagePath:
          reference.imageUrl ?? 'assets/images/analysis/design_ref_a.png',
      imageHeight: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reference.title,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral09,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reference.description,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reference.tags.map((tag) => _HistoryTag(tag)).toList(),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Buka Detail',
              size: AppButtonSize.sm,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        AnalysisResultPage(analysProductId: analysProductId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHistoryCard extends StatelessWidget {
  const _ResultHistoryCard({required this.product});

  final AnalysisProduct product;

  @override
  Widget build(BuildContext context) {
    return _HistoryCardFrame(
      imagePath: 'assets/images/analysis/history_result_circle.jpg',
      imageHeight: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.productName,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                  ),
                ),
              ),
              _StatusLabel(status: product.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: product.isDone ? 'Buka hasil' : 'Lihat proses',
              size: AppButtonSize.sm,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        AnalysisResultPage(analysProductId: product.id),
                  ),
                );
              },
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
  });

  final Widget child;
  final double imageHeight;
  final String imagePath;

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
              _HistoryImage(imagePath: imagePath, height: imageHeight),
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

class _HistoryImage extends StatelessWidget {
  const _HistoryImage({required this.imagePath, required this.height});

  final double height;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _FallbackHistoryImage(height: height);
        },
      );
    }

    return Image.asset(
      imagePath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

class _FallbackHistoryImage extends StatelessWidget {
  const _FallbackHistoryImage({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.neutral03,
      child: Center(
        child: AppIcon(
          AppIcons.package(),
          color: AppColors.neutral07,
          dimension: 36,
        ),
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

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDone = status.toLowerCase() == 'done';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDone ? AppColors.tertiary02 : AppColors.secondary04,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.primary08,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

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

class _HistoryData {
  const _HistoryData({required this.products, required this.referenceProduct});

  final List<AnalysisProduct> products;
  final AnalysisProduct? referenceProduct;
}

enum _HistoryTab { reference, result }
