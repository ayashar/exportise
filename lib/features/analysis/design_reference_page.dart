import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_models.dart';
import '../../core/api/api_repository.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_dropdown_field.dart';
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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();

  late Future<_DesignReferenceData> _dataFuture;
  bool _isSubmitting = false;
  String? _sortOrder;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _DesignHeader(),
                      const SizedBox(height: 30),
                      _DesignTitle(product: data.product),
                      const SizedBox(height: 20),
                      _CreateReferenceCard(
                        descriptionController: _descriptionController,
                        imageUrlController: _imageUrlController,
                        isSubmitting: _isSubmitting,
                        onCreate: () => _createReference(data.product.id),
                        onSortOrderChanged: (value) =>
                            setState(() => _sortOrder = value),
                        sortOrderValue: _sortOrder,
                        tagsController: _tagsController,
                        titleController: _titleController,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Design References',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.primary05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (data.references.isEmpty)
                        const _EmptyState()
                      else
                        Column(
                          children: data.references
                              .map(
                                (reference) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _DesignReferenceCard(
                                    reference: reference,
                                  ),
                                ),
                              )
                              .toList(),
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

  Future<void> _createReference(int analysProductId) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final sortOrder = int.tryParse(_sortOrder ?? '') ?? 0;

    if (title.isEmpty || description.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title, deskripsi, dan image URL wajib diisi.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.createDesignReference(
        analysProductId: analysProductId,
        description: description,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
        tags: tags,
        title: title,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design reference berhasil ditambahkan.')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _tagsController.clear();
      setState(() => _sortOrder = null);
      await _refresh();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty
                ? 'Gagal menambahkan design reference'
                : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan design reference.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
  const _DesignTitle({required this.product});

  final AnalysisProduct product;

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
                product.productName,
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.neutral09,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.category,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.neutral08,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateReferenceCard extends StatelessWidget {
  const _CreateReferenceCard({
    required this.descriptionController,
    required this.imageUrlController,
    required this.isSubmitting,
    required this.onCreate,
    required this.onSortOrderChanged,
    required this.sortOrderValue,
    required this.tagsController,
    required this.titleController,
  });

  final TextEditingController descriptionController;
  final TextEditingController imageUrlController;
  final bool isSubmitting;
  final VoidCallback onCreate;
  final ValueChanged<String?> onSortOrderChanged;
  final String? sortOrderValue;
  final TextEditingController tagsController;
  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Design Reference',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.neutral09,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _LabeledTextField(
            label: 'Title',
            controller: titleController,
            hintText: 'Soft Minimal Knit',
          ),
          const SizedBox(height: 12),
          _LabeledTextField(
            label: 'Description',
            controller: descriptionController,
            hintText: 'Deskripsi referensi desain',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _LabeledTextField(
            label: 'Image URL',
            controller: imageUrlController,
            hintText: 'https://...',
          ),
          const SizedBox(height: 12),
          _LabeledTextField(
            label: 'Tags',
            controller: tagsController,
            hintText: 'cream, minimal, soft texture',
          ),
          const SizedBox(height: 12),
          AppDropdownField(
            hintText: 'Sort Order',
            items: const ['0', '1', '2', '3'],
            onChanged: onSortOrderChanged,
            value: sortOrderValue,
            textStyle: AppTypography.bodySm.copyWith(
              color: AppColors.neutral09,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Simpan Reference',
            isLoading: isSubmitting,
            isFullWidth: true,
            onPressed: isSubmitting ? null : onCreate,
          ),
        ],
      ),
    );
  }
}

class _DesignReferenceCard extends StatelessWidget {
  const _DesignReferenceCard({required this.reference});

  final DesignReference reference;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReferenceImage(imageUrl: reference.imageUrl),
          const SizedBox(height: 18),
          Text(
            reference.title,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral09,
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
          const SizedBox(height: 18),
          Text(
            'Tags',
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
        ],
      ),
    );
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
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 1.2,
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

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

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
      child: Padding(padding: const EdgeInsets.all(20), child: child),
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

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.controller,
    required this.hintText,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.tertiary05,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.tertiary06),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary04),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Text(
        'Belum ada design reference. Tambahkan satu dari form di atas.',
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
