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
import '../analysis/analysis_input_page.dart';
import '../analysis/analysis_result_page.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = ApiRepository();
  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<_HomeData>(
              future: _homeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _HomeError(
                    onRetry: _reload,
                    message: _errorMessage(snapshot.error),
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return _HomeError(
                    onRetry: _reload,
                    message: 'Data beranda belum tersedia.',
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 28, 18, 118),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeHeader(user: data.user),
                      const SizedBox(height: 34),
                      _Greeting(user: data.user),
                      const SizedBox(height: 30),
                      _ExporterLevelCard(products: data.products),
                      const SizedBox(height: 26),
                      _InsightCard(product: data.latestProduct),
                      const SizedBox(height: 32),
                      _QuickActionGrid(),
                      const SizedBox(height: 34),
                      _SectionHeader(productCount: data.products.length),
                      const SizedBox(height: 16),
                      if (data.products.isEmpty)
                        const _EmptyProductsState()
                      else
                        Column(
                          children: data.products.map((product) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _AnalysisCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) => AnalysisResultPage(
                                        analysProductId: product.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
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

  Future<_HomeData> _loadData() async {
    final user = AppSession.instance.currentUser ?? await _repository.me();
    final products = await _repository.listAnalysisProducts();
    return _HomeData(
      latestProduct: products.isEmpty ? null : products.first,
      products: products,
      user: user,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _homeFuture = _loadData();
    });
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Gagal memuat beranda.';
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
  const _HomeHeader({required this.user});

  final ApiUser user;

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
              user.companyName.isEmpty ? user.fullName : user.companyName,
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
  const _Greeting({required this.user});

  final ApiUser user;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Halo! ${user.fullName}',
      style: AppTypography.headlineLg.copyWith(
        color: AppColors.neutral09,
        height: 1.1,
      ),
    );
  }
}

class _ExporterLevelCard extends StatelessWidget {
  const _ExporterLevelCard({required this.products});

  final List<AnalysisProduct> products;

  @override
  Widget build(BuildContext context) {
    final doneCount = products.where((product) => product.isDone).length;
    final pendingCount = products.length - doneCount;
    final progress = products.isEmpty ? 0.0 : doneCount / products.length;
    final title = products.isEmpty ? 'Akun baru' : 'Progress Analisis';
    final description = products.isEmpty
        ? 'Belum ada produk yang dianalisis. Mulai dari analisis pertama untuk membuat laporan ekspor.'
        : '$doneCount analisis selesai, $pendingCount masih diproses.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x147A5900),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral09,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
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
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.neutral03,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary04,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
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
  const _InsightCard({required this.product});

  final AnalysisProduct? product;

  @override
  Widget build(BuildContext context) {
    final title = product == null
        ? 'Mulai dari 0: buat analisis produk pertamamu.'
        : product!.isDone
        ? 'Analisis terakhir sudah siap. Buka detail untuk melihat report dan referensi desain.'
        : 'Analisis terakhir sedang diproses. Cek lagi sebentar lagi.';

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
                  title,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: product == null
                      ? 'Mulai analisis'
                      : 'Lihat hasil terakhir',
                  size: AppButtonSize.sm,
                  onPressed: () {
                    if (product == null) {
                      _openAnalysis(context);
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            AnalysisResultPage(analysProductId: product!.id),
                      ),
                    );
                  },
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
        Expanded(
          child: _QuickActionTile(
            icon: _QuickActionIcon.brain,
            label: 'Brain Studio',
            onTap: () => _openBrains(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: _QuickActionIcon.report,
            label: 'LaporanKu',
            onTap: () => _openReports(context),
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
  const _SectionHeader({required this.productCount});

  final int productCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Analisis Terbaru',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.neutral09,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$productCount item',
          style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
        ),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.onTap, required this.product});

  final VoidCallback onTap;
  final AnalysisProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.system01,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x127A5900),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary04,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AppIcon(
                  AppIcons.document(),
                  color: AppColors.primary08,
                  dimension: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.neutral09,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusDot(status: product.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.neutral08,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.neutral08,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AppButton(
                        label: product.isDone ? 'Buka hasil' : 'Tunggu hasil',
                        size: AppButtonSize.sm,
                        onPressed: onTap,
                      ),
                      const SizedBox(width: 10),
                      if (product.isProcessing)
                        Text(
                          product.message ?? 'Sedang diproses',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.neutral08,
                          ),
                        ),
                    ],
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

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status.toLowerCase() == 'done'
        ? AppColors.tertiary02
        : AppColors.secondary04;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral03),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral02,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondary08),
            ),
            child: Center(
              child: AppIcon(
                AppIcons.document(),
                color: AppColors.primary05,
                dimension: 24,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada riwayat analisis',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.neutral09,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hasil analisis, referensi desain, dan laporan ekspor akan muncul di sini setelah produk pertama dibuat.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Analisis produk pertama',
            size: AppButtonSize.sm,
            onPressed: () => _openAnalysis(context),
          ),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

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

class _HomeData {
  const _HomeData({
    required this.latestProduct,
    required this.products,
    required this.user,
  });

  final AnalysisProduct? latestProduct;
  final List<AnalysisProduct> products;
  final ApiUser user;
}
