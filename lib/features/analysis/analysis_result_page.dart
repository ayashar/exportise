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
import 'design_reference_page.dart';

class AnalysisResultPage extends StatefulWidget {
  const AnalysisResultPage({super.key, required this.analysProductId});

  final int analysProductId;

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  final _repository = ApiRepository();

  late Future<AnalysisProduct> _productFuture;
  bool _isDeleting = false;
  bool _isSchedulingAnalysis = false;
  bool _isDetailsExpanded = true;

  @override
  void initState() {
    super.initState();
    _productFuture = _repository.getAnalysisProduct(widget.analysProductId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<AnalysisProduct>(
              future: _productFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                    onRetry: _reload,
                    message: _errorMessage(snapshot.error),
                  );
                }

                final product = snapshot.data;
                if (product == null) {
                  return _ErrorState(
                    onRetry: _reload,
                    message: 'Data analisis kosong.',
                  );
                }

                final report = product.report ?? const <String, dynamic>{};
                final summary = _mapValue(report, 'summary');
                final sections = _listValue(report, 'sections');

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 118),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ResultHeader(
                        isDeleting: _isDeleting,
                        onDelete: () => _deleteProduct(product),
                        onRefresh: _reload,
                      ),
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
                        product.productName,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.neutral09,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.neutral08,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (product.isProcessing) ...[
                        _ProcessingBanner(message: product.message),
                        const SizedBox(height: 20),
                      ],
                      _SummaryCard(summary: summary, product: product),
                      const SizedBox(height: 20),
                      _ScoreCard(summary: summary, product: product),
                      const SizedBox(height: 20),
                      _ActionRow(
                        isSchedulingAnalysis: _isSchedulingAnalysis,
                        onAnalyze: () => _scheduleAnalysis(product),
                        onDesignReferences: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => DesignReferencePage(
                                analysProductId: product.id,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Rincian Analisis',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.primary05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ExpandableSectionHeader(
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
                            ? Column(
                                children: [
                                  const SizedBox(height: 18),
                                  _SectionRenderer(sections: sections),
                                  const SizedBox(height: 20),
                                  _DesignReferencesSection(
                                    references: product.designReferences,
                                    onOpenAll: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              DesignReferencePage(
                                                analysProductId: product.id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
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

  Future<void> _reload() async {
    setState(() {
      _productFuture = _repository.getAnalysisProduct(widget.analysProductId);
    });
  }

  Future<void> _deleteProduct(AnalysisProduct product) async {
    if (_isDeleting) {
      return;
    }

    setState(() => _isDeleting = true);

    try {
      await _repository.deleteAnalysisProduct(product.id);
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produk dihapus.')));
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty ? 'Gagal menghapus produk' : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus produk.')));
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _scheduleAnalysis(AnalysisProduct product) async {
    if (_isSchedulingAnalysis) {
      return;
    }

    setState(() => _isSchedulingAnalysis = true);

    try {
      final response = await _repository.analyzeProduct(product.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _messageFromResponse(response) ?? 'Analisis dijadwalkan.',
          ),
        ),
      );
      await _reload();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty
                ? 'Gagal menjadwalkan analisis'
                : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menjadwalkan analisis.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSchedulingAnalysis = false);
      }
    }
  }

  String? _messageFromResponse(Map<String, dynamic> response) {
    final message = response['message'];
    if (message == null) {
      return null;
    }

    return message.toString();
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Gagal memuat hasil analisis.';
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.isDeleting,
    required this.onDelete,
    required this.onRefresh,
  });

  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

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
        _CircleIconButton(
          icon: AppIcons.bell(),
          onTap: () => _openNotifications(context),
        ),
        const SizedBox(width: 12),
        _CircleIconButton(icon: AppIcons.refresh(), onTap: onRefresh),
        const SizedBox(width: 12),
        _CircleIconButton(
          icon: AppIcons.download(),
          onTap: isDeleting ? null : onDelete,
        ),
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

class _ProcessingBanner extends StatelessWidget {
  const _ProcessingBanner({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary08,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message ?? 'Analisis sedang diproses, silakan cek kembali nanti',
        style: AppTypography.bodySm.copyWith(
          color: AppColors.neutral09,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.product});

  final AnalysisProduct product;
  final Map<String, dynamic>? summary;

  @override
  Widget build(BuildContext context) {
    final market = _mapValue(summary, 'recommended_market');
    final exportReadiness = _mapValue(summary, 'export_readiness');

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.primary05,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _string(summary, 'title').isEmpty
                ? product.productName
                : _string(summary, 'title'),
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral09,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _string(summary, 'subtitle').isEmpty
                ? 'Analisis tren konsumen dan peluang ekspor'
                : _string(summary, 'subtitle'),
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary04,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Pasar utama: ${_string(market, 'primary').isEmpty ? 'Belum tersedia' : _string(market, 'primary')}',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.primary08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_listValue(market, 'alternatives').isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _stringList(
                _listValue(market, 'alternatives'),
              ).map((item) => _ChipLabel(item)).toList(),
            ),
          if (_mapValue(exportReadiness, 'score') != null) ...[
            const SizedBox(height: 18),
            Text(
              'Skor kesiapan: ${_num(exportReadiness, 'score').round()}/100',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.neutral08,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _num(exportReadiness, 'score') / 100,
                minHeight: 8,
                backgroundColor: AppColors.neutral03,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary04,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _string(exportReadiness, 'note'),
              style: AppTypography.bodySm.copyWith(
                color: AppColors.neutral08,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.summary, required this.product});

  final AnalysisProduct product;
  final Map<String, dynamic>? summary;

  @override
  Widget build(BuildContext context) {
    final exportReadiness = _mapValue(summary, 'export_readiness');
    final score = _num(exportReadiness, 'score');
    final label = _string(exportReadiness, 'label').isEmpty
        ? product.status
        : _string(exportReadiness, 'label');

    return _SectionCard(
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
              _StatusBadge(label: label.isEmpty ? 'Belum ada' : label),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
              children: [
                TextSpan(
                  text: score.toStringAsFixed(0),
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
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 7,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: index < (score / 20).ceil()
                        ? AppColors.primary04
                        : AppColors.neutral03,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _string(exportReadiness, 'note').isEmpty
                ? 'Produk Anda memiliki potensi tinggi berdasarkan data yang dikirim.'
                : _string(exportReadiness, 'note'),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isSchedulingAnalysis,
    required this.onAnalyze,
    required this.onDesignReferences,
  });

  final bool isSchedulingAnalysis;
  final VoidCallback onAnalyze;
  final VoidCallback onDesignReferences;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Analisis Ulang',
            variant: AppButtonVariant.ghost,
            isLoading: isSchedulingAnalysis,
            onPressed: onAnalyze,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppButton(
            label: 'Referensi Desain',
            onPressed: onDesignReferences,
          ),
        ),
      ],
    );
  }
}

class _ExpandableSectionHeader extends StatelessWidget {
  const _ExpandableSectionHeader({
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
              'Detail Analisis',
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

class _SectionRenderer extends StatelessWidget {
  const _SectionRenderer({required this.sections});

  final List<dynamic> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const _EmptySection(
        title: 'Belum ada detail tambahan dari report ini.',
      );
    }

    return Column(
      children: sections.map((section) {
        final map = _asMap(section);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _SectionCard(child: _buildSection(map)),
        );
      }).toList(),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final type = _string(section, 'type');
    final title = _string(section, 'title');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.isEmpty ? type : title,
          style: AppTypography.headlineSm.copyWith(color: AppColors.neutral09),
        ),
        const SizedBox(height: 14),
        switch (type) {
          'brainstorm' => _BulletItemList(items: _nestedItems(section)),
          'sentiment_breakdown' => _MetricList(
            items: _nestedItems(section),
            metricKey: 'aspect',
            valueKey: 'value',
          ),
          'seasonality' => _MetricList(
            items: _nestedItems(section),
            metricKey: 'month',
            valueKey: 'value',
          ),
          'favorite_colors' => _MetricList(
            items: _nestedItems(section),
            metricKey: 'name',
            valueKey: 'value',
          ),
          'popular_comments' => _ChipWrap(
            items: _stringList(_listValue(section, 'items')),
          ),
          'pricing_reference' => _PricingList(items: _nestedItems(section)),
          'opportunities' => _BulletItemList(items: _nestedItems(section)),
          'sources' => _SourceList(items: _nestedItems(section)),
          _ => Text(
            _string(section, 'note').isEmpty
                ? 'Tidak ada data tambahan.'
                : _string(section, 'note'),
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
        },
      ],
    );
  }
}

class _DesignReferencesSection extends StatelessWidget {
  const _DesignReferencesSection({
    required this.onOpenAll,
    required this.references,
  });

  final VoidCallback onOpenAll;
  final List<DesignReference> references;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Design References',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.neutral09,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenAll,
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (references.isEmpty)
            const _EmptySection(
              title: 'Belum ada design reference untuk analisis ini.',
            )
          else
            Column(
              children: references
                  .map(
                    (reference) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReferenceCard(reference: reference),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({required this.reference});

  final DesignReference reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral01,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral03),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reference.title,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            reference.description,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          _ChipWrap(items: reference.tags),
        ],
      ),
    );
  }
}

class _PricingList extends StatelessWidget {
  const _PricingList({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptySection(title: 'Tidak ada referensi harga.');
    }

    return Column(
      children: items.map((item) {
        final map = _asMap(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.neutral02,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _string(map, 'tier'),
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _string(map, 'price_range'),
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MetricList extends StatelessWidget {
  const _MetricList({
    required this.items,
    required this.metricKey,
    required this.valueKey,
  });

  final List<dynamic> items;
  final String metricKey;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptySection(title: 'Tidak ada metrik untuk ditampilkan.');
    }

    return Column(
      children: items.map((item) {
        final map = _asMap(item);
        final value = _num(map, valueKey).clamp(0.0, 1.0).toDouble();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _string(map, metricKey),
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${(value * 100).round()}%',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.primary05,
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
          ),
        );
      }).toList(),
    );
  }
}

class _BulletItemList extends StatelessWidget {
  const _BulletItemList({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptySection(
        title: 'Tidak ada item yang bisa ditampilkan.',
      );
    }

    return Column(
      children: items.map((item) {
        final map = _asMap(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.neutral02,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _string(map, 'title').isEmpty
                      ? _string(map, 'id')
                      : _string(map, 'title'),
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _string(map, 'content'),
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SourceList extends StatelessWidget {
  const _SourceList({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptySection(title: 'Tidak ada sumber data.');
    }

    return Column(
      children: items.map((item) {
        final map = _asMap(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.primary04),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _string(map, 'name').isEmpty
                      ? _string(map, 'product_id')
                      : _string(map, 'name'),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => _ChipLabel(item)).toList(),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.label);

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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary04,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.primary08,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x127A5900),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

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

Map<String, dynamic>? _mapValue(Map<String, dynamic>? json, String key) {
  if (json == null) {
    return null;
  }

  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((dynamic mapKey, dynamic mapValue) {
      return MapEntry(mapKey.toString(), mapValue);
    });
  }

  return null;
}

List<dynamic> _listValue(Map<String, dynamic>? json, String key) {
  if (json == null) {
    return const [];
  }

  final value = json[key];
  if (value is List) {
    return value;
  }
  return const [];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((dynamic mapKey, dynamic mapValue) {
      return MapEntry(mapKey.toString(), mapValue);
    });
  }

  return <String, dynamic>{};
}

String _string(Map<String, dynamic>? json, String key) {
  if (json == null) {
    return '';
  }

  final value = json[key];
  return value == null ? '' : value.toString();
}

double _num(Map<String, dynamic>? json, String key) {
  if (json == null) {
    return 0;
  }

  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _stringList(List<dynamic> items) {
  return items.map((item) => item.toString()).toList();
}

List<dynamic> _nestedItems(Map<String, dynamic> section) {
  final items = section['items'];
  if (items is List) {
    return items;
  }
  return const [];
}
